import 'dart:ui';

/// Simulated device for screenshot capture.
///
/// Curated set only — the devices developers use most for Play / App Store.
class GLINTDevice {
  const GLINTDevice({
    required this.name,
    required this.size,
    this.devicePixelRatio = 1.0,
    this.textScale = 1.0,
    this.platform = GLINTPlatform.android,
  });

  final String name;
  final Size size;
  final double devicePixelRatio;
  final double textScale;
  final GLINTPlatform platform;

  /// Pixel 9 — Play soft-launch default.
  static const pixel9 = GLINTDevice(
    name: 'pixel9',
    size: Size(412, 915),
    devicePixelRatio: 2.625,
    platform: GLINTPlatform.android,
  );

  /// Galaxy S24 — Play Samsung flagship.
  static const galaxyS24 = GLINTDevice(
    name: 'galaxy_s24',
    size: Size(360, 780),
    devicePixelRatio: 3.0,
    platform: GLINTPlatform.android,
  );

  /// iPhone 16 Pro Max — App Store 6.7" (→ 1290×2796).
  static const iphone16ProMax = GLINTDevice(
    name: 'iphone16_pro_max',
    size: Size(430, 932),
    devicePixelRatio: 3.0,
    platform: GLINTPlatform.ios,
  );

  /// iPhone 16 Pro.
  static const iphone16Pro = GLINTDevice(
    name: 'iphone16_pro',
    size: Size(393, 852),
    devicePixelRatio: 3.0,
    platform: GLINTPlatform.ios,
  );

  /// iPad Pro 13" (12.9" logical).
  static const ipadPro129 = GLINTDevice(
    name: 'ipad_pro_129',
    size: Size(1024, 1366),
    devicePixelRatio: 2.0,
    platform: GLINTPlatform.ios,
  );

  /// iPad Pro 11".
  static const ipadPro11 = GLINTDevice(
    name: 'ipad_pro_11',
    size: Size(834, 1194),
    devicePixelRatio: 2.0,
    platform: GLINTPlatform.ios,
  );

  /// Play Store export canvas (Glint-Web scales into this).
  static const playStoreExport = GLINTDevice(
    name: 'play_store',
    size: Size(1080, 1920),
    devicePixelRatio: 1.0,
    platform: GLINTPlatform.android,
  );

  /// App Store phone export canvas.
  static const appStoreExport = GLINTDevice(
    name: 'app_store',
    size: Size(1290, 2796),
    devicePixelRatio: 1.0,
    platform: GLINTPlatform.ios,
  );

  factory GLINTDevice.custom({
    required String name,
    required double width,
    required double height,
    double devicePixelRatio = 1.0,
    GLINTPlatform platform = GLINTPlatform.android,
  }) {
    return GLINTDevice(
      name: name,
      size: Size(width, height),
      devicePixelRatio: devicePixelRatio,
      platform: platform,
    );
  }
}

enum GLINTPlatform { android, ios }

/// Preset lists — only the curated devices above.
abstract final class GLINTDevices {
  static const playStoreDefaults = [
    GLINTDevice.pixel9,
    GLINTDevice.galaxyS24,
  ];

  static const appStoreDefaults = [
    GLINTDevice.iphone16ProMax,
    GLINTDevice.iphone16Pro,
    GLINTDevice.ipadPro129,
    GLINTDevice.ipadPro11,
  ];

  /// All curated devices (same as [allDefaults]).
  static const premium = [
    GLINTDevice.pixel9,
    GLINTDevice.galaxyS24,
    GLINTDevice.iphone16ProMax,
    GLINTDevice.iphone16Pro,
    GLINTDevice.ipadPro129,
    GLINTDevice.ipadPro11,
  ];

  static const allDefaults = premium;

  static List<GLINTDevice> resolve(String preset) {
    return switch (preset) {
      'play_store' => playStoreDefaults,
      'app_store' => appStoreDefaults,
      'premium' || 'all' => premium,
      'android' => playStoreDefaults,
      'ios' => appStoreDefaults,
      'phones' => [
        GLINTDevice.pixel9,
        GLINTDevice.galaxyS24,
        GLINTDevice.iphone16ProMax,
        GLINTDevice.iphone16Pro,
      ],
      'tablets' => [GLINTDevice.ipadPro129, GLINTDevice.ipadPro11],
      _ => throw ArgumentError('Unknown preset: $preset'),
    };
  }
}
