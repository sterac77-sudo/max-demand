# Max Demand Calculator

Primary app location: `fresh_app/`

Live site: https://sterac77-sudo.github.io/max-demand/

This repository contains a clean Flutter app under `fresh_app/` that is the primary project moving forward. Older files at the repository root are retained temporarily for reference.

## Run locally

From a terminal in VS Code or PowerShell on Windows:

```powershell
cd C:\Users\steve\OneDrive\max_demand_calculator\fresh_app
flutter run -d chrome   # or: flutter run -d windows
```

List available devices:

```powershell
flutter devices
```

Run tests:

```powershell
cd C:\Users\steve\OneDrive\max_demand_calculator\fresh_app
flutter test
```

## Web deployment (GitHub Pages)

GitHub Actions builds the web app from `fresh_app/` and deploys to GitHub Pages on pushes to `main`. The workflow is in `.github/workflows/deploy-pages.yml` and publishes `fresh_app/build/web`.

## SEO & Sitemaps

- **Sitemap location**: `fresh_app/web/sitemap.xml` (and alternate `sitemap-20251024.xml`)
- **robots.txt**: Lists both sitemap URLs; deployed to the web root
- **Google Search Console**:
  - Submit sitemaps in the URL-prefix property: `https://sterac77-sudo.github.io/max-demand/` (with trailing slash)
  - Use **URL Inspection** → "Test Live URL" → "Request Indexing" for key pages
  - The old Google sitemap ping endpoint is deprecated (returns 404); rely on normal crawling and lastmod timestamps
- **Metadata**: Canonical, og:url, and description tags are in `fresh_app/web/index.html`

## Notes

- The web PDF includes a footer: "Powered by Seaspray Electrical".
- Load group C2:M has been removed (only available under C1:M).
- Once you're comfortable with the new app, consider removing legacy Flutter files at the repo root to reduce confusion.

## Optional analytics (web)

Basic, privacy-friendly web analytics can be enabled without code changes:

- Plausible: open `fresh_app/web/index.html`, find the commented snippet
	`plausible.io/js/script.js`, set `data-domain` to your Pages domain (e.g., `sterac77-sudo.github.io`), and uncomment it.
- The app will automatically send a custom event `export_pdf` when users export.
- If you prefer Firebase Analytics or Umami, we can wire those later.
