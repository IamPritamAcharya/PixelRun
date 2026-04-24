import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/levels/level_data.dart';
import 'package:runner/game/utils/constants.dart';

class Pickup extends PositionComponent with HasGameReference<PlatformerGame> {
  final PickupType type;
  final double worldX;
  final double worldY;
  bool isCollected = false;

  double _bobTimer = 0;
  double _spinTimer = 0;

  Pickup({required this.type, required this.worldX, required this.worldY});

  static const double _size = 22.0;

  @override
  Future<void> onLoad() async {
    size = Vector2(_size, _size);
    priority = 4;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobTimer += dt * 3.5;
    _spinTimer += dt * 5.0;

    final screenX = worldX - game.cameraX;
    position.x = screenX;
    position.y = worldY - size.y / 2 + math.sin(_bobTimer) * 4;

    if (screenX + size.x < -50) removeFromParent();
  }

  Rect get screenRect =>
      Rect.fromLTWH(position.x + 3, position.y + 3, size.x - 6, size.y - 6);

  @override
  void render(Canvas canvas) {
    if (isCollected) return;

    final c = size.x / 2;

    switch (type) {
      case PickupType.coin:
        _drawCoin(canvas, c);
        break;
      case PickupType.firePower:
        _drawOrb(canvas, c, GameColors.fireOrb, GameColors.fireballCore, '🔥');
        break;
      case PickupType.teleport:
        _drawOrb(
          canvas,
          c,
          GameColors.teleportOrb,
          const Color(0xFFDDA0DD),
          '⚡',
        );
        break;
      case PickupType.star:
        _drawStar(canvas, c);
        break;
      case PickupType.shield:
        _drawOrb(
          canvas,
          c,
          GameColors.shieldOrb,
          const Color(0xFFE0F8FF),
          '🛡',
        );
        break;
    }
  }

  void _drawCoin(Canvas canvas, double c) {
    final scaleX = math.cos(_spinTimer).abs().clamp(0.15, 1.0);
    canvas.save();
    canvas.translate(c, c);
    canvas.scale(scaleX, 1.0);
    canvas.translate(-c, -c);

    canvas.drawCircle(Offset(c, c), c, Paint()..color = GameColors.coinDark);
    canvas.drawCircle(Offset(c, c), c - 2, Paint()..color = GameColors.coin);
    canvas.drawRect(
      Rect.fromLTWH(c - 3, c - 6, 6, 12),
      Paint()..color = GameColors.coinDark,
    );

    canvas.restore();

    canvas.drawCircle(
      Offset(c, c),
      c + 3,
      Paint()
        ..color = GameColors.coin.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawOrb(
    Canvas canvas,
    double c,
    Color color,
    Color core,
    String symbol,
  ) {
    canvas.drawCircle(
      Offset(c, c),
      c + 4,
      Paint()
        ..color = color.withAlpha(80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(Offset(c, c), c, Paint()..color = color);
    canvas.drawCircle(
      Offset(c, c),
      c - 3,
      Paint()..color = core.withAlpha(120),
    );

    final pulse = math.sin(_spinTimer) * 0.15 + 0.85;
    canvas.drawCircle(
      Offset(c, c),
      c * pulse,
      Paint()
        ..color = core.withAlpha(80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawStar(Canvas canvas, double c) {
    final hue = (_spinTimer * 60) % 360;
    final starColor = _hueToColor(hue);

    final path = _starPath(c, c, c - 1, c * 0.45, 5, _spinTimer * 0.5);
    canvas.drawPath(
      path,
      Paint()
        ..color = starColor.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(path, Paint()..color = starColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withAlpha(100)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  Path _starPath(
    double cx,
    double cy,
    double outerR,
    double innerR,
    int points,
    double rotation,
  ) {
    final path = Path();
    final angleStep = math.pi / points;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = i * angleStep - math.pi / 2 + rotation;
      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  Color _hueToColor(double hue) {
    final h = hue / 60;
    final i = h.floor() % 6;
    final f = h - h.floor();
    final t = (f * 255).round();
    final q = ((1.0 - f) * 255).round();
    switch (i) {
      case 0:
        return Color.fromARGB(255, 255, t, 0);
      case 1:
        return Color.fromARGB(255, q, 255, 0);
      case 2:
        return Color.fromARGB(255, 0, 255, t);
      case 3:
        return Color.fromARGB(255, 0, q, 255);
      case 4:
        return Color.fromARGB(255, t, 0, 255);
      default:
        return Color.fromARGB(255, 255, 0, q);
    }
  }
}

class Colors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
