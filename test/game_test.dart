import 'package:battle_hymn/game/config.dart';
import 'package:battle_hymn/game/game_state.dart';
import 'package:battle_hymn/game/note_data.dart';
import 'package:battle_hymn/input/key_mapping.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

NoteData _note({int noteClass = 0, double duration = 3}) =>
    NoteData(noteClass: noteClass, staffIndex: noteClass, angle: 0, duration: duration);

void main() {
  group('NoteData.evaluate', () {
    test('Perfect entro la finestra perfetta', () {
      final note = _note()..elapsed = 3 - GameConfig.perfectWindow / 2;
      expect(note.evaluate(), Judgment.perfect);
    });

    test('Good nella finestra intermedia', () {
      final note = _note()
        ..elapsed = 3 - (GameConfig.perfectWindow + GameConfig.goodWindow) / 2;
      expect(note.evaluate(), Judgment.good);
    });

    test('Early se ancora lontana (il colpo riesce comunque)', () {
      final note = _note()..elapsed = 0;
      expect(note.evaluate(), Judgment.early);
    });
  });

  group('GameState - colpi e gemme', () {
    test('un hit a tempo aumenta punteggio, combo e gemme', () {
      final s = GameState();
      s.registerHit(Judgment.perfect, true);
      expect(s.score, greaterThan(0));
      expect(s.combo, 1);
      expect(s.gems, 1);
    });

    test('un hit early non assegna gemme', () {
      final s = GameState();
      s.registerHit(Judgment.early, false);
      expect(s.gems, 0);
      expect(s.combo, 1);
    });

    test('5 gemme danno una vita', () {
      final s = GameState();
      for (int i = 0; i < GameConfig.gemsPerLife; i++) {
        s.registerHit(Judgment.perfect, true);
      }
      expect(s.lives, 1);
      expect(s.gems, 0);
    });
  });

  group('GameState - miss e vite', () {
    test('un miss toglie HP e azzera la combo', () {
      final s = GameState();
      s.registerHit(Judgment.good, true);
      s.registerMiss();
      expect(s.combo, 0);
      expect(s.hp, lessThan(GameConfig.maxHp));
    });

    test('con una vita, a 0 HP si continua', () {
      final s = GameState()..lives = 1;
      for (int i = 0; i < 100; i++) {
        s.registerMiss();
      }
      // La vita è stata consumata ma non è game over.
      expect(s.isGameOver, isFalse);
      expect(s.lives, lessThan(1));
    });

    test('senza vite, HP a 0 è game over', () {
      final s = GameState();
      for (int i = 0; i < 100; i++) {
        s.registerMiss();
      }
      expect(s.isGameOver, isTrue);
    });
  });

  group('KeyMapping (per classe di nota)', () {
    test('i tasti mappano le classi giuste', () {
      expect(KeyMapping.classForKey(LogicalKeyboardKey.keyA), 0); // Do
      expect(KeyMapping.classForKey(LogicalKeyboardKey.keyJ), 11); // Si
      expect(KeyMapping.classForKey(LogicalKeyboardKey.keyK), 0); // Do²→Do
    });

    test('un tasto non mappato ritorna null', () {
      expect(KeyMapping.classForKey(LogicalKeyboardKey.keyZ), isNull);
    });
  });
}
