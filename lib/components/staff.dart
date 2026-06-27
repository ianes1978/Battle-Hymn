import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';

/// Pentagramma in chiave di violino. Le note sono posizionate su posizioni
/// DIATONICHE reali (linee e spazi): i diesis condividono l'altezza della nota
/// naturale. I tagli addizionali compaiono solo per le note su una linea fuori
/// dal rigo (es. Do centrale, La acuto), non per quelle negli spazi.
class Staff extends Component with HasGameReference<BattleHymnGame> {
  Staff() : super(priority: 20);

  /// Classe di nota (0..11) → grado diatonico (0=Do ... 6=Si).
  /// I diesis prendono il grado della naturale sottostante.
  static const List<int> _classToDegree = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6];

  /// Grado diatonico di riferimento: Mi della 4ª ottava (linea inferiore).
  static const int _refDegree = 4 * 7 + 2; // 30

  /// Indice diatonico assoluto di uno staffIndex (0..21).
  static int diatonicIndex(int staffIndex) {
    final int octaveBit = staffIndex ~/ 12; // 0 = ottava bassa, 1 = alta
    final int noteClass = staffIndex % 12;
    final int octave = 4 + octaveBit;
    return octave * 7 + _classToDegree[noteClass];
  }

  /// Passo verticale tra una linea e lo spazio adiacente (mezzo interspazio).
  static double get _halfStep => GameConfig.staffHeight / 8;

  /// Y della linea inferiore del pentagramma (Mi4).
  static double get _bottomLineY => GameConfig.staffTop + GameConfig.staffHeight;

  /// Coordinata Y per uno staffIndex (posizione diatonica reale).
  static double yForStaffIndex(int staffIndex) =>
      _bottomLineY - (diatonicIndex(staffIndex) - _refDegree) * _halfStep;

  /// True se la nota va su una linea fuori dal rigo → richiede taglio addizionale.
  static bool needsLedger(int staffIndex) {
    final int d = diatonicIndex(staffIndex);
    final bool onLine = d.isEven; // le linee cadono su gradi pari (Mi4 = 30)
    final bool outside = d < _refDegree || d > _refDegree + 8;
    return onLine && outside;
  }

  @override
  void render(Canvas canvas) {
    final double width = game.size.x;
    const double top = GameConfig.staffTop;
    const double height = GameConfig.staffHeight;

    // Estensione verticale occupata dalle note (per pannello e linea).
    final double yHigh = yForStaffIndex(GameConfig.staffMax) - 16;
    final double yLow = yForStaffIndex(GameConfig.staffMin) + 16;

    // Pannello semitrasparente dietro la banda delle note.
    canvas.drawRect(
      Rect.fromLTWH(0, yHigh, width, yLow - yHigh),
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );

    // Le 5 linee principali.
    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 5; i++) {
      final double y = top + height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), linePaint);
    }

    _drawTrebleClef(canvas);

    // Linea di esecuzione (glow).
    const double x = GameConfig.judgmentLineX;
    canvas.drawLine(
      Offset(x, yHigh),
      Offset(x, yLow),
      Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.85)
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawLine(
      Offset(x, yHigh),
      Offset(x, yLow),
      Paint()
        ..color = Colors.amberAccent
        ..strokeWidth = 2.5,
    );
  }

  /// Disegna una chiave di violino (Sol) come un UNICO tratto continuo:
  /// spirale centrale (scroll) attorno alla linea del Sol → risale formando
  /// l'ansa in cima → ridiscende come spina fino sotto il rigo, con codino e
  /// pallino terminale.
  void _drawTrebleClef(Canvas canvas) {
    final double s = GameConfig.staffHeight / 4; // interlinea
    const double top = GameConfig.staffTop;
    final double gLineY = top + 3 * s; // linea del Sol (2ª dal basso)
    final double bottomLineY = top + 4 * s;
    const double cx = 56;

    final Paint p = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double rOuter = 1.05 * s, rInner = 0.12 * s;
    final Path clef = Path();

    // 1) Spirale dal centro verso l'esterno, fino a uscire sul lato sinistro.
    const int n = 80;
    const double turns = 2.2;
    for (int i = 0; i <= n; i++) {
      final double t = i / n;
      final double ang = math.pi - (1 - t) * turns * 2 * math.pi;
      final double r = rInner + (rOuter - rInner) * t;
      final double x = cx + r * math.cos(ang);
      final double y = gLineY + r * math.sin(ang);
      if (i == 0) {
        clef.moveTo(x, y);
      } else {
        clef.lineTo(x, y);
      }
    }
    // Punto di uscita della spirale (lato sinistro, ang = π).
    final double exX = cx - rOuter;
    final double exY = gLineY;

    // 2) Dall'uscita, su e oltre la cima (ansa) verso destra.
    clef.cubicTo(
      exX - 0.25 * s, exY - 1.3 * s,
      cx - 0.2 * s, top - 1.3 * s,
      cx + 0.18 * s, top - 1.0 * s,
    );
    // 3) Ridiscende come spina attraverso il rigo, fino sotto.
    clef.cubicTo(
      cx + 0.55 * s, top - 0.1 * s,
      cx + 0.22 * s, gLineY + 0.4 * s,
      cx + 0.05 * s, bottomLineY + 0.9 * s,
    );
    // 4) Codino con gancio a sinistra.
    clef.cubicTo(
      cx - 0.05 * s, bottomLineY + 1.6 * s,
      cx - 0.55 * s, bottomLineY + 1.95 * s,
      cx - 0.72 * s, bottomLineY + 1.5 * s,
    );
    canvas.drawPath(clef, p);

    // Pallino terminale.
    canvas.drawCircle(
      Offset(cx - 0.72 * s, bottomLineY + 1.45 * s),
      s * 0.2,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
  }
}
