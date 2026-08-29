/// Device-free Flutter screenshot capture for store-ready assets.
///
/// ```dart
/// import 'package:glint_capture/glint_capture.dart';
///
/// void main() {
///   glintScreenshots(
///     rules: [
///       GLINTRule.screen(
///         name: 'home',
///         builder: (context) => const HomeScreen(),
///       ),
///     ],
///   );
/// }
/// ```
library;

export 'src/config.dart';
export 'src/devices.dart';
export 'src/discover/models.dart';
export 'src/pump.dart';
export 'src/rules.dart';
export 'src/runner.dart';
export 'src/screenshot.dart';
export 'src/session.dart';

