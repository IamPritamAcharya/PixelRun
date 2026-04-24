import 'package:shared_preferences/shared_preferences.dart';

enum GamePlayState { menu, playing, paused, gameOver, levelComplete }
enum SuperPowerType { none, fire, star, shield }

class GameState {
  int score = 0;
  int highScore = 0;
  int coins = 0;
  double currentSpeed = 0.0; // no longer auto-scrolls
  double distanceTraveled = 0;
  GamePlayState playState = GamePlayState.menu;

  double musicVolume = 0.7;
  double sfxVolume = 0.8;
  bool isMuted = false;

  // Current level index
  int currentLevel = 0;

  // Superpower timers
  double fireTimeRemaining = 0;
  double starTimeRemaining = 0;
  double shieldTimeRemaining = 0;

  // Teleport: instant use, track cooldown
  double teleportCooldown = 0;

  // Lives
  int lives = 3;

  // Level progress (persisted)
  Set<int> clearedLevels = {};
  int highestUnlockedLevel = 0;

  bool get fireActive => fireTimeRemaining > 0;
  bool get starActive => starTimeRemaining > 0;
  bool get shieldActive => shieldTimeRemaining > 0;
  bool get hasPower => fireActive || starActive || shieldActive;

  SuperPowerType get activePower {
    if (starActive) return SuperPowerType.star;
    if (fireActive) return SuperPowerType.fire;
    if (shieldActive) return SuperPowerType.shield;
    return SuperPowerType.none;
  }

  void updateTimers(double dt) {
    fireTimeRemaining = (fireTimeRemaining - dt).clamp(0.0, 9999.0);
    starTimeRemaining = (starTimeRemaining - dt).clamp(0.0, 9999.0);
    shieldTimeRemaining = (shieldTimeRemaining - dt).clamp(0.0, 9999.0);
    teleportCooldown = (teleportCooldown - dt).clamp(0.0, 9999.0);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
    musicVolume = prefs.getDouble('musicVolume') ?? 0.7;
    sfxVolume = prefs.getDouble('sfxVolume') ?? 0.8;
    isMuted = prefs.getBool('isMuted') ?? false;
    highestUnlockedLevel = prefs.getInt('highestUnlocked') ?? 0;
    final cleared = prefs.getStringList('clearedLevels') ?? [];
    clearedLevels = cleared.map(int.parse).toSet();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', musicVolume);
    await prefs.setDouble('sfxVolume', sfxVolume);
    await prefs.setBool('isMuted', isMuted);
  }

  Future<void> saveHighScore() async {
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', highScore);
    }
  }

  Future<void> markLevelCleared(int levelIndex) async {
    clearedLevels.add(levelIndex);
    if (levelIndex + 1 > highestUnlockedLevel) {
      highestUnlockedLevel = levelIndex + 1;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('clearedLevels', clearedLevels.map((e) => e.toString()).toList());
    await prefs.setInt('highestUnlocked', highestUnlockedLevel);
    await saveHighScore();
  }

  Future<void> resetHighScore() async {
    highScore = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
  }

  void resetPowerUps() {
    fireTimeRemaining = 0;
    starTimeRemaining = 0;
    shieldTimeRemaining = 0;
    teleportCooldown = 0;
  }

  void resetForNewGame() {
    score = 0;
    coins = 0;
    lives = 3;
    currentSpeed = 0;
    distanceTraveled = 0;
    currentLevel = 0;
    playState = GamePlayState.playing;
    resetPowerUps();
  }

  void resetForLevel(int levelIndex) {
    currentLevel = levelIndex;
    currentSpeed = 0;
    distanceTraveled = 0;
    playState = GamePlayState.playing;
    resetPowerUps();
  }
}
