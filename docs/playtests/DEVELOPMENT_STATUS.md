# Phase 1 development status

Phase 15 factory and pet playtest is recorded in `PHASE15_COMPLETION_LEDGER.md`. Prices use a shared pre-unlock earning model and the 20/20/32/44/56-second target. See `PHASE15_UPGRADE_PRICING.csv`.

Current local candidate is `Deadzone-Phase14-Outbreak-Playtest.rbxl`. Phase 14 covers roaming zombies, Floor Two work bays and the Studio-only shop preview. See `PHASE14_COMPLETION_LEDGER.md` for verification and remaining gates.

Phase 13 has a local Siege Playtest candidate. The synced Studio build passed all eight weapon selections, roof gating and footprint across eight plots, and the first no-spend raid. See `PHASE13_COMPLETION_LEDGER.md` for its hash, evidence and pending exact-file acceptance.

Current Phase 12 execution is tracked in `PHASE12_COMPLETION_LEDGER.md`. The latest saved local build is `Deadzone-Phase12-Arrival-Verified.rbxl`. It reopened in Studio and passed the scripted phone-simulator claim and first collection. The phase has verified 79 purchases, three rebirths, both directions of stair traversal across tested builds, all eight scripted powers, two-client ownership, boards and admin checks, and private stale-save protection. Eight gate styles and 102 pet designs have scoped art coverage. Natural combat, unassisted pacing, physical devices and broader art acceptance remain open.

## Playable foundation

- Eight configurable plots, an industrial arena, four Reactor Crown ramps, two future objective markers, and a neutral spawn.
- Claim ownership is assigned on the server. The guide shows the next objective after a claim.
- The Roblox place remains in development. Combat, zombie waves, and progression are later milestones.

## Reference decisions

