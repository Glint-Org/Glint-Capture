import 'package:flutter/material.dart';
import 'package:glint_capture/glint_capture.dart';

import '../lib/main.dart' as app;

void main() {
  glintScreenshots(
    appName: 'ExampleApp',
    tagline: 'Screenshot automation made easy',
    outputDir: 'build/glint_screenshots',
    devices: GLINTDevices.playStoreDefaults,
    rules: [
      GLINTRule.screen(
        name: 'home',
        builder: (context) => const MaterialApp(home: app.HomeScreen()),
      ),
      GLINTRule.screen(
        name: 'profile',
        builder: (context) => const MaterialApp(home: app.ProfileScreen()),
      ),
      GLINTRule.screen(
        name: 'settings',
        builder: (context) => const MaterialApp(home: app.SettingsScreen()),
      ),
    ],
  );
}
