# Telor Capture

Device-free Flutter screenshot capture for Play Store and App Store assets.

Part of the [Telor](https://github.com/darkmintis/Telor-Org) ecosystem.

## Features

- Capture screenshots from code — no emulator or physical device
- Declarative rules API with custom and template-based flows
- Multi-device presets (Pixel 7, Galaxy S23, iPhone 15, iPad Pro)
- Outputs PNGs + `session.json` for Telor-Web import
- Built on [alchemist](https://pub.dev/packages/alchemist) golden testing

## Quick Start

```yaml
# pubspec.yaml
dev_dependencies:
  telor_capture:
    path: ../Telor-Capture  # or from pub.dev when published
```

```dart
// test/telor_screenshots_test.dart
import 'package:flutter/material.dart';
import 'package:telor_capture/telor_capture.dart';

void main() {
  telorScreenshots(
    appName: 'MyApp',
    tagline: 'Edit photos like a pro',
    devices: TelorDevices.playStoreDefaults,
    rules: [
      TelorRule.screen(
        name: 'home',
        builder: (context) => const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
      TelorRule.screen(
        name: 'profile',
        builder: (context) => const Scaffold(
          body: Center(child: Text('Profile Screen')),
        ),
      ),
    ],
  );
}
```

```bash
dart run telor_capture --app MyApp --output build/telor_screenshots
```

Import `build/telor_screenshots/` into Telor-Web to apply viral templates and export store-ready assets.

## CLI

```
dart run telor_capture [options]

  --test <path>       Test file (default: test/telor_screenshots_test.dart)
  -o, --output <dir>  Output directory (default: build/telor_screenshots)
  -a, --app <name>    App name for session.json
  -t, --tagline       Marketing tagline
  --store play|ios    Store target
```

## Device Presets

| Preset | Size | DPR | Target |
|--------|------|-----|--------|
| `pixel7` | 412×915 | 2.625 | Play Store |
| `galaxyS23` | 360×780 | 3.0 | Play Store |
| `iphone15` | 393×852 | 3.0 | App Store |
| `ipadPro11` | 834×1194 | 2.0 | App Store |

## Template Rules

```dart
TelorRule.template(
  name: 'onboarding_flow',
  screens: ['welcome', 'features', 'signup'],
  builders: {
    'welcome': (context) => WelcomeScreen(),
    'features': (context) => FeaturesScreen(),
    'signup': (context) => SignupScreen(),
  },
),
```

Built-in templates: `onboarding_flow`, `feature_highlights`, `settings_profile`.

## CI

```yaml
# .github/workflows/screenshots.yml
- run: dart run telor_capture --app ${{ env.APP_NAME }}
- uses: actions/upload-artifact@v4
  with:
    name: telor-screenshots
    path: build/telor_screenshots/
```

## License

MIT
