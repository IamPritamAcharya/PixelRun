import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/utils/constants.dart';

class Fireball extends PositionComponent with HasGameReference<PlatformerGame> {
  double _timer = 0;

  Fireball({required double x, required double y}) {
    size = Vector2(GameConfig.fireballSize, GameConfig.fireballSize);
    position = Vector2(x, y);
    priority = 8;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    position.x += GameConfig.fireballSpeed * dt;

    if (position.x > game.size.x + 30) removeFromParent();
  }

  Rect get screenRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  void render(Canvas canvas) {
    final c = size.x / 2;
    final pulse = math.sin(_timer * 20) * 0.2 + 0.8;

    canvas.drawCircle(
      Offset(c, c),
      c * pulse + 4,
      Paint()
        ..color = GameColors.fireOrb.withAlpha(80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawCircle(
      Offset(c, c),
      c * pulse,
      Paint()..color = GameColors.fireOrb,
    );
    canvas.drawCircle(
      Offset(c, c),
      c * pulse * 0.55,
      Paint()..color = GameColors.fireballCore,
    );

    for (int i = 0; i < 3; i++) {
      final trailX = -i * 8.0 - 4;
      final trailY = math.sin(_timer * 15 + i) * 3;
      canvas.drawCircle(
        Offset(c + trailX, c + trailY),
        (c * 0.5 - i * 1.5).clamp(2.0, 8.0),
        Paint()..color = GameColors.fireOrb.withAlpha(180 - i * 50),
      );
    }
  }
}
