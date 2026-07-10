# Your GOV.UK — design rationale

The 2026-07 redesign rethinks the app as **the personalised public square for UK government activity**: GOV.UK's design system carrying social-feed interaction patterns from Bluesky, X and Apple News. This document is the information architecture and the reasoning behind every major decision.

## The one-line thesis

> Instead of citizens navigating government, government activity comes to the citizen — in one live, followable, content-first feed.

## Information architecture

```
Your GOV.UK
├── Feed (home) ─── filter chips: All · Your area · Parliament · Departments · Consultations · Petitions
│     └── feed items → entity detail (publication, MP, petition, place)
├── Explore
│     ├── universal live search (GOV.UK + Parliament + postcodes)
│     ├── interests (topic chips — follow/unfollow, feed updates instantly)
│     ├── trending petitions (live, by signature count)
│     ├── open consultations (live, newest first)
│     ├── departments & bodies (live directory)
│     └── Bills & committees (honest slot: API needs a backend; links out)
├── Following ─── topics + people/places + organisations, unfollow anywhere
├── Notifications ─── assembled live per visit from follows + area
├── You ─── your area (MP, council, ward) · saved items · settings · privacy note
└── Entity profiles (reached from anywhere)
      ├── MP: photo, party, constituency, synopsis, votes with tallies, Hansard contributions
      ├── Department: colour band, ministers, verified channels, latest publications
      ├── Petition: signatures, state, thresholds explained
      └── Publication/place: summary, notify rules, official source
```

## Why it looks the way it does

**Content-first, not navigation-first.** The old home screen was cards about the app; the new home screen is the feed itself, and it is never empty — before a user follows anything it shows the newest publications across all of government. The first thing anyone sees is what government did in the last hour.

**Feed anatomy borrows from social, spends GOV.UK's trust.** Each item: source avatar in the department's official identity colour, source name, content type + relative timestamp ("32m ago"), bold headline, one-line summary, then a quiet action row — Follow, Save, Share, Source. The GOV.UK design system supplies every token: the fallback type stack (GDS Transport is licence-restricted), the palette, focus states, tag components. Departmental identity colours appear only on avatars and profile bands, never as decoration — consistent with GOV.UK brand rules.

**Boxes out, hairlines in.** The old design wrapped everything in bordered cards. The redesign uses a single centred column (max 600px, the proportion of every major feed app) with 1px hairline dividers, larger headline type (17.5px items, 26px screen titles), and whitespace doing the separation. It reads as a stream, not a dashboard.

**Local is a first-class feed source, not a page.** The entered postcode drives: the constituency + real MP (followed automatically), planning applications within 1.5km (council registers via PlanIt), Environment Agency flood alerts within 15km, all appearing inline in the feed with an "Affects your area"-style context tag and under the "Your area" filter chip.

**Parliament is people, not PDFs.** The MP appears in the feed as a person — real portrait (Parliament's official member photography), "Spoke in Parliament · 2d ago", deep link to the exact Hansard debate. Their profile shows voting records as visual aye/no tallies and recent contributions, all live and shown without commentary.

**Notifications answer "what happened to the things I follow".** Assembled live on every visit: newest publication per followed department, "your MP spoke", a real flood check (including the reassuring "No flood alerts near you right now"), planning activity counts. Every one explains *why* it's there ("because you follow…"), which is the trust contract of a personalised service.

## Honesty constraints (non-negotiable)

- **Nothing fictional is presented as real.** Where a host blocks external requests, fallback content is tagged **Example** and says so in the source line. The fallback never invents an MP, a place, or a signature count.
- **No fake engagement.** There are no follower counts, like counts or comments anywhere — we don't have that data, so it doesn't appear. Petition signature counts are shown because they are real and live.
- **Blocked APIs are named, not faked.** Parliament's Bills, Hansard-text and Committees APIs don't send CORS headers, so a browser-only prototype cannot call them. The Explore screen says exactly that and links to bills.parliament.uk. The full app's backend would proxy them — that's the plan, stated in the product.
- **Comments are omitted deliberately.** A government service hosting anonymous comments is a moderation and trust minefield; verified official channels (pulled live from each organisation's GOV.UK page) fill the "conversation" slot instead.

## Live data sources

| Source | Used for | Browser-callable |
| --- | --- | --- |
| GOV.UK Search API | feed, consultations, departments directory, search | Yes |
| GOV.UK Content API | ministers, verified social channels | Yes |
| Parliament Members API | MPs, portraits, synopsis, contributions | Yes |
| Commons Votes API | voting records | Yes |
| petition.parliament.uk | trending petitions, signature counts | Yes |
| postcodes.io | postcode → constituency, council, ward, coordinates | Yes |
| EA flood-monitoring | flood alerts near the user | Yes |
| PlanIt | planning applications near the user | Yes (can hang — 8s timeout) |
| Bills / Hansard / Committees APIs | Bill tracker, debate text | **No — needs backend proxy** |

## Accessibility

WCAG-AA-minded throughout: GOV.UK yellow focus ring on every interactive element, 44px minimum touch targets on feed actions, `aria-pressed` on all toggles, `aria-current` on navigation, `role="status"` on toasts, `prefers-reduced-motion` kills the skeleton shimmer, and both light and dark themes are designed (not inverted) with the token system — dark mode uses true-black page ground with a lifted surface, matching how the feed apps it borrows from handle OLED screens.

## Engineering shape

Single self-contained HTML file, no framework, no build step. Every network call goes through one `fetchJson` with an `?offline` test switch; slow open APIs are wrapped in an 8-second timeout so one hanging source can never blank a screen; renders are guarded by sequence counters so overlapping refreshes can't double-append. All personal state (interests, postcode, follows, saved items, notification choices) lives in `localStorage` on the user's device and nowhere else.
