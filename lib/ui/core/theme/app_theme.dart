import 'package:flutter/material.dart';
import 'package:mahjong/domain/models/app_skin.dart';

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

  static ThemeData fromSkin(AppSkin skin) {
    final isLight = skin.headingColor.computeLuminance() < skin.scaffoldBg.computeLuminance();
    return ThemeData(
      fontFamily: 'BebasNeue',
      pageTransitionsTheme: _noTransitionTheme,
      brightness: isLight ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: skin.scaffoldBg,
      primaryColor: skin.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: skin.primaryColor,
        brightness: isLight ? Brightness.light : Brightness.dark,
        surface: skin.surfaceColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'BebasNeue',
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: skin.headingColor,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(color: skin.headingColor),
      ),
      dividerTheme: DividerThemeData(
        color: skin.surfaceColor,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, letterSpacing: -0.5),
        displayMedium: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, letterSpacing: -0.5),
        displaySmall: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, letterSpacing: -0.5),
        headlineSmall: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, letterSpacing: -0.5),
        titleLarge: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, letterSpacing: 0.5),
        titleMedium: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, letterSpacing: 0.5),
        bodyLarge: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontFamily: 'BebasNeue', color: skin.subtextColor, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(fontFamily: 'BebasNeue', color: skin.headingColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get dark => fromSkin(AppSkin.jadeGarden);
}
