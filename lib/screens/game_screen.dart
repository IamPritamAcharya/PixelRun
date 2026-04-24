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
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScorePanel(),
                    _buildPowerUpTray(),
                    _buildPauseButton(),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 14,
            bottom: 16,
            child: SafeArea(
              minimum: const EdgeInsets.only(right: 0, bottom: 0),
              child: _buildJumpButton(),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(
        color: Color(0xDD080818),
        border: Border(
          top: BorderSide(color: Color(0xFF3a6aaa), width: 2),
          left: BorderSide(color: Color(0xFF3a6aaa), width: 2),
          right: BorderSide(color: Color(0xFF080818), width: 2),
          bottom: BorderSide(color: Color(0xFF080818), width: 3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 5),
          Text(
            '${_game.gameState.score}',
            style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text('🪙', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            '${_game.gameState.coins}',
            style: GoogleFonts.pressStart2p(
              fontSize: 10,
              color: GameColors.coin,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: _levelColor(level).withValues(alpha: 0.22),
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
          padding: const EdgeInsets.only(right: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
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
                Icon(icon, size: 11, color: color),
                const SizedBox(width: 4),
                Text(
                  '${time.ceil()}s',
                  style: GoogleFonts.pressStart2p(fontSize: 6, color: color),
                ),
              ],
            ),
          ),
        ),
      );
    }

    addChip(
      'SH',
      Icons.shield_rounded,
      GameColors.neonCyan,
      _game.gameState.shieldTimeRemaining,
    );
    addChip(
      'MG',
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
      'BT',
      Icons.flash_on_rounded,
      GameColors.neonGreen,
      _game.gameState.boostTimeRemaining,
    );

    if (effects.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: effects);
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

  Widget _buildJumpButton() {
    return GestureDetector(
      onTap: () => _game.jump(),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF22cc55).withValues(alpha: 0.92),
          border: Border.all(color: const Color(0xFFd7ffe0), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Colors.white,
                size: 26,
              ),
              SizedBox(height: 2),
              Text(
                'JUMP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                    size: 36,
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'PAUSED',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 18,
                        color: const Color(0xFF00EEFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: NeonButton(
                      text: 'RESUME',
                      onPressed: onResume,
                      color: const Color(0xFF22cc55),
                      width: double.infinity,
                      height: 46,
                      fontSize: 11,
                      icon: Icons.play_arrow_rounded,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: NeonButton(
                      text: 'RESTART',
                      onPressed: onRestart,
                      color: const Color(0xFF2255cc),
                      width: double.infinity,
                      height: 42,
                      fontSize: 9,
                      icon: Icons.refresh_rounded,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: NeonButton(
                      text: 'MENU',
                      onPressed: onMainMenu,
                      color: const Color(0xFF882222),
                      width: double.infinity,
                      height: 42,
                      fontSize: 9,
                      icon: Icons.home_rounded,
                    ),
                  ),
                ],
              ),
            ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth < 320
                  ? constraints.maxWidth
                  : 320.0;
              final maxHeight = constraints.maxHeight * 0.88;
              return AnimatedBuilder(
                animation: _ctrl,
                builder: (ctx, _) => Opacity(
                  opacity: _fade.value,
                  child: Transform.translate(
                    offset: Offset(0, _slide.value),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxWidth,
                        maxHeight: maxHeight,
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0d0d22),
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFcc2222),
                                width: 2,
                              ),
                              left: BorderSide(
                                color: Color(0xFFcc2222),
                                width: 2,
                              ),
                              right: BorderSide(
                                color: Color(0xFF440000),
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: Color(0xFF440000),
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'GAME',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 16,
                                    color: const Color(0xFFff3333),
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xFF660000),
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'OVER',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 16,
                                    color: const Color(0xFFff3333),
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xFF660000),
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.isNewBest) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFffd700,
                                    ).withValues(alpha: 0.12),
                                    border: Border.all(
                                      color: const Color(0xFFffd700),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '🏆',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'NEW BEST!',
                                            style: GoogleFonts.pressStart2p(
                                              fontSize: 7,
                                              color: const Color(0xFFffd700),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              _statRow(
                                'SCORE',
                                widget.score.toString(),
                                const Color(0xFF00EEFF),
                              ),
                              const SizedBox(height: 6),
                              _statRow(
                                'BEST',
                                widget.highScore.toString(),
                                const Color(0xFFffd700),
                              ),
                              const SizedBox(height: 6),
                              _statRow(
                                'COINS',
                                widget.coins.toString(),
                                const Color(0xFFff9900),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: NeonButton(
                                  text: 'RETRY',
                                  onPressed: widget.onRetry,
                                  color: const Color(0xFF22cc55),
                                  width: double.infinity,
                                  height: 34,
                                  fontSize: 9,
                                  icon: Icons.refresh_rounded,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: NeonButton(
                                  text: 'MENU',
                                  onPressed: widget.onMainMenu,
                                  color: const Color(0xFF4455aa),
                                  width: double.infinity,
                                  height: 32,
                                  fontSize: 7,
                                  icon: Icons.home_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Text(
                val,
                style: GoogleFonts.pressStart2p(fontSize: 11, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
