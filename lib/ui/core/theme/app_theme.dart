import 'package:flutter/material.dart';

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppTheme {
  AppTheme._();

  static const _noTransitionTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _NoTransitionBuilder(),
      TargetPlatform.iOS: _NoTransitionBuilder(),
      TargetPlatform.linux: _NoTransitionBuilder(),
      TargetPlatform.macOS: _NoTransitionBuilder(),
      TargetPlatform.windows: _NoTransitionBuilder(),
      TargetPlatform.fuchsia: _NoTransitionBuilder(),
    },
  );

  static ThemeData get dark => ThemeData(
    fontFamily: 'BebasNeue',
    pageTransitionsTheme: _noTransitionTheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121318),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFAF6EE),
        letterSpacing: 1.0,
      ),
      iconTheme: IconThemeData(color: Color(0xFFFAF6EE)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF232530),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineSmall: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      titleLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: 0.5),
      titleMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: 0.5),
      bodyLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF8E92A6), fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), fontWeight: FontWeight.bold),
    ),
  );
}
