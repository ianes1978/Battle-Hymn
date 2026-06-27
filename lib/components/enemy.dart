import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../game/note_data.dart';

/// Nemico che avanza radialmente verso il mago. La posizione deriva dal
/// [NoteData] condiviso. Il tipo ([EnemyType]) ne cambia dimensione e decori.
class Enemy extends PositionComponent with HasGameReference<BattleHymnGame> {
  final NoteData note;

  late double _maxRadius;
  double _deathTimer = 0;
  bool _dying = false;
  double _scale = 1;
  double _spin = 0;

  // Flash quando incassa un colpo (per i nemici a più colpi).
  int _prevHits = 0;
  double _hitFlash = 0;

  Enemy({required this.note}) : super(priority: 10, anchor: Anchor.center);

  /// Fattore di dimensione in base al tipo.
  double get _sizeFactor => switch (note.type) {
        EnemyType.fast => 0.8,
        EnemyType.armored => 1.05,
        EnemyType.boss => 1.8,
        EnemyType.normal => 1.0,
      };

  double get _baseR => 16 * _sizeFactor;

  @override
  void onMount() {
    super.onMount();
    _maxRadius = max(game.size.x, game.size.y) * 0.62;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * (note.type == EnemyType.boss ? 1.2 : 2);
    if (_hitFlash > 0) _hitFlash -= dt;

    // Flash all'incassare di un colpo.
    if (note.hitsTaken != _prevHits) {
      _prevHits = note.hitsTaken;
      _hitFlash = 0.18;
    }

    if (_dying) {
      _deathTimer -= dt;
      if (note.state == BeatState.resolved) {
        _scale = (_deathTimer / 0.25).clamp(0.0, 1.0);
      } else {
        _scale = 1 + (1 - (_deathTimer / 0.3).clamp(0.0, 1.0)) * 0.6;
      }
      if (_deathTimer <= 0) removeFromParent();
      return;
    }

    if (note.state == BeatState.resolved) {
      _startDeath(0.25);
      return;
    }
    if (note.state == BeatState.missed) {
      _startDeath(0.3);
      return;
    }

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
    final Color c = note.color;
    final double r = _baseR;

    // Anello di esplosione alla distruzione.
    if (_dying && note.state == BeatState.resolved) {
      final double prog = ((0.25 - _deathTimer) / 0.25).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset.zero,
        r + prog * 28,
        Paint()
          ..color = c.withValues(alpha: (1 - prog) * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * (1 - prog) + 0.5,
      );
    }

    // Evidenziazione del bersaglio corrente.
    if (game.activeTarget == note && !_dying) {
      final double rr = r + 10;
      canvas.drawCircle(Offset.zero, rr,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3);
      canvas.drawCircle(
        Offset.zero,
        rr,
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

    // Bagliore.
    canvas.drawCircle(
      Offset.zero,
      r + 6,
      Paint()
        ..color = c.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Anello d'armatura per corazzati/boss (esagono metallico).
    if (note.type == EnemyType.armored || note.type == EnemyType.boss) {
      _drawArmorRing(canvas, r + 5);
    }

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
    // Flash bianco quando incassa un colpo.
    if (_hitFlash > 0) {
      canvas.drawPath(
        body,
        Paint()..color = Colors.white.withValues(alpha: (_hitFlash / 0.18) * 0.7),
      );
    }

    canvas.restore();

    if (_dying) return;

    // Scie di velocità.
    if (note.type == EnemyType.fast) _drawStreaks(canvas, r);

    // Corona del boss.
    if (note.type == EnemyType.boss) _drawCrown(canvas, r);

    // Pip dei colpi residui (corazzato/boss).
    if (note.hits > 1) _drawHitPips(canvas, r);

    // Etichetta della nota.
    final String label =
        GameConfig.labelForClass(note.noteClass, game.settings.labelMode);
    if (label.isNotEmpty) _drawLabel(canvas, label, note.type == EnemyType.boss);
  }

  void _drawArmorRing(Canvas canvas, double radius) {
    final Path hex = Path();
    for (int i = 0; i < 6; i++) {
      final double a = i / 6 * 2 * pi;
      final Offset p = Offset(cos(a) * radius, sin(a) * radius);
      i == 0 ? hex.moveTo(p.dx, p.dy) : hex.lineTo(p.dx, p.dy);
    }
    hex.close();
    canvas.drawPath(
      hex,
      Paint()
        ..color = const Color(0xFFB0BEC5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawStreaks(Canvas canvas, double r) {
    // Direzione "uscente" (dietro al moto, che è verso il centro).
    final Offset out = Offset(cos(note.angle), sin(note.angle));
    final Offset perp = Offset(-out.dy, out.dx);
    final Paint p = Paint()
      ..color = note.color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = -1; i <= 1; i++) {
      final Offset off = perp * (i * 5.0);
      canvas.drawLine(out * r + off, out * (r + 14) + off, p);
    }
  }

  void _drawCrown(Canvas canvas, double r) {
    final double y = -r - 8;
    final Path crown = Path()
      ..moveTo(-12, y)
      ..lineTo(-12, y - 8)
      ..lineTo(-6, y - 2)
      ..lineTo(0, y - 10)
      ..lineTo(6, y - 2)
      ..lineTo(12, y - 8)
      ..lineTo(12, y)
      ..close();
    canvas.drawPath(crown, Paint()..color = const Color(0xFFF7CA17));
  }

  void _drawHitPips(Canvas canvas, double r) {
    final int left = note.hitsLeft.clamp(0, note.hits);
    final double y = -r - (note.type == EnemyType.boss ? 20 : 12);
    const double gap = 7;
    final double startX = -(note.hits - 1) * gap / 2;
    for (int i = 0; i < note.hits; i++) {
      final bool full = i < left;
      canvas.drawCircle(
        Offset(startX + i * gap, y),
        3,
        Paint()
          ..color = full ? Colors.white : Colors.white24
          ..style = full ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawLabel(Canvas canvas, String s, bool big) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: Colors.white,
          fontSize: big ? 22 : 15,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}
