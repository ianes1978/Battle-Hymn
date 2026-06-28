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

  /// Volume generale (0..1) e on/off, impostati dalle opzioni.
  double master = 0.8;
  bool enabled = true;

  // Base ritmica (kick + hi-hat) sintetizzata.
  // Player DEDICATI e PRE-CARICATI: su Android riavviare con seek(0)+resume()
  // un suono già caricato evita i drop/troncamenti del play(BytesSource) ripetuto.
  Uint8List? _kick;
  Uint8List? _hat;
  final List<AudioPlayer> _kickPlayers = [];
  final List<AudioPlayer> _hatPlayers = [];
  int _kickNext = 0;
  int _hatNext = 0;

  // Basso (una nota grave per classe).
  static const double _bassBaseFreq = 65.41; // Do2
  final List<Uint8List> _bassWavs = [];
  final List<AudioPlayer> _bassPool = [];
  int _bassNext = 0;

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

    // Base ritmica: player dedicati e pre-caricati (kick e hi-hat separati).
    _kick = _buildKickWav();
    _hat = _buildHatWav();
    for (int i = 0; i < 3; i++) {
      final AudioPlayer kp = AudioPlayer();
      await kp.setReleaseMode(ReleaseMode.stop);
      await kp.setSource(BytesSource(_kick!, mimeType: 'audio/wav'));
      _kickPlayers.add(kp);

      final AudioPlayer hp = AudioPlayer();
      await hp.setReleaseMode(ReleaseMode.stop);
      await hp.setSource(BytesSource(_hat!, mimeType: 'audio/wav'));
      _hatPlayers.add(hp);
    }

    // Basso (12 classi a ottava grave) + pool dedicato.
    for (int i = 0; i < 12; i++) {
      _bassWavs.add(_buildBassWav(_bassBaseFreq * pow(2, i / 12).toDouble()));
    }
    for (int i = 0; i < 3; i++) {
      final AudioPlayer p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      _bassPool.add(p);
    }

    _ready = true;
  }

  /// Riproduce il tono della classe di nota indicata.
  void playNote(int noteClass) {
    if (!enabled || !_ready || _noteWavs.isEmpty) return;
    final int c = noteClass % _noteWavs.length;
    final AudioPlayer player = _pool[_next];
    _next = (_next + 1) % _pool.length;
    // Fire-and-forget: eventuali errori (es. player occupato) sono ignorati.
    player
        .play(BytesSource(_noteWavs[c], mimeType: 'audio/wav'),
            volume: 0.7 * master)
        .catchError((_) {});
  }

  /// Suona il kick (battito forte) della base ritmica.
  void playKick(double volume) =>
      _retrigger(_kickPlayers, () => _kickNext, (v) => _kickNext = v, volume);

  /// Suona l'hi-hat (battito leggero) della base ritmica.
  void playHat(double volume) =>
      _retrigger(_hatPlayers, () => _hatNext, (v) => _hatNext = v, volume);

  /// Riavvia un suono pre-caricato: imposta volume, torna all'inizio e riparte.
  void _retrigger(List<AudioPlayer> pool, int Function() getIdx,
      void Function(int) setIdx, double volume) {
    if (!enabled || !_ready || pool.isEmpty) return;
    final AudioPlayer player = pool[getIdx() % pool.length];
    setIdx((getIdx() + 1) % pool.length);
    player.setVolume((volume * master).clamp(0.0, 1.0));
    // seek(0) poi resume: ordine garantito dall'await interno della catena.
    player
        .seek(Duration.zero)
        .then((_) => player.resume())
        .catchError((_) {});
  }

  /// Suona la nota di basso (classe a ottava grave).
  void playBass(int noteClass, double volume) {
    if (!enabled || !_ready || _bassWavs.isEmpty) return;
    final int c = noteClass % _bassWavs.length;
    final AudioPlayer player = _bassPool[_bassNext];
    _bassNext = (_bassNext + 1) % _bassPool.length;
    player
        .play(BytesSource(_bassWavs[c], mimeType: 'audio/wav'),
            volume: volume * master)
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
    _fadeOut(samples);
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
    _fadeOut(s);
    return _wrapWav(s);
  }

  /// Basso: sinusoide grave morbida (fondamentale + lieve 2ª armonica).
  Uint8List _buildBassWav(double freq) {
    const double dur = 0.4;
    final int n = (_sampleRate * dur).round();
    final Int16List s = Int16List(n);
    const double attack = 0.01;
    const double tau = 0.2;
    for (int i = 0; i < n; i++) {
      final double t = i / _sampleRate;
      final double env = (t < attack ? t / attack : 1.0) * exp(-t / tau);
      double v = sin(2 * pi * freq * t) + 0.3 * sin(2 * pi * freq * 2 * t);
      v /= 1.3;
      s[i] = (v * env * 0.8 * 32767).clamp(-32768.0, 32767.0).toInt();
    }
    _fadeOut(s);
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

  /// Dissolvenza finale (anti-click): porta a zero gli ultimi millisecondi.
  void _fadeOut(Int16List s, {double seconds = 0.012}) {
    final int r = min(s.length, (_sampleRate * seconds).round());
    for (int i = 0; i < r; i++) {
      final int idx = s.length - r + i;
      s[idx] = (s[idx] * (1 - i / r)).toInt();
    }
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
