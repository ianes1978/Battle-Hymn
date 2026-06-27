import 'package:flutter/material.dart';

import 'config.dart';

/// Esito del tempismo quando il giocatore suona una nota.
enum Judgment { perfect, good, miss, none }

/// Stato del "beat" (coppia nota + nemico, che condividono questo dato).
enum BeatState {
  /// In arrivo: il nemico avanza, la nota scorre.
  active,

  /// Suonata correttamente: il nemico viene distrutto.
  resolved,

  /// Non suonata in tempo: il nemico colpisce il mago.
  missed,
}

/// Modello dati condiviso tra una nota sullo spartito e il nemico associato.
///
/// È la "fonte di verità" del timing: la [NoteComponent] avanza [elapsed],
/// mentre la [EnemyComponent] legge soltanto [progress] per posizionarsi in
/// modo sincronizzato.
class NoteData {
  /// Indice del grado della scala (0..scaleLength-1).
  final int pitch;

  /// Direzione (in radianti) da cui arriva il nemico, a 360°.
  final double angle;

  /// Secondi necessari per raggiungere la linea di esecuzione / il mago.
  final double duration;

  /// Tempo trascorso dallo spawn.
  double elapsed = 0;

  /// Stato corrente del beat.
  BeatState state = BeatState.active;

  /// Giudizio assegnato al momento della risoluzione (per feedback).
  Judgment judgment = Judgment.none;

  NoteData({
    required this.pitch,
    required this.angle,
    required this.duration,
  });

  /// Avanzamento normalizzato: 0 = appena spawnato (lontano), 1 = sulla linea.
  double get progress => (elapsed / duration).clamp(0.0, 1.0);

  /// Secondi rimanenti prima che la nota raggiunga la linea.
  double get timeRemaining => (duration - elapsed).clamp(0.0, duration);

  bool get isActive => state == BeatState.active;

  /// Colore/elemento associato al pitch.
  Color get color => GameConfig.colorForPitch(pitch);

  /// Calcola il giudizio in base al tempo rimanente al momento della pressione.
  /// Ritorna [Judgment.none] se la nota è ancora troppo lontana.
  Judgment evaluate() {
    if (timeRemaining <= GameConfig.perfectWindow) return Judgment.perfect;
    if (timeRemaining <= GameConfig.goodWindow) return Judgment.good;
    return Judgment.none;
  }
}
