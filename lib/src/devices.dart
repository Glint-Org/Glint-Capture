import 'dart:ui';

/// Simulated device configuration for screenshot capture.
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

  /// Pixel 7 — Play Store phone default.
  static const pixel7 = GLINTDevice(
    name: 'pixel7',
    size: Size(412, 915),
    devicePixelRatio: 2.625,
    platform: GLINTPlatform.android,
  );

  /// Samsung Galaxy S23.
  static const galaxyS23 = GLINTDevice(
    name: 'galaxy_s23',
    size: Size(360, 780),
    devicePixelRatio: 3.0,
    platform: GLINTPlatform.android,
  );

  /// iPhone 15 — App Store phone.
  static const iphone15 = GLINTDevice(
    name: 'iphone15',
    size: Size(393, 852),
    devicePixelRatio: 3.0,
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

  /// Create a custom device with arbitrary dimensions.
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

/// Preset device lists for common store targets.
abstract final class GLINTDevices {
  static const playStoreDefaults = [GLINTDevice.pixel7, GLINTDevice.galaxyS23];

  static const appStoreDefaults = [GLINTDevice.iphone15, GLINTDevice.ipadPro11];

  static const allDefaults = [
    GLINTDevice.pixel7,
    GLINTDevice.galaxyS23,
    GLINTDevice.iphone15,
    GLINTDevice.ipadPro11,
  ];

  /// Resolve a preset name to a device list.
  static List<GLINTDevice> resolve(String preset) {
    return switch (preset) {
      'play_store' => playStoreDefaults,
      'app_store' => appStoreDefaults,
      'all' => allDefaults,
      _ => throw ArgumentError('Unknown preset: $preset'),
    };
  }
}
