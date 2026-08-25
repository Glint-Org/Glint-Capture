# Glint Capture Example

Minimal Flutter app that uses Glint Capture as a path dependency.

```bash
cd example
flutter pub get
flutter test test/glint_screenshots_test.dart
```

Or from the package root after `glint init` in a host app:

```bash
glint capture
```

Output: PNGs + `session.json` → import into Glint Web.
