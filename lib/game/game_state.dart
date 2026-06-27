import 'config.dart';
import 'note_data.dart';

/// Stato di gioco mutabile: vita, punteggio, combo, timer e flag di flusso.
///
/// Separato dalla logica di rendering: la HUD lo legge per disegnarsi.
class GameState {
  double hp = GameConfig.maxHp;
  int score = 0;
  int combo = 0;
  int bestCombo = 0;

  /// Tempo di sopravvivenza in secondi (anche guida la difficoltà).
  double survivalTime = 0;

  bool isGameOver = false;
  bool isPaused = false;

  // Feedback dell'ultimo giudizio (mostrato a schermo per breve tempo).
  Judgment lastJudgment = Judgment.none;
  double lastJudgmentTimer = 0;

  /// Riporta lo stato alle condizioni iniziali per una nuova partita.
  void reset() {
    hp = GameConfig.maxHp;
    score = 0;
    combo = 0;
    bestCombo = 0;
    survivalTime = 0;
    isGameOver = false;
    isPaused = false;
    lastJudgment = Judgment.none;
    lastJudgmentTimer = 0;
  }

  /// Applica un giudizio positivo (Perfect/Good): aggiorna punteggio e combo.
  void registerHit(Judgment judgment) {
    final int base = judgment == Judgment.perfect
        ? GameConfig.scorePerfect
        : GameConfig.scoreGood;
    combo += 1;
    if (combo > bestCombo) bestCombo = combo;
    // Moltiplicatore di combo: +10% ogni 10 colpi consecutivi (cap a 3x).
    final double multiplier = (1 + (combo ~/ 10) * 0.1).clamp(1.0, 3.0);
    score += (base * multiplier).round();
    _flashJudgment(judgment);
  }

  /// Applica un miss: danno al mago e azzeramento combo.
  void registerMiss() {
    hp = (hp - GameConfig.missDamage).clamp(0, GameConfig.maxHp);
    combo = 0;
    _flashJudgment(Judgment.miss);
    if (hp <= 0) isGameOver = true;
  }

  void _flashJudgment(Judgment judgment) {
    lastJudgment = judgment;
    lastJudgmentTimer = 0.8; // secondi di visibilità del popup
  }

  /// Avanza i timer di stato (chiamato dal game loop con dt corretto).
  void update(double dt) {
    if (isGameOver || isPaused) return;
    survivalTime += dt;
    if (lastJudgmentTimer > 0) {
      lastJudgmentTimer = (lastJudgmentTimer - dt).clamp(0, double.infinity);
    }
  }

  /// Difficoltà normalizzata 0..1 in base al tempo di sopravvivenza.
  double get difficulty =>
      (survivalTime / GameConfig.difficultyRampSeconds).clamp(0.0, 1.0);
}
