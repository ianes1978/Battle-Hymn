import 'package:shared_preferences/shared_preferences.dart';

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
/// Vengono salvate localmente e ricaricate all'avvio.
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

  /// Audio attivo/disattivato.
  bool audioEnabled = true;

  /// Volume generale (0..1).
  double volume = 0.8;

  // --- Accessibilità ---

  /// Modalità pratica: non si muore mai (per imparare con calma).
  bool practiceMode = false;

  /// Riduce gli effetti di movimento (niente scossa schermo, meno particelle).
  bool reduceMotion = false;

  /// Aiuto daltonici: mostra sempre il nome della nota sul bersaglio corrente,
  /// così non serve distinguere i colori.
  bool colorblind = false;

  /// Carica le impostazioni salvate (se presenti).
  void load(SharedPreferences p) {
    labelMode = LabelMode.values[(p.getInt('set_labelMode') ?? labelMode.index)
        .clamp(0, LabelMode.values.length - 1)];
    keyboardColors = p.getBool('set_keyboardColors') ?? keyboardColors;
    bpm = (p.getDouble('set_bpm') ?? bpm).clamp(30, 200);
    difficulty = Difficulty.values[
        (p.getInt('set_difficulty') ?? difficulty.index)
            .clamp(0, Difficulty.values.length - 1)];
    audioEnabled = p.getBool('set_audioEnabled') ?? audioEnabled;
    volume = (p.getDouble('set_volume') ?? volume).clamp(0, 1);
    practiceMode = p.getBool('set_practiceMode') ?? practiceMode;
    reduceMotion = p.getBool('set_reduceMotion') ?? reduceMotion;
    colorblind = p.getBool('set_colorblind') ?? colorblind;
  }

  /// Salva le impostazioni correnti.
  void save(SharedPreferences p) {
    p.setInt('set_labelMode', labelMode.index);
    p.setBool('set_keyboardColors', keyboardColors);
    p.setDouble('set_bpm', bpm);
    p.setInt('set_difficulty', difficulty.index);
    p.setBool('set_audioEnabled', audioEnabled);
    p.setDouble('set_volume', volume);
    p.setBool('set_practiceMode', practiceMode);
    p.setBool('set_reduceMotion', reduceMotion);
    p.setBool('set_colorblind', colorblind);
  }
}
