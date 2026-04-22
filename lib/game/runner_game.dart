import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runner/game/components/coin.dart';
import 'package:runner/game/components/obstacle.dart';
import 'package:runner/game/components/particle_effect.dart';
import 'package:runner/game/components/player.dart';
import 'package:runner/game/components/power_up.dart';
import 'package:runner/game/components/road.dart';
import 'package:runner/game/managers/audio_manager.dart';
import 'package:runner/game/managers/coin_manager.dart';
import 'package:runner/game/managers/obstacle_manager.dart';
import 'package:runner/game/managers/power_up_manager.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/game/utils/game_state.dart';

class RunnerGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, DragCallbacks {
  late Player player;
  late Road road;
  late ObstacleManager obstacleManager;
  late CoinManager coinManager;
  late PowerUpManager powerUpManager;
  late ParticleEffect particleEffect;
  late AudioManager audioManager;

  final GameState gameState = GameState();

  Vector2? _dragStart;
  static const double _swipeThreshold = 28;

  double _scoreTimer = 0;
  static const double _scoreInterval = 0.1;

  double _shakeTimer = 0;
  double _shakeIntensity = 0;
  int _lastSpeedLevel = 0;

  @override
  Color backgroundColor() => const Color(0xFF080818);

  @override
  Future<void> onLoad() async {
    await gameState.loadSettings();

    audioManager = AudioManager();
    audioManager.init(
      musicVol: gameState.musicVolume,
      sfxVol: gameState.sfxVolume,
      muted: gameState.isMuted,
    );

    road = Road()..priority = 0;
    obstacleManager = ObstacleManager()..priority = 1;
    coinManager = CoinManager()..priority = 2;
    powerUpManager = PowerUpManager()..priority = 2;
    player = Player()..priority = 10;
    particleEffect = ParticleEffect()..priority = 20;

    add(road);
    add(obstacleManager);
    add(coinManager);
    add(powerUpManager);
    add(player);
    add(particleEffect);

    audioManager.playBackgroundMusic();
    gameState.resetForNewGame();
  }

  void startGame() {
    gameState.resetForNewGame();
    obstacleManager.reset();
    coinManager.reset();
    _lastSpeedLevel = 0;
    _scoreTimer = 0;
    _shakeTimer = 0;
    _shakeIntensity = 0;
    camera.viewfinder.position = Vector2.zero();

    children.whereType<Obstacle>().toList().forEach((o) {
      o.removeFromParent();
    });
    children.whereType<Coin>().toList().forEach((c) {
      c.removeFromParent();
    });
    children.whereType<PowerUp>().toList().forEach((p) {
      p.removeFromParent();
    });

    player.currentLane = 1;
    player.targetLane = 1;
    player.resetPose();

    overlays.remove('GameOver');
    overlays.remove('Pause');
  }

  void pauseGame() {
    if (gameState.playState == GamePlayState.playing) {
      gameState.playState = GamePlayState.paused;
      pauseEngine();
      audioManager.pauseBackgroundMusic();
      overlays.add('Pause');
    }
  }

  void resumeGame() {
    if (gameState.playState == GamePlayState.paused) {
      gameState.playState = GamePlayState.playing;
      overlays.remove('Pause');
      resumeEngine();
      audioManager.resumeBackgroundMusic();
    }
  }

