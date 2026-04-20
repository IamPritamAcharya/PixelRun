import 'dart:math';
import 'package:flame/components.dart';
import 'package:runner/game/components/obstacle.dart';
import 'package:runner/game/components/power_up.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

class PowerUpManager extends Component with HasGameReference<RunnerGame> {
  final Random _random = Random();
  double _timeSinceLastSpawn = 0;
  double _spawnInterval = 6.0;

  void reset() {
    _timeSinceLastSpawn = 0;
    _spawnInterval = 6.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceLastSpawn += dt;

    _spawnInterval =
        (6.2 -
                (game.gameState.currentSpeed - GameConfig.initialSpeed) /
                    GameConfig.maxSpeed *
                    2.1)
            .clamp(3.2, 6.2);

    if (_timeSinceLastSpawn >= _spawnInterval) {
      _timeSinceLastSpawn = 0;
      if (_random.nextDouble() < GameConfig.powerUpSpawnChance) {
        _spawnPowerUp();
      }
    }
  }

  Set<int> _getOccupiedLanes() {
    final occupied = <int>{};
    final screenWidth = game.size.x;
    final roadLeft = (screenWidth - GameConfig.roadWidth) / 2;
    final laneSpacing = GameConfig.roadWidth / GameConfig.laneCount;

    for (final obstacle in game.children.whereType<Obstacle>()) {
      if (obstacle.position.y < 280) {
        final obsLeftX = obstacle.position.x;
        final obsRightX = obstacle.position.x + obstacle.size.x;
        for (int lane = 0; lane < GameConfig.laneCount; lane++) {
          final laneLeft = roadLeft + laneSpacing * lane;
          final laneRight = laneLeft + laneSpacing;
          if (obsLeftX < laneRight && obsRightX > laneLeft) {
            occupied.add(lane);
          }
        }
      }
    }
    return occupied;
  }

  void _spawnPowerUp() {
    final occupied = _getOccupiedLanes();
    final available = List.generate(
      GameConfig.laneCount,
      (i) => i,
    ).where((lane) => !occupied.contains(lane)).toList();
    if (available.isEmpty) return;

    final lane = available[_random.nextInt(available.length)];
    final type = PowerUpType.values[_random.nextInt(PowerUpType.values.length)];
    game.add(PowerUp(type: type, lane: lane));
  }
}
