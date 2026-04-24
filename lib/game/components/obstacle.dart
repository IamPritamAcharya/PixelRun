import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

enum ObstacleType { tall, low, wide, puddle }

class Obstacle extends PositionComponent with HasGameReference<RunnerGame> {
  final ObstacleType type;
  final int lane;

  Obstacle({required this.type, required this.lane});

  @override
  Future<void> onLoad() async {
    final sw = game.size.x;
    final roadTop = game.road.roadTop;
    final lh = GameConfig.laneHeight;
    final laneTop = roadTop + lane * lh;

    switch (type) {
      case ObstacleType.tall:
        size = Vector2(
          GameConfig.obstacleTallWidth,
          GameConfig.obstacleTallHeight,
        );
        position = Vector2(sw + 8, laneTop + lh - size.y - 6);
        break;

      case ObstacleType.low:
        size = Vector2(
          GameConfig.obstacleLowWidth,
          GameConfig.obstacleLowHeight,
        );
        position = Vector2(sw + 8, laneTop + lh - size.y - 6);
        break;

      case ObstacleType.wide:
        final topLane = lane.clamp(0, GameConfig.laneCount - 2);
        final laneTop2 = roadTop + topLane * lh;
        size = Vector2(GameConfig.obstacleWideWidth, lh * 2 - 12);
        position = Vector2(sw + 8, laneTop2 + 6);
        break;

      case ObstacleType.puddle:
        size = Vector2(
          GameConfig.obstacleWaterWidth,
          GameConfig.obstacleWaterHeight,
        );
        position = Vector2(sw + 8, laneTop + lh - size.y - 4);
        break;
    }

    add(RectangleHitbox());
    priority = 1;
  }

  Rect get collisionRect {
    final insetX = type == ObstacleType.puddle ? 4.0 : 5.0;
    final insetTop = type == ObstacleType.puddle ? 3.0 : 4.0;
    final insetBot = type == ObstacleType.tall ? 6.0 : 4.0;
    return Rect.fromLTWH(
      position.x + insetX,
      position.y + insetTop,
      size.x - insetX * 2,
      size.y - insetTop - insetBot,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= game.gameState.currentSpeed * dt;
    if (position.x + size.x < -100) removeFromParent();
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
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = GameColors.obstacleTall,
    );
    final mortarPaint = Paint()
      ..color = GameColors.obstacleTallDark
      ..strokeWidth = 2;
    for (double y = 12; y < h; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(w, y), mortarPaint);
    }
    int row = 0;
    for (double y = 0; y < h; y += 12) {
      final offset = (row % 2 == 0) ? 0.0 : w / 2;
      for (double x = offset; x < w; x += w / 2) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 12), mortarPaint);
      }
      row++;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = GameColors.obstacleTallDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawLog(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = GameColors.obstacleLow,
    );
    final grain = Paint()
      ..color = GameColors.obstacleLowDark
      ..strokeWidth = 2;
    for (double y = 6; y < h - 4; y += 8) {
      canvas.drawLine(Offset(4, y), Offset(w - 4, y), grain);
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = GameColors.obstacleLowDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawStoneWall(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = GameColors.obstacleWide,
    );
    final crevice = Paint()
      ..color = GameColors.obstacleWideDark
      ..strokeWidth = 2;
    final bh = h / 2;
    canvas.drawLine(Offset(0, bh), Offset(w, bh), crevice);
    canvas.drawLine(Offset(w * 0.33, 0), Offset(w * 0.33, bh), crevice);
    canvas.drawLine(Offset(w * 0.66, 0), Offset(w * 0.66, bh), crevice);
    canvas.drawLine(Offset(w * 0.18, bh), Offset(w * 0.18, h), crevice);
    canvas.drawLine(Offset(w * 0.52, bh), Offset(w * 0.52, h), crevice);
    canvas.drawLine(Offset(w * 0.82, bh), Offset(w * 0.82, h), crevice);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = GameColors.obstacleWideDark
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
