import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Gestore audio per il WEB: usa direttamente la Web Audio API del browser
/// (oscillatori + inviluppi), affidabile e a bassa latenza, senza file.
///
/// Stessa interfaccia pubblica della versione mobile/desktop.
class AudioManager {
  static const double _baseFreq = 261.626; // Do4

  /// Volume generale (0..1) e on/off, impostati dalle opzioni.
  double master = 0.8;
  bool enabled = true;

  web.AudioContext? _ctx;

  Future<void> init(int noteCount) async {
    try {
      _ctx = web.AudioContext();
    } catch (_) {
      _ctx = null;
    }
  }

  /// Sblocca/riprende il contesto audio (i browser lo avviano "sospeso").
  void _resume(web.AudioContext ctx) {
    if (ctx.state == 'suspended') {
      ctx.resume();
    }
  }

  void playNote(int noteClass) {
    final web.AudioContext? ctx = _ctx;
    if (!enabled || ctx == null) return;
    _resume(ctx);

    final double freq = _baseFreq * pow(2, (noteClass % 12) / 12).toDouble();
    final double t = ctx.currentTime + 0.018; // piccolo lookahead

    // Un solo oscillatore (triangolare = timbro ricco con un nodo solo).
    final web.OscillatorNode osc = ctx.createOscillator();
    osc.type = 'triangle';
    osc.frequency.value = freq;

    final web.GainNode g = ctx.createGain();
    g.gain.setValueAtTime(0, t);
    g.gain.linearRampToValueAtTime(0.45 * master, t + 0.006); // attacco
    g.gain.exponentialRampToValueAtTime(0.001, t + 0.45); // decadimento

    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.5);
  }

  void playBass(int noteClass, double volume) {
    final web.AudioContext? ctx = _ctx;
    if (!enabled || ctx == null) return;
    _resume(ctx);
    final double freq = 65.41 * pow(2, (noteClass % 12) / 12).toDouble(); // Do2
    final double t = ctx.currentTime + 0.018;

    final web.OscillatorNode osc = ctx.createOscillator();
    osc.type = 'triangle';
    osc.frequency.value = freq;

    final web.GainNode g = ctx.createGain();
    g.gain.setValueAtTime(0, t);
    g.gain.linearRampToValueAtTime(volume * master, t + 0.01);
    g.gain.exponentialRampToValueAtTime(0.001, t + 0.38);

    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.4);
  }

  void playKick(double volume) {
    final web.AudioContext? ctx = _ctx;
    if (!enabled || ctx == null) return;
    _resume(ctx);
    final double t = ctx.currentTime + 0.018;

    final web.OscillatorNode osc = ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(165, t);
    osc.frequency.exponentialRampToValueAtTime(45, t + 0.12);

    final web.GainNode g = ctx.createGain();
    g.gain.setValueAtTime(0, t);
    g.gain.linearRampToValueAtTime(volume * master, t + 0.004); // attacco morbido
    g.gain.exponentialRampToValueAtTime(0.0008, t + 0.18);

    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.2);
  }

  void playHat(double volume) {
    final web.AudioContext? ctx = _ctx;
    if (!enabled || ctx == null) return;
    _resume(ctx);
    final double t = ctx.currentTime + 0.018;

    // Hi-hat realistico: breve burst di rumore bianco filtrato (passa-alto),
    // morbido e "ticchettante" invece dell'onda quadra dura di prima.
    final int len = (ctx.sampleRate * 0.05).round();
    final web.AudioBuffer buf = ctx.createBuffer(1, len, ctx.sampleRate);
    final Float32List data = Float32List(len);
    final Random r = Random();
    final double decay = ctx.sampleRate * 0.012;
    for (int i = 0; i < len; i++) {
      data[i] = (r.nextDouble() * 2 - 1) * exp(-i / decay);
    }
    buf.copyToChannel(data.toJS, 0);

    final web.AudioBufferSourceNode src = ctx.createBufferSource();
    src.buffer = buf;

    final web.BiquadFilterNode hp = ctx.createBiquadFilter();
    hp.type = 'highpass';
    hp.frequency.value = 7000;

    final web.GainNode g = ctx.createGain();
    g.gain.value = volume * 0.16 * master;

    src.connect(hp);
    hp.connect(g);
    g.connect(ctx.destination);
    src.start(t);
    src.stop(t + 0.06);
  }

  void startBgm() {}
  void stopBgm() {}
}
