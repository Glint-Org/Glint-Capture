import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Writes a Telor session JSON file compatible with Telor-Web and Telor-View.
class TelorSession {
  TelorSession({
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

  String toJsonString({bool pretty = true}) =>
      pretty ? const JsonEncoder.withIndent('  ').convert(toJson()) : jsonEncode(toJson());

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

  /// Build session from PNG files in [outputDir] (filenames only, not full paths).
  static TelorSession fromDirectory({
    required String outputDir,
    required String appName,
    String? tagline,
    String store = 'play',
  }) {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      throw StateError('Output directory does not exist: $outputDir');
    }

    final screens = dir
        .listSync()
        .whereType<File>()
        .where((f) => p.extension(f.path).toLowerCase() == '.png')
        .map((f) => p.basename(f.path))
        .toList()
      ..sort();

    return TelorSession(
      app: appName,
      tagline: tagline,
      screens: screens,
      store: store,
    );
  }
}

/// Copies golden PNG files from [sourceDir] to [outputDir] with normalized names.
Future<List<String>> copyGoldensToOutput({
  required String sourceDir,
  required String outputDir,
  String prefix = '',
}) async {
  final source = Directory(sourceDir);
  final dest = Directory(outputDir);
  if (!await dest.exists()) {
    await dest.create(recursive: true);
  }

  final copied = <String>[];
  if (!await source.exists()) return copied;

  for (final entity in source.listSync(recursive: true)) {
    if (entity is! File) continue;
    if (p.extension(entity.path).toLowerCase() != '.png') continue;

    final baseName = p.basename(entity.path);
    final destName = prefix.isEmpty ? baseName : '${prefix}_$baseName';
    final destPath = p.join(outputDir, destName);
    await entity.copy(destPath);
    copied.add(destName);
  }

  copied.sort();
  return copied;
}
