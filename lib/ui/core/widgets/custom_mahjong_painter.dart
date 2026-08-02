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

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ------------------------------------------------------------------------
    // 1. BASE SLAB / PLINTH (Warm Amber / Orange Bottom Base - Reference Image)
    // ------------------------------------------------------------------------
    final baseDepth = h * 0.07;
    final r = w * 0.22; // Smooth rounded corners

    // Drop shadow under bottom plinth
    final shadowPath = RRect.fromLTRBAndCorners(
      0,
      baseDepth,
      w,
      h,
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
      bottomLeft: Radius.circular(r * 1.1),
      bottomRight: Radius.circular(r * 1.1),
    );
    canvas.drawRRect(
      shadowPath,
      Paint()
        ..color = isSelected
            ? const Color(0xFFEAB308).withValues(alpha: 0.8)
            : Colors.black.withValues(alpha: isFree ? 0.30 : 0.15)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 8.0 : 4.0),
    );

    // Bottom amber base plinth
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

    // Bottom plinth highlight line
    final baseHighlight = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(baseRect, baseHighlight);

    // ------------------------------------------------------------------------
    // 2. MIDDLE ACCENT LAYER (Light Grey / Off-White Layer - Reference Image)
    // ------------------------------------------------------------------------
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

    // ------------------------------------------------------------------------
    // 3. TOP PORCELAIN IVORY FACE PLATE (White Surface + Cyan Gradient Bezel)
    // ------------------------------------------------------------------------
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

    // ReferenceCyan Outer Soft Glow Bezel
    final outerBezelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isHinted
            ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
            : isSelected
                ? [const Color(0xFFFACC15), const Color(0xFFEAB308)]
                : [
                    const Color(0xFFA5F3FC).withValues(alpha: 0.9), // Bright Ice Cyan
                    const Color(0xFF67E8F9).withValues(alpha: 0.6),
                    const Color(0xFFCFFAFE).withValues(alpha: 0.4),
                  ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHinted ? 3.0 : (isSelected ? 2.5 : 2.0);
    canvas.drawRRect(faceRect, outerBezelPaint);

    // Inner Bezel Shadow Line (creates depth frame around tile top face)
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
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(innerBezelRect, innerBezelPaint);

    // Subtle glossy white reflection at upper edge of face plate
    final shinePath = Path()
      ..moveTo(w * 0.15, h * 0.04)
      ..quadraticBezierTo(w * 0.5, h * 0.02, w * 0.85, h * 0.04)
      ..quadraticBezierTo(w * 0.5, h * 0.06, w * 0.15, h * 0.04);
    canvas.drawPath(
      shinePath,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // ------------------------------------------------------------------------
    // 4. EMOJI ICON rendering inside Face Plate
    // ------------------------------------------------------------------------
    final type = TileType.values[typeIndex];
    String emoji = '🟨';

    switch (type) {
      case TileType.character:
        const fruits = ['🍎', '🍌', '🍇', '🍊', '🍓', '🍍', '🍑', '🍒', '🍉'];
        emoji = fruits[(value - 1) % 9];
        break;
      case TileType.bamboo:
        const animals = ['🦚', '🐼', '🐯', '🦁', '🦊', '🐸', '🐵', '🐨', '🐰'];
        emoji = animals[(value - 1) % 9];
        break;
      case TileType.rod:
        const foods = ['🍕', '🍩', '🍔', '🍟', '🍰', '🍦', '🍣', '🌮', '🧁'];
        emoji = foods[(value - 1) % 9];
        break;
      case TileType.season:
        emoji = '🌸';
        break;
      case TileType.wind:
        const winds = ['🧭', '⛵', '🚀', '🛸'];
        emoji = winds[value % 4];
        break;
      case TileType.dragon:
        const dragons = ['🐲', '🐉', '⭐'];
        emoji = dragons[value % 3];
        break;
      case TileType.flower:
        emoji = '🌺';
        break;
    }

    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: (h - baseDepth * 1.4) * 0.58,
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

    // Dark mask for locked unselectable tiles
    if (!isFree) {
      final lockedOverlayPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.28);
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
    return CustomPaint(
      painter: CustomMahjongTilePainter(
        typeIndex: typeIndex,
        value: value,
        isFree: isFree,
        isSelected: isSelected,
        isHinted: isHinted,
      ),
    );
  }
}
