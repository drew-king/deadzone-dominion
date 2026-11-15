import { categories, priorities, statuses } from "./roadmap.mjs";

const field = (name, description, required = true, choices) => ({
  name, description, required, type: 3,
  ...(choices && { choices: choices.map(value => ({name: value, value})) }),
});
const commands = [
  {name: "roadmap-approve", description: "Send this feedback thread to roadmap review.", options: [
    field("title", "Short title"), field("category", "Feedback category", true, categories),
    field("priority", "Priority", true, priorities),
    field("impact", "What should change and why?"), field("acceptance", "What proves the fix is complete?"),
    field("target", "Target release or Unscheduled", false),
  ]},
  {name: "roadmap-status", description: "Propose a roadmap status change for this thread.", options: [
    field("status", "New status", true, statuses),
    field("tag", "Published GitHub release tag required for Released", false),
  ]},
  {name: "roadmap-reject", description: "Close an unapproved suggestion without adding it to the roadmap."},
];
const {DISCORD_APPLICATION_ID: app, DISCORD_GUILD_ID: guild, DISCORD_BOT_TOKEN: token} = process.env;
if (![app, guild].every(value => /^\d{17,22}$/.test(value || "")) || !token) {
  throw Error("Set the app ID, guild ID and bot token in the deployment environment.");
}
for (const command of commands) {
  const response = await fetch("https://discord.com/api/v10/applications/" + app + "/guilds/" + guild + "/commands", {
    method: "POST", headers: {Authorization: "Bot " + token, "Content-Type": "application/json"},
    body: JSON.stringify({...command, default_member_permissions: "0"}),
  });
  if (!response.ok) throw Error("Command registration failed with HTTP " + response.status);
  console.log("Registered " + command.name);
}
