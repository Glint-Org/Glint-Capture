# Glint-Capture — Agent Instructions

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
3. Preserve `session.json` order so Web exports in the same sequence
