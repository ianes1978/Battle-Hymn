import 'dart:math';

import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import 'config.dart';
import 'note_data.dart';
import 'tuning.dart';

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

  // Conteggi per accuratezza e voto finale.
  int perfectCount = 0;
  int goodCount = 0;
  int earlyCount = 0;
  int missCount = 0;

  double survivalTime = 0;

  bool isGameOver = false;
  bool isPaused = false;

  /// Modalità pratica: gli errori non portano mai al game over.
  bool practice = false;

  Judgment lastJudgment = Judgment.none;
  double lastJudgmentTimer = 0;

  /// Flag per il feedback "vita guadagnata" / "vita persa".
  String? banner;
  double bannerTimer = 0;

  // --- Feedback "juice": scossa schermo e lampo a tutto schermo ---
  final Random _rng = Random();
  static const double _shakeDur = 0.28;
  double _shakeMag = 0;
  double _shakeTime = 0;
  double _flashTime = 0;
  double _flashDur = 0;
  Color flashColor = const Color(0x00000000);

  void _addShake(double mag) {
    if (mag > _shakeMag) _shakeMag = mag;
    _shakeTime = _shakeDur;
  }

  void _addFlash(Color color, double dur) {
    flashColor = color;
    _flashTime = dur;
    _flashDur = dur;
  }

  /// Offset di scossa da applicare al rendering (decade nel tempo).
  Offset shakeOffset() {
    if (_shakeTime <= 0) return Offset.zero;
    final double k = _shakeTime / _shakeDur;
    final double m = _shakeMag * k;
    return Offset(
      (_rng.nextDouble() * 2 - 1) * m,
      (_rng.nextDouble() * 2 - 1) * m,
    );
  }

  /// Opacità corrente del lampo a schermo (0..1).
  double get flashAlpha =>
      _flashDur <= 0 ? 0 : (_flashTime / _flashDur).clamp(0.0, 1.0);

  void reset() {
    hp = GameConfig.maxHp;
    score = 0;
    combo = 0;
    bestCombo = 0;
    gems = 0;
    lives = 0;
    totalGems = 0;
    perfectCount = 0;
    goodCount = 0;
    earlyCount = 0;
    missCount = 0;
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
          _showBanner(L.lifeGained);
          _addFlash(const Color(0xFFFFD54F), 0.5);
          _addShake(6);
        }
      }
    }

    // Conteggi per accuratezza.
    switch (judgment) {
      case Judgment.perfect:
        perfectCount++;
      case Judgment.good:
        goodCount++;
      default:
        earlyCount++;
    }

    // Feedback in base al giudizio.
    if (judgment == Judgment.perfect) {
      _addFlash(const Color(0xFFFFD54F), 0.18);
      _addShake(3.5);
    } else if (judgment == Judgment.good) {
      _addShake(2);
    }
    _flashJudgment(judgment);
  }

  /// Registra un miss: danno al mago, combo azzerata. Se l'HP arriva a 0 e ci
  /// sono vite, ne consuma una e continua; altrimenti è game over.
  void registerMiss() {
    hp = (hp - Tuning.missDamage).clamp(0, GameConfig.maxHp);
    combo = 0;
    missCount++;
    _addFlash(const Color(0xFFFF5252), 0.28);
    _addShake(9);
    _flashJudgment(Judgment.miss);
    if (hp <= 0) {
      if (practice) {
        // In pratica non si muore: l'HP si ricarica e si continua.
        hp = GameConfig.maxHp;
      } else if (lives > 0) {
        lives -= 1;
        hp = GameConfig.maxHp;
        _showBanner(L.lifeLost);
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
    if (_shakeTime > 0) {
      _shakeTime -= dt;
      if (_shakeTime <= 0) _shakeMag = 0;
    }
    if (_flashTime > 0) _flashTime -= dt;
  }

  double get difficulty =>
      (survivalTime / Tuning.rampSeconds).clamp(0.0, 1.0);

  /// Numero totale di "giudizi" (colpi + miss).
  int get _judged => perfectCount + goodCount + earlyCount + missCount;

  /// Accuratezza 0..1 (peso ai colpi a tempo: Perfect/Good).
  double get accuracy =>
      _judged == 0 ? 1.0 : (perfectCount + goodCount) / _judged;

  /// Voto finale in base all'accuratezza.
  String get grade {
    final double a = accuracy;
    if (a >= 0.95) return 'S';
    if (a >= 0.85) return 'A';
    if (a >= 0.70) return 'B';
    if (a >= 0.50) return 'C';
    return 'D';
  }
}
