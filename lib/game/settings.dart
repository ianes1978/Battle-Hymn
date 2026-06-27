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
}
