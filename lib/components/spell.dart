import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';

/// Proiettile di magia cosmetico: parte dal mago e viaggia verso il punto in
/// cui si trovava il nemico al momento del colpo, poi esplode in particelle.
class Spell extends PositionComponent with HasGameReference<BattleHymnGame> {
  final Vector2 target;
  final Color color;

  static const double speed = 900; // pixel/secondo
  late Vector2 _dir;
  final List<_Particle> _particles = [];
  bool _exploded = false;
  double _life = 0;
  final List<Offset> _trail = [];

  Spell({
    required Vector2 start,
    required this.target,
    required this.color,
  }) : super(priority: 12, anchor: Anchor.center) {
    position = start.clone();
    final Vector2 delta = target - start;
    _dir = delta.length == 0 ? Vector2(0, -1) : delta.normalized();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;

    if (!_exploded) {
      position += _dir * speed * dt;
      _trail.insert(0, position.toOffset());
      if (_trail.length > 8) _trail.removeLast();

      // Arrivo a destinazione (o timeout di sicurezza).
      if (position.distanceTo(target) < 18 || _life > 1.2) {
        _explode();
      }
    } else {
      // Aggiorna le particelle dell'esplosione.
      for (final p in _particles) {
        p.pos += p.vel * dt;
        p.vel *= 0.92;
        p.life -= dt;
      }
      _particles.removeWhere((p) => p.life <= 0);
      if (_particles.isEmpty) removeFromParent();
    }
  }

  void _explode() {
    _exploded = true;
    final Random rng = Random(position.x.toInt() ^ position.y.toInt());
    for (int i = 0; i < 14; i++) {
      final double a = rng.nextDouble() * pi * 2;
      final double s = 60 + rng.nextDouble() * 160;
      _particles.add(_Particle(
        pos: position.clone(),
        vel: Vector2(cos(a), sin(a)) * s,
        life: 0.3 + rng.nextDouble() * 0.3,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_exploded) {
      // Scia.
      for (int i = 0; i < _trail.length; i++) {
        final double a = (1 - i / _trail.length) * 0.5;
        canvas.drawCircle(
          _trail[i] - position.toOffset(),
          6.0 * (1 - i / _trail.length),
          Paint()..color = color.withValues(alpha: a),
        );
      }
      // Nucleo del proiettile.
      canvas.drawCircle(
        Offset.zero,
        7,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.white);
    } else {
      // Particelle (in coordinate locali rispetto alla posizione del componente).
      for (final p in _particles) {
        final double a = (p.life / 0.6).clamp(0.0, 1.0);
        canvas.drawCircle(
          (p.pos - position).toOffset(),
          3 * a,
          Paint()..color = color.withValues(alpha: a),
        );
      }
    }
  }
}

/// Particella interna dell'esplosione.
class _Particle {
  Vector2 pos;
  Vector2 vel;
  double life;
  _Particle({required this.pos, required this.vel, required this.life});
}
