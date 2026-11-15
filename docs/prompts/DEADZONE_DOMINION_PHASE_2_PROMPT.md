# Deadzone Dominion: Powers Tycoon — Phase 2 execution prompt

Open this project in Codex and execute Phase 2 in the real Roblox project. Read `DEADZONE_DOMINION_PHASE_1_MASTER_PROMPT.md` for the game design and `DEVELOPMENT_STATUS.md` for the verified baseline. This prompt defines the current implementation scope. Keep updates direct, dense, and concise.

## Starting point

- Use `C:\Users\GoldD\OneDrive\Documents\ChatGPT\Roblox Game` and the existing **Power-Up tycoon** Studio place, ID `96511474175721`. VS Code, Rojo 7.7.1, Git, and Studio are installed. Live sync was verified at `localhost:35011`. Check the existing connection. If the server is stopped and the port is free, run `.\tools\rojo\rojo.exe serve --port 35011` from the project root.
- Phase 1 is accepted. Eight plots, claim and reclaim, teleport, respawn, and routes to Reactor Crown are in place. The owner confirmed separate plots can be owned simultaneously. Scripted gate routes took 12.3–13.7 seconds. Independent review scored 8/10. Git baseline is `f91dad7`.
- Inspect the actual working tree and Studio state. Reuse the existing Rojo mappings, plot ownership, station coordinates, eight identities, and client guide. Preserve existing Studio content and uncommitted work. Develop and test locally in Studio. Publishing the Roblox experience requires a separate request.

## Build the first playable tycoon economy

1. **Claim and produce.** Once a base is claimed, a starter generator begins producing Scrap Cash into that plot's collection buffer. Show production and collection through readable station labels and simple conveyor feedback. Keep payout independent of visual physics and cap decorative instances.
2. **Collect and spend.** Give the owner a working collector, a visible wallet and pending balance, and purchase pads with price and state. Implement at least one real construction upgrade and a visible production upgrade. Show what changed and what the next purchase unlocks. Use one reusable implementation across all eight plots.
3. **Equip and fight.** Add the first functional weapon station, one basic Roblox weapon, and basic damage, elimination, and respawn. Respect protected spawns. Keep station access, damage, firing cadence, and combat outcomes under server control. Show equipment and hit feedback to the player.
4. **Lay persistence groundwork.** Define a versioned data schema and an adapter for wallet and unlocked upgrades. Separate permanent progression from ownership, pending production, and other session state. Use isolated test data or a local mock for development. Treat a load failure distinctly from a new player and prevent failed loads from overwriting data. Document which persistence paths were actually verified.
5. **Tune the first minute.** Guide players from claim to collection to a meaningful first purchase and then toward equipment. Test the journey from fresh spawn. Measure time to first collection and purchase, and tune centralized values around observed friction. Keep the eight themes recognizable and make prompts and HUD readable on phone, desktop, and controller.

Use server validation for ownership, distance, affordability, prerequisites, and duplicate requests. Reserve purchases and deduct funds without a yielding gap. End the old owner's production when they leave, clear transient plot state, and verify that the next owner starts correctly. Keep full powers, zombie waves, live arena objectives, monetization, and broader progression systems for their planned phases.

## Build the custom Dominion Control admin panel

Create an in-game admin panel for the owner to manage live sessions and run repeatable playtests. Use a searchable player list, clear target and scope labels, and previews for broad or destructive changes. Show each action's result and any expiry.

| Tab | Controls |
| --- | --- |
| Players | Inspect a player's plot, wallet, upgrades, and active effects. Teleport to a plot or Reactor Crown, respawn, and grant timed invulnerability. |
| Economy | Grant, deduct, or set Scrap Cash. Inspect or clear pending generator output, grant upgrades, and tune production or costs for the current server. Preview bulk adjustments and show before and after balances. |
| Powers | Assign, swap, revoke, or temporarily lock any of the eight power identities. For implemented powers, tune parameters, reset cooldowns, and clear active effects. Show **Preview only** for powers whose gameplay is still deferred. |
| World | Pause production or combat, toggle friendly damage where applicable, control time of day, and send an announcement to the current server. Release or reset a plot with a preview of what will be cleared. |
| Playtest Lab | Provide presets for fresh join, first purchase, fully upgraded base, and combat sparring. Give test overrides an expiry and a visible test indicator. Offer before-and-after snapshots and rollback for reversible changes, with conflict checks so rollback preserves intervening player activity. |
| Audit | Filter actions by admin, player, category, and outcome. Record actor and target user IDs, scope, reason, timestamp, and relevant before and after values. |

