import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../i18n/strings.dart';

/// Tutorial "Come si gioca": spiega la meccanica. Mostrato automaticamente al
/// primo avvio e richiamabile dal menu.
class HowToOverlay extends StatelessWidget {
  final BattleHymnGame game;
  const HowToOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L.howToTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7FE3FF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x334FC3F7)),
                ),
                child: Text(
                  L.howToBody,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: game.closeHowTo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2BA8E0),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
                  textStyle:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(L.gotIt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
