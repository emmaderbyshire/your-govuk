# Your GOV.UK

The personalised public square for UK government activity: one live feed of what departments, Parliament, petitions and your local area are doing — GOV.UK's design system carrying social-feed interaction patterns. Live from official open APIs, with no scraping, no commentary and no fake engagement.

**Try the demo: <https://emmaderbyshire.github.io/your-govuk/>**

See [DESIGN.md](DESIGN.md) for the information architecture and full design rationale.

Everything shown is fetched directly from the browser:

- **GOV.UK Search & Content APIs** — publications, news, consultations, organisations, ministers, verified social channels
- **UK Parliament Members & Commons Votes APIs** — MPs, portraits, voting records, contributions (linked to Hansard)
- **petition.parliament.uk** — trending petitions with live signature counts
- **postcodes.io** — postcode → constituency, council and ward
- **Environment Agency flood-monitoring API** — live flood alerts near you
- **PlanIt** — planning applications from council registers

Bills, Hansard and Committees APIs don't send CORS headers, so a full app would proxy those server-side; the prototype says so honestly instead of faking them.

## Files

| File | What it is |
| --- | --- |
| `govfeed-prototype.html` | The prototype. Starts with onboarding; everything rendered is live data or an honest empty state. |
| `demo.html` | The app. Onboarding asks your interests and postcode, then builds a live feed (departments, your MP, petitions, planning, flood alerts) with follow/save/share actions, Explore, Following, Notifications and You screens. On hosts that block external requests it falls back to clearly-labelled example content. Append `?offline` to preview that mode. |
| `index.html` | The GitHub Pages build of the demo — `demo.html` wrapped in a full HTML document. Regenerate it after editing `demo.html`. |
| `.claude/serve.ps1` | Zero-dependency local server (PowerShell `HttpListener`, port 4173). `/demo` serves the demo, any other path serves the prototype. |

## Run it locally

No Node or Python needed — just PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/serve.ps1
```

Then open <http://localhost:4173/> (prototype) or <http://localhost:4173/demo> (demo).

## Design notes

- Strict [GOV.UK Design System](https://design-system.service.gov.uk/) palette and type scale. GDS Transport is licence-restricted, so the documented fallback stack (`"Helvetica Neue", Helvetica, Arial`) is used deliberately.
- Official departmental identity colours appear only as source badges and card top-borders, never as decoration.
- Light and dark themes; visible focus states; `prefers-reduced-motion` respected.
- State (follows, notify rules, area) lives in `localStorage` — nothing leaves the device.
- Party affiliation is shown factually from Parliament data, without commentary. Nothing fictional is presented as real: demo fallback content is tagged "Example".