- Authorize every command on the server by Roblox UserId. Verify the owner's UserId before granting access. Use separate permissions for owner, tester, and moderator if delegated access is needed. Keep the client responsible for presentation only. Validate arguments, targets, numeric bounds, and rate limits, and reuse the normal gameplay services for mutations.
- Default overrides to the current session. Use isolated test profiles for playtest presets. Restrict permanent economy changes to the owner, require a reason and explicit confirmation, and route them through the persistence layer only when it is ready. Preview target counts and impact before any mass action. Keep test-only tools restricted to Studio or approved private test servers.
- Verify with an authorized and a regular Studio client. Test that the regular client has no access, invalid requests leave game state unchanged, temporary overrides expire, money operations and plot resets affect only the intended scope, and audit records match the changes. Add admin usability and maintainability to the independent review and record which commands were verified.

## Research and collaboration

- Start with [Elemental Powers Tycoon](https://www.roblox.com/games/10253248401/Elemental-Powers-Tycoon). Benchmark comparable Roblox tycoons for claim-to-first-purchase flow, visible production, readable costs, and clear upgrade payoff. Use [Military Tycoon](https://www.roblox.com/games/7180042682/Military-Tycoon) for the connection between base progression and leaving the base. Carry [Zombie Uprising](https://www.roblox.com/games/4972091010/Zombie-Uprising) forward as a reference for the later survival phase.
- Record the source, observed mechanic, and specific adaptation. Distinguish storefront descriptions from mechanics observed in play. Adapt patterns within scope and use original assets and layouts.
- Ask focused follow-up questions when a decision materially affects gameplay or scope. Continue unrelated work while waiting. Use reversible defaults for economy values and report the assumptions.
- Work directly in the source and Studio when available. Ask for local UI help only when needed. Keep `DEVELOPMENT_STATUS.md` current and update the existing **Power-Up Tycoon | Dev Hub** after meaningful milestones. Sites version 1 is the saved unpublished baseline. Use the existing Site, save updated versions without deployment, and verify the save before reporting it. If the Site is inaccessible, update the local HTML draft and identify the blocker.

## Test and review

- Verify Rojo build and live sync. In Studio, test the first player journey, generator timing, collection, exact wallet deductions, insufficient funds, repeat purchases, construction, weapon equip, elimination, respawn, and persistence round trips in the available test environment.
- Use two Studio clients to check separate ownership and balances, owner-only collection and purchases, repeat or competing inputs, combat, and reset on leave and reclaim. Recheck Phase 1 claims, respawns, and the arena routes affected by changes. Label each check as observed, owner-confirmed, or pending.
- Use a separate skeptical reviewer agent for major deliverables and final acceptance. Have it inspect the source and test evidence, score each dimension from 1–10, and propose concrete changes. Score engagement (20%), retention potential (15%), cleanliness (25%), build quality (30%), and test evidence (10%). Engagement and retention are design judgments until player data exists.
- A score of **7 or below** in any category or overall triggers fixes and retesting. Apply actionable suggestions even when scores improve. If a score is still **below 7** after the fix and retest, replace the affected implementation with a revised approach, then test and review it again. An exact 7 still requires improvement. Continue when all scores exceed 7 and the required checks pass. Keep a record of scores, changes, and evidence. If an independent reviewer is unavailable, label any self-review and report the independent review as pending.

## Handoff

Report the playable loop, verified Studio results, independent scores, saved Dev Hub version, and any unresolved items. Keep Phase 2 open while a required check is pending. Begin by inspecting the existing project and documenting the research decisions, then implement and verify the loop.
