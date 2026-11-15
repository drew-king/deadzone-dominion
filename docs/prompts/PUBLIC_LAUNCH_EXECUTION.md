Execute the public launch of **Deadzone Dominion: Powers Tycoon**, including the existing thumbnails, a permanent Supporter donation pass, and a Discord feedback workflow that turns approved suggestions into roadmap entries. Work in verifiable milestones. Keep progress reports brief. Stop on an unresolved release blocker or an action the owner must complete.

## 1. Identify the build and clear the public-release gates

- Read the master design, Phase 15 ledger and execution prompt, alpha walkthrough, and private GitHub repository. Download the latest saved Dev Hub roadmap and questions, compare them with owner amendments, and record the exact source revision. Repeat this before future phases.
- The verified private alpha is Roblox place `121220316198110`, universe `10776986725`. Use that as the intended release target unless the owner directs a different experience. Verify the IDs in Studio and Creator Dashboard before writing. Preserve the other Roblox experiences and the private test environment.
- Preserve the existing local and published versions. Verify the exact candidate file and SHA-256, the Git revision, and Rojo add-and-remove sync on a disposable local copy. Build and reopen a release candidate before touching public visibility.
- Run a private Roblox client test from fresh join through claim, first sale, weapon equip, pet hatch, and rejoin. Run two-client ownership and payout isolation, tested-device UI checks, and profile failure and reconnect checks. Replay the affected progression, siege, and cargo paths. Verify that any launch copy describes features present in the build. Use the Phase 15 ledger to track unverified pet and weapon animation upgrades.
- Verify current Roblox publishing eligibility, audience requirements, and content maturity settings using Creator Dashboard and official documentation. Ask the owner to complete required identity, age, account, or content declarations where their action is necessary. Record the tested build, rollback version, and unresolved findings. Change the intended experience to **Public** only after release-blocking checks pass. Independently verify the visibility and test a join from an eligible account without collaborator access. [Roblox publishing documentation](https://create.roblox.com/docs/production/publishing)

## 2. Add and verify the experience thumbnails

Use the existing PNGs in `art/alpha-media/`.

- Lead with `thumbnail-five-floor-factory.png`. It explains building, factory progression, pets, weapons, and survival at a glance.
- Use `thumbnail-alpha-powers.png` as the second image if the public listing still describes the game as a public alpha. If the owner wants a general-release label, get the matching title lockup before using that image.
- Check the aspect ratio, crop, desktop and mobile title legibility, and whether the illustrated power effects could mislead players about specific abilities. Add descriptive alt text and confirm each image’s moderation and placement status in Creator Dashboard.
- Keep `ad-hatch-build-defend.png` and `ad-defend-your-factory.png` with the optional marketing assets for later. Leave ad campaigns and spending for a separate owner decision. [Roblox thumbnail guidance](https://create.roblox.com/docs/production/publishing/thumbnails)

## 3. Add a donation game pass

- Create a one-time **Supporter** game pass in the verified release universe. Ask the owner for a Robux price and approval of the pass name and description before enabling sales. Describe it as voluntary support for development.
- List the same pass on the Roblox experience Store page and in the in-game shop. Use a compact card with an original icon, current Marketplace price, and clear Buy, Owned, and Unavailable states. Use the actual pass ID. Keep Auto-Collect clearly featured as the main gameplay pass.
- Use Roblox’s official purchase prompt and verify ownership on the server before granting any supporter recognition. Keep recognition cosmetic, such as a small badge or title, and make its behavior explicit. Test cancellation, duplicate clicks, owned state after rejoin, and store-page listing. A real Robux test purchase requires the owner’s explicit approval. Label any untested purchase step. [Roblox passes](https://create.roblox.com/docs/production/monetization/passes)

## 4. Create and link a simple Discord server

- Create **Deadzone Dominion** under the owner’s Discord account or work in a server they designate. Keep it small. Use `#start-here` for rules and verification, `#announcements` for release notes, a `#feedback` forum for bug reports and suggestions, and a private `#staff-review` channel.
- Use `Verified Player` and `Moderator` roles. Give the bot only the permissions it needs in the relevant channels. Keep account ownership with the owner.
- Use a vetted Roblox verification integration or build a minimal official Roblox sign-in flow with OAuth/OIDC. Match accounts by immutable Roblox user ID. Bind the callback to the initiating Discord member, expire verification sessions, and store only the account mapping and verification status required for role management. Provide an unlink route. Keep Roblox and Discord secrets out of the repository and logs. [Roblox OAuth/OIDC](https://create.roblox.com/docs/cloud/auth/oauth2-overview)
- Link Discord through Roblox’s supported **experience Social Links** feature only where Roblox permits it and applies its audience restrictions. Keep essential gameplay instructions and a feedback option available to people who cannot use Discord. Ask the owner to handle unavoidable sign-in, OAuth consent, or ownership steps. Test the invite and verification with an eligible non-staff account. [Roblox Social Links](https://create.roblox.com/docs/production/publishing/social-links)

## 5. Turn approved Discord suggestions into roadmap entries

- Use one canonical roadmap JSON file in the private game repository. Preserve the existing Dev Hub layout and roadmap history, and have the Hub consume or export the same tracked entries. Save a verified latest revision so future development agents can retrieve it.
- Let verified members submit a title, category, short description, reproduction steps for bugs, and expected behavior. Use tags such as `Bug`, `Balance`, `Accessibility`, `Art`, and `Feature`. Keep unapproved submissions inside Discord.
- Provide restricted slash commands for moderator approval, rejection, and status updates. Approval must capture the Discord thread ID, approver, priority, player impact, acceptance criteria, and a proposed release or `Unscheduled`. Only the approval event can create a roadmap entry. Treat submitted text as data, validate the schema, and avoid copying personal information or private conversation into the roadmap. [Discord application commands](https://discord.com/developers/docs/interactions/application-commands)
- Use a narrowly scoped GitHub integration to open or update a pull request for the roadmap change. Deduplicate by Discord thread ID, make retries idempotent, and record the bot’s action. Allow statuses such as `Approved`, `Planned`, `In Progress`, and `Released`. Only mark an item `Released` after a verified release references it. Send the roadmap ID and current status back to the Discord thread.
- Test moderator approval, regular-member denial, repeated approval, a reopened item, simultaneous approvals, a GitHub outage and retry, and an approved item flowing into the Dev Hub and the next phase prompt. If secure hosting or credentials are missing, deliver the runnable bot, setup and recovery instructions, and the exact owner action required to go live.

## 6. Independent acceptance and final handoff

Use the existing independent reviewer protocol. Score engagement, retention potential, cleanliness, build quality, and test evidence from 1–10. Address scores of 7 or below and rerun affected checks. If a score remains below 7, redesign the affected work. Use a second reviewer when evidence is missing or disputed.

Hand off the verified Roblox URL and place ID, published version and rollback target, thumbnail moderation status, donation pass ID and price, Discord invite and verification results, bot deployment status, and the roadmap revision. State which checks actually ran and which still require owner action. Leave production data, advertising spend, and unrelated Roblox experiences outside the launch scope.

## Owner amendment

Use a repeatable 99 Robux developer product. The first successful purchase unlocks a permanent blue Supporter nametag. Create a new Discord server under the owner’s account.
