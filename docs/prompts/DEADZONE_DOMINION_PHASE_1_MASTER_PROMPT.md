# DEADZONE DOMINION: POWERS TYCOON
# MASTER AI DEVELOPMENT, ENVIRONMENT SETUP, AND PHASE 1 EXECUTION PROMPT

**Document Version:** 1.1 — updated for the verified local setup and Phase 1 review process  
**Project:** Deadzone Dominion: Powers Tycoon  
**Development Platform:** Roblox Studio  
**Language:** Luau  
**Primary Coding Environment:** Visual Studio Code  
**Synchronization:** Rojo  
**Version Control:** Git  
**Operating System:** Windows 11, unless the user specifies otherwise  
**Primary AI:** GPT-6.1 Sol, High reasoning (if available; see the run recommendation in the accompanying handoff)  
**Current Development Phase:** Phase 1 — Environment, Architecture, and Playable Map Foundation

---


# AUTHORITATIVE PROJECT STATE AND PHASE 1 AMENDMENTS (2026-11-12)

These amendments reflect the user's confirmed project and connection state. They override any conflicting setup or place-creation instruction later in this prompt. Preserve the original game design below unless the user changes it.

## Confirmed development setup

- The project root is `C:\Users\GoldD\OneDrive\Documents\ChatGPT\Roblox Game`. This is the user's approved project folder. Keep using it; do not move or rename it as a setup step.
- Windows 11, Roblox Studio, Visual Studio Code, Git, Rojo CLI, the Rojo Studio plugin, and the VS Code Rojo setup are already installed/configured.
- The local Rojo CLI is `tools\rojo\rojo.exe` (Rojo 7.7.1). VS Code points to `${workspaceFolder}/default.project.json`.
- The current `default.project.json` maps `src\shared` to `ReplicatedStorage\Shared`, `src\server` to `ServerScriptService\Server`, and `src\client` to `StarterPlayer\StarterPlayerScripts\Client`. Inspect and extend it only when necessary; do not replace it blindly.
- Git is initialized, but project files were untracked when this prompt was prepared. Inspect `git status` and history before staging or committing. Create a baseline commit only after reviewing its contents and confirming identity configuration; never claim a commit exists unless it does.

## Confirmed Studio place and live connection

- The user confirmed the currently open Roblox Studio place, **Power-Up tycoon**, is the correct place for this project. Reported place ID: `96511474175721`; universe ID: `10776289738`. The user authorized renaming it. Continue in this place; do not create a replacement experience or publish a new place.
- The user's PowerShell reported the Rojo server listening at `localhost:35011`; the user connected the Rojo Studio plugin. Keep that user-owned process running. Do not start duplicate servers or terminate user-owned processes. If it stops, inspect first and restart from this project root using `.\tools\rojo\rojo.exe serve --port 35011` only if the port is free. If occupied, check the existing endpoint before acting.
- Live disk-to-Studio sync was verified: `src\shared\ProjectInfo.lua` included `SyncStatus = "Live sync verified"`, and Studio's `ReplicatedStorage.Shared.ProjectInfo` showed that source. Do not repeat installation/setup. Verify later changes separately and report only checks actually performed.
- Do not publish, overwrite, or replace the live place. Before any operation that could replace substantial Studio content, inspect the place and make a local backup or use available version history. Preserve user-managed content outside Rojo's mapped containers.

## Phase 1 starting point and working style

- The synchronized project currently has a minimal `ProjectInfo` ModuleScript and the mappings above. Inspect actual files and the Studio tree before adding architecture; adapt the proposed tree without duplicating files or pretending unfinished modules work.
- Connection and initial script sync already pass. Focus Phase 1 on architecture, the graybox map, eight plots, plot claiming, and the remaining acceptance criteria.
- The user wants direct work in the real project and control of available tools where possible. Use accessible local-file and Studio tools; request only unavoidable user UI steps or permissions, with concise exact instructions.
- Keep the development place private. No publishing action is authorized by this prompt.

## Independent critical review and iteration loop

Use a second, independent reviewer agent for skeptical review of each substantial Phase 1 deliverable and at the final acceptance gate. The reviewer must inspect implementation and test evidence, not merely endorse the builder's summary. If a second agent cannot actually be run, disclose that and label the review as self-review; never claim independent review.

The reviewer scores each category from 1 to 10, cites concrete evidence, and lists actionable changes:

1. **Engagement:** Does the map and initial loop invite exploration, meaningful decisions, and fun player interaction?
2. **Retention:** Does the foundation support clear short-term goals, a reason to return, and progression hooks without implementing deferred Phase 2 systems prematurely?
3. **Cleanliness:** Are map, hierarchy, naming, code organization, visual readability, and Studio scene free from avoidable clutter and inconsistencies?
4. **Build quality:** Are Rojo ownership boundaries, server/client responsibilities, plot geometry/orientation, claim behavior, spawn safety, performance, and failure handling sound?
5. **Test evidence:** Were checks actually run in Studio or supported tools, do they cover realistic cases, and do they support the reported claims?

Give an overall score from 1 to 10 using these weights: build quality 30%, cleanliness 25%, engagement 20%, retention 15%, and test evidence 10%. Treat engagement and retention as design judgments grounded in stated criteria, not measured player analytics. Never invent playtest or retention data.

After each review, apply the reviewer's actionable suggestions, including polish suggestions that improve the work even when its score is above 7. Then rerun relevant checks and request a fresh independent score. If any category or overall score is 7 or lower, the result is not accepted: apply the suggested fixes and retest. Repeat while scores improve and changes are making progress. If a relevant category or overall score remains 7 or lower after a complete fix-and-retest cycle, discard the current implementation of the affected deliverable and rebuild that deliverable from a revised approach; do not destroy unrelated working systems or the user's Studio place. Test the rebuilt result and review it again. Continue until every category and overall score is above 7, or report the concrete blocker and evidence if tools/access prevent further iteration. Record scores, findings, changes, and retest evidence in `DEVELOPMENT_STATUS.md`. Never mark a deliverable complete solely because the builder believes it is done.
---

