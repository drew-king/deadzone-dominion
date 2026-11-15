# Phase 13 completion ledger

Baseline `Deadzone-Phase12-Arrival-Verified.rbxl`, SHA-256 `480FD2AE31591616433A8A33B62D7AC5C15CC712324B49F973D85D68769BEF25`. Original source and candidate were copied to `art/rollback/phase13-start-20261115-132317`. The attachment matches the tracked Phase 13 prompt byte for byte.

| Milestone | State | Evidence |
| --- | --- | --- |
| Preservation and sync | Passed | Connected the disposable local Phase 12 Studio copy to `deadzone-dominion` on `localhost:34872`. Confirmed a new module on disk appeared in the Edit DataModel and disappeared on removal. PlaceId 0. |
| Armory | Scoped Studio pass | Fresh claim, earned Scrap, purchase, menu click and Scrap Pulse equip. Isolated R3 enabled all eight menu choices and each equipped the expected tool. Verified scanner-to-Scrap Pulse and out-of-range rejection. |
| Full-footprint floors | Scoped Studio pass | All 8 plots × 4 upper roofs × 4 sections matched the 108×118 footprint minus the intended shaft. Checked collision while hidden and purchased. Walked four flights up on Plot 1 and down on Plot 8 using the actual character controller. |
| Siege | First raid verified in the Rojo-synced Studio copy | Normal claim, factory, collection, Arsenal and Siege Console. Used an automated aim on the standard Scrap Pulse firing path, with no wallet grant. Three Walkers cleared. Wallet moved from 80 to 135 exactly once and no actors remained. |
| Exact packaged file | Built | `Deadzone-Phase13-Siege-Playtest.rbxl` SHA-256 `CE63F308C4EF3037609D16CAC750E5447BC7B605BBD6307E82618AC41FE272A1`. Studio reopen was interrupted. The latest retry, repair, HUD and turret feedback edits are included and need replay. |

Research handoffs scored 8.6/10. Agent 4's last scoped review scored engagement 8, retention potential 7, cleanliness 8, build quality 7 and test evidence 5. Agent 5 rated the review 8/10 and candidate test evidence 6/10. The phase acceptance threshold remains open. The intermediate Tower Playtest file predates a fixed map-generation error. Use the integrated Siege Playtest candidate.

Next verify the exact file with fresh Stage 1 and optional earned barricades, then exercise loss, paid repair, retry, next-wave scheduling and all six enemy types plus each defense tier. Check reversed walks on both tested rotations, uninterrupted two-client waves/rebirth/reclaim, protected spawn and PvP/power regressions, mobile/controller, isolated save compatibility and load. The existing hosted Dev Hub is still at its previously verified unpublished version 7. Production received no changes.

Open source findings from the evidence audit. A visiting avatar can block enemy movement and turret rays. Exercise a second player standing in the lane, then exclude characters from movement and turret rays while retaining the owner-target line-of-sight check. Test first-time gate installation with a player in the gate volume and gate repair with the volume occupied.
