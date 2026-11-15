import { createSign } from "node:crypto";
import { draft } from "./roadmap.mjs";

const baseUrl = "https://api.github.com";
const encode = value => Buffer.from(JSON.stringify(value)).toString("base64url");

export function githubApi(config, fetcher = fetch) {
  const repo = "/repos/" + config.repository;
  let cached;
  async function request(path, token, method = "GET", body) {
    const result = await fetcher(baseUrl + path, {
      method, signal: AbortSignal.timeout(8000),
      headers: { Authorization: "Bearer " + token, Accept: "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28",
        ...(body !== undefined && {"Content-Type": "application/json"}) },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    if (!result.ok) {
      const error = Error("GitHub " + method + " returned " + result.status);
      error.status = result.status;
      throw error;
    }
    return result.json();
  }
  async function installationToken() {
    if (cached && Date.parse(cached.expires_at) - Date.now() > 60_000) return cached.token;
    const now = Math.floor(Date.now() / 1000);
    const unsigned = encode({alg: "RS256", typ: "JWT"}) + "." + encode({iat: now - 30, exp: now + 540, iss: config.app});
    const signer = createSign("RSA-SHA256");
    signer.update(unsigned);
    cached = await request("/app/installations/" + config.installation + "/access_tokens",
      unsigned + "." + signer.sign(config.key).toString("base64url"), "POST",
      {repositories: [config.repository.split("/")[1]], permissions: {contents: "write", pull_requests: "write"}});
    return cached.token;
  }
  return async function update(entry) {
    const token = await installationToken();
    const owner = config.repository.split("/")[0];
    const path = "docs/roadmap/feedback/" + entry.threadId + ".json";
    const branch = "feedback/discord-" + entry.threadId + "-" + (entry.action === "approve" ? "approve" : entry.requestId);
    const file = repo + "/contents/" + path;
    async function getFile(ref) {
      try {
        return await request(file + "?ref=" + encodeURIComponent(ref), token);
      } catch (error) {
        if (error.status !== 404) throw error;
      }
    }
    const previousPull = await request(repo + "/pulls?state=all&head=" + encodeURIComponent(owner + ":" + branch), token);
    if (previousPull.length) {
      const pull = previousPull[0];
      if (pull.state === "closed" && !pull.merged_at) {
        const details = await request(repo + "/pulls/" + pull.number, token);
        if (!details.merged) await request(repo + "/pulls/" + pull.number, token, "PATCH", {state: "open"});
      }
      return {id: "DD-" + entry.threadId, url: pull.html_url};
    }
    const base = await request(repo + "/git/ref/heads/" + config.base, token);
    const original = await getFile(config.base);
    const current = original && JSON.parse(Buffer.from(original.content, "base64").toString());
    const next = draft(entry.action, entry, current);
    if (next === current) return {id: current.id, status: current.status};
    if (next.status === "Released") {
      const release = await request(repo + "/releases/tags/" + encodeURIComponent(next.release), token);
      const ids = release.body?.match(/\bDD-\d{17,22}\b/g) || [];
      if (release.draft || !release.published_at || !ids.includes(next.id)) throw Error("Publish a release that references this roadmap ID first.");
    }
    try {
      await request(repo + "/git/refs", token, "POST", {ref: "refs/heads/" + branch, sha: base.object.sha});
    } catch (error) {
      if (error.status !== 422) throw error;
      await request(repo + "/git/ref/heads/" + branch, token);
    }
    const branchFile = await getFile(branch);
    const content = Buffer.from(JSON.stringify(next, null, 2) + "\n").toString("base64");
    if (branchFile?.content?.replace(/\s/g, "") !== content) {
      await request(file, token, "PUT", {
        message: "Record " + next.id + " as " + next.status,
        branch, content, ...(branchFile && {sha: branchFile.sha}),
      });
    }
    const pull = await request(repo + "/pulls", token, "POST", {
      title: next.id + " — " + next.title, head: branch, base: config.base,
      body: "Moderator-approved feedback. Review the roadmap entry before merging.",
    });
    return {id: next.id, url: pull.html_url};
  };
}
