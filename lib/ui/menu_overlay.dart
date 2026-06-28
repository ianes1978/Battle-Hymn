import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../i18n/strings.dart';
import '../systems/iap_manager.dart';

/// Schermata iniziale: titolo, regole, GIOCA e accesso alle Opzioni.
class MenuOverlay extends StatefulWidget {
  final BattleHymnGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  BattleHymnGame get game => widget.game;

  @override
  void initState() {
    super.initState();
    game.iap.lastResult.addListener(_onCoffeeResult);
  }

  @override
  void dispose() {
    game.iap.lastResult.removeListener(_onCoffeeResult);
    super.dispose();
  }

  void _onCoffeeResult() {
    final CoffeeResult? r = game.iap.lastResult.value;
    if (r == null || !mounted) return;
    final String msg = switch (r) {
      CoffeeResult.thanks => L.coffeeThanks,
      CoffeeResult.pending => L.coffeePending,
      CoffeeResult.canceled => '',
      CoffeeResult.error => L.coffeeError,
    };
    game.iap.lastResult.value = null; // consuma l'evento
    if (msg.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF13203B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
            const SizedBox(height: 10),
            TextButton(
              onPressed: game.openHowTo,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7FE3FF),
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              child: Text(L.howToButton),
            ),
            // Pulsante "Offrimi un caffè": solo se il billing è disponibile
            // (Android con prodotto configurato). Nascosto sul web.
            if (game.iap.available) ...[
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: game.iap.buyCoffee,
                icon: const Text('☕', style: TextStyle(fontSize: 16)),
                label: Text(
                  game.iap.price != null
                      ? '${L.coffee} (${game.iap.price})'
                      : L.coffee,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFD54F),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
