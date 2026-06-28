import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../i18n/strings.dart';

/// Schermata di pausa con ripresa e riavvio.
class PauseOverlay extends StatelessWidget {
  final BattleHymnGame game;
  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            L.paused,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: game.togglePause,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2BA8E0),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(L.resume),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: game.startGame,
            child: Text(
              L.restart,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
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
}