# SECTION 1 — YOUR ROLE

You are the lead developer and technical architect for a multiplayer Roblox game titled **Deadzone Dominion: Powers Tycoon**.

You are responsible for overseeing the development of a complete PvP-focused zombie survival tycoon experience.

Operate as a professional Roblox development team with expertise in:

- Roblox Studio
- Luau scripting
- Multiplayer networking
- Client-server architecture
- Roblox DataStores
- Roblox PathfindingService
- Physics and character movement
- Modular weapon systems
- Ability systems
- Tycoon frameworks
- User interface development
- Zombie AI
- Base-defense mechanics
- Game economy design
- PvP balancing
- Animation and effects
- Anti-exploit protection
- Mobile and console compatibility
- Performance optimization
- Rojo
- VS Code
- Git
- Automated testing

Your primary responsibility is to transform the game specification into an actual, organized, functional Roblox game.

You must not simply describe how to develop the game when the necessary development tools are available.

You must create, edit, inspect, and test the real project files wherever your environment permits.

If tools cannot access the user's local computer, explicitly state the limitation and provide executable files or exact installation instructions. Never claim to have installed software, connected to Roblox Studio, or run a test without having actually done so.

## 1.1 Development Philosophy

Follow these principles:

1. Build functional systems before adding visual polish.
2. Use modular, reusable Luau architecture.
3. Keep important configuration values centralized.
4. Use server-authoritative systems for sensitive gameplay.
5. Minimize unnecessary script duplication.
6. Maintain compatibility with eight simultaneous players.
7. Design for mouse/keyboard, touch, and controller input.
8. Save important permanent progression safely.
9. Preserve all user-requested mechanics.
10. Prefer targeted modifications instead of rebuilding working systems.
11. Test each completed feature.
12. Maintain clear documentation of project progress.
13. Do not introduce unnecessary third-party dependencies.
14. Maintain a professional and consistent folder structure.
15. Never allow temporary testing code to become permanent production functionality accidentally.

You should always consider how a feature affects other features before implementing it.

For example, the weapon framework must be designed to support CritShot's instant elimination chance, Spam-Him-Up's hit tracking, and Double Pop's damage multiplier without requiring separate combat systems.

---

# SECTION 2 — COMPLETE GAME OVERVIEW

Deadzone Dominion is an eight-player competitive Roblox game combining tycoon progression, intense PvP, zombie survival, and base defense.

Each player claims one of eight unique tycoons.

Every tycoon has:

- Its own visual theme.
- Its own signature combat power.
- Three or more specialized weapons.
- Its own generator progression.
- Its own physical construction and decoration.
- Upgradeable barricades.
- Automated defensive turrets.
- A central power core.
- Equipment stations.
- A protected respawn area.
- A distinctive exterior identity.

The eight tycoons surround a compact central battlefield.

Players passively earn currency from their tycoons, but can progress more quickly by leaving their bases to fight other players and capture dangerous objectives.

Zombies periodically attack each player's base.

At the beginning of progression, zombies are a genuine threat.

As players build defenses and improve weapons, zombies become increasingly manageable and PvP becomes the primary gameplay focus.

## 2.1 Eight Mandatory Powers

### Power 1 — JuggerJigg

Dancing generates additional armor.

- Armor accumulates while performing a qualifying dance.
- Default generation: 8 armor per second after a short startup.
- Maximum additional armor: 60.
- Armor absorbs incoming damage before health.
- Attacking cancels armor-generating dancing.
- Theme: rhythm, heavy armor, speakers, industrial bass machinery.
- Colors: crimson, black, copper.

### Power 2 — Spam-Him-Up

Repeatedly hitting one specific opponent triggers a speed boost.

- Hit thresholds depend on weapon category.
- Faster weapons require more hits.
- Hits against different enemies do not combine.
- Default speed bonus: 25%.
- Default duration: 5 seconds.
- Theme: electricity, speed, kinetic machinery.
- Colors: cyan, yellow, graphite.

### Power 3 — Double Pop

Eliminating two opponents empowers the player's next 15 qualifying attacks.

- Damage multiplier: 2×.
- Maximum empowered attacks: 15.
- Effect expires after 5 minutes.
- Charges are only consumed by legitimate damaging attacks.
- Elimination progress resets on death.
- Theme: explosions, combos, dual energy chambers.
- Colors: orange, pink, charcoal.

### Power 4 — Rising Sun

The player can revive after a lethal attack.

- Character enters a gray, semi-transparent spectral state.
- Character gradually becomes golden.
- Character is invincible and unable to fight during transformation.
- The revival ends with a controlled golden flash.
- Player receives 2 seconds of additional immunity.
- Default revival cooldown: 180 seconds.
- Theme: rebirth, spectral energy, golden light.
- Colors: gold, white, gray.

### Power 5 — SlurperAid

The player can collect healing bubbles from recently eliminated opponents.

- Bubbles appear approximately 3.5 studs above death locations.
- Only eligible SlurperAid players can see and collect them.
- Bubbles despawn after 20 seconds.
- Pickup restores 15% of maximum health.
- If already at full health, create a short red smoke puff containing a faint black skull.
- Theme: experimental medicine, biological scavenging.
- Colors: dark green, red, white.

### Power 6 — PlopperFizz

Significant falls cause purple explosions upon landing.

- Ordinary jumps on level ground do not trigger the ability.
- The player is immune to fall damage and their own explosions.
- Explosion damage increases with fall distance.
- Maximum default damage: 48.
- Maximum radius: 13 studs.
- Default minimum qualifying descent: 8 studs.
- Theme: gravity, experimental chemicals, purple impact energy.
- Colors: purple, lavender, dark slate.

### Power 7 — CritShot

The player receives an income bonus and a chance to instantly eliminate opponents.

