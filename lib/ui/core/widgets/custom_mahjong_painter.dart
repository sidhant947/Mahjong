import 'package:flutter/material.dart';
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
    this.skin = AppSkin.jadeGarden,
    this.useTraditional = false,
    this.dimLowerTiles = true,
  });

  final int typeIndex;
  final int value;
  final bool isFree;
  final bool isSelected;
  final bool isHinted;
  final bool useTraditional;
  final bool dimLowerTiles;
  final AppSkin skin;

  static const _fruits = ['🍎', '🍌', '🍇', '🍊', '🍓', '🍍', '🍑', '🍒', '🍉'];
  static const _animals = ['🦚', '🐼', '🐯', '🦁', '🦊', '🐸', '🐵', '🐨', '🐰'];
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

    final baseDepth = h * 0.07;
    final r = w * 0.22;

    final shadowRRect = RRect.fromLTRBAndCorners(
      1.0,
      baseDepth + 2.0,
      w + 1.0,
      h + 2.0,
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
      bottomLeft: Radius.circular(r * 1.1),
      bottomRight: Radius.circular(r * 1.1),
    );

    final shadowPaint = Paint()
      ..color = isSelected
          ? skin.primaryColor.withValues(alpha: 0.6)
          : (isFree || !dimLowerTiles ? const Color(0x33000000) : const Color(0x18000000));
    canvas.drawRRect(shadowRRect, shadowPaint);

    final baseRect = RRect.fromLTRBAndCorners(
      0,
      h * 0.1,
      w,
      h,
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
      bottomLeft: Radius.circular(r * 1.1),
      bottomRight: Radius.circular(r * 1.1),
    );
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: skin.tileBaseGradient,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(baseRect, basePaint);

    final baseHighlight = Paint()
      ..color = skin.tileBaseHighlight.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(baseRect, baseHighlight);

    final midRect = RRect.fromLTRBAndCorners(
      0,
      h * 0.04,
      w,
      h - baseDepth * 0.7,
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
      bottomLeft: Radius.circular(r),
      bottomRight: Radius.circular(r),
    );
    final midPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(midRect, midPaint);

    final faceRect = RRect.fromLTRBAndCorners(
      0,
      0,
      w,
      h - baseDepth * 1.4,
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
      bottomLeft: Radius.circular(r),
      bottomRight: Radius.circular(r),
    );

    final shouldDim = !isFree && dimLowerTiles;

    final faceGradient = !shouldDim
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: skin.tileFaceGradient,
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
          );

    final facePaint = Paint()..shader = faceGradient.createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(faceRect, facePaint);

    final outerBezelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isHinted
            ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
            : isSelected
                ? [skin.primaryColor, skin.accentColor]
                : skin.tileBezelColors,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHinted ? 3.0 : (isSelected ? 2.5 : 2.0);
    canvas.drawRRect(faceRect, outerBezelPaint);

    final innerBezelRect = RRect.fromLTRBAndCorners(
      w * 0.03,
      h * 0.03,
      w * 0.97,
      (h - baseDepth * 1.4) * 0.97,
      topLeft: Radius.circular(r * 0.8),
      topRight: Radius.circular(r * 0.8),
      bottomLeft: Radius.circular(r * 0.8),
      bottomRight: Radius.circular(r * 0.8),
    );
    final innerBezelPaint = Paint()
      ..color = skin.tileInnerBezelColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(innerBezelRect, innerBezelPaint);

    final shinePath = Path()
      ..moveTo(w * 0.15, h * 0.04)
      ..quadraticBezierTo(w * 0.5, h * 0.02, w * 0.85, h * 0.04)
      ..quadraticBezierTo(w * 0.5, h * 0.06, w * 0.15, h * 0.04);
    canvas.drawPath(
      shinePath,
      Paint()..color = const Color(0xD9FFFFFF),
    );

    final type = TileType.values[typeIndex];
    final faceHeight = h - baseDepth * 1.4;

    if (useTraditional) {
      _paintTraditionalTile(canvas, size, type, value, faceHeight);
    } else {
      final emoji = _getEmoji(type, value);
      final fontSize = faceHeight * 0.58;
      if (fontSize > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: emoji,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final faceCenterY = faceHeight / 2;
        final emojiOffset = Offset(
          (w - tp.width) / 2,
          faceCenterY - tp.height / 2,
        );

        tp.paint(canvas, emojiOffset);
        tp.dispose();
      }
    }

    if (shouldDim) {
      final lockedOverlayPaint = Paint()..color = const Color(0x47000000);
      canvas.drawRRect(faceRect, lockedOverlayPaint);
    }
  }

  void _paintTraditionalTile(Canvas canvas, Size size, TileType type, int val, double faceHeight) {
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

  void _paintCharacterTile(Canvas canvas, Size size, int val, double faceHeight) {
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
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2));
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
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2));
    tp.dispose();
  }

  void _paintDragonTile(Canvas canvas, Size size, int val, double faceHeight) {
    const chars = ['中', '發', '白'];
    const colors = [
      Color(0xFFDC2626),
      Color(0xFF15803D),
      Color(0xFF1D4ED8),
    ];
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
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2));
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
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2));
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
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (faceHeight - tp.height) / 2));
    tp.dispose();
  }

  void _drawDot(Canvas canvas, Offset center, double radius, Color outerColor, [Color? innerColor]) {
    final outerPaint = Paint()..color = outerColor;
    canvas.drawCircle(center, radius, outerPaint);
    final innerPaint = Paint()..color = innerColor ?? Colors.white.withValues(alpha: 0.9);
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

  void _drawBambooStick(Canvas canvas, Offset center, double width, double height, Color color) {
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
          Rect.fromCenter(center: Offset(cx, cy), width: stalkWidth, height: stalkHeight),
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
          ..quadraticBezierTo(cx - w * 0.35, cy - stalkHeight * 0.25, cx - w * 0.32, cy - stalkHeight * 0.35)
          ..quadraticBezierTo(cx - w * 0.2, cy - stalkHeight * 0.2, cx - stalkWidth * 0.4, cy - stalkHeight * 0.1);
        canvas.drawPath(leftLeaf, leafPaint);

        final rightLeaf = Path()
          ..moveTo(cx + stalkWidth * 0.4, cy + stalkHeight * 0.1)
          ..quadraticBezierTo(cx + w * 0.35, cy - stalkHeight * 0.05, cx + w * 0.32, cy - stalkHeight * 0.15)
          ..quadraticBezierTo(cx + w * 0.2, cy, cx + stalkWidth * 0.4, cy + stalkHeight * 0.1);
        canvas.drawPath(rightLeaf, leafPaint);
      case 2:
        _drawBambooStick(canvas, Offset(cx, cy - h * 0.18), sw, sh, green);
        _drawBambooStick(canvas, Offset(cx, cy + h * 0.18), sw, sh, green);
      case 3:
        _drawBambooStick(canvas, Offset(cx, cy - h * 0.22), sw, sh, blue);
        _drawBambooStick(canvas, Offset(cx - w * 0.2, cy + h * 0.18), sw, sh, green);
        _drawBambooStick(canvas, Offset(cx + w * 0.2, cy + h * 0.18), sw, sh, green);
      case 4:
        _drawBambooStick(canvas, Offset(cx - w * 0.2, cy - h * 0.18), sw, sh, blue);
        _drawBambooStick(canvas, Offset(cx + w * 0.2, cy - h * 0.18), sw, sh, green);
        _drawBambooStick(canvas, Offset(cx - w * 0.2, cy + h * 0.18), sw, sh, green);
        _drawBambooStick(canvas, Offset(cx + w * 0.2, cy + h * 0.18), sw, sh, blue);
      case 5:
        _drawBambooStick(canvas, Offset(cx - w * 0.22, cy - h * 0.2), sw, sh * 0.85, green);
        _drawBambooStick(canvas, Offset(cx + w * 0.22, cy - h * 0.2), sw, sh * 0.85, blue);
        _drawBambooStick(canvas, Offset(cx - w * 0.22, cy + h * 0.2), sw, sh * 0.85, blue);
        _drawBambooStick(canvas, Offset(cx + w * 0.22, cy + h * 0.2), sw, sh * 0.85, green);
        _drawBambooStick(canvas, Offset(cx, cy), sw, sh * 0.85, red);
      case 6:
        for (int i = 0; i < 3; i++) {
          final dx = cx - w * 0.24 + i * (w * 0.24);
          _drawBambooStick(canvas, Offset(dx, cy - h * 0.18), sw, sh, green);
          _drawBambooStick(canvas, Offset(dx, cy + h * 0.18), sw, sh, green);
        }
      case 7:
        _drawBambooStick(canvas, Offset(cx, cy - h * 0.26), sw, sh * 0.7, red);
        _drawBambooStick(canvas, Offset(cx - w * 0.24, cy - h * 0.15), sw, sh * 0.7, green);
        _drawBambooStick(canvas, Offset(cx + w * 0.24, cy - h * 0.15), sw, sh * 0.7, green);
        _drawBambooStick(canvas, Offset(cx - w * 0.2, cy + h * 0.12), sw, sh * 0.65, green);
        _drawBambooStick(canvas, Offset(cx + w * 0.2, cy + h * 0.12), sw, sh * 0.65, green);
        _drawBambooStick(canvas, Offset(cx - w * 0.2, cy + h * 0.3), sw, sh * 0.65, blue);
        _drawBambooStick(canvas, Offset(cx + w * 0.2, cy + h * 0.3), sw, sh * 0.65, blue);
      case 8:
        for (int i = 0; i < 4; i++) {
          final dx = cx - w * 0.27 + i * (w * 0.18);
          _drawBambooStick(canvas, Offset(dx, cy - h * 0.18), sw * 0.9, sh, green);
          _drawBambooStick(canvas, Offset(dx, cy + h * 0.18), sw * 0.9, sh, blue);
        }
      case 9:
        for (int i = 0; i < 3; i++) {
          final dy = cy - h * 0.24 + i * (h * 0.24);
          final col = i == 0 ? green : (i == 1 ? red : blue);
          _drawBambooStick(canvas, Offset(cx - w * 0.24, dy), sw, sh * 0.7, col);
          _drawBambooStick(canvas, Offset(cx, dy), sw, sh * 0.7, col);
          _drawBambooStick(canvas, Offset(cx + w * 0.24, dy), sw, sh * 0.7, col);
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
    this.useTraditional,
    this.dimLowerTiles,
  });

  final int typeIndex;
  final int value;
  final bool isFree;
  final bool isSelected;
  final bool isHinted;
  final bool? useTraditional;
  final bool? dimLowerTiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool traditional = useTraditional ?? ref.watch(traditionalTilesEnabledProvider);
    final bool shouldDimLower = dimLowerTiles ?? ref.watch(dimLowerTilesEnabledProvider);
    final skin = ref.watch(currentSkinProvider);
    return RepaintBoundary(
      child: CustomPaint(
        painter: CustomMahjongTilePainter(
          typeIndex: typeIndex,
          value: value,
          isFree: isFree,
          isSelected: isSelected,
          isHinted: isHinted,
          useTraditional: traditional,
          dimLowerTiles: shouldDimLower,
          skin: skin,
        ),
      ),
    );
  }
}


