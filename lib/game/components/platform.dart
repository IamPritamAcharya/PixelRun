import 'dart:ui';
import 'package:flame/components.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/levels/level_data.dart';
import 'package:runner/game/utils/constants.dart';

class Platform extends PositionComponent with HasGameReference<PlatformerGame> {
  final PlatformType type;
  final double worldX;
  double scrollX = 0;

  Platform({
    required this.worldX,
    required double worldY,
    required double width,
    required this.type,
  }) {
    final h = type == PlatformType.pipe ? 52.0 : GameConfig.platformH;
    size = Vector2(width, h);
    position = Vector2(0, worldY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final screenX = worldX - game.cameraX;
    position.x = screenX;

    if (screenX + size.x < -200 || screenX > game.size.x + 400) {}
  }

  double get topY => position.y;

  Rect get screenRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  void render(Canvas canvas) {
    switch (type) {
      case PlatformType.dirt:
        _drawDirt(canvas);
        break;
      case PlatformType.brick:
        _drawBrick(canvas);
        break;
      case PlatformType.stone:
        _drawStone(canvas);
        break;
      case PlatformType.cloud:
        _drawCloud(canvas);
        break;
      case PlatformType.pipe:
        _drawPipe(canvas);
        break;
    }
  }

  void _drawDirt(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.35),
      Paint()..color = GameColors.groundTop,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.35, w, h * 0.65),
      Paint()..color = GameColors.groundBody,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = GameColors.groundDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.35, w, 2),
      Paint()..color = GameColors.groundDark,
    );
  }

  void _drawBrick(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = GameColors.brickPlatformBody,
    );
    final m = Paint()
      ..color = GameColors.brickPlatformTop
      ..strokeWidth = 1.5;
    for (double y = 8; y < h; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(w, y), m);
    }
    int row = 0;
    for (double y = 0; y < h; y += 8) {
      final off = (row % 2 == 0) ? 0.0 : w / 2;
      for (double x = off; x < w; x += w / 2) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 8), m);
      }
      row++;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = const Color(0xFF660000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawRect(
      Rect.fromLTWH(2, 2, w - 4, 3),
      Paint()..color = const Color(0x44FFFFFF),
    );
  }

  void _drawStone(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF8899AA),
    );
    final c = Paint()
      ..color = const Color(0xFF667788)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), c);
    canvas.drawLine(Offset(w * 0.33, 0), Offset(w * 0.33, h / 2), c);
    canvas.drawLine(Offset(w * 0.66, 0), Offset(w * 0.66, h / 2), c);
    canvas.drawLine(Offset(w * 0.5, h / 2), Offset(w * 0.5, h), c);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = const Color(0xFF445566)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRect(
      Rect.fromLTWH(2, 2, w - 4, 3),
      Paint()..color = const Color(0x33FFFFFF),
    );
  }

  void _drawCloud(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final fill = Paint()..color = const Color(0xDDFFFFFF);
    final shadow = Paint()..color = const Color(0x44AACCFF);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, w, h),
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, h * 0.6, w, h * 0.4),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      shadow,
    );
  }

  void _drawPipe(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawRect(
      Rect.fromLTWH(w * 0.1, 0, w * 0.8, h),
      Paint()..color = GameColors.pipePlatformColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.1, 0, w * 0.8, h),
      Paint()
        ..color = GameColors.pipePlatformDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.18),
      Paint()..color = GameColors.pipePlatformColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.18),
      Paint()
        ..color = GameColors.pipePlatformDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.05, w * 0.25, h * 0.6),
      Paint()..color = const Color(0x3300FF00),
    );
  }
}
