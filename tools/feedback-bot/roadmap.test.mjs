import assert from "node:assert/strict";
import test from "node:test";
import {canModerate, draft} from "./roadmap.mjs";

const item = {
  guildId:"1571630020420702280", threadId:"1571630824439283793", moderatorId:"1571630021477670944",
  title:"Cargo stalls", category:"Bug", priority:"High",
  acceptance:"A shipment sells once after rerouting.", impact:"Players lose cargo when changing lines.",
};
test("only the configured moderator and guild are accepted", () => {
  const config = {guild:item.guildId, moderator:"moderator"};
  const event = {guild_id:item.guildId, member:{user:{id:item.moderatorId},roles:["moderator"]}};
  assert.equal(canModerate(event, config), true);
  assert.equal(canModerate({...event, guild_id:"wrong"}, config), false);
  assert.equal(canModerate({...event, member:{...event.member,roles:[]}}, config), false);
});
test("approval is idempotent and suggestions cannot insert contact data or links", () => {
  const entry = draft("approve", item);
  assert.equal(entry.id, "DD-" + item.threadId);
  assert.equal(draft("approve", item, entry), entry);
  assert.throws(() => draft("approve", {...item,title:"DM example@example.com"}));
  assert.throws(() => draft("approve", {...item,impact:"See https://example.com for instructions"}));
  assert.throws(() => draft("approve", {...item,threadId:"../../unrelated"}));
});
test("status updates require prior approval and a release tag", () => {
  const changing = {...item,status:"Released"};
  assert.throws(() => draft("status", changing));
  const entry = draft("approve", item);
  assert.throws(() => draft("status", changing, entry));
  assert.equal(draft("status", {...changing,tag:"v16.1"}, entry).release, "v16.1");
});
