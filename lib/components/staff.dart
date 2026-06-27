import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';

/// Pentagramma (5 linee orizzontali) con la linea di esecuzione verticale a
/// sinistra, dove le note vanno "suonate".
class Staff extends Component with HasGameReference<BattleHymnGame> {
  Staff() : super(priority: 20);

  /// Calcola la coordinata Y sul pentagramma per un dato pitch.
  /// Pitch alto = più in alto sullo spartito.
  static double yForPitch(int pitch) {
    final double t = pitch / (GameConfig.scaleLength - 1); // 0..1
    final double top = GameConfig.staffTop;
    final double bottom = GameConfig.staffTop + GameConfig.staffHeight;
    return bottom - t * (bottom - top);
  }

  @override
  void render(Canvas canvas) {
    final double width = game.size.x;
    final double top = GameConfig.staffTop;
    final double height = GameConfig.staffHeight;

    // Pannello semitrasparente dietro il pentagramma.
    final Paint panel = Paint()..color = Colors.black.withValues(alpha: 0.18);
    canvas.drawRect(Rect.fromLTWH(0, top - 18, width, height + 36), panel);

    // Le 5 linee del pentagramma.
    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 5; i++) {
      final double y = top + height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), linePaint);
    }

    // Linea di esecuzione (glow).
    final double x = GameConfig.judgmentLineX;
    final Paint glow = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.85)
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final Paint core = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(x, top - 20), Offset(x, top + height + 20), glow);
    canvas.drawLine(Offset(x, top - 20), Offset(x, top + height + 20), core);
  }
}
