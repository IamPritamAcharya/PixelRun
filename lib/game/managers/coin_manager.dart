import 'dart:math';
import 'package:flame/components.dart';
import 'package:runner/game/components/coin.dart';
import 'package:runner/game/components/obstacle.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

class CoinManager extends Component with HasGameReference<RunnerGame> {
  final Random _random = Random();
  double _timeSinceLastSpawn = 0;
  double _coinSpawnInterval = 2.0;

  void reset() {
    _timeSinceLastSpawn = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timeSinceLastSpawn += dt;

    _coinSpawnInterval =
        (2.0 -
                (game.gameState.currentSpeed - GameConfig.initialSpeed) /
                    GameConfig.maxSpeed *
                    0.8)
            .clamp(0.8, 2.0);

    if (_timeSinceLastSpawn >= _coinSpawnInterval) {
      _timeSinceLastSpawn = 0;
      if (_random.nextDouble() < GameConfig.coinSpawnChance) {
        _spawnCoins();
      }
    }
  }

  Set<int> _getOccupiedLanes() {
    final occupied = <int>{};
    final screenWidth = game.size.x;
    final roadLeft = (screenWidth - GameConfig.roadWidth) / 2;
    final laneSpacing = GameConfig.roadWidth / GameConfig.laneCount;

    for (final obstacle in game.children.whereType<Obstacle>()) {
      if (obstacle.position.y < 300) {
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

  void _spawnCoins() {
    final occupied = _getOccupiedLanes();
    final available = List.generate(
      GameConfig.laneCount,
      (i) => i,
    ).where((lane) => !occupied.contains(lane)).toList();

    if (available.isEmpty) return;

    final pattern = _random.nextInt(4);

    switch (pattern) {
      case 0:
        final lane = available[_random.nextInt(available.length)];
        game.add(Coin(lane: lane));
        break;

      case 1:
        final lane = available[_random.nextInt(available.length)];
        for (int i = 0; i < 3; i++) {
          final coin = Coin(lane: lane);
          coin.position.y = -(i * 48.0 + Coin.coinSize);
          game.add(coin);
        }
        break;

      case 2:
        for (final lane in available) {
          game.add(Coin(lane: lane));
        }
        break;

      case 3:
        for (int i = 0; i < available.length; i++) {
          final coin = Coin(lane: available[i]);
          coin.position.y = -(i * 40.0 + Coin.coinSize);
          game.add(coin);
        }
        break;
    }
  }
}
