import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runner/game/managers/audio_manager.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/widgets/glass_card.dart';
import 'package:runner/widgets/neon_button.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _isMuted = false;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.7;
      _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.8;
      _isMuted = prefs.getBool('isMuted') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', _musicVolume);
    await prefs.setDouble('sfxVolume', _sfxVolume);
    await prefs.setBool('isMuted', _isMuted);

    _audioManager.setMusicVolume(_musicVolume);
    _audioManager.setSfxVolume(_sfxVolume);
    _audioManager.setMuted(_isMuted);
  }

  Future<void> _resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'High score reset!',
            style: TextStyle(fontFamily: 'Rajdhani', fontSize: 16),
          ),
          backgroundColor: GameColors.neonPink.withValues(alpha: 0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0a0a1a), Color(0xFF1a0a2e), Color(0xFF0a0a1a)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onBack,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: GameColors.neonCyan.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: GameColors.neonCyan,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GameColors.neonCyan,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: GameColors.neonCyan.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.headphones_rounded,
                                      color: GameColors.neonCyan,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'AUDIO',
                                      style: TextStyle(
                                        fontFamily: 'Orbitron',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: GameColors.neonCyan,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const Spacer(),

                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isMuted = !_isMuted;
                                        });
                                        _saveSettings();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: _isMuted
                                                ? GameColors.neonPink
                                                      .withValues(alpha: 0.5)
                                                : GameColors.neonGreen
                                                      .withValues(alpha: 0.5),
                                          ),
                                          color: _isMuted
                                              ? GameColors.neonPink.withValues(
                                                  alpha: 0.1,
                                                )
                                              : GameColors.neonGreen.withValues(
                                                  alpha: 0.1,
                                                ),
                                        ),
                                        child: Icon(
                                          _isMuted
                                              ? Icons.volume_off_rounded
                                              : Icons.volume_up_rounded,
                                          color: _isMuted
                                              ? GameColors.neonPink
                                              : GameColors.neonGreen,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                _buildSlider(
                                  label: 'Music',
                                  icon: Icons.music_note_rounded,
                                  value: _musicVolume,
                                  color: GameColors.neonPurple,
                                  onChanged: _isMuted
                                      ? null
                                      : (value) {
                                          setState(() => _musicVolume = value);
                                          _saveSettings();
                                        },
                                ),

                                const SizedBox(height: 20),

                                _buildSlider(
                                  label: 'SFX',
                                  icon: Icons.surround_sound_rounded,
                                  value: _sfxVolume,
                                  color: GameColors.neonGreen,
                                  onChanged: _isMuted
                                      ? null
                                      : (value) {
                                          setState(() => _sfxVolume = value);
                                          _saveSettings();
                                        },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.storage_rounded,
                                      color: GameColors.neonPink,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'DATA',
                                      style: TextStyle(
                                        fontFamily: 'Orbitron',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: GameColors.neonPink,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                NeonButton(
                                  text: 'RESET SCORE',
                                  onPressed: _resetHighScore,
                                  color: GameColors.neonPink,
                                  width: double.infinity,
                                  height: 48,
                                  fontSize: 14,
                                  icon: Icons.delete_outline_rounded,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.gamepad_rounded,
                                      color: GameColors.neonGreen,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'CONTROLS',
                                      style: TextStyle(
                                        fontFamily: 'Orbitron',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: GameColors.neonGreen,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildControlRow('←  →', 'Switch lanes'),
                                _buildControlRow('↑  SPACE', 'Jump'),
                                _buildControlRow('ESC  P', 'Pause'),
                                const SizedBox(height: 8),
                                Divider(
                                  color: GameColors.textSecondary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildControlRow('Swipe L/R', 'Switch lanes'),
                                _buildControlRow('Swipe Up', 'Jump'),
                                _buildControlRow('Tap sides', 'Switch lanes'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required IconData icon,
    required double value,
    required Color color,
    ValueChanged<double>? onChanged,
  }) {
    final isDisabled = onChanged == null;
    final displayColor = isDisabled ? color.withValues(alpha: 0.3) : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: displayColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: displayColor,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                color: displayColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: displayColor,
            inactiveTrackColor: displayColor.withValues(alpha: 0.2),
            thumbColor: displayColor,
            overlayColor: displayColor.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildControlRow(String keys, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: GameColors.textSecondary.withValues(alpha: 0.1),
              border: Border.all(
                color: GameColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                color: GameColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            action,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 15,
              color: GameColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
