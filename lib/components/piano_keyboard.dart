import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';

/// Tastiera di pianoforte on-screen: 8 tasti bianchi + 5 neri (un'ottava + Do).
///
/// L'input conta per CLASSE di nota: premere un tasto "Do" o "Do²" produce la
/// stessa nota. Hit-testing manuale così i tasti neri hanno la precedenza.
class PianoKeyboard extends PositionComponent
    with HasGameReference<BattleHymnGame>, TapCallbacks {
  PianoKeyboard() : super(priority: 30);

  /// Intensità di pressione per classe di nota (feedback luminoso).
  final List<double> _flash =
      List<double>.filled(GameConfig.classCount, 0, growable: false);

  double _whiteWidth = 0;

  @override
  void update(double dt) {
    super.update(dt);
    position = Vector2(0, game.size.y - GameConfig.keyboardHeight);
    size = Vector2(game.size.x, GameConfig.keyboardHeight);
    _whiteWidth = size.x / GameConfig.whiteSlotClasses.length;

    for (int i = 0; i < _flash.length; i++) {
      if (_flash[i] > 0) _flash[i] = (_flash[i] - dt * 4).clamp(0, 1);
    }
  }

  /// Evidenzia il tasto di una classe (chiamato anche da tastiera fisica).
  void flashClass(int noteClass) {
    final int c = noteClass % 12;
    if (c >= 0 && c < _flash.length) _flash[c] = 1;
  }

  // --- Geometria (coordinate locali) ---------------------------------------

  Rect _whiteRect(int whiteIndex) =>
      Rect.fromLTWH(whiteIndex * _whiteWidth, 0, _whiteWidth, size.y);

  double get _blackWidth => _whiteWidth * 0.62;
  double get _blackHeight => size.y * 0.62;

  Rect _blackRect(int leftWhite) {
    final double centerX = (leftWhite + 1) * _whiteWidth;
    return Rect.fromLTWH(centerX - _blackWidth / 2, 0, _blackWidth, _blackHeight);
  }

  // --- Input ----------------------------------------------------------------

  @override
  void onTapDown(TapDownEvent event) {
    final Offset p = Offset(event.localPosition.x, event.localPosition.y);

    if (p.dy <= _blackHeight) {
      for (final b in GameConfig.blackSlots) {
        if (_blackRect(b.leftWhite).contains(p)) {
          _press(b.noteClass);
          return;
        }
      }
    }

    final int whiteIndex = (p.dx / _whiteWidth).floor();
    if (whiteIndex >= 0 && whiteIndex < GameConfig.whiteSlotClasses.length) {
      _press(GameConfig.whiteSlotClasses[whiteIndex]);
    }
  }

  void _press(int noteClass) {
    game.playClass(noteClass);
    flashClass(noteClass);
  }

  // --- Rendering ------------------------------------------------------------

  @override
  void render(Canvas canvas) {
    final bool colored = game.settings.keyboardColors;

    for (int i = 0; i < GameConfig.whiteSlotClasses.length; i++) {
      _drawWhiteKey(
          canvas, _whiteRect(i), GameConfig.whiteSlotClasses[i], colored);
    }
    for (final b in GameConfig.blackSlots) {
      _drawBlackKey(canvas, _blackRect(b.leftWhite), b.noteClass, colored);
    }
  }

  void _drawWhiteKey(Canvas canvas, Rect rect, int noteClass, bool colored) {
    final double press = _flash[noteClass % 12];
    final RRect rrect = RRect.fromRectAndCorners(
      rect.deflate(1),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );

    // Corpo: bianco; da premuto si tinge (se colori attivi) o si scurisce.
    final Color pressed = colored
        ? GameConfig.colorForClass(noteClass)
        : const Color(0xFFBDBDBD);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Color.lerp(const Color(0xFFF7F7F7), pressed, press * 0.7)!,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Pallino del colore-elemento (solo se i colori tastiera sono attivi).
    if (colored) {
      canvas.drawCircle(Offset(rect.center.dx, rect.bottom - 30), 5,
          Paint()..color = GameConfig.colorForClass(noteClass));
    }

    // Etichetta (solfège/lettere/nessuna).
    final String label =
        GameConfig.labelForClass(noteClass, game.settings.labelMode);
    if (label.isNotEmpty) {
      _text(canvas, label, Offset(rect.center.dx, rect.bottom - 16), 13,
          Colors.black87, bold: true);
    }
  }

  void _drawBlackKey(Canvas canvas, Rect rect, int noteClass, bool colored) {
    final double press = _flash[noteClass % 12];
    final RRect rrect = RRect.fromRectAndCorners(
      rect,
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );

    final Color pressed = colored
        ? GameConfig.colorForClass(noteClass)
        : const Color(0xFF666666);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Color.lerp(const Color(0xFF1A1A1A), pressed, press * 0.85)!,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    if (colored) {
      canvas.drawCircle(Offset(rect.center.dx, rect.bottom - 22), 4,
          Paint()..color = GameConfig.colorForClass(noteClass));
    }

    final String label =
        GameConfig.labelForClass(noteClass, game.settings.labelMode);
    if (label.isNotEmpty) {
      _text(canvas, label, Offset(rect.center.dx, rect.bottom - 12), 10,
          Colors.white, bold: true);
    }
  }

  void _text(Canvas canvas, String s, Offset center, double fontSize, Color color,
      {bool bold = false}) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}
