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
import 'settings.dart';

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
  final GameSettings settings = GameSettings();
  final AudioManager audio = AudioManager();

  late final Wizard wizard;
  late final PianoKeyboard keyboard;
  late final Spawner spawner;

  /// Note/beat attualmente in gioco (fonte di verità per il matching input).
  final List<NoteData> notes = [];

  /// Nota-bersaglio corrente: la più vicina alla linea (va colpita per prima).
  /// Ricalcolata ogni frame in [update].
  NoteData? activeTarget;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await audio.init(GameConfig.classCount);

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
  void render(Canvas canvas) {
    // Scossa schermo: trasla tutto il rendering di un piccolo offset.
    final Offset o = state.shakeOffset();
    if (o == Offset.zero) {
      super.render(canvas);
      return;
    }
    canvas.save();
    canvas.translate(o.dx, o.dy);
    super.render(canvas);
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    state.update(dt);
    _recomputeTarget();

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

  /// Ricalcola il bersaglio corrente: la nota attiva più vicina alla linea.
  void _recomputeTarget() {
    NoteData? best;
    for (final NoteData n in notes) {
      if (n.isActive && (best == null || n.progress > best.progress)) {
        best = n;
      }
    }
    activeTarget = best;
  }

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------

  /// Suona una classe di nota: riproduce il suono, illumina il tasto e — se
  /// corrisponde al bersaglio corrente — lo colpisce (in qualunque momento).
  ///
  /// Le note vanno colpite in ordine: solo il bersaglio (la nota più vicina
  /// alla linea) è bersagliabile. Il tempismo non è obbligatorio; se preciso
  /// (Perfect/Good) assegna una gemma.
  void playClass(int noteClass) {
    audio.playNote(noteClass);
    keyboard.flashClass(noteClass);

    if (state.isGameOver || state.isPaused) return;

    final NoteData? target = activeTarget;
    if (target == null || target.noteClass != noteClass) {
      return; // nota sbagliata o nessun bersaglio: nessun effetto
    }

    _resolveHit(target);
  }

  /// Risolve un colpo riuscito: distrugge il nemico e lancia la magia.
  void _resolveHit(NoteData note) {
    final Judgment judgment = note.evaluate();
    final bool gem =
        judgment == Judgment.perfect || judgment == Judgment.good;

    note.state = BeatState.resolved;
    note.judgment = judgment;
    activeTarget = null;
    state.registerHit(judgment, gem);
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

    // Note musicali (per classe, ottava-indipendente).
    final int? noteClass = KeyMapping.classForKey(key);
    if (noteClass != null) {
      playClass(noteClass);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
