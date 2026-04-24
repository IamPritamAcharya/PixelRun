import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:runner/game/platformer_game.dart';
import 'package:runner/game/utils/constants.dart';

class WorldBackground extends PositionComponent
    with HasGameReference<PlatformerGame> {
  ui.Color _skyTop = const ui.Color(0xFF5C94FC);
  ui.Color _skyBottom = const ui.Color(0xFF9BB8FF);

  static const _cloudDefs = [
    _CloudDef(0.06, 0.10, 120, 40),
    _CloudDef(0.22, 0.22, 85, 28),
    _CloudDef(0.44, 0.08, 150, 48),
    _CloudDef(0.64, 0.18, 100, 32),
    _CloudDef(0.82, 0.07, 72, 24),
    _CloudDef(0.35, 0.28, 64, 20),
    _CloudDef(0.90, 0.25, 95, 30),
    _CloudDef(0.15, 0.32, 55, 18),
  ];

  void setSkyColors(int top, int bottom) {
    _skyTop = ui.Color(top);
    _skyBottom = ui.Color(bottom);
  }

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 0;
  }

  @override
  void render(ui.Canvas canvas) {
    final sw = size.x;
    final sh = size.y;
    final groundY = game.groundSurfaceY;

    final camX = game.cameraX;

    _drawSky(canvas, sw, groundY, camX);
    _drawGround(canvas, sw, sh, groundY, camX);
  }

  void _drawSky(ui.Canvas canvas, double w, double groundY, double camX) {
    final rect = ui.Rect.fromLTWH(0, 0, w, groundY);
    canvas.drawRect(
      rect,
      ui.Paint()
        ..shader = ui.Gradient.linear(ui.Offset(0, 0), ui.Offset(0, groundY), [
          _skyTop,
          _skyBottom,
        ]),
    );

    _drawHills(
      canvas,
      w,
      groundY,
      camX * 0.05,
      _skyBottom.withAlpha(210),
      0.36,
      0.42,
    );
    _drawHills(
      canvas,
      w,
      groundY,
      camX * 0.12,
      GameColors.groundTop.withAlpha(160),
      0.30,
      0.38,
    );

    _drawClouds(canvas, w, groundY, camX);
  }

  void _drawHills(
    ui.Canvas canvas,
    double w,
    double groundY,
    double offsetX,
    ui.Color color,
    double widthFrac,
    double heightFrac,
  ) {
    final paint = ui.Paint()..color = color;

    const hillCount = 4;
    for (int i = 0; i < hillCount; i++) {
      final baseX = (i / hillCount) * w * 1.3 - (offsetX % (w * 1.3));
      canvas.drawOval(
        ui.Rect.fromCenter(
          center: ui.Offset(baseX, groundY),
          width: w * widthFrac,
          height: groundY * heightFrac,
        ),
        paint,
      );

      canvas.drawOval(
        ui.Rect.fromCenter(
          center: ui.Offset(baseX + w * 1.3, groundY),
          width: w * widthFrac,
          height: groundY * heightFrac,
        ),
        paint,
      );
    }
  }

  void _drawClouds(ui.Canvas canvas, double w, double groundY, double camX) {
    final cloudFill = ui.Paint()..color = const ui.Color(0xCCFFFFFF);
    final cloudShad = ui.Paint()..color = const ui.Color(0x44AACCFF);

    for (final def in _cloudDefs) {
      final rawX = def.xFrac * w - (camX * 0.2) % (w * 1.5);

      final cx = rawX < -def.w * 1.5 ? rawX + w * 1.5 : rawX;
      final cy = def.yFrac * groundY;
      _drawCloud(
        canvas,
        ui.Offset(cx, cy),
        def.w.toDouble(),
        def.h.toDouble(),
        cloudFill,
        cloudShad,
      );
    }
  }

  void _drawGround(
    ui.Canvas canvas,
    double w,
    double sh,
    double groundY,
    double camX,
  ) {
    final groundH = sh - groundY;

    canvas.drawRect(
      ui.Rect.fromLTWH(0, groundY, w, groundH * 0.18),
      ui.Paint()..color = GameColors.groundTop,
    );

    canvas.drawRect(
      ui.Rect.fromLTWH(0, groundY + groundH * 0.18, w, groundH * 0.82),
      ui.Paint()..color = GameColors.groundBody,
    );

    canvas.drawRect(
      ui.Rect.fromLTWH(0, groundY, w, 3),
      ui.Paint()..color = GameColors.groundDark,
    );

    final texP = ui.Paint()
      ..color = GameColors.groundDark.withAlpha(50)
      ..strokeWidth = 1;
    for (double y = groundY + groundH * 0.30; y < sh - 4; y += 18) {
      canvas.drawLine(ui.Offset(4, y), ui.Offset(w - 4, y), texP);
    }

    _drawTrees(canvas, w, groundY, camX * 0.65);
  }

  void _drawTrees(ui.Canvas canvas, double w, double groundY, double offsetX) {
    const treeXFracs = [0.05, 0.16, 0.28, 0.40, 0.52, 0.64, 0.76, 0.88, 0.98];
    final trunkP = ui.Paint()..color = const ui.Color(0xFF5c3d1e);
    final canopy1 = ui.Paint()..color = const ui.Color(0xFF1a5c28);
    final canopy2 = ui.Paint()..color = const ui.Color(0xFF22772e);

    const totalW = 1.4;
    for (final frac in treeXFracs) {
      final treeH = 42.0 + math.sin(frac * 17.3) * 14;
      final trunkH = treeH * 0.35;
      const trunkW = 6.0;
      final canopyR = (treeH - trunkH) * 0.55;

      var tx = frac * w * totalW - (offsetX % (w * totalW));
      if (tx < -canopyR * 2) tx += w * totalW;

      canvas.drawRect(
        ui.Rect.fromLTWH(tx - trunkW / 2, groundY - trunkH, trunkW, trunkH),
        trunkP,
      );
      canvas.drawOval(
        ui.Rect.fromCenter(
          center: ui.Offset(tx, groundY - trunkH - canopyR * 0.6),
          width: canopyR * 2.2,
          height: canopyR * 1.4,
        ),
        canopy1,
      );
      canvas.drawOval(
        ui.Rect.fromCenter(
          center: ui.Offset(tx, groundY - trunkH - canopyR * 1.1),
          width: canopyR * 1.6,
          height: canopyR * 1.2,
        ),
        canopy2,
      );
    }
  }
}

