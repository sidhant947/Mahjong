import 'package:flutter/material.dart';
import 'package:mahjong/domain/models/mahjong_tile.dart';

class CustomMahjongTilePainter extends CustomPainter {
  const CustomMahjongTilePainter({
    required this.typeIndex,
    required this.value,
    required this.isFree,
    required this.isSelected,
    required this.isHinted,
  });

  final int typeIndex;
  final int value;
  final bool isFree;
  final bool isSelected;
  final bool isHinted;

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
          ? const Color(0xFFEAB308).withValues(alpha: 0.6)
          : (isFree ? const Color(0x33000000) : const Color(0x18000000));
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
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(baseRect, basePaint);

    final baseHighlight = Paint()
      ..color = const Color(0xB3FDE68A)
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

    final faceGradient = isFree
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0xFFFAFAFA),
              Color(0xFFF3F4F6),
            ],
            stops: [0.0, 0.5, 0.85, 1.0],
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
                ? [const Color(0xFFFACC15), const Color(0xFFEAB308)]
                : [
                    const Color(0xE6A5F3FC),
                    const Color(0x9967E8F9),
                    const Color(0x66CFFAFE),
                  ],
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
      ..color = const Color(0x4006B6D4)
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
    final emoji = _getEmoji(type, value);

    final fontSize = (h - baseDepth * 1.4) * 0.58;
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

      final faceCenterY = (h - baseDepth * 1.4) / 2;
      final emojiOffset = Offset(
        (w - tp.width) / 2,
        faceCenterY - tp.height / 2,
      );

      tp.paint(canvas, emojiOffset);
      tp.dispose();
    }

    if (!isFree) {
      final lockedOverlayPaint = Paint()..color = const Color(0x47000000);
      canvas.drawRRect(faceRect, lockedOverlayPaint);
    }
  }


  @override
  bool shouldRepaint(covariant CustomMahjongTilePainter oldDelegate) {
    return oldDelegate.typeIndex != typeIndex ||
        oldDelegate.value != value ||
        oldDelegate.isFree != isFree ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isHinted != isHinted;
  }
}

class MahjongTileAssetWidget extends StatelessWidget {
  const MahjongTileAssetWidget({
    super.key,
    required this.typeIndex,
    required this.value,
    required this.isFree,
    required this.isSelected,
    required this.isHinted,
  });

  final int typeIndex;
  final int value;
  final bool isFree;
  final bool isSelected;
  final bool isHinted;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CustomMahjongTilePainter(
          typeIndex: typeIndex,
          value: value,
          isFree: isFree,
          isSelected: isSelected,
          isHinted: isHinted,
        ),
      ),
    );
  }
}

