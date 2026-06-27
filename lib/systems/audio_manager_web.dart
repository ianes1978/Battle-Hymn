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
    final double now = ctx.currentTime;

    // Inviluppo principale (attacco rapido + decadimento).
    final web.GainNode master = ctx.createGain();
    master.gain.setValueAtTime(0.0001, now);
    master.gain.exponentialRampToValueAtTime(0.5, now + 0.006);
    master.gain.exponentialRampToValueAtTime(0.0008, now + 0.45);
    master.connect(ctx.destination);

    // Fondamentale + 2 armoniche.
    const List<double> harmonics = [1.0, 2.0, 3.0];
    const List<double> levels = [1.0, 0.4, 0.2];
    for (int i = 0; i < harmonics.length; i++) {
      final web.OscillatorNode osc = ctx.createOscillator();
      osc.type = 'sine';
      osc.frequency.value = freq * harmonics[i];
      final web.GainNode g = ctx.createGain();
      g.gain.value = levels[i];
      osc.connect(g);
      g.connect(master);
      osc.start(now);
      osc.stop(now + 0.5);
    }
  }

  void playKick(double volume) {
    final web.AudioContext? ctx = _ctx;
    if (ctx == null) return;
    _resume(ctx);
    final double now = ctx.currentTime;

    final web.OscillatorNode osc = ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(165, now);
    osc.frequency.exponentialRampToValueAtTime(45, now + 0.12);

    final web.GainNode g = ctx.createGain();
    g.gain.setValueAtTime(volume, now);
    g.gain.exponentialRampToValueAtTime(0.0008, now + 0.18);

    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(now);
    osc.stop(now + 0.2);
  }

  void playHat(double volume) {
    final web.AudioContext? ctx = _ctx;
    if (ctx == null) return;
    _resume(ctx);
    final double now = ctx.currentTime;

    // Hi-hat approssimato con un breve burst acuto.
    final web.OscillatorNode osc = ctx.createOscillator();
    osc.type = 'square';
    osc.frequency.value = 8000;

    final web.GainNode g = ctx.createGain();
    g.gain.setValueAtTime(volume * 0.3, now);
    g.gain.exponentialRampToValueAtTime(0.0005, now + 0.04);

    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(now);
    osc.stop(now + 0.05);
  }

  void startBgm() {}
  void stopBgm() {}
}
