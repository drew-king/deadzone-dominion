# Deadzone Dominion: Powers Tycoon — Phase 4 execution prompt

Implement **Power Prototypes**, the milestone after the multiplayer combat sandbox. Read the Phase 1 master design, Phase 2 and 3 prompts, DEVELOPMENT_STATUS.md, and the Dev Hub roadmap. Work in the existing Roblox Game workspace and Power-Up tycoon Studio place (96511474175721). Reuse Rojo at localhost:35011, the eight plots, Scrap economy, Scrap Pulse, Reactor Crown, and Dominion Control. Preserve existing work and verify the current Studio sync before editing.

## Verify the baseline

Close the outstanding Phase 2 and 3 checks before integrating powers into the normal PvP loop. Use a fresh Studio Server & Clients session with two clients to verify separate wallets and plots, owner-only purchases, reclaim, normal PvP elimination and respawn, protected areas, regular-player admin denial, and admin expiry, rollback, and audit. Review the latest development log for updates. The last recorded Phase 3 review was 7.8/10 with test evidence at 6/10. Record what you actually verify and keep unresolved acceptance gates open.

## Build all eight prototypes

Use the master design as the source of truth for exact rules, visuals, defaults, and lifecycle. Centralize tuning and use one server combat pipeline. The server owns activation, cooldowns, damage, eligibility, rewards, and cleanup. Resolve armor, lethal prevention, and final damage before applying damage. Emit validated hit and elimination events once, with clear trigger semantics. Keep effect rendering on clients.

| Power | Required first playable behavior |
| --- | --- |
| JuggerJigg | A qualifying dance generates armor after startup at 8/sec, capped at 60. Armor absorbs damage before health. Attacking cancels armor generation. |
| Spam-Him-Up | Consecutive qualifying hits track the specific opponent and weapon category. Award the default 25% speed boost for 5 seconds once the threshold is reached. |
| Double Pop | Two eliminations empower the next 15 qualifying damaging attacks at 2× damage for up to 5 minutes. Consume charges on valid damage. Reset elimination progress on death. |
| Rising Sun | Intercept a lethal hit when ready. Transition from spectral gray to gold, block attacks during the transformation, grant 2 seconds of additional immunity, and apply the 180-second default cooldown. A prevented death awards zero elimination credit. |
| SlurperAid | Eligible players see and collect healing bubbles at recent elimination locations. They expire after 20 seconds and restore 15% max health, with the specified full-health effect. |
| PlopperFizz | Qualifying falls create purple landing bursts. Use the 8-stud descent threshold, 48 damage cap, and 13-stud radius. Ignore ordinary level jumps and preserve self-immunity. |
| CritShot | Grant +10% on ordinary generator income only. Roll 4% on each valid damaging attack on the server, at most once per shotgun trigger pull. |
| PolarBear Kick | Eligible players can loot temporary copies of held weapons from recent eliminations. Loot expires after 20 seconds, has limited reserve ammo, and supports at most two stolen weapons. |

- Follow the master design for unspecified rules. Use reversible defaults and log open balance questions. Define how power swaps, deaths, plot releases, disconnects, and respawns affect timers, speed, armor, temporary loot, and pending effects. Preserve protected spawns, normal PvP boundaries, and sparring isolation.
- Show each power's name, activation condition, cooldown or charges, and clear success and failure feedback. Check desktop, touch, and controller where available. Keep effects readable in fights and cap temporary instances.
- Extend Dominion Control with owner-only power assignment, revocation, cooldown reset, effect cleanup, and bounded tuning. Preview changes, show expiry, and audit actor, target, scope, reason, and result. Use isolated Studio presets for power testing and keep test effects out of ordinary progression.
- Keep zombie waves, live objective capture, monetization, and broad release work for their scheduled milestones.

## Research, tests, and review

- Benchmark Elemental Powers Tycoon for kit identity and learnability, Military Tycoon for reasons to leave base, and retain Zombie Uprising for later survival design. Verify sources, distinguish storefront claims from play observations, and record original adaptations. Ask focused questions when an answer materially changes the work and continue independent work while waiting.
- Exercise each power with two clients through its normal activation path, valid and rejected triggers, reset and expiry, and at least one interaction with another power. Verify one-credit eliminations, revive ordering, safe spawn and arena rules, temporary loot cleanup, exact CritShot trigger accounting, and unchanged economy isolation. Use deterministic Studio fixtures for random outcomes and label actual match observations separately.
- Have a separate skeptical reviewer inspect source and evidence. Score 1–10 in engagement (20%), retention potential (15%), cleanliness (25%), build quality (30%), and test evidence (10%). Any score at 7 or below triggers fixes and retesting. If still below 7 after retesting, replace the affected work and review again. Apply actionable suggestions even when scores improve. Accept only when all scores exceed 7 and checks pass. Label self-review if independent review is unavailable.
- Update DEVELOPMENT_STATUS.md and save and verify a new version of the existing unpublished Dev Hub. Record changes, unresolved issues, test evidence, and scores. Use the local HTML draft if Sites is blocked. Keep status concise. Publishing requires a separate request.
