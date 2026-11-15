import assert from "node:assert/strict";
import {spawn} from "node:child_process";
import {generateKeyPairSync, sign} from "node:crypto";
import {fileURLToPath} from "node:url";
import test from "node:test";

test("the service starts, answers signed pings and denies unsigned or non-moderator requests", async t => {
  const {privateKey, publicKey} = generateKeyPairSync("ed25519");
  const guild = "1571630020420702280";
  const thread = "1571630824439283793";
  const child = spawn(process.execPath, [fileURLToPath(new URL("./server.mjs", import.meta.url))], {
    env: {...process.env, PORT:"0", HOST:"127.0.0.1", FEEDBACK_DB_PATH:":memory:",
      DISCORD_PUBLIC_KEY:publicKey.export({type:"spki",format:"der"}).subarray(-32).toString("hex"),
      DISCORD_GUILD_ID:guild, DISCORD_FEEDBACK_FORUM_ID:thread, DISCORD_MODERATOR_ROLE_ID:"1571630021477670944",
      DISCORD_BOT_TOKEN:"local-test", GITHUB_REPOSITORY:"owner/tycoon", GITHUB_APP_ID:"1",
      GITHUB_INSTALLATION_ID:"2", GITHUB_APP_KEY:"not-used-in-this-test"},
    stdio:["ignore","pipe","pipe"], windowsHide:true,
  });
  t.after(() => child.kill());
  const port = await new Promise((resolve, reject) => {
    const clock = setTimeout(() => reject(Error("Local server did not start.")), 5000);
    child.once("error", error => { clearTimeout(clock); reject(error); });
    child.once("exit", code => { clearTimeout(clock); reject(Error("Server exited " + code)); });
    child.stdout.on("data", data => {
      const match = /listening on port (\d+)/.exec(data.toString());
      if (match) { clearTimeout(clock); resolve(match[1]); }
    });
  });
  function call(body, valid = true) {
    const json = JSON.stringify(body);
    const timestamp = String(Math.floor(Date.now()/1000));
    return fetch("http://127.0.0.1:" + port + "/discord/interactions", {
      method:"POST", body:json,
      headers:{"x-signature-timestamp":timestamp,
        "x-signature-ed25519":valid ? sign(null, Buffer.from(timestamp + json), privateKey).toString("hex") : "0".repeat(128)},
    });
  }
  assert.deepEqual(await (await call({type:1})).json(), {type:1});
  assert.equal((await call({type:1}, false)).status, 401);
  const denied = await (await call({id:"111111111111111111", type:2, guild_id:guild, channel_id:thread,
    member:{user:{id:"222222222222222222"},roles:[]},data:{name:"roadmap-approve"}})).json();
  assert.match(denied.data.content, /moderator/);
  assert.equal(denied.data.flags, 64);
});
