import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glint_capture/glint_capture.dart';

void main() {
  group('GLINTDevice', () {
    test('playStoreDefaults contains android devices', () {
      expect(GLINTDevices.playStoreDefaults, hasLength(3));
      expect(
        GLINTDevices.playStoreDefaults.every(
          (d) => d.platform == GLINTPlatform.android,
        ),
        isTrue,
      );
    });

    test('allDefaults includes eight presets', () {
      expect(GLINTDevices.allDefaults, hasLength(8));
    });
  });

  group('GLINTSession', () {
    test('toJson matches Glint schema', () {
      final session = GLINTSession(
        app: 'TestApp',
        tagline: 'Hello',
        screens: ['home_pixel7.png', 'profile_pixel7.png'],
        store: 'play',
      );

      final json = session.toJson();
      expect(json['app'], 'TestApp');
      expect(json['tagline'], 'Hello');
      expect(json['screens'], hasLength(2));
      expect(json['store'], 'play');
      expect(json['version'], '1.0');
      expect(json['exportedAt'], isNotNull);
    });

    test('fromDirectory scans nested png paths', () async {
      final dir = await Directory.systemTemp.createTemp('glint_session_');
      addTearDown(() => dir.delete(recursive: true));

      final screenDir = Directory('${dir.path}/android/pixel7');
      await screenDir.create(recursive: true);
      await File('${screenDir.path}/home.png').writeAsBytes([0x89, 0x50, 0x4E, 0x47]);
      await File('${screenDir.path}/profile.png').writeAsBytes([0x89, 0x50, 0x4E, 0x47]);

      final session = GLINTSession.fromDirectory(
        outputDir: dir.path,
        appName: 'ScanApp',
        tagline: 'Tag',
        store: 'play',
      );

      expect(session.app, 'ScanApp');
      expect(session.screens, containsAll(['android/pixel7/home.png', 'android/pixel7/profile.png']));

      final written = await session.write(dir.path);
      expect(await written.exists(), isTrue);
      final contents = await written.readAsString();
      expect(contents, contains('"version": "1.0"'));
      expect(contents, contains('android/pixel7/home.png'));
    });
  });

  group('expandRules', () {
    test('expands screen rules unchanged', () {
      final rules = [
        GLINTRule.screen(name: 'home', builder: (context) => const SizedBox()),
      ];
      expect(expandRules(rules), hasLength(1));
    });

    test('expands template rules with builders', () {
      final rules = [
        GLINTRule.template(
          name: 'onboarding_flow',
          screens: ['welcome', 'signup'],
          builders: {
            'welcome': (context) => const SizedBox(),
            'signup': (context) => const SizedBox(),
          },
        ),
      ];
      expect(expandRules(rules), hasLength(2));
    });
  });

  group('GLINTTemplates', () {
    test('resolve returns known templates', () {
      expect(GLINTTemplates.resolve('onboarding_flow'), hasLength(5));
      expect(GLINTTemplates.resolve('feature_highlights'), hasLength(5));
    });
  });
}
