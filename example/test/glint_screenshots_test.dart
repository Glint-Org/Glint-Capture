import 'package:flutter/material.dart';
import 'package:glint_capture/glint_capture.dart';

import '../lib/main.dart' as app;

void main() {
  glintScreenshots(
    devices: [
      GLINTDevice.pixel9,
      GLINTDevice.ipadPro11,
    ],
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
      // Overlay UIs work too - compose dialog / sheet on top of a screen
      GLINTRule.screen(
        name: 'confirm_dialog',
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: [
            const app.HomeScreen(),
            ModalBarrier(color: Colors.black.withValues(alpha: 0.54), dismissible: false),
            Center(
              child: AlertDialog(
                title: const Text('Delete item?'),
                content: const Text('This cannot be undone.'),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Cancel')),
                  FilledButton(onPressed: () {}, child: const Text('Delete')),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
