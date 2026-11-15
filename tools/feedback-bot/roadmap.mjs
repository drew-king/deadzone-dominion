export const categories = ["Bug", "Balance", "Accessibility", "Art", "Feature"];
export const priorities = ["Blocker", "High", "Normal", "Low"];
export const statuses = ["Planned", "In Progress", "Released"];
export const idPattern = /^\d{17,22}$/;

function text(value, min, max) {
  if (typeof value !== "string") throw Error("Missing required text.");
  const clean = value.trim();
  if (clean.length < min || clean.length > max || /[\u0000-\u001f\u007f]/.test(clean)
      || /https?:\/\/|discord\.gg|<[@#]|[\w.+-]+@[\w.-]+\.[a-z]{2,}|(?:\+?\d[ .-]?){9,}/i.test(clean)) {
    throw Error("Use short, plain text without links, mentions, email or phone numbers.");
  }
  return clean;
}

export function draft(action, input, current) {
  const {threadId, guildId, moderatorId} = input;
  if (![threadId, guildId, moderatorId].every(id => idPattern.test(id))) throw Error("Invalid Discord context.");
  const id = "DD-" + threadId;
  if (action === "approve") {
    if (current) return current;
    if (!categories.includes(input.category) || !priorities.includes(input.priority)) throw Error("Choose a category and priority.");
    return {
      id, threadId,
      thread: "https://discord.com/channels/" + guildId + "/" + threadId,
      title: text(input.title, 4, 90),
      category: input.category,
      priority: input.priority,
      impact: text(input.impact, 8, 350),
      acceptance: text(input.acceptance, 8, 350),
      target: text(input.target || "Unscheduled", 1, 48),
      status: "Approved", approvedBy: moderatorId,
    };
  }
  if (!current || current.id !== id || !statuses.includes(input.status)) throw Error("Approve this thread first and use a valid status.");
  if (current.status === "Released" && input.status !== "Released") throw Error("A released entry requires a new feedback thread for follow-up.");
  return {
    ...current, status: input.status, updatedBy: moderatorId,
    ...(input.status === "Released" ? {release: text(input.tag, 1, 60)} : {}),
  };
}

export function canModerate(interaction, config) {
  return interaction.guild_id === config.guild
    && idPattern.test(interaction.member?.user?.id || "")
    && interaction.member?.roles?.includes(config.moderator);
}
