import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/game_state.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/widgets/neon_button.dart';

class GameScreen extends StatefulWidget {
  final VoidCallback onMainMenu;
  const GameScreen({super.key, required this.onMainMenu});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late RunnerGame _game;

  @override
  void initState() {
    super.initState();
    _game = RunnerGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(
            game: _game,
            overlayBuilderMap: {
              'Pause': (context, game) => _PauseOverlay(
                onResume: () => _game.resumeGame(),
                onRestart: () {
                  _game.resumeEngine();
                  _game.startGame();
                },
                onMainMenu: () {
                  _game.resumeEngine();
                  widget.onMainMenu();
                },
              ),
              'GameOver': (context, game) => _GameOverOverlay(
                score: _game.gameState.score,
                highScore: _game.gameState.highScore,
                coins: _game.gameState.coins,
                isNewBest:
                    _game.gameState.score >= _game.gameState.highScore &&
                    _game.gameState.score > 0,
                onRetry: () {
                  _game.resumeEngine();
                  _game.startGame();
                },
                onMainMenu: () {
                  _game.resumeEngine();
                  widget.onMainMenu();
                },
              ),
            },
          ),

          SafeArea(
            child: StreamBuilder(
              stream: Stream.periodic(const Duration(milliseconds: 80)),
              builder: (context, _) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_buildScorePanel(), _buildPauseButton()],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildPowerUpTray(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePanel() {
    final speed = _game.gameState.currentSpeed;
    final level =
        ((speed - GameConfig.initialSpeed) / GameConfig.speedIncrement)
            .round()
            .clamp(0, 99);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xDD080818),
        border: Border(
          top: BorderSide(color: Color(0xFF3a6aaa), width: 2),
          left: BorderSide(color: Color(0xFF3a6aaa), width: 2),
          right: BorderSide(color: Color(0xFF080818), width: 2),
          bottom: BorderSide(color: Color(0xFF080818), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                '${_game.gameState.score}',
                style: GoogleFonts.pressStart2p(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                '${_game.gameState.coins}',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: GameColors.coin,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _levelColor(level).withValues(alpha: 0.25),
                  border: Border.all(color: _levelColor(level), width: 1),
                ),
                child: Text(
                  'LV.$level',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: _levelColor(level),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _levelColor(int level) {
    if (level < 5) return const Color(0xFF44ff88);
    if (level < 10) return const Color(0xFFffcc00);
    if (level < 20) return const Color(0xFFff8800);
    return const Color(0xFFff3333);
  }

  Widget _buildPowerUpTray() {
    final effects = <Widget>[];

    void addChip(String label, IconData icon, Color color, double time) {
      if (time <= 0) return;
      effects.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              border: Border.all(
                color: color.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  '${label} ${time.ceil()}s',
                  style: GoogleFonts.pressStart2p(fontSize: 7, color: color),
                ),
              ],
            ),
          ),
        ),
      );
    }

    addChip(
      'SHIELD',
      Icons.shield_rounded,
      GameColors.neonCyan,
      _game.gameState.shieldTimeRemaining,
    );
    addChip(
      'MAGNET',
      Icons.all_inclusive_rounded,
      GameColors.neonPink,
      _game.gameState.magnetTimeRemaining,
    );
    addChip(
      '2X',
      Icons.diamond_rounded,
      GameColors.pixelYellow,
      _game.gameState.doubleCoinTimeRemaining,
    );
    addChip(
      'BOOST',
      Icons.flash_on_rounded,
      GameColors.neonGreen,
      _game.gameState.boostTimeRemaining,
    );

    if (effects.isEmpty) return const SizedBox.shrink();
    return Wrap(children: effects);
  }

  Widget _buildPauseButton() {
    return GestureDetector(
      onTap: () => _game.pauseGame(),
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: Color(0xDD080818),
          border: Border(
            top: BorderSide(color: Color(0xFF3a6aaa), width: 2),
            left: BorderSide(color: Color(0xFF3a6aaa), width: 2),
            right: BorderSide(color: Color(0xFF080818), width: 2),
            bottom: BorderSide(color: Color(0xFF080818), width: 3),
          ),
        ),
        child: const Icon(Icons.pause_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume, onRestart, onMainMenu;
  const _PauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.80),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(28),
          decoration: const BoxDecoration(
            color: Color(0xFF0d0d28),
            border: Border(
              top: BorderSide(color: Color(0xFF4488ff), width: 3),
              left: BorderSide(color: Color(0xFF4488ff), width: 3),
              right: BorderSide(color: Color(0xFF080810), width: 3),
              bottom: BorderSide(color: Color(0xFF080810), width: 5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_filled_rounded,
                color: Color(0xFF4488ff),
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                'PAUSED',
                style: GoogleFonts.pressStart2p(
                  fontSize: 20,
                  color: const Color(0xFF00EEFF),
                ),
              ),
              const SizedBox(height: 28),
              NeonButton(
                text: 'RESUME',
                onPressed: onResume,
                color: const Color(0xFF22cc55),
                width: 230,
                height: 50,
                fontSize: 12,
                icon: Icons.play_arrow_rounded,
              ),
              const SizedBox(height: 10),
              NeonButton(
                text: 'RESTART',
                onPressed: onRestart,
                color: const Color(0xFF2255cc),
                width: 230,
                height: 44,
                fontSize: 10,
                icon: Icons.refresh_rounded,
              ),
              const SizedBox(height: 10),
              NeonButton(
                text: 'MENU',
                onPressed: onMainMenu,
                color: const Color(0xFF882222),
                width: 230,
                height: 44,
                fontSize: 10,
                icon: Icons.home_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatefulWidget {
  final int score, highScore, coins;
  final bool isNewBest;
  final VoidCallback onRetry, onMainMenu;
  const _GameOverOverlay({
    required this.score,
    required this.highScore,
    required this.coins,
    required this.isNewBest,
    required this.onRetry,
    required this.onMainMenu,
  });

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<double>(
      begin: -30,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) => Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: Color(0xFF0d0d22),
                  border: Border(
                    top: BorderSide(color: Color(0xFFcc2222), width: 3),
                    left: BorderSide(color: Color(0xFFcc2222), width: 3),
                    right: BorderSide(color: Color(0xFF440000), width: 3),
                    bottom: BorderSide(color: Color(0xFF440000), width: 5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GAME',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 24,
                        color: const Color(0xFFff3333),
                        shadows: const [
                          Shadow(
                            color: Color(0xFF660000),
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'OVER',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 24,
                        color: const Color(0xFFff3333),
                        shadows: const [
                          Shadow(
                            color: Color(0xFF660000),
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                    ),

                    if (widget.isNewBest) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFffd700,
                          ).withValues(alpha: 0.12),
                          border: Border.all(
                            color: const Color(0xFFffd700),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              'NEW BEST!',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 10,
                                color: const Color(0xFFffd700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    _statRow(
                      'SCORE',
                      widget.score.toString(),
                      const Color(0xFF00EEFF),
                    ),
                    const SizedBox(height: 10),
                    _statRow(
                      'BEST ',
                      widget.highScore.toString(),
                      const Color(0xFFffd700),
                    ),
                    const SizedBox(height: 10),
                    _statRow(
                      'COINS',
                      widget.coins.toString(),
                      const Color(0xFFff9900),
                    ),

                    const SizedBox(height: 28),

                    NeonButton(
                      text: 'RETRY',
                      onPressed: widget.onRetry,
                      color: const Color(0xFF22cc55),
                      width: 240,
                      height: 54,
                      fontSize: 14,
                      icon: Icons.refresh_rounded,
                    ),
                    const SizedBox(height: 12),
                    NeonButton(
                      text: 'MENU',
                      onPressed: widget.onMainMenu,
                      color: const Color(0xFF4455aa),
                      width: 240,
                      height: 46,
                      fontSize: 10,
                      icon: Icons.home_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: const Color(0xFF888888),
            ),
          ),
          Text(
            val,
            style: GoogleFonts.pressStart2p(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
