import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glint_capture/glint_capture.dart';

void main() {
  group('GLINTDevice', () {
    test('playStoreDefaults contains android devices', () {
      expect(GLINTDevices.playStoreDefaults, hasLength(2));
      expect(
        GLINTDevices.playStoreDefaults.every(
          (d) => d.platform == GLINTPlatform.android,
        ),
        isTrue,
      );
    });

    test('allDefaults includes four presets', () {
      expect(GLINTDevices.allDefaults, hasLength(4));
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
