# Deadzone Dominion storefront audit

Observed November 15, 2026. Target place `121220316198110`, universe `10776986725`. Opened the signed-in public listing and the matching experience in Creator Dashboard. Workspace backup `art/rollback/growth-audit-start-20261115-164109`. Prior candidate SHA‑256 `5D2D023461980AA19413EDD1526F14A6CF5D305E0E983EB3744EB69ABCE5F5CC`. Prior saved Dev Hub v10 at `1175f03758e75aaf6e4990072971ff6b6b04a1dd`.

## Before captured during this audit

- Public title **Deadzone Dominion [Alpha Playtest]**. Experience Detail Page image order was **Alpha Powers → Five-Floor Factory**. The five-floor factory was visible in the lead art but competed with characters, weapon effects, and the title. A visual desktop capture was taken before edits. Baseline mobile crops were unavailable. The square icon used the existing illustrated branding.
- Public description and Social Links below. Creator Dashboard promotional text was empty.

> Build a five-floor Scrap factory, hatch power-themed pets, unlock weapons, and defend your tycoon from zombie outbreaks. Early alpha playtest. Progress and balance may change.
>
> Found a bug or have an idea? Open the Discord link under Social Links and post in #feedback.

- Public maturity was **Mild · Ages 16+**, repeated mild violence. Genre was **Party & Casual / Childhood Game** and Creator Dashboard showed a genre change restriction until December 3, 2026. Voice and camera were listed as supported. Server size was 50. Access, communication, localization, prices and the square icon were kept at the baseline. Native device and public Store availability need separate verification.
- The signed-in public snapshot showed one favorite, zero active users, and zero visits. These are point-in-time counters and do not establish an acquisition or retention baseline.

## Saved copy

Promotional text **Build a Scrap factory**. Creator Dashboard caps this field at 25 characters. Reopened and verified both saved fields and the public description. The public About page still includes the Discord feedback invitation and Social Links section.

Description:

> Claim your plot and turn moving Scrap into a five-floor factory. Build droppers, extend your conveyors, and collect Scrap to unlock the next floor.
>
> Hatch power-themed pets, unlock weapons at the Arsenal, and defend your factory from zombie outbreaks.
>
> Early alpha playtest. Progress and balance may change.
>
> Found a bug or have an idea? Open the Discord link under Social Links and post in #feedback.

## Change and verification ledger

| Surface | Result | Evidence and rollback |
| --- | --- | --- |
| Experience Details description and promo text | Description live, promo saved | Reopened Creator Dashboard and followed the signed-in public page after refresh. Restore the dated original copy above and clear the promo field to roll back. |
| Experience Detail Page carousel | Factory image moved into the first slot, Alpha Powers retained second | Reopened thumbnail manager, then refreshed the signed-in public desktop page and visually verified the new lead and new copy in the same capture. Reverse the order and save to roll back. |
| Home thumbnails | Two existing images were listed inactive in the Home manager | Adaptive thumbnail testing remains queued until traffic can support a useful result. |
| Public title and social link | Existing title and Deadzone Dominion Feedback continued to render | Description points to official Social Links and #feedback. Reworded copy leaves the public alpha caveat visible. |
| Narrow viewport | Updated copy and title were readable in the desktop browser accessibility view at 390 CSS pixels | Native mobile Roblox layout and device input remain pending. |
| Creator Analytics, Acquisition | Last 56 days showed no data for new users with plays, unique impressions by source and unique plays by source | Insufficient evidence to report conversion or retention baseline. |
| Public gameplay | Browser Play displayed the Roblox download prompt. A native Roblox Player session was unavailable | Current public first-session route and elapsed times are pending. Phase 15 Studio evidence applies only to the tested candidate. |
| Ads Manager | Campaign creation opened personal account setup covering timezone and advertising terms | Campaigns are local, editable, inactive and priced only as sample scenarios. |
| Workspace | Gameplay and map stayed out of this storefront pass | Candidate preserved in the dated backup. Prior verified sync is recorded in the Phase 15 ledger. No fresh Rojo live sync claim for this pass. |

## Review

- The independent first review scored research **7/10**. Added dated competitor artwork observations, provenance and limits. Corrected campaign wording about the fixed game build and clarified illustrated features.
- Independent recheck **8/10 each** for research quality, click appeal, creative clarity, accuracy to the game and testability. Public gameplay, native mobile previews and analytics remain campaign gates. Gameplay improvements are tracked by ID in [the growth backlog](../roadmap/growth-backlog.json).
- Dev Hub version **11** was saved and verified unpublished at source `e3d83d67b03573b808cb81460b1813a5bebfab6d`. Its roadmap and question exports include the campaign decisions and seven findings. The designated approved-feedback folders contained no new issue records at review.
