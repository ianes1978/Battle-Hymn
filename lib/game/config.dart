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

  /// Nomi delle note di un'ottava cromatica completa (Do → Do²),
  /// 13 semitoni: 8 tasti bianchi + 5 tasti neri (diesis).
  static const List<String> scaleNames = [
    'Do', // 0  (bianco)
    'Do#', // 1  (nero)
    'Re', // 2  (bianco)
    'Re#', // 3  (nero)
    'Mi', // 4  (bianco)
    'Fa', // 5  (bianco)
    'Fa#', // 6  (nero)
    'Sol', // 7  (bianco)
    'Sol#', // 8  (nero)
    'La', // 9  (bianco)
    'La#', // 10 (nero)
    'Si', // 11 (bianco)
    'Do²', // 12 (bianco)
  ];

  /// Numero di note/pitch disponibili.
  static int get scaleLength => scaleNames.length;

  /// Semitoni che corrispondono ai tasti neri (diesis) all'interno di un'ottava.
  static const Set<int> _blackSemitones = {1, 3, 6, 8, 10};

  /// True se il pitch è un tasto nero (diesis).
  static bool isBlackPitch(int pitch) => _blackSemitones.contains(pitch % 12);

  /// Indici (in [scaleNames]) dei tasti bianchi, da sinistra a destra.
  static const List<int> whitePitches = [0, 2, 4, 5, 7, 9, 11, 12];

  /// Definizione dei tasti neri: per ognuno, l'indice del tasto bianco alla sua
  /// sinistra (per posizionarlo sul confine) e il pitch corrispondente.
  static const List<({int leftWhite, int pitch})> blackKeys = [
    (leftWhite: 0, pitch: 1), // Do#
    (leftWhite: 1, pitch: 3), // Re#
    (leftWhite: 3, pitch: 6), // Fa#
    (leftWhite: 4, pitch: 8), // Sol#
    (leftWhite: 5, pitch: 10), // La#
  ];

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
  // Colore per pitch (identifica anche l'"elemento" della magia).
  // Calcolato lungo la ruota dei colori così da avere una tinta distinta per
  // ciascuno dei 13 semitoni.
  // ---------------------------------------------------------------------------

  static Color colorForPitch(int pitch) {
    final double hue = (pitch / scaleLength) * 360.0;
    return HSVColor.fromAHSV(1, hue % 360, 0.6, 1.0).toColor();
  }
}
