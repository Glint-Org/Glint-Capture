import 'package:flutter/material.dart';
import 'package:glint_capture/glint_capture.dart';

import '../lib/main.dart' as app;

void main() {
  glintScreenshots(
    appName: 'ExampleApp',
    tagline: 'Screenshot automation made easy',
    outputDir: 'build/glint_screenshots',
    devices: GLINTDevices.playStoreDefaults,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    rules: [
      GLINTRule.screen(
        name: 'home',
        builder: (context) => const app.HomeScreen(),
      ),
      GLINTRule.screen(
        name: 'profile',
        builder: (context) => const app.ProfileScreen(),
      ),
      GLINTRule.screen(
        name: 'settings',
        builder: (context) => const app.SettingsScreen(),
      ),
    ],
  );
}
