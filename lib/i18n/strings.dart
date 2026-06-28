import 'dart:ui' as ui;

/// Lingue supportate dall'interfaccia.
enum Lang { en, it }

/// Localizzazione leggera dell'interfaccia.
///
/// La lingua viene rilevata dal sistema all'avvio ([detect]): italiano se il
/// dispositivo è in italiano, inglese in tutti gli altri casi. Tutte le
/// stringhe visibili passano da qui tramite semplici getter.
class L {
  L._();

  /// Lingua corrente (default: inglese).
  static Lang lang = Lang.en;

  /// Rileva la lingua di sistema. Va chiamata dopo l'init dei binding.
  static void detect() {
    final String code = ui.PlatformDispatcher.instance.locale.languageCode;
    lang = code == 'it' ? Lang.it : Lang.en;
  }

  /// Sceglie tra inglese e italiano in base alla lingua corrente.
  static String _t(String en, String it) => lang == Lang.it ? it : en;

  // --- Menu -----------------------------------------------------------------
  static String get tagline => 'rhythm bullet-heaven';
  static String get play => _t('PLAY', 'GIOCA');
  static String get options => _t('OPTIONS', 'OPZIONI');
  static String get upgrades => _t('UPGRADES', 'POTENZIAMENTI');
  static String get record => _t('Best', 'Record');
  static String get menuHint => _t(
        'Hit the HIGHLIGHTED note by pressing the right key.\n'
            'The note matters, not the octave. On beat = gem; 5 gems = +1 life.',
        'Colpisci la nota EVIDENZIATA premendo il tasto giusto.\n'
            'Conta la nota, non l\'ottava. A tempo = gemma; 5 gemme = +1 vita.',
      );

  // --- Opzioni --------------------------------------------------------------
  static String get optionsTitle => _t('OPTIONS', 'OPZIONI');
  static String get difficulty => _t('Difficulty', 'Difficoltà');
  static String get easy => _t('Easy', 'Facile');
  static String get normal => _t('Normal', 'Normale');
  static String get hard => _t('Hard', 'Difficile');
  static String get diffHintEasy => _t('Basic enemies only', 'Solo nemici base');
  static String get diffHintNormal =>
      _t('+ fast & armored', '+ veloci e corazzati');
  static String get diffHintHard =>
      _t('+ mini-bosses (all)', '+ mini-boss (tutto)');
  static String tempo(int bpm) => _t('Tempo: $bpm BPM', 'Tempo: $bpm BPM');
  static String get labels => _t('Labels', 'Etichette');
  static String get labelsNone => _t('None', 'Nessuna');
  static String get keyboardColors => _t('Keyboard colors', 'Colori tastiera');
  static String get on => 'ON';
  static String get off => 'OFF';
  static String get audio => 'AUDIO';
  static String get sound => _t('Sound', 'Suono');
  static String volume(int pct) => _t('Volume: $pct%', 'Volume: $pct%');
  static String get back => _t('BACK', 'INDIETRO');

  // --- Pausa ----------------------------------------------------------------
  static String get paused => _t('PAUSED', 'PAUSA');
  static String get resume => _t('RESUME', 'RIPRENDI');
  static String get restart => _t('Restart', 'Ricomincia');
  static String get mainMenu => _t('Main menu', 'Menu principale');

  // --- Game over ------------------------------------------------------------
  static String get gameOver => 'GAME OVER';
  static String get score => _t('Score', 'Punteggio');
  static String get accuracy => _t('Accuracy', 'Accuratezza');
  static String get bestCombo => _t('Best combo', 'Combo migliore');
  static String get survived => _t('Survived', 'Sopravvissuto');
  static String get newRecord => _t('NEW RECORD!', 'NUOVO RECORD!');
  static String crystalsEarned(int n) =>
      _t('+$n crystals', '+$n cristalli');
  static String get retry => _t('RETRY', 'RIPROVA');

  // --- Potenziamenti --------------------------------------------------------
  static String get upgradesTitle => _t('UPGRADES', 'POTENZIAMENTI');
  static String crystals(int n) => _t('$n crystals', '$n cristalli');
  static String get max => 'MAX';
  static String get upLifeTitle => _t('Starting life', 'Vita iniziale');
  static String get upLifeDesc => _t('+1 starting life', '+1 vita iniziale');
  static String get upSlowTitle => _t('Slower notes', 'Note più lente');
  static String get upSlowDesc => _t('Notes 8% slower', 'Note +8% più lente');
  static String get upShieldTitle => _t('Shield', 'Scudo');
  static String get upShieldDesc => _t('-15% miss damage', '-15% danno da miss');
  static String get upLuckTitle => _t('Gem luck', 'Fortuna gemme');
  static String get upLuckDesc =>
      _t('Wider gem windows', 'Finestre gemma più larghe');

  // --- HUD ------------------------------------------------------------------
  static String get scoreLabel => _t('SCORE', 'PUNTEGGIO');
  static String get combo => 'COMBO';
  static String get perfect => _t('PERFECT  +GEM', 'PERFECT  +GEMMA');
  static String get good => _t('GOOD  +GEM', 'GOOD  +GEMMA');
  static String get ok => 'OK';
  static String get miss => 'MISS';

  // --- Banner ---------------------------------------------------------------
  static String get lifeGained => _t('+1 LIFE!', '+1 VITA!');
  static String get lifeLost => _t('LIFE LOST', 'VITA PERSA');
}
