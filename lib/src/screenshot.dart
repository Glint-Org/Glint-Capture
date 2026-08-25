import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

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
  }) async {
    final view = tester.view;
    final previousPhysical = view.physicalSize;
    final previousDpr = view.devicePixelRatio;

    view.physicalSize = Size(
      size.width * devicePixelRatio,
      size.height * devicePixelRatio,
    );
    view.devicePixelRatio = devicePixelRatio;
    await tester.binding.setSurfaceSize(size);

    final key = GlobalKey();
    try {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: devicePixelRatio,
            textScaler: TextScaler.linear(textScale),
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme ?? ThemeData(useMaterial3: true),
            home: SizedBox(
              width: size.width,
              height: size.height,
              child: RepaintBoundary(
                key: key,
                child: widget,
              ),
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
