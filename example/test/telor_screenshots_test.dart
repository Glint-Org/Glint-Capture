import 'package:flutter/material.dart';
import 'package:telor_capture/telor_capture.dart';

import '../lib/main.dart' as app;

void main() {
  telorScreenshots(
    appName: 'ExampleApp',
    tagline: 'Screenshot automation made easy',
    outputDir: 'build/telor_screenshots',
    devices: TelorDevices.playStoreDefaults,
    rules: [
      TelorRule.screen(
        name: 'home',
        builder: (context) => const MaterialApp(home: app.HomeScreen()),
      ),
      TelorRule.screen(
        name: 'profile',
        builder: (context) => const MaterialApp(home: app.ProfileScreen()),
      ),
      TelorRule.screen(
        name: 'settings',
        builder: (context) => const MaterialApp(home: app.SettingsScreen()),
      ),
    ],
  );
}
