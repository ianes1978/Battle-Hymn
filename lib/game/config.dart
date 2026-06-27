import 'package:flutter/material.dart';

import 'settings.dart';

/// Configurazione centrale del gioco: scala musicale, tastiera, estensione
/// dello spartito, finestre di tempismo, bilanciamento e colori.
///
/// Concetto chiave: l'INPUT conta per *classe di nota* (Do, Re, Mi, ...),
/// indipendentemente dall'ottava. Sullo spartito, invece, le note occupano
/// posizioni verticali diverse su 2 ottave (Do basso → La alto).
class GameConfig {
  GameConfig._();

  // ---------------------------------------------------------------------------
  // Classi di nota (0..11) — ciò che conta per l'input
  // ---------------------------------------------------------------------------

  static const List<String> solfegeNames = [
    'Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si',
  ];

  static const List<String> letterNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  /// Numero di classi di nota disponibili (ottava cromatica).
  static int get classCount => 12;

  /// Classi corrispondenti ai tasti neri (diesis).
  static const Set<int> _blackClasses = {1, 3, 6, 8, 10};

  static bool isBlackClass(int noteClass) =>
      _blackClasses.contains(noteClass % 12);

  /// Etichetta da disegnare per una classe, secondo la modalità scelta.
  static String labelForClass(int noteClass, LabelMode mode) => switch (mode) {
        LabelMode.solfege => solfegeNames[noteClass % 12],
        LabelMode.letters => letterNames[noteClass % 12],
        LabelMode.none => '',
      };

  // ---------------------------------------------------------------------------
  // Tastiera: 13 tasti = un'ottava + Do (8 bianchi + 5 neri)
  // Ogni "slot" ha una classe di nota; gli slot bianchi vanno da sinistra a
  // destra, i neri stanno sul confine tra due bianchi.
  // ---------------------------------------------------------------------------

  /// Classi dei tasti bianchi: Do Re Mi Fa Sol La Si Do(²).
  static const List<int> whiteSlotClasses = [0, 2, 4, 5, 7, 9, 11, 0];

  /// Tasti neri: indice del bianco a sinistra + classe della nota.
  static const List<({int leftWhite, int noteClass})> blackSlots = [
    (leftWhite: 0, noteClass: 1), // Do#
    (leftWhite: 1, noteClass: 3), // Re#
    (leftWhite: 3, noteClass: 6), // Fa#
    (leftWhite: 4, noteClass: 8), // Sol#
    (leftWhite: 5, noteClass: 10), // La#
  ];

  // ---------------------------------------------------------------------------
  // Estensione sullo spartito: 2 ottave, dal Do basso al La alto.
  // staffIndex assoluto = ottava * 12 + classe.  0 = Do basso ... 21 = La alto.
  // ---------------------------------------------------------------------------

  static const int staffMin = 0;
  static const int staffMax = 21;
  static int get staffSpan => staffMax - staffMin + 1; // 22 posizioni

  // ---------------------------------------------------------------------------
  // Tempismo (per il bonus gemma). Il colpo riesce SEMPRE; il tempismo decide
  // solo il giudizio e se assegnare la gemma.
  // ---------------------------------------------------------------------------

  static const double perfectWindow = 0.12;
  static const double goodWindow = 0.28;

  // ---------------------------------------------------------------------------
  // Punteggio e gemme/vite
  // ---------------------------------------------------------------------------

  static const int scorePerfect = 100;
  static const int scoreGood = 60;
  static const int scoreEarly = 20;

  /// Gemme necessarie per guadagnare una vita.
  static const int gemsPerLife = 5;

  /// Tetto massimo di vite accumulabili.
  static const int maxLives = 9;

  // ---------------------------------------------------------------------------
  // Vita del mago
  // ---------------------------------------------------------------------------

  static const double maxHp = 100;
  static const double missDamage = 12;

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  /// Le 5 linee "principali" del pentagramma (un po' più in basso per fare
  /// spazio alla HUD e alle note acute fuori dal rigo).
  static const double staffTop = 96;
  static const double staffHeight = 108;

  static const double judgmentLineX = 150;
  static const double keyboardHeight = 104;
  static const double wizardBottomOffset = 158;

  // ---------------------------------------------------------------------------
  // Difficoltà / spawn
  // ---------------------------------------------------------------------------

  static const double initialSpawnInterval = 1.9;
  static const double minSpawnInterval = 0.6;
  static const double initialNoteDuration = 3.8;
  static const double minNoteDuration = 2.1;
  static const double difficultyRampSeconds = 120;

  // ---------------------------------------------------------------------------
  // Colore per classe di nota (identifica anche l'"elemento").
  // ---------------------------------------------------------------------------

  static Color colorForClass(int noteClass) {
    final double hue = (noteClass % 12) / 12 * 360.0;
    return HSVColor.fromAHSV(1, hue % 360, 0.62, 1.0).toColor();
  }
}
