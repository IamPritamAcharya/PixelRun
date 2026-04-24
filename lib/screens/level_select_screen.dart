import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runner/game/levels/level_data.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/game/utils/game_state.dart';
import 'package:runner/widgets/neon_button.dart';

class LevelSelectScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(int levelIndex) onSelectLevel;

  const LevelSelectScreen({
    super.key,
    required this.onBack,
    required this.onSelectLevel,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with TickerProviderStateMixin {
  late GameState _gs;
  late AnimationController _entryCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _float;
  int? _hovered;

  static const _levelIcons = ['🌿', '🏜️', '🌌', '⚡', '🏔️', '🔥'];
  static const _levelColors = [
    Color(0xFF22cc55),
    Color(0xFFE8A020),
    Color(0xFF9c27b0),
    Color(0xFF00BFFF),
    Color(0xFF888888),
    Color(0xFFFF4422),
  ];

  @override
  void initState() {
    super.initState();
    _gs = GameState();
    _gs.loadSettings().then((_) => mounted ? setState(() {}) : null);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06060f),
      body: Stack(
        children: [
          const _StarField(),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0d0d28),
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFF4488ff),
                                width: 2,
                              ),
                              left: BorderSide(
                                color: Color(0xFF4488ff),
                                width: 2,
                              ),
                              right: BorderSide(
                                color: Color(0xFF080818),
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: Color(0xFF080818),
                                width: 3,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SELECT LEVEL',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 14,
                                color: const Color(0xFF00EEFF),
                                shadows: const [
                                  Shadow(
                                    color: Color(0xFF0055FF),
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_gs.clearedLevels.length}/${levels.length} CLEARED',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 6,
                                color: const Color(0xFF556699),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF221800),
                          border: Border.all(
                            color: const Color(0xFFffd700),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              '${_gs.clearedLevels.length}',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 12,
                                color: const Color(0xFFffd700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: _ProgressBar(
                    value: levels.isEmpty
                        ? 0
                        : _gs.clearedLevels.length / levels.length,
                    color: const Color(0xFF22cc55),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: levels.length,
                      itemBuilder: (ctx, i) => _buildLevelCard(i),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int index) {
    final isCleared = _gs.clearedLevels.contains(index);
    final isLocked = index > _gs.highestUnlockedLevel;
    final isHovered = _hovered == index;

    final accent = isLocked
        ? const Color(0xFF333355)
        : _levelColors[index % _levelColors.length];
    final icon = isLocked ? '🔒' : _levelIcons[index % _levelIcons.length];
    final level = levels[index];

    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (ctx, _) => Transform.translate(
        offset: Offset(0, isHovered ? _float.value : 0),
        child: GestureDetector(
          onTap: isLocked ? null : () => widget.onSelectLevel(index),
          onTapDown: isLocked ? null : (_) => setState(() => _hovered = index),
          onTapUp: isLocked ? null : (_) => setState(() => _hovered = null),
          onTapCancel: () => setState(() => _hovered = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color(0xFF0a0a18)
                  : const Color(0xFF0d0d24),
              border: Border(
                top: BorderSide(
                  color: isHovered ? accent : accent.withAlpha(120),
                  width: 2,
                ),
                left: BorderSide(
                  color: isHovered ? accent : accent.withAlpha(120),
                  width: 2,
                ),
                right: const BorderSide(color: Color(0xFF080818), width: 2),
                bottom: BorderSide(
                  color: const Color(0xFF080818),
                  width: isHovered ? 2 : 4,
                ),
              ),
              boxShadow: isHovered && !isLocked
                  ? [BoxShadow(color: accent.withAlpha(80), blurRadius: 14)]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: accent.withAlpha(isLocked ? 5 : 15)),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withAlpha(isLocked ? 30 : 50),
                              border: Border.all(
                                color: accent.withAlpha(isLocked ? 60 : 120),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${index + 1}'.padLeft(2, '0'),
                              style: GoogleFonts.pressStart2p(
                                fontSize: 9,
                                color: isLocked
                                    ? const Color(0xFF333355)
                                    : accent,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isCleared)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22cc55).withAlpha(50),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF22cc55),
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '✓',
                                  style: TextStyle(
                                    color: Color(0xFF22cc55),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      Center(
                        child: Text(
                          icon,
                          style: TextStyle(
                            fontSize: isLocked ? 28 : 32,
                            shadows: isLocked
                                ? null
                                : [
                                    Shadow(
                                      color: accent.withAlpha(150),
                                      blurRadius: 8,
                                    ),
                                  ],
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.pressStart2p(
                              fontSize: 6,
                              color: isLocked
                                  ? const Color(0xFF333355)
                                  : Colors.white70,
                            ),
                          ),
                          if (!isLocked) ...[
                            const SizedBox(height: 3),
                            _difficultyIndicator(index, accent),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                if (isLocked)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0x88000000),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔒', style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 3),
                            Text(
                              'LOCKED',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 5,
                                color: const Color(0xFF444466),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _difficultyIndicator(int index, Color color) {
    final dots = (index % 3) + 1;
    return Row(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: i < dots ? color : color.withAlpha(40),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(color: color),
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter(), child: const SizedBox.expand());
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xBBCCDDFF);

    for (int i = 0; i < 60; i++) {
      final x = (i * 137.508 + 113) % size.width;
      final y = (i * 97.3 + 37) % size.height * 0.7;
      final r = (i % 3 == 0) ? 1.5 : 0.8;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
