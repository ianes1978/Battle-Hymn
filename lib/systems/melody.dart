import 'dart:math';

/// Genera una melodia "che suona bene": note prese da una scala (Do maggiore)
/// con movimento prevalentemente per gradi vicini e qualche salto. Copre due
/// ottave, così c'è varietà anche visiva sullo spartito.
class MelodyGenerator {
  /// Gradi di Do maggiore (classi di nota).
  static const List<int> _scale = [0, 2, 4, 5, 7, 9, 11];

  final Random rng = Random();

  /// Posizione corrente come grado diatonico su 2 ottave (0..13).
  int _degree = 7;

  void reset() => _degree = 7;

  /// Prossima nota: classe (0..11) + ottava (0 bassa, 1 alta).
  ({int noteClass, int octave}) next() {
    final double r = rng.nextDouble();
    int step;
    if (r < 0.62) {
      step = rng.nextBool() ? 1 : -1; // grado adiacente
    } else if (r < 0.85) {
      step = rng.nextBool() ? 2 : -2; // terza
    } else {
      step = rng.nextInt(5) - 2; // piccolo salto
    }
    _degree = (_degree + step).clamp(0, _scale.length * 2 - 1);

    final int octave = _degree >= _scale.length ? 1 : 0;
    final int noteClass = _scale[_degree % _scale.length];
    return (noteClass: noteClass, octave: octave);
  }
}
