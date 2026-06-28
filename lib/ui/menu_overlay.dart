import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../i18n/strings.dart';

/// Schermata iniziale: titolo, regole, GIOCA e accesso alle Opzioni.
class MenuOverlay extends StatelessWidget {
  final BattleHymnGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.62),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                'assets/images/title.png',
                width: 340,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Text(L.tagline,
                style: const TextStyle(fontSize: 16, color: Color(0xFF7FE3FF))),
            if (game.highScore > 0) ...[
              const SizedBox(height: 6),
              Text('${L.record}: ${game.highScore}',
                  style: const TextStyle(fontSize: 15, color: Colors.white70)),
            ],
            const SizedBox(height: 18),
            Text(
              L.menuHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: game.startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BA8E0), // azzurro ghiaccio
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text(L.play),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: game.openOptions,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7FE3FF),
                    side: const BorderSide(color: Color(0xFF4FC3F7)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  child: Text(L.options),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: game.openUpgrades,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7FE3FF),
                    side: const BorderSide(color: Color(0xFF4FC3F7)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  child: Text(L.upgrades),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
