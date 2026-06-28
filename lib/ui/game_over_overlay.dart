import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../i18n/strings.dart';

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
          Text(
            L.gameOver,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          _gradeBadge(state.grade),
          const SizedBox(height: 12),
          _stat(L.score, '${state.score}'),
          _stat(L.accuracy, '${(state.accuracy * 100).round()}%'),
          _stat(L.bestCombo, '${state.bestCombo}x'),
          _stat(L.survived, time),
          const SizedBox(height: 8),
          if (game.newRecord)
            Text(L.newRecord,
                style: const TextStyle(
                    color: Color(0xFF7FE3FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold))
          else
            _stat(L.record, '${game.highScore}'),
          const SizedBox(height: 4),
          Text('💎 ${L.crystalsEarned(game.lastCrystalsEarned)}',
              style: const TextStyle(
                  color: Color(0xFF7FE3FF),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: game.startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2BA8E0),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            child: Text(L.retry),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: game.goToMenu,
            child: Text(
              L.mainMenu,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeBadge(String grade) {
    final Color c = switch (grade) {
      'S' => const Color(0xFFFFD54F),
      'A' => const Color(0xFF7FE3FF),
      'B' => const Color(0xFF66BB6A),
      'C' => const Color(0xFFB0BEC5),
      _ => const Color(0xFFEF9A9A),
    };
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c, width: 4),
        color: c.withValues(alpha: 0.15),
      ),
      child: Text(
        grade,
        style: TextStyle(
            color: c, fontSize: 52, fontWeight: FontWeight.bold),
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
