import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runner/game/utils/constants.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double width;
  final double height;
  final double fontSize;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = GameColors.pixelGreen,
    this.width = 220,
    this.height = 56,
    this.fontSize = 14,
    this.icon,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color;

    final shadow = HSLColor.fromColor(c)
        .withLightness((HSLColor.fromColor(c).lightness * 0.45).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        transform: _isPressed
            ? Matrix4.translationValues(0, 3, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _isPressed ? shadow : c,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.45),
              width: 3,
            ),
            left: BorderSide(
              color: Colors.white.withValues(alpha: 0.45),
              width: 3,
            ),
            right: BorderSide(color: shadow, width: 3),
            bottom: _isPressed
                ? BorderSide(color: shadow, width: 2)
                : BorderSide(color: shadow, width: 5),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.fontSize + 2,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: GoogleFonts.pressStart2p(
                  fontSize: widget.fontSize,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Color(0x88000000), offset: Offset(1, 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