- +10% ordinary tycoon generator income.
- The economic bonus excludes Robux-purchased currency, paid boosts, and external rewards.
- Each valid damaging attack has a 1-in-25 chance of instantly eliminating its target.
- Probability is exactly 4%.
- The server performs the random roll.
- One shotgun trigger pull must not create one roll per pellet.
- Theme: precision, targeting, industrial currency processing.
- Colors: acid green, black, steel.

### Power 8 — PolarBear Kick

The player can loot temporary copies of weapons held by recently eliminated players.

- Loot appears near the death location.
- Only eligible PolarBear Kick players can see or interact with it.
- Loot expires after 20 seconds.
- Maximum stolen weapons carried: 2.
- Stolen weapons use limited reserve ammunition.
- Looted weapons are temporary.
- Premium and administrative weapons cannot be stolen.
- Theme: cryogenic storage, weapon scavenging, ice.
- Colors: ice blue, navy, white.

## 2.2 Game Identity

The overall experience should evoke the intensity of arcade-style zombie survival shooters while remaining entirely original.

Include original versions of familiar genre mechanics, such as:

- Weapon upgrade machines.
- Power restoration.
- Zombie waves.
- Barricade repairs.
- Special equipment lockers.
- Power-specific abilities.
- Combat announcements.
- Environmental emergency events.

Use original naming, art, music, animations, sound effects, models, and interface design.

Do not copy another game's assets or recognizable protected creative expression.

---

# SECTION 3 — IMPORTANT FUTURE SYSTEMS

The following systems must be accounted for in the architecture, even though they should not all be implemented during Phase 1.

## 3.1 Weapons

Support:

- Pistols
- Automatic rifles
- SMGs
- Shotguns
- Precision rifles
- Melee weapons
- Explosive weapons
- Unique power-specific weapons

All weapons must share a central damage system.

## 3.2 Zombies

Create a modular zombie framework supporting:

- Walker
- Runner
- Bruiser
- Spitter
- Saboteur
- Abomination

Zombies attack bases, players, and defensive structures according to their behavior configuration.

## 3.3 Base Defense

Support:

- Barricades
- Reinforced walls
- Repairable gates
- Basic turrets
- Heavy turrets
- Shock turrets
- Automated repair systems
- Advanced defensive upgrades

## 3.4 Central PvP Objectives

The map contains three primary areas:

**Reactor Crown**

Central capture point providing an initial +35% ordinary tycoon income while controlled.

**Supply Yard**

A contested resource event located approximately 64 studs east of the center.

**Quarantine Relay**

A contested utility objective approximately 64 studs west of the center.

## 3.5 Progression

Support:

- Currency generation
- Tycoon purchases
- Permanent saves
- Missions
- Power mastery
- Prestige
- Season XP
- Battle pass progression
- Cosmetics

## 3.6 Monetization

Eventually implement:

- Game passes
- Developer products
- Cosmetic upgrades
- Modest production boosters
- Optional special weapons balanced as sidegrades
- Free and premium seasonal battle-pass tracks

Also create a separate paid progression system called **Blacksite Acquisition Chain**.

This chain contains paid reward nodes followed by bonus nodes requiring the preceding paid purchase.

Clearly disclose those prerequisites. Do not call a bonus reward independently free if payment is required to access it.

All monetization must comply with current Roblox policies.

**Do not implement monetization during Phase 1.**

---

# SECTION 4 — DEVELOPMENT TECHNOLOGY

Use the following development stack.

## 4.1 Required Software

1. Roblox Studio
2. Visual Studio Code
3. Rojo 7.x
4. Rojo Roblox Studio plugin matching the CLI major version
5. Rojo VS Code extension
6. Luau Language Server extension for VS Code
7. Git

## 4.2 Recommended Supporting Tools

Use these only when they provide a concrete benefit:

- Rokit for pinned development tools.
- StyLua for Luau formatting.
- Selene for Luau linting, if compatible with the chosen architecture.
- Luau Language Server for static analysis.
- GitHub as an optional remote backup.

Avoid installing an excessive number of extensions or libraries.

## 4.3 Preferred Project Approach

Use a **partially managed Rojo project**.

This means:

- Luau scripts and shared configuration are maintained on the local filesystem.
- VS Code is the primary code editor.
- Git tracks changes to source-controlled files.
- Rojo synchronizes managed scripts into Roblox Studio.
- Roblox Studio maintains the visual game scene, terrain, imported models, and other explicitly unmanaged assets.
- Generated map objects can be created or updated by source-controlled Luau scripts.

This approach should prevent source-code changes from accidentally deleting manually constructed Studio assets.

Use a clear ownership boundary between Rojo-managed and Studio-managed instances.

Do not configure Rojo in a way that silently deletes manually created content.

---

# SECTION 5 — FIRST TASK: VERIFY DEVELOPMENT ENVIRONMENT

Before creating game systems, determine which required tools are available.

Check for:

- Roblox Studio
- VS Code
- Rojo CLI
- Rojo Studio plugin
- Rojo VS Code extension
- Git
- Luau Language Server

Determine whether the AI can directly inspect or operate the user's local development environment.

If direct computer access is not available, provide explicit user-executable setup instructions and project files.

Inspect actual system state before changing anything. In this project the required apps, Rojo CLI, Studio plugin, VS Code setup, and Git are already installed, and live sync has passed. Do not reinstall unless a specific verified problem requires it.

Do not assume VS Code can automatically control Roblox Studio.

Do not assume installing the Rojo VS Code extension automatically installs the terminal CLI.

## 5.1 Roblox Studio Setup

The user already completed this setup. Verify existing state when relevant; do not ask them to repeat these steps:

1. Roblox Studio is already installed; use the currently confirmed Power-Up tycoon place.
2. The user is already signed in to Roblox Studio.
3. Do not create a new experience. Continue in the existing user-approved Power-Up tycoon place.
4. The user authorized renaming the existing place to Deadzone Dominion: Powers Tycoon when appropriate; preserve its place and universe identity.
5. Do not publish or overwrite the experience. Publishing requires separate explicit user authorization.
6. Open the Explorer panel.
7. Open the Properties panel.
8. Open the Output panel.
9. Save a backup of the initial place.

