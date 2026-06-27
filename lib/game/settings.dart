/// Preset di difficoltà scelto nel menu.
enum Difficulty { facile, normale, difficile }

/// Modalità di etichetta mostrata su note, nemici e tastiera.
enum LabelMode {
  /// Nomi solfeggiati: Do, Re, Mi, Fa, Sol, La, Si.
  solfege,

  /// Nomi anglosassoni: C, D, E, F, G, A, B.
  letters,

  /// Nessuna etichetta.
  none,
}

/// Impostazioni scelte dal giocatore nel menu, prima di iniziare.
class GameSettings {
  /// Etichetta da mostrare (note/nemici/tastiera).
  LabelMode labelMode = LabelMode.solfege;

  /// Se true la tastiera usa i colori-elemento; se false resta bianca/nera
  /// (note e nemici restano comunque colorati).
  bool keyboardColors = true;

  /// Tempo del gioco in BPM (beat al minuto): regola arrivo note e spawn.
  /// 120 BPM = velocità "normale".
  double bpm = 120;

  /// Moltiplicatore di velocità derivato dal BPM (120 BPM = 1.0x).
  double get speed => bpm / 120.0;

  /// Preset di difficoltà (regola danno, ritmo, finestre, vite iniziali...).
  Difficulty difficulty = Difficulty.normale;
}
