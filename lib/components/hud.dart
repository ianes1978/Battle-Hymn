import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../game/game_state.dart';
import '../game/note_data.dart';

/// Interfaccia di gioco: barra HP, punteggio, combo, timer di sopravvivenza e
/// popup dei giudizi (Perfect/Good/Miss).
class Hud extends Component with HasGameReference<BattleHymnGame> {
  Hud() : super(priority: 40);

  @override
  void render(Canvas canvas) {
    final GameState s = game.state;
    final double w = game.size.x;

    _drawHpBar(canvas, s);

    // Punteggio (in alto a destra).
    _text(canvas, '${s.score}', Offset(w - 16, 16), 26,
        align: TextAlign.right, color: Colors.white, bold: true);
    _text(canvas, 'PUNTEGGIO', Offset(w - 16, 46), 11,
        align: TextAlign.right, color: Colors.white60);

    // Combo (sotto il punteggio).
    if (s.combo > 1) {
      _text(canvas, '${s.combo}x COMBO', Offset(w - 16, 70), 16,
          align: TextAlign.right, color: Colors.amberAccent, bold: true);
    }

    // Timer di sopravvivenza (centro in alto).
    _text(canvas, _formatTime(s.survivalTime), Offset(w / 2, 14), 20,
        align: TextAlign.center, color: Colors.white70, bold: true);

    _drawJudgment(canvas, s);
  }

  void _drawHpBar(Canvas canvas, GameState s) {
    const double x = 16, y = 16, width = 220, height = 18;
    final RRect bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, height),
      const Radius.circular(9),
    );
    canvas.drawRRect(bg, Paint()..color = Colors.black.withValues(alpha: 0.4));

    final double frac = (s.hp / GameConfig.maxHp).clamp(0.0, 1.0);
    final Color hpColor = Color.lerp(Colors.redAccent, Colors.greenAccent, frac)!;
    if (frac > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, width * frac, height),
          const Radius.circular(9),
        ),
        Paint()..color = hpColor,
      );
    }
    _text(canvas, 'HP ${s.hp.ceil()}', Offset(x + 8, y - 1), 13,
        color: Colors.white, bold: true);
  }

  void _drawJudgment(Canvas canvas, GameState s) {
    if (s.lastJudgmentTimer <= 0 || s.lastJudgment == Judgment.none) return;
    final double a = (s.lastJudgmentTimer / 0.8).clamp(0.0, 1.0);
    final (String label, Color color) = switch (s.lastJudgment) {
      Judgment.perfect => ('PERFECT', Colors.amberAccent),
      Judgment.good => ('GOOD', Colors.lightGreenAccent),
      Judgment.miss => ('MISS', Colors.redAccent),
      Judgment.none => ('', Colors.white),
    };
    final double yOffset = (1 - a) * 20;
    _text(
      canvas,
      label,
      Offset(game.size.x / 2, game.size.y * 0.42 - yOffset),
      40,
      align: TextAlign.center,
      color: color.withValues(alpha: a),
      bold: true,
    );
  }

  String _formatTime(double t) {
    final int total = t.floor();
    final int m = total ~/ 60;
    final int sec = total % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _text(
    Canvas canvas,
    String s,
    Offset pos,
    double size, {
    TextAlign align = TextAlign.left,
    Color color = Colors.white,
    bool bold = false,
  }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();

    double dx = pos.dx;
    if (align == TextAlign.right) dx -= tp.width;
    if (align == TextAlign.center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, pos.dy));
  }
}
