import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong/domain/models/app_skin.dart';
import 'package:mahjong/domain/models/mahjong_tile.dart';
import 'package:mahjong/ui/providers.dart';

class CustomMahjongTilePainter extends CustomPainter {
  const CustomMahjongTilePainter({
    required this.typeIndex,
    required this.value,
    required this.isFree,
    required this.isSelected,
    required this.isHinted,
    this.hintProgress = 0.0,
    this.skin = AppSkin.jadeGarden,
    this.useTraditional = false,
    this.dimLowerTiles = true,
  });

  final int typeIndex;
  final int value;
  final bool isFree;
  final bool isSelected;
  final bool isHinted;
  final double hintProgress;
  final bool useTraditional;
  final bool dimLowerTiles;
  final AppSkin skin;

  static const _fruits = ['🍎', '🍌', '🍇', '🍊', '🍓', '🍍', '🍑', '🍒', '🍉'];
  static const _animals = [
    '🦚',
    '🐼',
    '🐯',
    '🦁',
    '🦊',
    '🐸',
    '🐵',
    '🐨',
    '🐰',
  ];
  static const _foods = ['🍕', '🍩', '🍔', '🍟', '🍰', '🍦', '🍣', '🌮', '🧁'];
  static const _winds = ['🧭', '⛵', '🚀', '🛸'];
  static const _dragons = ['🐲', '🐉', '⭐'];

