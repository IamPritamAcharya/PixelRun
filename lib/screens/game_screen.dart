import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/levels/level_data.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/widgets/neon_button.dart';

class GameScreen extends StatefulWidget {
  final VoidCallback onMainMenu;
  final int startLevel;
  const GameScreen({super.key, required this.onMainMenu, this.startLevel = 0});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late PlatformerGame _game;
  late AnimationController _hudPulse;

  @override
  void initState() {
    super.initState();
    _game = PlatformerGame();
    _game.onLevelComplete = () {
      if (mounted) setState(() {});
    };
    _hudPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hudPulse.dispose();
    super.dispose();
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
              'Pause': (_, __) => _PauseOverlay(
                onResume: _game.resumeGame,
                onRestart: () {
                  _game.resumeEngine();
                  _game.startGame(widget.startLevel);
                },
                onMainMenu: () {
                  _game.resumeEngine();
                  widget.onMainMenu();
                },
              ),
              'GameOver': (_, __) => _GameOverOverlay(
                game: _game,
                onRetry: () {
                  _game.resumeEngine();
                  _game.startGame(widget.startLevel);
                },
                onMainMenu: () {
                  _game.resumeEngine();
                  widget.onMainMenu();
                },
              ),
              'LevelComplete': (_, __) => _LevelCompleteOverlay(
                game: _game,
                hasNextLevel: _game.gameState.currentLevel + 1 < levels.length,
                onNext: () {
                  _game.resumeEngine();
                  _game.startNextLevel();
                },
                onMainMenu: () {
                  _game.resumeEngine();
                  widget.onMainMenu();
                },
              ),
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: StreamBuilder(
                stream: Stream.periodic(const Duration(milliseconds: 120)),
                builder: (_, __) => _HUD(game: _game, hudPulse: _hudPulse),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(top: false, child: _MobileControls(game: _game)),
          ),
        ],
      ),
    );
  }
}

class _HUD extends StatelessWidget {
  final PlatformerGame game;
  final AnimationController hudPulse;
  const _HUD({required this.game, required this.hudPulse});

  @override
  Widget build(BuildContext context) {
    final gs = game.gameState;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leftStats(gs),
          const Spacer(),

          _powerChips(gs),
          const Spacer(),

          _rightPanel(gs),
        ],
      ),
    );
  }

  Widget _leftStats(gs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _HUDBadge(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 5),
              Text(
                _fmtScore(gs.score),
                style: GoogleFonts.pressStart2p(
                  fontSize: 12,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Color(0xFF0033AA),
                      blurRadius: 6,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          color: const Color(0xFF1a2a4a),
          border: const Color(0xFF3a6aaa),
        ),
        const SizedBox(height: 5),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HUDBadge(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 4),
                  Text(
                    '${gs.coins}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              color: const Color(0xFF1a1a00),
              border: const Color(0xFF665500),
            ),
            const SizedBox(width: 6),
            _HUDBadge(
              child: Text(
                'LV.${gs.currentLevel + 1}',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: const Color(0xFF22cc55),
                ),
              ),
              color: const Color(0xFF001a08),
              border: const Color(0xFF226633),
            ),
          ],
        ),
      ],
    );
  }

  Widget _powerChips(gs) {
    final chips = <Widget>[];
    if (gs.fireTimeRemaining > 0) {
      chips.add(
        _PowerChip(
          label: 'FIRE',
          emoji: '🔥',
          t: gs.fireTimeRemaining,
          color: const Color(0xFFFF6600),
        ),
      );
    }
    if (gs.starTimeRemaining > 0) {
      chips.add(
        _PowerChip(
          label: 'STAR',
          emoji: '⭐',
          t: gs.starTimeRemaining,
          color: const Color(0xFFFFD700),
        ),
      );
    }
    if (gs.shieldTimeRemaining > 0) {
      chips.add(
        _PowerChip(
          label: 'SHIELD',
          emoji: '🛡',
          t: gs.shieldTimeRemaining,
          color: const Color(0xFF00BFFF),
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: chips
          .map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: c,
            ),
          )
          .toList(),
    );
  }

  Widget _rightPanel(gs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: game.pauseGame,
          child: _HUDBadge(
            child: const Icon(
              Icons.pause_rounded,
              color: Colors.white70,
              size: 18,
            ),
            color: const Color(0xFF1a1a2e),
            border: const Color(0xFF3a3a6a),
          ),
        ),
        const SizedBox(height: 6),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                i < gs.lives ? '❤️' : '🖤',
                style: TextStyle(fontSize: i < gs.lives ? 18 : 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmtScore(int s) {
    if (s >= 10000) return '${(s / 1000).toStringAsFixed(1)}K';
    return s.toString().padLeft(5, '0');
  }
}

