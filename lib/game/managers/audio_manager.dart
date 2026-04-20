class AudioManager {
  double musicVolume = 0.7;
  double sfxVolume = 0.8;
  bool isMuted = false;

  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  void init({
    required double musicVol,
    required double sfxVol,
    required bool muted,
  }) {
    musicVolume = musicVol;
    sfxVolume = sfxVol;
    isMuted = muted;
  }

  void playBackgroundMusic() {
    if (isMuted) return;
  }

  void stopBackgroundMusic() {}

  void pauseBackgroundMusic() {}

  void resumeBackgroundMusic() {
    if (isMuted) return;
  }

  void playCoinCollect() {
    if (isMuted) return;
  }

  void playJump() {
    if (isMuted) return;
  }

  void playCrash() {
    if (isMuted) return;
  }

  void playLaneSwitch() {
    if (isMuted) return;
  }

  void setMusicVolume(double vol) {
    musicVolume = vol;
  }

  void setSfxVolume(double vol) {
    sfxVolume = vol;
  }

  void setMuted(bool muted) {
    isMuted = muted;
    if (muted) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  void dispose() {
    stopBackgroundMusic();
  }
}
