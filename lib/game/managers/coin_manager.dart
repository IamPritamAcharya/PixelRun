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

  void reset() => _timeSinceLastSpawn = 0;

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
    final sw = game.size.x;
    final roadTop = game.road.roadTop;
    final lh = GameConfig.laneHeight;

    for (final obstacle in game.children.whereType<Obstacle>()) {
      if (obstacle.position.x > sw * 0.5) {
        final obsTop = obstacle.position.y;
        final obsBottom = obsTop + obstacle.size.y;
        for (int lane = 0; lane < GameConfig.laneCount; lane++) {
          final laneTop = roadTop + lane * lh;
          final laneBottom = laneTop + lh;
          if (obsTop < laneBottom && obsBottom > laneTop) {
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

          coin.position.x = game.size.x + Coin.coinSize + i * 48.0;
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
          coin.position.x = game.size.x + Coin.coinSize + i * 40.0;
          game.add(coin);
        }
        break;
    }
  }
}
