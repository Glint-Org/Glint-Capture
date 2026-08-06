/// Device-free Flutter screenshot capture for store-ready assets.
///
/// ```dart
/// import 'package:telor_capture/telor_capture.dart';
///
/// void main() {
///   telorScreenshots(
///     appName: 'MyApp',
///     rules: [
///       TelorRule.screen(
///         name: 'home',
///         builder: (context) => const HomeScreen(),
///       ),
///     ],
///   );
/// }
/// ```
library telor_capture;

export 'src/devices.dart';
export 'src/pump.dart';
export 'src/rules.dart';
export 'src/runner.dart';
export 'src/session.dart';
