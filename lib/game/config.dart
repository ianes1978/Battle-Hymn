import 'package:flutter/material.dart';

/// Configurazione centrale del gioco: costanti di bilanciamento, layout,
/// scala musicale, finestre di tempismo e palette colori.
///
/// Tenere tutti i "numeri magici" qui rende facile il tuning del gameplay.
class GameConfig {
  GameConfig._();

  // ---------------------------------------------------------------------------
  // Scala musicale
  // ---------------------------------------------------------------------------

  /// Nomi dei gradi della scala mostrati sui tasti (un'ottava diatonica).
  static const List<String> scaleNames = [
    'Do',
    'Re',
    'Mi',
    'Fa',
    'Sol',
    'La',
    'Si',
    'Do²',
  ];

  /// Numero di note/pitch disponibili.
  static int get scaleLength => scaleNames.length;

  // ---------------------------------------------------------------------------
  // Tempismo (giudizi)
  //
  // Le finestre sono espresse in SECONDI rimanenti prima che la nota
  // raggiunga la linea di esecuzione, così il feel è coerente anche quando la
  // velocità delle note cambia con la difficoltà.
  // ---------------------------------------------------------------------------

  /// Entro questa finestra il colpo è "Perfect".
  static const double perfectWindow = 0.11;

  /// Entro questa finestra (ma oltre perfectWindow) il colpo è "Good".
  static const double goodWindow = 0.26;

  // ---------------------------------------------------------------------------
  // Punteggio
  // ---------------------------------------------------------------------------

  static const int scorePerfect = 100;
  static const int scoreGood = 50;

  // ---------------------------------------------------------------------------
  // Vita del mago
  // ---------------------------------------------------------------------------

  static const double maxHp = 100;

  /// Danno subìto quando una nota raggiunge la linea senza essere suonata.
  static const double missDamage = 12;

  // ---------------------------------------------------------------------------
  // Layout (frazioni dell'altezza/larghezza dello schermo dove sensato)
  // ---------------------------------------------------------------------------

  /// Margine superiore del pentagramma.
  static const double staffTop = 64;

  /// Altezza della zona del pentagramma (le 5 linee).
  static const double staffHeight = 120;

  /// Posizione X della linea di esecuzione (dove si "suona" la nota).
  static const double judgmentLineX = 150;

  /// Altezza della tastiera on-screen in fondo allo schermo.
  static const double keyboardHeight = 96;

  /// Distanza verticale del mago dal bordo inferiore (sopra la tastiera).
  static const double wizardBottomOffset = 150;

  // ---------------------------------------------------------------------------
  // Difficoltà / spawn
  // ---------------------------------------------------------------------------

  /// Intervallo iniziale tra spawn (secondi).
  static const double initialSpawnInterval = 1.9;

  /// Intervallo minimo raggiungibile a difficoltà alta.
  static const double minSpawnInterval = 0.55;

  /// Tempo iniziale impiegato da una nota per raggiungere la linea (secondi).
  static const double initialNoteDuration = 3.6;

  /// Tempo minimo (note più veloci = più difficili).
  static const double minNoteDuration = 1.9;

  /// Dopo quanti secondi di sopravvivenza si raggiunge la difficoltà massima.
  static const double difficultyRampSeconds = 120;

  // ---------------------------------------------------------------------------
  // Palette colori per pitch (uno per grado della scala)
  // Il colore identifica anche l'"elemento" della magia.
  // ---------------------------------------------------------------------------

  static const List<Color> pitchColors = [
    Color(0xFFFF5252), // Do  - rosso
    Color(0xFFFF9800), // Re  - arancio
    Color(0xFFFFEB3B), // Mi  - giallo
    Color(0xFF66BB6A), // Fa  - verde
    Color(0xFF26C6DA), // Sol - ciano
    Color(0xFF42A5F5), // La  - blu
    Color(0xFFAB47BC), // Si  - viola
    Color(0xFFEC407A), // Do² - rosa
  ];

  static Color colorForPitch(int pitch) =>
      pitchColors[pitch % pitchColors.length];
}
