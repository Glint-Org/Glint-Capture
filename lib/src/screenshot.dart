import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'devices.dart';
import 'pump.dart';

/// Whether fonts have been loaded for this test process.
bool _fontsLoaded = false;

/// Loads Roboto + MaterialIcons + all host app fonts so captures show real text.
///
/// Called automatically before every capture. Safe to call multiple times.
Future<void> _ensureFontsLoaded() async {
  if (_fontsLoaded) return;

  // 1. Load Roboto from the package's bundled fonts.
  final robotoLoader = FontLoader('Roboto');
  for (final w in ['Thin', 'Light', 'Regular', 'Medium', 'Bold', 'Black']) {
    try {
      robotoLoader.addFont(rootBundle.load('packages/glint_capture/assets/fonts/Roboto/Roboto-$w.ttf'));
    } catch (_) {}
  }
  await robotoLoader.load();

  // 2. Load MaterialIcons from the Flutter SDK.
  try {
    final iconsLoader = FontLoader('MaterialIcons');
    iconsLoader.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await iconsLoader.load();
  } catch (_) {}

  // 3. Auto-load all fonts declared in the host app's FontManifest.json.
  //    This picks up Inter, Poppins, and any other custom fonts automatically.
  try {
    final manifestString = await rootBundle.loadString('FontManifest.json');
    final manifest = json.decode(manifestString) as List<dynamic>;

    for (final entry in manifest) {
      final family = entry['family'] as String;
      final fonts = entry['fonts'] as List<dynamic>;

      // Skip fonts we already loaded
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

  _fontsLoaded = true;
}

/// Captures widgets as PNG screenshots without golden test dependencies.
///
/// Renders at full device logical size × [devicePixelRatio] so output matches
/// store pixel dimensions (e.g. Pixel 9 → ~1081×2402).
class GLINTScreenshot {
  /// Pump [widget] and capture as PNG bytes.
  ///
  /// [widget] should be a screen (or overlay stack), not a nested [MaterialApp]
  /// unless you pass a tree that already includes one and skip [theme].
  static Future<Uint8List> capture({
    required WidgetTester tester,
    required Widget widget,
    required Size size,
    double devicePixelRatio = 1.0,
    double textScale = 1.0,
    ThemeData? theme,
    GLINTPumpFn? pump,
    GLINTDevice? device,
  }) async {
    // Ensure Roboto + MaterialIcons + host fonts are loaded before building widget tree.
    await _ensureFontsLoaded();

    final view = tester.view;
    final previousPhysical = view.physicalSize;
    final previousDpr = view.devicePixelRatio;

    // Set device geometry: physical size = logical size × DPR
    view.physicalSize = Size(
      size.width * devicePixelRatio,
      size.height * devicePixelRatio,
    );
    view.devicePixelRatio = devicePixelRatio;
    await tester.binding.setSurfaceSize(size);

    final key = GlobalKey();
    try {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme ?? ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: SizedBox(
            width: size.width,
            height: size.height,
            child: RepaintBoundary(
              key: key,
              child: widget,
            ),
          ),
        ),
      );

      await (pump ?? GLINTPump.settle)(tester);

      late final Uint8List bytes;
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: devicePixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        bytes = byteData!.buffer.asUint8List();
        image.dispose();
      });

      return bytes;
    } finally {
      await tester.binding.setSurfaceSize(null);
      view.physicalSize = previousPhysical;
      view.devicePixelRatio = previousDpr;
    }
  }

  /// Save PNG bytes to [path], creating parent directories as needed.
  static Future<File> save(Uint8List bytes, String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    return file.writeAsBytes(bytes);
  }
}
