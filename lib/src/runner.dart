import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'devices.dart';
import 'pump.dart';
import 'rules.dart';
import 'screenshot.dart';
import 'session.dart';

/// Configuration for a glint screenshot test suite.
class GLINTScreenshotConfig {
  const GLINTScreenshotConfig({
    this.outputDir = 'glint_screenshots',
    this.devices = GLINTDevices.playStoreDefaults,
    required this.rules,
    this.theme,
    this.store = 'play',
  });

  final String outputDir;
  final List<GLINTDevice> devices;
  final List<GLINTRule> rules;
  final ThemeData? theme;
  final String store;

  /// Build config from a glint.yaml file.
  factory GLINTScreenshotConfig.fromYaml(String path) {
    final yaml = GLINTConfig.load(path);
    return GLINTScreenshotConfig(
      outputDir: yaml.outputDir,
      devices: yaml.devices,
      rules: [],
      store: yaml.store,
    );
  }
}

/// Top-level entry point - registers screenshot capture tests.
void glintScreenshots({
  String outputDir = 'glint_screenshots',
  List<GLINTDevice> devices = GLINTDevices.playStoreDefaults,
  required List<GLINTRule> rules,
  ThemeData? theme,
  String store = 'play',
}) {
  final config = GLINTScreenshotConfig(
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
            Widget content = Builder(builder: rule.builder);
            if (rule.wrapper != null) {
              content = rule.wrapper!(content);
            }

            final bytes = await GLINTScreenshot.capture(
              tester: tester,
              widget: content,
              size: device.size,
              devicePixelRatio: device.devicePixelRatio,
              textScale: device.textScale,
              theme: config.theme,
              pump: rule.pump,
              device: device,
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

    // Emit session.json for Glint-Web / Glint-View after all captures.
    tearDownAll(() async {
      try {
        final session = GLINTSession.fromDirectory(
          outputDir: config.outputDir,
          store: config.store,
        );
        await session.write(config.outputDir);
      } catch (_) {
        // Directory may be empty if every capture failed.
      }
    });
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
    tester.view.physicalSize = Size(
      device.size.width * device.devicePixelRatio,
      device.size.height * device.devicePixelRatio,
    );
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
