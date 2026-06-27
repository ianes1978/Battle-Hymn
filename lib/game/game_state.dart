import 'config.dart';
import 'note_data.dart';

/// Stato di gioco mutabile: vita, vite extra, gemme, punteggio, combo, timer.
class GameState {
  double hp = GameConfig.maxHp;
  int score = 0;
  int combo = 0;
  int bestCombo = 0;

  /// Gemme accumulate verso la prossima vita (0..gemsPerLife-1).
  int gems = 0;

  /// Vite extra: a 0 HP se ne consuma una per continuare.
  int lives = 0;

  /// Gemme totali raccolte nella partita (statistica).
  int totalGems = 0;

  double survivalTime = 0;

  bool isGameOver = false;
  bool isPaused = false;

  Judgment lastJudgment = Judgment.none;
  double lastJudgmentTimer = 0;

  /// Flag per il feedback "vita guadagnata" / "vita persa".
  String? banner;
  double bannerTimer = 0;

  void reset() {
    hp = GameConfig.maxHp;
    score = 0;
    combo = 0;
    bestCombo = 0;
    gems = 0;
    lives = 0;
    totalGems = 0;
    survivalTime = 0;
    isGameOver = false;
    isPaused = false;
    lastJudgment = Judgment.none;
    lastJudgmentTimer = 0;
    banner = null;
    bannerTimer = 0;
  }

  /// Registra un colpo riuscito. [gem] = true se a tempo (Perfect/Good).
  void registerHit(Judgment judgment, bool gem) {
    final int base = switch (judgment) {
      Judgment.perfect => GameConfig.scorePerfect,
      Judgment.good => GameConfig.scoreGood,
      _ => GameConfig.scoreEarly,
    };
    combo += 1;
    if (combo > bestCombo) bestCombo = combo;
    final double multiplier = (1 + (combo ~/ 10) * 0.1).clamp(1.0, 3.0);
    score += (base * multiplier).round();

    if (gem) {
      gems += 1;
      totalGems += 1;
      if (gems >= GameConfig.gemsPerLife) {
        gems -= GameConfig.gemsPerLife;
        if (lives < GameConfig.maxLives) {
          lives += 1;
          _showBanner('+1 VITA!');
        }
      }
    }
    _flashJudgment(judgment);
  }

  /// Registra un miss: danno al mago, combo azzerata. Se l'HP arriva a 0 e ci
  /// sono vite, ne consuma una e continua; altrimenti è game over.
  void registerMiss() {
    hp = (hp - GameConfig.missDamage).clamp(0, GameConfig.maxHp);
    combo = 0;
    _flashJudgment(Judgment.miss);
    if (hp <= 0) {
      if (lives > 0) {
        lives -= 1;
        hp = GameConfig.maxHp;
        _showBanner('VITA PERSA');
      } else {
        isGameOver = true;
      }
    }
  }

  void _flashJudgment(Judgment judgment) {
    lastJudgment = judgment;
    lastJudgmentTimer = 0.8;
  }

  void _showBanner(String text) {
    banner = text;
    bannerTimer = 1.6;
  }

  void update(double dt) {
    if (isGameOver || isPaused) return;
    survivalTime += dt;
    if (lastJudgmentTimer > 0) {
      lastJudgmentTimer = (lastJudgmentTimer - dt).clamp(0, double.infinity);
    }
    if (bannerTimer > 0) {
      bannerTimer = (bannerTimer - dt).clamp(0, double.infinity);
      if (bannerTimer == 0) banner = null;
    }
  }

  double get difficulty =>
      (survivalTime / GameConfig.difficultyRampSeconds).clamp(0.0, 1.0);
}
