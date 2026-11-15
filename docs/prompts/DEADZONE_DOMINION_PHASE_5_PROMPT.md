# Deadzone Dominion: Powers Tycoon — Phase 5 execution prompt

Run the **Alpha Playtest** milestone after Power Prototypes. Read the master design, prior phase prompts, DEVELOPMENT_STATUS.md, and the Dev Hub roadmap. Use the existing Roblox Game workspace, Power-Up tycoon place (96511474175721), Rojo at localhost:35011, and the same Dev Hub. Keep the existing plot, economy, combat, power, and admin architecture. Complete and record any outstanding Phase 2–4 acceptance checks before calling the build alpha-ready.

## Prepare the alpha candidate

- Record the build identifier, Studio sync state, test environment, and current tuning. Run a fresh two-client smoke test before expanding the session. Start with Studio and isolated data. The Phase 2 profile adapter was tested in memory. If it is still mock-only, implement and verify an isolated persistent test adapter before claiming restart or reconnect persistence. Distinguish a failed load from a new profile and verify failed loads cannot cause writes. Keep test data separate from any live data.
- Prepare a short tester brief: claim → produce → collect → upgrade → equip → fight at Reactor Crown → use a power → respawn and return. Observe the first run before coaching. Include separate plots, contested claims, reconnect, and the current session flow from arrival to repeat play. Treat a formal round system as a scope decision if the build does not already have one.
- Test with two clients, then target four and eight as available. Include real players when the owner arranges access. Ask focused follow-up questions about devices, tester access, and session timing while continuing local checks. Record the actual client count and input methods. Keep release preparation for the next roadmap milestone. Publishing or widening access requires separate direction.

## Run and improve the playtest

| Area | Evidence to collect |
| --- | --- |
| Onboarding and engagement | Time to claim, first collection, first meaningful upgrade, first arena entry, and first successful power use. Record where players hesitate and whether they choose to return to the arena. |
| Ownership and economy | Exclusive claims, wallet isolation, exact spending, duplicate request handling, owner-only actions, leave/reclaim, and persistence across the environments actually tested. |
| Combat and powers | Clear hit and elimination feedback, respawn and re-entry, protected spawns, all eight activation rules, power interactions, cooldowns, and counterplay. Record match size and sample counts with observations. |
| Input and accessibility | Desktop, touch, and controller where available. Check prompt discoverability, legible HUD, tap targets, contrast, and readability without depending on color alone. |
| Performance and cleanup | Observe client responsiveness and server behavior at the tested load. Check effect caps, loot expiry, disconnect cleanup, and repeated fights. Record device and client count with any measurements. |
| Dominion Control | Verify owner and regular-player access, harmless invalid inputs, scoped overrides, preview and rollback, expiration, and audit records. Keep testing defensive and use isolated profiles for sparring and balance trials. |

- Benchmark the relevant onboarding and combat cues in Elemental Powers Tycoon and Military Tycoon. Keep Zombie Uprising as a reference for the later survival work. Distinguish verified observations, player feedback, and hypotheses. Report observed replay behavior and sample sizes. Treat long-term retention as unknown until measured.
- Rank issues by effect on players. Fix blockers first, rerun affected journeys and regressions, then tune and polish using evidence. Preserve the eight plot pivots and the working economy and combat loop. Keep new monetization, zombie waves, and release prep within their separately approved scope.

## Independent acceptance and handoff

- Use a separate skeptical reviewer for major deliverables and final acceptance. Score engagement (20%), retention potential (15%), cleanliness (25%), build quality (30%), and test evidence (10%) from 1 to 10. Ask for concrete evidence, highest-priority fixes, and a new score after changes.
- A score of 7 or below triggers fixes and retesting. If a score stays below 7 after retesting, rebuild the affected work and review again. Apply actionable tweaks even after improvement. Acceptance requires scores above 7 and passing required checks. Report missing devices, tester access, and unverified scenarios as pending. Label self-review if independent review is unavailable.
- Update DEVELOPMENT_STATUS.md and save and verify a new unpublished version of the existing Dev Hub. Use the local HTML draft if Sites is blocked. Hand off the build identifier, tested scenarios, review scores, ranked findings, remaining blockers, and proposed release-prep priorities. Keep updates direct and concise.
