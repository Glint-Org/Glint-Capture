import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telor_capture/telor_capture.dart';

void main() {
  group('TelorDevice', () {
    test('playStoreDefaults contains android devices', () {
      expect(TelorDevices.playStoreDefaults, hasLength(2));
      expect(TelorDevices.playStoreDefaults.every((d) => d.platform == TelorPlatform.android), isTrue);
    });

    test('allDefaults includes four presets', () {
      expect(TelorDevices.allDefaults, hasLength(4));
    });
  });

  group('TelorSession', () {
    test('toJson matches Telor schema', () {
      final session = TelorSession(
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
        TelorRule.screen(
          name: 'home',
          builder: (context) => const SizedBox(),
        ),
      ];
      expect(expandRules(rules), hasLength(1));
    });

    test('expands template rules with builders', () {
      final rules = [
        TelorRule.template(
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

  group('TelorTemplates', () {
    test('resolve returns known templates', () {
      expect(TelorTemplates.resolve('onboarding_flow'), hasLength(5));
      expect(TelorTemplates.resolve('feature_highlights'), hasLength(5));
    });
  });
}
