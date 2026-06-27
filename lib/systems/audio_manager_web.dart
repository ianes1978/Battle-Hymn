import 'dart:math';

import 'package:web/web.dart' as web;

/// Gestore audio per il WEB: usa direttamente la Web Audio API del browser
/// (oscillatori + inviluppi), affidabile e a bassa latenza, senza file.
///
/// Stessa interfaccia pubblica della versione mobile/desktop.
class AudioManager {
  static const double _baseFreq = 261.626; // Do4

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
    if (ctx == null) return;
    _resume(ctx);

    final double freq = _baseFreq * pow(2, (noteClass % 12) / 12).toDouble();
    final double t = ctx.currentTime + 0.018; // piccolo lookahead

    // Un solo oscillatore (triangolare = timbro ricco con un nodo solo).
    final web.OscillatorNode osc = ctx.createOscillator();
    osc.type = 'triangle';
    osc.frequency.value = freq;

    final web.GainNode g = ctx.createGain();
    g.gain.setValueAtTime(0, t);
    g.gain.linearRampToValueAtTime(0.45, t + 0.006); // attacco lineare
    g.gain.exponentialRampToValueAtTime(0.001, t + 0.45); // decadimento

    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.5);
  }

  void playKick(double volume) {
    final web.AudioContext? ctx = _ctx;
    if (ctx == null) return;
    _resume(ctx);
    final double t = ctx.currentTime + 0.018;

    final web.OscillatorNode osc = ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(165, t);
    osc.frequency.exponentialRampToValueAtTime(45, t + 0.12);

    final web.GainNode g = ctx.createGain();
    g.gain.setValueAtTime(volume, t);
    g.gain.exponentialRampToValueAtTime(0.0008, t + 0.18);

    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.2);
  }

  void playHat(double volume) {
    final web.AudioContext? ctx = _ctx;
    if (ctx == null) return;
    _resume(ctx);
    final double t = ctx.currentTime + 0.018;

    // Hi-hat approssimato con un breve burst acuto.
    final web.OscillatorNode osc = ctx.createOscillator();
    osc.type = 'square';
    osc.frequency.value = 8000;

    final web.GainNode g = ctx.createGain();
    g.gain.setValueAtTime(volume * 0.3, t);
    g.gain.exponentialRampToValueAtTime(0.0005, t + 0.04);

    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(t);
    osc.stop(t + 0.05);
  }

  void startBgm() {}
  void stopBgm() {}
}
