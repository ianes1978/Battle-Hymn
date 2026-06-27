import 'package:flame_audio/flame_audio.dart';

/// Gestore audio "crash-free": prova a precaricare i campioni delle note e la
/// musica; se i file non esistono (cartella assets vuota), l'audio resta
/// semplicemente disattivato e il gioco gira lo stesso in silenzio.
class AudioManager {
  /// Estensione dei campioni delle note (cambiala se usi mp3/ogg).
  static const String noteExtension = 'wav';
  static const String bgmFile = 'bgm.mp3';

  final Set<int> _loadedNotes = {};
  bool _bgmLoaded = false;
  bool _bgmPlaying = false;

  bool get hasAnyNote => _loadedNotes.isNotEmpty;

  /// Tenta di caricare tutti gli asset audio, ignorando quelli mancanti.
  Future<void> init(int scaleLength) async {
    for (int i = 0; i < scaleLength; i++) {
      final String file = 'note_$i.$noteExtension';
      try {
        await FlameAudio.audioCache.load(file);
        _loadedNotes.add(i);
      } catch (_) {
        // Asset mancante: nota disattivata, nessun crash.
      }
    }

    try {
      await FlameAudio.audioCache.load(bgmFile);
      _bgmLoaded = true;
    } catch (_) {
      _bgmLoaded = false;
    }
  }

  /// Riproduce il campione di una nota, se disponibile.
  void playNote(int pitch) {
    if (_loadedNotes.contains(pitch)) {
      FlameAudio.play('note_$pitch.$noteExtension', volume: 0.8);
    }
  }

  /// Avvia la musica di sottofondo in loop, se disponibile.
  void startBgm() {
    if (_bgmLoaded && !_bgmPlaying) {
      FlameAudio.bgm.play(bgmFile, volume: 0.4);
      _bgmPlaying = true;
    }
  }

  void stopBgm() {
    if (_bgmPlaying) {
      FlameAudio.bgm.stop();
      _bgmPlaying = false;
    }
  }
}
