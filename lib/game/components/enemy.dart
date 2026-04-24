import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/levels/level_data.dart';
import 'package:runner/game/utils/constants.dart';

class Enemy extends PositionComponent with HasGameReference<PlatformerGame> {
  final EnemyType type;
  final double worldX;
  final double worldY;
  final double patrolRange;

  bool _dead = false;
  bool _isShell = false;
  double _shellSlideVx = 0;

  double _patrolTimer = 0;
  double _direction = -1.0;
  double _patrolOffset = 0;
  double _flyTimer = 0;
  double _flashTimer = 0;

  double _vy = 0;
  bool _onGround = true;

  Enemy({
    required this.type,
    required this.worldX,
    required this.worldY,
    required this.patrolRange,
  });

  bool get dead => _dead;
  bool get isShell => _isShell;

  Rect get screenRect =>
      Rect.fromLTWH(position.x + 3, position.y + 3, size.x - 6, size.y - 6);

  @override
  Future<void> onLoad() async {
    final w = type == EnemyType.flying
        ? GameConfig.enemyWidth
        : GameConfig.enemyWidth;
    final h = type == EnemyType.flying
        ? GameConfig.flyingEnemyHeight
        : GameConfig.enemyHeight;
    size = Vector2(w, h);
    priority = 5;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final screenX = worldX - game.cameraX + _patrolOffset;
    position.x = screenX;
    position.y = worldY - size.y;

    if (_dead) {
      _flashTimer += dt;
      if (_flashTimer > 1.2) removeFromParent();
      return;
    }

    if (_isShell) {
      _patrolOffset += _shellSlideVx * dt;

      if (!_onGround) {
        _vy += GameConfig.gravity * dt;
        position.y += _vy * dt;
        if (position.y + size.y >= game.groundSurfaceY) {
          position.y = game.groundSurfaceY - size.y;
          _vy = 0;
          _onGround = true;
        }
      }
      return;
    }

    switch (type) {
      case EnemyType.goomba:
      case EnemyType.spiky:
        _patrolTimer += dt;
        _patrolOffset += _direction * 60.0 * dt;
        if (_patrolOffset > patrolRange || _patrolOffset < -patrolRange) {
          _direction = -_direction;
        }
        break;
      case EnemyType.koopa:
        _patrolTimer += dt;
        _patrolOffset += _direction * 70.0 * dt;
        if (_patrolOffset > patrolRange || _patrolOffset < -patrolRange) {
          _direction = -_direction;
        }
        break;
      case EnemyType.flying:
        _flyTimer += dt;
        _patrolOffset = math.sin(_flyTimer * 1.8) * patrolRange * 0.4;
        position.y = worldY - size.y + math.sin(_flyTimer * 2.2) * 30;
        break;
    }

    if (position.x + size.x < -60) removeFromParent();
  }

  bool stomp() {
    if (type == EnemyType.spiky) return false;
    if (type == EnemyType.flying || type == EnemyType.goomba) {
      _dead = true;
      _flashTimer = 0;
      size.y = size.y * 0.35;
      return true;
    }
    if (type == EnemyType.koopa) {
      if (!_isShell) {
        _isShell = true;
        size.y = size.y * 0.55;
        return true;
      } else {
        _shellSlideVx = 340.0;
        return true;
      }
    }
    return false;
  }

  void killByFireball() {
    _dead = true;
    _flashTimer = 0;
  }

  @override
  void render(Canvas canvas) {
    if (_dead) {
      if (_flashTimer < 0.4) {
        _drawSquashed(canvas);
      }
      return;
    }

    switch (type) {
      case EnemyType.goomba:
        _drawGoomba(canvas);
        break;
      case EnemyType.koopa:
        _isShell ? _drawShell(canvas) : _drawKoopa(canvas);
        break;
      case EnemyType.flying:
        _drawFlying(canvas);
        break;
      case EnemyType.spiky:
        _drawSpiky(canvas);
        break;
    }
  }

  void _drawGoomba(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawOval(
      Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.8, h * 0.7),
      Paint()..color = GameColors.enemyGoomba,
    );

