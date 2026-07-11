# Bug report: Hansard links truncated to the debate UUID (2026-07-12)

Fix the Hansard URL handling bug in the app.

The app is currently truncating Hansard links by removing the final debate-title
slug from the URL. This causes links to open an incomplete or non-working page.

Example:

Incorrect URL currently produced by the app:

    https://hansard.parliament.uk/Commons/2026-07-09/debates/723FCBB0-C8A3-4D4F-84E0-733A51F1222A/

Correct source URL:

    https://hansard.parliament.uk/commons/2026-07-09/debates/723FCBB0-C8A3-4D4F-84E0-733A51F1222A/IsraeliSettlementsTradeBan

Please:

1. Find where Hansard URLs are parsed, normalised, shortened, reconstructed, or stored.
2. Preserve the complete original Hansard URL, including everything after the debate UUID.
3. Do not assume the UUID is the final path segment.
4. Preserve the debate-title slug exactly as supplied by the source.
5. Avoid changing the URL path casing unless Hansard explicitly redirects safely.
6. Ensure trailing-slash cleanup does not remove a legitimate final path segment.
7. Use the canonical source URL directly wherever possible instead of rebuilding it
   from individual fields.
8. Check feed cards, Hansard quote links, detail pages, saved items, sharing links,
   and any API transformation layer for the same issue.

Add regression tests covering:

- Hansard URLs with a debate-title slug
- URLs with and without a trailing slash
- Commons and Lords URLs
- Mixed-case input paths
- URLs containing query strings or fragments
- Existing saved records containing truncated URLs

Expected behaviour:

Clicking a Hansard item should open the exact debate or section represented by the
original source URL, rather than the debate UUID's parent page.

After making the fix, search the codebase for any other logic that splits a Hansard
URL at the UUID or assumes a fixed number of path segments, and correct those cases
too.

---

## Resolution notes (2026-07-12)

Verified against the live Hansard site before fixing:

- `…/debates/<UUID>/` and `…/debates/<UUID>` (no slash) both return **404** —
  the truncated links the app produced were genuinely broken, not just untidy.
- `…/debates/<UUID>/<AnySlug>` serves the debate: Hansard resolves by UUID and
  requires a non-empty final path segment; it does not redirect to a canonical slug.
- The Members API `ContributionSummary` endpoint (the app's only Hansard data
  source) supplies **no URL field** — only `house`, `sittingDate`,
  `debateWebsiteId` and `debateTitle` (sometimes with leading whitespace) — so the
  URL must be constructed; the slug is derived from `debateTitle` using Hansard's
  own convention (word-initial capitals, characters outside `A-Za-z0-9()-` dropped).

Fix: shared `hansardSlug` / `hansardDebateUrl` / `repairHansardUrl` helpers in
`demo.html` (and the generated `index.html`) and `govfeed-prototype.html`; all
Hansard link sites (feed cards, entity detail pages, alerts — save/share reuse the
feed item URL) now include the slug, and saved records containing truncated URLs
are repaired at boot. Regression tests: `tests/hansard-url.test.html`.
