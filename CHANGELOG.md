# Changelog

## Unreleased

- CLI: `glint discover [--write]` and `glint capture --auto`
- Scans `lib/` for `*Screen` / `*Page` widgets and generates real `GLINTRule` builders
- Agentic IDE workflow (Cursor / Copilot) — no developer API keys for Capture

## 0.1.0

- Initial soft-launch release
- `glintScreenshots` / `GLINTRule` capture API
- Device presets for Play Store and App Store
- CLI: `glint init`, `glint capture`
- `session.json` schema v1 for Glint Web
- Font loading for golden-quality captures (Roboto; MaterialIcons via host FontManifest when present)
- Curated device presets only: Pixel 9, Galaxy S24, iPhone 16 Pro / Pro Max, iPad Pro 11"/13"
- Full-resolution capture (physicalSize × DPR), wired pump/wrapper, no DEBUG banner
- Font loader: all Roboto weights + MaterialIcons; docs for dialogs/sheets
- Soft-launch install: git `ref: v0.1.0` (pub.dev publish when org is ready)
