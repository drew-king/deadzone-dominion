import { createServer } from "node:http";
import { createPublicKey, verify } from "node:crypto";
import { DatabaseSync } from "node:sqlite";
import { githubApi } from "./github.mjs";
import { canModerate, draft, idPattern } from "./roadmap.mjs";

function required(name, pattern) {
  const value = process.env[name];
  if (!value || (pattern && !pattern.test(value))) throw Error("Set " + name + " to a valid value.");
  return value;
}
const discord = {
  guild: required("DISCORD_GUILD_ID", idPattern),
  forum: required("DISCORD_FEEDBACK_FORUM_ID", idPattern),
  moderator: required("DISCORD_MODERATOR_ROLE_ID", idPattern),
  token: required("DISCORD_BOT_TOKEN"),
};
const publicKey = createPublicKey({
  key: Buffer.concat([Buffer.from("302a300506032b6570032100", "hex"), Buffer.from(required("DISCORD_PUBLIC_KEY", /^[0-9a-f]{64}$/i), "hex")]),
  format: "der", type: "spki",
});
const update = githubApi({
  repository: required("GITHUB_REPOSITORY", /^[\w.-]+\/[\w.-]+$/),
  base: "main", app: required("GITHUB_APP_ID", /^\d+$/),
  installation: required("GITHUB_INSTALLATION_ID", /^\d+$/),
  key: required("GITHUB_APP_KEY").replaceAll("\\n", "\n"),
});
const database = new DatabaseSync(required("FEEDBACK_DB_PATH"));
database.exec(`CREATE TABLE IF NOT EXISTS jobs(
  id TEXT PRIMARY KEY, body TEXT NOT NULL, run_at INTEGER NOT NULL,
  attempts INTEGER NOT NULL DEFAULT 0, state TEXT NOT NULL DEFAULT 'queued'
)`);
const add = database.prepare("INSERT OR IGNORE INTO jobs(id, body, run_at) VALUES(?, ?, ?)");
const queued = database.prepare("SELECT * FROM jobs WHERE state='queued' AND run_at <= ? ORDER BY rowid LIMIT 1");
const done = database.prepare("UPDATE jobs SET state=? WHERE id=?");
const retry = database.prepare("UPDATE jobs SET run_at=?, attempts=attempts+1 WHERE id=?");

async function discordRequest(path, body) {
  const response = await fetch("https://discord.com/api/v10" + path, {
    method: body ? "POST" : "GET", signal: AbortSignal.timeout(6000),
    headers: {Authorization: "Bot " + discord.token, "Content-Type": "application/json"},
    body: body && JSON.stringify(body),
  });
  if (!response.ok) throw Error("Discord API returned " + response.status);
  return response.json();
}
async function process(job) {
  const action = JSON.parse(job.body);
  const channel = await discordRequest("/channels/" + action.threadId);
  if (channel.parent_id !== discord.forum || channel.guild_id !== discord.guild || ![10,11,12].includes(channel.type)) {
    done.run("wrong-channel", job.id);
    return;
  }
  let message;
  if (action.action === "reject") {
    message = "Moderator rejected this suggestion. No roadmap change was made.";
  } else {
    const result = await update(action);
    if (result.url) console.info("Roadmap PR", result.id, result.url);
    message = result.url ? result.id + " · Roadmap update queued for staff review."
      : result.id + " · Already on the roadmap as " + result.status + ".";
  }
  await discordRequest("/channels/" + action.threadId + "/messages",
    {content: message, allowed_mentions: {parse: []}, nonce: job.id, enforce_nonce: true});
  done.run("done", job.id);
}
let busy = false;
setInterval(async () => {
  if (busy) return;
  const job = queued.get(Date.now());
  if (!job) return;
  busy = true;
  try { await process(job); }
  catch (error) {
    console.error("Feedback job", job.id, error.message);
    if (job.attempts >= 6) done.run("needs-review", job.id);
    else retry.run(Date.now() + Math.min(900_000, 5000 * 2 ** job.attempts), job.id);
  } finally { busy = false; }
}, 1500).unref();

function reply(response, content) {
  response.writeHead(200, {"content-type": "application/json"});
  response.end(JSON.stringify({type: 4, data: {content, flags: 64, allowed_mentions: {parse: []}}}));
}
const actions = {"roadmap-approve": "approve", "roadmap-status": "status", "roadmap-reject": "reject"};
const server = createServer(async (request, response) => {
  if (request.method !== "POST" || request.url !== "/discord/interactions") {
    response.writeHead(404).end();
    return;
  }
  try {
    const chunks = [];
    let bytes = 0;
    for await (const chunk of request) {
      bytes += chunk.length;
      if (bytes > 65536) { response.writeHead(413).end(); return; }
      chunks.push(chunk);
    }
    const body = Buffer.concat(chunks);
    const time = request.headers["x-signature-timestamp"];
    const signature = request.headers["x-signature-ed25519"];
    if (!/^\d{10,12}$/.test(time || "") || Math.abs(Date.now() - Number(time) * 1000) > 300_000
        || !/^[0-9a-f]{128}$/i.test(signature || "")
        || !verify(null, Buffer.concat([Buffer.from(time), body]), publicKey, Buffer.from(signature, "hex"))) {
      response.writeHead(401).end();
      return;
    }
    const interaction = JSON.parse(body.toString("utf8"));
    if (interaction.type === 1) {
      response.writeHead(200, {"content-type": "application/json"}).end('{"type":1}');
      return;
    }
    const action = actions[interaction.data?.name];
    if (!action || interaction.type !== 2 || !canModerate(interaction, discord)) {
      reply(response, "Only the configured moderator role may use this command.");
      return;
    }
    if (!idPattern.test(interaction.id || "") || !idPattern.test(interaction.channel_id || "")
        || (interaction.channel?.parent_id && interaction.channel.parent_id !== discord.forum)) {
      reply(response, "Run this command inside a post in #feedback.");
      return;
    }
    const fields = Object.fromEntries((interaction.data.options || []).map(field => [field.name, field.value]));
    const item = {
      ...fields, action, guildId: discord.guild, threadId: interaction.channel_id,
      requestId: interaction.id, moderatorId: interaction.member.user.id,
    };
    if (action === "approve") {
      try { draft(action, item); } catch (error) { reply(response, error.message); return; }
    }
    add.run(item.requestId, JSON.stringify(item), Date.now());
    reply(response, "Queued. The bot will post the roadmap result in this thread.");
  } catch {
    if (!response.headersSent) response.writeHead(400).end();
  }
});
server.requestTimeout = 10_000;
server.listen(Number(process.env.PORT || 8080), "0.0.0.0");
