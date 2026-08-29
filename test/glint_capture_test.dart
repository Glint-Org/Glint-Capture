import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glint_capture/glint_capture.dart';

void main() {
  group('GLINTDevice', () {
    test('playStoreDefaults are curated Android phones', () {
      expect(GLINTDevices.playStoreDefaults, hasLength(2));
      expect(GLINTDevices.playStoreDefaults.first.name, 'pixel9');
    });

    test('premium is the full curated set of six', () {
      expect(GLINTDevices.premium, hasLength(6));
      expect(GLINTDevices.allDefaults, GLINTDevices.premium);
    });
  });

  group('GLINTSession', () {
    test('toJson matches Glint schema', () {
      final session = GLINTSession(
        screens: ['android/pixel9/home.png', 'android/pixel9/profile.png'],
        store: 'play',
      );

      final json = session.toJson();
      expect(json['screens'], hasLength(2));
      expect(json['store'], 'play');
      expect(json['version'], '1.0');
      expect(json['exportedAt'], isNotNull);
    });

    test('fromDirectory picks primary device for Web frames', () async {
      final dir = await Directory.systemTemp.createTemp('glint_session_');
      addTearDown(() => dir.delete(recursive: true));

      final pixel = Directory('${dir.path}/android/pixel9');
      final galaxy = Directory('${dir.path}/android/galaxy_s24');
      await pixel.create(recursive: true);
      await galaxy.create(recursive: true);
      await File('${pixel.path}/home.png').writeAsBytes([0x89, 0x50, 0x4E, 0x47]);
      await File('${pixel.path}/profile.png').writeAsBytes([0x89, 0x50, 0x4E, 0x47]);
      await File('${galaxy.path}/home.png').writeAsBytes([0x89, 0x50, 0x4E, 0x47]);

      final session = GLINTSession.fromDirectory(
        outputDir: dir.path,
        store: 'play',
      );

      expect(session.screens, [
        'android/pixel9/home.png',
        'android/pixel9/profile.png',
      ]);

      final written = await session.write(dir.path);
      expect(await written.exists(), isTrue);
      final contents = await written.readAsString();
      expect(contents, contains('"version": "1.0"'));
      expect(contents, contains('android/pixel9/home.png'));
      expect(contents, isNot(contains('galaxy_s24')));
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

    test('unknown template throws', () {
      expect(
        () => GLINTTemplates.resolve('not_a_real_template'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('GLINTSession store keys', () {
    test('preserves canonical store ids in JSON', () {
      final session = GLINTSession(
        screens: ['android/pixel9/home.png'],
        store: 'play/phone',
      );
      expect(session.toJson()['store'], 'play/phone');
    });
  });
}