void _drawCloud(
  ui.Canvas canvas,
  ui.Offset center,
  double width,
  double height,
  ui.Paint fill,
  ui.Paint shadow,
) {
  final w = width;
  final h = height;
  final left = center.dx - w / 2;
  final top = center.dy - h / 2;
  canvas.drawOval(
    ui.Rect.fromLTWH(left + w * 0.08, top + h * 0.3, w * 0.84, h * 0.56),
    shadow,
  );
  canvas.drawOval(
    ui.Rect.fromLTWH(left + w * 0.18, top + h * 0.10, w * 0.46, h * 0.58),
    fill,
  );
  canvas.drawOval(
    ui.Rect.fromLTWH(left + w * 0.42, top, w * 0.34, h * 0.68),
    fill,
  );
  canvas.drawOval(
    ui.Rect.fromLTWH(left + w * 0.06, top + h * 0.20, w * 0.34, h * 0.48),
    fill,
  );
  canvas.drawOval(
    ui.Rect.fromLTWH(left + w * 0.30, top + h * 0.22, w * 0.52, h * 0.44),
    fill,
  );
}

class _CloudDef {
  final double xFrac;
  final double yFrac;
  final int w, h;
  const _CloudDef(this.xFrac, this.yFrac, this.w, this.h);
}
