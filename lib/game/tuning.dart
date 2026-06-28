import 'config.dart';
import 'settings.dart';

/// Parametri di bilanciamento applicati in base al preset di difficoltà.
///
/// Sono valori mutabili impostati all'avvio della partita da [apply]; così la
/// logica (giudizi, danno, spawn) legge un'unica fonte ed è facile calibrare.
class Tuning {
  Tuning._();

  /// Finestre di tempismo per il bonus gemma (secondi prima della linea).
  static double perfectWindow = GameConfig.perfectWindow;
  static double goodWindow = GameConfig.goodWindow;

  /// Danno per nota mancata.
  static double missDamage = GameConfig.missDamage;

  /// Moltiplicatore intervallo di spawn (>1 = meno nemici).
  static double spawnScale = 1;

  /// Moltiplicatore durata note (>1 = note più lente / più facili).
  static double durationScale = 1;

  /// Secondi per raggiungere la difficoltà massima (ramp).
  static double rampSeconds = GameConfig.difficultyRampSeconds;

  /// Vite extra iniziali.
  static int startLives = 0;

  /// Numero massimo di nemici contemporaneamente attivi.
  static int maxConcurrent = 8;

  /// Quali "dinamiche" di nemici sono attive (dipende dalla difficoltà).
  static bool allowFast = true;
  static bool allowArmored = true;
  static bool allowBoss = true;

  /// Imposta i parametri secondo il preset scelto.
  static void apply(Difficulty d) {
    switch (d) {
      case Difficulty.facile:
        perfectWindow = GameConfig.perfectWindow * 1.5;
        goodWindow = GameConfig.goodWindow * 1.6;
        missDamage = GameConfig.missDamage * 0.6;
        spawnScale = 1.3;
        durationScale = 1.25;
        rampSeconds = GameConfig.difficultyRampSeconds * 1.6;
        startLives = 1;
        maxConcurrent = 5;
        allowFast = false;
        allowArmored = false;
        allowBoss = false;
        break;
      case Difficulty.normale:
        perfectWindow = GameConfig.perfectWindow;
        goodWindow = GameConfig.goodWindow;
        missDamage = GameConfig.missDamage;
        spawnScale = 1;
        durationScale = 1;
        rampSeconds = GameConfig.difficultyRampSeconds;
        startLives = 0;
        maxConcurrent = 8;
        allowFast = true;
        allowArmored = true;
        allowBoss = false;
        break;
      case Difficulty.difficile:
        perfectWindow = GameConfig.perfectWindow * 0.8;
        goodWindow = GameConfig.goodWindow * 0.8;
        missDamage = GameConfig.missDamage * 1.3;
        spawnScale = 0.8;
        durationScale = 0.85;
        rampSeconds = GameConfig.difficultyRampSeconds * 0.7;
        startLives = 0;
        maxConcurrent = 12;
        allowFast = true;
        allowArmored = true;
        allowBoss = true;
        break;
    }
  }
}
