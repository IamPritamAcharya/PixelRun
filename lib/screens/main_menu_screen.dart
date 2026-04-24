import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/widgets/neon_button.dart';

class MainMenuScreen extends StatefulWidget {
  final VoidCallback onPlay;
  final VoidCallback onSettings;
  final VoidCallback onInfo;
  final int highScore;

  const MainMenuScreen({
    super.key,
    required this.onPlay,
    required this.onSettings,
    required this.onInfo,
    required this.highScore,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _pulse;
  late Animation<double> _float;

  final List<_Star> _stars = [];
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    for (int i = 0; i < 40; i++) {
      _stars.add(
        _Star(
          x: _rng.nextDouble(),
          y: _rng.nextDouble() * 0.75,
          size: 1.0 + _rng.nextDouble() * 2.0,
          twinkleOffset: _rng.nextDouble(),
        ),
      );
    }

    for (int i = 0; i < 12; i++) {
      _particles.add(_Particle.random(_rng));
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _bgCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF080818),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_bgCtrl, _shimmerCtrl]),
            builder: (ctx, _) => CustomPaint(
              size: size,
              painter: _MenuBgPainter(
                _stars,
                _particles,
                _bgCtrl.value,
                _shimmerCtrl.value,
              ),
            ),
          ),

          SafeArea(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.highScore > 0) ...[
                        _buildHighScoreBadge(),
                        const SizedBox(height: 12),
                      ],

                      AnimatedBuilder(
                        animation: _float,
                        builder: (ctx, _) => Transform.translate(
                          offset: Offset(0, _float.value),
                          child: AnimatedBuilder(
                            animation: _pulse,
                            builder: (ctx, _) => Transform.scale(
                              scale: _pulse.value,
                              child: SizedBox(
                                width: 56,
                                height: 72,
                                child: CustomPaint(painter: _HeroPainter()),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildTitle(),

                      const SizedBox(height: 6),

                      Text(
                        'JUMP · STOMP · BLAST',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6,
                          color: const Color(0xFF88aadd),
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildControlsHint(),
                    ],
                  ),
                ),

                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPlayButton(),

                      const SizedBox(height: 10),

                      NeonButton(
                        text: 'SETTINGS',
                        onPressed: widget.onSettings,
                        color: const Color(0xFF5566aa),
                        width: 190,
                        height: 44,
                        fontSize: 9,
                        icon: Icons.settings_rounded,
                      ),

                      const SizedBox(height: 8),

                      NeonButton(
                        text: 'INFO',
                        onPressed: widget.onInfo,
                        color: const Color(0xFF9c27b0),
                        width: 190,
                        height: 40,
                        fontSize: 8,
                        icon: Icons.info_outline_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighScoreBadge() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (ctx, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1a1a00),
              Color.lerp(
                const Color(0xFF332200),
                const Color(0xFF443300),
                _shimmerCtrl.value,
              )!,
              const Color(0xFF1a1a00),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFffd700).withValues(alpha: 0.8),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(
              'BEST  ${widget.highScore}',
              style: GoogleFonts.pressStart2p(
                fontSize: 11,
                color: const Color(0xFFffd700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (ctx, _) => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0d1530), Color(0xFF0a0e24)],
              ),
              border: Border(
                top: BorderSide(
                  color: Color.lerp(
                    const Color(0xFF4a8aff),
                    const Color(0xFF88bbff),
                    _shimmerCtrl.value,
                  )!,
                  width: 3,
                ),
                left: BorderSide(
                  color: Color.lerp(
                    const Color(0xFF4a8aff),
                    const Color(0xFF88bbff),
                    _shimmerCtrl.value,
                  )!,
                  width: 3,
                ),
                right: const BorderSide(color: Color(0xFF0d0d1a), width: 3),
                bottom: const BorderSide(color: Color(0xFF0d0d1a), width: 5),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'PIXEL',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 22,
                    color: const Color(0xFF00EEFF),
                    height: 1.2,
                    shadows: const [
                      Shadow(
                        color: Color(0xFF006688),
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                      Shadow(
                        color: Color(0x4400EEFF),
                        offset: Offset(0, 0),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                Text(
                  'JUMPER',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 22,
                    color: const Color(0xFF22FF88),
                    height: 1.2,
                    shadows: const [
                      Shadow(
                        color: Color(0xFF006633),
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                      Shadow(
                        color: Color(0x4422FF88),
                        offset: Offset(0, 0),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (ctx, _) => Transform.scale(
        scale: 1.0 + (_pulse.value - 1.0) * 0.3,
        child: NeonButton(
          text: 'PLAY',
          onPressed: widget.onPlay,
          color: const Color(0xFF22cc55),
          width: 190,
          height: 54,
          fontSize: 16,
          icon: Icons.play_arrow_rounded,
        ),
      ),
    );
  }

  Widget _buildControlsHint() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (ctx, _) => Opacity(
        opacity: 0.5 + _shimmerCtrl.value * 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Text(
                'CONTROLS',
                style: GoogleFonts.pressStart2p(
                  fontSize: 5,
                  color: const Color(0xFF556688),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlChip('SPACE', 'JUMP'),
                  const SizedBox(width: 6),
                  _controlChip('[F]', 'FIRE'),
                  const SizedBox(width: 6),
                  _controlChip('[T]', 'TELE'),
                  const SizedBox(width: 6),
                  _controlChip('TAP', 'TOUCH'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x220066FF),
        border: Border.all(color: const Color(0x554488ff), width: 1),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 5,
              color: const Color(0xFF7799cc),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  double x, y, vy, size, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.vy,
    required this.size,
    required this.opacity,
  });
  factory _Particle.random(Random r) => _Particle(
    x: r.nextDouble(),
    y: r.nextDouble(),
    vy: -0.0008 - r.nextDouble() * 0.0012,
    size: 2 + r.nextDouble() * 3,
    opacity: 0.3 + r.nextDouble() * 0.5,
  );
  void update() {
    y += vy;
    if (y < -0.05) y = 1.05;
  }
}

class _Star {
  final double x, y, size, twinkleOffset;
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleOffset,
  });
}

class _MenuBgPainter extends CustomPainter {
  final List<_Star> stars;
  final List<_Particle> particles;
  final double bgProgress;
  final double shimmer;

  _MenuBgPainter(this.stars, this.particles, this.bgProgress, this.shimmer) {
    for (final p in particles) p.update();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF04040e), Color(0xFF0c0c28), Color(0xFF100820)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final nebX = size.width * 0.4;
    final nebY = size.height * 0.3;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(nebX, nebY), width: 300, height: 200),
      Paint()
        ..color = const Color(0x08224488)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height * 0.5),
        width: 200,
        height: 150,
      ),
      Paint()
        ..color = const Color(0x08441188)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );

    for (final s in stars) {
      final twinkle =
          (sin((bgProgress * 2 * pi) + s.twinkleOffset * 2 * pi) + 1) / 2;
      final alpha = (0.3 + twinkle * 0.6).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(s.x * size.width, s.y * size.height),
          width: s.size,
          height: s.size,
        ),
        Paint()..color = Color.fromRGBO(200, 220, 255, alpha),
      );
    }

    final mx = size.width * 0.85;
    const my = 40.0;
    canvas.drawCircle(
      Offset(mx, my),
      20,
      Paint()..color = const Color(0xFFf0f0d8),
    );

    canvas.drawCircle(
      Offset(mx + 8, my + 4),
      4,
      Paint()..color = const Color(0xFFd8d8b0),
    );
    canvas.drawCircle(
      Offset(mx + 2, my + 10),
      3,
      Paint()..color = const Color(0xFFd8d8b0),
    );

    for (final p in particles) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(p.x * size.width, p.y * size.height),
          width: p.size,
          height: p.size,
        ),
        Paint()..color = Color.fromRGBO(255, 220, 50, p.opacity * shimmer),
      );
    }

    final groundY = size.height * 0.88;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      Paint()..color = const Color(0xFF0e2016),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, 5),
      Paint()..color = const Color(0xFF1a3a24),
    );

    const laneH = 28.0;
    final roadTop = groundY + 8;
    canvas.drawRect(
      Rect.fromLTWH(0, roadTop, size.width, laneH * 3),
      Paint()..color = const Color(0xFF1a1a1a),
    );

    final lp = Paint()
      ..color = const Color(0x55FFFFFF)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, roadTop + laneH),
      Offset(size.width, roadTop + laneH),
      lp,
    );
    canvas.drawLine(
      Offset(0, roadTop + laneH * 2),
      Offset(size.width, roadTop + laneH * 2),
      lp,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.4),
        width: w * 1.4,
        height: h * 0.9,
      ),
      Paint()
        ..color = const Color(0x2200EEFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.14, h * 0.02, w * 0.72, h * 0.50),
      Paint()..color = GameColors.playerColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.14, h * 0.02, w * 0.72, h * 0.50),
      Paint()
        ..color = GameColors.playerDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.04, w * 0.60, h * 0.22),
      Paint()..color = const Color(0xFF0d1020),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.22, h * 0.05, w * 0.56, h * 0.06),
      Paint()..color = const Color(0x33FFFFFF),
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.26, h * 0.09, w * 0.18, h * 0.10),
      Paint()..color = const Color(0xFF00EEFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.56, h * 0.09, w * 0.18, h * 0.10),
      Paint()..color = const Color(0xFF00EEFF),
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.14, h * 0.52, w * 0.72, h * 0.06),
      Paint()..color = const Color(0xFF1a3a5e),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.42, h * 0.52, w * 0.16, h * 0.06),
      Paint()..color = const Color(0xFFffd700),
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.58, w * 0.26, h * 0.30),
      Paint()..color = GameColors.playerDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.58, h * 0.64, w * 0.26, h * 0.28),
      Paint()..color = GameColors.playerDark,
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.12, h * 0.85, w * 0.32, h * 0.10),
      Paint()..color = const Color(0xFF1a2030),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.55, h * 0.89, w * 0.32, h * 0.08),
      Paint()..color = const Color(0xFF1a2030),
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.00, h * 0.10, w * 0.14, h * 0.26),
      Paint()..color = GameColors.playerColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.86, h * 0.06, w * 0.14, h * 0.26),
      Paint()..color = GameColors.playerColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
