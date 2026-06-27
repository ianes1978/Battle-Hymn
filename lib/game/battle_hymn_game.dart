import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/background.dart';
import '../components/enemy.dart';
import '../components/hud.dart';
import '../components/note_component.dart';
import '../components/piano_keyboard.dart';
import '../components/spell.dart';
import '../components/staff.dart';
import '../components/wizard.dart';
import '../input/key_mapping.dart';
import '../systems/audio_manager.dart';
import '../systems/spawner.dart';
import 'config.dart';
import 'game_state.dart';
import 'note_data.dart';

/// Identificatori degli overlay (schermate Flutter sopra il gioco).
class Overlays {
  static const String menu = 'menu';
  static const String pause = 'pause';
  static const String gameOver = 'gameOver';
}

/// Classe principale del gioco: orchestra componenti, input, punteggio e flusso
/// (menu → partita → game over). Tiene separati stato, rendering e input.
class BattleHymnGame extends FlameGame with KeyboardEvents {
  final GameState state = GameState();
  final AudioManager audio = AudioManager();

  late final Wizard wizard;
  late final PianoKeyboard keyboard;
  late final Spawner spawner;

  /// Note/beat attualmente in gioco (fonte di verità per il matching input).
  final List<NoteData> notes = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await audio.init(GameConfig.scaleLength);

    wizard = Wizard();
    keyboard = PianoKeyboard();
    spawner = Spawner();

    addAll([
      Background(),
      Staff(),
      wizard,
      keyboard,
      spawner,
      Hud(),
    ]);

    // Si parte dal menu, con il motore in pausa.
    overlays.add(Overlays.menu);
    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    state.update(dt);

    // Transizione a game over.
    if (state.isGameOver && !overlays.isActive(Overlays.gameOver)) {
      overlays.add(Overlays.gameOver);
      audio.stopBgm();
      pauseEngine();
    }
  }

  // ---------------------------------------------------------------------------
  // Flusso di gioco
  // ---------------------------------------------------------------------------

  /// Avvia una nuova partita da capo.
  void startGame() {
    _clearBeats();
    state.reset();
    spawner.reset();
    overlays.remove(Overlays.menu);
    overlays.remove(Overlays.gameOver);
    overlays.remove(Overlays.pause);
    resumeEngine();
    audio.startBgm();
  }

  /// Mette in pausa / riprende (ignorato durante menu o game over).
  void togglePause() {
    if (overlays.isActive(Overlays.menu) ||
        overlays.isActive(Overlays.gameOver)) {
      return;
    }
    if (state.isPaused) {
      state.isPaused = false;
      overlays.remove(Overlays.pause);
      resumeEngine();
    } else {
      state.isPaused = true;
      overlays.add(Overlays.pause);
      pauseEngine();
    }
  }

  /// Rimuove tutti i beat (note, nemici, magie) e svuota la lista.
  void _clearBeats() {
    children.whereType<Enemy>().forEach((c) => c.removeFromParent());
    children.whereType<NoteComponent>().forEach((c) => c.removeFromParent());
    children.whereType<Spell>().forEach((c) => c.removeFromParent());
    notes.clear();
  }

  // ---------------------------------------------------------------------------
  // Gestione beat
  // ---------------------------------------------------------------------------

  /// Crea sul campo una nuova coppia nota + nemico.
  void spawnBeat(NoteData note) {
    notes.add(note);
    add(NoteComponent(note: note));
    add(Enemy(note: note));
  }

  /// Rimuove una nota dalla lista logica (chiamato quando il componente esce).
  void removeNote(NoteData note) => notes.remove(note);

  /// Una nota ha raggiunto la linea senza essere suonata: il mago subisce danno.
  void onNoteReachedLine(NoteData note) {
    if (!note.isActive) return;
    note.state = BeatState.missed;
    state.registerMiss();
  }

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------

  /// Suona un pitch: riproduce il suono, illumina il tasto e prova a colpire la
  /// nota attiva più vicina alla linea con quel pitch.
  void playPitch(int pitch) {
    audio.playNote(pitch);
    keyboard.flash(pitch);

    if (state.isGameOver || state.isPaused) return;

    // Trova la nota attiva del pitch più vicina alla linea.
    NoteData? best;
    for (final NoteData n in notes) {
      if (n.isActive && n.pitch == pitch) {
        if (best == null || n.timeRemaining < best.timeRemaining) best = n;
      }
    }
    if (best == null) return;

    final Judgment j = best.evaluate();
    if (j == Judgment.none) return; // ancora troppo lontana: nessun effetto
    _resolveHit(best, j);
  }

  /// Risolve un colpo riuscito: distrugge il nemico e lancia la magia.
  void _resolveHit(NoteData note, Judgment judgment) {
    note.state = BeatState.resolved;
    note.judgment = judgment;
    state.registerHit(judgment);
    wizard.cast(note.angle);

    // Posizione del nemico colpito, per indirizzare la magia.
    Vector2? targetPos;
    for (final Enemy e in children.whereType<Enemy>()) {
      if (e.note == note) {
        targetPos = e.position.clone();
        break;
      }
    }
    targetPos ??= wizard.homePosition +
        Vector2(cos(note.angle), sin(note.angle)) * 200;

    add(Spell(
      start: wizard.homePosition.clone(),
      target: targetPos,
      color: note.color,
    ));
  }

  // ---------------------------------------------------------------------------
  // Tastiera fisica
  // ---------------------------------------------------------------------------

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final LogicalKeyboardKey key = event.logicalKey;

    // Pausa con P o ESC.
    if (key == LogicalKeyboardKey.keyP ||
        key == LogicalKeyboardKey.escape) {
      togglePause();
      return KeyEventResult.handled;
    }

    // Invio/Spazio: avvia o riavvia dal menu / game over.
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      if (overlays.isActive(Overlays.menu) ||
          overlays.isActive(Overlays.gameOver)) {
        startGame();
        return KeyEventResult.handled;
      }
    }

    // Note musicali.
    final int? pitch = KeyMapping.pitchForKey(key);
    if (pitch != null) {
      playPitch(pitch);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
