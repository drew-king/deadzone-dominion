# Deadzone Dominion visual overhaul

## Art direction and editable source

Warm sand and cream carry the floors. Aubergine ink frames signs and large silhouettes. Teal identifies Scrap collection across all plots, and gold marks the arena and common action cues. Each power keeps a primary and light accent defined in `src/shared/VisualTheme.luau`. Use cream on ink for world signs. Rounded signs and bold Gotham text work alongside part silhouettes. Keep lamps small and avoid bloom across the conveyor or arena.

| Plot | Gate and egg mark | Pet silhouette cue |
| --- | --- | --- |
| JuggerJigg | Crimson shield | Box speaker cheeks |
| Spam-Him-Up | Turquoise turbine | Swept fins |
| Double Pop | Orange and pink twin discs | Twin tanks |
| Rising Sun | Gold sunburst | Solar crest |
| SlurperAid | Green medical cross | Sprout |
| PlopperFizz | Violet bubbles | Canisters |
| CritShot | Green reticle | Sight fins |
| PolarBear Kick | Blue ice facets | Angular frost crest |

## Asset manifest

| Asset group | Editable source | Construction and collision | Validation |
| --- | --- | --- | --- |
| Gates, signs, crest poles, runners and arena cover | `src/server/MapBuilder.luau`, `src/server/FactoryArt.luau`, `src/shared/VisualTheme.luau` | Functional original collision and cosmetic overlays with no query or collision | Named crest layout present across eight plots. See the JuggerJigg gate capture. |
| Dropper housings and nozzles, conveyor, cargo, exchange, collector, pad rims, walls and upper consoles | `src/server/Economy.luau`, `src/server/FactoryArt.luau` | Stage and purchase roots govern visibility; motion and server payouts share the existing sale path | Starter Factory, blocked successor and first sale tested with one Studio client. |
| Incubator and egg marks, follower details | `src/server/Pets.luau`, `src/shared/PetConfig.luau`, `src/client/Pets.client.luau` | Incubator follows purchase state; follower uses client visuals with no collision or query | JuggerJigg hatch and equip observed in an isolated profile. |
| Shop and server boards | `src/client/Shop.client.luau`, `src/server/LiveBoards.luau` | Screen interface and pass-through board shells | Studio loaded the shop and boards. Touch/controller coverage remains open. |

The project generates original Parts and UI using built-in materials. All seven original OBJ files are editable under `art/meshes` and reproducible from `art/build-meshes.mjs`. The table records the asset IDs from the Rojo templates in `art/roblox`. The server tints the Power Egg per plot. Cargo and dropper meshes are noncolliding. The Reactor Crown uses a separate collision core.

## Research and testable design choices

Reference pages checked November 13, 2026. Competitor observations come from their public listings and publisher FAQ.

| Evidence | Application and next measurement |
| --- | --- |
| [Roblox discovery](https://create.roblox.com/docs/discovery) connects recommendations to engagement and repeat play. [Onboarding](https://create.roblox.com/docs/production/game-design/onboarding) recommends identifying where players leave the first-time funnel. | Show each plot's power and ownership from the gate. Put first-time arrivals near the Starter Factory and give one named objective. Observe unassisted claim, purchase, and first sale times. |
| [Elemental Powers Tycoon](https://www.roblox.com/games/10253248401/Elemental-Powers-Tycoon) leads with claiming a power base. [Military Tycoon](https://www.roblox.com/games/7180042682/Military-Tycoon) presents building and external objectives together. | Use eight distinct base crests and a readable Crown landmark. Ask whether a fresh player can identify their plot on return from the arena. |
| [Pet Simulator 99](https://www.biggames.io/faq/pet-simulator-99) uses hatching and pets differentiated by rarity. [Steal the Brainrot](https://www.roblox.com/games/85112180178766/Steal-the-Brainrot) lists conveyor acquisition, collectible traits and rebirth. | Match egg marks to the plot and distinguish pet families and cargo tiers by shape. Measure incubator discovery and whether players recognize the hatch result and equip state. |
| [Roblox performance guidance](https://create.roblox.com/docs/performance-optimization/improve) identifies rendering and instance costs. [Studio Importer](https://create.roblox.com/docs/studio/importer) supports multiple model formats. | Reduce repeated decorative pieces. Profile at matching camera positions and simultaneous plot load. Import finished mesh exports into a separate local candidate and verify after reopen. |

## Defect register

| ID / phase | Reproduction and impact | Correction and verification |
| --- | --- | --- |
| V1 / 1, 8 | Baseline billboard overlapped the HUD and motifs were recolored blocks. Medium. | Moved identity onto the gate face, installed eight geometric crests, and synchronized name and claim state. Verified eight starting labels, one ownership change and a readable owned gate capture. |
| V2 / 2, 6, 9 | Claim arrival was about 81 studs from the first pad. Decoration needed a dependable construction root. High. | Shorter first arrival and staged pads/rims. Server check found one available starter after claim, then Twin Dropper unlock and Foundry still hidden after buying. |
| V3 / 6, 7, 10 | Cargo tiers shared the same silhouette and bright trim obscured the factory. Medium. | Added cargo shape variants and revised lamp and trim treatment. Both candidates ran sales. The matching arena screenshots show the beacon refinement. |
| V4 / 7, 9, 11 | Paid construction needs correct visibility on fresh/advanced profiles. High. | Studio checked six hidden objects across eight fresh plots on the first candidate. On the refined build, the upgraded isolated preset showed wall, deck and incubator, then hatched and equipped a pet. Release hid the incubator and reset ownership. Rebirth and all rotations still need full retests. |
| V5 / 5, 8 | Performance, real devices, reconnect, and PvP/admin isolation lack sufficient evidence. High. | Track under Phase 12. Reproduce at two clients, gather frame time and memory on a physical phone, and verify profile writes in an isolated adapter. |
| V6 / 10, 11 | Full mesh and texture pass, all 96 pet variants in play, and thumbnail set remain outstanding. Medium. | Current local candidate uses original editable Parts. Finish asset production and verify asset ownership, import, moderation and reopen when applicable. |

## Studio evidence

- [Refined JuggerJigg gate](refined-gate.jpg) and [refined Reactor Crown](refined-arena.jpg).
- [First art candidate factory in an upgraded preset](factory-final.jpg) and [earlier Reactor Crown at the same camera angle](shot-arena.jpg).
- [Imported egg shell in the working incubator](mesh-incubator.jpg) from the reopened mesh build.
- [Production meshes on the running factory line](production-factory.jpg) from the latest verified build.
- [District entrance and paid wall trim](district-art.jpg).
- The full refined solo smoke results and file hash are in `DEVELOPMENT_STATUS.md`. Counts are from startup, with one desktop client per build. No matched device FPS or memory measurements were collected.
