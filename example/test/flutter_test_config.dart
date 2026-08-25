import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads real fonts before tests run so captures are not Ahem blocks.
///
/// Loads Roboto (all common weights) + MaterialIcons, then every family in
/// FontManifest.json (host app custom fonts).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final robotoLoader = FontLoader('Roboto');
  for (final asset in [
    'packages/glint_capture/assets/fonts/Roboto/Roboto-Thin.ttf',
    'packages/glint_capture/assets/fonts/Roboto/Roboto-Light.ttf',
    'packages/glint_capture/assets/fonts/Roboto/Roboto-Regular.ttf',
    'packages/glint_capture/assets/fonts/Roboto/Roboto-Medium.ttf',
    'packages/glint_capture/assets/fonts/Roboto/Roboto-Bold.ttf',
    'packages/glint_capture/assets/fonts/Roboto/Roboto-Black.ttf',
  ]) {
    robotoLoader.addFont(rootBundle.load(asset));
  }
  await robotoLoader.load();

  try {
    final iconsLoader = FontLoader('MaterialIcons');
    iconsLoader.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await iconsLoader.load();
  } catch (_) {
    // Host apps usually get MaterialIcons via FontManifest below.
  }

  try {
    final manifestString = await rootBundle.loadString('FontManifest.json');
    final manifest = json.decode(manifestString) as List<dynamic>;

    for (final entry in manifest) {
      final family = entry['family'] as String;
      final fonts = entry['fonts'] as List<dynamic>;

      if (family == 'Roboto' ||
          family == 'packages/glint_capture/Roboto' ||
          family == 'MaterialIcons') {
        continue;
      }

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
