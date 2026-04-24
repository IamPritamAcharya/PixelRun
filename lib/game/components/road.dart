import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

class Road extends PositionComponent with HasGameReference<RunnerGame> {
  double _lineOffset = 0;
  double _groundOffset = 0;
  double _cloudOffset = 0;

  static const double _dashLength = 30.0;
  static const double _dashGap = 20.0;
  static const double _dashCycle = _dashLength + _dashGap;

  final List<_Cloud> _clouds = [
    _Cloud(0.10, 0.18, 108, 34),
    _Cloud(0.28, 0.30, 72, 24),
    _Cloud(0.52, 0.14, 128, 40),
    _Cloud(0.74, 0.22, 92, 28),
    _Cloud(0.90, 0.10, 64, 20),
  ];

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final speed = game.gameState.currentSpeed;

    _lineOffset += speed * dt;
    if (_lineOffset >= _dashCycle) _lineOffset -= _dashCycle;

    _groundOffset += speed * dt * 0.4;
    if (_groundOffset > 64) _groundOffset -= 64;

    _cloudOffset += speed * dt * 0.02;

    for (final c in _clouds) {
      c.xFraction -= speed * dt * 0.00008;
      if (c.xFraction < -0.25) c.xFraction += 1.45;
    }
  }

  double get roadTop => game.size.y * GameConfig.roadTopFraction;

  double laneGroundY(int lane) => roadTop + (lane + 1) * GameConfig.laneHeight;

  double laneCenterY(int lane) =>
      roadTop + lane * GameConfig.laneHeight + GameConfig.laneHeight / 2;

  @override
  void render(Canvas canvas) {
    final sw = size.x;
    final sh = size.y;
    final rt = roadTop;
    final rb = rt + GameConfig.roadHeight;

    _drawSky(canvas, sw, rt);
    _drawRoadRows(canvas, sw, rt);
    _drawLaneDividers(canvas, sw, rt);
    _drawCurbs(canvas, sw, rt, rb);
    _drawSideGround(canvas, sw, sh, rb);
  }

  void _drawSky(Canvas canvas, double w, double roadTopY) {
    final rect = Rect.fromLTWH(0, 0, w, roadTopY);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87c8ff), Color(0xFF7ebdf8), Color(0xFFc7efff)],
          stops: [0.0, 0.62, 1.0],
        ).createShader(rect),
    );

    final cloudPaint = Paint()..color = const Color(0x99FFFFFF);
    final cloudShadow = Paint()..color = const Color(0x44D6F2FF);
    for (final c in _clouds) {
      final cx = c.xFraction * w;
      final cy = c.yFraction * roadTopY;
      _drawCloud(
        canvas,
        Offset(cx, cy),
        c.w.toDouble(),
        c.h.toDouble(),
        cloudPaint,
        cloudShadow,
      );
    }

    final hillPaint = Paint()
      ..color = const Color(0xFF98e07f).withValues(alpha: 0.62);
    final hillDark = Paint()
      ..color = const Color(0xFF6ec56a).withValues(alpha: 0.55);
    final hillBaseY = roadTopY * 0.92;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.18, hillBaseY),
        width: w * 0.34,
        height: roadTopY * 0.45,
      ),
      hillDark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.42, hillBaseY + 6),
        width: w * 0.46,
        height: roadTopY * 0.54,
      ),
      hillPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.72, hillBaseY + 4),
        width: w * 0.38,
        height: roadTopY * 0.44,
      ),
      hillDark,
    );
  }

  void _drawRoadRows(Canvas canvas, double w, double rt) {
    for (int lane = 0; lane < GameConfig.laneCount; lane++) {
      final top = rt + lane * GameConfig.laneHeight;
      final bottom = top + GameConfig.laneHeight;
      final rect = Rect.fromLTRB(0, top, w, bottom);

      final shade = lane.isEven
          ? const Color(0xFF252525)
          : const Color(0xFF2c2c2c);
      canvas.drawRect(rect, Paint()..color = shade);

      canvas.drawRect(
        Rect.fromLTWH(0, bottom - 5, w, 5),
        Paint()..color = const Color(0xFF181818),
      );

      final cy = top + GameConfig.laneHeight / 2;
      canvas.drawRect(
        Rect.fromLTWH(4, cy - 10, 3, 20),
        Paint()..color = const Color(0x44FFFFFF),
      );
    }
  }

  void _drawLaneDividers(Canvas canvas, double w, double rt) {
    final paint = Paint()
      ..color = const Color(0x88FFFFFF)
      ..strokeWidth = 2;

    for (int i = 1; i < GameConfig.laneCount; i++) {
      final y = rt + i * GameConfig.laneHeight;

      double x = -_dashLength + _lineOffset;
      while (x < w) {
        final sx = x.clamp(0.0, w);
        final ex = (x + _dashLength).clamp(0.0, w);
        if (ex > sx) canvas.drawLine(Offset(sx, y), Offset(ex, y), paint);
        x += _dashCycle;
      }
    }
  }

  void _drawCurbs(Canvas canvas, double w, double rt, double rb) {
    const checkerW = 24.0;
    final yPaint = Paint()..color = const Color(0xFFffcc00);
    final wPaint = Paint()..color = const Color(0xFFffffff);
    final gPaint = Paint()..color = const Color(0xFF555555);

    canvas.drawRect(Rect.fromLTWH(0, rt - 4, w, 4), gPaint);
    double cx = -checkerW + _lineOffset % checkerW;
    bool alt = false;
    while (cx < w) {
      canvas.drawRect(
        Rect.fromLTWH(cx, rt, checkerW, 4),
        alt ? wPaint : yPaint,
      );
      cx += checkerW;
      alt = !alt;
    }

    canvas.drawRect(Rect.fromLTWH(0, rb, w, 4), gPaint);
    cx = -checkerW + _lineOffset % checkerW;
    alt = false;
    while (cx < w) {
      canvas.drawRect(
        Rect.fromLTWH(cx, rb, checkerW, 4),
        alt ? wPaint : yPaint,
      );
      cx += checkerW;
      alt = !alt;
    }
  }

  void _drawSideGround(Canvas canvas, double w, double sh, double rb) {
    final groundH = sh - rb - 4;

    canvas.drawRect(
      Rect.fromLTWH(0, rb + 4, w, groundH),
      Paint()..color = const Color(0xFF162e1e),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, rb + 4, w, 10),
      Paint()..color = const Color(0xFF22422a),
    );

    final tp = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;
    for (double y = rb + 22; y < sh - 4; y += 14) {
      canvas.drawLine(Offset(4, y), Offset(w - 4, y), tp);
    }

    if (groundH > 24) {
      final treeBaseY = rb + 6;
      final treeH = (groundH * 0.80).clamp(16.0, 48.0);
      final trunkH = (treeH * 0.35).clamp(6.0, 16.0);
      final trunkW = 6.0;
      final canopyR = (treeH - trunkH) * 0.55;

      final trunkPaint = Paint()..color = const Color(0xFF5c3d1e);
      final canopyPaint = Paint()..color = const Color(0xFF1a5c28);
      final canopy2Paint = Paint()..color = const Color(0xFF22772e);

      final treeXs = [0.07, 0.20, 0.33, 0.47, 0.60, 0.73, 0.86, 0.98];
      for (final frac in treeXs) {
        double tx = ((frac * w - _groundOffset * 0.5) % (w + 60)) - 30;

        canvas.drawRect(
          Rect.fromLTWH(
            tx - trunkW / 2,
            treeBaseY + treeH - trunkH,
            trunkW,
            trunkH,
          ),
          trunkPaint,
        );

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(tx, treeBaseY + treeH - trunkH - canopyR * 0.6),
            width: canopyR * 2.2,
            height: canopyR * 1.4,
          ),
          canopyPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(tx, treeBaseY + treeH - trunkH - canopyR * 1.1),
            width: canopyR * 1.6,
            height: canopyR * 1.2,
          ),
          canopy2Paint,
        );
      }
    }
  }
}

void _drawCloud(
  Canvas canvas,
  Offset center,
  double width,
  double height,
  Paint fill,
  Paint shadow,
) {
  final w = width;
  final h = height;
  final left = center.dx - w / 2;
  final top = center.dy - h / 2;

  canvas.drawOval(
    Rect.fromLTWH(left + w * 0.08, top + h * 0.28, w * 0.84, h * 0.58),
    shadow,
  );

  canvas.drawOval(
    Rect.fromLTWH(left + w * 0.18, top + h * 0.12, w * 0.46, h * 0.56),
    fill,
  );
  canvas.drawOval(
    Rect.fromLTWH(left + w * 0.42, top, w * 0.34, h * 0.66),
    fill,
  );
  canvas.drawOval(
    Rect.fromLTWH(left + w * 0.06, top + h * 0.18, w * 0.34, h * 0.46),
    fill,
  );
  canvas.drawOval(
    Rect.fromLTWH(left + w * 0.30, top + h * 0.24, w * 0.52, h * 0.42),
    fill,
  );
}

class _Cloud {
  double xFraction;
  final double yFraction;
  final int w, h;
  _Cloud(this.xFraction, this.yFraction, this.w, this.h);
}
