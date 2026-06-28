import 'package:flutter/material.dart';

import '../game/battle_hymn_game.dart';
import '../game/settings.dart';
import '../i18n/strings.dart';

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
            Text(
              L.optionsTitle,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 18),

            _label(L.difficulty),
            _segment<Difficulty>(
              current: s.difficulty,
              options: {
                Difficulty.facile: L.easy,
                Difficulty.normale: L.normal,
                Difficulty.difficile: L.hard,
              },
              onSelect: (v) => setState(() => s.difficulty = v),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                switch (s.difficulty) {
                  Difficulty.facile => L.diffHintEasy,
                  Difficulty.normale => L.diffHintNormal,
                  Difficulty.difficile => L.diffHintHard,
                },
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
            const SizedBox(height: 14),

            _label(L.tempo(s.bpm.round())),
            _slider(
              value: s.bpm,
              min: 30,
              max: 200,
              divisions: 34, // passo di 5 BPM
              label: '${s.bpm.round()} BPM',
              onChanged: (v) => setState(() => s.bpm = v),
            ),
            const SizedBox(height: 14),

            _label(L.labels),
            _segment<LabelMode>(
              current: s.labelMode,
              options: {
                LabelMode.solfege: 'Do Re Mi',
                LabelMode.letters: 'C D E',
                LabelMode.none: L.labelsNone,
              },
              onSelect: (v) => setState(() => s.labelMode = v),
            ),
            const SizedBox(height: 14),

            _label(L.keyboardColors),
            _segment<bool>(
              current: s.keyboardColors,
              options: {true: L.on, false: L.off},
              onSelect: (v) => setState(() => s.keyboardColors = v),
            ),
            const SizedBox(height: 18),

            // --- Audio ---
            Text(L.audio,
                style: const TextStyle(
                    color: Color(0xFF2BA8E0),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            const SizedBox(height: 8),
            _label(L.sound),
            _segment<bool>(
              current: s.audioEnabled,
              options: {true: L.on, false: L.off},
              onSelect: (v) => setState(() {
                s.audioEnabled = v;
                widget.game.applyAudioSettings();
              }),
            ),
            const SizedBox(height: 10),
            _label(L.volume((s.volume * 100).round())),
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
            const SizedBox(height: 18),

            // --- Accessibilità ---
            Text(L.accessibility,
                style: const TextStyle(
                    color: Color(0xFF2BA8E0),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            const SizedBox(height: 8),
            _label(L.practiceMode),
            _segment<bool>(
              current: s.practiceMode,
              options: {true: L.on, false: L.off},
              onSelect: (v) => setState(() => s.practiceMode = v),
            ),
            const SizedBox(height: 10),
            _label(L.reduceMotion),
            _segment<bool>(
              current: s.reduceMotion,
              options: {true: L.on, false: L.off},
              onSelect: (v) => setState(() => s.reduceMotion = v),
            ),
            const SizedBox(height: 10),
            _label(L.colorblind),
            _segment<bool>(
              current: s.colorblind,
              options: {true: L.on, false: L.off},
              onSelect: (v) => setState(() => s.colorblind = v),
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
              child: Text(L.back),
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
