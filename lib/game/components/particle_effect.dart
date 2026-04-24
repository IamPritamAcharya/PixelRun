import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/utils/constants.dart';

class ParticleEffect extends PositionComponent
    with HasGameReference<PlatformerGame> {
  final List<_Particle> _particles = [];

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 20;
  }

  void spawnExplosion(double x, double y) {
    final rng = math.Random();
    for (int i = 0; i < 14; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 80 + rng.nextDouble() * 180;
      _particles.add(
        _Particle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 60,
          color: [
            GameColors.fireOrb,
            const Color(0xFFFF8800),
            const Color(0xFFFFFF00),
          ][rng.nextInt(3)],
          radius: 3 + rng.nextDouble() * 4,
          life: 0.5 + rng.nextDouble() * 0.4,
        ),
      );
    }
  }

  void spawnCoinCollect(double x, double y) {
    final rng = math.Random();
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (rng.nextDouble() - 0.5) * math.pi;
      _particles.add(
        _Particle(
          x: x,
          y: y,
          vx: math.cos(angle) * 60,
          vy: math.sin(angle) * 60 - 80,
          color: GameColors.coin,
          radius: 3,
          life: 0.4,
        ),
      );
    }
  }

  void spawnPowerUpCollect(double x, double y, Color color) {
    final rng = math.Random();
    for (int i = 0; i < 10; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      _particles.add(
        _Particle(
          x: x,
          y: y,
          vx: math.cos(angle) * 120,
          vy: math.sin(angle) * 120 - 40,
          color: color,
          radius: 4,
          life: 0.6 + rng.nextDouble() * 0.3,
          gravity: true,
        ),
      );
    }
  }

  void spawnStarTrail(double x, double y, Color color) {
    _particles.add(
      _Particle(
        x: x,
        y: y,
        vx: -20,
        vy: -10,
        color: color.withAlpha(200),
        radius: 5,
        life: 0.25,
      ),
    );
  }

  void spawnTeleport(double x, double y) {
    final rng = math.Random();
    for (int i = 0; i < 18; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 40 + rng.nextDouble() * 100;
      _particles.add(
        _Particle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: GameColors.teleportOrb,
          radius: 3 + rng.nextDouble() * 3,
          life: 0.4 + rng.nextDouble() * 0.3,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final p in _particles) {
      p.update(dt);
    }
    _particles.removeWhere((p) => p.isDead);
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * p.lifeFraction,
        Paint()..color = p.color.withAlpha((p.lifeFraction * 255).toInt()),
      );
    }
  }
}

class _Particle {
  double x, y, vx, vy;
  Color color;
  double radius;
  double life;
  double elapsed = 0;
  bool gravity;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.radius,
    required this.life,
    this.gravity = false,
  });

  void update(double dt) {
    elapsed += dt;
    x += vx * dt;
    y += vy * dt;
    if (gravity) vy += 400 * dt;
    vx *= 0.95;
    vy *= 0.95;
  }

  bool get isDead => elapsed >= life;
  double get lifeFraction => (1 - elapsed / life).clamp(0.0, 1.0);
}
