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
  // Orientamento verticale (portrait) su mobile.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final BattleHymnGame game = BattleHymnGame();

  runApp(
    MaterialApp(
      title: 'Battle Hymn',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        // SafeArea: il gioco resta dentro l'area visibile (sotto la status bar
        // e sopra i pulsanti di navigazione), così non sborda né viene coperto.
        body: SafeArea(
          child: GameWidget<BattleHymnGame>(
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
    ),
  );
}
