import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../input/key_mapping.dart';

/// Tastiera di pianoforte on-screen: tasti bianchi (note naturali) con i tasti
/// neri (diesis) sovrapposti, esattamente come un pianoforte reale.
///
/// È un unico componente con [TapCallbacks] che gestisce manualmente il
/// rilevamento del tocco, così i tasti neri hanno la precedenza su quelli
/// bianchi sottostanti (niente doppie note quando si preme un nero).
class PianoKeyboard extends PositionComponent
    with HasGameReference<BattleHymnGame>, TapCallbacks {
  PianoKeyboard() : super(priority: 30);

  /// Intensità di pressione per ogni pitch (per il feedback luminoso).
  final List<double> _flash =
      List<double>.filled(GameConfig.scaleLength, 0, growable: false);

  /// Larghezza di un tasto bianco (calcolata in [update]).
  double _whiteWidth = 0;

  @override
  void update(double dt) {
    super.update(dt);
    // Layout responsive: la tastiera occupa tutta la larghezza in basso.
    position = Vector2(0, game.size.y - GameConfig.keyboardHeight);
    size = Vector2(game.size.x, GameConfig.keyboardHeight);
    _whiteWidth = size.x / GameConfig.whitePitches.length;

    for (int i = 0; i < _flash.length; i++) {
      if (_flash[i] > 0) _flash[i] = (_flash[i] - dt * 4).clamp(0, 1);
    }
  }

  /// Evidenzia visivamente il tasto di un pitch (input da tastiera fisica).
  void flash(int pitch) {
    if (pitch >= 0 && pitch < _flash.length) _flash[pitch] = 1;
  }

  // ---------------------------------------------------------------------------
  // Geometria dei tasti (in coordinate locali al componente)
  // ---------------------------------------------------------------------------

  Rect _whiteRect(int whiteIndex) =>
      Rect.fromLTWH(whiteIndex * _whiteWidth, 0, _whiteWidth, size.y);

  double get _blackWidth => _whiteWidth * 0.62;
  double get _blackHeight => size.y * 0.62;

  Rect _blackRect(int leftWhite) {
    final double centerX = (leftWhite + 1) * _whiteWidth;
    return Rect.fromLTWH(
      centerX - _blackWidth / 2,
      0,
      _blackWidth,
      _blackHeight,
    );
  }

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------

  @override
  void onTapDown(TapDownEvent event) {
    final Offset p = Offset(event.localPosition.x, event.localPosition.y);

    // Prima i tasti neri (stanno sopra).
    if (p.dy <= _blackHeight) {
      for (final b in GameConfig.blackKeys) {
        if (_blackRect(b.leftWhite).contains(p)) {
          _press(b.pitch);
          return;
        }
      }
    }

    // Poi i tasti bianchi.
    final int whiteIndex = (p.dx / _whiteWidth).floor();
    if (whiteIndex >= 0 && whiteIndex < GameConfig.whitePitches.length) {
      _press(GameConfig.whitePitches[whiteIndex]);
    }
  }

  void _press(int pitch) {
    game.playPitch(pitch);
    flash(pitch);
  }

  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------

  @override
  void render(Canvas canvas) {
    // 1) Tasti bianchi.
    for (int i = 0; i < GameConfig.whitePitches.length; i++) {
      final int pitch = GameConfig.whitePitches[i];
      _drawWhiteKey(canvas, _whiteRect(i), pitch);
    }

    // 2) Tasti neri sopra.
    for (final b in GameConfig.blackKeys) {
      _drawBlackKey(canvas, _blackRect(b.leftWhite), b.pitch);
    }
  }

  void _drawWhiteKey(Canvas canvas, Rect rect, int pitch) {
    final double press = _flash[pitch];
    final RRect rrect = RRect.fromRectAndCorners(
      rect.deflate(1),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );

    // Corpo: bianco, si tinge del colore del pitch quando premuto.
    final Paint fill = Paint()
      ..color = Color.lerp(
        const Color(0xFFF7F7F7),
        GameConfig.colorForPitch(pitch),
        press * 0.7,
      )!;
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Pallino del colore-elemento (riferimento per il giocatore).
    canvas.drawCircle(
      Offset(rect.center.dx, rect.bottom - 30),
      5,
      Paint()..color = GameConfig.colorForPitch(pitch),
    );

    // Etichette: nome nota + tasto fisico.
    _text(canvas, KeyMapping.keyLabels[pitch],
        Offset(rect.center.dx, rect.bottom - 16), 13, Colors.black87,
        bold: true);
    _text(canvas, GameConfig.scaleNames[pitch],
        Offset(rect.center.dx, rect.bottom - 46), 10, Colors.black54);
  }

  void _drawBlackKey(Canvas canvas, Rect rect, int pitch) {
    final double press = _flash[pitch];
    final RRect rrect = RRect.fromRectAndCorners(
      rect,
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );

    // Corpo: nero, si illumina del colore del pitch quando premuto.
    final Paint fill = Paint()
      ..color = Color.lerp(
        const Color(0xFF1A1A1A),
        GameConfig.colorForPitch(pitch),
        press * 0.85,
      )!;
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Pallino del colore-elemento.
    canvas.drawCircle(
      Offset(rect.center.dx, rect.bottom - 22),
      4,
      Paint()..color = GameConfig.colorForPitch(pitch),
    );

    // Etichetta del tasto fisico (in chiaro su fondo scuro).
    _text(canvas, KeyMapping.keyLabels[pitch],
        Offset(rect.center.dx, rect.bottom - 12), 11, Colors.white,
        bold: true);
  }

  void _text(
    Canvas canvas,
    String s,
    Offset center,
    double fontSize,
    Color color, {
    bool bold = false,
  }) {
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
