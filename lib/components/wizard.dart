import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';

/// Il mago: fisso al centro-basso. Look vettoriale ripreso dall'SVG fornito
/// (mantello blu, cappello a punta con highlight, cappuccio scuro, mani e
/// quadrati dorati). Il bastone con l'orb verde punta verso il bersaglio.
class Wizard extends PositionComponent with HasGameReference<BattleHymnGame> {
  Wizard() : super(priority: 15, anchor: Anchor.center);

  // Palette (dall'SVG).
  static const _robe = Color(0xFF2B3AD1);
  static const _robeShadow = Color(0xFF1A2280);
  static const _collar = Color(0xFF4A5AEE);
  static const _feet = Color(0xFF5A66C2);
  static const _feetDark = Color(0xFF3A45A0);
  static const _hood = Color(0xFF121A55);
  static const _gold = Color(0xFFF7CA17);
  static const _goldHi = Color(0xFFFFE066);
  static const _staffCol = Color(0xFF6E4A22);
  static const _knob = Color(0xFFE1B233);

  /// Fattore di scala dall'SVG (alto ~234u) alla dimensione di gioco.
  static const double _s = 0.34;

  double _castFlash = 0;
  double _aim = -pi / 2; // direzione del bastone (verso l'alto a riposo)
  double _t = 0;

  Vector2 get homePosition => Vector2(
        game.size.x / 2,
        game.size.y - GameConfig.wizardBottomOffset,
      );

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
    final double bob = sin(_t * 2.2) * 1.2;
    canvas.translate(0, bob);
    canvas.scale(_s); // tutto il disegno è in coordinate SVG

    _drawBody(canvas);
    _drawStaff(canvas, cast);
  }

  // --- helper di disegno ----------------------------------------------------

  Paint _fill(Color c, [double a = 1]) =>
      Paint()..color = a == 1 ? c : c.withValues(alpha: a);

  void _rrect(Canvas c, double x, double y, double w, double h, double r,
      Paint p) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      p,
    );
  }

  void _drawBody(Canvas canvas) {
    // Ombra a terra.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 116), width: 104, height: 14),
      _fill(Colors.black, 0.12),
    );

    // Piedi.
    _rrect(canvas, -30, 98, 22, 16, 3, _fill(_feet));
    _rrect(canvas, 8, 98, 22, 16, 3, _fill(_feet));
    _rrect(canvas, -30, 108, 22, 6, 2, _fill(_feetDark));
    _rrect(canvas, 8, 108, 22, 6, 2, _fill(_feetDark));

    // Mantello.
    final Path robe = Path()
      ..moveTo(-42, 10)
      ..lineTo(-54, 102)
      ..quadraticBezierTo(0, 116, 54, 102)
      ..lineTo(42, 10)
      ..quadraticBezierTo(0, 2, -42, 10)
      ..close();
    canvas.drawPath(robe, _fill(_robe));
    final Path robeSh = Path()
      ..moveTo(0, 7)
      ..lineTo(54, 102)
      ..quadraticBezierTo(27, 110, 0, 112)
      ..close();
    canvas.drawPath(robeSh, _fill(_robeShadow, 0.5));
    final Path collar = Path()
      ..moveTo(-42, 10)
      ..quadraticBezierTo(0, 2, 42, 10)
      ..lineTo(40, 18)
      ..quadraticBezierTo(0, 10, -40, 18)
      ..close();
    canvas.drawPath(collar, _fill(_collar, 0.5));

    // Quadrato dorato sul petto.
    _rrect(canvas, -9, 34, 18, 18, 2, _fill(_gold));
    _rrect(canvas, -9, 34, 18, 5, 2, _fill(_goldHi));

    // Cappello.
    final Path hat = Path()
      ..moveTo(0, -118)
      ..lineTo(-52, -20)
      ..quadraticBezierTo(0, -4, 52, -20)
      ..close();
    canvas.drawPath(hat, _fill(_robe));
    final Path hatSh = Path()
      ..moveTo(0, -118)
      ..lineTo(52, -20)
      ..quadraticBezierTo(26, -8, 0, -7)
      ..close();
    canvas.drawPath(hatSh, _fill(_robeShadow, 0.55));
    final Path hatHi = Path()
      ..moveTo(0, -118)
      ..lineTo(-52, -20)
      ..lineTo(-42, -22)
      ..lineTo(-3, -108)
      ..close();
    canvas.drawPath(hatHi, _fill(_collar, 0.6));

    // Cappuccio scuro (volto).
    final Path hood = Path()
      ..moveTo(-40, -22)
      ..quadraticBezierTo(0, -6, 40, -22)
      ..lineTo(40, 10)
      ..quadraticBezierTo(0, 18, -40, 10)
      ..close();
    canvas.drawPath(hood, _fill(_hood));

    // Mani dorate.
    _rrect(canvas, -30, -16, 14, 26, 6, _fill(_gold));
    _rrect(canvas, 16, -16, 14, 26, 6, _fill(_gold));

    // Quadrato dorato sul cappello.
    _rrect(canvas, -9, -74, 18, 18, 2, _fill(_gold));
    _rrect(canvas, -9, -74, 18, 5, 2, _fill(_goldHi));
  }

  void _drawStaff(Canvas canvas, double cast) {
    const Offset hand = Offset(6, -2);
    final Offset dir = Offset(cos(_aim), sin(_aim));
    const double len = 104;
    final Offset tip = hand + dir * len;

    // Asta.
    canvas.drawLine(
      hand,
      tip,
      Paint()
        ..color = _staffCol
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    // Pomelli dorati lungo l'asta.
    canvas.drawCircle(hand + dir * (len * 0.45), 4.5, _fill(_knob));
    canvas.drawCircle(hand + dir * (len * 0.78), 4.5, _fill(_knob));
    canvas.drawCircle(tip, 7, _fill(_knob));

    // Orb verde sulla punta (pulsa a riposo, brilla nel lancio).
    final double pulse = (0.9 + 0.1 * sin(_t * 4)) * (1 + 0.35 * cast);
    _drawOrb(canvas, tip, pulse, cast);

    // Muzzle flash durante il lancio.
    if (cast > 0) {
      _drawFlash(canvas, tip, cast);
    }
  }

  void _drawOrb(Canvas canvas, Offset c, double scale, double cast) {
    // Bagliore.
    canvas.drawCircle(
      c,
      24 * scale,
      Paint()
        ..color = const Color(0xFF33DD33).withValues(alpha: 0.45 + 0.3 * cast)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(c, 13 * scale, _fill(const Color(0xFF2FC42F)));
    canvas.drawCircle(c, 8.5 * scale, _fill(const Color(0xFF74FF74)));
    canvas.drawCircle(c, 4 * scale, _fill(const Color(0xFFECFFEC)));
  }

  void _drawFlash(Canvas canvas, Offset c, double a) {
    final Path star = Path()
      ..moveTo(c.dx, c.dy - 14)
      ..lineTo(c.dx + 4, c.dy - 4)
      ..lineTo(c.dx + 14, c.dy)
      ..lineTo(c.dx + 4, c.dy + 4)
      ..lineTo(c.dx, c.dy + 14)
      ..lineTo(c.dx - 4, c.dy + 4)
      ..lineTo(c.dx - 14, c.dy)
      ..lineTo(c.dx - 4, c.dy - 4)
      ..close();
    canvas.drawPath(star, _fill(const Color(0xFF74FF74), 0.9 * a));
    canvas.drawCircle(c, 5 * a, _fill(const Color(0xFFECFFEC)));
  }
}
