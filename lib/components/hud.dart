import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../game/game_state.dart';
import '../game/note_data.dart';
import '../i18n/strings.dart';

/// Interfaccia di gioco: HP, vite, gemme, punteggio, combo, timer, giudizi.
class Hud extends Component with HasGameReference<BattleHymnGame> {
  Hud() : super(priority: 40);

  @override
  void render(Canvas canvas) {
    final GameState s = game.state;
    final double w = game.size.x;

    // Lampo a tutto schermo (oro su Perfect/vita, rosso su Miss).
    if (s.flashAlpha > 0) {
      canvas.drawRect(
        Rect.fromLTWH(-40, -40, w + 80, game.size.y + 80),
        Paint()..color = s.flashColor.withValues(alpha: 0.22 * s.flashAlpha),
      );
    }

    _drawHpBar(canvas, s);
    _drawLives(canvas, s);
    _drawGems(canvas, s);

    // Punteggio (in alto a destra).
    _text(canvas, '${s.score}', Offset(w - 16, 16), 26,
        align: TextAlign.right, color: Colors.white, bold: true);
    _text(canvas, L.scoreLabel, Offset(w - 16, 46), 11,
        align: TextAlign.right, color: Colors.white60);

    if (s.combo > 1) {
      _text(canvas, '${s.combo}x ${L.combo}', Offset(w - 16, 70), 16,
          align: TextAlign.right, color: Colors.amberAccent, bold: true);
    }

    _text(canvas, _formatTime(s.survivalTime), Offset(w / 2, 14), 20,
        align: TextAlign.center, color: Colors.white70, bold: true);

    _drawJudgment(canvas, s);
    _drawBanner(canvas, s);
  }

  void _drawHpBar(Canvas canvas, GameState s) {
    const double x = 16, y = 16, width = 220, height = 18;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, width, height), const Radius.circular(9)),
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );
    final double frac = (s.hp / GameConfig.maxHp).clamp(0.0, 1.0);
    if (frac > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, width * frac, height),
            const Radius.circular(9)),
        Paint()..color = Color.lerp(Colors.redAccent, Colors.greenAccent, frac)!,
      );
    }
    _text(canvas, 'HP ${s.hp.ceil()}', Offset(x + 8, y - 1), 13,
        color: Colors.white, bold: true);
  }

  /// Vite extra: cuori rossi a destra della barra HP.
  void _drawLives(Canvas canvas, GameState s) {
    const double startX = 248, y = 25;
    for (int i = 0; i < s.lives; i++) {
      _heart(canvas, Offset(startX + i * 22, y), 8, Colors.redAccent);
    }
  }

  /// Gemme verso la prossima vita: 5 rombi sotto la barra HP.
  void _drawGems(Canvas canvas, GameState s) {
    const double startX = 18, y = 46;
    for (int i = 0; i < GameConfig.gemsPerLife; i++) {
      final bool filled = i < s.gems;
      _diamond(
        canvas,
        Offset(startX + i * 20, y),
        7,
        filled ? Colors.cyanAccent : Colors.white24,
        filled,
      );
    }
  }

  void _drawJudgment(Canvas canvas, GameState s) {
    if (s.lastJudgmentTimer <= 0 || s.lastJudgment == Judgment.none) return;
    final double a = (s.lastJudgmentTimer / 0.8).clamp(0.0, 1.0);
    final (String label, Color color) = switch (s.lastJudgment) {
      Judgment.perfect => (L.perfect, Colors.amberAccent),
      Judgment.good => (L.good, Colors.lightGreenAccent),
      Judgment.early => (L.ok, Colors.white70),
      Judgment.miss => (L.miss, Colors.redAccent),
      Judgment.none => ('', Colors.white),
    };
    _text(canvas, label, Offset(game.size.x / 2, game.size.y * 0.40 - (1 - a) * 20),
        34, align: TextAlign.center, color: color.withValues(alpha: a), bold: true);
  }

  void _drawBanner(Canvas canvas, GameState s) {
    if (s.bannerTimer <= 0 || s.banner == null) return;
    final double a = (s.bannerTimer / 1.6).clamp(0.0, 1.0);
    _text(canvas, s.banner!, Offset(game.size.x / 2, game.size.y * 0.30), 40,
        align: TextAlign.center,
        color: Colors.amberAccent.withValues(alpha: a),
        bold: true);
  }

  // --- forme ----------------------------------------------------------------

  void _diamond(
      Canvas canvas, Offset c, double r, Color color, bool filled) {
    final Path p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * 0.8, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * 0.8, c.dy)
      ..close();
    canvas.drawPath(
      p,
      Paint()
        ..color = color
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _heart(Canvas canvas, Offset c, double r, Color color) {
    final Path p = Path()
      ..moveTo(c.dx, c.dy + r * 0.8)
      ..cubicTo(c.dx - r * 1.6, c.dy - r * 0.5, c.dx - r * 0.4,
          c.dy - r * 1.3, c.dx, c.dy - r * 0.4)
      ..cubicTo(c.dx + r * 0.4, c.dy - r * 1.3, c.dx + r * 1.6,
          c.dy - r * 0.5, c.dx, c.dy + r * 0.8)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  String _formatTime(double t) {
    final int total = t.floor();
    return '${(total ~/ 60).toString().padLeft(2, '0')}:'
        '${(total % 60).toString().padLeft(2, '0')}';
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
