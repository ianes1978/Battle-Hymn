import 'package:flutter/services.dart';

import '../game/config.dart';

/// Mappatura tra i tasti della tastiera fisica e i 13 semitoni dell'ottava,
/// disposti come su un pianoforte "da computer":
///
/// - tasti bianchi sulla riga "home":  A S D F G H J K  → Do Re Mi Fa Sol La Si Do²
/// - tasti neri sulla riga superiore:  W E   T Y U       → Do# Re# Fa# Sol# La#
///
/// I tasti neri stanno fisicamente "in mezzo" ai bianchi, proprio come un piano.
class KeyMapping {
  KeyMapping._();

  /// Tasto fisico associato a ciascun pitch (indicizzato 0..scaleLength-1).
  static const List<LogicalKeyboardKey> keys = [
    LogicalKeyboardKey.keyA, // 0  Do
    LogicalKeyboardKey.keyW, // 1  Do#
    LogicalKeyboardKey.keyS, // 2  Re
    LogicalKeyboardKey.keyE, // 3  Re#
    LogicalKeyboardKey.keyD, // 4  Mi
    LogicalKeyboardKey.keyF, // 5  Fa
    LogicalKeyboardKey.keyT, // 6  Fa#
    LogicalKeyboardKey.keyG, // 7  Sol
    LogicalKeyboardKey.keyY, // 8  Sol#
    LogicalKeyboardKey.keyH, // 9  La
    LogicalKeyboardKey.keyU, // 10 La#
    LogicalKeyboardKey.keyJ, // 11 Si
    LogicalKeyboardKey.keyK, // 12 Do²
  ];

  /// Etichette dei tasti fisici (mostrate su tastiera, note e nemici).
  static const List<String> keyLabels = [
    'A', 'W', 'S', 'E', 'D', 'F', 'T', 'G', 'Y', 'H', 'U', 'J', 'K',
  ];

  /// Restituisce il pitch associato a un tasto, oppure null se non mappato.
  static int? pitchForKey(LogicalKeyboardKey key) {
    final int index = keys.indexOf(key);
    return index >= 0 && index < GameConfig.scaleLength ? index : null;
  }
}
