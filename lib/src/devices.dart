import 'dart:ui';

/// Simulated device configuration for screenshot capture.
class TelorDevice {
  const TelorDevice({
    required this.name,
    required this.size,
    this.devicePixelRatio = 1.0,
    this.textScale = 1.0,
    this.platform = TelorPlatform.android,
  });

  final String name;
  final Size size;
  final double devicePixelRatio;
  final double textScale;
  final TelorPlatform platform;

  /// Pixel 7 — Play Store phone default.
  static const pixel7 = TelorDevice(
    name: 'pixel7',
    size: Size(412, 915),
    devicePixelRatio: 2.625,
    platform: TelorPlatform.android,
  );

  /// Samsung Galaxy S23.
  static const galaxyS23 = TelorDevice(
    name: 'galaxy_s23',
    size: Size(360, 780),
    devicePixelRatio: 3.0,
    platform: TelorPlatform.android,
  );

  /// iPhone 15 — App Store phone.
  static const iphone15 = TelorDevice(
    name: 'iphone15',
    size: Size(393, 852),
    devicePixelRatio: 3.0,
    platform: TelorPlatform.ios,
  );

  /// iPad Pro 11".
  static const ipadPro11 = TelorDevice(
    name: 'ipad_pro_11',
    size: Size(834, 1194),
    devicePixelRatio: 2.0,
    platform: TelorPlatform.ios,
  );

  /// Play Store export canvas (Telor-Web scales into this).
  static const playStoreExport = TelorDevice(
    name: 'play_store',
    size: Size(1080, 1920),
    devicePixelRatio: 1.0,
    platform: TelorPlatform.android,
  );

  /// App Store phone export canvas.
  static const appStoreExport = TelorDevice(
    name: 'app_store',
    size: Size(1290, 2796),
    devicePixelRatio: 1.0,
    platform: TelorPlatform.ios,
  );
}

enum TelorPlatform { android, ios }

/// Preset device lists for common store targets.
abstract final class TelorDevices {
  static const playStoreDefaults = [
    TelorDevice.pixel7,
    TelorDevice.galaxyS23,
  ];

  static const appStoreDefaults = [
    TelorDevice.iphone15,
    TelorDevice.ipadPro11,
  ];

  static const allDefaults = [
    TelorDevice.pixel7,
    TelorDevice.galaxyS23,
    TelorDevice.iphone15,
    TelorDevice.ipadPro11,
  ];
}
