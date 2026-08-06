import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'devices.dart';
import 'pump.dart';
import 'rules.dart';

/// Configuration for a telor screenshot test suite.
class TelorScreenshotConfig {
  const TelorScreenshotConfig({
    required this.appName,
    this.tagline,
    this.outputDir = 'build/telor_screenshots',
    this.devices = TelorDevices.playStoreDefaults,
    required this.rules,
    this.theme,
    this.store = 'play',
  });

  final String appName;
  final String? tagline;
  final String outputDir;
  final List<TelorDevice> devices;
  final List<TelorRule> rules;
  final ThemeData? theme;
  final String store;
}

/// Registers golden screenshot tests for each rule × device combination.
///
/// Run with: `flutter test test/telor_screenshots_test.dart --update-goldens`
void telorScreenshots({
  required String appName,
  String? tagline,
  String outputDir = 'build/telor_screenshots',
  List<TelorDevice> devices = TelorDevices.playStoreDefaults,
  required List<TelorRule> rules,
  ThemeData? theme,
  String store = 'play',
}) {
  final config = TelorScreenshotConfig(
    appName: appName,
    tagline: tagline,
    outputDir: outputDir,
    devices: devices,
    rules: rules,
    theme: theme,
    store: store,
  );

  TelorRunner(config).registerTests();
}

/// Orchestrates alchemist golden test registration and post-processing.
class TelorRunner {
  TelorRunner(this.config);

  final TelorScreenshotConfig config;

  void registerTests() {
    final screenRules = expandRules(config.rules);
    if (screenRules.isEmpty) {
      throw StateError('No screenshot rules defined. Add TelorRule.screen() entries.');
    }

    AlchemistConfig.runWithConfig(
      config: AlchemistConfig(
        theme: config.theme ?? ThemeData.light(useMaterial3: true),
        platformGoldensConfig: const PlatformGoldensConfig(
          enabled: true,
        ),
        ciGoldensConfig: const CiGoldensConfig(
          enabled: true,
        ),
      ),
      run: () {
        for (final rule in screenRules) {
          for (final device in config.devices) {
            final fileName = '${rule.name}_${device.name}';
            goldenTest(
              '${rule.name} on ${device.name}',
              fileName: fileName,
              constraints: BoxConstraints(
                maxWidth: device.size.width,
                maxHeight: device.size.height,
              ),
              builder: () => GoldenTestGroup(
                scenarioConstraints: BoxConstraints(
                  maxWidth: device.size.width,
                  maxHeight: device.size.height,
                ),
                children: [
                  GoldenTestScenario(
                    name: device.name,
                    constraints: BoxConstraints(
                      maxWidth: device.size.width,
                      maxHeight: device.size.height,
                    ),
                    child: SizedBox(
                      width: device.size.width,
                      height: device.size.height,
                      child: MediaQuery(
                        data: MediaQueryData(
                          size: device.size,
                          devicePixelRatio: device.devicePixelRatio,
                          textScaler: TextScaler.linear(device.textScale),
                          platformBrightness: Brightness.light,
                        ),
                        child: Builder(builder: rule.builder),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}

/// Helper to pump a widget with custom timing before golden capture.
Future<void> telorPumpWidget(
  WidgetTester tester,
  Widget widget, {
  TelorPumpFn? pump,
  TelorDevice? device,
}) async {
  final effectivePump = pump ?? TelorPump.settle;
  if (device != null) {
    await tester.binding.setSurfaceSize(device.size);
    tester.view.devicePixelRatio = device.devicePixelRatio;
  }
  await tester.pumpWidget(widget);
  await effectivePump(tester);
}
