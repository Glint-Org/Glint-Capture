import 'package:flutter/material.dart';
import 'package:glint_capture/glint_capture.dart';

import '../lib/main.dart' as app;

void main() {
  glintScreenshots(
    appName: 'ExampleApp',
    tagline: 'Screenshot automation made easy',
    devices: [GLINTDevice.pixel9],
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF5D06F))),
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
