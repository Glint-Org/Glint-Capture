import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'devices.dart';
import 'pump.dart';
import 'rules.dart';
import 'screenshot.dart';

/// Configuration for a glint screenshot test suite.
class GLINTScreenshotConfig {
  const GLINTScreenshotConfig({
    required this.appName,
    this.tagline,
    this.outputDir = 'build/glint_screenshots',
    this.devices = GLINTDevices.playStoreDefaults,
    required this.rules,
    this.theme,
    this.store = 'play',
  });

  final String appName;
  final String? tagline;
  final String outputDir;
  final List<GLINTDevice> devices;
  final List<GLINTRule> rules;
  final ThemeData? theme;
  final String store;

  /// Build config from a glint.yaml file.
  factory GLINTScreenshotConfig.fromYaml(String path) {
    final yaml = GLINTConfig.load(path);
    return GLINTScreenshotConfig(
      appName: yaml.appName,
      tagline: yaml.tagline,
      outputDir: yaml.outputDir,
      devices: yaml.devices,
      rules: [],
      store: yaml.store,
    );
  }
}

/// Top-level entry point — registers screenshot capture tests.
void glintScreenshots({
  required String appName,
  String? tagline,
  String outputDir = 'build/glint_screenshots',
  List<GLINTDevice> devices = GLINTDevices.playStoreDefaults,
  required List<GLINTRule> rules,
  ThemeData? theme,
  String store = 'play',
}) {
  final config = GLINTScreenshotConfig(
    appName: appName,
    tagline: tagline,
    outputDir: outputDir,
    devices: devices,
    rules: rules,
    theme: theme,
    store: store,
  );

  GLINTRunner(config).registerTests();
}

/// Orchestrates screenshot capture test registration.
class GLINTRunner {
  GLINTRunner(this.config);

  final GLINTScreenshotConfig config;

  void registerTests() {
    final screenRules = expandRules(config.rules);
    if (screenRules.isEmpty) {
      throw StateError(
        'No screenshot rules defined. Add GLINTRule.screen() entries.',
      );
    }

    for (final rule in screenRules) {
      for (final device in config.devices) {
        testWidgets(
          '${rule.name} on ${device.name}',
          (tester) async {
            final bytes = await GLINTScreenshot.capture(
              tester: tester,
              widget: config.theme != null
                  ? MaterialApp(
                      theme: config.theme,
                      home: Builder(builder: rule.builder),
                    )
                  : Builder(builder: rule.builder),
              size: device.size,
              devicePixelRatio: device.devicePixelRatio,
            );

            final platformDir = switch (device.platform) {
              GLINTPlatform.android => 'android',
              GLINTPlatform.ios => 'ios',
            };
            final outputPath = p.join(
              config.outputDir,
              platformDir,
              device.name,
              '${rule.name}.png',
            );

            await tester.runAsync(
              () => GLINTScreenshot.save(bytes, outputPath),
            );
          },
        );
      }
    }
  }
}

/// Helper to pump a widget with custom timing before screenshot capture.
Future<void> glintPumpWidget(
  WidgetTester tester,
  Widget widget, {
  GLINTPumpFn? pump,
  GLINTDevice? device,
}) async {
  final effectivePump = pump ?? GLINTPump.settle;
  if (device != null) {
    await tester.binding.setSurfaceSize(device.size);
    tester.view.devicePixelRatio = device.devicePixelRatio;
  }
  await tester.pumpWidget(widget);
  await effectivePump(tester);
  if (device != null) {
    await tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}
