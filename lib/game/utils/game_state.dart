import 'package:shared_preferences/shared_preferences.dart';

enum GamePlayState { menu, playing, paused, gameOver }

class GameState {
  int score = 0;
  int highScore = 0;
  int coins = 0;
  double currentSpeed = 300.0;
  double distanceTraveled = 0;
  GamePlayState playState = GamePlayState.menu;

  double musicVolume = 0.7;
  double sfxVolume = 0.8;
  bool isMuted = false;

  double shieldTimeRemaining = 0;
  double magnetTimeRemaining = 0;
  double doubleCoinTimeRemaining = 0;
  double boostTimeRemaining = 0;

  bool get shieldActive => shieldTimeRemaining > 0;
  bool get magnetActive => magnetTimeRemaining > 0;
  bool get doubleCoinActive => doubleCoinTimeRemaining > 0;
  bool get boostActive => boostTimeRemaining > 0;
  double get coinMultiplier => doubleCoinActive ? 4.0 : 1.0;

  void updateTimers(double dt) {
    shieldTimeRemaining = (shieldTimeRemaining - dt).clamp(0.0, 9999.0);
    magnetTimeRemaining = (magnetTimeRemaining - dt).clamp(0.0, 9999.0);
    doubleCoinTimeRemaining = (doubleCoinTimeRemaining - dt).clamp(0.0, 9999.0);
    boostTimeRemaining = (boostTimeRemaining - dt).clamp(0.0, 9999.0);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
    musicVolume = prefs.getDouble('musicVolume') ?? 0.7;
    sfxVolume = prefs.getDouble('sfxVolume') ?? 0.8;
    isMuted = prefs.getBool('isMuted') ?? false;
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

  Future<void> resetHighScore() async {
    highScore = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
  }

  void resetPowerUps() {
    shieldTimeRemaining = 0;
    magnetTimeRemaining = 0;
    doubleCoinTimeRemaining = 0;
    boostTimeRemaining = 0;
  }

  void resetForNewGame() {
    score = 0;
    coins = 0;
    currentSpeed = 300.0;
    distanceTraveled = 0;
    playState = GamePlayState.playing;
    resetPowerUps();
  }
}
