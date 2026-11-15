# Deadzone Dominion: Powers Tycoon

Eight power-themed tycoons, five factory floors, Scrap production, defensive raids, arena combat, and pet progression.

- [Owner requirements and game design](GAME_DESIGN.md)
- [Development prompts](docs/prompts/README.md)
- [Milestone status and verification](docs/playtests/PHASE15_COMPLETION_LEDGER.md)
- [Alpha walkthrough](docs/playtests/ALPHA_PLAYTEST.md)
- [Dev Hub](Power-Up-Tycoon-Dev-Hub.html)

## Local development

Install Roblox Studio and Rojo 7.7.1. Open this folder in VS Code. Run the commands below from the repository root, open the local place, and connect the Rojo Studio plugin to localhost on port 34872 when editing.

    rojo build default.project.json --output builds/Deadzone-Local.rbxl
    rojo serve default.project.json --port 34872

Rojo maps Luau source from src and editable Roblox model assets from art/roblox. Current release candidate files are in builds. The private persistence project is an isolated test target. The local shop only simulates Robux offers. Do not use a live production place or profile to test it.
