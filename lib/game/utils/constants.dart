import 'dart:ui';

class GameColors {
  static const Color darkBg = Color(0xFF080818);
  static const Color darkBg2 = Color(0xFF0c0c28);
  static const Color roadColor = Color(0xFF2a2a2a);
  static const Color roadColor2 = Color(0xFF303030);
  static const Color roadLine = Color(0xFFffffff);

  static const Color grassColor = Color(0xFF162e1e);
  static const Color grassDark = Color(0xFF0e1e14);
  static const Color skyColor = Color(0xFF080818);

  static const Color playerColor = Color(0xFF29b6f6);
  static const Color playerDark = Color(0xFF0277bd);
  static const Color playerGlow = Color(0x3329b6f6);

  static const Color obstacleTall = Color(0xFFe53935);
  static const Color obstacleTallDark = Color(0xFF880000);
  static const Color obstacleLow = Color(0xFF8d6e63);
  static const Color obstacleLowDark = Color(0xFF4e342e);
  static const Color obstacleWide = Color(0xFF546e7a);
  static const Color obstacleWideDark = Color(0xFF263238);
  static const Color obstacleWater = Color(0xFF2467d6);
  static const Color obstacleWaterDark = Color(0xFF12308a);

  static const Color coin = Color(0xFFffd700);
  static const Color coinDark = Color(0xFFff8f00);
  static const Color coinGlow = Color(0x44ffd700);

  static const Color shield = Color(0xFF00EEFF);
  static const Color magnet = Color(0xFFe91e63);
  static const Color doubleCoins = Color(0xFFffee00);
  static const Color boost = Color(0xFF22cc55);

  static const Color pixelBrown = Color(0xFF7e5c3e);
  static const Color pixelLight = Color(0xFFe0cfb0);
  static const Color pixelAccent = Color(0xFFe91e63);
  static const Color pixelGreen = Color(0xFF22cc55);
  static const Color pixelRed = Color(0xFFf44336);
  static const Color pixelYellow = Color(0xFFffee00);
  static const Color textPrimary = Color(0xFFffffff);
  static const Color textSecondary = Color(0xFF8899bb);

  static const Color neonCyan = Color(0xFF00EEFF);
  static const Color neonPink = Color(0xFFe91e63);
  static const Color neonPurple = Color(0xFF9c27b0);
  static const Color neonGreen = Color(0xFF22cc55);
  static const Color glassWhite = Color(0xDD0d0d28);
  static const Color glassBorder = Color(0xFF2255aa);
}

class GameConfig {
  static const int laneCount = 3;
  static const double laneWidth = 80.0;
  static const double roadWidth = laneWidth * laneCount + 40;

  static const double playerWidth = 48.0;
  static const double playerHeight = 64.0;
  static const double playerBottomMargin = 120.0;
  static const double laneSwitchDuration = 0.15;

  static const double jumpHeight = 160.0;
  static const double jumpDuration = 0.60;

  static const double playerTopMargin = 84.0;

  static const double obstacleMinWidth = 60.0;
  static const double obstacleMaxWidth = 160.0;
  static const double obstacleTallHeight = 82.0;
  static const double obstacleLowHeight = 34.0;
  static const double obstacleWideHeight = 50.0;
  static const double obstacleWaterHeight = 24.0;

  static const double initialSpeed = 260.0;
  static const double maxSpeed = 800.0;
  static const double speedIncrement = 18.0;
  static const int speedIncreaseInterval = 400;

  static const double initialSpawnInterval = 1.8;
  static const double minSpawnInterval = 0.45;
  static const double spawnIntervalDecrease = 0.05;
  static const double coinSpawnChance = 0.48;
  static const double powerUpSpawnChance = 0.28;

  static const double shieldDuration = 6.0;
  static const double magnetDuration = 7.5;
  static const double doubleCoinDuration = 8.0;
  static const double boostDuration = 4.0;
  static const double boostSpeedBonus = 120.0;

  static const int coinScore = 10;
  static const int distanceScoreRate = 1;
}
