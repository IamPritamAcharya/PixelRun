import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

enum ObstacleType { tall, low, wide, puddle }

class Obstacle extends PositionComponent
    with CollisionCallbacks, HasGameReference<RunnerGame> {
  final ObstacleType type;
  final int lane;

  Obstacle({required this.type, required this.lane});

  @override
  Future<void> onLoad() async {
    final screenWidth = game.size.x;
    final roadLeft = (screenWidth - GameConfig.roadWidth) / 2;
    final laneSpacing = GameConfig.roadWidth / GameConfig.laneCount;
    final laneIndex = lane.clamp(0, GameConfig.laneCount - 1);
    final laneStart = roadLeft + laneSpacing * laneIndex;

    switch (type) {
      case ObstacleType.tall:
        size = Vector2(laneSpacing * 0.70, GameConfig.obstacleTallHeight);
        position = Vector2(laneStart + (laneSpacing - size.x) / 2, -size.y - 2);
        break;
      case ObstacleType.low:
        size = Vector2(laneSpacing * 0.68, GameConfig.obstacleLowHeight);
        position = Vector2(laneStart + (laneSpacing - size.x) / 2, -size.y - 2);
        break;
      case ObstacleType.wide:
        final startLane = laneIndex == GameConfig.laneCount - 1
            ? GameConfig.laneCount - 2
            : laneIndex;
        final left = roadLeft + laneSpacing * startLane;
        size = Vector2(laneSpacing * 2 - 8, GameConfig.obstacleWideHeight);
        position = Vector2(left + 4, -size.y - 2);
        break;
      case ObstacleType.puddle:
        size = Vector2(laneSpacing * 0.80, GameConfig.obstacleWaterHeight);
        position = Vector2(laneStart + (laneSpacing - size.x) / 2, -size.y - 2);
        break;
    }

    add(RectangleHitbox());
    priority = 1;
  }

  Rect get collisionRect {
    final insetX = type == ObstacleType.wide ? 6.0 : 5.0;
    final insetTop = type == ObstacleType.puddle ? 3.0 : 4.0;
    final insetBottom = type == ObstacleType.tall ? 6.0 : 4.0;
    return Rect.fromLTWH(
      position.x + insetX,
      position.y + insetTop,
      size.x - insetX * 2,
      size.y - insetTop - insetBottom,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += game.gameState.currentSpeed * dt;

    if (position.y > game.size.y + 100) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    switch (type) {
      case ObstacleType.tall:
        _drawBrick(canvas);
        break;
      case ObstacleType.low:
        _drawLog(canvas);
        break;
      case ObstacleType.wide:
        _drawStoneWall(canvas);
        break;
      case ObstacleType.puddle:
        _drawPuddle(canvas);
        break;
    }
  }

  void _drawBrick(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final brickColor = GameColors.obstacleTall;
    final darkColor = GameColors.obstacleTallDark;
    final mortarColor = const Color(0xFF880000);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = brickColor);

    final brickH = 12.0;
    final mortarPaint = Paint()
      ..color = mortarColor
      ..strokeWidth = 2;

    for (double y = brickH; y < h; y += brickH) {
      canvas.drawLine(Offset(0, y), Offset(w, y), mortarPaint);
    }
    int row = 0;
    for (double y = 0; y < h; y += brickH) {
      final offset = (row % 2 == 0) ? 0.0 : w / 2;
      for (double x = offset; x < w; x += w / 2) {
        canvas.drawLine(Offset(x, y), Offset(x, y + brickH), mortarPaint);
      }
      row++;
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, 3, h), Paint()..color = darkColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 3),
      Paint()..color = const Color(0xFFff6666),
    );
    canvas.drawRect(Rect.fromLTWH(0, h - 3, w, 3), Paint()..color = darkColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = darkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawLog(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final logColor = GameColors.obstacleLow;
    final darkColor = GameColors.obstacleLowDark;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = logColor);

    final grainPaint = Paint()
      ..color = darkColor
      ..strokeWidth = 2;
    for (double y = 6; y < h - 4; y += 8) {
      canvas.drawLine(Offset(4, y), Offset(w - 4, y), grainPaint);
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, 10, h), Paint()..color = darkColor);
    canvas.drawOval(
      Rect.fromLTWH(1, h * 0.15, 8, h * 0.7),
      Paint()
        ..color = logColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 4),
      Paint()..color = const Color(0xFFa1887f),
    );
    canvas.drawRect(Rect.fromLTWH(0, h - 4, w, 4), Paint()..color = darkColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = darkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawStoneWall(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final stoneColor = GameColors.obstacleWide;
    final darkColor = GameColors.obstacleWideDark;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = stoneColor);

    final blockW = w / 4;
    final blockH = h / 2;
    final crevicePaint = Paint()
      ..color = darkColor
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, blockH), Offset(w, blockH), crevicePaint);
    canvas.drawLine(Offset(blockW, 0), Offset(blockW, blockH), crevicePaint);
    canvas.drawLine(
      Offset(blockW * 2, 0),
      Offset(blockW * 2, blockH),
      crevicePaint,
    );
    canvas.drawLine(
      Offset(blockW * 3, 0),
      Offset(blockW * 3, blockH),
      crevicePaint,
    );
    canvas.drawLine(
      Offset(blockW * 0.5, blockH),
      Offset(blockW * 0.5, h),
      crevicePaint,
    );
    canvas.drawLine(
      Offset(blockW * 1.5, blockH),
      Offset(blockW * 1.5, h),
      crevicePaint,
    );
    canvas.drawLine(
      Offset(blockW * 2.5, blockH),
      Offset(blockW * 2.5, h),
      crevicePaint,
    );
    canvas.drawLine(
      Offset(blockW * 3.5, blockH),
      Offset(blockW * 3.5, h),
      crevicePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 4),
      Paint()..color = const Color(0xFF78909c),
    );
    canvas.drawRect(Rect.fromLTWH(0, h - 4, w, 4), Paint()..color = darkColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = darkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawPuddle(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 2, w, h - 2),
        const Radius.circular(10),
      ),
      Paint()..color = GameColors.obstacleWater.withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 2, w, h - 2),
        const Radius.circular(10),
      ),
      Paint()
        ..color = GameColors.obstacleWaterDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.12, 5, w * 0.30, 4),
      Paint()..color = const Color(0x6600EEFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.56, 9, w * 0.22, 3),
      Paint()..color = const Color(0x44FFFFFF),
    );
  }
}
