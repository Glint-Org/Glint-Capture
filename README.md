# Glint Capture

Device-free Flutter screenshot capture for Play Store and App Store assets.

Part of the [Glint](https://github.com/Glint-Org) ecosystem. Soft-launch path: **Capture → Web → View**.

## Install

**Preferred (path / git until pub.dev):**

```yaml
dev_dependencies:
  glint_capture:
    path: ../Glint-Capture
```

Or:

```yaml
dev_dependencies:
  glint_capture:
    git:
      url: https://github.com/Glint-Org/Glint-Capture.git
```

Then activate the CLI from this package:

```bash
dart pub global activate --source path .
# or: dart pub global activate --source git https://github.com/Glint-Org/Glint-Capture.git
```

```bash
glint init
glint capture
```

## Features

- Screenshots from Flutter widget tests - no emulator required
- Declarative `GLINTRule` API + template flows
- Device presets for Play and App Store
- PNGs + `session.json` (schema v1) for Glint Web
- Real fonts (Roboto + MaterialIcons) via `flutter_test_config.dart`

## Quick example

```dart
import 'package:flutter/material.dart';
import 'package:glint_capture/glint_capture.dart';

void main() {
  glintScreenshots(
    appName: 'MyApp',
    tagline: 'Edit photos like a pro',
    devices: GLINTDevices.playStoreDefaults,
    rules: [
      GLINTRule.screen(
        name: 'home',
        builder: (context) => const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
    ],
  );
}
```

```bash
glint init && glint capture
# or: flutter test test/glint_screenshots_test.dart
```

Import the output folder into **Glint Web** → Templates → Export → Copy for Glint View.

**Tip:** Soft launch with **one device** (e.g. `pixel9`) so `session.json` maps cleanly onto Web frames. Multi-device captures still write all PNGs; session lists the primary device only.

## Device presets

Six curated devices only:

| Preset | Logical size | DPR | Store |
|--------|--------------|-----|-------|
| `pixel9` | 412×915 | 2.625 | Play (default) |
| `galaxy_s24` | 360×780 | 3.0 | Play |
| `iphone16_pro_max` | 430×932 | 3.0 | App Store 6.7" |
| `iphone16_pro` | 393×852 | 3.0 | App Store |
| `ipad_pro_129` | 1024×1366 | 2.0 | App Store tablet |
| `ipad_pro_11` | 834×1194 | 2.0 | App Store tablet |

Lists: `GLINTDevices.premium` (= all), `.playStoreDefaults`, `.appStoreDefaults`. Soft launch: one device (`pixel9`).

## CI

```yaml
- run: dart run glint_capture capture
- uses: actions/upload-artifact@v4
  with:
    name: glint-screenshots
    path: glint_screenshots/
```

## License

MIT
