import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

class Coin extends PositionComponent with HasGameReference<RunnerGame> {
  final int lane;
  double _animTimer = 0;
  bool isCollected = false;

  Coin({required this.lane});

  static const double coinSize = 26.0;

  @override
  Future<void> onLoad() async {
    final screenWidth = game.size.x;
    final roadLeft = (screenWidth - GameConfig.roadWidth) / 2;
    final laneSpacing = GameConfig.roadWidth / GameConfig.laneCount;
    final laneCenter = roadLeft + laneSpacing * lane + laneSpacing / 2;
    size = Vector2(coinSize, coinSize);
    position = Vector2(laneCenter - coinSize / 2, -coinSize);
  }

  Rect get collisionRect =>
      Rect.fromLTWH(position.x + 4, position.y + 4, size.x - 8, size.y - 8);

  @override
  void update(double dt) {
    super.update(dt);
    position.y += game.gameState.currentSpeed * dt;
    _animTimer += dt * 4;

    if (game.gameState.magnetActive) {
      final playerCenter = game.player.position + game.player.size / 2;
      final coinCenter = position + size / 2;
      final dx = playerCenter.x - coinCenter.x;
      final dy = playerCenter.y - coinCenter.y;
      final distance = sqrt(dx * dx + dy * dy);
      if (distance < 170) {
        position.x += dx * dt * 7;
      }
    }

    if (position.y > game.size.y + 60) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (isCollected) return;

    final bob = sin(_animTimer) * 3.0;

    canvas.save();
    canvas.translate(0, bob);

    canvas.drawCircle(
      Offset(coinSize / 2, coinSize / 2),
      coinSize * 0.6,
      Paint()
        ..color = GameColors.coin.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final c = coinSize / 2;
    canvas.drawCircle(Offset(c, c), c - 1, Paint()..color = GameColors.coin);
    canvas.drawCircle(
      Offset(c, c),
      c - 4,
      Paint()
        ..color = GameColors.coinDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(c - 2, c - 6, 4, 12),
      Paint()..color = GameColors.coinDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(c - 5, c - 2, 10, 4),
      Paint()..color = GameColors.coinDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(c - 5, c - 8, 5, 3),
      Paint()..color = const Color(0xFFFFFF99),
    );

    canvas.restore();
  }
}
