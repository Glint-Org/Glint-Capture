import 'package:flutter_test/flutter_test.dart';

/// Controls how long to wait before capturing a screenshot.
typedef GLINTPumpFn = Future<void> Function(WidgetTester tester);

/// Pump helpers for screenshot timing.
abstract final class GLINTPump {
  /// Wait for all animations to settle (default).
  static GLINTPumpFn get settle =>
      (tester) => tester.pumpAndSettle();

  /// Wait a fixed duration (useful for infinite animations).
  static GLINTPumpFn duration(int milliseconds) =>
      (tester) => tester.pump(Duration(milliseconds: milliseconds));

  /// Single frame pump — no waiting.
  static GLINTPumpFn get none =>
      (tester) => tester.pump();
}
