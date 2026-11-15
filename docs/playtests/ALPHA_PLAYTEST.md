# Deadzone Dominion alpha walkthrough

## Phase 15 factory and pet route

In `Deadzone-Phase15-Factory-Playtest.rbxl`, claim and purchase Starter Factory, Twin Dropper, Conveyor Annex, Foundry, Dispatch Extension, and Reactor. Watch cargo finish at its previous dock during extension, then follow the next shipment to the new dock. Build the Floor Two refinery and route its cargo to the Floor Three lift. At the starter incubator, inspect all odds before hatching. Check two equipped pets, one space per potion stack or unique pet type, Triple Hatch, Auto-Open stop, and the Cash Tonic timer. Compare staged profile checks with a normal no-spend run.

## Phase 14 outbreak and shop path

Open `Deadzone-Phase14-Outbreak-Playtest.rbxl` locally. Claim, build Starter Factory, collect the first sale, and equip Scrap Pulse. Approach an orange outbreak zone, note the number and type of zombies, and retreat beyond the marked edge. Compare damage and time to kill with a later weapon. Open Shop and toggle Auto-Collect, watch a sale bank to the wallet, then toggle it off and confirm the next sale waits to be collected. Try the guaranteed income pet, inspect egg odds and preview one hatch. Build Floor Two and check the intake, processing and live dispatch bays from player height before testing both stairs on a rotated plot.

## Phase 12 five-floor walkthrough

Open `Deadzone-Phase12-Arrival-Verified.rbxl` locally. Claim, buy Starter Factory, collect the first sale, buy Arsenal Station and walk to the ARSENAL counter. Use the equip prompt, then confirm that the tool appears in your hands. On Floor Two, use the Cargo Analyzer to see the latest sale and toggle the Routing Console to compare Value and Express. Complete Crown Uplink and trigger the rebirth prompt twice to confirm. Rebuild the prior floor, buy new floor access, then repeat for R2 and R3. Check the three new standard weapons and compare against Prism Repeater at the same arena range.

Record paid construction visibility, safe stair travel in both directions, pad readability, mode feedback and the next eligible floor on each reset. Record natural Scrap acquisition separately from Studio tests using admin cash. Use `PHASE12_COMPLETION_LEDGER.md` for verification state and candidate hash.

## Visual overhaul playtest

Use the latest candidate in `DEVELOPMENT_STATUS.md` locally. At a numbered gate, check the power and ownership text. Claim JuggerJigg, walk toward the Starter Factory pad and spend 25 Scrap. Watch the first cargo reach the exchange, collect its credited Scrap, and check that Twin Dropper appears while Plasma Foundry remains hidden. Use an isolated upgraded preset to check stairs, the upper deck, wall panels and the incubator. Hatch and inspect the pet's visual motif, odds and bonus, then check the Scrap shop and boards.

Run the same route with two players on different plots. Record uncoached claim-to-purchase and purchase-to-first-sale times, then compare frame time and memory around the Crown and a busy factory. Repeat touch and controller checks on available devices. See `art/Visual-Overhaul.md` for the audit.

Start a fresh Play session in the existing Power-Up tycoon place. On your first run, try following the on-screen guide without reading ahead. Note the first point where you need help and your input device.

1. Claim a numbered plot. Record the time from spawn to claim.
2. Collect Scrap and purchase a barricade or generator upgrade. Record the time to collection and purchase, and whether the result was obvious.
3. Equip Scrap Pulse and follow your gate road to Reactor Crown. Record the time to arena entry and whether its boundary is clear.
4. Check your power hint. JuggerJigg's dance can be tried solo. Powers requiring another player need Studio Server & Clients with two simulated clients.
5. In multiplayer, defeat an opponent, respawn at your plot, and decide whether to return to the arena. Check both wallets, plot reclaim, power expiry and cleanup, and Dominion Control using separate admin and regular clients.

Default sessions use memory. The optional Studio-only adapter uses the dedicated DeadzoneAlphaProfiles_v1 store and requires an explicitly enabled DeadzoneAlphaPersistence Workspace attribute in a separate private Roblox experience with DataStore access already configured. Places within the same experience share DataStore access. Verify a save and a fresh-session reload there before reporting restart persistence.

Log elapsed times, client count, device, and whether inputs were human or scripted. Record confusion or defects with the exact step and expected result.

## Phase 8 release walkthrough and gates

Open `DeadzonePhase8-LocalRelease.rbxl` in Studio. Start fresh with keyboard and mouse. Find a numbered gate and claim the base. Follow the guide to watch cargo sell, collect at the teal terminal and buy the barricade. Equip at the arsenal and follow the gate stripe to Reactor Crown. Return for Floor One completion, climb the rear stairs, buy Alloy Press and progress to Prism Repeater and Crown Uplink. Double confirm rebirth and check the starter grant and cleared installations. Record when you needed help and whether you chose to return to the arena or rebirth.

| Gate | Evidence required before release |
| --- | --- |
| Multiplayer | Two clients, separate plots and wallets, contested claim/reclaim, sales, combat, powers and regular-player admin denial. |
| Persistence | Save and reconnect in an isolated Roblox test place, restart the server, verify retained unlocks and rebirth count, then simulate failed load and confirm no writes. A local mock passed reload and failed-load checks. |
| Device usability | Run the same walkthrough with touch and controller. Check prompt conflicts, aim, HUD fit and focus navigation. |
| Performance | Record client frame times, server step and cargo count on a lower-end device with multiple plots producing. |
| Storefront | Owner approves original icon, thumbnails, readable signage and description. |
| Rollback | Retain the prior approved place file, record the artifact checksum and Roblox version before publishing, and rehearse restoring that version in a private test environment. |

Add uncoached timings and arena/rebirth choices to the alpha follow-up prompt. Add alternate cargo routing and a meaningful rebirth choice to the progression prompt. Carry the remaining gates into the release acceptance prompt.