  void activatePowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        gameState.shieldTimeRemaining = GameConfig.shieldDuration;
        break;
      case PowerUpType.magnet:
        gameState.magnetTimeRemaining = GameConfig.magnetDuration;
        break;
      case PowerUpType.doubleCoins:
        gameState.doubleCoinTimeRemaining = GameConfig.doubleCoinDuration;
        break;
      case PowerUpType.boost:
        gameState.boostTimeRemaining = GameConfig.boostDuration;
        break;
    }

    particleEffect.spawnPowerUpCollect(
      player.position.x + player.size.x / 2,
      player.position.y + player.size.y / 2,
      _powerUpColor(type),
    );
  }

  Color _powerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return GameColors.shield;
      case PowerUpType.magnet:
        return GameColors.magnet;
      case PowerUpType.doubleCoins:
        return GameColors.doubleCoins;
      case PowerUpType.boost:
        return GameColors.boost;
    }
  }

  void gameOver() {
    gameState.playState = GamePlayState.gameOver;
    gameState.saveHighScore();
    audioManager.playCrash();

    _shakeTimer = 0.5;
    _shakeIntensity = 12;

    particleEffect.spawnExplosion(
      player.position.x + player.size.x / 2,
      player.position.y + player.size.y / 2,
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (gameState.playState == GamePlayState.gameOver) {
        pauseEngine();
        overlays.add('GameOver');
      }
    });
  }

  @override
  void update(double dt) {
    if (gameState.playState != GamePlayState.playing) return;

    super.update(dt);
    gameState.updateTimers(dt);

    _scoreTimer += dt;
    if (_scoreTimer >= _scoreInterval) {
      _scoreTimer = 0;
      gameState.score += GameConfig.distanceScoreRate;
      gameState.distanceTraveled += gameState.currentSpeed * _scoreInterval;
    }

    final speedLevel = gameState.score ~/ GameConfig.speedIncreaseInterval;
    final baseSpeed =
        (GameConfig.initialSpeed + speedLevel * GameConfig.speedIncrement)
            .clamp(GameConfig.initialSpeed, GameConfig.maxSpeed);

    gameState.currentSpeed =
        (baseSpeed + (gameState.boostActive ? GameConfig.boostSpeedBonus : 0))
            .clamp(
              GameConfig.initialSpeed,
              GameConfig.maxSpeed + GameConfig.boostSpeedBonus,
            );

    if (speedLevel > _lastSpeedLevel) {
      _lastSpeedLevel = speedLevel;
      if (_shakeTimer <= 0) {
        _shakeTimer = 0.2;
        _shakeIntensity = 4;
      }
    }

    _checkCollisions();

    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      if (_shakeTimer <= 0) {
        _shakeIntensity = 0;
        camera.viewfinder.position = Vector2.zero();
      } else {
        final shakeX =
            ((_shakeTimer * 100).toInt() % 2 == 0 ? 1 : -1) *
            _shakeIntensity *
            _shakeTimer;
        final shakeY =
            ((_shakeTimer * 130).toInt() % 2 == 0 ? 1 : -1) *
            _shakeIntensity *
            _shakeTimer *
            0.5;
        camera.viewfinder.position = Vector2(shakeX, shakeY);
      }
    }
  }

  void _checkCollisions() {
    for (final powerUp in children.whereType<PowerUp>().toList()) {
      if (_isColliding(player, powerUp)) {
        activatePowerUp(powerUp.type);
        powerUp.removeFromParent();
      }
    }

    for (final obstacle in children.whereType<Obstacle>().toList()) {
      if (_isColliding(player, obstacle)) {
        if (gameState.shieldActive) {
          gameState.shieldTimeRemaining = 0;
          obstacle.removeFromParent();

          particleEffect.spawnExplosion(
            obstacle.position.x + obstacle.size.x / 2,
            obstacle.position.y + obstacle.size.y / 2,
          );

          player.triggerInvincibilityFlash();
          continue;
        }

        gameOver();
        return;
      }
    }

    for (final coin in children.whereType<Coin>().toList()) {
      final attracted = gameState.magnetActive && _coinNearPlayer(coin);

      if (!coin.isCollected && (attracted || _isColliding(player, coin))) {
        coin.isCollected = true;

        final coinPoints = (GameConfig.coinScore * gameState.coinMultiplier)
            .round();
        gameState.score += coinPoints;
        gameState.coins++;

        audioManager.playCoinCollect();

        particleEffect.spawnCoinCollect(
          coin.position.x + coin.size.x / 2,
          coin.position.y + coin.size.y / 2,
        );

        coin.removeFromParent();
      }
    }
  }

  bool _coinNearPlayer(Coin coin) {
    final pc = player.position + player.size / 2;
    final cc = coin.position + coin.size / 2;
    final dx = (pc.x - cc.x).abs();
    final dy = (pc.y - cc.y).abs();
    return dx < 110 && dy < 160;
  }

  bool _isColliding(PositionComponent a, PositionComponent b) {
    if (a is Player && b is Obstacle && a.isAirborneSafe) {
      return false;
    }

    final aRect = _rectForComponent(a);
    final bRect = _rectForComponent(b);
    return aRect.overlaps(bRect);
  }

  Rect _rectForComponent(PositionComponent c) {
    if (c is Player) {
      const shrinkX = 10.0;
      const shrinkTopBottom = 8.0;
      return Rect.fromLTWH(
        c.position.x + shrinkX,
        c.position.y + shrinkTopBottom,
        c.size.x - (shrinkX * 2),
        c.size.y - shrinkTopBottom * 2,
      );
    }

    if (c is Coin) {
      return Rect.fromLTWH(
        c.position.x + 6,
        c.position.y + 6,
        c.size.x - 12,
        c.size.y - 12,
      );
    }

    if (c is Obstacle) {
      return c.collisionRect;
    }

    return Rect.fromLTWH(
      c.position.x + 6,
      c.position.y + 4,
      c.size.x - 12,
      c.size.y - 6,
    );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && gameState.playState == GamePlayState.playing) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        player.moveLeft();
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        player.moveRight();
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        player.jump();
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        player.jumpBackward();
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.keyP) {
        pauseGame();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragStart = event.localPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _dragStart = null;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStart == null) return;
    if (gameState.playState != GamePlayState.playing) return;

    final current = event.localEndPosition;
    final delta = current - _dragStart!;

    if (delta.length > _swipeThreshold) {
      if (delta.x.abs() > delta.y.abs()) {
        if (delta.x > 0) {
          player.moveRight();
        } else {
          player.moveLeft();
        }
      } else {
        if (delta.y < 0) {
          player.jump();
        } else {
          player.jumpBackward();
        }
      }
      _dragStart = current;
    }
  }
}
