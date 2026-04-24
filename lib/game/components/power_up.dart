import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

enum PowerUpType { shield, magnet, doubleCoins, boost }

class PowerUp extends PositionComponent with HasGameReference<RunnerGame> {
  final PowerUpType type;
  final int lane;
  double _spinTimer = 0;

  PowerUp({required this.type, required this.lane});

  static const double powerUpSize = 34.0;

  @override
  Future<void> onLoad() async {
    final laneCenter = game.road.laneCenterY(lane);
    size = Vector2(powerUpSize, powerUpSize);

    position = Vector2(
      game.size.x + powerUpSize + 8,
      laneCenter - powerUpSize / 2,
    );
  }

  Rect get collisionRect =>
      Rect.fromLTWH(position.x + 5, position.y + 5, size.x - 10, size.y - 10);

  Color get _color {
    switch (type) {
      case PowerUpType.shield:
        return GameColors.shield;
      case PowerUpType.magnet:
        return GameColors.magnet;
      case PowerUpType.doubleCoins:
        return GameColors.doubleCoins;
      case PowerUpType.boost:
        return GameColors.boost;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= game.gameState.currentSpeed * dt;
    _spinTimer += dt * 4;
    if (position.x + size.x < -80) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final pulse = 1 + sin(_spinTimer) * 0.08;
    final c = size.x / 2;

    canvas.save();
    canvas.translate(c, c);
    canvas.scale(pulse, pulse);
    canvas.translate(-c, -c);

    canvas.drawCircle(
      Offset(c, c),
      c,
      Paint()
        ..color = _color.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(Offset(c, c), c - 1, Paint()..color = _color);
    canvas.drawCircle(
      Offset(c, c),
      c - 4,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    switch (type) {
      case PowerUpType.shield:
        canvas.drawRect(
          Rect.fromLTWH(c - 3, c - 8, 6, 16),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        canvas.drawRect(
          Rect.fromLTWH(c - 8, c - 3, 16, 6),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        break;
      case PowerUpType.magnet:
        canvas.drawArc(
          Rect.fromCircle(center: Offset(c, c), radius: c * 0.58),
          pi * 0.15,
          pi * 0.70,
          false,
          Paint()
            ..color = const Color(0xFFFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
        canvas.drawRect(
          Rect.fromLTWH(c - 7, c + 1, 6, 9),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        canvas.drawRect(
          Rect.fromLTWH(c + 1, c + 1, 6, 9),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        break;
      case PowerUpType.doubleCoins:
        canvas.drawRect(
          Rect.fromLTWH(c - 8, c - 5, 6, 10),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        canvas.drawRect(
          Rect.fromLTWH(c + 2, c - 5, 6, 10),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        canvas.drawRect(
          Rect.fromLTWH(c - 10, c - 8, 20, 3),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        canvas.drawRect(
          Rect.fromLTWH(c - 10, c + 5, 20, 3),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        break;
      case PowerUpType.boost:
        canvas.drawRect(
          Rect.fromLTWH(c - 6, c - 7, 6, 14),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        final path = Path()
          ..moveTo(c + 1, c - 10)
          ..lineTo(c + 9, c)
          ..lineTo(c + 1, c + 10)
          ..lineTo(c + 4, c + 2)
          ..lineTo(c - 6, c + 2)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFFFFFFF));
        break;
    }

    canvas.restore();
  }
}
