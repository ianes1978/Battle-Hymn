import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';

/// Schermata di game over: mostra punteggio, combo migliore e tempo, con
/// pulsante per riprovare.
class GameOverOverlay extends StatelessWidget {
  final BattleHymnGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    final int total = state.survivalTime.floor();
    final String time =
        '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';

    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'GAME OVER',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),
          _stat('Punteggio', '${state.score}'),
          _stat('Combo migliore', '${state.bestCombo}x'),
          _stat('Sopravvissuto', time),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: game.startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            child: const Text('RIPROVA'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: game.goToMenu,
            child: const Text(
              'Menu principale',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
