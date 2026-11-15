import {readdirSync, readFileSync, writeFileSync} from "node:fs";
import {join} from "node:path";
import {idPattern} from "./roadmap.mjs";

const [directory = "docs/roadmap/feedback", hub = "Power-Up-Tycoon-Dev-Hub.html"] = process.argv.slice(2);
const entries = readdirSync(directory).filter(file => file.endsWith(".json")).sort().map(file => {
  const id = file.slice(0, -5);
  const entry = JSON.parse(readFileSync(join(directory, file), "utf8"));
  if (!idPattern.test(id) || entry.threadId !== id || entry.id !== "DD-" + id) {
    throw Error("Roadmap filename or ID mismatch: " + file);
  }
  const {title, category, priority, target, status, impact, acceptance} = entry;
  if (![title, category, priority, target, status, impact, acceptance].every(field => typeof field === "string")) {
    throw Error("Roadmap display fields must all be strings: " + file);
  }
  return {id: entry.id, title, category, priority, target, status, impact, acceptance};
});
const original = readFileSync(hub, "utf8");
const slot = /\/\* approved-feedback-start \*\/[\s\S]*?\/\* approved-feedback-end \*\//;
if (!slot.test(original)) throw Error("Dev Hub feedback slot is missing.");
const encoded = JSON.stringify(entries).replaceAll("<", "\\u003c");
const next = original.replace(slot, () => "/* approved-feedback-start */" + encoded + "/* approved-feedback-end */");
writeFileSync(hub, next, "utf8");
console.log(entries.length + " approved feedback entries in the Dev Hub.");
