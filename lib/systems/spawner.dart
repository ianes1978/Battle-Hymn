import 'dart:math';

import 'package:flame/components.dart';

import '../game/battle_hymn_game.dart';
import '../game/config.dart';
import '../game/note_data.dart';

/// Sistema di spawn: decide QUANDO generare un nuovo beat (nota + nemico) e con
/// quali parametri, facendo crescere la difficoltà nel tempo.
class Spawner extends Component with HasGameReference<BattleHymnGame> {
  final Random _rng = Random();
  double _timer = 0;

  /// Intervallo corrente fino al prossimo spawn.
  double _nextInterval = GameConfig.initialSpawnInterval;

  void reset() {
    _timer = 0;
    _nextInterval = GameConfig.initialSpawnInterval;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state.isGameOver || game.state.isPaused) return;

    _timer += dt;
    if (_timer >= _nextInterval) {
      _timer = 0;
      _spawnBeat();
      _scheduleNext();
    }
  }

  /// Calcola l'intervallo del prossimo spawn in base alla difficoltà.
  void _scheduleNext() {
    final double d = game.state.difficulty; // 0..1
    final double base = _lerp(
      GameConfig.initialSpawnInterval,
      GameConfig.minSpawnInterval,
      d,
    );
    // Variazione casuale ±20% per evitare un ritmo robotico.
    _nextInterval = base * (0.8 + _rng.nextDouble() * 0.4);
  }

  /// Crea un beat: sceglie pitch (→ direzione/colore) e velocità.
  void _spawnBeat() {
    final int pitch = _rng.nextInt(GameConfig.scaleLength);

    // Direzione a 360° derivata dal pitch (settori distinti) + piccolo jitter,
    // così l'altezza della nota resta correlata alla direzione del nemico.
    final double sector = (pitch / GameConfig.scaleLength) * 2 * pi;
    final double jitter = (_rng.nextDouble() - 0.5) * 0.5;
    final double angle = sector - pi / 2 + jitter;

    // Velocità: le note diventano più rapide con la difficoltà.
    final double d = game.state.difficulty;
    final double duration = _lerp(
      GameConfig.initialNoteDuration,
      GameConfig.minNoteDuration,
      d,
    );

    final NoteData note = NoteData(
      pitch: pitch,
      angle: angle,
      duration: duration,
    );
    game.spawnBeat(note);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);
}
