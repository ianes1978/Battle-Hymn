import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../game/note_data.dart';

/// Nemico che avanza radialmente verso il mago. La sua posizione è derivata
/// dal [NoteData] condiviso con la nota sullo spartito (sincronizzati).
class Enemy extends PositionComponent with HasGameReference<BattleHymnGame> {
  final NoteData note;

  /// Raggio massimo (distanza di spawn) calcolato in base allo schermo.
  late double _maxRadius;

  /// Timer dell'animazione di morte (se > 0 il nemico sta scomparendo).
  double _deathTimer = 0;
  bool _dying = false;
  double _scale = 1;
  double _spin = 0;

  Enemy({required this.note}) : super(priority: 10, anchor: Anchor.center);

  @override
  void onMount() {
    super.onMount();
    // Distanza di spawn: abbastanza ampia da partire fuori dall'azione.
    _maxRadius = max(game.size.x, game.size.y) * 0.62;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 2;

    if (_dying) {
      _deathTimer -= dt;
      // Animazione differente per kill (rimpicciolisce) e miss (espande).
      if (note.state == BeatState.resolved) {
        _scale = (_deathTimer / 0.25).clamp(0.0, 1.0);
      } else {
        _scale = 1 + (1 - (_deathTimer / 0.3).clamp(0.0, 1.0)) * 0.6;
      }
      if (_deathTimer <= 0) removeFromParent();
      return;
    }

    // Avvia l'animazione di morte alla transizione di stato.
    if (note.state == BeatState.resolved) {
      _startDeath(0.25);
      return;
    }
    if (note.state == BeatState.missed) {
      _startDeath(0.3);
      return;
    }

    // Posizione radiale: progress 0 = lontano, progress 1 = sul mago.
    final Vector2 origin = game.wizard.homePosition;
    final double distance = _maxRadius * (1 - note.progress);
    position = origin + Vector2(cos(note.angle), sin(note.angle)) * distance;
  }

  void _startDeath(double duration) {
    _dying = true;
    _deathTimer = duration;
  }

  @override
  void render(Canvas canvas) {
    // Anello di esplosione quando il nemico viene distrutto.
    if (_dying && note.state == BeatState.resolved) {
      final double prog = ((0.25 - _deathTimer) / 0.25).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset.zero,
        16 + prog * 28,
        Paint()
          ..color = note.color.withValues(alpha: (1 - prog) * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * (1 - prog) + 0.5,
      );
    }

    final bool isTarget = game.activeTarget == note;

    // Anello di evidenziazione del bersaglio corrente (non ruota/scala).
    if (isTarget && !_dying) {
      canvas.drawCircle(
        Offset.zero,
        26,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        Offset.zero,
        26,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    canvas.save();
    canvas.scale(_scale);
    canvas.rotate(_spin);

    final Color c = note.color;
    const double r = 16;

    // Bagliore.
    canvas.drawCircle(
      Offset.zero,
      r + 6,
      Paint()
        ..color = c.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Corpo: rombo/cristallo a 4 punte.
    final Path body = Path()
      ..moveTo(0, -r)
      ..lineTo(r * 0.7, 0)
      ..lineTo(0, r)
      ..lineTo(-r * 0.7, 0)
      ..close();
    canvas.drawPath(body, Paint()..color = c);
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.restore();

    // Etichetta della nota (solfège/lettere/nessuna), sempre dritta e leggibile.
    if (!_dying) {
      final String label =
          GameConfig.labelForClass(note.noteClass, game.settings.labelMode);
      if (label.isNotEmpty) _drawLabel(canvas, label);
    }
  }

  void _drawLabel(Canvas canvas, String s) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 3, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}
