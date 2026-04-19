import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

class Player extends PositionComponent
    with CollisionCallbacks, HasGameReference<RunnerGame> {
  int currentLane = 1;
  int targetLane = 1;

  bool isJumping = false;
  bool _jumpingBackward = false;
  double _jumpTime = 0;
  double _baseY = 0;
  double _jumpProgress = 0.0;

  double _currentX = 0;
  double _targetX = 0;

  double _legTimer = 0;
  bool _legPhase = false;
  double _armSwing = 0;

  double _flashTimer = 0;
  bool _visible = true;

  static const Color _white = Color(0xFFFFFFFF);

  bool get isAirborneSafe {
    if (!isJumping) return false;
    final groundY = _baseY - size.y;
    final heightAboveGround = groundY - position.y;
    return heightAboveGround > 8;
  }

  @override
  Future<void> onLoad() async {
    final screenWidth = game.size.x;
    _baseY = game.size.y - GameConfig.playerBottomMargin;
    size = Vector2(GameConfig.playerWidth, GameConfig.playerHeight);
    _currentX = _getLaneX(currentLane, screenWidth);
    _targetX = _currentX;
    position = Vector2(_currentX - size.x / 2, _baseY - size.y);
    add(RectangleHitbox());
  }

  void resetPose() {
    isJumping = false;
    _jumpingBackward = false;
    _jumpTime = 0;
    _jumpProgress = 0;
    _currentX = _getLaneX(currentLane, game.size.x);
    _targetX = _currentX;
    position = Vector2(_currentX - size.x / 2, _baseY - size.y);
  }

  double _getLaneX(int lane, double screenWidth) {
    final roadLeft = (screenWidth - GameConfig.roadWidth) / 2;
    final laneSpacing = GameConfig.roadWidth / GameConfig.laneCount;
    return roadLeft + laneSpacing * lane + laneSpacing / 2;
  }

  void moveLeft() {
    if (currentLane > 0) {
      currentLane--;
      targetLane = currentLane;
      _targetX = _getLaneX(currentLane, game.size.x);
      game.audioManager.playLaneSwitch();
    }
  }

  void moveRight() {
    if (currentLane < GameConfig.laneCount - 1) {
      currentLane++;
      targetLane = currentLane;
      _targetX = _getLaneX(currentLane, game.size.x);
      game.audioManager.playLaneSwitch();
    }
  }

  void jump() {
    if (!isJumping) {
      isJumping = true;
      _jumpingBackward = false;
      _jumpTime = 0;
      _jumpProgress = 0.0;
      game.audioManager.playJump();
      add(
        ScaleEffect.to(
          Vector2(0.82, 1.20),
          EffectController(duration: 0.07, reverseDuration: 0.12),
        ),
      );
    }
  }

  void jumpBackward() {
    if (!isJumping) {
      isJumping = true;
      _jumpingBackward = true;
      _jumpTime = 0;
      _jumpProgress = 0.0;
      game.audioManager.playJump();
      add(
        ScaleEffect.to(
          Vector2(1.10, 1.15),
          EffectController(duration: 0.07, reverseDuration: 0.12),
        ),
      );
    }
  }

  void triggerInvincibilityFlash() {
    _flashTimer = 1.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _currentX = _lerp(_currentX, _targetX, dt * 14);
    position.x = _currentX - size.x / 2;

    if (isJumping) {
      _jumpTime += dt;
      _jumpProgress = (_jumpTime / GameConfig.jumpDuration).clamp(0.0, 1.0);

      final arc = _sinArc(_jumpProgress);
      final groundY = _baseY - size.y;
      position.y = groundY - GameConfig.jumpHeight * arc;

      if (_jumpProgress >= 1.0) {
        isJumping = false;
        _jumpingBackward = false;
        position.y = groundY;
        add(
          ScaleEffect.to(
            Vector2(1.12, 0.88),
            EffectController(duration: 0.06, reverseDuration: 0.10),
          ),
        );
      }
    }

    _legTimer += dt * 9;
    if (_legTimer >= 1.0) {
      _legTimer = 0;
      _legPhase = !_legPhase;
    }
    _armSwing = _legPhase ? 1.0 : -1.0;

    if (_flashTimer > 0) {
      _flashTimer -= dt;
      _visible = (_flashTimer * 10).toInt() % 2 == 0;
    } else {
      _visible = true;
    }
  }

  double _sinArc(double t) {
    return (3.14159265 * t < 3.14159265) ? _sin01(t) : 0.0;
  }

  double _sin01(double t) {
    return 4.0 * t * (1.0 - t);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);

  @override
  void render(Canvas canvas) {
    if (!_visible) return;

    final groundY = _baseY - size.y;
    final heightAboveGround = groundY - position.y;
    final airFraction = (heightAboveGround / GameConfig.jumpHeight).clamp(
      0.0,
      1.0,
    );
    final shadowW = size.x * (0.75 - airFraction * 0.40);
    final shadowAlpha = (0.40 * (1 - airFraction * 0.75)).clamp(0.05, 0.40);
    final shadowY = heightAboveGround + size.y + 6;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, shadowY.clamp(size.y + 2, size.y + 12)),
        width: shadowW.clamp(8.0, size.x),
        height: 6,
      ),
      Paint()..color = Color.fromRGBO(0, 0, 0, shadowAlpha),
    );

    _drawCharacter(canvas);
  }

  void _drawCharacter(Canvas canvas) {
    final pw = size.x;
    final ph = size.y;

    if (_jumpingBackward && isJumping) {
      canvas.save();
      final cx = pw / 2;
      final cy = ph / 2;

      final groundY = _baseY - size.y;
      final airFrac = ((groundY - position.y) / GameConfig.jumpHeight).clamp(
        0.0,
        1.0,
      );
      final angle = -0.26 * airFrac;
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.translate(-cx, -cy);
    }

    canvas.drawRect(
      Rect.fromLTWH(pw * 0.14, ph * 0.02, pw * 0.72, ph * 0.52),
      Paint()..color = GameColors.playerColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.14, ph * 0.02, pw * 0.72, ph * 0.52),
      Paint()
        ..color = GameColors.playerDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.20, ph * 0.06, pw * 0.16, ph * 0.20),
      Paint()..color = const Color(0x55FFFFFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.40, ph * 0.08, pw * 0.06, ph * 0.38),
      Paint()..color = GameColors.playerDark.withValues(alpha: 0.5),
    );

    canvas.drawRect(
      Rect.fromLTWH(pw * 0.20, ph * 0.04, pw * 0.60, ph * 0.24),
      Paint()..color = const Color(0xFF0d1020),
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.22, ph * 0.05, pw * 0.56, ph * 0.07),
      Paint()..color = const Color(0x33FFFFFF),
    );

    Color eyeColor;
    if (_jumpingBackward && isJumping) {
      eyeColor = const Color(0xFFFF6600);
    } else if (isJumping) {
      eyeColor = const Color(0xFFFFFF00);
    } else {
      eyeColor = const Color(0xFF00EEFF);
    }

    canvas.drawRect(
      Rect.fromLTWH(pw * 0.26, ph * 0.09, pw * 0.18, ph * 0.11),
      Paint()..color = eyeColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.56, ph * 0.09, pw * 0.18, ph * 0.11),
      Paint()..color = eyeColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.30, ph * 0.11, pw * 0.09, ph * 0.07),
      Paint()..color = const Color(0xFF001020),
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.60, ph * 0.11, pw * 0.09, ph * 0.07),
      Paint()..color = const Color(0xFF001020),
    );

    canvas.drawRect(
      Rect.fromLTWH(pw * 0.14, ph * 0.54, pw * 0.72, ph * 0.06),
      Paint()..color = const Color(0xFF1a3a5e),
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.42, ph * 0.54, pw * 0.16, ph * 0.06),
      Paint()..color = const Color(0xFFffd700),
    );

    final legW = pw * 0.26;
    final legY = ph * 0.60;
    const legH = 0.32;

    double leftOff;
    if (isJumping) {
      leftOff = _jumpingBackward ? ph * 0.06 : -ph * 0.06;
    } else {
      leftOff = _legPhase ? -ph * 0.07 : ph * 0.05;
    }

    canvas.drawRect(
      Rect.fromLTWH(
        pw * 0.15,
        legY + leftOff.clamp(-ph * 0.08, 0),
        legW,
        ph * legH + leftOff.abs() * 0.2,
      ),
      Paint()..color = GameColors.playerDark,
    );

    final rightOff = -leftOff;
    canvas.drawRect(
      Rect.fromLTWH(
        pw * 0.58,
        legY + rightOff.clamp(-ph * 0.08, 0),
        legW,
        ph * legH + rightOff.abs() * 0.2,
      ),
      Paint()..color = GameColors.playerDark,
    );

    final bootColor = const Color(0xFF1a2030);
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.12, legY + ph * legH - 2, legW + 6, 10),
      Paint()..color = bootColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.55, legY + ph * legH - 2, legW + 6, 10),
      Paint()..color = bootColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.12, legY + ph * legH + 5, legW + 6, 3),
      Paint()..color = const Color(0xFFDDDDDD),
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.55, legY + ph * legH + 5, legW + 6, 3),
      Paint()..color = const Color(0xFFDDDDDD),
    );

    final armOff = isJumping
        ? (_jumpingBackward ? ph * 0.06 : -ph * 0.06)
        : _armSwing * ph * 0.06;
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.00, ph * 0.07 + armOff, pw * 0.14, ph * 0.28),
      Paint()..color = GameColors.playerColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.00, ph * 0.07 + armOff, pw * 0.14, ph * 0.28),
      Paint()
        ..color = GameColors.playerDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.86, ph * 0.07 - armOff, pw * 0.14, ph * 0.28),
      Paint()..color = GameColors.playerColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.86, ph * 0.07 - armOff, pw * 0.14, ph * 0.28),
      Paint()
        ..color = GameColors.playerDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    if (_jumpingBackward && isJumping) {
      canvas.restore();
    }
  }
}
