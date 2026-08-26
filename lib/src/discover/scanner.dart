import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'models.dart';

/// Heuristic scan of `lib/` for Screen/Page widgets and common route patterns.
///
/// No device / emulator — discovers real Dart types for `GLINTRule` builders.
class ScreenScanner {
  ScreenScanner({
    required this.projectRoot,
    this.libRelative = 'lib',
  });

  final String projectRoot;
  final String libRelative;

  Future<List<DiscoveredScreen>> scan() async {
    final packageName = _readPackageName();
    if (packageName == null) {
      throw StateError('No package name in pubspec.yaml under $projectRoot');
    }

    final libDir = Directory(p.join(projectRoot, libRelative));
    if (!libDir.existsSync()) {
      throw StateError('No $libRelative/ directory in $projectRoot');
    }

    final byClass = <String, DiscoveredScreen>{};

    await for (final entity in libDir.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart') || entity.path.endsWith('.freezed.dart')) {
        continue;
      }
      final rel = p.relative(entity.path, from: libDir.path);
      if (rel.contains('${p.separator}generated${p.separator}')) continue;

      final content = await entity.readAsString();
      final importUri = 'package:$packageName/${rel.replaceAll(r'\', '/')}';

      for (final match in _widgetClassRe.allMatches(content)) {
        final className = match.group(1)!;
        if (_skipClass(className)) continue;
        final name = _slugFromClass(className);
        final hasConst = _hasConstConstructor(content, className);
        final score = _heuristicScore(className, rel);
        byClass.putIfAbsent(
          className,
          () => DiscoveredScreen(
            name: name,
            className: className,
            importUri: importUri,
            sourcePath: p.relative(entity.path, from: projectRoot),
            hasConstConstructor: hasConst,
            score: score,
            reason: 'Matched *Screen/*Page widget',
          ),
        );
      }

      // Routes that reference Widget constructors: HomeScreen( / const HomeScreen(
      for (final match in _routeCtorRe.allMatches(content)) {
        final className = match.group(1)!;
        if (_skipClass(className)) continue;
        if (byClass.containsKey(className)) continue;
        // May live in another file — still record with this import as hint;
        // prefer later if we find the class definition.
        byClass[className] = DiscoveredScreen(
          name: _slugFromClass(className),
          className: className,
          importUri: importUri,
          sourcePath: p.relative(entity.path, from: projectRoot),
          hasConstConstructor: match.group(0)!.contains('const '),
          score: 0.55,
          reason: 'Referenced in routes',
        );
      }
    }

    final list = byClass.values.toList()
      ..sort((a, b) {
        final c = b.score.compareTo(a.score);
        if (c != 0) return c;
        return a.name.compareTo(b.name);
      });
    return list;
  }

  String? _readPackageName() {
    final file = File(p.join(projectRoot, 'pubspec.yaml'));
    if (!file.existsSync()) return null;
    final yaml = loadYaml(file.readAsStringSync());
    if (yaml is YamlMap) return yaml['name'] as String?;
    return null;
  }

  static final _widgetClassRe = RegExp(
    r'class\s+(\w+(?:Screen|Page))\s+extends\s+(?:StatelessWidget|StatefulWidget|ConsumerWidget|HookWidget|HookConsumerWidget)\b',
  );

  static final _routeCtorRe = RegExp(
    r'(?:const\s+)?(\w+(?:Screen|Page))\s*\(',
  );

  static bool _skipClass(String className) {
    const skip = {
      'StatelessWidget',
      'StatefulWidget',
      'MaterialApp',
      'CupertinoApp',
      'MyApp',
      'App',
    };
    if (skip.contains(className)) return true;
    if (className.startsWith('_')) return true;
    return false;
  }

  static String _slugFromClass(String className) {
    var s = className;
    if (s.endsWith('Screen')) {
      s = s.substring(0, s.length - 'Screen'.length);
    } else if (s.endsWith('Page')) {
      s = s.substring(0, s.length - 'Page'.length);
    }
    // CamelCase → snake_case
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      final isUpper = ch.toUpperCase() == ch && ch.toLowerCase() != ch;
      if (isUpper && i > 0) buf.write('_');
      buf.write(ch.toLowerCase());
    }
    final out = buf.toString();
    return out.isEmpty ? className.toLowerCase() : out;
  }

  static bool _hasConstConstructor(String source, String className) {
    final re = RegExp('const\\s+$className\\s*\\(');
    return re.hasMatch(source);
  }

  static double _heuristicScore(String className, String relPath) {
    final lower = className.toLowerCase();
    var score = 0.5;
    const boost = [
      'home',
      'main',
      'dashboard',
      'feed',
      'explore',
      'feature',
      'onboarding',
      'welcome',
      'profile',
      'settings',
      'empty',
      'library',
      'inbox',
    ];
    const demote = [
      'debug',
      'test',
      'stub',
      'dummy',
      'login',
      'signup',
      'signin',
      'auth',
      'splash',
      'loading',
      'error',
      'permission',
    ];
    for (final b in boost) {
      if (lower.contains(b)) score += 0.12;
    }
    for (final d in demote) {
      if (lower.contains(d)) score -= 0.15;
    }
    if (relPath.toLowerCase().contains('screen')) score += 0.05;
    if (score < 0.1) score = 0.1;
    if (score > 0.95) score = 0.95;
    return score;
  }
}
