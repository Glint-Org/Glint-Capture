import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads real fonts before tests run.
/// Prevents Ahem font from rendering text as black blocks.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final robotoLoader = FontLoader('Roboto');
  robotoLoader.addFont(rootBundle.load('assets/fonts/Roboto/Roboto-Regular.ttf'));
  robotoLoader.addFont(rootBundle.load('assets/fonts/Roboto/Roboto-Medium.ttf'));
  robotoLoader.addFont(rootBundle.load('assets/fonts/Roboto/Roboto-Bold.ttf'));
  await robotoLoader.load();

  final iconsLoader = FontLoader('MaterialIcons');
  iconsLoader.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await iconsLoader.load();

  await testMain();
}
