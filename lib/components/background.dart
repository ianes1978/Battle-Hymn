import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';

/// Sfondo a gradiente verticale, ridisegnato in base alla dimensione corrente
/// dello schermo (responsive).
class Background extends Component with HasGameReference<BattleHymnGame> {
  Background() : super(priority: 0);

  static const _top = Color(0xFF12102A);
  static const _bottom = Color(0xFF241B45);

  @override
  void render(Canvas canvas) {
    final Rect rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_top, _bottom],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
