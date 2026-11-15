import assert from "node:assert/strict";
import {generateKeyPairSync} from "node:crypto";
import test from "node:test";
import {githubApi} from "./github.mjs";

test("an approval retries after an outage and never creates a duplicate pull request", async () => {
  const {privateKey} = generateKeyPairSync("rsa", {modulusLength: 2048});
  const config = {repository:"owner/tycoon",base:"main",app:"1",installation:"2",key:privateKey};
  const entry = {action:"approve",requestId:"111111111111111111",threadId:"222222222222222222",
    guildId:"333333333333333333",moderatorId:"444444444444444444",
    title:"Broken conveyor",category:"Bug",priority:"High",
    impact:"Cargo stops after buying a belt.",acceptance:"Cargo sells once after extending the belt."};
  const branch = "feedback/discord-" + entry.threadId + "-approve";
  const ok = data => Response.json(data);
  const bad = status => Response.json({}, {status});
  let hasBranch = false, committed, closed = false, reopened = 0, pullCount = 0;
  const push = githubApi(config, async (url, options) => {
    const path = new URL(url);
    if (path.pathname.includes("/access_tokens")) return ok({token:"test",expires_at:"9999-01-01T00:00:00Z"});
    if (path.pathname.endsWith("/pulls") && options.method === "GET") {
      return ok(pullCount ? [{html_url:"https://github.com/owner/tycoon/pull/1", number:1, state:closed?"closed":"open"}] : []);
    }
    if (path.pathname.endsWith("/pulls/1") && options.method === "PATCH") { closed = false; reopened++; return ok({}); }
    if (path.pathname.endsWith("/pulls/1")) return ok({merged:false});
    if (path.pathname.endsWith("/git/ref/heads/main")) return ok({object:{sha:"base"}});
    if (path.pathname.endsWith("/git/ref/heads/" + branch)) return ok({object:{sha:"base"}});
    if (path.pathname.endsWith("/git/refs")) {
      if (hasBranch) return bad(422);
      hasBranch = true;
      return ok({});
    }
    if (path.pathname.includes("/contents/")) {
      if (options.method === "PUT") { committed = JSON.parse(options.body).content; return ok({}); }
      return path.searchParams.get("ref") === branch && committed ? ok({content:committed,sha:"file"}) : bad(404);
    }
    if (path.pathname.endsWith("/pulls")) {
      if (pullCount === 0 && !push.attempted) { push.attempted = true; return bad(503); }
      pullCount++;
      return ok({html_url:"https://github.com/owner/tycoon/pull/1"});
    }
    throw Error("Unexpected request");
  });
  await assert.rejects(push(entry), /503/);
  const retried = await push(entry);
  const duplicate = await push({...entry,requestId:"555555555555555555"});
  assert.equal(retried.url, duplicate.url);
  closed = true;
  await push({...entry,requestId:"666666666666666666"});
  assert.equal(reopened, 1);
  assert.equal(pullCount, 1);
  assert.equal(JSON.parse(Buffer.from(committed,"base64").toString()).threadId, entry.threadId);
});
