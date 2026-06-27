import 'package:flutter/material.dart';

import 'config.dart';
import 'tuning.dart';

/// Esito del tempismo quando si colpisce una nota.
enum Judgment { perfect, good, early, miss, none }

/// Stato del "beat" (coppia nota + nemico, che condividono questo dato).
enum BeatState { active, resolved, missed }

/// Modello dati condiviso tra una nota sullo spartito e il nemico associato.
///
/// - [noteClass] (0..11) è ciò che conta per l'input: premere la nota giusta,
///   a prescindere dall'ottava.
/// - [staffIndex] (0..21) determina solo la posizione verticale sullo spartito
///   (2 ottave, Do basso → La alto).
class NoteData {
  /// Classe di nota (Do, Do#, ...). Per input, colore, etichetta, direzione.
  final int noteClass;

  /// Posizione verticale sullo spartito (0 = Do basso, 21 = La alto).
  final int staffIndex;

  /// Direzione (radianti) da cui arriva il nemico, a 360°.
  final double angle;

  /// Secondi per raggiungere la linea di esecuzione / il mago.
  final double duration;

  double elapsed = 0;
  BeatState state = BeatState.active;
  Judgment judgment = Judgment.none;

  NoteData({
    required this.noteClass,
    required this.staffIndex,
    required this.angle,
    required this.duration,
  });

  double get progress => (elapsed / duration).clamp(0.0, 1.0);
  double get timeRemaining => (duration - elapsed).clamp(0.0, duration);
  bool get isActive => state == BeatState.active;

  Color get color => GameConfig.colorForClass(noteClass);

  /// Giudizio in base al tempismo. Il colpo riesce sempre: se la nota è ancora
  /// lontana il giudizio è [Judgment.early] (nessuna gemma).
  Judgment evaluate() {
    if (timeRemaining <= Tuning.perfectWindow) return Judgment.perfect;
    if (timeRemaining <= Tuning.goodWindow) return Judgment.good;
    return Judgment.early;
  }
}
