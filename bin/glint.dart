#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:glint_capture/glint_capture.dart';

/// CLI for Glint — generates store-ready screenshots.
///
/// Usage:
///   glint init                    # create glint.yaml + sample screens
///   glint capture                 # generate screenshots
///   glint capture --devices pixel7,galaxy_s23
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    _printHelp();
    return;
  }

  switch (args.first) {
    case 'init':
      await _init();
    case 'capture':
      await _capture(_parseArgs(args.sublist(1)));
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

/// Initialize a new project with glint.yaml and sample screens file.
Future<void> _init() async {
  final configPath = 'glint.yaml';
  final screensPath = p.join('test', 'glint_screenshots_test.dart');

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

  print('''
Done! Next steps:
  1. Edit glint.yaml — set app name, devices
  2. Edit $screensPath — define your screens
  3. Run: glint capture
''');
}

/// Generate screenshots from glint.yaml config.
Future<void> _capture(_Options options) async {
  final configPath = options.config ?? GLINTConfig.findConfig();
  if (configPath == null) {
    print('Error: No glint.yaml found. Run: glint init');
    exit(1);
  }

  final config = GLINTConfig.load(configPath);

  print('Glint');
  print('  Config:  $configPath');
  print('  App:     ${config.appName}');
  print('  Store:   ${config.store}');
  print('  Devices: ${config.devices.map((d) => d.name).join(', ')}');

  // Find the screens test file
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
  ], runInShell: true);

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    print('\nError: flutter test failed (exit ${result.exitCode})');
    exit(result.exitCode);
  }

  // Write session.json
  final outputDir = config.outputDir;
  final session = GLINTSession.fromDirectory(
    outputDir: outputDir,
    appName: config.appName,
    tagline: config.tagline,
    store: config.store,
  );
  final sessionFile = await session.write(outputDir);

  // Count screenshots
  var count = 0;
  for (final device in config.devices) {
    final platformDir = switch (device.platform) {
      GLINTPlatform.android => 'android',
      GLINTPlatform.ios => 'ios',
    };
    final deviceDir = Directory(p.join(outputDir, platformDir, device.name));
    if (deviceDir.existsSync()) {
      count += deviceDir
          .listSync()
          .whereType<File>()
          .where((f) => p.extension(f.path) == '.png')
          .length;
    }
  }

  print('\nDone! Generated $count screenshot(s).');
  print('Session: ${sessionFile.path}');
  print('Import $outputDir/ into Glint-Web to apply templates and export.');
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

class _Options {
  _Options({this.config, this.devices});

  final String? config;
  final String? devices;
}

_Options _parseArgs(List<String> args) {
  String? config;
  String? devices;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--config':
        config = _nextArg(args, ++i, '--config');
      case '--devices':
      case '-d':
        devices = _nextArg(args, ++i, arg);
    }
  }

  return _Options(config: config, devices: devices);
}

String _nextArg(List<String> args, int index, String flag) {
  if (index >= args.length) {
    print('Error: $flag requires a value');
    exit(1);
  }
  return args[index];
}

void _printHelp() {
  print('''
Glint — device-free Flutter screenshot generation

Usage:
  glint <command> [options]

Commands:
  init                Create glint.yaml + sample screens file
  capture             Generate screenshots from config
  help                Show this help

Options:
  --config <path>     Path to glint.yaml (default: auto-find)
  -d, --devices <list> Comma-separated device names (overrides config)

Devices:
  pixel7, galaxy_s23, iphone15, ipad_pro_11
  play_store (pixel7 + galaxy_s23)
  app_store (iphone15 + ipad_pro_11)
  all (all four presets)

Workflow:
  1. glint init
  2. Edit glint.yaml — set app name, devices
  3. Edit test/glint_screenshots_test.dart — define screens
  4. glint capture
  5. Import glint_screenshots/ into Glint-Web
''');
}

const _defaultConfig = '''# Glint configuration
# Docs: https://github.com/darkmintis/Glint-Capture

app_name: MyApp
tagline: "Your app tagline"
store: play  # play | ios

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
