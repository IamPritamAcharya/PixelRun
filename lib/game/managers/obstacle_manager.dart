import 'dart:math';
import 'package:flame/components.dart';
import 'package:runner/game/components/obstacle.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

class ObstacleManager extends Component with HasGameReference<RunnerGame> {
  final Random _random = Random();
  double _timeSinceLastSpawn = 0;
  double _spawnInterval = GameConfig.initialSpawnInterval;
  double _gracePeriod = 2.0;

  void reset() {
    _timeSinceLastSpawn = 0;
    _spawnInterval = GameConfig.initialSpawnInterval;
    _gracePeriod = 2.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gracePeriod > 0) {
      _gracePeriod -= dt;
      return;
    }

    _timeSinceLastSpawn += dt;

    _spawnInterval =
        (GameConfig.initialSpawnInterval -
                (game.gameState.currentSpeed - GameConfig.initialSpeed) /
                    GameConfig.maxSpeed *
                    (GameConfig.initialSpawnInterval -
                        GameConfig.minSpawnInterval))
            .clamp(
              GameConfig.minSpawnInterval,
              GameConfig.initialSpawnInterval,
            );

    if (_timeSinceLastSpawn >= _spawnInterval) {
      _timeSinceLastSpawn = 0;
      _spawnObstacles();
    }
  }

  void _spawnObstacles() {
    final pattern = _random.nextInt(10);

    if (pattern < 4) {
      final lane = _random.nextInt(GameConfig.laneCount);
      final type = _randomObstacleType();
      game.add(Obstacle(type: type, lane: lane));
    } else if (pattern < 7) {
      final freeLane = _random.nextInt(GameConfig.laneCount);
      for (int i = 0; i < GameConfig.laneCount; i++) {
        if (i != freeLane) {
          game.add(
            Obstacle(
              type: _random.nextBool()
                  ? ObstacleType.tall
                  : (_random.nextBool()
                        ? ObstacleType.low
                        : ObstacleType.puddle),
              lane: i,
            ),
          );
        }
      }
    } else if (pattern < 9) {
      final lane = _random.nextInt(GameConfig.laneCount);
      game.add(
        Obstacle(
          type: _random.nextBool() ? ObstacleType.low : ObstacleType.puddle,
          lane: lane,
        ),
      );
    } else {
      final lane = _random.nextInt(GameConfig.laneCount - 1);
      game.add(Obstacle(type: ObstacleType.wide, lane: lane));
    }
  }

  ObstacleType _randomObstacleType() {
    final roll = _random.nextInt(10);
    if (roll < 5) return ObstacleType.tall;
    if (roll < 9) return ObstacleType.low;
    return ObstacleType.wide;
  }
}
