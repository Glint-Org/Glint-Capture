#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:glint_capture/glint_capture.dart';

/// CLI for running glint screenshot capture and exporting session.json.
///
/// Usage:
///   dart run glint_capture --test test/glint_screenshots_test.dart
///   dart run glint_capture --test test/glint_screenshots_test.dart --app MyApp --output build/glint_screenshots
Future<void> main(List<String> args) async {
  final options = _parseArgs(args);

  if (options.help) {
    _printHelp();
    return;
  }

  final testFile = options.testFile ?? 'test/glint_screenshots_test.dart';
  if (!File(testFile).existsSync()) {
    print('Error: Test file not found: $testFile');
    print('Create a test file that calls glintScreenshots() in main().');
    exit(1);
  }

  print('Glint Capture — running golden screenshot tests...');
  print('  Test:   $testFile');
  print('  Output: ${options.outputDir}');

  final result = await Process.run('flutter', [
    'test',
    testFile,
    '--update-goldens',
  ], runInShell: true);

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    print('\nError: flutter test failed (exit ${result.exitCode})');
    exit(result.exitCode);
  }

  final testDir = p.dirname(p.absolute(testFile));
  final goldensDir = p.join(testDir, 'goldens');
  final ciGoldensDir = p.join(goldensDir, 'ci');

  final sourceDir = Directory(ciGoldensDir).existsSync()
      ? ciGoldensDir
      : goldensDir;

  print('\nCopying golden files from $sourceDir...');
  final copied = await copyGoldensToOutput(
    sourceDir: sourceDir,
    outputDir: options.outputDir,
  );

  if (copied.isEmpty) {
    print('Warning: No PNG files found in $sourceDir');
    print(
      'Ensure tests ran with --update-goldens and alchemist generated files.',
    );
  } else {
    print('Copied ${copied.length} screenshot(s):');
    for (final name in copied) {
      print('  $name');
    }
  }

  final session = GLINTSession(
    app: options.appName,
    tagline: options.tagline,
    screens: copied,
    store: options.store,
  );
  final sessionFile = await session.write(options.outputDir);
  print('\nSession written: ${sessionFile.path}');
  print('Import this folder into Glint-Web to apply templates and export.');
}

class _Options {
  _Options({
    required this.help,
    this.testFile,
    required this.outputDir,
    required this.appName,
    this.tagline,
    required this.store,
  });

  final bool help;
  final String? testFile;
  final String outputDir;
  final String appName;
  final String? tagline;
  final String store;
}

_Options _parseArgs(List<String> args) {
  var help = false;
  String? testFile;
  var outputDir = 'build/glint_screenshots';
  var appName = 'MyApp';
  String? tagline;
  var store = 'play';

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '-h':
      case '--help':
        help = true;
      case '--test':
        testFile = _nextArg(args, ++i, '--test');
      case '--output':
      case '-o':
        outputDir = _nextArg(args, ++i, arg);
      case '--app':
      case '-a':
        appName = _nextArg(args, ++i, arg);
      case '--tagline':
      case '-t':
        tagline = _nextArg(args, ++i, arg);
      case '--store':
        store = _nextArg(args, ++i, arg);
    }
  }

  return _Options(
    help: help,
    testFile: testFile,
    outputDir: outputDir,
    appName: appName,
    tagline: tagline,
    store: store,
  );
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
Glint Capture — device-free Flutter screenshot generation

Usage:
  dart run glint_capture [options]

Options:
  --test <path>       Test file with glintScreenshots() (default: test/glint_screenshots_test.dart)
  -o, --output <dir>  Output directory for PNGs + session.json (default: build/glint_screenshots)
  -a, --app <name>    App name for session.json (default: MyApp)
  -t, --tagline <text> Tagline for session.json
  --store <play|ios>  Store target (default: play)
  -h, --help          Show this help

Workflow:
  1. Add glint_capture to dev_dependencies
  2. Create test/glint_screenshots_test.dart with glintScreenshots()
  3. Run: dart run glint_capture
  4. Import build/glint_screenshots/ into Glint-Web
''');
}