  String _getEmoji(TileType type, int val) {
    switch (type) {
      case TileType.character:
        return _fruits[(val - 1) % 9];
      case TileType.bamboo:
        return _animals[(val - 1) % 9];
      case TileType.rod:
        return _foods[(val - 1) % 9];
      case TileType.season:
        return '🌸';
      case TileType.wind:
        return _winds[val % 4];
      case TileType.dragon:
        return _dragons[val % 3];
      case TileType.flower:
        return '🌺';
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;

    final shiftY = (h * 0.11).clamp(4.0, 10.0);
    final shiftX = (shiftY * 0.32).clamp(1.5, 3.5);

    final faceW = w - shiftX;
    final faceH = h - shiftY;
    final r = faceW * 0.15;

    final shadowBlur = isSelected ? 10.0 : (shiftY * 0.45).clamp(2.5, 6.0);
    final shadowColor = isSelected
        ? const Color(0x35000000)
        : (isFree || !dimLowerTiles
              ? const Color(0x3E000000)
              : const Color(0x20000000));

    final dropShadowRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        shiftX + (isSelected ? 1.5 : 0.8),
        shiftY + (isSelected ? 9.5 : 2.2),
        faceW,
        faceH,
      ),
      Radius.circular(r * (isSelected ? 1.15 : 1.05)),
    );
    final dropShadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);
    canvas.drawRRect(dropShadowRRect, dropShadowPaint);

    if (isSelected) {
      final warmGlowPaint = Paint()
        ..color = const Color(0x26FFB300)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawRRect(dropShadowRRect, warmGlowPaint);
    }

    if (!isSelected) {
      final contactShadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(shiftX + 0.4, shiftY + 1.0, faceW, faceH),
        Radius.circular(r),
      );
      final contactShadowPaint = Paint()
        ..color = shadowColor.withValues(alpha: shadowColor.a * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      canvas.drawRRect(contactShadowRRect, contactShadowPaint);
    }

    final shouldDim = !isFree && dimLowerTiles;

    final baseColors = shouldDim
        ? const [
            Color(0xFF8E887D),
            Color(0xFF7F7A70),
            Color(0xFF6F6A61),
          ]
        : const [
            Color(0xFFEDE8DC),
            Color(0xFFE2DCCF),
            Color(0xFFD5CEBF),
          ];

    final baseShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: baseColors,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final basePaint = Paint()..shader = baseShader;

    final stepCount = (shiftY / 0.5).round().clamp(8, 20);
    for (int i = stepCount; i >= 1; i--) {
      final t = i / stepCount;
      final curX = shiftX * t;
      final curY = shiftY * t;
      final sliceRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(curX, curY, faceW, faceH),
        Radius.circular(r),
      );
      canvas.drawRRect(sliceRRect, basePaint);
    }

    final faceRect = Rect.fromLTWH(0, 0, faceW, faceH);
    final faceRRect = RRect.fromRectAndRadius(faceRect, Radius.circular(r));

    final faceColors = isSelected
        ? const [Color(0xFFFFFDF2), Color(0xFFFFFBE8), Color(0xFFFFF6D8)]
        : const [Color(0xFFFAF7F0), Color(0xFFF6F3EB), Color(0xFFEFECE2)];

    final facePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: faceColors,
      ).createShader(faceRect);
    canvas.drawRRect(faceRRect, facePaint);

    canvas.save();
    canvas.clipRRect(faceRRect);

    final bevelColors = isSelected
        ? const [
            Color(0xFFFFFDFA),
            Color(0xCCFFE082),
            Color(0x00FFFFFF),
            Color(0x40C5BEB0),
            Color(0xFFD8D2C5),
          ]
        : const [
            Color(0xCCFFFFFF),
            Color(0x66FFFFFF),
            Color(0x00FFFFFF),
            Color(0x40C5BEB0),
            Color(0xFFD8D2C5),
          ];

    final bevelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: bevelColors,
        stops: const [0.0, 0.22, 0.45, 0.72, 1.0],
      ).createShader(faceRect);
    canvas.drawRRect(faceRRect, bevelPaint);

    final rimPath = Path()
      ..moveTo(0, r * 1.2)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(faceW - r * 0.8, 0);
    final rimPaint = Paint()
      ..color = isSelected
          ? const Color(0xE6FFE082)
          : (shouldDim ? const Color(0x35FFFFFF) : const Color(0xE6FFFFFF))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(rimPath, rimPaint);

    final sheenPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment(-1.0, -1.0),
        end: Alignment(0.7, 0.7),
        colors: [Color(0x2EFFFFFF), Color(0x14FFFFFF), Color(0x00FFFFFF)],
        stops: [0.0, 0.35, 0.65],
      ).createShader(faceRect);
    canvas.drawRRect(faceRRect, sheenPaint);

    final glossPath = Path()
      ..moveTo(faceW * 0.12, faceH * 0.05)
      ..quadraticBezierTo(
        faceW * 0.5,
        faceH * 0.025,
        faceW * 0.88,
        faceH * 0.05,
      )
      ..quadraticBezierTo(
        faceW * 0.5,
        faceH * 0.075,
        faceW * 0.12,
        faceH * 0.05,
      );
    canvas.drawPath(glossPath, Paint()..color = const Color(0x33FFFFFF));

    if (isHinted) {
      final shimmerCenter = -0.6 + 2.2 * hintProgress;
      final shimmerPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment(shimmerCenter - 0.35, shimmerCenter - 0.35),
          end: Alignment(shimmerCenter + 0.35, shimmerCenter + 0.35),
          colors: const [
            Color(0x00FFFFFF),
            Color(0x55FFFFFF),
            Color(0x00FFFFFF),
          ],
        ).createShader(faceRect);
      canvas.drawRRect(faceRRect, shimmerPaint);
    }

    canvas.restore();

    final type = TileType.values[typeIndex];
    if (useTraditional) {
      _paintTraditionalTile(canvas, Size(faceW, faceH), type, value, faceH);
    } else {
      final emoji = _getEmoji(type, value);
      final fontSize = faceH * 0.54;
      if (fontSize > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: emoji,
            style: TextStyle(fontSize: fontSize),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final emojiOffset = Offset(
          (faceW - tp.width) / 2,
          (faceH - tp.height) / 2,
        );

        tp.paint(canvas, emojiOffset);
        tp.dispose();
      }
    }

    if (isHinted) {
      final auraRadius = 3.0 + 4.5 * hintProgress;
      final auraStroke = 2.2 + 1.8 * hintProgress;
      final auraAlpha = 0.4 + 0.45 * hintProgress;

      final hintAura = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = auraStroke
        ..color = const Color(0xFF00E676).withValues(alpha: auraAlpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, auraRadius);
      canvas.drawRRect(faceRRect, hintAura);

      final hintBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00E676), Color(0xFF40C4FF), Color(0xFFFFD740)],
        ).createShader(faceRect);
      canvas.drawRRect(faceRRect, hintBorder);

      final hintWash = Paint()
        ..color = const Color(
          0xFF00E676,
        ).withValues(alpha: 0.12 * hintProgress + 0.06);
      canvas.drawRRect(faceRRect, hintWash);
    }

    if (shouldDim) {
      final baseRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(shiftX, shiftY, faceW, faceH),
        Radius.circular(r),
      );
      final fullTilePath = Path()
        ..addRRect(faceRRect)
        ..addRRect(baseRRect);

      final multiplyPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..blendMode = BlendMode.multiply;
      canvas.drawPath(fullTilePath, multiplyPaint);

      final coolSlatePaint = Paint()..color = const Color(0x1F334155);
      canvas.drawPath(fullTilePath, coolSlatePaint);
    }
  }

  void _paintTraditionalTile(
    Canvas canvas,
    Size size,
    TileType type,
    int val,
    double faceHeight,
  ) {
    switch (type) {
      case TileType.character:
        _paintCharacterTile(canvas, size, val, faceHeight);
      case TileType.bamboo:
        _paintBambooTile(canvas, size, val, faceHeight);
      case TileType.rod:
        _paintRodTile(canvas, size, val, faceHeight);
      case TileType.wind:
        _paintWindTile(canvas, size, val, faceHeight);
      case TileType.dragon:
        _paintDragonTile(canvas, size, val, faceHeight);
      case TileType.flower:
        _paintFlowerTile(canvas, size, val, faceHeight);
      case TileType.season:
        _paintSeasonTile(canvas, size, val, faceHeight);
    }
  }

  void _paintCharacterTile(
    Canvas canvas,
    Size size,
    int val,
    double faceHeight,
  ) {
    const numerals = ['一', '二', '三', '四', '五', '六', '七', '八', '九'];
    final numStr = numerals[(val - 1).clamp(0, 8)];
    final textSpan = TextSpan(
      style: TextStyle(
        fontSize: faceHeight * 0.32,
        fontWeight: FontWeight.w900,
        height: 1.05,
      ),
      children: [
        TextSpan(
          text: '$numStr\n',
          style: const TextStyle(color: Color(0xFF1D4ED8)),
        ),
        const TextSpan(
          text: '萬',
          style: TextStyle(color: Color(0xFFDC2626)),
        ),
      ],
    );
    final tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2),
    );
    tp.dispose();
  }

  void _paintWindTile(Canvas canvas, Size size, int val, double faceHeight) {
    const winds = ['東', '南', '西', '北'];
    final char = winds[val.clamp(0, 3)];
    final tp = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          fontSize: faceHeight * 0.52,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1E293B),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2),
    );
    tp.dispose();
  }

  void _paintDragonTile(Canvas canvas, Size size, int val, double faceHeight) {
    const chars = ['中', '發', '白'];
    const colors = [Color(0xFFDC2626), Color(0xFF15803D), Color(0xFF1D4ED8)];
    final idx = val.clamp(0, 2);
    final tp = TextPainter(
      text: TextSpan(
        text: chars[idx],
        style: TextStyle(
          fontSize: faceHeight * 0.52,
          fontWeight: FontWeight.w900,
          color: colors[idx],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2),
    );
    tp.dispose();
  }

  void _paintSeasonTile(Canvas canvas, Size size, int val, double faceHeight) {
    const seasons = ['春', '夏', '秋', '冬'];
    final idx = val.clamp(0, 3);
    final indexTp = TextPainter(
      text: TextSpan(
        text: '${idx + 1}',
        style: TextStyle(
          fontSize: faceHeight * 0.16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFDC2626),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    indexTp.paint(canvas, Offset(size.width * 0.1, faceHeight * 0.08));
    indexTp.dispose();

    final tp = TextPainter(
      text: TextSpan(
        text: seasons[idx],
        style: TextStyle(
          fontSize: faceHeight * 0.44,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFDC2626),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2),
    );
    tp.dispose();
  }

  void _paintFlowerTile(Canvas canvas, Size size, int val, double faceHeight) {
    const flowers = ['梅', '蘭', '竹', '菊'];
    final idx = val.clamp(0, 3);
    final indexTp = TextPainter(
      text: TextSpan(
        text: '${idx + 1}',
        style: TextStyle(
          fontSize: faceHeight * 0.16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF15803D),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    indexTp.paint(canvas, Offset(size.width * 0.1, faceHeight * 0.08));
    indexTp.dispose();

    final tp = TextPainter(
      text: TextSpan(
        text: flowers[idx],
        style: TextStyle(
          fontSize: faceHeight * 0.44,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF15803D),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2),
    );
    tp.dispose();
  }

  void _drawDot(
    Canvas canvas,
    Offset center,
    double radius,
    Color outerColor, [
    Color? innerColor,
  ]) {
    final outerPaint = Paint()..color = outerColor;
    canvas.drawCircle(center, radius, outerPaint);
    final innerPaint = Paint()
      ..color = innerColor ?? Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(center, radius * 0.45, innerPaint);
    final centerPaint = Paint()..color = outerColor;
    canvas.drawCircle(center, radius * 0.2, centerPaint);
  }

  void _paintRodTile(Canvas canvas, Size size, int val, double faceHeight) {
    final w = size.width;
    final h = faceHeight;
    final cx = w / 2;
    final cy = h / 2;

    const green = Color(0xFF15803D);
    const red = Color(0xFFDC2626);
    const blue = Color(0xFF1D4ED8);

    switch (val) {
      case 1:
        _drawDot(canvas, Offset(cx, cy), w * 0.28, green, red);
      case 2:
        final r = w * 0.16;
        _drawDot(canvas, Offset(cx, cy - h * 0.22), r, green);
        _drawDot(canvas, Offset(cx, cy + h * 0.22), r, blue);
      case 3:
        final r = w * 0.13;
        _drawDot(canvas, Offset(cx - w * 0.24, cy - h * 0.24), r, blue);
        _drawDot(canvas, Offset(cx, cy), r, red);
        _drawDot(canvas, Offset(cx + w * 0.24, cy + h * 0.24), r, green);
      case 4:
        final r = w * 0.14;
        _drawDot(canvas, Offset(cx - w * 0.22, cy - h * 0.22), r, blue);
        _drawDot(canvas, Offset(cx + w * 0.22, cy - h * 0.22), r, green);
        _drawDot(canvas, Offset(cx - w * 0.22, cy + h * 0.22), r, green);
        _drawDot(canvas, Offset(cx + w * 0.22, cy + h * 0.22), r, blue);
      case 5:
        final r = w * 0.12;
        _drawDot(canvas, Offset(cx - w * 0.24, cy - h * 0.24), r, blue);
        _drawDot(canvas, Offset(cx + w * 0.24, cy - h * 0.24), r, green);
        _drawDot(canvas, Offset(cx - w * 0.24, cy + h * 0.24), r, green);
        _drawDot(canvas, Offset(cx + w * 0.24, cy + h * 0.24), r, blue);
        _drawDot(canvas, Offset(cx, cy), w * 0.14, red);
      case 6:
        final r = w * 0.11;
        _drawDot(canvas, Offset(cx - w * 0.22, cy - h * 0.26), r, green);
        _drawDot(canvas, Offset(cx + w * 0.22, cy - h * 0.26), r, green);
        _drawDot(canvas, Offset(cx - w * 0.22, cy), r, red);
        _drawDot(canvas, Offset(cx + w * 0.22, cy), r, red);
        _drawDot(canvas, Offset(cx - w * 0.22, cy + h * 0.26), r, red);
        _drawDot(canvas, Offset(cx + w * 0.22, cy + h * 0.26), r, red);
      case 7:
        final r = w * 0.10;
        _drawDot(canvas, Offset(cx - w * 0.24, cy - h * 0.3), r, green);
        _drawDot(canvas, Offset(cx, cy - h * 0.2), r, green);
        _drawDot(canvas, Offset(cx + w * 0.24, cy - h * 0.1), r, green);
        _drawDot(canvas, Offset(cx - w * 0.22, cy + h * 0.14), r, red);
        _drawDot(canvas, Offset(cx + w * 0.22, cy + h * 0.14), r, red);
        _drawDot(canvas, Offset(cx - w * 0.22, cy + h * 0.32), r, red);
        _drawDot(canvas, Offset(cx + w * 0.22, cy + h * 0.32), r, red);
      case 8:
        final r = w * 0.095;
        for (int i = 0; i < 4; i++) {
          final dy = cy - h * 0.3 + i * (h * 0.2);
          _drawDot(canvas, Offset(cx - w * 0.22, dy), r, blue);
          _drawDot(canvas, Offset(cx + w * 0.22, dy), r, blue);
        }
      case 9:
        final r = w * 0.095;
        for (int i = 0; i < 3; i++) {
          final dy = cy - h * 0.26 + i * (h * 0.26);
          final col = i == 0 ? green : (i == 1 ? red : blue);
          _drawDot(canvas, Offset(cx - w * 0.24, dy), r, col);
          _drawDot(canvas, Offset(cx, dy), r, col);
          _drawDot(canvas, Offset(cx + w * 0.24, dy), r, col);
        }
      default:
        _drawDot(canvas, Offset(cx, cy), w * 0.2, green);
    }
  }

  void _drawBambooStick(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    Color color,
  ) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(width * 0.35),
    );
    final paint = Paint()..color = color;
    canvas.drawRRect(rrect, paint);

    final nodePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = width * 0.25
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx - width * 0.38, center.dy),
      Offset(center.dx + width * 0.38, center.dy),
      nodePaint,
    );
  }

  void _paintBambooTile(Canvas canvas, Size size, int val, double faceHeight) {
    final w = size.width;
    final h = faceHeight;
    final cx = w / 2;
    final cy = h / 2;

    const green = Color(0xFF15803D);
    const red = Color(0xFFDC2626);
    const blue = Color(0xFF1D4ED8);

    final sw = w * 0.11;
    final sh = h * 0.26;

    switch (val) {
      case 1:
        final stalkWidth = w * 0.16;
        final stalkHeight = h * 0.65;
        final rrect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: stalkWidth,
            height: stalkHeight,
          ),
          Radius.circular(stalkWidth * 0.35),
        );
        canvas.drawRRect(rrect, Paint()..color = green);

        final nodePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..strokeWidth = stalkWidth * 0.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(cx - stalkWidth * 0.4, cy - stalkHeight * 0.2),
          Offset(cx + stalkWidth * 0.4, cy - stalkHeight * 0.2),
          nodePaint,
        );
        canvas.drawLine(
          Offset(cx - stalkWidth * 0.4, cy + stalkHeight * 0.2),
          Offset(cx + stalkWidth * 0.4, cy + stalkHeight * 0.2),
          nodePaint,
        );

        final leafPaint = Paint()..color = const Color(0xFF166534);
        final leftLeaf = Path()
          ..moveTo(cx - stalkWidth * 0.4, cy - stalkHeight * 0.1)
          ..quadraticBezierTo(
            cx - w * 0.35,
            cy - stalkHeight * 0.25,
            cx - w * 0.32,
            cy - stalkHeight * 0.35,
          )
          ..quadraticBezierTo(
            cx - w * 0.2,
            cy - stalkHeight * 0.2,
            cx - stalkWidth * 0.4,
            cy - stalkHeight * 0.1,
          );
        canvas.drawPath(leftLeaf, leafPaint);

        final rightLeaf = Path()
          ..moveTo(cx + stalkWidth * 0.4, cy + stalkHeight * 0.1)
          ..quadraticBezierTo(
            cx + w * 0.35,
            cy - stalkHeight * 0.05,
            cx + w * 0.32,
            cy - stalkHeight * 0.15,
          )
          ..quadraticBezierTo(
            cx + w * 0.2,
            cy,
            cx + stalkWidth * 0.4,
            cy + stalkHeight * 0.1,
          );
        canvas.drawPath(rightLeaf, leafPaint);
      case 2:
        _drawBambooStick(canvas, Offset(cx, cy - h * 0.18), sw, sh, green);
        _drawBambooStick(canvas, Offset(cx, cy + h * 0.18), sw, sh, green);
      case 3:
        _drawBambooStick(canvas, Offset(cx, cy - h * 0.22), sw, sh, blue);
        _drawBambooStick(
          canvas,
          Offset(cx - w * 0.2, cy + h * 0.18),
          sw,
          sh,
          green,
        );
        _drawBambooStick(
          canvas,
          Offset(cx + w * 0.2, cy + h * 0.18),
          sw,
          sh,
          green,
        );
      case 4:
        _drawBambooStick(
          canvas,
          Offset(cx - w * 0.2, cy - h * 0.18),
          sw,
          sh,
          blue,
        );
        _drawBambooStick(
          canvas,
          Offset(cx + w * 0.2, cy - h * 0.18),
          sw,
          sh,
          green,
        );
        _drawBambooStick(
          canvas,
          Offset(cx - w * 0.2, cy + h * 0.18),
          sw,
          sh,
          green,
        );
        _drawBambooStick(
          canvas,
          Offset(cx + w * 0.2, cy + h * 0.22),
          sw,
          sh,
          blue,
        );
      case 5:
        _drawBambooStick(
          canvas,
          Offset(cx - w * 0.22, cy - h * 0.2),
          sw,
          sh * 0.85,
          green,
        );
        _drawBambooStick(
          canvas,
          Offset(cx + w * 0.22, cy - h * 0.2),
          sw,
          sh * 0.85,
          blue,
        );
        _drawBambooStick(
          canvas,
          Offset(cx - w * 0.22, cy + h * 0.2),
          sw,
          sh * 0.85,
          blue,
        );
        _drawBambooStick(
          canvas,
          Offset(cx + w * 0.22, cy + h * 0.2),
          sw,
          sh * 0.85,
          green,
        );
        _drawBambooStick(canvas, Offset(cx, cy), sw, sh * 0.85, red);
      case 6:
        for (int i = 0; i < 3; i++) {
          final dx = cx - w * 0.24 + i * (w * 0.24);
          _drawBambooStick(canvas, Offset(dx, cy - h * 0.18), sw, sh, green);
          _drawBambooStick(canvas, Offset(dx, cy + h * 0.18), sw, sh, green);
        }
      case 7:
        _drawBambooStick(canvas, Offset(cx, cy - h * 0.26), sw, sh * 0.7, red);
        _drawBambooStick(
          canvas,
          Offset(cx - w * 0.24, cy - h * 0.15),
          sw,
          sh * 0.7,
          green,
        );
        _drawBambooStick(
          canvas,
          Offset(cx + w * 0.24, cy - h * 0.15),
          sw,
          sh * 0.7,
          green,
        );
        _drawBambooStick(
          canvas,
          Offset(cx - w * 0.2, cy + h * 0.12),
          sw,
          sh * 0.65,
          green,
        );
        _drawBambooStick(
          canvas,
          Offset(cx + w * 0.2, cy + h * 0.12),
          sw,
          sh * 0.65,
          green,
        );
        _drawBambooStick(
          canvas,
          Offset(cx - w * 0.2, cy + h * 0.3),
          sw,
          sh * 0.65,
          blue,
        );
        _drawBambooStick(
          canvas,
          Offset(cx + w * 0.2, cy + h * 0.3),
          sw,
          sh * 0.65,
          blue,
        );
      case 8:
        for (int i = 0; i < 4; i++) {
          final dx = cx - w * 0.27 + i * (w * 0.18);
          _drawBambooStick(
            canvas,
            Offset(dx, cy - h * 0.18),
            sw * 0.9,
            sh,
            green,
          );
          _drawBambooStick(
            canvas,
            Offset(dx, cy + h * 0.18),
            sw * 0.9,
            sh,
            blue,
          );
        }
      case 9:
        for (int i = 0; i < 3; i++) {
          final dy = cy - h * 0.24 + i * (h * 0.24);
          final col = i == 0 ? green : (i == 1 ? red : blue);
          _drawBambooStick(
            canvas,
            Offset(cx - w * 0.24, dy),
            sw,
            sh * 0.7,
            col,
          );
          _drawBambooStick(canvas, Offset(cx, dy), sw, sh * 0.7, col);
          _drawBambooStick(
            canvas,
            Offset(cx + w * 0.24, dy),
            sw,
            sh * 0.7,
            col,
          );
        }
      default:
        _drawBambooStick(canvas, Offset(cx, cy), sw, sh, green);
    }
  }

  @override
  bool shouldRepaint(covariant CustomMahjongTilePainter oldDelegate) {
    return oldDelegate.typeIndex != typeIndex ||
        oldDelegate.value != value ||
        oldDelegate.isFree != isFree ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isHinted != isHinted ||
        oldDelegate.hintProgress != hintProgress ||
        oldDelegate.useTraditional != useTraditional ||
        oldDelegate.dimLowerTiles != dimLowerTiles ||
        oldDelegate.skin.id != skin.id;
  }
}

class MahjongTileAssetWidget extends ConsumerWidget {
  const MahjongTileAssetWidget({
    super.key,
    required this.typeIndex,
    required this.value,
    required this.isFree,
    required this.isSelected,
    required this.isHinted,
    this.hintProgress = 0.0,
    this.useTraditional,
    this.dimLowerTiles,
  });

  final int typeIndex;
  final int value;
  final bool isFree;
  final bool isSelected;
  final bool isHinted;
  final double hintProgress;
  final bool? useTraditional;
  final bool? dimLowerTiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool traditional =
        useTraditional ?? ref.watch(traditionalTilesEnabledProvider);
    final bool shouldDimLower =
        dimLowerTiles ?? ref.watch(dimLowerTilesEnabledProvider);
    final skin = ref.watch(currentSkinProvider);
    return RepaintBoundary(
      child: CustomPaint(
        painter: CustomMahjongTilePainter(
          typeIndex: typeIndex,
          value: value,
          isFree: isFree,
          isSelected: isSelected,
          isHinted: isHinted,
          hintProgress: hintProgress,
          useTraditional: traditional,
          dimLowerTiles: shouldDimLower,
          skin: skin,
        ),
      ),
    );
  }
}
