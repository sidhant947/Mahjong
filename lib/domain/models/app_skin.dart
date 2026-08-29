import 'package:flutter/material.dart';

class AppSkin {
  const AppSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.previewColor,
    required this.bgGradient,
    required this.primaryColor,
    required this.accentColor,
    required this.surfaceColor,
    required this.headingColor,
    required this.subtextColor,
    required this.scaffoldBg,
    required this.glowColor,
  });

  final String id;
  final String name;
  final String description;
  final Color previewColor;
  final List<Color> bgGradient;
  final Color primaryColor;
  final Color accentColor;
  final Color surfaceColor;
  final Color headingColor;
  final Color subtextColor;
  final Color scaffoldBg;
  final Color glowColor;

  static const AppSkin jadeGarden = AppSkin(
    id: 'jade_garden',
    name: 'Jade Garden',
    description: 'Classic emerald green mahjong aesthetic',
    previewColor: Color(0xFF2D8B7A),
    bgGradient: [
      Color(0xFF1A5C5C),
      Color(0xFF0F3838),
      Color(0xFF092424),
    ],
    primaryColor: Color(0xFF2D8B7A),
    accentColor: Color(0xFF3D7A6B),
    surfaceColor: Color(0xFF134545),
    headingColor: Color(0xFFF5F5F0),
    subtextColor: Color(0xFFA3C4BC),
    scaffoldBg: Color(0xFF1A5C5C),
    glowColor: Color(0xFF2D8B7A),
  );

  static const AppSkin midnightIndigo = AppSkin(
    id: 'midnight_indigo',
    name: 'Midnight Indigo',
    description: 'Deep celestial blue and cosmic tones',
    previewColor: Color(0xFF3B82F6),
    bgGradient: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
      Color(0xFF020617),
    ],
    primaryColor: Color(0xFF3B82F6),
    accentColor: Color(0xFF2563EB),
    surfaceColor: Color(0xFF1E293B),
    headingColor: Color(0xFFF8FAFC),
    subtextColor: Color(0xFF94A3B8),
    scaffoldBg: Color(0xFF0F172A),
    glowColor: Color(0xFF3B82F6),
  );

  static const AppSkin crimsonDynasty = AppSkin(
    id: 'crimson_dynasty',
    name: 'Crimson Dynasty',
    description: 'Imperial red and golden accents',
    previewColor: Color(0xFFDC2626),
    bgGradient: [
      Color(0xFF5A1414),
      Color(0xFF3B0C0C),
      Color(0xFF200505),
    ],
    primaryColor: Color(0xFFDC2626),
    accentColor: Color(0xFFB91C1C),
    surfaceColor: Color(0xFF4A1010),
    headingColor: Color(0xFFFFF1F2),
    subtextColor: Color(0xFFFECDD3),
    scaffoldBg: Color(0xFF3B0C0C),
    glowColor: Color(0xFFDC2626),
  );

  static const AppSkin sakuraBlossom = AppSkin(
    id: 'sakura_blossom',
    name: 'Sakura Blossom',
    description: 'Delicate floral pink and lavender haze',
    previewColor: Color(0xFFEC4899),
    bgGradient: [
      Color(0xFF4C1D3E),
      Color(0xFF321229),
      Color(0xFF1F0819),
    ],
    primaryColor: Color(0xFFEC4899),
    accentColor: Color(0xFFDB2777),
    surfaceColor: Color(0xFF3B1630),
    headingColor: Color(0xFFFDF2F8),
    subtextColor: Color(0xFFFBCFE8),
    scaffoldBg: Color(0xFF321229),
    glowColor: Color(0xFFEC4899),
  );

  static const AppSkin obsidianCyber = AppSkin(
    id: 'obsidian_cyber',
    name: 'Obsidian Cyber',
    description: 'Dark stealth carbon with neon teal highlights',
    previewColor: Color(0xFF14B8A6),
    bgGradient: [
      Color(0xFF18181B),
      Color(0xFF09090B),
      Color(0xFF000000),
    ],
    primaryColor: Color(0xFF14B8A6),
    accentColor: Color(0xFF0D9488),
    surfaceColor: Color(0xFF27272A),
    headingColor: Color(0xFFFAFAFA),
    subtextColor: Color(0xFFA1A1AA),
    scaffoldBg: Color(0xFF09090B),
    glowColor: Color(0xFF14B8A6),
  );

  static const AppSkin amberSunset = AppSkin(
    id: 'amber_sunset',
    name: 'Amber Sunset',
    description: 'Warm glowing terracotta and dusk amber',
    previewColor: Color(0xFFF59E0B),
    bgGradient: [
      Color(0xFF592D0D),
      Color(0xFF3D1E08),
      Color(0xFF261104),
    ],
    primaryColor: Color(0xFFF59E0B),
    accentColor: Color(0xFFD97706),
    surfaceColor: Color(0xFF4D250A),
    headingColor: Color(0xFFFFFBEB),
    subtextColor: Color(0xFFFDE68A),
    scaffoldBg: Color(0xFF3D1E08),
    glowColor: Color(0xFFF59E0B),
  );

  static const AppSkin mysticAmethyst = AppSkin(
    id: 'mystic_amethyst',
    name: 'Mystic Amethyst',
    description: 'Royal purple velvet and enchanting quartz',
    previewColor: Color(0xFF9333EA),
    bgGradient: [
      Color(0xFF3B1A59),
      Color(0xFF250F3B),
      Color(0xFF140721),
    ],
    primaryColor: Color(0xFF9333EA),
    accentColor: Color(0xFF7E22CE),
    surfaceColor: Color(0xFF2F1447),
    headingColor: Color(0xFFFAF5FF),
    subtextColor: Color(0xFFE9D5FF),
    scaffoldBg: Color(0xFF250F3B),
    glowColor: Color(0xFF9333EA),
  );

  static const AppSkin deepOcean = AppSkin(
    id: 'deep_ocean',
    name: 'Deep Ocean',
    description: 'Submerged oceanic abyss and turquoise glow',
    previewColor: Color(0xFF06B6D4),
    bgGradient: [
      Color(0xFF0E4354),
      Color(0xFF082B37),
      Color(0xFF04171E),
    ],
    primaryColor: Color(0xFF06B6D4),
    accentColor: Color(0xFF0891B2),
    surfaceColor: Color(0xFF0B3644),
    headingColor: Color(0xFFECFEFF),
    subtextColor: Color(0xFFA5F3FC),
    scaffoldBg: Color(0xFF082B37),
    glowColor: Color(0xFF06B6D4),
  );

  static const AppSkin autumnForest = AppSkin(
    id: 'autumn_forest',
    name: 'Autumn Forest',
    description: 'Earthy moss, fallen leaves, and rustic woods',
    previewColor: Color(0xFF84CC16),
    bgGradient: [
      Color(0xFF2C3E14),
      Color(0xFF1E2B0C),
      Color(0xFF111906),
    ],
    primaryColor: Color(0xFF65A30D),
    accentColor: Color(0xFF4D7C0F),
    surfaceColor: Color(0xFF243310),
    headingColor: Color(0xFFF7FEE7),
    subtextColor: Color(0xFFD9F99D),
    scaffoldBg: Color(0xFF1E2B0C),
    glowColor: Color(0xFF84CC16),
  );

  static const AppSkin monoMinimal = AppSkin(
    id: 'mono_minimal',
    name: 'Mono Minimal',
    description: 'Sleek neutral grayscale and titanium accents',
    previewColor: Color(0xFFE2E8F0),
    bgGradient: [
      Color(0xFF2B2D33),
      Color(0xFF1B1C20),
      Color(0xFF111215),
    ],
    primaryColor: Color(0xFF64748B),
    accentColor: Color(0xFF475569),
    surfaceColor: Color(0xFF24262C),
    headingColor: Color(0xFFF8FAFC),
    subtextColor: Color(0xFFCBD5E1),
    scaffoldBg: Color(0xFF1B1C20),
    glowColor: Color(0xFF94A3B8),
  );

  static const List<AppSkin> allSkins = [
    jadeGarden,
    midnightIndigo,
    crimsonDynasty,
    sakuraBlossom,
    obsidianCyber,
    amberSunset,
    mysticAmethyst,
    deepOcean,
    autumnForest,
    monoMinimal,
  ];

  static AppSkin fromId(String? id) {
    return allSkins.firstWhere(
      (skin) => skin.id == id,
      orElse: () => jadeGarden,
    );
  }
}
