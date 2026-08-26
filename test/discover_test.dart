import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glint_capture/src/discover/discover.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('glint_discover_');
  });

  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test('scanner finds Screen widgets', () async {
    await File(p.join(tmp.path, 'pubspec.yaml')).writeAsString('''
name: demo_app
''');
    final lib = Directory(p.join(tmp.path, 'lib', 'screens'));
    await lib.create(recursive: true);
    await File(p.join(lib.path, 'home_screen.dart')).writeAsString('''
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''');
    await File(p.join(lib.path, 'profile_screen.dart')).writeAsString('''
import 'package:flutter/material.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''');

    final screens = await ScreenScanner(projectRoot: tmp.path).scan();
    expect(screens.map((s) => s.className), containsAll(['HomeScreen', 'ProfileScreen']));
    expect(screens.firstWhere((s) => s.name == 'home').importUri, contains('package:demo_app/'));
  });

  test('codegen emits real builders', () async {
    final screens = [
      const DiscoveredScreen(
        name: 'home',
        className: 'HomeScreen',
        importUri: 'package:demo_app/screens/home_screen.dart',
        sourcePath: 'lib/screens/home_screen.dart',
      ),
    ];
    final codegen = ScreensTestCodegen(projectRoot: tmp.path, appName: 'Demo');
    final src = codegen.generateFullSource(screens);
    expect(src, contains("import 'package:demo_app/screens/home_screen.dart';"));
    expect(src, contains('const HomeScreen()'));
    expect(src, contains("name: 'home'"));
    expect(src, isNot(contains('Text(\'Home Screen\')')));
  });
}
