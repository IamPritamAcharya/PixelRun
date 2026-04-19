import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runner/game/runner_game.dart';
import 'package:runner/game/utils/constants.dart';

class Road extends PositionComponent with HasGameReference<RunnerGame> {
  double _lineOffset = 0;
  double _groundOffset = 0;

  static const double _dashLength = 30.0;
  static const double _dashGap = 20.0;
  static const double _dashCycle = _dashLength + _dashGap;

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

    _groundOffset += speed * dt * 0.6;
    if (_groundOffset > 64) _groundOffset -= 64;
  }

  @override
  void render(Canvas canvas) {
    final sw = size.x;
    final sh = size.y;
    final roadLeft = (sw - GameConfig.roadWidth) / 2;
    final roadRight = roadLeft + GameConfig.roadWidth;

    _drawSky(canvas, sw, sh);
    _drawSideGround(canvas, roadLeft, roadRight, sh, sw);
    _drawRoad(canvas, roadLeft, roadRight, sh);
    _drawLaneDividers(canvas, roadLeft, sh);
    _drawCurbs(canvas, roadLeft, roadRight, sh);
  }

  void _drawSky(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF080818), Color(0xFF12123a), Color(0xFF1e1645)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    final sp = Paint()..color = const Color(0x99FFFFFF);
    for (final s in const [
      [0.05, 0.05],
      [0.13, 0.03],
      [0.22, 0.09],
      [0.34, 0.04],
      [0.46, 0.07],
      [0.57, 0.02],
      [0.68, 0.10],
      [0.80, 0.05],
      [0.91, 0.08],
      [0.96, 0.03],
      [0.09, 0.17],
      [0.29, 0.14],
      [0.50, 0.20],
      [0.74, 0.12],
      [0.89, 0.16],
      [0.04, 0.27],
      [0.18, 0.23],
      [0.40, 0.19],
      [0.63, 0.24],
      [0.84, 0.20],
    ]) {
      canvas.drawRect(Rect.fromLTWH(s[0] * w - 1, s[1] * h - 1, 2, 2), sp);
    }

    final mx = w * 0.84;
    final my = h * 0.05;
    canvas.drawRect(
      Rect.fromLTWH(mx, my, 26, 26),
      Paint()..color = const Color(0xFFf2f2d5),
    );
    canvas.drawRect(
      Rect.fromLTWH(mx + 14, my + 5, 8, 8),
      Paint()..color = const Color(0xFFd5d5aa),
    );
    canvas.drawRect(
      Rect.fromLTWH(mx + 5, my + 15, 6, 6),
      Paint()..color = const Color(0xFFd5d5aa),
    );
  }

  void _drawSideGround(
    Canvas canvas,
    double roadLeft,
    double roadRight,
    double sh,
    double sw,
  ) {
    final groundY = sh * 0.66;

    final gp = Paint()..color = const Color(0xFF162e1e);
    canvas.drawRect(Rect.fromLTWH(0, groundY, roadLeft, sh - groundY), gp);
    canvas.drawRect(
      Rect.fromLTWH(roadRight, groundY, sw - roadRight, sh - groundY),
      gp,
    );

    final gs = Paint()..color = const Color(0xFF22422a);
    canvas.drawRect(Rect.fromLTWH(0, groundY, roadLeft, 8), gs);
    canvas.drawRect(Rect.fromLTWH(roadRight, groundY, sw - roadRight, 8), gs);

    final tp = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;
    for (double y = groundY + 16; y < sh; y += 20) {
      final dy = y + (_groundOffset % 20);
      if (dy < sh) {
        canvas.drawLine(Offset(4, dy), Offset(roadLeft - 4, dy), tp);
        canvas.drawLine(Offset(roadRight + 4, dy), Offset(sw - 4, dy), tp);
      }
    }
  }

  void _drawRoad(Canvas canvas, double roadLeft, double roadRight, double sh) {
    final roadRect = Rect.fromLTRB(roadLeft, 0, roadRight, sh);
    canvas.drawRect(
      roadRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2a2a2a), Color(0xFF303030)],
        ).createShader(roadRect),
    );
  }

  void _drawLaneDividers(Canvas canvas, double roadLeft, double sh) {
    final laneSpacing = GameConfig.roadWidth / GameConfig.laneCount;
    final paint = Paint()
      ..color = const Color(0xCCffffff)
      ..strokeWidth = 3;

    for (int i = 1; i < GameConfig.laneCount; i++) {
      final x = roadLeft + laneSpacing * i;
      double y = -_dashLength + _lineOffset;
      while (y < sh) {
        final sy = y.clamp(0.0, sh);
        final ey = (y + _dashLength).clamp(0.0, sh);
        if (ey > sy) canvas.drawLine(Offset(x, sy), Offset(x, ey), paint);
        y += _dashCycle;
      }
    }
  }

  void _drawCurbs(Canvas canvas, double roadLeft, double roadRight, double sh) {
    const checkerH = 24.0;
    final yPaint = Paint()..color = const Color(0xFFffcc00);
    final wPaint = Paint()..color = const Color(0xFFffffff);
    final gPaint = Paint()..color = const Color(0xFF555555);

    canvas.drawRect(Rect.fromLTWH(roadLeft - 8, 0, 4, sh), gPaint);
    double cy = -checkerH + _lineOffset % checkerH;
    bool alt = false;
    while (cy < sh) {
      canvas.drawRect(
        Rect.fromLTWH(roadLeft - 4, cy, 4, checkerH),
        alt ? wPaint : yPaint,
      );
      cy += checkerH;
      alt = !alt;
    }

    canvas.drawRect(Rect.fromLTWH(roadRight + 4, 0, 4, sh), gPaint);
    cy = -checkerH + _lineOffset % checkerH;
    alt = false;
    while (cy < sh) {
      canvas.drawRect(
        Rect.fromLTWH(roadRight, cy, 4, checkerH),
        alt ? wPaint : yPaint,
      );
      cy += checkerH;
      alt = !alt;
    }
  }
}
