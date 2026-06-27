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

  /// Timer di dissolvenza dopo risoluzione/miss.
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
      // Avanza il tempo SOLO qui per evitare doppie avanzate.
      note.elapsed += dt;
      if (note.progress >= 1) {
        game.onNoteReachedLine(note);
      }
    }

    // Se non è più attiva (risolta o mancata) inizia la dissolvenza.
    if (!note.isActive && !_resolving) {
      _resolving = true;
    }

    // Posizione X dalla destra verso la linea di esecuzione.
    final double startX = game.size.x + 30;
    final double endX = GameConfig.judgmentLineX;
    position = Vector2(
      startX - note.progress * (startX - endX),
      Staff.yForPitch(note.pitch),
    );
  }

  @override
  void render(Canvas canvas) {
    final Color c = note.color;
    final double alpha = _fade.clamp(0.0, 1.0);

    // Gambo della nota.
    final Paint stem = Paint()
      ..color = Colors.white.withValues(alpha: 0.7 * alpha)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(7, 0), const Offset(7, -22), stem);

    // Testa della nota (ellisse colorata).
    final Paint head = Paint()..color = c.withValues(alpha: alpha);
    canvas.save();
    canvas.rotate(-0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 12),
      head,
    );
    canvas.restore();

    // Bordo.
    canvas.drawCircle(
      Offset.zero,
      8,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}
