# Max Demand Calculator

Primary app location: `fresh_app/`

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

## Notes

- The web PDF includes a footer: "Powered by Seaspray Electrical".
- Load group C2:M has been removed (only available under C1:M).
- Once you're comfortable with the new app, consider removing legacy Flutter files at the repo root to reduce confusion.
