# Deadzone Dominion ad package

**Status** · Local, inactive drafts for owner review. Ads Manager campaign creation reached personal account setup, including timezone and advertising terms. Creative assets are 1920 × 1080 PNGs under 3 MB. The official 16:9 Home format is the target. Preview every actual placement in the dashboard. These are original illustrated concepts and use stylized models, effects and framing. [Ads Manager](https://create.roblox.com/docs/production/promotion/ads-manager) · [Home thumbnail guidance](https://create.roblox.com/docs/production/publishing/thumbnails)

- [Factory campaign](factory/CAMPAIGN.md) · Primary audience.
- [Zombie defense campaign](defense/CAMPAIGN.md) · Secondary, after a verified first-session encounter.
- [Pet campaign](pets/CAMPAIGN.md) · Secondary, after a verified first-session hatch route.
- [Small tile proof](small-tile-proof.png) · Six 160 × 90 previews.
- [Transparent compact mark](brand/deadzone-mark-transparent-512.png) · [Wordmark for dark backgrounds](brand/deadzone-wordmark-for-dark-background.png) · [Wordmark for light backgrounds](brand/deadzone-wordmark-for-light-background.png).
- [Editable rendering recipe](source/render-creatives.ps1) · The textless plates are in the same folder. Run [the delivery encoder](source/encode-delivery.py) with Python and Pillow after regenerating the banners to losslessly enforce the size target.

## Sample budgets for owner review

| Hypothetical total | Experiment | Interpretation |
| --- | --- | --- |
| USD 30 | Factory pair only, one audience and one game build. | Feasibility and reporting check if platform minimums allow. |
| USD 90 | Factory pair, same audience and game build. | Estimate acquisition ranges. A comparison needs the predeclared sample. |
| USD 180 | USD 90 factory, up to USD 45 per secondary concept in separate later flights, contingent on the primary test and verified payoff. | Separate audience tests. Compare within each matched pair rather than ranking cross-audience counts. |

These are illustrative ceilings, with no live billing configuration or platform rate quoted. If minimums or predicted delivery make the test infeasible, return it for review. No live bids, credits, schedules or start dates are specified.

## Setup and evaluation

1. Confirm the intended [public place](https://www.roblox.com/games/121220316198110), working client launch, eligible audience and present build. Confirm the appropriate first-session payoff in each campaign sheet.
2. Open Ads Manager and confirm the current campaign objective, placement and preview. Use the same audience, destination, device mix, objective, build and run window within a pair. Upload only the matching pair. Labels in the PNG are part of the creative. Keep all remaining campaign text identical where a field exists.
3. Capture the baseline conversion, target minimum detectable effect, desired sample, designated primary metric and downside guardrail before any activation. For CTR, the denominator is impressions. Where post-click plays are attributed to the same reporting scope, inspect plays per click alongside plays per impression. A creative with higher CTR and weaker conversion per click may produce fewer plays per impression.
4. Confirm available placement and targeting options. For a first-time acquisition read, use New Users reporting where available. New Players targeting may include players lapsed for 180 days or more. Paid plays, Home qPTR and first-session funnel completion are separate. Analyze first-sale and return signals at the cohort level unless attribution reaches a particular creative.
5. Preserve counts, dates, timezone, placement, build and attribution definitions. Allow up to 48 hours for Ads Manager reporting. Declare a winner only when the predefined sample and lift rule are met with acceptable downstream evidence. Low counts or ambiguous attribution mean inconclusive results.
6. Owner handles setup decisions that commit budget, billing, dates or activation. Keep a local record of the selected creative, approval and actual campaign settings when the campaign later runs.
