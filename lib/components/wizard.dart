import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';

/// Il mago: fisso al centro-basso dello schermo, non si muove.
/// Disegnato con forme geometriche (cappello + mantello).
class Wizard extends PositionComponent with HasGameReference<BattleHymnGame> {
  Wizard() : super(priority: 15, anchor: Anchor.center);

  /// Timer del flash di lancio (quando spara una magia).
  double _castFlash = 0;

  /// Angolo verso cui il mago sta "guardando" durante l'ultimo lancio.
  double _aim = -pi / 2;

  /// Posizione del mago calcolata dalla dimensione corrente dello schermo.
  Vector2 get center => Vector2(
        game.size.x / 2,
        game.size.y - GameConfig.wizardBottomOffset,
      );

  /// Innesca l'animazione di lancio verso [angle].
  void cast(double angle) {
    _castFlash = 0.25;
    _aim = angle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = center;
    if (_castFlash > 0) _castFlash -= dt;
  }

  @override
  void render(Canvas canvas) {
    const double r = 26; // raggio corpo
    final Color robe = const Color(0xFF5C6BC0);
    final Color hat = const Color(0xFF3949AB);

    // Aura di lancio.
    if (_castFlash > 0) {
      final double a = (_castFlash / 0.25).clamp(0.0, 1.0);
      final Paint aura = Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.5 * a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset.zero, r + 18, aura);

      // Indicatore di mira.
      final Paint aim = Paint()
        ..color = Colors.amberAccent.withValues(alpha: a)
        ..strokeWidth = 3;
      canvas.drawLine(
        Offset.zero,
        Offset(cos(_aim) * (r + 24), sin(_aim) * (r + 24)),
        aim,
      );
    }

    // Mantello (corpo).
    final Path body = Path()
      ..moveTo(0, -r)
      ..lineTo(r, r + 6)
      ..lineTo(-r, r + 6)
      ..close();
    canvas.drawPath(body, Paint()..color = robe);

    // Testa.
    canvas.drawCircle(
      const Offset(0, -r + 2),
      9,
      Paint()..color = const Color(0xFFFFE0B2),
    );

    // Cappello a punta.
    final Path cap = Path()
      ..moveTo(0, -r - 22)
      ..lineTo(13, -r + 2)
      ..lineTo(-13, -r + 2)
      ..close();
    canvas.drawPath(cap, Paint()..color = hat);

    // Stella sul cappello.
    canvas.drawCircle(
      Offset(0, -r - 6),
      2.5,
      Paint()..color = Colors.amberAccent,
    );
  }
}
