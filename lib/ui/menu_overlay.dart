import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';

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
            const Text('rhythm bullet-heaven',
                style: TextStyle(fontSize: 16, color: Color(0xFF7FE3FF))),
            const SizedBox(height: 18),
            Text(
              'Colpisci la nota EVIDENZIATA premendo il tasto giusto.\n'
              'Conta la nota, non l\'ottava. A tempo = gemma; 5 gemme = +1 vita.',
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
              child: const Text('GIOCA'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: game.openOptions,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7FE3FF),
                side: const BorderSide(color: Color(0xFF4FC3F7)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('OPZIONI'),
            ),
          ],
        ),
      ),
    );
  }
}
