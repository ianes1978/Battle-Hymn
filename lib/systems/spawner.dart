import 'dart:math';

import 'package:flame/components.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../game/note_data.dart';
import '../game/tuning.dart';
import 'melody.dart';

/// "Conductor" del gioco: scandisce i beat in base al BPM, suona la base
/// ritmica e genera le note melodiche in modo che arrivino sulla linea a tempo.
class Spawner extends Component with HasGameReference<BattleHymnGame> {
  final MelodyGenerator _melody = MelodyGenerator();
  final Random _rng = Random();

  double _songTime = 0;
  int _lastBeat = -1;
  double _beatsSinceSpawn = 99; // grande: spawn quasi subito

  void reset() {
    _songTime = 0;
    _lastBeat = -1;
    _beatsSinceSpawn = 99;
    _melody.reset();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state.isGameOver || game.state.isPaused) return;

    final double beatInterval = 60.0 / game.settings.bpm;
    _songTime += dt;
    final int beat = (_songTime / beatInterval).floor();

    // Processa ogni beat trascorso (se un frame ne salta più d'uno).
    while (_lastBeat < beat) {
      _lastBeat++;
      _onBeat(_lastBeat, beatInterval);
    }
  }

  void _onBeat(int beatIndex, double beatInterval) {
    // Pulsazione visiva + base ritmica.
    game.beatPulse = 1;
    final bool accent = beatIndex % 4 == 0;
    game.audio.playKick(accent ? 0.6 : 0.4);
    // Crescendo: con la combo si aggiunge l'hi-hat.
    if (game.state.combo >= 8) {
      game.audio.playHat(game.state.combo >= 20 ? 0.32 : 0.2);
    }

    // Densità: più note man mano che si sopravvive / con la difficoltà.
    final double d = game.state.difficulty;
    final double beatsPerNote =
        (_lerp(2.2, 1.0, d) * Tuning.spawnScale).clamp(0.5, 4.0);

    _beatsSinceSpawn += 1;
    if (_beatsSinceSpawn >= beatsPerNote &&
        _activeCount() < Tuning.maxConcurrent) {
      _beatsSinceSpawn -= beatsPerNote;
      _spawnNote(beatInterval, d);
    }
  }

  void _spawnNote(double beatInterval, double d) {
    final note = _melody.next();
    int staffIndex = note.octave * 12 + note.noteClass;
    if (staffIndex > GameConfig.staffMax) staffIndex = note.noteClass;

    // Direzione nel semicerchio superiore, derivata dalla classe.
    final double sector =
        pi + ((note.noteClass + 0.5) / GameConfig.classCount) * pi;
    final double jitter = (_rng.nextDouble() - 0.5) * 0.3;
    final double angle = (sector + jitter).clamp(pi + 0.08, 2 * pi - 0.08);

    // Durata = numero intero di beat: così l'arrivo cade su un battito.
    final int travelBeats =
        (_lerp(6, 4, d) * Tuning.durationScale).clamp(2.0, 9.0).round();
    final double duration = travelBeats * beatInterval;

    game.spawnBeat(NoteData(
      noteClass: note.noteClass,
      staffIndex: staffIndex,
      angle: angle,
      duration: duration,
    ));
  }

  int _activeCount() {
    int c = 0;
    for (final NoteData n in game.notes) {
      if (n.isActive) c++;
    }
    return c;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);
}
