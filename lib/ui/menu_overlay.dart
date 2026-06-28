import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/settings.dart';

/// Schermata iniziale: titolo, regole, opzioni (etichette e colori) e GIOCA.
class MenuOverlay extends StatefulWidget {
  final BattleHymnGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  GameSettings get settings => widget.game.settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.62),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BATTLE HYMN',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 6),
            const Text('rhythm bullet-heaven',
                style: TextStyle(fontSize: 16, color: Colors.amberAccent)),
            const SizedBox(height: 18),
            Text(
              'Colpisci la nota EVIDENZIATA premendo il tasto giusto.\n'
              'Conta la nota, non l\'ottava: un La va bene alto o basso.\n'
              'A tempo = gemma. 5 gemme = +1 vita. Le note vanno in ordine!',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 22),

            // --- Opzione: difficoltà ---
            _label('Difficoltà'),
            _segment<Difficulty>(
              current: settings.difficulty,
              options: const {
                Difficulty.facile: 'Facile',
                Difficulty.normale: 'Normale',
                Difficulty.difficile: 'Difficile',
              },
              onSelect: (v) => setState(() => settings.difficulty = v),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                switch (settings.difficulty) {
                  Difficulty.facile => 'Solo nemici base',
                  Difficulty.normale => '+ veloci e corazzati',
                  Difficulty.difficile => '+ mini-boss (tutto)',
                },
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
            const SizedBox(height: 14),

            // --- Opzione: etichette ---
            _label('Etichette'),
            _segment<LabelMode>(
              current: settings.labelMode,
              options: const {
                LabelMode.solfege: 'Do Re Mi',
                LabelMode.letters: 'C D E',
                LabelMode.none: 'Nessuna',
              },
              onSelect: (v) => setState(() => settings.labelMode = v),
            ),
            const SizedBox(height: 14),

            // --- Opzione: tempo (slider BPM) ---
            _label('Tempo: ${settings.bpm.round()} BPM'),
            SizedBox(
              width: 280,
              child: Slider(
                value: settings.bpm,
                min: 60,
                max: 200,
                divisions: 28, // passo di 5 BPM
                label: '${settings.bpm.round()} BPM',
                activeColor: Colors.amberAccent,
                onChanged: (v) => setState(() => settings.bpm = v),
              ),
            ),
            const SizedBox(height: 14),

            // --- Opzione: colori tastiera ---
            _label('Colori tastiera'),
            _segment<bool>(
              current: settings.keyboardColors,
              options: const {true: 'ON', false: 'OFF'},
              onSelect: (v) => setState(() => settings.keyboardColors = v),
            ),
            const SizedBox(height: 26),

            ElevatedButton(
              onPressed: widget.game.startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: const Text('GIOCA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      );

  /// Selettore "segmentato" generico.
  Widget _segment<T>({
    required T current,
    required Map<T, String> options,
    required ValueChanged<T> onSelect,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.entries.map((e) {
        final bool selected = e.key == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            onPressed: () => onSelect(e.key),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selected ? Colors.amberAccent : Colors.white24,
              foregroundColor: selected ? Colors.black : Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              textStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
            child: Text(e.value),
          ),
        );
      }).toList(),
    );
  }
}
