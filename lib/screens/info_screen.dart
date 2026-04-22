import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/widgets/glass_card.dart';
import 'package:runner/widgets/neon_button.dart';

class InfoScreen extends StatelessWidget {
  final VoidCallback onBack;

  const InfoScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF080818), Color(0xFF111136), Color(0xFF080818)],
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
                        onTap: onBack,
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
                      'INFO',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GameColors.neonCyan,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: GameColors.neonCyan,
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'POWER-UPS',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.neonCyan,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _powerUpRow(
                              Icons.shield_rounded,
                              'Shield',
                              'Blocks one crash with an obstacle.',
                              GameColors.neonCyan,
                            ),
                            _powerUpRow(
                              Icons.all_inclusive_rounded,
                              'Magnet',
                              'Pulls nearby coins toward you.',
                              GameColors.neonPink,
                            ),
                            _powerUpRow(
                              Icons.diamond_rounded,
                              'Double Coins',
                              'Doubles coin value for a short burst.',
                              GameColors.pixelYellow,
                            ),
                            _powerUpRow(
                              Icons.flash_on_rounded,
                              'Boost',
                              'Temporarily increases running speed.',
                              GameColors.neonGreen,
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
                                  Icons.videogame_asset_rounded,
                                  color: GameColors.neonGreen,
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'GAMEPLAY',
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
                            _bullet('Jump over low obstacles and puddles.'),
                            _bullet('Swap lanes to dodge barriers.'),
                            _bullet('Grab power-ups before they scroll away.'),
                            _bullet(
                              'All obstacles stay inside the road lanes.',
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
                                  Icons.tips_and_updates_rounded,
                                  color: GameColors.neonPink,
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'CONTROLS',
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
                            const SizedBox(height: 16),
                            _bullet(
                              'Swipe left / right or use arrow keys to change lanes.',
                            ),
                            _bullet(
                              'Swipe up, tap top, or press jump to hop forward.',
                            ),
                            _bullet('Pause with ESC or P.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      NeonButton(
                        text: 'BACK',
                        onPressed: onBack,
                        color: GameColors.neonCyan,
                        width: double.infinity,
                        height: 52,
                        fontSize: 14,
                        icon: Icons.home_rounded,
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _powerUpRow(IconData icon, String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      color: GameColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(color: GameColors.neonCyan, fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 16,
                color: GameColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
