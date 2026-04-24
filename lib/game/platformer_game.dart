import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:runner/game/components/enemy.dart';
import 'package:runner/game/components/fireball.dart';
import 'package:runner/game/components/goal_flag.dart';
import 'package:runner/game/components/particle_effect.dart';
import 'package:runner/game/components/pickup.dart';
import 'package:runner/game/components/platform.dart';
import 'package:runner/game/components/player.dart';
import 'package:runner/game/components/world_bg.dart';
import 'package:runner/game/levels/level_data.dart';
import 'package:runner/game/managers/audio_manager.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/game/utils/game_state.dart';

class PlatformerGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  late Player player;
  late WorldBackground worldBg;
  late ParticleEffect particles;
  late AudioManager audioManager;
  GoalFlag? goalFlag;

  final GameState gameState = GameState();

  double cameraX = 0;

  double _shakeTimer = 0;
  double _shakeIntensity = 0;

  double get groundSurfaceY => size.y * GameConfig.groundY;

  double _scoreTimer = 0;

  int _spawnedPlatformIndex = 0;
  int _spawnedEnemyIndex = 0;
  int _spawnedPickupIndex = 0;

  double _starTrailTimer = 0;
  int _starColorIdx = 0;
  static const _starTrailColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD700),
    Color(0xFF00FF88),
    Color(0xFF00BFFF),
    Color(0xFFFF69B4),
  ];

  bool _levelGoalTriggered = false;

  LevelData get currentLevel =>
      levels[gameState.currentLevel.clamp(0, levels.length - 1)];
  double get levelWorldLength => currentLevel.length;

  void Function()? onLevelComplete;

  @override
  Color backgroundColor() => const Color(0xFF5C94FC);

  @override
  Future<void> onLoad() async {
    await gameState.loadSettings();

    audioManager = AudioManager();
    audioManager.init(
      musicVol: gameState.musicVolume,
      sfxVol: gameState.sfxVolume,
      muted: gameState.isMuted,
    );

    worldBg = WorldBackground()..priority = 0;
    particles = ParticleEffect()..priority = 20;
    player = Player()..priority = 10;

    add(worldBg);
    add(particles);
    add(player);

    audioManager.playBackgroundMusic();
    gameState.resetForNewGame();
    _loadLevel(0);
  }

  void _loadLevel(int index) {
    gameState.currentLevel = index;
    cameraX = 0;
    _spawnedPlatformIndex = 0;
    _spawnedEnemyIndex = 0;
    _spawnedPickupIndex = 0;
    _levelGoalTriggered = false;

    worldBg.setSkyColors(currentLevel.skyColorTop, currentLevel.skyColorBottom);

    children.whereType<Platform>().toList().forEach(
      (p) => p.removeFromParent(),
    );
    children.whereType<Enemy>().toList().forEach((e) => e.removeFromParent());
    children.whereType<Pickup>().toList().forEach((p) => p.removeFromParent());
    children.whereType<Fireball>().toList().forEach(
      (f) => f.removeFromParent(),
    );
    goalFlag?.removeFromParent();
    goalFlag = null;

    player.placeOnGround();

    _snapCameraToPlayer();

    goalFlag = GoalFlag(worldX: currentLevel.length - 80);
    add(goalFlag!);
  }

  void _snapCameraToPlayer() {
    cameraX = (player.worldX - player.screenX + player.size.x / 2).clamp(
      0.0,
      levelWorldLength + 200,
    );
  }

  void startGame(int levelIndex) {
    gameState.resetForNewGame();
    gameState.currentLevel = levelIndex;
    _loadLevel(levelIndex);
    overlays.remove('GameOver');
    overlays.remove('Pause');
    overlays.remove('LevelComplete');
    _shakeTimer = 0;
    _shakeIntensity = 0;
    _scoreTimer = 0;
    gameState.playState = GamePlayState.playing;
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

  void jump() {
    if (gameState.playState == GamePlayState.playing) {
      player.jump();
    }
  }

  void moveRight(bool pressed) {
    player.movingRight = pressed;
    if (pressed) player.movingLeft = false;
  }

  void moveLeft(bool pressed) {
    player.movingLeft = pressed;
    if (pressed) player.movingRight = false;
  }

  void shootFireball() {
    if (!gameState.fireActive) return;
    final fb = Fireball(
      x: player.position.x + player.size.x,
      y: player.position.y + player.size.y / 2 - GameConfig.fireballSize / 2,
    );
    add(fb);
    particles.spawnPowerUpCollect(
      player.position.x + player.size.x,
      player.position.y + player.size.y / 2,
      GameColors.fireOrb,
    );
  }

  void useTeleport() {
    if (gameState.teleportCooldown > 0) return;

    particles.spawnTeleport(
      player.position.x + player.size.x / 2,
      player.position.y + player.size.y / 2,
    );

    player.worldX = (player.worldX + 350).clamp(0, levelWorldLength - 50);
    gameState.teleportCooldown = 4.0;
    gameState.score += 50;

    particles.spawnTeleport(
      player.position.x + player.size.x / 2,
      player.position.y + player.size.y / 2,
    );
  }

  void gameOver() {
    gameState.lives--;
    if (gameState.lives > 0) {
      player.placeOnGround();
      player.triggerHit();
      gameState.shieldTimeRemaining = 1.5;
      particles.spawnExplosion(
        player.position.x + player.size.x / 2,
        player.position.y + player.size.y / 2,
      );
      _shake(10);
      return;
    }

    gameState.playState = GamePlayState.gameOver;
    gameState.saveHighScore();
    audioManager.playCrash();
    particles.spawnExplosion(
      player.position.x + player.size.x / 2,
      player.position.y + player.size.y / 2,
    );
    _shake(14);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (gameState.playState == GamePlayState.gameOver) {
        pauseEngine();
        overlays.add('GameOver');
      }
    });
  }

  void _shake(double intensity) {
    _shakeTimer = 0.5;
    _shakeIntensity = intensity;
  }

  void _triggerLevelComplete() {
    if (_levelGoalTriggered) return;
    _levelGoalTriggered = true;
    goalFlag?.celebrate();

    gameState.playState = GamePlayState.levelComplete;
    gameState.score += 500;

    player.movingLeft = false;
    player.movingRight = false;

    gameState.markLevelCleared(gameState.currentLevel);

    Future.delayed(const Duration(milliseconds: 1200), () {
      pauseEngine();
      overlays.add('LevelComplete');
      onLevelComplete?.call();
    });
  }

  void startNextLevel() {
    overlays.remove('LevelComplete');
    resumeEngine();
    final nextLevel = (gameState.currentLevel + 1).clamp(0, levels.length - 1);
    gameState.resetForLevel(nextLevel);
    _loadLevel(nextLevel);
  }

  @override
  void update(double dt) {
    if (gameState.playState != GamePlayState.playing) return;
    super.update(dt);

    gameState.updateTimers(dt);

    final targetCameraX = player.worldX - player.screenX + player.size.x / 2;
    final lerpSpeed = 8.0;
    cameraX += (targetCameraX - cameraX) * (lerpSpeed * dt).clamp(0.0, 1.0);

    cameraX = cameraX.clamp(0.0, levelWorldLength + 200);

    _scoreTimer += dt;
    if (_scoreTimer >= 0.5) {
      _scoreTimer = 0;
      if (player.isMoving) gameState.score += GameConfig.distanceScoreRate;
    }

    if (gameState.starActive) {
      _starTrailTimer += dt;
      if (_starTrailTimer >= 0.05) {
        _starTrailTimer = 0;
        _starColorIdx = (_starColorIdx + 1) % _starTrailColors.length;
        particles.spawnStarTrail(
          player.position.x + player.size.x / 2,
          player.position.y + player.size.y / 2,
          _starTrailColors[_starColorIdx],
        );
      }
    }

    _spawnLevelObjects();

    _handlePlayerPlatformCollision();
    _handleCollisions();

    if (goalFlag != null && !goalFlag!.reached) {
      final playerMid = player.worldX + player.size.x / 2;
      if ((playerMid - currentLevel.length + 80).abs() < 60) {
        _triggerLevelComplete();
      }
    }

    if (player.position.y > size.y + 60) {
      gameOver();
    }

    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      if (_shakeTimer <= 0) {
        _shakeIntensity = 0;
        camera.viewfinder.position = Vector2.zero();
      } else {
        final sx =
            ((_shakeTimer * 100).toInt() % 2 == 0 ? 1 : -1) *
            _shakeIntensity *
            _shakeTimer;
        final sy =
            ((_shakeTimer * 130).toInt() % 2 == 0 ? 1 : -1) *
            _shakeIntensity *
            _shakeTimer *
            0.5;
        camera.viewfinder.position = Vector2(sx, sy);
      }
    }
  }

  void _spawnLevelObjects() {
    final level = currentLevel;
    final viewRight = cameraX + size.x + 300;

    while (_spawnedPlatformIndex < level.platforms.length) {
      final def = level.platforms[_spawnedPlatformIndex];
      if (def.x <= viewRight) {
        final platformTop = size.y * def.yFraction;
        add(
          Platform(
            worldX: def.x,
            worldY: platformTop,
            width: def.width,
            type: def.type,
          ),
        );
        _spawnedPlatformIndex++;
      } else {
        break;
      }
    }

    while (_spawnedEnemyIndex < level.enemies.length) {
      final def = level.enemies[_spawnedEnemyIndex];
      if (def.x <= viewRight) {
        final worldY = def.yFraction >= 0.84
            ? groundSurfaceY
            : size.y * def.yFraction;
        add(
          Enemy(
            type: def.type,
            worldX: def.x,
            worldY: worldY,
            patrolRange: def.patrolRange,
          ),
        );
        _spawnedEnemyIndex++;
      } else {
        break;
      }
    }

    while (_spawnedPickupIndex < level.pickups.length) {
      final def = level.pickups[_spawnedPickupIndex];
      if (def.x <= viewRight) {
        final screenY = size.y * def.yFraction;
        add(Pickup(type: def.type, worldX: def.x, worldY: screenY));
        _spawnedPickupIndex++;
      } else {
        break;
      }
    }
  }

  void _handlePlayerPlatformCollision() {
    final pRect = Rect.fromLTWH(
      player.position.x + 4,
      player.position.y + 2,
      player.size.x - 8,
      player.size.y - 2,
    );

    bool onAnyPlatform = false;
    bool blockedLeft = false;
    bool blockedRight = false;

    for (final platform in children.whereType<Platform>()) {
      final platRect = platform.screenRect;
      if (!pRect.overlaps(platRect)) continue;

      final playerBottom = pRect.bottom;
      final platTop = platRect.top;

      if (player.vy >= 0 &&
          playerBottom <= platTop + 14 &&
          playerBottom >= platTop - 6) {
        player.landOnPlatform(platTop);
        onAnyPlatform = true;
      } else if (platform.type == PlatformType.pipe) {
        if (pRect.right > platRect.left + 4 &&
            pRect.center.dx < platRect.center.dx) {
          blockedRight = true;
        } else if (pRect.left < platRect.right - 4 &&
            pRect.center.dx > platRect.center.dx) {
          blockedLeft = true;
        }
      }
    }

    if (blockedRight && player.movingRight) {
      player.worldX -= 4;
    }
    if (blockedLeft && player.movingLeft) {
      player.worldX += 4;
    }

    if (!onAnyPlatform && player.onGround) {
      if (player.position.y + player.size.y < groundSurfaceY - 2) {
        player.leaveGround();
      }
    }
  }

  void _handleCollisions() {
    final pRect = Rect.fromLTWH(
      player.position.x + 4,
      player.position.y + 2,
      player.size.x - 8,
      player.size.y - 2,
    );

    for (final pickup in children.whereType<Pickup>().toList()) {
      if (pickup.isCollected) continue;
      if (pRect.overlaps(pickup.screenRect)) {
        pickup.isCollected = true;
        _collectPickup(pickup);
        pickup.removeFromParent();
      }
    }

    for (final enemy in children.whereType<Enemy>().toList()) {
      if (enemy.dead) continue;
      if (!pRect.overlaps(enemy.screenRect)) continue;

      if (gameState.starActive) {
        enemy.killByFireball();
        gameState.score += 100;
        particles.spawnExplosion(
          enemy.position.x + enemy.size.x / 2,
          enemy.position.y + enemy.size.y / 2,
        );
        continue;
      }

      final playerFeetY = pRect.bottom;
      final enemyTopY = enemy.screenRect.top;
      final isStomping = playerFeetY <= enemyTopY + 14 && player.vy > 0;

      if (isStomping) {
        final stomped = enemy.stomp();
        if (stomped) {
          player.stompEnemy();
          gameState.score += 200;
          particles.spawnCoinCollect(
            enemy.position.x + enemy.size.x / 2,
            enemy.position.y + enemy.size.y / 2,
          );
        } else {
          if (gameState.shieldActive) {
            gameState.shieldTimeRemaining = 0;
            player.triggerHit();
          } else {
            gameOver();
          }
        }
      } else {
        if (gameState.shieldActive) {
          gameState.shieldTimeRemaining = 0;
          enemy.killByFireball();
          player.triggerHit();
          _shake(6);
        } else {
          gameOver();
        }
      }
    }

    for (final fb in children.whereType<Fireball>().toList()) {
      for (final enemy in children.whereType<Enemy>().toList()) {
        if (enemy.dead) continue;
        if (fb.screenRect.overlaps(enemy.screenRect)) {
          enemy.killByFireball();
          fb.removeFromParent();
          gameState.score += 150;
          particles.spawnExplosion(
            enemy.position.x + enemy.size.x / 2,
            enemy.position.y + enemy.size.y / 2,
          );
          break;
        }
      }
    }
  }

  void _collectPickup(Pickup pickup) {
    switch (pickup.type) {
      case PickupType.coin:
        gameState.score += GameConfig.coinScore;
        gameState.coins++;
        audioManager.playCoinCollect();
        particles.spawnCoinCollect(
          pickup.position.x + pickup.size.x / 2,
          pickup.position.y + pickup.size.y / 2,
        );
        break;
      case PickupType.firePower:
        gameState.fireTimeRemaining = GameConfig.fireDuration;
        particles.spawnPowerUpCollect(
          pickup.position.x + pickup.size.x / 2,
          pickup.position.y + pickup.size.y / 2,
          GameColors.fireOrb,
        );
        break;
      case PickupType.teleport:
        useTeleport();
        break;
      case PickupType.star:
        gameState.starTimeRemaining = GameConfig.starDuration;
        particles.spawnPowerUpCollect(
          pickup.position.x + pickup.size.x / 2,
          pickup.position.y + pickup.size.y / 2,
          const Color(0xFFFFFF00),
        );
        break;
      case PickupType.shield:
        gameState.shieldTimeRemaining = GameConfig.shieldDuration;
        particles.spawnPowerUpCollect(
          pickup.position.x + pickup.size.x / 2,
          pickup.position.y + pickup.size.y / 2,
          GameColors.shieldOrb,
        );
        break;
    }
  }

  final _keysHeld = <LogicalKeyboardKey>{};

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (gameState.playState != GamePlayState.playing)
      return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      _keysHeld.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _keysHeld.remove(event.logicalKey);
    }

    final wantRight =
        _keysHeld.contains(LogicalKeyboardKey.arrowRight) ||
        _keysHeld.contains(LogicalKeyboardKey.keyD);
    final wantLeft =
        _keysHeld.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysHeld.contains(LogicalKeyboardKey.keyA);

    moveRight(wantRight && !wantLeft);
    moveLeft(wantLeft && !wantRight);

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        jump();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyZ ||
          event.logicalKey == LogicalKeyboardKey.keyF) {
        shootFireball();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyT) {
        useTeleport();
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
  void onTapDown(TapDownEvent event) {
    if (gameState.playState == GamePlayState.playing) {
      jump();
    }
  }
}
