# Deadzone Dominion: Powers Tycoon — Phase 3 execution prompt

Implement Phase 3 in the real Roblox project. Read the Phase 1 master prompt for the complete game design, the Phase 2 execution prompt for the economy and Dominion Control requirements, and DEVELOPMENT_STATUS.md for verified progress. Use the Dev Hub roadmap order: Phase 3 is the **multiplayer combat sandbox**. Full power prototypes follow in the next milestone.

## Start from the existing build

- Use the current Roblox Game workspace and the existing Power-Up tycoon place (ID 96511474175721). Inspect the working tree before editing. Reuse the existing Rojo configuration, eight plots, claim flow, Scrap economy, upgrades, Scrap Pulse, and Dominion Control. Verify the current Studio connection at localhost:35011 before changing it.
- Start with a fresh Studio Server & Clients session with two clients. Check the outstanding Phase 2 requirements before treating that baseline as accepted: concurrent plot ownership and wallet isolation, owner-only economy interactions, reset on leave/reclaim, PvP elimination and respawn, regular-player admin denial, and admin expiry, rollback, and audit. Resolve regressions and log the evidence. Distinguish owner-confirmed results from tests you ran.
- Work in Studio and the local source. Use the existing unpublished Dev Hub for saved milestone updates. Publishing the Roblox experience or deploying the site requires a separate request.

## Build a complete PvP loop

1. **Equip → enter → fight → recover.** Extend the existing Scrap Pulse rather than creating a parallel combat system. Give players clear equipment, firing, hit, elimination, and respawn feedback. Keep the route from an owned base to Reactor Crown obvious. Give the first match a concise cue for where PvP starts and where players return after elimination.
2. **Server authority.** The server decides weapon ownership and equip state, valid shot origin, range, line of sight, damage, cadence, spawn protection, and elimination credit. Use centralized weapon tuning and preserve normal tycoon progression across respawns. Handle leaving, plot release, repeated inputs, missing characters, and simultaneous shots without duplicate credit.
3. **Arena readability.** Use Reactor Crown as the shared combat destination. Adjust cover and sightlines only where playtests show a problem. Preserve the eight plot pivots and navigable routes. Check that players can retreat or rejoin the fight and that protected spawns cannot be camped for easy eliminations.
4. **Power integration points.** Define server-owned hooks for validated hits, damage modifiers, and eliminations. Keep all eight original power identities and their rules in the design. Leave actual power activation for the next milestone. Keep the Reactor Crown capture system, zombie waves, monetization, and cross-server progression out of this combat milestone.
5. **Dominion Control.** Extend the existing panel with combat pause, temporary sparring and spawn-protection controls, and useful combat diagnostics. Keep owner authorization by verified Roblox UserId and Studio test permissions distinct. Audit changes with actor, target, scope, reason, and result. Expire temporary overrides and keep sparring separate from progression.

## Research, playtest, and polish

- Start with [Elemental Powers Tycoon](https://www.roblox.com/games/10253248401/Elemental-Powers-Tycoon) for the transition from owning a base to using its kit, and [Military Tycoon](https://www.roblox.com/games/7180042682/Military-Tycoon) for reasons to leave base and re-enter combat. Retain [Zombie Uprising](https://www.roblox.com/games/4972091010/Zombie-Uprising) for the later survival phase. Verify sources, distinguish game descriptions from hands-on observations, and record what you adapted.
- Run two clients through the normal equip, fire, damage, elimination, and respawn flow. Check blocked sightlines, out-of-range shots, firing cadence, spawn protection, simultaneous eliminations, and admin combat pause and expiry. Check that losing or releasing a plot invalidates the issued weapon. Recheck economy isolation and the affected base-to-arena routes.
- Check feedback and controls on desktop, touch, and controller where available. Record time from spawn or respawn to the first fight and note where testers get stuck. Prioritize readable feedback and fair fights before adding content. Ask focused follow-up questions when an answer materially changes the build, and continue independent work while waiting.

## Independent review and handoff

- Use a separate skeptical reviewer for major deliverables and final acceptance. It must inspect source and evidence and score engagement (20%), retention potential (15%), cleanliness (25%), build quality (30%), and test evidence (10%) on a 1–10 scale. Record category scores, the weighted total, and actionable fixes. Treat retention as a design judgment until there is player data.
- A score of **7 or below** triggers fixes and retesting. Apply actionable suggestions even when the score improves. If the score remains **below 7** after retesting, replace the affected implementation with a revised approach, then test and review again. A score of exactly 7 still requires improvement. Accept only after all scores exceed 7 and the required checks pass. Label self-review if a second agent is unavailable.
- Update DEVELOPMENT_STATUS.md and save an updated version of the existing **Power-Up Tycoon | Dev Hub** without deployment. Verify the saved version. If access fails, update the local HTML draft and document the blocker. Report what shipped, Studio evidence, review scores, remaining items, and how the owner can start the playtest. Keep output concise.
