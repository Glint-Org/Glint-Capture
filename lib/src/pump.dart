import 'package:flutter_test/flutter_test.dart';

/// Controls how long to wait before capturing a screenshot.
typedef TelorPumpFn = Future<void> Function(WidgetTester tester);

/// Pump helpers for screenshot timing.
abstract final class TelorPump {
  /// Wait for all animations to settle (default).
  static TelorPumpFn get settle =>
      (tester) => tester.pumpAndSettle();

  /// Wait a fixed duration (useful for infinite animations).
  static TelorPumpFn duration(int milliseconds) =>
      (tester) => tester.pump(Duration(milliseconds: milliseconds));

  /// Single frame pump — no waiting.
  static TelorPumpFn get none => (tester) => tester.pump();
}
