---
name: glint-capture
description: Set up Glint Capture and produce real Flutter store screenshots (session.json).
---

# Glint Capture (agent)

## Install

```yaml
dev_dependencies:
  glint_capture:
    git:
      url: https://github.com/Glint-Org/Glint-Capture.git
      ref: v0.1.0
```

```bash
dart pub get
dart pub global activate --source git https://github.com/Glint-Org/Glint-Capture.git
glint init
```

## Capture

1. Edit generated test / rules — each screen must build **real** app widgets.
2. Soft launch: configure **pixel9** only.
3. Run `glint capture`.
4. Confirm `glint_screenshots/session.json` + PNGs.

## Do not

- Fabricate UI bitmaps
- Skip widget builders for “placeholder” marketing art
- Mix Play and App Store sizes in one Capture run without separate sessions

## Next

Import into Glint Web or call MCP `glint_export` / headless script. Docs: `Glint-Docs/guides/golden-path.md`.
