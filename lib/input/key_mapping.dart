import 'package:flutter/services.dart';

/// Mappatura tra i tasti della tastiera fisica e le CLASSI di nota (0..11).
///
/// Disposizione "piano da computer" su un'ottava:
/// - bianchi (riga home):   A S D F G H J K  → Do Re Mi Fa Sol La Si Do
/// - neri (riga superiore):  W E   T Y U      → Do# Re# Fa# Sol# La#
///
/// Conta la classe di nota, non l'ottava: premere `La` colpisce un La sia alto
/// che basso.
class KeyMapping {
  KeyMapping._();

  /// Tasto fisico → classe di nota (0..11).
  /// (final, non const: LogicalKeyboardKey non ha "primitive equality".)
  static final Map<LogicalKeyboardKey, int> _keyToClass = {
    LogicalKeyboardKey.keyA: 0, // Do
    LogicalKeyboardKey.keyW: 1, // Do#
    LogicalKeyboardKey.keyS: 2, // Re
    LogicalKeyboardKey.keyE: 3, // Re#
    LogicalKeyboardKey.keyD: 4, // Mi
    LogicalKeyboardKey.keyF: 5, // Fa
    LogicalKeyboardKey.keyT: 6, // Fa#
    LogicalKeyboardKey.keyG: 7, // Sol
    LogicalKeyboardKey.keyY: 8, // Sol#
    LogicalKeyboardKey.keyH: 9, // La
    LogicalKeyboardKey.keyU: 10, // La#
    LogicalKeyboardKey.keyJ: 11, // Si
    LogicalKeyboardKey.keyK: 0, // Do (ottava sopra → stessa classe)
  };

  /// Restituisce la classe di nota associata a un tasto, o null se non mappato.
  static int? classForKey(LogicalKeyboardKey key) => _keyToClass[key];
}
