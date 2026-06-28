import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Esplosione di particelle leggere usata come feedback (colpo, distruzione,
/// errore). Si rimuove da sola al termine. Niente dipendenze esterne: disegna
/// puntini che si espandono e svaniscono.
class Burst extends Component {
  final Vector2 origin;
  final Color color;
  final int count;
  final double speed;
  final double maxLife;

  final List<_P> _parts = [];
  static final Random _rng = Random();

  Burst({
    required this.origin,
    required this.color,
    this.count = 10,
    this.speed = 120,
    this.maxLife = 0.5,
  }) : super(priority: 30) {
    for (int i = 0; i < count; i++) {
      final double a = _rng.nextDouble() * 2 * pi;
      final double v = speed * (0.4 + _rng.nextDouble() * 0.8);
      _parts.add(_P(
        pos: origin.clone(),
        vel: Vector2(cos(a), sin(a)) * v,
        life: maxLife * (0.6 + _rng.nextDouble() * 0.4),
        size: 1.5 + _rng.nextDouble() * 2.5,
      ));
    }
  }

  @override
  void update(double dt) {
    bool any = false;
    for (final _P p in _parts) {
      if (p.life <= 0) continue;
      any = true;
      p.life -= dt;
      p.vel *= 0.90; // attrito
      p.pos += p.vel * dt;
    }
    if (!any) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    for (final _P p in _parts) {
      if (p.life <= 0) continue;
      final double a = (p.life / maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.pos.x, p.pos.y),
        p.size * a,
        Paint()..color = color.withValues(alpha: a),
      );
    }
  }
}

class _P {
  Vector2 pos;
  Vector2 vel;
  double life;
  double size;
  _P({required this.pos, required this.vel, required this.life, required this.size});
}
