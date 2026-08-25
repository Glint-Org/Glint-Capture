import 'package:flutter/widgets.dart';

import 'pump.dart';

/// Wraps the screen under test (e.g. add a [Navigator], [Scaffold], provider).
typedef GLINTWrapper = Widget Function(Widget child);

/// A declarative screenshot capture rule.
sealed class GLINTRule {
  const GLINTRule({required this.name});

  final String name;

  /// Capture a single screen or overlay widget tree.
  ///
  /// Return any design you built: pages, dialogs, sheets, drawers, custom
  /// painters. For modal UI, either compose it in the tree or open it in [pump]:
  ///
  /// ```dart
  /// GLINTRule.screen(
  ///   name: 'confirm',
  ///   builder: (context) => const HomeScreen(),
  ///   pump: (tester) async {
  ///     await tester.tap(find.text('Delete'));
  ///     await tester.pumpAndSettle();
  ///   },
  /// )
  /// ```
  factory GLINTRule.screen({
    required String name,
    required WidgetBuilder builder,
    GLINTPumpFn? pump,
    GLINTWrapper? wrapper,
  }) = GLINTScreenRule;

  /// Expand a built-in template into multiple screen rules.
  factory GLINTRule.template({
    required String name,
    required List<String> screens,
    Map<String, WidgetBuilder>? builders,
  }) = GLINTTemplateRule;
}

class GLINTScreenRule extends GLINTRule {
  GLINTScreenRule({
    required super.name,
    required this.builder,
    GLINTPumpFn? pump,
    this.wrapper,
  }) : pump = pump ?? GLINTPump.settle;

  final WidgetBuilder builder;
  final GLINTPumpFn pump;
  final GLINTWrapper? wrapper;
}

class GLINTTemplateRule extends GLINTRule {
  const GLINTTemplateRule({
    required super.name,
    required this.screens,
    this.builders,
  });

  final List<String> screens;
  final Map<String, WidgetBuilder>? builders;
}

/// Built-in template presets that map to common store screenshot flows.
abstract final class GLINTTemplates {
  static const onboardingFlow = [
    'welcome',
    'features',
    'permissions',
    'signup',
    'home',
  ];

  static const featureHighlights = [
    'home',
    'search',
    'detail',
    'profile',
    'settings',
  ];

  static const settingsProfile = [
    'home',
    'settings',
    'profile',
    'notifications',
    'about',
  ];

  /// Resolves a template name to screen identifiers.
  static List<String> resolve(String templateName) {
    return switch (templateName) {
      'onboarding_flow' => onboardingFlow,
      'feature_highlights' => featureHighlights,
      'settings_profile' => settingsProfile,
      _ => throw ArgumentError('Unknown template: $templateName'),
    };
  }
}

/// Expands template rules into concrete screen rules using provided builders.
List<GLINTScreenRule> expandRules(List<GLINTRule> rules) {
  final expanded = <GLINTScreenRule>[];
  for (final rule in rules) {
    switch (rule) {
      case GLINTScreenRule():
        expanded.add(rule);
      case GLINTTemplateRule template:
        final names = template.screens.isNotEmpty
            ? template.screens
            : GLINTTemplates.resolve(template.name);
        for (final screenName in names) {
          final builder = template.builders?[screenName];
          if (builder != null) {
            expanded.add(GLINTScreenRule(name: screenName, builder: builder));
          }
        }
    }
  }
  return expanded;
}
