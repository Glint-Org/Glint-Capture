import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Package-local font loader for glint_capture's own tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final robotoLoader = FontLoader('Roboto');
  for (final asset in [
    'assets/fonts/Roboto/Roboto-Thin.ttf',
    'assets/fonts/Roboto/Roboto-Light.ttf',
    'assets/fonts/Roboto/Roboto-Regular.ttf',
    'assets/fonts/Roboto/Roboto-Medium.ttf',
    'assets/fonts/Roboto/Roboto-Bold.ttf',
    'assets/fonts/Roboto/Roboto-Black.ttf',
  ]) {
    robotoLoader.addFont(rootBundle.load(asset));
  }
  await robotoLoader.load();

  final iconsLoader = FontLoader('MaterialIcons');
  iconsLoader.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await iconsLoader.load();

  await testMain();
}
