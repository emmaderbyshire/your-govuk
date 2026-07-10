# Your GOV.UK

A prototype of a personalised UK Government & Parliament feed app: follow departments, your MP, consultations and your local area, and see what they do — live from official open APIs, with no scraping and no commentary.

**Try the demo: <https://emmaderbyshire.github.io/your-govuk/>**

Everything shown is fetched directly from the browser:

- **GOV.UK Search & Content APIs** — publications, news, consultations, organisations, verified social channels
- **UK Parliament Members & Commons Votes APIs** — MPs, peers, voting records, contributions (linked to Hansard)
- **postcodes.io** — postcode → constituency, council and ward
- **Environment Agency flood-monitoring API** — live flood alerts near you
- **PlanIt** — planning applications from council registers

Bills, Hansard and Committees APIs don't send CORS headers, so a full app would proxy those server-side; the prototype says so honestly instead of faking them.

## Files

| File | What it is |
| --- | --- |
| `govfeed-prototype.html` | The prototype. Starts with onboarding; everything rendered is live data or an honest empty state. |
| `demo.html` | The demo build. Pre-seeded persona (York postcode, four topics, three follows) plus a live "latest from what you follow" feed. On hosts that block external requests it falls back to clearly-labelled example content. Append `?offline` to preview that mode; the header cog resets the demo. |
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
