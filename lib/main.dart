import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/battle_hymn_game.dart';
import 'ui/game_over_overlay.dart';
import 'ui/menu_overlay.dart';
import 'ui/pause_overlay.dart';

/// Punto di ingresso dell'applicazione.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Forza l'orientamento orizzontale su mobile (il layout è pensato in wide).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final BattleHymnGame game = BattleHymnGame();

  runApp(
    MaterialApp(
      title: 'Battle Hymn',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<BattleHymnGame>(
          game: game,
          // Overlay attivi all'avvio (mostra il menu).
          initialActiveOverlays: const [Overlays.menu],
          overlayBuilderMap: {
            Overlays.menu: (context, g) => MenuOverlay(game: g),
            Overlays.pause: (context, g) => PauseOverlay(game: g),
            Overlays.gameOver: (context, g) => GameOverOverlay(game: g),
          },
        ),
      ),
    ),
  );
}
