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
  /// │   ├── pixel7/
  /// │   │   ├── home.png
  /// │   │   └── profile.png
  /// │   └── galaxy_s23/
  /// │       └── ...
  /// └── ios/
  ///     └── ...
  /// ```
  static GLINTSession fromDirectory({
    required String outputDir,
    required String appName,
    String? tagline,
    String store = 'play',
  }) {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      throw StateError('Output directory does not exist: $outputDir');
    }

    final screens = <String>[];
    for (final platformDir in dir.listSync().whereType<Directory>()) {
      for (final deviceDir in platformDir.listSync().whereType<Directory>()) {
        for (final file in deviceDir.listSync().whereType<File>()) {
          if (p.extension(file.path).toLowerCase() == '.png') {
            screens.add(
              '${p.basename(platformDir.path)}/${p.basename(deviceDir.path)}/${p.basename(file.path)}',
            );
          }
        }
      }
    }
    screens.sort();

    return GLINTSession(
      app: appName,
      tagline: tagline,
      screens: screens,
      store: store,
    );
  }
}
