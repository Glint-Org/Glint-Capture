import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures widgets as PNG screenshots without golden test dependencies.
class GLINTScreenshot {
  /// Pump [widget] and capture as PNG bytes.
  /// Waits for all animations and layouts to complete before capturing.
  static Future<Uint8List> capture({
    required WidgetTester tester,
    required Widget widget,
    required Size size,
    double devicePixelRatio = 1.0,
  }) async {
    tester.view.devicePixelRatio = devicePixelRatio;

    final key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          devicePixelRatio: devicePixelRatio,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: SizedBox(
              width: size.width,
              height: size.height,
              child: RepaintBoundary(
                key: key,
                child: widget,
              ),
            ),
          ),
        ),
      ),
    );

    // Wait for all animations, layouts, and fonts to settle
    await tester.pumpAndSettle();

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
  }

  /// Save PNG bytes to [path], creating parent directories as needed.
  static Future<File> save(Uint8List bytes, String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    return file.writeAsBytes(bytes);
  }
}
