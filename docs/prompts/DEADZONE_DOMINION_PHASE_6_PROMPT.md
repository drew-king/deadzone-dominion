# Deadzone Dominion: Powers Tycoon — Phase 6 execution prompt

Implement **Floor One Tycoon Depth and the Physical Production Loop**. Read the Phase 1 master design, Phase 2–5 prompts, `DEVELOPMENT_STATUS.md`, and the Dev Hub roadmap before editing. Work in the existing Roblox Game project and Power-Up Tycoon place (place ID `96511474175721`). Use the existing Rojo project and server at `localhost:35011`; verify the connected Studio place and live sync before changes. Preserve all working systems and the existing architecture.

## Player feedback and objective

The owner reports that all current stages work, but the tycoon is far too short and visually bland. Droppers and buttons function but lack depth, detailed visual design, and a satisfying production-to-sale loop. Expand Floor One with **at least 20 additional meaningful upgrades** beyond the existing progression, create a richer and more readable visual identity, and make droppers produce collectible-looking items that visibly travel along a conveyor into a sell block and award Scrap.

## Plan and inspect first

- Inspect the current plot footprint, button unlock graph, dropper and conveyor code, Scrap authority, profile fields, rebirth rules, weapon station, and current Rojo mapping. Establish the current Floor One upgrade count and distinguish pre-existing upgrades from the 20 new purchases.
- Present a concise implementation plan in `DEVELOPMENT_STATUS.md` before major edits. Keep the existing plot layout and progression unless an extension is needed; expand the footprint intentionally so the tycoon feels substantially larger rather than cramming tiny buttons together.
- Implement the work as a coherent progression with a visible start, middle, and end. Make purchases unlock in a clear order and ensure every button has a meaningful effect, cost, readable name, and satisfying feedback. No filler upgrades that only change a number without a visible or gameplay effect.

## Floor One progression: 20+ new upgrades

- Add at least 20 new purchasable Floor One upgrades in addition to the current working upgrades. Track them in configuration/data rather than duplicating one-off button logic.
- Build a balanced progression across production capacity, dropper tiers, conveyor speed/width/branching, item value or refinement, collection/sell capacity, lighting/power infrastructure, defensive details, and weapon progression where it fits the existing design. Do not add monetization or pay-to-win advantages.
- Ensure the price curve, production rates, sell values, and time-to-next-purchase create a satisfying pace. Preserve rebirth compatibility and define what each rebirth resets or retains based on the existing implementation. Do not silently alter save schema or profile semantics.
- Buttons must clearly show name, price, locked/available/purchased state, and purchase result. Use large readable labels and distinct silhouettes, not color alone. Prevent duplicate or concurrent purchase exploits and verify insufficient-funds behavior.
- Give the floor meaningful spatial progression: multiple production bays, visible connections, landmarks, and a clear path through upgrades. Add collision-safe walkways and keep prompts accessible on desktop and touch.

## Visual direction and production loop

- Replace the bland presentation with a deliberate Deadzone Dominion industrial sci-fi palette: charcoal/graphite structure with controlled hazard amber, energized cyan/teal, and selective reactor violet or green accents. Use contrast to communicate function; avoid flooding every surface with neon. Ensure text and interaction prompts remain legible and the palette is not the only way to distinguish states.
- Give each dropper a designed machine silhouette with frame, hopper, feed path, animated/illuminated core, output chute, and tier-specific detail. Use existing Roblox geometry/materials or available project assets; do not claim custom meshes or images unless actually created and included. Make later tiers visibly evolve.
- Construct a continuous conveyor belt with visible rollers/side rails, direction cues, joins, and support framing. Route it through each unlocked production station to one clearly marked **SELL / SCRAP EXCHANGE** block at the end. No dead ends or impossible-to-follow pathing.
- Droppers must spawn visible items at their output at a controlled cadence. Items should travel along the belt in the correct direction, pass through any purchased processing stations, and reach the sell block. Use a robust deterministic movement approach if physical conveyor forces are unreliable; the player's visible experience must still show items moving through the machine. Provide readable sell feedback (item value and Scrap awarded) without excessive spam.
- Currency authority stays server-side. Never award Scrap from a client-controlled `Touched` event or untrusted client payload. Validate plot ownership, item identity/state, and one-time sale; prevent duplicate sales, cross-plot sales, spoofing, and race conditions. Decouple payout correctness from decorative physics. Cap active item/effect counts per plot and globally, expire stuck items, and clean them up on purchase changes, plot release, player leave, and shutdown.
- Keep separate player plots isolated. Existing combat, powers, weapon unlocks, rebirths, and Dominion Control must continue to work. Admin-only testing tools must remain owner-gated and safe for ordinary players.

## Verification and tuning

- Build with Rojo and verify Studio has the current files. Test the full Floor One path from claim through the 20 new purchases, production, conveyor travel, processing, sale, Scrap collection/spending, weapon progression, and rebirth behavior.
- Test with two Studio clients where available: separate plot ownership, item and payout isolation, simultaneous purchases, leaving/reclaiming, and no cross-plot item interaction. Record the actual test client count; do not imply multiplayer verification if only solo Studio was available.
- Verify every upgrade can be bought once, unlock order is correct, costs and effects match the displayed data, locked purchases reject safely, and the end-of-line sell block cannot be bypassed or double-triggered.
- Observe sustained production and repeated sale cycles. Record active-item cap, cadence, cleanup result, and any performance symptoms. Verify stuck/expired items and disconnected owners do not accumulate parts or grant currency.
- Re-run affected economy, combat, power, rebirth, admin, and profile regressions. Persistence claims require an isolated persistence test; default memory mode is not proof of persistence. Preserve existing data compatibility.
- Capture before/after evidence or concise Studio observations for layout scale, color/readability, machine detail, conveyor continuity, and item-to-sale feedback. The owner is the only real tester currently available; list wider playtesting and device coverage as pending.

## Independent critical review and acceptance

- Use a separate skeptical reviewer for the finished milestone. Score engagement (20%), retention potential (15%), cleanliness (25%), build quality (30%), and test evidence (10%), each from 1–10. Require evidence, concrete fixes, and a re-score after changes. Clearly label self-review if independent review is unavailable.
- A score of 7 or below triggers changes and retesting. If the work remains below 7 after retesting, rebuild the affected work and review again. Apply actionable improvements even if scores rise above 7. Accept only when all required checks pass and every category is above 7.
- Update `DEVELOPMENT_STATUS.md`, the local Dev Hub roadmap/draft, and this milestone's result notes. Save a new unpublished Dev Hub version if the connected Sites workflow is available; otherwise update the local draft and state that hosted saving is pending.
- Report the build identifier, exact new upgrade count, verified test environment/client count, progression and sale results, performance/cleanup findings, reviewer scores, remaining blockers, and next roadmap milestone. Do not publish or widen access.
