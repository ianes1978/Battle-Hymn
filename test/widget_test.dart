import 'package:battle_hymn/game/battle_hymn_game.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke test: il gioco si istanzia correttamente.
///
/// Questo file sostituisce il template generato da `flutter create`
/// (che referenzia una classe `MyApp` inesistente in questo progetto).
void main() {
  test('BattleHymnGame si costruisce senza note attive', () {
    final BattleHymnGame game = BattleHymnGame();
    expect(game.notes, isEmpty);
    expect(game.state.hp, greaterThan(0));
    expect(game.state.isGameOver, isFalse);
  });
}
