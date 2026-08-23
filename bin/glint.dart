#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// CLI for Glint — generates store-ready screenshots.
///
/// Usage:
///   glint init
///   glint capture
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    _printHelp();
    return;
  }

  switch (args.first) {
    case 'init':
      await _init();
    case 'capture':
      await _capture();
    case '-h':
    case '--help':
    case 'help':
      _printHelp();
    default:
      print('Unknown command: ${args.first}');
      print('Run: glint help');
      exit(1);
  }
}

/// Initialize a new project with glint.yaml, screens file, and font config.
Future<void> _init() async {
  final configPath = 'glint.yaml';
  final screensPath = p.join('test', 'glint_screenshots_test.dart');
  final fontConfigPath = p.join('test', 'flutter_test_config.dart');

  if (File(configPath).existsSync()) {
    print('glint.yaml already exists. Skipping.');
  } else {
    await File(configPath).writeAsString(_defaultConfig);
    print('Created glint.yaml');
  }

  if (File(screensPath).existsSync()) {
    print('$screensPath already exists. Skipping.');
  } else {
    await Directory(p.dirname(screensPath)).create(recursive: true);
    await File(screensPath).writeAsString(_defaultScreens);
    print('Created $screensPath');
  }

  if (File(fontConfigPath).existsSync()) {
    print('$fontConfigPath already exists. Skipping.');
  } else {
    await Directory(p.dirname(fontConfigPath)).create(recursive: true);
    await File(fontConfigPath).writeAsString(_defaultFontConfig);
    print('Created $fontConfigPath');
  }

  print('''
Done! Next steps:
  1. Edit glint.yaml — set app name, devices
  2. Edit $screensPath — import your screens and define rules
  3. Run: glint capture
''');
}

/// Generate screenshots by running flutter test on the screens file.
Future<void> _capture() async {
  final configPath = _findConfig();
  if (configPath == null) {
    print('Error: No glint.yaml found. Run: glint init');
    exit(1);
  }

  // Parse config
  final yaml = loadYaml(File(configPath).readAsStringSync());
  final appName = yaml['app_name'] as String? ?? 'MyApp';
  final store = yaml['store'] as String? ?? 'play';
  final outputDir = yaml['output'] as String? ?? 'glint_screenshots';
  final devicesRaw = yaml['devices'];

  List<String> deviceNames;
  if (devicesRaw is String) {
    deviceNames = [devicesRaw];
  } else if (devicesRaw is List) {
    deviceNames = devicesRaw.map((d) => d['name'] as String).toList();
  } else {
    deviceNames = ['play_store'];
  }

  print('Glint');
  print('  Config:  $configPath');
  print('  App:     $appName');
  print('  Store:   $store');
  print('  Devices: ${deviceNames.join(', ')}');

  // Find screens file
  final testFile = _findTestFile();
  if (testFile == null) {
    print('\nError: No screens file found. Run: glint init');
    exit(1);
  }

  print('  Screens: ${p.relative(testFile)}');
  print('\nCapturing...');

  // Run flutter test
  final result = await Process.run('flutter', [
    'test',
    testFile,
    '--no-pub',
  ], runInShell: true);

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    print('\nError: flutter test failed (exit ${result.exitCode})');
    exit(result.exitCode);
  }

  // Count screenshots
  var count = 0;
  final outputDirObj = Directory(outputDir);
  if (outputDirObj.existsSync()) {
    for (final entity in outputDirObj.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.png')) count++;
    }
  }

  print('\nDone! Generated $count screenshot(s).');
  print('Output: ${p.normalize(outputDir)}/');
  print('Import into Glint-Web to apply templates and export.');
}

String? _findConfig() {
  for (final path in ['glint.yaml', 'glint.yml']) {
    if (File(path).existsSync()) return path;
  }
  return null;
}

