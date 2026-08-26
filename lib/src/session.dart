import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Writes a Glint session JSON file compatible with Glint-Web and Glint-View.
class GLINTSession {
  GLINTSession({
    required this.app,
    required this.screens,
    this.tagline,
    this.store = 'play',
    this.version = '1.0',
    DateTime? exportedAt,
  }) : exportedAt = exportedAt ?? DateTime.now().toUtc();

  final String app;
  final String? tagline;
  final List<String> screens;
  final String store;
  final String version;
  final DateTime exportedAt;

  Map<String, dynamic> toJson() => {
    'app': app,
    if (tagline != null) 'tagline': tagline,
    'screens': screens,
    'store': store,
    'version': version,
    'exportedAt': exportedAt.toIso8601String(),
  };

  String toJsonString({bool pretty = true}) => pretty
      ? const JsonEncoder.withIndent('  ').convert(toJson())
      : jsonEncode(toJson());

  /// Write session.json to [outputDir].
  Future<File> write(String outputDir) async {
    final dir = Directory(outputDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(p.join(outputDir, 'session.json'));
    await file.writeAsString(toJsonString());
    return file;
  }

  /// Build session by scanning the platform/device/screen output structure.
  ///
  /// Expected layout:
  /// ```
  /// outputDir/
  /// ├── android/
  /// │   └── pixel9/
  /// │       ├── home.png
  /// │       └── profile.png
  /// └── ios/
  ///     └── ...
  /// ```
  ///
  /// For Glint Web frames import, [screens] lists **one primary device** only
  /// (so frame 1–N map to home → profile → …). Other device folders remain on
  /// disk for optional use. Prefer soft-launch captures with a single device.
  static GLINTSession fromDirectory({
    required String outputDir,
    required String appName,
    String? tagline,
    String store = 'play',
    String? primaryDevice,
  }) {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      throw StateError('Output directory does not exist: $outputDir');
    }

    // platform -> device -> [relative paths]
    final byDevice = <String, Map<String, List<String>>>{};

    for (final platformDir in dir.listSync().whereType<Directory>()) {
      final platform = p.basename(platformDir.path);
      if (platform.startsWith('.')) continue;
      byDevice[platform] ??= {};
      for (final deviceDir in platformDir.listSync().whereType<Directory>()) {
        final device = p.basename(deviceDir.path);
        final paths = <String>[];
        for (final file in deviceDir.listSync().whereType<File>()) {
          if (p.extension(file.path).toLowerCase() == '.png') {
            paths.add('$platform/$device/${p.basename(file.path)}');
          }
        }
        // Keep screen order stable by basename (home, profile, …) within device
        paths.sort((a, b) => p.basename(a).compareTo(p.basename(b)));
        if (paths.isNotEmpty) {
          byDevice[platform]![device] = paths;
        }
      }
    }

    final screens = _pickPrimaryScreens(byDevice, store, primaryDevice);

    return GLINTSession(
      app: appName,
      tagline: tagline,
      screens: screens,
      store: store,
    );
  }

  /// Prefer a coherent single-device list for Web frames mapping.
  static List<String> _pickPrimaryScreens(
    Map<String, Map<String, List<String>>> byDevice,
    String store,
    String? primaryDevice,
  ) {
    if (byDevice.isEmpty) return [];

    String? platformHint;
    final normalized = store.contains('/') ? store.split('/').first : store;
    if (normalized == 'ios' || store == 'ios-tablet' || store == 'ios/iphone' || store == 'ios/ipad') {
      platformHint = 'ios';
    } else if (normalized == 'play' || store == 'android') {
      platformHint = 'android';
    }

    // Explicit device name wins when present under any platform.
    if (primaryDevice != null && primaryDevice.isNotEmpty) {
      for (final platform in byDevice.keys) {
        final paths = byDevice[platform]![primaryDevice];
        if (paths != null && paths.isNotEmpty) return paths;
      }
    }

    // Curated devices only — prefer store-appropriate primary.
    final isIpad = store == 'ios-tablet' || store == 'ios/ipad';
    final preferredDevices = (platformHint == 'ios')
        ? (isIpad
            ? [
                'ipad_pro_129',
                'ipad_pro_11',
                'iphone16_pro_max',
                'iphone16_pro',
              ]
            : [
                'iphone16_pro_max',
                'iphone16_pro',
                'ipad_pro_129',
                'ipad_pro_11',
              ])
        : [
            'pixel9',
            'galaxy_s24',
          ];

    if (platformHint != null && byDevice.containsKey(platformHint)) {
      final devices = byDevice[platformHint]!;
      for (final name in preferredDevices) {
        if (devices.containsKey(name)) return devices[name]!;
      }
      final first = devices.values.first;
      if (first.isNotEmpty) return first;
    }

    // Fallback: first platform, first device (deterministic key order)
    final platforms = byDevice.keys.toList()..sort();
    for (final platform in platforms) {
      final devices = byDevice[platform]!;
      final names = devices.keys.toList()..sort();
      for (final name in names) {
        final paths = devices[name]!;
        if (paths.isNotEmpty) return paths;
      }
    }
    return [];
  }
}
