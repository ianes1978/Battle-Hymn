import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Gestore audio (mobile/desktop): genera a runtime i suoni delle note come WAV
/// PCM in memoria e li riproduce con un pool di player audioplayers.
class AudioManager {
  static const int _sampleRate = 44100;
  static const double _toneSeconds = 0.45;

  /// Frequenza base: Do4 (Do centrale). Le classi salgono di semitono.
  static const double _baseFreq = 261.626;

  final List<Uint8List> _noteWavs = [];
  final List<AudioPlayer> _pool = [];
  int _next = 0;
  bool _ready = false;

  // Base ritmica (kick + hi-hat) sintetizzata.
  Uint8List? _kick;
  Uint8List? _hat;
  final List<AudioPlayer> _drumPool = [];
  int _drumNext = 0;

  /// Prepara i WAV delle note e il pool di player.
  Future<void> init(int noteCount) async {
    for (int i = 0; i < noteCount; i++) {
      final double freq = _baseFreq * pow(2, i / 12).toDouble();
      _noteWavs.add(_buildToneWav(freq));
    }
    // Pool ampio: pressioni rapide + base ritmica non si rubano i canali.
    for (int i = 0; i < 16; i++) {
      final AudioPlayer p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      _pool.add(p);
    }

    // Base ritmica (pool dedicato, separato dalle note).
    _kick = _buildKickWav();
    _hat = _buildHatWav();
    for (int i = 0; i < 6; i++) {
      final AudioPlayer p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      _drumPool.add(p);
    }

    _ready = true;
  }

  /// Riproduce il tono della classe di nota indicata.
  void playNote(int noteClass) {
    if (!_ready || _noteWavs.isEmpty) return;
    final int c = noteClass % _noteWavs.length;
    final AudioPlayer player = _pool[_next];
    _next = (_next + 1) % _pool.length;
    // Fire-and-forget: eventuali errori (es. player occupato) sono ignorati.
    player
        .play(BytesSource(_noteWavs[c], mimeType: 'audio/wav'), volume: 0.7)
        .catchError((_) {});
  }

  /// Suona il kick (battito forte) della base ritmica.
  void playKick(double volume) => _playDrum(_kick, volume);

  /// Suona l'hi-hat (battito leggero) della base ritmica.
  void playHat(double volume) => _playDrum(_hat, volume);

  void _playDrum(Uint8List? wav, double volume) {
    if (!_ready || wav == null) return;
    final AudioPlayer player = _drumPool[_drumNext];
    _drumNext = (_drumNext + 1) % _drumPool.length;
    player
        .play(BytesSource(wav, mimeType: 'audio/wav'), volume: volume)
        .catchError((_) {});
  }

  // La base ritmica è guidata dai beat (vedi Spawner): nessun loop separato.
  void startBgm() {}
  void stopBgm() {}

  // ---------------------------------------------------------------------------
  // Sintesi
  // ---------------------------------------------------------------------------

  Uint8List _buildToneWav(double freq) {
    final int n = (_sampleRate * _toneSeconds).round();
    final Int16List samples = Int16List(n);
    const double attack = 0.006;
    const double tau = 0.16;

    for (int i = 0; i < n; i++) {
      final double t = i / _sampleRate;
      final double env = (t < attack ? t / attack : 1.0) * exp(-t / tau);
      double s = sin(2 * pi * freq * t) +
          0.5 * sin(2 * pi * freq * 2 * t) +
          0.25 * sin(2 * pi * freq * 3 * t);
      s /= 1.75;
      final double amp = (s * env * 0.6 * 32767).clamp(-32768.0, 32767.0);
      samples[i] = amp.toInt();
    }
    return _wrapWav(samples);
  }

  Uint8List _buildKickWav() {
    const double dur = 0.18;
    final int n = (_sampleRate * dur).round();
    final Int16List s = Int16List(n);
    for (int i = 0; i < n; i++) {
      final double t = i / _sampleRate;
      final double env = exp(-t / 0.05);
      final double freq = 120 * exp(-t / 0.03) + 45;
      final double v = sin(2 * pi * freq * t) * env;
      s[i] = (v * 0.9 * 32767).clamp(-32768.0, 32767.0).toInt();
    }
    return _wrapWav(s);
  }

  Uint8List _buildHatWav() {
    const double dur = 0.05;
    final int n = (_sampleRate * dur).round();
    final Int16List s = Int16List(n);
    final Random r = Random(12345);
    for (int i = 0; i < n; i++) {
      final double t = i / _sampleRate;
      final double env = exp(-t / 0.012);
      final double v = (r.nextDouble() * 2 - 1) * env;
      s[i] = (v * 0.5 * 32767).clamp(-32768.0, 32767.0).toInt();
    }
    return _wrapWav(s);
  }

  Uint8List _wrapWav(Int16List samples) {
    final int dataLen = samples.length * 2;
    final ByteData bd = ByteData(44 + dataLen);
    int o = 0;
    void str(String s) {
      for (final int code in s.codeUnits) {
        bd.setUint8(o++, code);
      }
    }

    str('RIFF');
    bd.setUint32(o, 36 + dataLen, Endian.little);
    o += 4;
    str('WAVE');
    str('fmt ');
    bd.setUint32(o, 16, Endian.little);
    o += 4;
    bd.setUint16(o, 1, Endian.little);
    o += 2;
    bd.setUint16(o, 1, Endian.little);
    o += 2;
    bd.setUint32(o, _sampleRate, Endian.little);
    o += 4;
    bd.setUint32(o, _sampleRate * 2, Endian.little);
    o += 4;
    bd.setUint16(o, 2, Endian.little);
    o += 2;
    bd.setUint16(o, 16, Endian.little);
    o += 2;
    str('data');
    bd.setUint32(o, dataLen, Endian.little);
    o += 4;
    for (int i = 0; i < samples.length; i++) {
      bd.setInt16(o, samples[i], Endian.little);
      o += 2;
    }
    return bd.buffer.asUint8List();
  }
}
