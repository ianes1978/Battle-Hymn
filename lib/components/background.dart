import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';

/// Sfondo a gradiente verticale, ridisegnato in base alla dimensione corrente
/// dello schermo (responsive).
class Background extends Component with HasGameReference<BattleHymnGame> {
  Background() : super(priority: 0);

  static const _top = Color(0xFF12102A);
  static const _bottom = Color(0xFF241B45);
  static const _topPulse = Color(0xFF1E1746);
  static const _bottomPulse = Color(0xFF3A2A6B);

  @override
  void render(Canvas canvas) {
    final Rect rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    // A ogni beat lo sfondo si schiarisce leggermente, poi torna scuro.
    final double p = game.beatPulse * 0.6;
    final Color top = Color.lerp(_top, _topPulse, p)!;
    final Color bottom = Color.lerp(_bottom, _bottomPulse, p)!;
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