    canvas.drawOval(
      Rect.fromLTWH(w * 0.15, 0, w * 0.7, h * 0.5),
      Paint()..color = GameColors.enemyGoomba,
    );

    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.22, h * 0.18),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.58, h * 0.1, w * 0.22, h * 0.18),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.24, h * 0.12, w * 0.12, h * 0.12),
      Paint()..color = const Color(0xFF220000),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.62, h * 0.12, w * 0.12, h * 0.12),
      Paint()..color = const Color(0xFF220000),
    );

    final brow = Paint()
      ..color = GameColors.enemyGoombaDark
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(w * 0.19, h * 0.09),
      Offset(w * 0.34, h * 0.15),
      brow,
    );
    canvas.drawLine(
      Offset(w * 0.57, h * 0.15),
      Offset(w * 0.73, h * 0.09),
      brow,
    );

    canvas.drawOval(
      Rect.fromLTWH(w * 0.05, h * 0.82, w * 0.36, h * 0.18),
      Paint()..color = GameColors.enemyGoombaDark,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.59, h * 0.82, w * 0.36, h * 0.18),
      Paint()..color = GameColors.enemyGoombaDark,
    );
  }

  void _drawKoopa(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawOval(
      Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.8, h * 0.65),
      Paint()..color = GameColors.enemyKoopa,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.3, w * 0.6, h * 0.45),
      Paint()..color = GameColors.enemyKoopaDark,
    );

    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.0, w * 0.5, h * 0.35),
      Paint()..color = const Color(0xFF88CC44),
    );

    canvas.drawOval(
      Rect.fromLTWH(w * 0.55, h * 0.05, w * 0.18, h * 0.14),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.59, h * 0.07, w * 0.10, h * 0.10),
      Paint()..color = Colors.black,
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.78, w * 0.25, h * 0.22),
      Paint()..color = const Color(0xFF88CC44),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.6, h * 0.78, w * 0.25, h * 0.22),
      Paint()..color = const Color(0xFF88CC44),
    );
  }

  void _drawShell(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.05, 0, w * 0.9, h),
      Paint()..color = GameColors.enemyKoopa,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.15, w * 0.6, h * 0.7),
      Paint()..color = GameColors.enemyKoopaDark,
    );
    final cross = Paint()
      ..color = GameColors.enemyKoopa
      ..strokeWidth = 3;
    canvas.drawLine(Offset(w / 2, h * 0.15), Offset(w / 2, h * 0.85), cross);
    canvas.drawLine(Offset(w * 0.2, h / 2), Offset(w * 0.8, h / 2), cross);
  }

  void _drawFlying(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final wingY = math.sin(_flyTimer * 8) * 4;

    final wingPaint = Paint()..color = GameColors.enemyFlying.withAlpha(200);
    canvas.drawOval(
      Rect.fromLTWH(-w * 0.2, h * 0.1 + wingY, w * 0.45, h * 0.45),
      wingPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.75, h * 0.1 - wingY, w * 0.45, h * 0.45),
      wingPaint,
    );

    canvas.drawOval(
      Rect.fromLTWH(w * 0.15, h * 0.1, w * 0.7, h * 0.8),
      Paint()..color = GameColors.enemyFlying,
    );

    canvas.drawOval(
      Rect.fromLTWH(w * 0.22, h * 0.2, w * 0.22, h * 0.2),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.56, h * 0.2, w * 0.22, h * 0.2),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.26, h * 0.24, w * 0.12, h * 0.14),
      Paint()..color = Colors.black,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.60, h * 0.24, w * 0.12, h * 0.14),
      Paint()..color = Colors.black,
    );

    final beakPath = Path()
      ..moveTo(w * 0.35, h * 0.5)
      ..lineTo(w * 0.65, h * 0.5)
      ..lineTo(w * 0.5, h * 0.68)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = const Color(0xFFFFAA00));
  }

  void _drawSpiky(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawOval(
      Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.8, h * 0.7),
      Paint()..color = const Color(0xFF606060),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.15, 0, w * 0.7, h * 0.5),
      Paint()..color = const Color(0xFF606060),
    );

    final spikePaint = Paint()..color = const Color(0xFFDDDDDD);
    for (int i = 0; i < 5; i++) {
      final sx = w * (0.15 + i * 0.175);
      final path = Path()
        ..moveTo(sx, h * 0.1)
        ..lineTo(sx + w * 0.07, h * 0.28)
        ..lineTo(sx - w * 0.07, h * 0.28)
        ..close();
      canvas.drawPath(path, spikePaint);
    }

    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.14, w * 0.22, h * 0.16),
      Paint()..color = Colors.red,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.58, h * 0.14, w * 0.22, h * 0.16),
      Paint()..color = Colors.red,
    );

    canvas.drawOval(
      Rect.fromLTWH(w * 0.05, h * 0.82, w * 0.36, h * 0.18),
      Paint()..color = const Color(0xFF404040),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.59, h * 0.82, w * 0.36, h * 0.18),
      Paint()..color = const Color(0xFF404040),
    );
  }

  void _drawSquashed(Canvas canvas) {
    final w = size.x;
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * 0.5, w, size.y * 0.5),
      Paint()..color = GameColors.enemyGoomba.withAlpha(180),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.3, size.y * 0.1, w * 0.4, size.y * 0.5),
      Paint()..color = Colors.white.withAlpha(120),
    );
  }
}

class Colors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFFF0000);
}