- [Elemental Powers Tycoon](https://www.roblox.com/games/10253248401/Elemental-Powers-Tycoon) leads with claiming a base. Deadzone uses numbered gates, distinct power colors and silhouettes, and a direct claim prompt.
- [Military Tycoon](https://www.roblox.com/games/7180042682/Military-Tycoon) pairs base building with external objectives. Deadzone uses a central landmark and routes from every plot.
- [Zombie Uprising](https://www.roblox.com/games/4972091010/Zombie-Uprising) gives players a shared survival objective. Revisit that pattern when zombie waves enter scope.

## Checks

- Rojo built the place file. Studio received the scripts via live sync.
- Studio Play generated eight inward-facing plots and spawned the player at the neutral arrival point. A real ProximityPrompt interaction claimed JuggerJigg.
- Independent review round one scored 7.15/10. Applied fixes to ramp pitch, plot silhouettes, spawn guidance, and persistent objective text.
- The revised build passed Studio checks for all four ramp slopes and joins, plot ownership, claim teleport, and respawn. Ramp checks inspected geometry.
- Independent review round two scored 7.9/10. Engagement, retention, cleanliness, and build quality scored 8. Test evidence scored 7.
- Two Studio clients attempted JuggerJigg at the same time. Exactly one got ownership. The other received the occupied message and successfully reclaimed the plot after the owner disconnected.
- Independent review round three scored 8/10 in every category based on the added multiplayer evidence.
- Scripted Studio traversal reached Reactor Crown from all eight gates in 12.3–13.7 seconds, within the 12–18 second target. These timings came from scripted movement.
- The project owner confirmed that two players can own different plots simultaneously. This closes the Phase 1 gameplay acceptance checklist.
- Dev Hub Sites version 1 is saved as an unpublished draft.

## Phase 2 — first playable economy

- Implemented owner-scoped Scrap production, collection, a barricade purchase, generator upgrade, and a first-purchase guide on the existing eight plots.
- Adapted Elemental Powers Tycoon's storefront claim-first premise into a direct claim-to-collection guide. Military Tycoon's storefront pairs base building with excursions; the station equips a starter tool and directs players toward Reactor Crown. Zombie Uprising remains a later wave-design reference. These observations came from the game descriptions.
- Added Scrap Pulse with server-side validation, plus a versioned in-memory profile adapter. Studio verified mock save/load, snapshot isolation, and write rejection after failed reads or unsupported schema. Cross-server persistence is pending.
- Added Dominion Control for the verified owner account and a Studio test role. Economy commands are session-scoped, power identities are previews, and Studio presets use an isolated temporary profile.
- Studio observed a claim, passive production, collection of 60 Scrap, a 25 Scrap barricade debit, and no additional debit on a repeat purchase. Verified owner received 100 Scrap through Dominion Control, and an invalid negative grant was rejected.
- Studio verified the 45 Scrap generator purchase and Scrap Pulse equip. Final Rojo build passed.
- Independent re-review scored 7.9/10 overall (8 in engagement, retention, cleanliness, and build quality; 7 in test evidence).
- Dev Hub Sites version 2 is saved and unpublished.
- Phase 2 remains open for the fresh two-client combat and authorization checks, multiplayer economy isolation, and admin expiry, reset, rollback, and audit verification.

## Phase 3 — combat sandbox in progress

- Centralized Scrap Pulse tuning. Normal PvP requires both players to own plots and be inside Reactor Crown plaza. Studio sparring is isolated from normal combat and elimination credit.
- Added arena entry feedback, visible shots, centered aiming, server-only hit and elimination hooks, and weapon cleanup on respawn. Dominion Control inspection reports equip state and arena eliminations.
- Reference research used the official game descriptions: Elemental Powers Tycoon leads with claiming a base, Military Tycoon connects base building to outside objectives, and Zombie Uprising remains a later survival reference.
- Rojo build passed and Studio confirmed the new combat config, weapon station, and admin remote in solo Play. Independent review scored 7.8/10 with test evidence at 6/10. The boundary cue and spectator restriction were added after the review.
- Acceptance remains open for a fresh two-client combat run, Phase 2 regression and admin checks, and input checks on available devices.

## Phase 4 — power prototypes in progress

- Integrated eight Studio-only prototypes with shared combat damage resolution, fractional CritShot income, a power HUD, private pickup markers, and Dominion Control cooldown reset, effect cleanup, and time-limited tuning. Sparring excludes normal power progression.
- Prototype balance choices: Spam-Him-Up needs four Scrap Pulse hits on one target within four seconds, Rising Sun uses a 1.5-second transformation and 40% minimum health restoration, and looted Scrap Pulse copies have six shots. Healing and weapon pickups are currently reserved for an eligible credited eliminator.
- Official listing observations support claim-first kit discovery and a clear route out of the base. The HUD translates those ideas into an activation hint and visible power state. This is listing research, with hands-on reference testing pending.
- Rojo build passed. Independent static review scored 7.7/10 (8 engagement, retention potential, cleanliness, and build quality; 5 test evidence).
- Dev Hub Sites version 4 is saved and unpublished.
- Acceptance remains open for Phase 2/3 regression coverage, two-client power activation and interactions, admin expiry, lifecycle cleanup, and device input checks.

## Phase 5 — alpha preparation

- Candidate: local Rojo build DeadzonePhase5-Alpha.rbxl, working tree based on f91dad7. Build and git diff whitespace check passed. Roblox Studio connection timed out, so current sync and runtime are unverified.
- The owner is the sole available real tester. ALPHA_PLAYTEST.md contains the first-run walkthrough and evidence checklist. Current candidate tests have zero observed clients and no device or replay data.
- Updated the arrival guide and arena directions. The official Elemental Powers Tycoon and Military Tycoon descriptions support claim-first onboarding and a clear reason to leave the base. These are storefront observations.
- Added an opt-in Studio profile adapter with a dedicated alpha data store namespace and a shutdown save path. Default profiles remain in memory. Fresh-session persistence and failed-load behavior on the new adapter need an isolated Studio test.
- Preliminary independent review: 7.4/10 (engagement 8, retention 8, cleanliness 8, build quality 7, evidence 5). The reviewer reached a usage limit before re-review.
- Prioritize fresh Phase 2–4 two-client regression and power checks, then isolated persistence and the owner walkthrough. Larger sessions, input coverage, and release preparation remain open.
- Dev Hub version 5 is saved and unpublished. Local alpha place SHA-256 starts with 9ED20B1E4865.

## Alpha progression expansion

- Source now includes multipart droppers, labeled pads and collector, five ordered purchases, three new weapon unlocks, and a double-confirm rebirth console. Rebirth resets Scrap and upgrades and grants a cumulative 20% production bonus per rebirth.
- Progression values are initial tuning. Rebirth count shares the existing profile adapter. The default local build still uses memory.
- Built DeadzonePhase5-Progression.rbxl with Rojo. Studio visual and gameplay verification remain pending.

## Phase 6 — floor-one tycoon depth (local candidate)

- Owner reports that the existing stages work, but the tycoon feels too short and visually bland.
- Next milestone: add at least 20 meaningful, visibly distinct floor-one upgrades; improve the color palette and industrial presentation; build a readable conveyor route ending at a sell block; and make droppers spawn physical-looking items that travel along the conveyor and are sold for Scrap.
- Keep server-authoritative payout and ownership. Item visuals must be capped, cleaned up, and unable to grant currency by client-side touch or spoofed events. Preserve existing plots, economy, combat, weapons, powers, rebirth, admin controls, and Rojo workflow.
- Phase 6 acceptance remains open and should cover all 20+ purchases, visual readability, item travel and sell feedback, value/payout correctness, ownership isolation, repeated operation, and cleanup/performance.

## Phase 6 implementation and polish

- Audit the existing map, economy, arena guidance, profiles and admin hooks. Resolve overlapping floor surfaces and keep the eight plot entrances and arena routes.
- Add 20 data-driven purchases in four production bays. Replace passive Scrap credit with visible cargo and credit the existing collector buffer only at the exchange.
- Rebuild the local candidate and check Studio geometry and production. Record completed checks and place broader playtesting and release work under the corresponding roadmap milestones.

### Local candidate results

- Roblox Studio inspection found a 2048 × 2048 template Baseplate in the published place whose top shares Y=0 with the generated ground. The runtime map builder now suppresses the matching template floor and hides legacy station markers.
- Rojo built DeadzonePhase6-Polish.rbxl with 25 total purchases, cargo movement and sale to the collector buffer, and a completion requirement for rebirth. Source changes also clarified purchase visibility, exchange feedback, and floor progress.
- Initial independent static review: 6.55/10 weighted. Corrected the overlapping purchase pad, competing prompts, exchange label orientation and per-sale construction refresh. Studio acceptance and independent re-score remain open.
- Studio showed Phase 5 and the cloud place after the candidate launch attempt. The candidate has not been played in Studio. Direct script and template edits were rejected by automatic review. No cloud changes were made.

### Follow-up roadmap and prompt additions

- Alpha follow-up (Phase 5 acceptance): add Floor One pacing observations, two-client plot and sale isolation, all eight power interactions, and isolated persistence across restart to the next alpha execution prompt.
- Floor Two and rebirth (next progression prompt): add alternate production routes, more varied purchase effects, weapon sidegrades, and meaningful rebirth rewards. Reuse the Floor One item and exchange flow.
- Release preparation: add original mesh and signage review, mobile and controller accessibility, low-end device load, and storefront visuals to the release prep prompt.

## Phases 7 and 8 — layout, Floor Two and release preparation

- Floor One purchase pads moved into a dedicated 5 × 5 grid clear of the claim terminal. Generator, scanner posts, perimeter wall joints and collector clearances were adjusted. Gate header and pillars, belt assembly and stair landing contacts are intentional.
- Floor Two has five upgrades, rear stairs, a Prism Repeater option and a Crown Uplink goal. Rebirth resets both floors, keeps the rebirth count, adds +20% output per rebirth and grants 25 starting Scrap. Existing upgrade keys are retained.
- Phase 8 includes first-sale, first-purchase, arena and stairs guidance, temporary action feedback and extra HUD clearance. Candidate built locally with Rojo.
- Initial independent static scores in rubric order: Phase 7 (8, 7, 7, 7, 4), weighted 6.90. Phase 8 (7, 6, 7, 7, 4), weighted 6.55. Addressed generator and wall intersections, floor-level prompt authorization, rapid weapon classification, guide and announcement spacing, and arsenal directions.

### Engagement and design follow-ups

- **Alpha follow-up prompt** — Time an uncoached claim, first sale, first upgrade, first arena choice, first upper purchase and first rebirth. Idealized economy model estimates roughly nine minutes to rebirth before routing and collection. Measure before tuning. Follow up with two clients and isolated restart persistence.
- **Next progression prompt** — Evaluate a visible alternate cargo route and let rebirth unlock a strategic choice. Measure whether players select the Prism Repeater and whether early arena visits feel worthwhile.
- **Release acceptance prompt** — Add mobile and controller pass, low-end performance, final original machine art and storefront images. Confirm combat and power regressions and capture a rollback candidate before any publishing decision.

### Studio verification and independent re-review

- One client in the preceding candidate generated all eight plots and 240 purchase pads. A plot-local box check found zero pad intersections with other direct parts, excluding angled stair rails. Real prompts claimed JuggerJigg, collected 50 Scrap from cargo sales and bought the 25 Scrap barricade. The guide advanced to Twin Dropper with 25 Scrap left.
- The wider geometry scan identified dropper chassis intruding into conveyor parts, raised modules sunk into the deck, and a guard seam. Adjusted those dimensions and rebuilt DeadzonePhase8-Polished.rbxl. Gate header/pillar and pieces within each dropper are intentional assemblies. Final geometry pass, stairs traversal and full two-floor progression test remain open.
- Independent re-review after the first fixes and geometry check: both phases scored 8 engagement, 7 retention potential, 8 cleanliness, 8 build quality and 6 evidence (7.65 weighted). Acceptance remains open. Add uncoached replay observations, two-client isolation, full rebirth, device and persistence checks to the alpha and release acceptance prompts.

## Phase 7 acceptance follow-up

- Studio candidate: DeadzonePhase7-StudioCandidate.rbxl, SHA-256 beginning 57230A06E9777368. This is a byte-identical copy of the tested local Polished place.
- One Studio client tested fresh claim, accrued 15 pending Scrap after a six-second wait, collected and bought the 25-Scrap barricade, with 5 Scrap remaining. This was assisted verification, not a first-session pacing study.
- The full potential construction scan covered all eight plots, including 240 purchase pads and 192 stairs. Zero unexpected intersections among aligned static plot parts. Deliberate contacts: 160 internal dropper joins and 16 gate joints. Angled stair rails and moving cargo were excluded from the box scan.
- Client-directed movement traversed JuggerJigg center stairs in 2.21 seconds up and 2.15 down. Rail edge traversal remains open.
- Isolated upgraded preset equipped Prism Repeater with its prompt. Double-confirmed rebirth changed 1,100 Scrap and 30 installations to 25 Scrap, zero installations and one rebirth. A mocked older profile kept 900 Scrap, two rebirths and the Floor One upgrade keys, and resolved Alloy Press next. A natural Floor Two purchase run remains open.
- Independent Phase 7 regrade: engagement 8, retention potential 8, cleanliness 9, build quality 8, test evidence 8. Weighted 8.25/10. Multiplayer payout/ownership, natural unlock pacing, rail edges and voluntary replay behavior remain open. Add to the alpha follow-up prompt.

## Phase 8 local release handoff

- Candidate: DeadzonePhase8-LocalRelease.rbxl. SHA-256 CEC3388B096533A75963044C6B5CA9747D12ADF29BEE9F38040ED0CECE2246BB. Rojo build passed. Opened the local candidate in Studio. No cloud publishing or access changes.
- First-session guide now advances from cargo to collector to affordable purchase. Final candidate: one desktop Studio client with assisted keyboard prompts. Spawn, claim, pending-sale and collected states all reported TextFits=true. Observed 25 pending Scrap, collected 40, and received the 25-Scrap Barricade objective.
- Prior byte-identical Phase 7 baseline geometry, purchases, weapon, stairs and rebirth checks still provide server-system evidence. Additional one-client baseline regressions confirmed the Reactor Crown entry cue, owner roster access and JuggerJigg toggle with 6 armor. Mock reconnect restored 72 Scrap, Walls and one rebirth. Failed read blocked a second write.
- Independent Phase 8 regrade before the final HUD retest: 8 engagement, 8 retention potential, 8 cleanliness, 8 build quality, 7 evidence. Weighted 7.90/10. The remaining evidence gate covers two-client plot/sale isolation, PvP, power interactions, regular-player admin denial, actual isolated Roblox restart/reconnect, touch/controller and low-end performance.
- Walkthrough and release gates are in ALPHA_PLAYTEST.md. Add uncoached timings and voluntary arena/rebirth choices to the alpha follow-up, alternate cargo routing and replay choices to the next progression prompt, and unfinished technical, art and rollback gates to the release acceptance prompt.

- Final independent re-score after the HUD retest: 9 engagement, 8 retention potential, 8 cleanliness, 8 build quality and 7 evidence. Weighted 8.10/10. Release acceptance remains pending under the above-7 rule.

## Planned phases 9–12

- Phase 9: Hide pads until their branch prerequisites are met. Weapons, production and infrastructure advance independently, with sequential dropper tiers.
- Phase 10: Begin the model and visual overhaul with a finished production bay, then cover both floors, all eight plot identities and Reactor Crown.
- Phase 11: Add earnable rarity tiers and plan damage or income pets. Evaluate an owner-approved premium Robux egg with the strongest pets, clear odds and eligibility controls. Protect competitive PvP balance.
- Phase 12: Complete launch acceptance. Carry forward open Phase 8 gates. Combined Phase 9–11 execution prompt is saved in DEADZONE_DOMINION_PHASES_9_AND_10_PROMPT.md.

## Phases 9–11 local candidates

- Phase 9: independent production, weapon and infrastructure branches, sequential prerequisites and hidden pads. Version 1 profiles retain prior weapon entitlements. Current Phase 9 source is included in the latest Phase 11 candidate.
- Phase 10: original procedural Parts and built-in Roblox materials add station armor, status bars, conveyor markers and tiered dropper fins. Full model and texture pass, screenshots and performance measurements remain open.
- Phase 11: one equipped pet, six rarities, earnable first egg after Twin Dropper, later Scrap eggs, partial duplicate refund, local followers and factory income effects. Damage bonuses are reserved for future PvE. No live Robux integration.
- Proposed Studio premium egg at 99 Robux: Arc Hound 65% (+20% income), Crown Drake 30% (+30% future PvE damage), Nova Warden 5% (+35% income). All three have a non-Robux factory egg path; earnable odds 6%, 2%, and 0.5%, respectively.
- Independent source reviews, weighted: Phase 9 improved from 6.15 to 7.70; Phase 10 6.25; Phase 11 6.40. Applied review findings for hidden art, hatch pricing and debounce, preset fields and isolated premium simulation. Acceptance remains open.
- Carry visual differentiation, screenshots and device performance into Phase 10 follow-up. Carry pet damage in PvE, two-client verification, real isolated persistence, and approved paid receipt integration into Phase 11 follow-up. Preserve open Phase 8 release gates.

- Built DeadzonePhase9-Branches.rbxl (initial branch candidate before follow-up fixes), DeadzonePhase10-Art.rbxl (intermediate art candidate), and DeadzonePhase11-Pets.rbxl (latest combined candidate, SHA-256 begins FE056B02E31C6957). Studio reported low system resources and did not open the combined candidate during verification. No runtime results for these candidates. The review scores above precede the latest follow-up fixes and need another pass with Studio evidence.

## Construction, lighting and power eggs

- New plots provide a claim terminal, a foundation and 25 starter Scrap. Starter Factory activates the production line. The perimeter walls, upper stairs and deck, arsenal, egg incubator and rebirth console appear with their purchases. Prior profiles retain construction needed for existing progress.
- Brighter daylight, lighter factory surfaces and color-coded purchase cards mark the visual pass. The purchase card changes tone with affordability and shows the price directly.
- Eight plot-themed earnable eggs contain two outcomes per rarity tier, for 96 themed pets. Profiles retain the original six pet IDs for compatibility. Paid eggs remain simulated.
- Reference: BIG Games' Pet Simulator X Doodle and Space updates demonstrate themed egg variants and visually distinct pet families. Adapted the theme structure to Deadzone's own powers.
- Rojo built Deadzone-ConstructionAndEggs.rbxl. Visual appearance, overlap clearance, purchase and rebirth flows and all eight egg pools need Studio regression and independent re-review before release acceptance.

## Art, shop and live rankings

- Candidate: Deadzone-ArtShopBoards.rbxl. Icon artwork: Deadzone-Dominion-Icon.png. Original geometry uses Roblox Parts. Added station and weapon shells, expressive pet models and arena perimeter crystal gardens.
- Factory Shop sells three permanent pet trails for 120, 240 and 360 Scrap and directs players to their power egg incubator. Server sets the price, deducts Scrap and grants/equips the trail. No transaction with real money was made.
- Five live boards update every five seconds for the current server: wallet, rebirths, arena eliminations as the power metric, session minutes and net Scrap spent. Global ranking, cumulative playtime and Robux-spend tracking remain roadmap items.
- Market reference: BIG Games' official Pet Simulator X Anime update and Pet Simulator 99 FAQ show themed egg offerings and a dedicated shop. Roblox experience listings for Elemental Powers Tycoon and Steal a Brainrot support using distinct power presentation and collectible personalities. Public evidence does not establish which passes have the best sales.
- Proposed Robux test prices for owner review: 49 for a guaranteed signature trail, 149 for a guaranteed cosmetic bundle, and the earlier 99 for a premium egg after odds, eligibility and receipt verification. These are hypotheses, not verified best-selling price points. Showcase featured items with accurate fixed prices. Use Roblox price optimization after sufficient real data and owner approval.
- Rojo build and tracked diff whitespace check passed. Shop purchase and re-equip, new profile fields, art/readability and multiplayer rankings require Studio runtime acceptance. Storefront icon upload and live premium offers remain separate release actions.

## Visual overhaul local playtest

- Local candidate `Deadzone-VisualOverhaul-Refined.rbxl`, SHA-256 `5EDA7C0EF9EC2F87DBF617BBB76C9D965DB6348C2141870883AA8A73D5622EDD`. Opened and played in Roblox Studio from the Rojo-built file. Live Rojo sync was not reverified in this pass. The prior local place is backed up in `art/rollback`.
- All eight plots have power-specific crests, gate ownership text, and colors shared with factory and egg details. Claim arrival moved closer to the Starter Factory. New visuals include four cargo silhouettes, common teal collection, egg and pet motifs, lower glare at the arena and factory, and a scrollable shop. Boards name the actual session metrics.
- Solo desktop Studio verified first claim, a 25 Scrap Starter Factory debit, first cargo sale worth 5 Scrap, a 15 Scrap collection, Twin Dropper visibility and a disabled Foundry pad. Isolated upgraded preset exposed walls, upper deck and incubator. A free hatch equipped Rhythm Pup. The 120 Scrap Aqua Spark purchase rejected a balance of 100 and succeeded after collection with an exact 120 debit. Release reset the terminal ownership and hid the incubator. A second claim updated Spam-Him-Up ownership.
- Runtime startup counts were 2,358 Part instances and 4,544 Workspace descendants on the baseline, 3,632 and 5,939 on the first art candidate, and 2,898 and 5,205 on the refined candidate. These counts do not establish frame times or memory on a real device.
- Independent re-review after solo regression scored 7.73/10 weighted (engagement 8, retention potential 7.5, cleanliness 8, build quality 7.5, test evidence 7.5). The reviewer verified source and file hash and evaluated the builder's runtime evidence. Release acceptance remains open.
- Art direction, asset provenance, research and defects are in `art/Visual-Overhaul.md`. Custom mesh and texture import, storefront thumbnails, all-plot and all-power play checks, physical touch/controller input, multiplayer, isolated save/reconnect and performance remain open. The Roblox cloud place was not published.

### Mesh continuation

- `Deadzone-Mesh-Eggs.rbxl`, SHA-256 `E88A65B4A8098E3C052A47FA43292C1F9C042F001A9036B33386CFCE461D2F16`, reopened and played in Studio. Its Rojo-built ServerStorage template carries the imported 164-triangle Power Egg shell (mesh asset `122522546308019`), created from the editable original OBJ.
- Solo desktop Studio verified eight tinted shells, all hidden and noncolliding on fresh plots. The isolated upgraded preset exposed JuggerJigg's shell. The client loaded and displayed it, and a normal incubator prompt hatched and equipped Rhythm Moth.
- Six other original OBJ exports in `art/meshes` pass the generator's closed-edge and winding checks. Integration of the reactor beacon, four cargo tiers, and dropper housing remains pending. The local Dev Hub reflects the new build. Preparing the hosted Dev Hub source did not complete, so no newer hosted version was confirmed.
- Independent mesh review scored 7.80/10 weighted and verified the saved file hash, original source and complete Studio screenshot. Asset access on another client and release acceptance remain open.

### Production mesh playtest

- `Deadzone-Production-Meshes.rbxl` (SHA-256 `83614D79BFFED4EA8D0C5C1D7A69C308C8BEA8230C888109059D3FC88B5AB8D5`) reopened and played with one desktop Studio client. Rojo packages seven original meshes: Power Egg, four cargo tiers, dropper housing, and Reactor Crown beacon.
- All 32 housings were hidden and noncolliding on fresh plots. Starter Factory debited 25 Scrap, revealed only the first housing, and produced a first sale of 5 Scrap. An isolated upgraded profile showed all four cargo tiers. A sampled tier-three MeshPart moved 2.78 studs along the conveyor at its expected height.
- The client reported successful fetches for all seven meshes. Server raycasts hit the beacon's 2.4-stud core and passed outside it. Collecting credited the wallet, and releasing JuggerJigg cleared ownership, hid its four housings, and removed all active cargo.
- Independent regrade: 7.90/10 weighted (engagement 8, retention potential 7.5, cleanliness 8, build quality 8, evidence 7.75). Multiplayer asset access, physical device checks and isolated persistence remain open.

### Two-client regression and district art

- Production Meshes passed a two-client Studio server test. Player2 attempted the owned JuggerJigg plot, received no claim, and then claimed Spam-Him-Up. Player1 bought the starter and collected 10 Scrap. Player2 stayed at 25 Scrap in the wallet and zero pending. Both clients loaded seven mesh templates. Updated independent score: 7.95/10.
- `Deadzone-District-Art.rbxl` (SHA-256 `9F308536E4A74094079478429C2AA78246F493F8FC922333C44AC4734C52042B`) adds approach markers, horizon silhouettes, cover accents and gated wall and Floor Two art. Eight center routes passed short obstruction checks. All eight egg pools contain 12 outcomes, two per rarity, and total 1,000 weight each.
- Studio solo check confirmed wall caps and upper runners were hidden on all eight fresh plots. On JuggerJigg, the upgraded preset showed both. A double-confirmed rebirth changed R0 to R1 and reset the wallet to 25, re-hiding the wall, upper runner, and dropper mesh.
- The real ProfileStore module saved and restored wallet, rebirth, pet and trail through a test adapter shared by two store instances. A failed load wrote nothing. This was isolated module coverage, without access to a Roblox DataStore, in local PlaceId 0.
- Warm five-second desktop Studio sample at the JuggerJigg approach: 301 frames, median 16.67 ms, p95 18.31 ms, total reported memory 1,022.3 MB. Pending matched baseline, physical input/device performance and longer multi-plot profiling. District repeated the ownership, payout isolation and seven mesh fetches with two clients. Independent District regrade: 8.15/10.

### Visual playtest candidate

- Open `Deadzone-Visual-Playtest-Ready.rbxl` locally and select Play in Studio. SHA-256 `D6B0D687DFFD3BAB61E126DF29EF8E18164FE645F84830D2DE4A18EDC14ADC5B`. `Deadzone-Visual-Local.rbxl` (`C805858FE878E6F7BC81EF5E009DB595A6644642E703407653AD5EC056FE6399`) is the previous tested candidate. No Roblox place publication was performed.
- A manual render check exposed zero source mesh extents even when Roblox reported a successful fetch. All seven Rojo templates now store their original extents. Reopening in Studio verified seven nonzero `MeshSize` values and proportionate dropper, Power Egg and Reactor Crown renders.
- The arsenal and five equipped weapon silhouettes use original geometry. Normal progression in the arsenal art build verified Scrap Pulse, Ion Carbine and Arc Lance. Isolated advanced progression verified Reactor Breaker and Prism Repeater. The standard prompt appeared after the arsenal, while the sidegrade prompt also required its Floor Two entitlement.
- The pet panel has responsive dimensions and clearer odds. Desktop Studio showed 12 distinct outcomes totaling 100% in the JuggerJigg panel. The combined build tested a fresh claim, 25 Scrap purchase, 30 Scrap collection, and a free hatch that equipped Echo Beetle. The guide named the target purchase and required amount before and after saving.
- The combined build passed with two simulated desktop clients in a local Studio server. Both loaded all seven meshes. Player 2 was denied the occupied JuggerJigg claim and Dominion Control, then claimed Spam-Him-Up. Player 2 could not collect from JuggerJigg and stayed at 25 Scrap with zero pending. Player 1 collected 45 Scrap.
- Independent review on the combined build scored 8.45/10, with engagement 8.5, retention potential 8, cleanliness 8.5, build quality 8.5 and evidence 8.75. Owner and power readability scored 8.5, and visual coherence scored 8.25. Follow-up feedback led to an inclined arsenal nameplate, tested hidden on all eight fresh plots and visible at player height in an upgraded preset.
- Remaining launch gates include physical touch and controller, unassisted player pacing, the full two-client combat and power suite, actual save and reconnect with a private test experience, sustained matched performance profiling, and broader asset and pet render coverage. Market cues and full rollout evidence are tracked in `art/Visual-Overhaul.md` and the local Dev Hub.