class _HUDBadge extends StatelessWidget {
  final Widget child;
  final Color color, border;
  const _HUDBadge({
    required this.child,
    required this.color,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: border.withAlpha(80),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          top: BorderSide(color: border, width: 1.5),
          left: BorderSide(color: border, width: 1.5),
          right: BorderSide(color: color.withAlpha(80), width: 1.5),
          bottom: BorderSide(color: Colors.black54, width: 3),
        ),
      ),
      child: child,
    );
  }
}

class _PowerChip extends StatelessWidget {
  final String label, emoji;
  final double t;
  final Color color;
  const _PowerChip({
    required this.label,
    required this.emoji,
    required this.t,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final frac = (t / 10.0).clamp(0.0, 1.0);
    return Container(
      width: 68,
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        border: Border(
          top: BorderSide(color: color, width: 1.5),
          left: BorderSide(color: color, width: 1.5),
          right: BorderSide(color: Colors.black, width: 1.5),
          bottom: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 3),
              Text(
                '${t.ceil()}s',
                style: GoogleFonts.pressStart2p(fontSize: 6, color: color),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  border: Border.all(color: color.withAlpha(60), width: 0.5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: frac,
                child: Container(height: 4, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileControls extends StatefulWidget {
  final PlatformerGame game;
  const _MobileControls({required this.game});

  @override
  State<_MobileControls> createState() => _MobileControlsState();
}

class _MobileControlsState extends State<_MobileControls> {
  bool _leftHeld = false;
  bool _rightHeld = false;

  void _setLeft(bool v) {
    if (_leftHeld == v) return;
    setState(() => _leftHeld = v);
    widget.game.moveLeft(v);
  }

  void _setRight(bool v) {
    if (_rightHeld == v) return;
    setState(() => _rightHeld = v);
    widget.game.moveRight(v);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _DpadBtn(
                icon: Icons.arrow_back_ios_rounded,
                held: _leftHeld,
                onDown: () => _setLeft(true),
                onUp: () => _setLeft(false),
                accent: const Color(0xFF4488FF),
              ),
              const SizedBox(width: 8),
              _DpadBtn(
                icon: Icons.arrow_forward_ios_rounded,
                held: _rightHeld,
                onDown: () => _setRight(true),
                onUp: () => _setRight(false),
                accent: const Color(0xFF4488FF),
              ),
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StreamBuilder(
                stream: Stream.periodic(const Duration(milliseconds: 200)),
                builder: (_, __) {
                  if (!widget.game.gameState.fireActive)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _ActionBtn(
                      label: 'FIRE',
                      emoji: '🔥',
                      color: const Color(0xFFFF5500),
                      onTap: widget.game.shootFireball,
                      size: 56,
                    ),
                  );
                },
              ),

              StreamBuilder(
                stream: Stream.periodic(const Duration(milliseconds: 200)),
                builder: (_, __) {
                  if (widget.game.gameState.teleportCooldown > 0)
                    return const SizedBox.shrink();
                  return const SizedBox.shrink();
                },
              ),

              _ActionBtn(
                label: 'JUMP',
                icon: Icons.keyboard_double_arrow_up_rounded,
                color: const Color(0xFF22CC55),
                onTap: widget.game.jump,
                size: 70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DpadBtn extends StatelessWidget {
  final IconData icon;
  final bool held;
  final VoidCallback onDown, onUp;
  final Color accent;
  const _DpadBtn({
    required this.icon,
    required this.held,
    required this.onDown,
    required this.onUp,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: 62,
        height: 54,
        decoration: BoxDecoration(
          color: held ? accent.withAlpha(60) : const Color(0xFF0a0a1e),
          boxShadow: held
              ? [BoxShadow(color: accent.withAlpha(120), blurRadius: 10)]
              : null,
          border: Border(
            top: BorderSide(
              color: held ? accent : accent.withAlpha(140),
              width: 2,
            ),
            left: BorderSide(
              color: held ? accent : accent.withAlpha(140),
              width: 2,
            ),
            right: const BorderSide(color: Color(0xFF050510), width: 2),
            bottom: BorderSide(color: Colors.black, width: held ? 2 : 5),
          ),
        ),
        child: Center(
          child: Icon(icon, color: held ? accent : Colors.white54, size: 24),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final Color color;
  final VoidCallback onTap;
  final double size;
  const _ActionBtn({
    required this.label,
    this.icon,
    this.emoji,
    required this.color,
    required this.onTap,
    required this.size,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTap();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed
              ? widget.color.withAlpha(200)
              : widget.color.withAlpha(230),
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha(_pressed ? 60 : 120),
              blurRadius: _pressed ? 6 : 16,
              offset: Offset(0, _pressed ? 2 : 5),
            ),
          ],
          border: Border.all(color: Colors.white.withAlpha(50), width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.emoji != null)
                Text(
                  widget.emoji!,
                  style: TextStyle(fontSize: widget.size * 0.28),
                ),
              if (widget.icon != null)
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.size * 0.36,
                ),
              Text(
                widget.label,
                style: GoogleFonts.pressStart2p(
                  fontSize: widget.size * 0.11,
                  color: Colors.white,
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
    return _OverlayScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OverlayIcon(
            Icons.pause_circle_filled_rounded,
            const Color(0xFF4488FF),
            size: 40,
          ),
          const SizedBox(height: 10),
          _OverlayTitle('PAUSED', const Color(0xFF00EEFF)),
          const SizedBox(height: 20),
          _OverlayBtn(
            '▶  RESUME',
            const Color(0xFF22CC55),
            onResume,
            icon: Icons.play_arrow_rounded,
          ),
          const SizedBox(height: 8),
          _OverlayBtn(
            '↺  RESTART',
            const Color(0xFF2255CC),
            onRestart,
            icon: Icons.refresh_rounded,
          ),
          const SizedBox(height: 8),
          _OverlayBtn(
            '⌂  MENU',
            const Color(0xFF882222),
            onMainMenu,
            icon: Icons.home_rounded,
          ),
        ],
      ),
      accent: const Color(0xFF4488FF),
    );
  }
}

class _LevelCompleteOverlay extends StatefulWidget {
  final PlatformerGame game;
  final bool hasNextLevel;
  final VoidCallback onNext, onMainMenu;
  const _LevelCompleteOverlay({
    required this.game,
    required this.hasNextLevel,
    required this.onNext,
    required this.onMainMenu,
  });

  @override
  State<_LevelCompleteOverlay> createState() => _LevelCompleteOverlayState();
}

class _LevelCompleteOverlayState extends State<_LevelCompleteOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.game.gameState;
    final lvName = levels[gs.currentLevel.clamp(0, levels.length - 1)].name;
    return ScaleTransition(
      scale: _scale,
      child: _OverlayScaffold(
        accent: const Color(0xFF22CC55),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 6),
            _OverlayTitle('LEVEL CLEAR!', const Color(0xFF22CC55)),
            const SizedBox(height: 3),
            Text(
              lvName.toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: const Color(0xFF66EE99),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatBlock('SCORE', _fmtNum(gs.score), const Color(0xFF00EEFF)),
                Container(width: 1, height: 36, color: const Color(0xFF224422)),
                _StatBlock('COINS', '${gs.coins}', const Color(0xFFFFD700)),
              ],
            ),
            const SizedBox(height: 18),
            if (widget.hasNextLevel)
              _OverlayBtn(
                'NEXT  ▶',
                const Color(0xFF22CC55),
                widget.onNext,
                icon: Icons.arrow_forward_rounded,
              ),
            if (widget.hasNextLevel) const SizedBox(height: 8),
            _OverlayBtn(
              '⌂  MENU',
              const Color(0xFF334488),
              widget.onMainMenu,
              icon: Icons.home_rounded,
            ),
          ],
        ),
      ),
    );
  }

  String _fmtNum(int n) =>
      n >= 10000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';
}

class _GameOverOverlay extends StatefulWidget {
  final PlatformerGame game;
  final VoidCallback onRetry, onMainMenu;
  const _GameOverOverlay({
    required this.game,
    required this.onRetry,
    required this.onMainMenu,
  });

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
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
    final gs = widget.game.gameState;
    final isNewBest = gs.score > 0 && gs.score >= gs.highScore;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _OverlayScaffold(
          accent: const Color(0xFFCC2222),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xFFFF4444), Color(0xFFFF0000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(r),
                child: Text(
                  'GAME OVER',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Color(0xFF660000),
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
              if (isNewBest) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withAlpha(20),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🏆 ', style: TextStyle(fontSize: 14)),
                      Text(
                        'NEW BEST!',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _StatRow('SCORE', _fmt(gs.score), const Color(0xFF00EEFF)),
              const Divider(color: Color(0xFF222244), height: 10),
              _StatRow('BEST', _fmt(gs.highScore), const Color(0xFFFFD700)),
              const Divider(color: Color(0xFF222244), height: 10),
              _StatRow('COINS', '${gs.coins}', const Color(0xFFFF9900)),
              const SizedBox(height: 16),
              _OverlayBtn(
                '↺  RETRY',
                const Color(0xFF22CC55),
                widget.onRetry,
                icon: Icons.refresh_rounded,
              ),
              const SizedBox(height: 8),
              _OverlayBtn(
                '⌂  MENU',
                const Color(0xFF334488),
                widget.onMainMenu,
                icon: Icons.home_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int n) => n >= 10000
      ? '${(n / 1000).toStringAsFixed(1)}K'
      : n.toString().padLeft(5, '0');
}

class _OverlayScaffold extends StatelessWidget {
  final Widget child;
  final Color accent;
  const _OverlayScaffold({required this.child, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 310),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF08081A),
            boxShadow: [BoxShadow(color: accent.withAlpha(70), blurRadius: 30)],
            border: Border(
              top: BorderSide(color: accent, width: 2),
              left: BorderSide(color: accent, width: 2),
              right: const BorderSide(color: Color(0xFF060610), width: 2),
              bottom: const BorderSide(color: Color(0xFF060610), width: 4),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _OverlayTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _OverlayTitle(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.pressStart2p(
      fontSize: 14,
      color: color,
      shadows: [
        Shadow(
          color: color.withAlpha(120),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
    ),
  );
}

class _OverlayIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _OverlayIcon(this.icon, this.color, {this.size = 32});

  @override
  Widget build(BuildContext context) => Icon(icon, color: color, size: size);
}

class _OverlayBtn extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  const _OverlayBtn(this.text, this.color, this.onTap, {this.icon});

  @override
  Widget build(BuildContext context) {
    return NeonButton(
      text: text,
      onPressed: onTap,
      color: color,
      width: double.infinity,
      height: 42,
      fontSize: 8,
      icon: icon,
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBlock(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: GoogleFonts.pressStart2p(
          fontSize: 6,
          color: const Color(0xFF666688),
        ),
      ),
      const SizedBox(height: 5),
      Text(value, style: GoogleFonts.pressStart2p(fontSize: 13, color: color)),
    ],
  );
}

class _StatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: const Color(0xFF666688),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.pressStart2p(fontSize: 11, color: color),
        ),
      ],
    ),
  );
}
