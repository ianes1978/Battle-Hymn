import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/settings.dart';

/// Schermata Opzioni: difficoltà, tempo, etichette, colori e audio.
class OptionsOverlay extends StatefulWidget {
  final BattleHymnGame game;
  const OptionsOverlay({super.key, required this.game});

  @override
  State<OptionsOverlay> createState() => _OptionsOverlayState();
}

class _OptionsOverlayState extends State<OptionsOverlay> {
  GameSettings get s => widget.game.settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'OPZIONI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 18),

            _label('Difficoltà'),
            _segment<Difficulty>(
              current: s.difficulty,
              options: const {
                Difficulty.facile: 'Facile',
                Difficulty.normale: 'Normale',
                Difficulty.difficile: 'Difficile',
              },
              onSelect: (v) => setState(() => s.difficulty = v),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                switch (s.difficulty) {
                  Difficulty.facile => 'Solo nemici base',
                  Difficulty.normale => '+ veloci e corazzati',
                  Difficulty.difficile => '+ mini-boss (tutto)',
                },
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
            const SizedBox(height: 14),

            _label('Tempo: ${s.bpm.round()} BPM'),
            _slider(
              value: s.bpm,
              min: 30,
              max: 200,
              divisions: 34, // passo di 5 BPM
              label: '${s.bpm.round()} BPM',
              onChanged: (v) => setState(() => s.bpm = v),
            ),
            const SizedBox(height: 14),

            _label('Etichette'),
            _segment<LabelMode>(
              current: s.labelMode,
              options: const {
                LabelMode.solfege: 'Do Re Mi',
                LabelMode.letters: 'C D E',
                LabelMode.none: 'Nessuna',
              },
              onSelect: (v) => setState(() => s.labelMode = v),
            ),
            const SizedBox(height: 14),

            _label('Colori tastiera'),
            _segment<bool>(
              current: s.keyboardColors,
              options: const {true: 'ON', false: 'OFF'},
              onSelect: (v) => setState(() => s.keyboardColors = v),
            ),
            const SizedBox(height: 18),

            // --- Audio ---
            const Text('AUDIO',
                style: TextStyle(
                    color: const Color(0xFF2BA8E0),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            const SizedBox(height: 8),
            _label('Suono'),
            _segment<bool>(
              current: s.audioEnabled,
              options: const {true: 'ON', false: 'OFF'},
              onSelect: (v) => setState(() {
                s.audioEnabled = v;
                widget.game.applyAudioSettings();
              }),
            ),
            const SizedBox(height: 10),
            _label('Volume: ${(s.volume * 100).round()}%'),
            _slider(
              value: s.volume,
              min: 0,
              max: 1,
              divisions: 20,
              label: '${(s.volume * 100).round()}%',
              onChanged: (v) => setState(() {
                s.volume = v;
                widget.game.applyAudioSettings();
              }),
            ),
            const SizedBox(height: 26),

            ElevatedButton(
              onPressed: widget.game.closeOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BA8E0),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('INDIETRO'),
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

  Widget _slider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return SizedBox(
      width: 280,
      child: Slider(
        value: value.clamp(min, max).toDouble(),
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        activeColor: const Color(0xFF2BA8E0),
        onChanged: onChanged,
      ),
    );
  }

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
              backgroundColor: selected ? const Color(0xFF2BA8E0) : Colors.white24,
              foregroundColor: selected ? Colors.black : Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            child: Text(e.value),
          ),
        );
      }).toList(),
    );
  }
}
