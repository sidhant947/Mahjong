import 'package:flutter/material.dart';
import 'package:mahjong/ui/core/services/haptic_service.dart';

class TangibleButton extends StatefulWidget {
  const TangibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.height = 56,
    this.primaryColor,
    this.secondaryColor,
    this.borderColor,
    this.textColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final double height;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? borderColor;
  final Color? textColor;

  @override
  State<TangibleButton> createState() => _TangibleButtonState();
}

class _TangibleButtonState extends State<TangibleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onPressed != null;
    final isPressedNow = _isPressed && isInteractive;

    final Color buttonBg = widget.isSecondary
        ? (widget.secondaryColor ?? const Color(0xFF134545))
        : (widget.primaryColor ?? const Color(0xFF2D8B7A));
    final Color textColor = widget.textColor ?? const Color(0xFFF5F5F0);
    final Color borderColor = widget.borderColor ?? (widget.isSecondary ? const Color(0xFF2D8B7A).withValues(alpha: 0.3) : const Color(0xFF3D7A6B));

    return GestureDetector(
      onTapDown: (_) {
        if (isInteractive) {
          setState(() => _isPressed = true);
          HapticService.lightImpact();
        }
      },
      onTapUp: (_) {
        if (isInteractive) {
          setState(() => _isPressed = false);
          if (widget.onPressed != null) widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (isInteractive) setState(() => _isPressed = false);
      },
      child: Opacity(
        opacity: isPressedNow ? 0.85 : 1.0,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: buttonBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text.toUpperCase(),
            style: TextStyle(
              
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
