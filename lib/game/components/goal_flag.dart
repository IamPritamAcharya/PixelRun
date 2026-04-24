import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/utils/constants.dart';

class GoalFlag extends PositionComponent with HasGameReference<PlatformerGame> {
  final double worldX;
  bool reached = false;

  double _waveTimer = 0;
  double _celebTimer = 0;
  bool _celebrating = false;

  static const double poleH = 120.0;
  static const double poleW = 5.0;
  static const double flagW = 50.0;
  static const double flagH = 32.0;

  GoalFlag({required this.worldX});

  @override
  Future<void> onLoad() async {
    size = Vector2(flagW + poleW + 10, poleH + 10);
    priority = 6;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _waveTimer += dt * 3.5;

    final screenX = worldX - game.cameraX;
    position.x = screenX;
    position.y = game.groundSurfaceY - poleH;

    if (screenX < -200) return;

    if (_celebrating) {
      _celebTimer += dt;
    }
  }

  void celebrate() {
    reached = true;
    _celebrating = true;
  }

  ui.Rect get hitRect =>
      ui.Rect.fromLTWH(position.x, position.y, poleW + flagW * 0.4, poleH);

  @override
  void render(ui.Canvas canvas) {
    final groundY = game.groundSurfaceY - position.y;

    canvas.drawRect(
      ui.Rect.fromLTWH(poleW / 2 + 3, 10, poleW - 1, groundY - 10),
      ui.Paint()..color = const ui.Color(0x33000000),
    );

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, poleW, groundY),
      ui.Paint()..color = const ui.Color(0xFFCCCCCC),
    );

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, 2, groundY),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    canvas.drawCircle(
      ui.Offset(poleW / 2, 0),
      7,
      ui.Paint()..color = const ui.Color(0xFFFFD700),
    );
    canvas.drawCircle(
      ui.Offset(poleW / 2, 0),
      5,
      ui.Paint()..color = const ui.Color(0xFFFFF0A0),
    );

    final color1 = reached
        ? const ui.Color(0xFF22FF88)
        : const ui.Color(0xFFFF3333);
    final color2 = reached
        ? const ui.Color(0xFF00AA55)
        : const ui.Color(0xFF880000);

    final flagPath = ui.Path();
    flagPath.moveTo(poleW, 6);
    const segments = 8;
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final waveX = poleW + t * flagW;
      final waveY = 6 + math.sin(_waveTimer + t * math.pi * 1.8) * 5 * t;
      if (i == 0) {
        flagPath.moveTo(waveX, waveY);
      } else {
        flagPath.lineTo(waveX, waveY);
      }
    }
    for (int i = segments; i >= 0; i--) {
      final t = i / segments;
      final waveX = poleW + t * flagW;
      final waveY =
          6 + flagH + math.sin(_waveTimer + t * math.pi * 1.8) * 5 * t;
      flagPath.lineTo(waveX, waveY);
    }
    flagPath.close();

    canvas.drawPath(flagPath, ui.Paint()..color = color1);

    final topHalf = ui.Path();
    topHalf.moveTo(poleW, 6);
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final waveX = poleW + t * flagW;
      final waveY = 6 + math.sin(_waveTimer + t * math.pi * 1.8) * 5 * t;
      topHalf.lineTo(waveX, waveY);
    }
    for (int i = segments; i >= 0; i--) {
      final t = i / segments;
      final waveX = poleW + t * flagW;
      final waveY =
          6 + flagH * 0.5 + math.sin(_waveTimer + t * math.pi * 1.8) * 5 * t;
      topHalf.lineTo(waveX, waveY);
    }
    topHalf.close();
    canvas.drawPath(topHalf, ui.Paint()..color = color2.withAlpha(100));

    if (!reached) {
      final paragraph = _buildText('GOAL', 9, const ui.Color(0xFFFFFFFF));
      canvas.save();
      canvas.translate(poleW + 6, 10);
      canvas.drawParagraph(paragraph, ui.Offset.zero);
      canvas.restore();
    } else {
      final pulse = math.sin(_celebTimer * 8) * 0.2 + 1.0;
      canvas.save();
      canvas.translate(poleW + flagW / 2, 6 + flagH / 2);
      canvas.scale(pulse, pulse);
      final p = _buildText('✓', 18, const ui.Color(0xFFFFFFFF));
      canvas.drawParagraph(p, ui.Offset(-9, -10));
      canvas.restore();
    }

    if (_celebrating) {
      final rng = math.Random((_celebTimer * 10).toInt());
      for (int i = 0; i < 5; i++) {
        final angle = rng.nextDouble() * math.pi * 2;
        final dist = 20 + rng.nextDouble() * 30;
        final x = poleW + flagW / 2 + math.cos(angle) * dist;
        final y = flagH / 2 + math.sin(angle) * dist;
        canvas.drawCircle(
          ui.Offset(x, y),
          3,
          ui.Paint()..color = GameColors.neonCyan.withAlpha(200),
        );
      }
    }
  }

  ui.Paragraph _buildText(String text, double size, ui.Color color) {
    final builder =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.center))
          ..pushStyle(
            ui.TextStyle(
              color: color,
              fontSize: size,
              fontWeight: ui.FontWeight.bold,
            ),
          )
          ..addText(text);
    final p = builder.build();
    p.layout(const ui.ParagraphConstraints(width: 60));
    return p;
  }
}
