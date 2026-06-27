import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';

/// Pentagramma con la linea di esecuzione. Le note coprono 2 ottave distribuite
/// su una banda verticale più ampia delle 5 linee principali (le note fuori
/// dalle linee usano tagli addizionali, disegnati dalla nota stessa).
class Staff extends Component with HasGameReference<BattleHymnGame> {
  Staff() : super(priority: 20);

  /// Coordinata Y per un dato indice di rigo (0 = Do basso ... 21 = La alto).
  /// Indice alto = più in alto (Y minore).
  static double yForStaffIndex(int staffIndex) {
    final double t =
        (staffIndex - GameConfig.staffMin) / (GameConfig.staffSpan - 1);
    final double top = GameConfig.noteBandTop;
    final double bottom = GameConfig.noteBandBottom;
    return bottom - t * (bottom - top);
  }

  @override
  void render(Canvas canvas) {
    final double width = game.size.x;
    const double top = GameConfig.staffTop;
    const double height = GameConfig.staffHeight;

    // Pannello semitrasparente dietro la banda delle note.
    final Paint panel = Paint()..color = Colors.black.withValues(alpha: 0.16);
    canvas.drawRect(
      Rect.fromLTWH(0, GameConfig.noteBandTop - 8, width,
          GameConfig.noteBandBottom - GameConfig.noteBandTop + 16),
      panel,
    );

    // Le 5 linee principali del pentagramma.
    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 5; i++) {
      final double y = top + height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), linePaint);
    }

    // Linea di esecuzione (glow).
    const double x = GameConfig.judgmentLineX;
    final Paint glow = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.85)
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final Paint core = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 2.5;
    final double yTop = GameConfig.noteBandTop - 6;
    final double yBot = GameConfig.noteBandBottom + 6;
    canvas.drawLine(Offset(x, yTop), Offset(x, yBot), glow);
    canvas.drawLine(Offset(x, yTop), Offset(x, yBot), core);
  }
}
