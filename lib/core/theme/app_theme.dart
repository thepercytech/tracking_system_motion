import 'package:flutter/material.dart';

/// Central place for the app's visual identity.
///
/// Keep both themes in sync when tweaking colors/typography so light and
/// dark mode never drift apart.
abstract final class AppTheme {
  static const Color _seedColor = Colors.teal;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      );
}