The experience should remain private throughout early development.

Do not expose a nonfunctional prototype publicly.

## 5.2 VS Code Setup

Guide the user to:

1. Install Visual Studio Code from https://code.visualstudio.com/.
2. Open VS Code.
3. Install the Rojo extension.
4. Install the Luau Language Server extension.
5. Install Git support if not already available through the editor.
6. Prepare a dedicated game development folder.

Preferred project directory:

`C:\Users\GoldD\OneDrive\Documents\ChatGPT\Roblox Game`

This confirmed project folder is in OneDrive and is the approved working directory. Keep work here; do not relocate it as a setup step.

## 5.3 Git Setup

Guide the user to install Git from:

https://git-scm.com/

Verify installation through the VS Code terminal:

```powershell
git --version
```

Initialize the project repository:

```powershell
git init
```

Create an appropriate `.gitignore`.

Ignore:

- Temporary build artifacts
- Editor-specific local files when appropriate
- Operating-system generated files
- Secrets
- Authentication tokens
- Local test outputs
- Large generated files that should not be source-controlled

Do not ignore actual source files or necessary configuration.

Make the first commit after the project structure is confirmed to work.

---

# SECTION 6 — ROJO INSTALLATION

Follow the current official Rojo documentation.

Official references:

https://rojo.space/docs/v7/getting-started/installation/

https://create.roblox.com/docs/projects/rojo

https://github.com/rojo-rbx/rojo/releases

## 6.1 Installation Method

Prefer a pinned Rojo 7.x CLI installed through Rokit.

If Rokit is not installed, guide the user through its current official installation procedure before using its commands.

Once Rokit is available, configure a project-local Rojo toolchain.

A suitable starting command is:

```powershell
rokit add rojo-rbx/rojo
rokit install
```

Verify:

```powershell
rojo --version
```

Record the exact installed version.

Do not guess that the installed version matches an example.

Do not run terminal commands if the runtime does not permit local command execution.

## 6.2 Studio Plugin

Once the CLI is functioning, install the compatible Roblox Studio plugin:

```powershell
rojo plugin install
```

If the installation fails:

1. Read the error.
2. Check that Roblox Studio is installed.
3. Check permissions.
4. Confirm the Rojo CLI version.
5. Offer the official Creator Store installation method.
6. Ensure the plugin major version matches the Rojo CLI major version.

Do not install an obsolete Rojo plugin.

## 6.3 VS Code Rojo Extension

Install the official Rojo VS Code extension.

Extension identifier:

`evaera.vscode-rojo`

Explain that:

- The extension provides convenient Rojo commands inside VS Code.
- The standalone Rojo CLI is separately required for terminal commands.
- The Studio plugin is separately required for Studio synchronization.

## 6.4 Verify Rojo Components

Confirm:

1. Rojo CLI responds.
2. VS Code extension loads.
3. Roblox Studio displays the Rojo plugin.
4. No version compatibility warnings appear.

If anything fails, fix it before beginning map construction.

---

# SECTION 7 — CREATE THE ROJO PROJECT

## 7.1 Working Directory

Use:

`C:\Users\GoldD\OneDrive\Documents\ChatGPT\Roblox Game`

This project is already initialized and has a working `default.project.json`; inspect it first. Do not run `rojo init` over this project.

Inspect the existing structure first.

## 7.2 Project Configuration

Create or customize:

`default.project.json`

Configure a partially managed project.

The configuration must establish mappings for:

- ReplicatedStorage shared scripts and configuration.
- ServerScriptService server code.
- StarterPlayerScripts client code.
- Necessary GUI source templates.
- Source-controlled assets, when appropriate.

Do not blindly remap entire Roblox services in a way that destroys manually managed instances.

Use appropriate Rojo ownership behavior, including `$ignoreUnknownInstances` where necessary.

The current place ID is 96511474175721. Configure a place-specific safeguard only if supported by this Rojo version and only if it cannot trigger a publish or replace the current place.

Do not invent or guess the game's PlaceId.

## 7.3 Initial File Structure

Create the following local project architecture:

```text
DeadzoneDominion/
│
├── default.project.json
├── rokit.toml
├── .gitignore
├── README.md
├── CHANGELOG.md
├── DEVELOPMENT_STATUS.md
├── GAME_DESIGN.md
├── AMENDMENTS.md
├── TESTING.md
│
├── docs/
│   ├── architecture.md
│   ├── map-layout.md
│   ├── development-roadmap.md
│   └── coding-standards.md
│
├── src/
│   │
│   ├── shared/
│   │   ├── Config/
│   │   │   ├── GameConfig.luau
│   │   │   ├── MapConfig.luau
│   │   │   ├── PlotConfig.luau
│   │   │   ├── PowerConfig.luau
│   │   │   ├── WeaponConfig.luau
│   │   │   ├── EconomyConfig.luau
│   │   │   └── UpgradeConfig.luau
│   │   │
│   │   ├── Constants.luau
│   │   └── Utilities/
│   │       ├── CFrameUtils.luau
│   │       └── TableUtils.luau
│   │
│   ├── server/
│   │   ├── ServerBootstrap.server.luau
│   │   │
│   │   ├── Services/
│   │   │   ├── PlotService.luau
│   │   │   ├── TycoonService.luau
│   │   │   ├── PlayerDataService.luau
│   │   │   ├── EconomyService.luau
│   │   │   ├── CombatService.luau
│   │   │   └── AbilityService.luau
│   │   │
│   │   └── World/
│   │       ├── MapBuilder.luau
│   │       ├── PlotBuilder.luau
│   │       └── ArenaBuilder.luau
│   │
│   └── client/
│       ├── ClientBootstrap.client.luau
│       └── Controllers/
│           └── UIController.luau
│
└── tests/
    ├── map-tests.md
    ├── claim-tests.md
    └── sync-tests.md
```

This is the intended logical organization.

Adjust filenames or Rojo mappings where necessary to ensure Roblox receives the correct Script, LocalScript, and ModuleScript instance types.

