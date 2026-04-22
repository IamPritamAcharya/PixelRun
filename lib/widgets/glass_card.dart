import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xEE1a1a2e),
        border: Border(
          top: const BorderSide(color: Color(0xFF4a6fa5), width: 3),
          left: const BorderSide(color: Color(0xFF4a6fa5), width: 3),
          right: const BorderSide(color: Color(0xFF0d0d1a), width: 3),
          bottom: const BorderSide(color: Color(0xFF0d0d1a), width: 4),
        ),
      ),
      child: child,
    );
  }
}
