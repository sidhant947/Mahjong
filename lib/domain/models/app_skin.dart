import 'package:flutter/material.dart';

class AppSkin {
  const AppSkin({
    required this.id,
    required this.name,
    required this.bgGradient,
    required this.primaryColor,
    required this.accentColor,
    required this.surfaceColor,
    required this.headingColor,
    required this.subtextColor,
    required this.glowColor,
    required this.tileBaseGradient,
    required this.tileBaseHighlight,
    required this.tileBezelColors,
    required this.tileInnerBezelColor,
    required this.tileFaceGradient,
  });

  final String id;
  final String name;
  final List<Color> bgGradient;
  final Color primaryColor;
  final Color accentColor;
  final Color surfaceColor;
  final Color headingColor;
  final Color subtextColor;
  final Color glowColor;

  final List<Color> tileBaseGradient;
  final Color tileBaseHighlight;
  final List<Color> tileBezelColors;
  final Color tileInnerBezelColor;
  final List<Color> tileFaceGradient;

  Color get scaffoldBg => bgGradient.first;

  static const AppSkin jadeGarden = AppSkin(
    id: 'jade_garden',
    name: 'Jade Garden',
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
    glowColor: Color(0xFF2D8B7A),
    tileBaseGradient: [
      Color(0xFF2D8B7A),
      Color(0xFF1E6B5E),
      Color(0xFF134545),
    ],
    tileBaseHighlight: Color(0xFF80DFCD),
    tileBezelColors: [
      Color(0xE6A3C4BC),
      Color(0x995C9C8E),
      Color(0x662D8B7A),
    ],
    tileInnerBezelColor: Color(0x402D8B7A),
    tileFaceGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0xFFF5F9F8),
      Color(0xFFE8F2EF),
    ],
  );

  static const AppSkin pastelDusk = AppSkin(
    id: 'pastel_dusk',
    name: 'Pastel Dusk',
    bgGradient: [
      Color(0xFF2C243B),
      Color(0xFF1F182C),
      Color(0xFF150F1E),
    ],
    primaryColor: Color(0xFFC4B5FD),
    accentColor: Color(0xFFA78BFA),
    surfaceColor: Color(0xFF382E4A),
    headingColor: Color(0xFFF5F3FF),
    subtextColor: Color(0xFFDDD6FE),
    glowColor: Color(0xFFC4B5FD),
    tileBaseGradient: [
      Color(0xFF8B5CF6),
      Color(0xFF6D28D9),
      Color(0xFF4C1D95),
    ],
    tileBaseHighlight: Color(0xFFDDD6FE),
    tileBezelColors: [
      Color(0xE6C4B5FD),
      Color(0x99A78BFA),
      Color(0x668B5CF6),
    ],
    tileInnerBezelColor: Color(0x408B5CF6),
    tileFaceGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFFAF5FF),
      Color(0xFFF3E8FF),
      Color(0xFFE9D5FF),
    ],
  );

  static const AppSkin pastelSage = AppSkin(
    id: 'pastel_sage',
    name: 'Pastel Sage',
    bgGradient: [
      Color(0xFF1E2D27),
      Color(0xFF14201B),
      Color(0xFF0B1310),
    ],
    primaryColor: Color(0xFF86EFAC),
    accentColor: Color(0xFF4ADE80),
    surfaceColor: Color(0xFF273B33),
    headingColor: Color(0xFFF0FDF4),
    subtextColor: Color(0xFFBBF7D0),
    glowColor: Color(0xFF86EFAC),
    tileBaseGradient: [
      Color(0xFF22C55E),
      Color(0xFF15803D),
      Color(0xFF14532D),
    ],
    tileBaseHighlight: Color(0xFFBBF7D0),
    tileBezelColors: [
      Color(0xE686EFAC),
      Color(0x994ADE80),
      Color(0x6622C55E),
    ],
    tileInnerBezelColor: Color(0x4022C55E),
    tileFaceGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFF0FDF4),
      Color(0xFFDCFCE7),
      Color(0xFFBBF7D0),
    ],
  );

  static const AppSkin pastelRose = AppSkin(
    id: 'pastel_rose',
    name: 'Pastel Rose',
    bgGradient: [
      Color(0xFF36202B),
      Color(0xFF27151E),
      Color(0xFF190C13),
    ],
    primaryColor: Color(0xFFF472B6),
    accentColor: Color(0xFFE879F9),
    surfaceColor: Color(0xFF472A39),
    headingColor: Color(0xFFFDF2F8),
    subtextColor: Color(0xFFFBCFE8),
    glowColor: Color(0xFFF472B6),
    tileBaseGradient: [
      Color(0xFFEC4899),
      Color(0xFFBE185D),
      Color(0xFF831843),
    ],
    tileBaseHighlight: Color(0xFFFBCFE8),
    tileBezelColors: [
      Color(0xE6F472B6),
      Color(0x99E879F9),
      Color(0x66EC4899),
    ],
    tileInnerBezelColor: Color(0x40EC4899),
    tileFaceGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFFDF2F8),
      Color(0xFFFCE7F3),
      Color(0xFFFBCFE8),
    ],
  );

  static const AppSkin pastelTwilight = AppSkin(
    id: 'pastel_twilight',
    name: 'Pastel Twilight',
    bgGradient: [
      Color(0xFF1E293B),
      Color(0xFF151E2D),
      Color(0xFF0D131F),
    ],
    primaryColor: Color(0xFF38BDF8),
    accentColor: Color(0xFF7DD3FC),
    surfaceColor: Color(0xFF27354A),
    headingColor: Color(0xFFF0F9FF),
    subtextColor: Color(0xFFBAE6FD),
    glowColor: Color(0xFF38BDF8),
    tileBaseGradient: [
      Color(0xFF0284C7),
      Color(0xFF0369A1),
      Color(0xFF075985),
    ],
    tileBaseHighlight: Color(0xFFBAE6FD),
    tileBezelColors: [
      Color(0xE638BDF8),
      Color(0x997DD3FC),
      Color(0x660284C7),
    ],
    tileInnerBezelColor: Color(0x400284C7),
    tileFaceGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFF0F9FF),
      Color(0xFFE0F2FE),
      Color(0xFFBAE6FD),
    ],
  );

  static const AppSkin pastelAmber = AppSkin(
    id: 'pastel_amber',
    name: 'Pastel Amber',
    bgGradient: [
      Color(0xFF33251D),
      Color(0xFF241913),
      Color(0xFF170F0B),
    ],
    primaryColor: Color(0xFFFDE047),
    accentColor: Color(0xFFFACC15),
    surfaceColor: Color(0xFF423126),
    headingColor: Color(0xFFFEFCE8),
    subtextColor: Color(0xFFFEF08A),
    glowColor: Color(0xFFFDE047),
    tileBaseGradient: [
      Color(0xFFEAB308),
      Color(0xFFA16207),
      Color(0xFF713F12),
    ],
    tileBaseHighlight: Color(0xFFFEF08A),
    tileBezelColors: [
      Color(0xE6FDE047),
      Color(0x99FACC15),
      Color(0x66EAB308),
    ],
    tileInnerBezelColor: Color(0x40EAB308),
    tileFaceGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFFEFCE8),
      Color(0xFFFEF9C3),
      Color(0xFFFEF08A),
    ],
  );

  static const List<AppSkin> allSkins = [
    jadeGarden,
    pastelDusk,
    pastelSage,
    pastelRose,
    pastelTwilight,
    pastelAmber,
  ];

  static AppSkin fromId(String? id) {
    return allSkins.firstWhere(
      (skin) => skin.id == id,
      orElse: () => jadeGarden,
    );
  }
}
