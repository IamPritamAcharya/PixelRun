import 'dart:ui';

class GameColors {
  // Sky & World
  static const Color skyTop = Color(0xFF5C94FC);
  static const Color skyBottom = Color(0xFF9BB8FF);
  static const Color groundTop = Color(0xFF6AB04C);
  static const Color groundBody = Color(0xFF4A7C2F);
  static const Color groundDark = Color(0xFF2D5016);

  // Player
  static const Color playerBody = Color(0xFF29b6f6);
  static const Color playerDark = Color(0xFF0277bd);
  static const Color playerAccent = Color(0xFFFF6B6B);

  // Platforms
  static const Color platformTop = Color(0xFF8B6914);
  static const Color platformBody = Color(0xFF6B4F0E);
  static const Color platformDark = Color(0xFF4A3509);
  static const Color brickPlatformTop = Color(0xFFCC4444);
  static const Color brickPlatformBody = Color(0xFFAA3333);
  static const Color pipePlatformColor = Color(0xFF2E8B2E);
  static const Color pipePlatformDark = Color(0xFF1A6B1A);

  // Enemies
  static const Color enemyGoomba = Color(0xFF8B4513);
  static const Color enemyGoombaDark = Color(0xFF5C2D0A);
  static const Color enemyKoopa = Color(0xFF228B22);
  static const Color enemyKoopaDark = Color(0xFF145214);
  static const Color enemyFlying = Color(0xFFDC143C);
  static const Color enemyFlyingDark = Color(0xFF8B0000);

  // Collectibles
  static const Color coin = Color(0xFFffd700);
  static const Color coinDark = Color(0xFFff8f00);

  // Superpowers
  static const Color fireOrb = Color(0xFFFF4500);
  static const Color teleportOrb = Color(0xFF9B59B6);
  static const Color starOrb = Color(0xFFFFFF00);
  static const Color shieldOrb = Color(0xFF00BFFF);

  // Projectile
  static const Color fireball = Color(0xFFFF6600);
  static const Color fireballCore = Color(0xFFFFFF00);

  // UI
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8899bb);
  static const Color uiBg = Color(0xDD080818);
  static const Color uiBorder = Color(0xFF3a6aaa);
  static const Color neonCyan = Color(0xFF00EEFF);
  static const Color neonPink = Color(0xFFe91e63);
  static const Color neonPurple = Color(0xFF9c27b0);
  static const Color neonGreen = Color(0xFF22cc55);

  // Legacy compatibility aliases
  static const Color playerColor = playerBody;
  static const Color darkBg = Color(0xFF080818);
  static const Color darkBg2 = Color(0xFF0c0c28);
  static const Color pixelYellow = Color(0xFFffee00);
  static const Color pixelGreen = Color(0xFF22cc55);
  static const Color glassWhite = Color(0xDD0d0d28);
  static const Color glassBorder = Color(0xFF2255aa);
}

class GameConfig {
  // World
  static const double gravity = 1800.0;
  static const double groundY = 0.85; // fraction of screen height = ground surface

  // Player
  static const double playerWidth = 32.0;
  static const double playerHeight = 42.0;
  static const double playerXOffset = 100.0;
  static const double jumpVelocity = -640.0;
  static const double doubleJumpVelocity = -560.0;
  static const double moveSpeed = 0.0; // player stays at X; world scrolls

  // Scroll speed
  static const double initialSpeed = 220.0;
  static const double maxSpeed = 600.0;
  static const double speedIncrement = 15.0;
  static const int speedIncreaseInterval = 300;

  // Camera / scroll
  static const double cameraLookAhead = 0.0;

  // Enemies
  static const double enemyWidth = 36.0;
  static const double enemyHeight = 36.0;
  static const double flyingEnemyHeight = 30.0;

  // Platform sizes
  static const double platformH = 20.0;
  static const double tileSize = 32.0;

  // Scoring
  static const int coinScore = 10;
  static const int distanceScoreRate = 1;

  // Superpower durations
  static const double fireDuration = 8.0;
  static const double teleportCooldown = 0.0; // instant use
  static const double starDuration = 7.0;
  static const double shieldDuration = 6.0;

  // Fireball
  static const double fireballSpeed = 520.0;
  static const double fireballSize = 14.0;

  // Level progression
  static const double levelLength = 3000.0; // world units before next level
}
