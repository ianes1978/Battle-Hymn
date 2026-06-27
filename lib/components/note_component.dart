import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../game/note_data.dart';
import 'staff.dart';

/// Nota sullo spartito. È il "timekeeper" del beat: avanza [NoteData.elapsed]
/// e, quando raggiunge la linea senza essere suonata, notifica il miss.
class NoteComponent extends PositionComponent
    with HasGameReference<BattleHymnGame> {
  final NoteData note;

  double _fade = 1;
  bool _resolving = false;

  NoteComponent({required this.note})
      : super(priority: 22, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);

    if (_resolving) {
      _fade -= dt * 4;
      if (_fade <= 0) {
        game.removeNote(note);
        removeFromParent();
      }
      return;
    }

    if (note.isActive) {
      note.elapsed += dt; // unico punto in cui avanza il tempo
      if (note.progress >= 1) {
        game.onNoteReachedLine(note);
      }
    }

    if (!note.isActive && !_resolving) {
      _resolving = true;
    }

    final double startX = game.size.x + 30;
    const double endX = GameConfig.judgmentLineX;
    position = Vector2(
      startX - note.progress * (startX - endX),
      Staff.yForStaffIndex(note.staffIndex),
    );
  }

  @override
  void render(Canvas canvas) {
    final Color c = note.color;
    final double alpha = _fade.clamp(0.0, 1.0);
    final bool isTarget = game.activeTarget == note;

    // Tagli addizionali se la nota è fuori dalle 5 linee del pentagramma.
    _drawLedger(canvas, alpha);

    // Evidenziazione del bersaglio corrente.
    if (isTarget) {
      canvas.drawCircle(
        Offset.zero,
        14,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // Gambo.
    canvas.drawLine(
      const Offset(7, 0),
      const Offset(7, -22),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7 * alpha)
        ..strokeWidth = 2,
    );

    // Testa della nota.
    canvas.save();
    canvas.rotate(-0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 12),
      Paint()..color = c.withValues(alpha: alpha),
    );
    canvas.restore();
    canvas.drawCircle(
      Offset.zero,
      8,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Etichetta (solfège/lettere/nessuna) accanto alla nota.
    final String label =
        GameConfig.labelForClass(note.noteClass, game.settings.labelMode);
    if (label.isNotEmpty) {
      _text(canvas, label, const Offset(0, 16), c.withValues(alpha: alpha));
    }
  }

  /// Disegna un taglio addizionale solo se la nota cade su una linea fuori dal
  /// pentagramma (le note negli spazi non hanno linea).
  void _drawLedger(Canvas canvas, double alpha) {
    if (Staff.needsLedger(note.staffIndex)) {
      canvas.drawLine(
        const Offset(-12, 0),
        const Offset(12, 0),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.45 * alpha)
          ..strokeWidth = 1.5,
      );
    }
  }

  void _text(Canvas canvas, String s, Offset center, Color color) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}
