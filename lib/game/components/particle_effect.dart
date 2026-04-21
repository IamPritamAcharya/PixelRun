import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:runner/game/utils/constants.dart';

class Particle {
  double x, y;
  double vx, vy;
  double life;
  double maxLife;
  Color color;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  }) : maxLife = life;
}

class ParticleEffect extends PositionComponent {
  final List<Particle> particles = [];
  final Random _random = Random();

  void spawnExplosion(double x, double y) {
    for (int i = 0; i < 24; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 100 + _random.nextDouble() * 220;
      final colors = [
        GameColors.obstacleTall,
        GameColors.obstacleLow,
        GameColors.pixelYellow,
        const Color(0xFFFFFFFF),
      ];
      particles.add(
        Particle(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          life: 0.4 + _random.nextDouble() * 0.5,
          color: colors[_random.nextInt(colors.length)],
          size: 4 + _random.nextDouble() * 5,
        ),
      );
    }
  }

  void spawnCoinCollect(double x, double y) {
    for (int i = 0; i < 10; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 60 + _random.nextDouble() * 130;
      particles.add(
        Particle(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 60,
          life: 0.25 + _random.nextDouble() * 0.35,
          color: _random.nextBool() ? GameColors.coin : GameColors.coinDark,
          size: 3 + _random.nextDouble() * 4,
        ),
      );
    }
  }

  void spawnPowerUpCollect(double x, double y, Color color) {
    for (int i = 0; i < 14; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80 + _random.nextDouble() * 170;
      particles.add(
        Particle(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 50,
          life: 0.28 + _random.nextDouble() * 0.45,
          color: color,
          size: 3 + _random.nextDouble() * 4,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final p in particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 240 * dt;
      p.life -= dt;
      p.size = (p.size * 0.97).clamp(1, 20);
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  @override
  void render(Canvas canvas) {
    for (final p in particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(p.x, p.y),
          width: p.size,
          height: p.size,
        ),
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }
  }
}