String? _findTestFile() {
  for (final path in [
    'test/glint_screenshots_test.dart',
    'test/screenshots_test.dart',
    'test/glint_test.dart',
  ]) {
    if (File(path).existsSync()) return path;
  }

  final testDir = Directory('test');
  if (testDir.existsSync()) {
    for (final file in testDir.listSync().whereType<File>()) {
      if (file.path.endsWith('.dart')) {
        final content = file.readAsStringSync();
        if (content.contains('glintScreenshots')) return file.path;
      }
    }
  }

  return null;
}

void _printHelp() {
  print('''
Glint — device-free Flutter screenshot generation

Usage:
  glint <command>

Commands:
  init                Create glint.yaml + screens file + font config
  capture             Generate screenshots from config
  help                Show this help

Device Presets (use in glint.yaml):
  play_store          pixel7 + galaxy_s23 + samsung_m12
  app_store           iphone14_pro + iphone15 + ipad_10 + ipad_pro_11
  android             All Android phones
  ios                 All iOS devices
  phones              All phones only
  tablets             All tablets only
  all                 Everything

Workflow:
  1. glint init
  2. Edit glint.yaml — set app name, devices
  3. Edit test/glint_screenshots_test.dart — import your screens
  4. glint capture
''');
}

const _defaultConfig = '''# Glint configuration
# Docs: https://github.com/darkmintis/Glint-Capture

app_name: MyApp
tagline: "Your app tagline"
store: play  # play | ios

# Use a preset:
# devices: play_store
# devices: app_store
# devices: phones
# devices: all

# Or define custom devices:
devices:
  - name: pixel7
    width: 412
    height: 915
    device_pixel_ratio: 2.625
    platform: android
  - name: galaxy_s23
    width: 360
    height: 780
    device_pixel_ratio: 3.0
    platform: android
  - name: samsung_m12
    width: 360
    height: 800
    device_pixel_ratio: 2.0
    platform: android
  - name: iphone14_pro
    width: 393
    height: 852
    device_pixel_ratio: 3.0
    platform: ios
  - name: ipad_10
    width: 820
    height: 1180
    device_pixel_ratio: 2.0
    platform: ios
''';

const _defaultScreens = '''import 'package:flutter/material.dart';
import 'package:glint_capture/glint_capture.dart';

/// Define your screens here. Each GLINTRule.screen() creates a screenshot.
///
/// Run: glint capture
void main() {
  glintScreenshots(
    appName: 'MyApp',
    devices: GLINTDevices.playStoreDefaults,
    rules: [
      GLINTRule.screen(
        name: 'home',
        builder: (context) => const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Home Screen')),
          ),
        ),
      ),
      // Add more screens here...
    ],
  );
}
''';

const _defaultFontConfig = '''import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads real fonts before tests run.
/// Prevents Ahem font from rendering text as black blocks.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load Roboto from glint_capture package (not package-prefixed)
  final robotoLoader = FontLoader('Roboto');
  robotoLoader.addFont(rootBundle.load('packages/glint_capture/assets/fonts/Roboto/Roboto-Regular.ttf'));
  robotoLoader.addFont(rootBundle.load('packages/glint_capture/assets/fonts/Roboto/Roboto-Medium.ttf'));
  robotoLoader.addFont(rootBundle.load('packages/glint_capture/assets/fonts/Roboto/Roboto-Bold.ttf'));
  await robotoLoader.load();

  // Load all fonts from FontManifest.json (your custom fonts + MaterialIcons)
  try {
    final manifestString = await rootBundle.loadString('FontManifest.json');
    final manifest = json.decode(manifestString) as List<dynamic>;

    for (final entry in manifest) {
      final family = entry['family'] as String;
      final fonts = entry['fonts'] as List<dynamic>;

      // Skip Roboto (already loaded above)
      if (family == 'Roboto' || family == 'packages/glint_capture/Roboto') continue;

      final loader = FontLoader(family);
      for (final fontAsset in fonts) {
        final assetPath = fontAsset['asset'] as String;
        loader.addFont(rootBundle.load(assetPath));
      }
      await loader.load();
    }
  } catch (_) {}

  await testMain();
}
''';
