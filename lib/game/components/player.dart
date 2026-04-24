import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/utils/constants.dart';

class Player extends PositionComponent with HasGameReference<PlatformerGame> {
  double _vy = 0.0;
  double get vy => _vy;
  double _vx = 0.0;
  bool _onGround = false;
  bool _jumping = false;
  bool _canDoubleJump = false;
  bool _hasDoubleJumped = false;

  double worldX = 0.0;

  bool movingRight = false;
  bool movingLeft = false;

  static const double walkSpeed = 230.0;
  static const double runSpeed = 320.0;

  double _legTimer = 0;
  bool _legPhase = false;
  double _flashTimer = 0;
  bool _visible = true;
  double _runTimer = 0;

  double _starColorTimer = 0;
  int _starColorIndex = 0;
  static const _starColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD700),
    Color(0xFF00FF88),
    Color(0xFF00BFFF),
    Color(0xFFFF69B4),
    Color(0xFFAA88FF),
  ];

  double get screenX => game.size.x * 0.28;

  bool get onGround => _onGround;
  bool get isMoving => movingRight || movingLeft;

  @override
  Future<void> onLoad() async {
    size = Vector2(GameConfig.playerWidth, GameConfig.playerHeight);
    priority = 10;
  }

  void placeOnGround() {
    final cam = game.cameraX;
    worldX = cam + screenX - size.x / 2;
    position = Vector2(screenX - size.x / 2, game.groundSurfaceY - size.y);
    _vy = 0;
    _vx = 0;
    _onGround = true;
    _jumping = false;
    _hasDoubleJumped = false;
    _canDoubleJump = false;
    movingRight = false;
    movingLeft = false;
  }

  void jump() {
    if (_onGround) {
      _vy = GameConfig.jumpVelocity;
      _onGround = false;
      _jumping = true;
      _canDoubleJump = true;
      _hasDoubleJumped = false;
      game.audioManager.playJump();
      add(
        ScaleEffect.to(
          Vector2(0.80, 1.25),
          EffectController(duration: 0.06, reverseDuration: 0.10),
        ),
      );
    } else if (_canDoubleJump && !_hasDoubleJumped) {
      _vy = GameConfig.doubleJumpVelocity;
      _hasDoubleJumped = true;
      game.audioManager.playJump();
      add(
        ScaleEffect.to(
          Vector2(0.85, 1.18),
          EffectController(duration: 0.05, reverseDuration: 0.09),
        ),
      );
    }
  }

  void triggerHit() {
    _flashTimer = 1.5;
  }

  void stompEnemy() {
    _vy = GameConfig.jumpVelocity * 0.6;
    _onGround = false;
    _jumping = true;
    _canDoubleJump = true;
    _hasDoubleJumped = false;
  }

  bool get isStarActive => game.gameState.starActive;
  bool get isShieldActive => game.gameState.shieldActive;

  @override
  void update(double dt) {
    super.update(dt);

    final speed = isStarActive ? runSpeed * 1.3 : runSpeed;
    if (movingRight) {
      _vx = speed;
    } else if (movingLeft) {
      _vx = -speed;
    } else {
      _vx = 0;
    }

    worldX += _vx * dt;

    worldX = worldX.clamp(0.0, game.levelWorldLength + 200);

    if (!_onGround) {
      _vy += GameConfig.gravity * dt;
    }
    position.y += _vy * dt;

    final gY = game.groundSurfaceY;
    if (position.y + size.y >= gY) {
      position.y = gY - size.y;
      _vy = 0;
      if (!_onGround) {
        _onGround = true;
        _jumping = false;
        _hasDoubleJumped = false;
        add(
          ScaleEffect.to(
            Vector2(1.15, 0.85),
            EffectController(duration: 0.05, reverseDuration: 0.09),
          ),
        );
      }
    }

    position.x = screenX - size.x / 2;

    _legTimer += dt * (isMoving ? (isStarActive ? 18 : 9) : 3);
    if (_legTimer >= 1.0) {
      _legTimer = 0;
      _legPhase = !_legPhase;
    }

    _runTimer +=
        dt *
        (movingRight
            ? 1
            : movingLeft
            ? -1
            : 0) *
        4;

    if (_flashTimer > 0) {
      _flashTimer -= dt;
      _visible = (_flashTimer * 10).toInt() % 2 == 0;
    } else {
      _visible = true;
    }

    if (isStarActive) {
      _starColorTimer += dt * 8;
      if (_starColorTimer >= 1.0) {
        _starColorTimer = 0;
        _starColorIndex = (_starColorIndex + 1) % _starColors.length;
      }
    }
  }

  void landOnPlatform(double platformTopY) {
    if (_vy >= 0) {
      position.y = platformTopY - size.y;
      _vy = 0;
      if (!_onGround) {
        _onGround = true;
        _jumping = false;
        _hasDoubleJumped = false;
      }
    }
  }

  void leaveGround() {
    _onGround = false;
  }

  @override
  void render(Canvas canvas) {
    if (!_visible) return;

    final bodyColor = isStarActive
        ? _starColors[_starColorIndex]
        : isShieldActive
        ? const Color(0xFF00BFFF)
        : GameColors.playerBody;

    final darkColor = isStarActive
        ? bodyColor.withAlpha(180)
        : GameColors.playerDark;

    if (isShieldActive) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.75,
        Paint()
          ..color = const Color(0x4400BFFF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.74,
        Paint()
          ..color = const Color(0x5500BFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (isStarActive) {
      for (int i = 0; i < 5; i++) {
        final angle = (i / 5) * math.pi * 2 + _starColorTimer * math.pi * 2;
        final r =
            size.x * 0.7 + math.sin(_starColorTimer * math.pi * 2 + i) * 4;
        canvas.drawCircle(
          Offset(
            size.x / 2 + math.cos(angle) * r,
            size.y / 2 + math.sin(angle) * r,
          ),
          3.5,
          Paint()
            ..color = _starColors[(i + _starColorIndex) % _starColors.length],
        );
      }
    }

    _drawCharacter(canvas, bodyColor, darkColor);
  }

  void _drawCharacter(Canvas canvas, Color bodyColor, Color darkColor) {
    final pw = size.x;
    final ph = size.y;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pw / 2, ph + 3),
        width: pw * 0.8,
        height: ph * 0.12,
      ),
      Paint()..color = const Color(0x44000000),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pw * 0.14, ph * 0.02, pw * 0.72, ph * 0.52),
        const Radius.circular(3),
      ),
      Paint()..color = bodyColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pw * 0.14, ph * 0.02, pw * 0.72, ph * 0.52),
        const Radius.circular(3),
      ),
      Paint()
        ..color = darkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pw * 0.20, ph * 0.04, pw * 0.60, ph * 0.24),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF0d1020),
    );

    canvas.drawRect(
      Rect.fromLTWH(pw * 0.22, ph * 0.05, pw * 0.56, ph * 0.06),
      Paint()..color = const Color(0x44FFFFFF),
    );

    final eyeColor = _jumping
        ? const Color(0xFFFFFF00)
        : isStarActive
        ? _starColors[(_starColorIndex + 2) % _starColors.length]
        : GameColors.neonCyan;

    canvas.drawRect(
      Rect.fromLTWH(pw * 0.25, ph * 0.08, pw * 0.20, ph * 0.12),
      Paint()
        ..color = eyeColor.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.55, ph * 0.08, pw * 0.20, ph * 0.12),
      Paint()
        ..color = eyeColor.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawRect(
      Rect.fromLTWH(pw * 0.26, ph * 0.09, pw * 0.18, ph * 0.11),
      Paint()..color = eyeColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(pw * 0.56, ph * 0.09, pw * 0.18, ph * 0.11),
      Paint()..color = eyeColor,
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
    const legFrac = 0.32;

    final leftOff = _jumping
        ? -ph * 0.06
        : (isMoving ? (_legPhase ? -ph * 0.09 : ph * 0.06) : 0.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          pw * 0.15,
          legY + leftOff.clamp(-ph * 0.10, 0),
          legW,
          ph * legFrac + leftOff.abs() * 0.2,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = darkColor,
    );
    final rightOff = -leftOff;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          pw * 0.58,
          legY + rightOff.clamp(-ph * 0.10, 0),
          legW,
          ph * legFrac + rightOff.abs() * 0.2,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = darkColor,
    );

    const bootColor = Color(0xFF1a2030);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pw * 0.10, legY + ph * legFrac - 2, legW + 8, 11),
        const Radius.circular(2),
      ),
      Paint()..color = bootColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pw * 0.53, legY + ph * legFrac - 2, legW + 8, 11),
        const Radius.circular(2),
      ),
      Paint()..color = bootColor,
    );

    final armOff = _jumping
        ? -ph * 0.07
        : (isMoving ? (_legPhase ? ph * 0.07 : -ph * 0.07) : 0.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, ph * 0.07 + armOff, pw * 0.14, ph * 0.28),
        const Radius.circular(2),
      ),
      Paint()..color = bodyColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pw * 0.86, ph * 0.07 - armOff, pw * 0.14, ph * 0.28),
        const Radius.circular(2),
      ),
      Paint()..color = bodyColor,
    );

    if (game.gameState.fireActive) {
      final fireT = _starColorTimer;
      canvas.drawCircle(
        Offset(pw * 0.93, ph * 0.14 - armOff),
        6,
        Paint()
          ..color = GameColors.fireOrb.withAlpha(80)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        Offset(pw * 0.93, ph * 0.14 - armOff),
        5,
        Paint()..color = GameColors.fireOrb,
      );
      canvas.drawCircle(
        Offset(pw * 0.93, ph * 0.14 - armOff),
        3,
        Paint()..color = GameColors.fireballCore,
      );
    }

    if (movingLeft) {
      _drawChevron(
        canvas,
        pw * 0.86,
        ph * 0.22,
        true,
        bodyColor.withAlpha(180),
      );
    }
  }

  void _drawChevron(Canvas canvas, double x, double y, bool left, Color color) {
    final path = Path();
    final d = left ? 4.0 : -4.0;
    path.moveTo(x + d, y - 5);
    path.lineTo(x - d, y);
    path.lineTo(x + d, y + 5);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
