import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';

/// Il mago: fisso al centro-basso dello schermo. Disegnato in vettoriale, in
/// stile "pixel/chibi" ispirato allo sprite (cappello blu a punta col quadrato
/// dorato, faccia gialla, mantello, bastone con gemma verde che mira).
class Wizard extends PositionComponent with HasGameReference<BattleHymnGame> {
  Wizard() : super(priority: 15, anchor: Anchor.center);

  // Palette.
  static const _robe = Color(0xFF2E43C0);
  static const _robeDark = Color(0xFF20307F);
  static const _hat = Color(0xFF283BA6);
  static const _gold = Color(0xFFF2C14E);
  static const _face = Color(0xFFF6C84B);
  static const _staff = Color(0xFF7A5230);
  static const _gem = Color(0xFF38E07B);

  /// Timer del flash di lancio (quando spara una magia).
  double _castFlash = 0;

  /// Direzione verso cui punta il bastone (ultimo lancio); default verso l'alto.
  double _aim = -pi / 2;

  /// Leggero "respiro" idle.
  double _t = 0;

  Vector2 get homePosition => Vector2(
        game.size.x / 2,
        game.size.y - GameConfig.wizardBottomOffset,
      );

  /// Innesca l'animazione di lancio verso [angle].
  void cast(double angle) {
    _castFlash = 0.28;
    _aim = angle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = homePosition;
    _t += dt;
    if (_castFlash > 0) _castFlash -= dt;
  }

  @override
  void render(Canvas canvas) {
    final double cast = (_castFlash / 0.28).clamp(0.0, 1.0);
    // Respiro: leggera oscillazione verticale.
    final double bob = sin(_t * 2.2) * 1.2;
    canvas.translate(0, bob);

    _drawShadow(canvas);
    if (cast > 0) _drawAura(canvas, cast);
    _drawBody(canvas);
    _drawHead(canvas);
    _drawHat(canvas);
    _drawStaff(canvas, cast);
  }

  void _drawShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 34), width: 46, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );
  }

  void _drawAura(Canvas canvas, double a) {
    canvas.drawCircle(
      Offset.zero,
      40,
      Paint()
        ..color = _gem.withValues(alpha: 0.35 * a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  void _drawBody(Canvas canvas) {
    // Mantello a campana.
    final Path robe = Path()
      ..moveTo(-14, -8)
      ..lineTo(14, -8)
      ..quadraticBezierTo(26, 16, 22, 32)
      ..lineTo(-22, 32)
      ..quadraticBezierTo(-26, 16, -14, -8)
      ..close();
    canvas.drawPath(robe, Paint()..color = _robe);
    // Ombra laterale.
    final Path shade = Path()
      ..moveTo(4, -8)
      ..lineTo(14, -8)
      ..quadraticBezierTo(26, 16, 22, 32)
      ..lineTo(6, 32)
      ..close();
    canvas.drawPath(shade, Paint()..color = _robeDark.withValues(alpha: 0.55));
    // Piedini.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-13, 30, 9, 7), const Radius.circular(2)),
      Paint()..color = _robeDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(4, 30, 9, 7), const Radius.circular(2)),
      Paint()..color = _robeDark,
    );
  }

  void _drawHead(Canvas canvas) {
    // Cappuccio (dietro alla faccia).
    canvas.drawCircle(const Offset(0, -14), 17, Paint()..color = _hat);
    // Faccia gialla.
    canvas.drawCircle(const Offset(0, -12), 13, Paint()..color = _face);
    // Occhietti.
    final Paint eye = Paint()..color = const Color(0xFF20307F);
    canvas.drawCircle(const Offset(-5, -13), 1.8, eye);
    canvas.drawCircle(const Offset(5, -13), 1.8, eye);
  }

  void _drawHat(Canvas canvas) {
    // Cappello a punta.
    final Path hat = Path()
      ..moveTo(0, -52)
      ..lineTo(18, -20)
      ..quadraticBezierTo(0, -26, -18, -20)
      ..close();
    canvas.drawPath(hat, Paint()..color = _hat);
    // Punta leggermente piegata (highlight).
    canvas.drawPath(
      Path()
        ..moveTo(0, -52)
        ..lineTo(6, -34)
        ..lineTo(-2, -34)
        ..close(),
      Paint()..color = _robe.withValues(alpha: 0.8),
    );
    // Quadrato dorato (rombo) sul cappello.
    canvas.save();
    canvas.translate(0, -32);
    canvas.rotate(pi / 4);
    canvas.drawRect(
      const Rect.fromLTWH(-4, -4, 8, 8),
      Paint()..color = _gold,
    );
    canvas.restore();
  }

  void _drawStaff(Canvas canvas, double cast) {
    // Il bastone parte dalla "mano" e punta verso _aim.
    const Offset hand = Offset(0, 2);
    final Offset dir = Offset(cos(_aim), sin(_aim));
    final Offset tip = hand + dir * 30;

    canvas.drawLine(
      hand,
      tip,
      Paint()
        ..color = _staff
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Gemma verde sulla punta: pulsa col respiro, brilla nel lancio.
    final double pulse = 0.85 + 0.15 * sin(_t * 4);
    final double glowR = (6 + cast * 10) * pulse;
    canvas.drawCircle(
      tip,
      glowR,
      Paint()
        ..color = _gem.withValues(alpha: 0.5 + 0.4 * cast)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(tip, 4 * pulse, Paint()..color = _gem);
    canvas.drawCircle(tip, 1.8, Paint()..color = Colors.white);
  }
}
