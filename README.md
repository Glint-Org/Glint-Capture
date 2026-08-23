# Glint Capture

Device-free Flutter screenshot capture for Play Store and App Store assets.

Part of the [Glint](https://github.com/darkmintis/Glint-Org) ecosystem.

## Features

- Capture screenshots from code — no emulator or physical device
- Declarative rules API with custom and template-based flows
- Multi-device presets (Pixel 7, Galaxy S23, Samsung M12, iPhone 14 Pro, iPad)
- Outputs PNGs + `session.json` for Glint-Web import
- Real font rendering (Roboto + MaterialIcons) — no Ahem blocks
- Global CLI: `glint init` → `glint capture`

## Quick Start

```yaml
# pubspec.yaml
dev_dependencies:
  glint_capture:
    path: ../Glint-Capture  # or from pub.dev when published
```

```dart
// test/glint_screenshots_test.dart
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
      GLINTRule.screen(
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
dart run glint_capture --app MyApp --output build/glint_screenshots
```

Import `build/glint_screenshots/` into Glint-Web to apply viral templates and export store-ready assets.

## CLI

```
dart run glint_capture [options]

  --test <path>       Test file (default: test/glint_screenshots_test.dart)
  -o, --output <dir>  Output directory (default: build/glint_screenshots)
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
GLINTRule.template(
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
- run: dart run glint_capture --app ${{ env.APP_NAME }}
- uses: actions/upload-artifact@v4
  with:
    name: glint-screenshots
    path: build/glint_screenshots/
```

## License

MIT
