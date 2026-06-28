import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/strings.dart';
import 'tuning.dart';

/// Progressione roguelite persistente: cristalli guadagnati a fine partita e
/// potenziamenti permanenti acquistabili che si applicano alle partite future.
class Upgrades {
  /// Valuta meta (persistente).
  int crystals = 0;

  /// Livelli dei potenziamenti (0..maxLevel).
  int life = 0;
  int slow = 0;
  int shield = 0;
  int luck = 0;

  static const int maxLevel = 3;

  /// Chiavi disponibili e relativi titoli/descrizioni.
  static const List<String> keys = ['life', 'slow', 'shield', 'luck'];

  static String title(String k) => switch (k) {
        'life' => L.upLifeTitle,
        'slow' => L.upSlowTitle,
        'shield' => L.upShieldTitle,
        'luck' => L.upLuckTitle,
        _ => k,
      };

  static String describe(String k) => switch (k) {
        'life' => L.upLifeDesc,
        'slow' => L.upSlowDesc,
        'shield' => L.upShieldDesc,
        'luck' => L.upLuckDesc,
        _ => '',
      };

  int levelOf(String k) => switch (k) {
        'life' => life,
        'slow' => slow,
        'shield' => shield,
        'luck' => luck,
        _ => 0,
      };

  void _setLevel(String k, int v) {
    if (k == 'life') life = v;
    if (k == 'slow') slow = v;
    if (k == 'shield') shield = v;
    if (k == 'luck') luck = v;
  }

  /// Costo del prossimo livello (50, 100, 150...).
  int costOf(String k) => 50 * (levelOf(k) + 1);

  bool isMaxed(String k) => levelOf(k) >= maxLevel;
  bool canBuy(String k) => !isMaxed(k) && crystals >= costOf(k);

  void buy(String k) {
    if (!canBuy(k)) return;
    crystals -= costOf(k);
    _setLevel(k, levelOf(k) + 1);
  }

  /// Cristalli guadagnati per un punteggio.
  static int crystalsFor(int score) => score ~/ 80;

  /// Applica i potenziamenti ai parametri di gioco (dopo Tuning.apply).
  void applyToTuning() {
    Tuning.startLives += life;
    Tuning.durationScale *= 1 + 0.08 * slow;
    Tuning.missDamage *= 1 - 0.15 * shield;
    Tuning.perfectWindow *= 1 + 0.12 * luck;
    Tuning.goodWindow *= 1 + 0.12 * luck;
  }

  void load(SharedPreferences p) {
    crystals = p.getInt('crystals') ?? 0;
    life = p.getInt('up_life') ?? 0;
    slow = p.getInt('up_slow') ?? 0;
    shield = p.getInt('up_shield') ?? 0;
    luck = p.getInt('up_luck') ?? 0;
  }

  void save(SharedPreferences p) {
    p.setInt('crystals', crystals);
    p.setInt('up_life', life);
    p.setInt('up_slow', slow);
    p.setInt('up_shield', shield);
    p.setInt('up_luck', luck);
  }
}