Do not create empty placeholder modules that claim to contain completed functionality.

If a future service is not yet needed, either omit its implementation or create a minimal documented interface with no misleading behavior.

## 7.4 Shared Configuration

Ensure all map coordinates, plot measurements, and major gameplay constants are defined in shared configuration modules.

Do not scatter values throughout dozens of scripts.

Use typed Luau where practical.

---

# SECTION 8 — CONNECT VS CODE TO ROBLOX STUDIO

This is a mandatory milestone.

The AI must explain the synchronization process and verify it where tools permit.

## 8.1 Build Initial Project

From the project root, build a local Roblox place file:

```powershell
rojo build -o DeadzoneDominion.rbxl
```

If the command fails, investigate the exact error.

Do not continue until the project configuration is valid.

For a partially managed workflow, clearly explain which environment is authoritative for the current place and which data Rojo manages.

Do not publish, replace, or overwrite the existing Studio place with a generated place file.

## 8.2 Start Rojo Server

The user already started the server and connected Studio. The confirmed endpoint was `localhost:35011`; keep that user-owned PowerShell process open and do not launch a duplicate. If it has stopped, inspect first and restart only if the port is free:

```powershell
.\tools\rojo\rojo.exe serve --port 35011
```

If the port reports in use, check the existing endpoint rather than starting another copy.



## 8.3 Connect Studio

The user already connected the Rojo plugin, and initial live script sync was verified. Do not ask them to repeat this unless the connection has actually dropped.

The initial connection and sync have passed. If the connection drops, reopen the Rojo panel in the confirmed place, connect to localhost:35011, and verify a mapped script in Explorer.

Do not connect to an unrelated Roblox place.

## 8.4 Synchronization Test

Create a minimal source-controlled server script that prints a unique development message.

Example:

```lua
print("[DeadzoneDominion] Rojo synchronization test successful")
```

Save the file in VS Code.

Verify that:

1. The corresponding script exists in Roblox Studio Explorer.
2. The source matches the local file.
3. The script executes during a Studio Play test.
4. The message appears in Output.
5. Editing the local source updates the managed Studio instance.

If the test fails, investigate before constructing game systems.

## 8.5 Confirm Project Ownership Boundaries

Verify that manually created Studio objects are not unintentionally deleted during synchronization.

Create a harmless temporary unmanaged test part if necessary.

Perform a test sync.

Confirm whether the part survives.

Delete the temporary test after verification.

Document the result.

---

# SECTION 9 — PHASE 1 DEVELOPMENT OBJECTIVE

After the environment is verified, implement the first phase of Deadzone Dominion.

## 9.1 Phase 1 Goal

Create a functioning technical foundation and an accurately positioned eight-plot map with a central battlefield.

The map should be a clean, navigable graybox prototype.

Do not build the final detailed environment yet.

Do not implement the full eight powers yet.

Do not implement monetization yet.

Do not create advanced zombies or finished weapons yet.

The first phase should produce a map that can be inspected, tested, and extended reliably.

## 9.2 Phase 1 Deliverables

Deliver:

1. Functional Rojo project.
2. VS Code-to-Studio live synchronization.
3. Modular server bootstrap.
4. Shared configuration.
5. Deterministic map generation.
6. Eight properly oriented tycoon plots.
7. Central PvP arena blockout.
8. Main roads and entrances.
9. Correct spawn placement.
10. Basic visual identifiers for each tycoon.
11. Initial claim system.
12. Functional test output.
13. Basic multiplayer testing.
14. Updated documentation.
15. Initial Git commit.

Do not mark the phase complete if the project does not run.

---

# SECTION 10 — EXACT MAP COORDINATES

Roblox uses studs for world dimensions.

Establish the following convention:

- Positive X: east
- Negative X: west
- Positive Z: south
- Negative Z: north
- Positive Y: upward
- Main ground surface: Y = 0
- Central battlefield origin: X = 0, Z = 0

Create one shared map configuration.

## 10.1 Main Map

Initial ground footprint:

- Width: 720 studs
- Depth: 720 studs
- Top surface: Y = 0
- Ground depth: 12 studs

If the ground is created as an anchored Part, place its center at Y = -6.

Use terrain or anchored geometry that is visually stable and easy to edit.

Keep decorative out-of-bounds terrain separate from the functional playable map.

## 10.2 Eight Plot Coordinates

Use these exact plot pivots:

| Plot | Power | X | Z |
|---|---|---:|---:|
| 1 | JuggerJigg | 0 | -260 |
| 2 | Spam-Him-Up | 184 | -184 |
| 3 | Double Pop | 260 | 0 |
| 4 | Rising Sun | 184 | 184 |
| 5 | SlurperAid | 0 | 260 |
| 6 | PlopperFizz | -184 | 184 |
| 7 | CritShot | -260 | 0 |
| 8 | PolarBear Kick | -184 | -184 |

All eight bases face toward the central arena.

Do not orient all plots identically in world space.

Calculate each plot's inward direction from its pivot to the world origin.

Use a consistent local coordinate basis.

For this project:

- Local negative Z means forward toward the battlefield.
- Local positive Z means backward.
- Local negative X means left.
- Local positive X means right.

The map builder must rotate each plot correctly.

## 10.3 Plot Dimensions

Every base has a consistent initial footprint:

- Width: 108 studs.
- Depth: 118 studs.
- Initial wall height: 12 studs.
- First-floor vertical clearance: approximately 16 studs.
- Main gate width: 14 studs.
- Outer decorative margin: at least 5 studs where space permits.

Do not allow neighboring plot boundaries or decorative structures to overlap.

Add boundary validation to the build process.

## 10.4 Tycoon Local Layout

Create placement markers or initial geometry for these structures:

| Structure | Local X | Local Z |
|---|---:|---:|
| Main Entrance | 0 | -57 |
| Claim Terminal | -18 | -47 |
| Protected Spawn | 0 | 38 |
| Starter Generator | -31 | 19 |
| Conveyor Start | -22 | 8 |
| Currency Collector | -17 | -29 |
| Weapon Station | 29 | -25 |
| Ability Station | 29 | 6 |
| Defense Terminal | -38 | -34 |
| Power Core | 0 | 0 |
| Upgrade Terminal | 22 | 30 |
| Stairs | 42 | 21 |

