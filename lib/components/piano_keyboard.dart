import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../input/key_mapping.dart';

/// Tastiera di pianoforte on-screen in fondo allo schermo: una fila di tasti
/// diatonici cliccabili/tappabili, uno per pitch.
class PianoKeyboard extends Component with HasGameReference<BattleHymnGame> {
  final List<PianoKey> _keys = [];

  PianoKeyboard() : super(priority: 30);

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < GameConfig.scaleLength; i++) {
      final PianoKey key = PianoKey(pitch: i);
      _keys.add(key);
      add(key);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Layout responsive: i tasti si ridimensionano con la larghezza schermo.
    final double n = GameConfig.scaleLength.toDouble();
    final double keyWidth = game.size.x / n;
    final double top = game.size.y - GameConfig.keyboardHeight;
    for (int i = 0; i < _keys.length; i++) {
      _keys[i]
        ..position = Vector2(i * keyWidth, top)
        ..size = Vector2(keyWidth, GameConfig.keyboardHeight);
    }
  }

  /// Evidenzia visivamente il tasto di un pitch (input da tastiera fisica).
  void flash(int pitch) {
    if (pitch >= 0 && pitch < _keys.length) _keys[pitch].flash();
  }
}

/// Singolo tasto del pianoforte: cliccabile/tappabile (TapCallbacks).
class PianoKey extends PositionComponent
    with HasGameReference<BattleHymnGame>, TapCallbacks {
  final int pitch;
  double _press = 0; // intensità di pressione per il feedback

  PianoKey({required this.pitch});

  void flash() => _press = 1;

  @override
  void onTapDown(TapDownEvent event) {
    game.playPitch(pitch);
    flash();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_press > 0) _press = (_press - dt * 4).clamp(0, 1);
  }

  @override
  void render(Canvas canvas) {
    final Color base = GameConfig.colorForPitch(pitch);
    final Rect rect = Rect.fromLTWH(2, 2, size.x - 4, size.y - 4);
    final RRect rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(6));

    // Corpo del tasto (più chiaro se premuto).
    final Paint fill = Paint()
      ..color = Color.lerp(
        const Color(0xFFEDEDED),
        base,
        0.25 + _press * 0.6,
      )!;
    canvas.drawRRect(rrect, fill);

    // Bordo.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Striscia colorata superiore (identifica l'elemento).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top, rect.width, 8),
        const Radius.circular(6),
      ),
      Paint()..color = base,
    );

    // Etichette: nome nota + tasto fisico.
    _text(
      canvas,
      GameConfig.scaleNames[pitch],
      Offset(size.x / 2, size.y * 0.52),
      16,
      Colors.black87,
      bold: true,
    );
    _text(
      canvas,
      KeyMapping.keyLabels[pitch],
      Offset(size.x / 2, size.y * 0.78),
      12,
      Colors.black54,
    );
  }

  void _text(Canvas canvas, String s, Offset center, double size, Color color,
      {bool bold = false}) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}
