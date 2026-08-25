# Glint-Capture - Agent Instructions

Capture real Flutter UI into store-sized PNGs and `session.json`.

## Primary commands

- `glint init`
- `glint capture`

## Outputs

- PNG screenshots under device folders
- `session.json` at output root (used by Glint-Web import)

## Rules

1. Use real app widgets/screens only
2. Keep rules deterministic and CI-friendly
3. Soft launch: prefer **one device** so `session.json` maps cleanly onto Web frames
4. Preserve screen order within that device
