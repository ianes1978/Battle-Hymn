import 'package:battle_hymn/game/config.dart';
import 'package:battle_hymn/game/game_state.dart';
import 'package:battle_hymn/game/note_data.dart';
import 'package:battle_hymn/input/key_mapping.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteData.evaluate', () {
    test('Perfect entro la finestra perfetta', () {
      final note = NoteData(pitch: 0, angle: 0, duration: 3);
      note.elapsed = 3 - GameConfig.perfectWindow / 2; // quasi sulla linea
      expect(note.evaluate(), Judgment.perfect);
    });

    test('Good nella finestra intermedia', () {
      final note = NoteData(pitch: 0, angle: 0, duration: 3);
      note.elapsed = 3 -
          (GameConfig.perfectWindow + GameConfig.goodWindow) / 2;
      expect(note.evaluate(), Judgment.good);
    });

    test('None se ancora troppo lontana', () {
      final note = NoteData(pitch: 0, angle: 0, duration: 3);
      note.elapsed = 0;
      expect(note.evaluate(), Judgment.none);
    });
  });

  group('GameState', () {
    test('un hit aumenta punteggio e combo', () {
      final s = GameState();
      s.registerHit(Judgment.perfect);
      expect(s.score, greaterThan(0));
      expect(s.combo, 1);
    });

    test('un miss toglie HP e azzera la combo', () {
      final s = GameState();
      s.registerHit(Judgment.good);
      s.registerMiss();
      expect(s.combo, 0);
      expect(s.hp, lessThan(GameConfig.maxHp));
    });

    test('HP a 0 provoca game over', () {
      final s = GameState();
      for (int i = 0; i < 100; i++) {
        s.registerMiss();
      }
      expect(s.isGameOver, isTrue);
      expect(s.hp, 0);
    });
  });

  group('KeyMapping', () {
    test('i tasti home mappano i pitch in ordine', () {
      expect(KeyMapping.pitchForKey(LogicalKeyboardKey.keyA), 0);
      expect(KeyMapping.pitchForKey(LogicalKeyboardKey.keyK),
          GameConfig.scaleLength - 1);
    });

    test('un tasto non mappato ritorna null', () {
      expect(KeyMapping.pitchForKey(LogicalKeyboardKey.keyZ), isNull);
    });
  });
}