For Phase 1, only construct fully functioning objects where necessary.

Other structures may be represented by clearly labeled placement markers.

Markers must not claim to provide gameplay functionality.

The main player walkway must remain unobstructed.

Use Roblox Attachment objects or dedicated marker Parts where appropriate.

## 10.5 Orientation Logic

Use each plot's CFrame for placement.

Do not compute final world positions by manually adding unrotated offsets.

Conceptually, use:

```lua
local worldCFrame = plotCFrame * localCFrame
```

Ensure plot rotation faces its entrance toward the center.

Verify visually for all eight plots.

Test that a player standing at the front entrance faces the central battlefield.

---

# SECTION 11 — CENTRAL ARENA BLOCKOUT

Build the arena around world position:

`Vector3.new(0, 0, 0)`

## 11.1 Primary Arena

Create a central approximately circular combat plaza.

Target diameter: 145 studs.

Use gray concrete and dark industrial materials.

Avoid excessive decoration in this phase.

## 11.2 Reactor Crown

Place:

- Main capture platform centered around X = 0, Z = 0.
- Platform top height: approximately Y = 4.
- Platform diameter: 34 studs.
- Four ramps connected to the platform.
- Ramp width: 9 studs.
- Capture marker radius: 14 studs.

The raised platform must be reachable by ordinary Roblox characters without special movement powers.

Create the reactor as a visible but simplified placeholder structure.

Avoid obstructing the capture area's entire playable surface.

## 11.3 Secondary Objective Locations

Create clearly labeled graybox areas for:

**Supply Yard**

- Approximate center X = 64, Z = 0.

**Quarantine Relay**

- Approximate center X = -64, Z = 0.

These are placement targets, not yet functioning objective systems.

Keep approaches from the bases accessible.

## 11.4 Cover

Place initial cover objects around the arena.

Use:

- Concrete barricades
- Simple crate geometry
- Low industrial walls
- Large blockout containers

Create multiple sightline breaks.

Do not obstruct every approach.

Do not place major cover directly inside spawn compartments.

Use anchored geometry.

## 11.5 Player Movement

Provide at least one clear primary road or corridor from each tycoon entrance toward the central combat district.

Target travel time from each main gate to central combat:

Approximately 12–18 seconds using normal movement or ordinary sprint movement where available.

The target is intended to keep PvP frequent.

Validate actual travel times during playtesting.

If movement speed, routes, or obstructions cause excessive travel time, adjust the route geometry while preserving the eight plot pivot locations.

---

# SECTION 12 — PHASE 1 TYCOON EXTERIOR DESIGN

Even the graybox stage should communicate which power belongs to which plot.

Use simple visual identity.

## 12.1 JuggerJigg

- Crimson accents.
- Heavy dark structural geometry.
- Speaker-shaped decorative blocks.
- Industrial armor theme.

## 12.2 Spam-Him-Up

- Cyan accents.
- Yellow line markings.
- Turbine-shaped placeholder.
- Sleek, fast-looking geometry.

## 12.3 Double Pop

- Orange and pink accents.
- Twin circular decoration.
- Explosive-industrial appearance.

## 12.4 Rising Sun

- Gold and white accents.
- Symmetrical structures.
- Circular light-themed decorations.

## 12.5 SlurperAid

- Green and muted red accents.
- Research equipment placeholders.
- Medical-industrial appearance.

## 12.6 PlopperFizz

- Purple accents.
- Chemical tank placeholders.
- Vertical structures suggesting aerial movement.

## 12.7 CritShot

- Dark steel and acid green accents.
- Precision-target shapes.
- Industrial processing decorations.

## 12.8 PolarBear Kick

- Ice blue accents.
- White and navy panels.
- Frozen industrial storage appearance.

These decorations should be simple in Phase 1.

Do not spend significant development effort on final meshes, particles, or complicated lighting yet.

---

# SECTION 13 — PHASE 1 CLAIM SYSTEM

Implement a basic functional claim system.

## 13.1 Unclaimed Plots

Every unclaimed plot displays:

- Plot name.
- Power name.
- Availability indicator.
- Claim interaction.

Use a ProximityPrompt or another secure interaction mechanism.

The server must validate all claims.

## 13.2 Claim Rules

- One active tycoon per player.
- One owner per tycoon.
- No overlapping ownership.
- No stealing occupied tycoons.
- Two players attempting to claim the same plot must not both succeed.
- Leaving players release their active plot after appropriate cleanup.
- Plot ownership must remain consistent during the server session.

## 13.3 Claim Interaction

When a player successfully claims a plot:

1. Server validates availability.
2. Server assigns ownership.
3. Claim terminal updates.
4. Plot nameplate updates to display the player's username.
5. Player teleports to the assigned base spawn.
6. Player receives a confirmation notification.
7. Server logs the successful claim.

If the plot is occupied, the player receives a clear notification.

## 13.4 Player Spawns

Create a protected spawn location inside every base.

Initial local location:

- X = 0
- Z = 38

Calculate Y from the floor surface.

Ensure:

- Spawn location is not inside walls.
- Character fits in the spawn space.
- Character faces the appropriate direction.
- Respawning works.
- Players cannot accidentally spawn in the void.

Provide a neutral initial spawn or lobby point for players who have not claimed a tycoon.

Do not teleport players into a random occupied base.

## 13.5 Leaving and Cleanup

When a player disconnects:

- Remove session ownership.
- Update the exterior nameplate.
- Reset session-specific claim states.
- Remove temporary player-specific objects.
- Preserve the map.
- Do not damage unrelated players' plots.

Persistent claim ownership across servers is not required.

Permanent progression will be saved in a later development phase.

---

# SECTION 14 — SERVER ARCHITECTURE

Create one server bootstrap script.

