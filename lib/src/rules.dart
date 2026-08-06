import 'package:flutter/widgets.dart';

import 'pump.dart';

/// A declarative screenshot capture rule.
sealed class TelorRule {
  const TelorRule({required this.name});

  final String name;

  /// Capture a single screen widget.
  factory TelorRule.screen({
    required String name,
    required WidgetBuilder builder,
    TelorPumpFn? pump,
    Widget? wrapper,
  }) = TelorScreenRule;

  /// Expand a built-in template into multiple screen rules.
  factory TelorRule.template({
    required String name,
    required List<String> screens,
    Map<String, WidgetBuilder>? builders,
  }) = TelorTemplateRule;
}

class TelorScreenRule extends TelorRule {
  TelorScreenRule({
    required super.name,
    required this.builder,
    TelorPumpFn? pump,
    this.wrapper,
  }) : pump = pump ?? TelorPump.settle;

  final WidgetBuilder builder;
  final TelorPumpFn pump;
  final Widget? wrapper;
}

class TelorTemplateRule extends TelorRule {
  const TelorTemplateRule({
    required super.name,
    required this.screens,
    this.builders,
  });

  final List<String> screens;
  final Map<String, WidgetBuilder>? builders;
}

/// Built-in template presets that map to common store screenshot flows.
abstract final class TelorTemplates {
  static const onboardingFlow = ['welcome', 'features', 'permissions', 'signup', 'home'];

  static const featureHighlights = ['home', 'search', 'detail', 'profile', 'settings'];

  static const settingsProfile = ['home', 'settings', 'profile', 'notifications', 'about'];

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
List<TelorScreenRule> expandRules(List<TelorRule> rules) {
  final expanded = <TelorScreenRule>[];
  for (final rule in rules) {
    switch (rule) {
      case TelorScreenRule():
        expanded.add(rule);
      case TelorTemplateRule template:
        final names = template.screens.isNotEmpty
            ? template.screens
            : TelorTemplates.resolve(template.name);
        for (final screenName in names) {
          final builder = template.builders?[screenName];
          if (builder != null) {
            expanded.add(TelorScreenRule(name: screenName, builder: builder));
          }
        }
    }
  }
  return expanded;
}
