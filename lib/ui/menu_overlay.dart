import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';

/// Schermata iniziale: titolo, controlli e pulsante per iniziare.
class MenuOverlay extends StatelessWidget {
  final BattleHymnGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      children: [
        const Text(
          'BATTLE HYMN',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'rhythm bullet-heaven',
          style: TextStyle(fontSize: 16, color: Colors.amberAccent),
        ),
        const SizedBox(height: 24),
        Text(
          'Premi il tasto mostrato sul nemico quando raggiunge la linea.\n'
          'Tasti bianchi:  A S D F G H J K\n'
          'Tasti neri (diesis):  W E  T Y U\n'
          'Puoi anche cliccare/toccare il pianoforte.  P / ESC = pausa.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.85)),
        ),
        const SizedBox(height: 28),
        _PlayButton(label: 'GIOCA', onPressed: game.startGame),
      ],
    );
  }
}

/// Pannello centrato semitrasparente riutilizzato dagli overlay.
class _Panel extends StatelessWidget {
  final List<Widget> children;
  const _Panel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PlayButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
