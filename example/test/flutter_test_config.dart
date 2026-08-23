import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads real fonts before tests run.
/// Prevents Ahem font from rendering text as black blocks.
///
/// 1. Loads Roboto from glint_capture package assets (guaranteed available)
/// 2. Loads all fonts from FontManifest.json (developer's custom fonts)
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load Roboto from package assets (not package-prefixed)
  final robotoLoader = FontLoader('Roboto');
  robotoLoader.addFont(rootBundle.load('packages/glint_capture/assets/fonts/Roboto/Roboto-Regular.ttf'));
  robotoLoader.addFont(rootBundle.load('packages/glint_capture/assets/fonts/Roboto/Roboto-Medium.ttf'));
  robotoLoader.addFont(rootBundle.load('packages/glint_capture/assets/fonts/Roboto/Roboto-Bold.ttf'));
  await robotoLoader.load();

  // Load all fonts from FontManifest.json (developer's custom fonts + MaterialIcons)
  try {
    final manifestString = await rootBundle.loadString('FontManifest.json');
    final manifest = json.decode(manifestString) as List<dynamic>;

    for (final entry in manifest) {
      final family = entry['family'] as String;
      final fonts = entry['fonts'] as List<dynamic>;

      // Skip Roboto (already loaded above with correct family name)
      if (family == 'Roboto' || family == 'packages/glint_capture/Roboto') continue;

      final loader = FontLoader(family);
      for (final fontAsset in fonts) {
        final assetPath = fontAsset['asset'] as String;
        loader.addFont(rootBundle.load(assetPath));
      }
      await loader.load();
    }
  } catch (_) {
    // FontManifest.json may not exist in all environments
  }

  await testMain();
}