Its responsibility is to initialize services in a predictable order.

Suggested initialization sequence:

1. Load shared configuration.
2. Validate configuration.
3. Initialize map-generation system.
4. Initialize plot registry.
5. Initialize claim service.
6. Register player join and leave handling.
7. Initialize client-facing state synchronization.
8. Announce readiness to the server Output.

Avoid circular ModuleScript dependencies.

Service modules should have clearly defined initialization functions.

Use a consistent error-reporting strategy.

If a critical service fails, log a useful error instead of silently continuing.

## 14.1 Map Generation

Use a deterministic map-generation system.

Requirements:

- Re-running generation must not create duplicated plots.
- Existing managed map geometry should be replaced or updated safely.
- The system must not destroy unrelated manually managed Studio objects.
- All generated geometry must have predictable names.
- Use anchored Parts for static geometry.
- Organize generated objects under a dedicated model.

Recommended Workspace hierarchy:

```text
Workspace
├── Map
│   ├── GeneratedEnvironment
│   ├── CentralArena
│   ├── Roads
│   └── NeutralSpawn
│
├── TycoonPlots
│   ├── Plot01_JuggerJigg
│   ├── Plot02_SpamHimUp
│   ├── Plot03_DoublePop
│   ├── Plot04_RisingSun
│   ├── Plot05_SlurperAid
│   ├── Plot06_PlopperFizz
│   ├── Plot07_CritShot
│   └── Plot08_PolarBearKick
│
└── RuntimeEntities
```

Map and plot builders must reuse the same configuration.

## 14.2 Avoid Source Conflicts

If the map is generated at server startup, clearly document that the generated Parts are runtime objects.

Do not confuse runtime geometry with permanently saved Studio geometry.

If persistent Studio editing is needed later, design a controlled map-generation workflow rather than relying on changes made only during Play mode.

---

# SECTION 15 — PHASE 1 USER INTERFACE

Create only the basic interfaces needed for testing.

## 15.1 Claim Notification

Show:

- Successful claim.
- Occupied plot.
- Already owns a plot.
- Claim failed.

## 15.2 Temporary Development HUD

Display:

- Player's assigned plot.
- Current power name.
- Current development phase.
- Optional diagnostic information.

Keep the development HUD simple.

Do not implement the final combat HUD yet.

## 15.3 Debug Information

Provide a way to inspect:

- Plot ownership.
- Plot IDs.
- Spawn assignments.
- Map-generation status.
- Rojo synchronization state where relevant.

Do not expose sensitive developer functions to ordinary players.

---

# SECTION 16 — TESTING REQUIREMENTS

Never assume that code is correct because it contains no obvious syntax errors.

## 16.1 Synchronization Test

Initial live sync has already passed for src\shared\ProjectInfo.lua to ReplicatedStorage.Shared.ProjectInfo. Preserve that as verified history; verify later changes separately.

Verify that:

- VS Code changes appear in Roblox Studio.
- Roblox recognizes the correct script instance types.
- The correct project is being synchronized.
- Manually managed objects are not unexpectedly removed.

## 16.2 Map Tests

Verify:

- Exactly eight plots exist.
- Every plot is correctly named.
- Every plot uses its configured coordinates.
- Every plot faces inward.
- No plots overlap.
- Entrance roads are navigable.
- The central platform is accessible.
- Arena cover is anchored.
- No critical walkway is blocked.

## 16.3 Claim Tests

Verify:

- Player can claim an available plot.
- A second player cannot claim the occupied plot.
- One player cannot claim multiple plots.
- Disconnecting releases the plot.
- Reclaiming after a player leaves works.
- Teleportation places the player inside the correct base.
- Respawning works.

## 16.4 Multiplayer Test

Use Roblox Studio's Server & Clients mode.

Test with two simulated clients first.

Procedure:

1. Start a two-client simulation.
2. Have Player A claim JuggerJigg.
3. Have Player B attempt to claim JuggerJigg.
4. Verify the second claim is rejected.
5. Have Player B claim Spam-Him-Up.
6. Verify independent ownership.
7. Verify both players see the same claim states.
8. Test movement from both bases to the central arena.
9. Test player respawning.
10. End the simulation.

Later repeat relevant tests with eight clients.

## 16.5 Error Handling

Examine Roblox Studio Output.

Identify:

- Syntax errors.
- Missing ModuleScripts.
- Circular dependencies.
- Incorrect Rojo mappings.
- Nil references.
- Server/client execution mistakes.
- Invalid CFrames.
- Duplicate instances.
- Unexpected runtime warnings.

Do not conceal errors.

Do not report an unexecuted test as passed.

---

# SECTION 17 — PHASE 1 ACCEPTANCE CRITERIA

Phase 1 is complete only if all of these conditions are satisfied:

- [ ] VS Code project exists.
- [ ] Rojo is installed and configured.
- [ ] Rojo Studio plugin is connected.
- [ ] Live script synchronization works.
- [ ] Roblox Studio opens the correct development place.
- [ ] Project hierarchy is modular.
- [ ] Server bootstrap executes.
- [ ] Map generation executes without critical errors.
- [ ] All eight plots appear.
- [ ] Plot orientation is correct.
- [ ] The central arena exists.
- [ ] Roads connect the bases to the center.
- [ ] Every plot has an interaction terminal.
- [ ] At least two players can claim different plots.
- [ ] The same plot cannot be claimed twice simultaneously.
- [ ] Spawn and respawn behavior is correct.
- [ ] Developer documentation is updated.
- [ ] Git repository has an initial baseline commit.
- [ ] Known issues are recorded.

Mark environment, plugin connection, and initial live sync as already verified based on the project-state amendment at the beginning of this prompt. Do not substitute explanations for the remaining requirements.

If any requirement cannot be met because of missing access, explain the precise blocker.

---

# SECTION 18 — DEVELOPMENT PROGRESS DOCUMENTATION

Maintain these files throughout development.

## 18.1 DEVELOPMENT_STATUS.md

Record:

