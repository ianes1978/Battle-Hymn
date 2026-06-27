import 'package:flutter/services.dart';

import '../game/config.dart';

/// Mappatura tra i tasti della tastiera fisica e i gradi della scala.
///
/// Riga "home" della tastiera: A S D F G H J K = Do Re Mi Fa Sol La Si Do².
class KeyMapping {
  KeyMapping._();

  /// Ordine dei tasti fisici, indicizzato per pitch (0..scaleLength-1).
  static const List<LogicalKeyboardKey> keys = [
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyG,
    LogicalKeyboardKey.keyH,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
  ];

  /// Etichette dei tasti fisici (per mostrarle sulla tastiera on-screen).
  static const List<String> keyLabels = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K'];

  /// Restituisce il pitch associato a un tasto, oppure null se non mappato.
  static int? pitchForKey(LogicalKeyboardKey key) {
    final int index = keys.indexOf(key);
    return index >= 0 && index < GameConfig.scaleLength ? index : null;
  }
}
