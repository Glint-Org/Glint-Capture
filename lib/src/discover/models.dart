/// Models for Flutter screen discovery (AI / heuristic → GLINTRule codegen).
library;

class DiscoveredScreen {
  const DiscoveredScreen({
    required this.name,
    required this.className,
    required this.importUri,
    required this.sourcePath,
    this.hasConstConstructor = true,
    this.score = 0.5,
    this.reason = '',
  });

  /// Rule / file slug, e.g. `home`.
  final String name;

  /// Dart class, e.g. `HomeScreen`.
  final String className;

  /// `package:my_app/screens/home_screen.dart`
  final String importUri;

  /// Absolute or project-relative file path.
  final String sourcePath;

  final bool hasConstConstructor;
  final double score;
  final String reason;

  DiscoveredScreen copyWith({
    String? name,
    String? className,
    String? importUri,
    String? sourcePath,
    bool? hasConstConstructor,
    double? score,
    String? reason,
  }) {
    return DiscoveredScreen(
      name: name ?? this.name,
      className: className ?? this.className,
      importUri: importUri ?? this.importUri,
      sourcePath: sourcePath ?? this.sourcePath,
      hasConstConstructor: hasConstConstructor ?? this.hasConstConstructor,
      score: score ?? this.score,
      reason: reason ?? this.reason,
    );
  }

  Map<String, Object?> toJson() => {
        'name': name,
        'className': className,
        'importUri': importUri,
        'sourcePath': sourcePath,
        'hasConstConstructor': hasConstConstructor,
        'score': score,
        'reason': reason,
      };
}