- Current phase.
- Completed work.
- In-progress work.
- Failed or blocked work.
- Known technical issues.
- Next development action.

## 18.2 CHANGELOG.md

Record major modifications.

Use version numbers.

## 18.3 AMENDMENTS.md

Store future user instructions that change the original specification.

Do not lose earlier amendments.

## 18.4 architecture.md

Document:

- Source-code layout.
- Service responsibilities.
- Shared configuration.
- Communication patterns.
- Client-server trust boundaries.
- Important dependencies.

## 18.5 map-layout.md

Document:

- Coordinate conventions.
- Plot pivots.
- Plot dimensions.
- Entrance orientations.
- Arena positioning.
- Important local offsets.

---

# SECTION 19 — TOKEN EFFICIENCY REQUIREMENTS

Development must be efficient without sacrificing quality.

Follow these rules:

1. Do not repeatedly restate the entire game specification.
2. Read only the relevant files when performing a targeted change.
3. Prefer modifying existing scripts over replacing them wholesale.
4. Keep implementation reports concise.
5. Do not output enormous code listings when actual project files can be edited directly.
6. When the user needs copy-and-paste scripts, provide complete functional scripts rather than incomplete excerpts.
7. Avoid generating unnecessary assets before the related gameplay exists.
8. Maintain a compact project status summary for future sessions.
9. Reuse architecture and configuration.
10. Do not reinvent previously completed systems.
11. Separate planning from execution only when genuinely useful.
12. Never use repetitive explanations to fill the response.
13. Do not sacrifice correctness or testing merely to reduce token usage.

If an implementation requires multiple steps, complete as much as the available environment permits, then accurately report what is finished and what remains.

---

# SECTION 20 — USER AMENDMENTS AND CUSTOM COMMANDS

The game owner may add instructions at any time.

Later user amendments take priority over conflicting earlier game design requirements.

Preserve unrelated systems.

Every amendment should be reviewed for compatibility with existing architecture.

## AMENDMENT TEMPLATE

**Amendment ID:**  
**Date:**  
**Priority:** Critical / High / Medium / Low  
**System:**  
**Instruction:**  
**Specific Placement Requirements:**  
**Gameplay Requirements:**  
**Things That Must Not Change:**  
**Acceptance Criteria:**  

### Amendment 001

[ADD YOUR OWN INSTRUCTIONS HERE]

### Amendment 002

[ADD YOUR OWN INSTRUCTIONS HERE]

### Amendment 003

[ADD YOUR OWN INSTRUCTIONS HERE]

### Additional Commands

[ADD COMMANDS HERE]

## Recognized Commands

**IMPLEMENT:** Build the requested system.

**MODIFY:** Change an existing system.

**REBALANCE:** Adjust gameplay values while preserving intended mechanics.

**REDESIGN:** Change visual design or structure.

**AUDIT:** Inspect for technical problems.

**TEST:** Test the specified features.

**POLISH:** Improve the user experience and visual quality.

**PRESERVE:** Do not modify the identified system.

**ROLLBACK:** Restore a previous known working state when a suitable backup or Git revision exists.

**CONTINUE:** Resume from the latest verified project status.

**EXPLAIN:** Explain architecture or implementation decisions.

**OPTIMIZE:** Improve performance while preserving behavior.

---

# SECTION 21 — WHAT NOT TO BUILD YET

During Phase 1, do not spend time building:

- Final weapon models.
- Complete combat framework.
- Full ability implementations.
- Advanced zombie AI.
- Detailed base-defense systems.
- Battle passes.
- Robux purchases.
- Prestige systems.
- Final cinematic effects.
- Detailed environment art.
- Complicated music systems.
- Advanced inventory UI.
- Finished player progression.

The current goal is a stable foundation.

The complete game specification must guide architectural choices, but future phases should be implemented only after the current phase passes testing.

---

# SECTION 22 — NEXT PHASE PREPARATION

Once Phase 1 passes all tests, the next development milestone is:

**Phase 2 — First Playable Tycoon Economy**

It will include:

1. Starter generator.
2. Scrap Cash currency.
3. Working income generation.
4. Currency collection.
5. Purchase pads.
6. Basic construction upgrades.
7. First weapon station.
8. Basic player weapon.
9. Basic combat and elimination.
10. Persistent tycoon progression groundwork.

Do not automatically overwrite Phase 1 systems while implementing Phase 2.

First inspect the working architecture.

Use the same configurations and existing services wherever practical.

---

# SECTION 23 — REQUIRED FIRST RESPONSE AND EXECUTION

When receiving this prompt for the first time, begin development with the following order.

**Step A:** Determine which development tools and local files are accessible.

**Step B:** Inspect the current development environment without modifying unrelated files.

**Step C:** Guide the user through any required installation or connection steps that cannot be performed automatically.

**Step D:** Establish the VS Code and Rojo project.

**Step E:** Verify live synchronization with Roblox Studio.

**Step F:** Create the modular game architecture.

**Step G:** Generate the eight-plot map and central arena.

**Step H:** Implement the initial claim system.

**Step I:** Test the map and multiplayer claiming.

**Step J:** Update the development documentation and report completion status.

Do not skip synchronization verification.

Do not claim that the map has been tested without running the necessary Roblox Studio tests.

If the environment lacks access to Roblox Studio, create or provide the actual source files and explain the exact steps needed to perform the Studio-specific verification.

Do not ask unnecessary clarification questions.

Use the existing specification and sensible defaults.

Ask for user intervention only where required to install software, grant access, choose a local folder, or perform an operation unavailable to the AI.

## FINAL INSTRUCTION

**Continue Phase 1 of Deadzone Dominion: Powers Tycoon in the existing verified project and Studio place. The environment and initial live sync are already confirmed. Inspect the current project, implement the remaining Phase 1 foundation and eight-plot map, run available checks, obtain the independent critical review described at the beginning of this prompt (or disclose if a second agent is unavailable), fix blocking findings, and report verified results and remaining limitations. Do not move on to Phase 2 until the foundation passes its acceptance gate.**
