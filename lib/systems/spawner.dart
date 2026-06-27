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

  void _scheduleNext() {
    final double d = game.state.difficulty;
    final double base = _lerp(
      GameConfig.initialSpawnInterval,
      GameConfig.minSpawnInterval,
      d,
    );
    // Velocità scelta dal giocatore: < 1 rallenta (intervalli più lunghi).
    _nextInterval = base * (0.8 + _rng.nextDouble() * 0.4) / game.settings.speed;
  }

  void _spawnBeat() {
    // Classe di nota (0..11): conta per l'input.
    final int noteClass = _rng.nextInt(GameConfig.classCount);

    // Ottava sullo spartito: 0 (bassa) o 1 (alta), limitando al La alto.
    int octave = _rng.nextInt(2);
    int staffIndex = octave * 12 + noteClass;
    if (staffIndex > GameConfig.staffMax) {
      octave = 0;
      staffIndex = noteClass;
    }

    // Direzione derivata dalla classe, ma limitata al SEMICERCHIO SUPERIORE
    // (dall'alto e dai lati, mai da sotto: il mago è in basso al centro).
    // In coordinate schermo l'asse Y cresce verso il basso, quindi gli angoli
    // in [π, 2π] puntano verso l'alto/i lati.
    final double sector =
        pi + ((noteClass + 0.5) / GameConfig.classCount) * pi;
    final double jitter = (_rng.nextDouble() - 0.5) * 0.35;
    final double angle = (sector + jitter).clamp(pi + 0.08, 2 * pi - 0.08);

    final double d = game.state.difficulty;
    // Più alta la velocità, più breve il tempo per raggiungere la linea.
    final double duration = _lerp(
      GameConfig.initialNoteDuration,
      GameConfig.minNoteDuration,
      d,
    ) /
        game.settings.speed;

    game.spawnBeat(NoteData(
      noteClass: noteClass,
      staffIndex: staffIndex,
      angle: angle,
      duration: duration,
    ));
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);
}
