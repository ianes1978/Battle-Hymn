import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/background.dart';
import '../components/burst.dart';
import '../components/enemy.dart';
import '../components/hud.dart';
import '../components/note_component.dart';
import '../components/piano_keyboard.dart';
import '../components/spell.dart';
import '../components/staff.dart';
import '../components/wizard.dart';
import '../input/key_mapping.dart';
import '../systems/audio_manager.dart';
import '../systems/iap_manager.dart';
import '../systems/spawner.dart';
import 'config.dart';
import 'game_state.dart';
import 'note_data.dart';
import 'settings.dart';
import 'tuning.dart';
import 'upgrades.dart';

/// Identificatori degli overlay (schermate Flutter sopra il gioco).
class Overlays {
  static const String menu = 'menu';
  static const String options = 'options';
  static const String upgrades = 'upgrades';
  static const String pause = 'pause';
  static const String gameOver = 'gameOver';
  static const String howTo = 'howTo';
}

/// Classe principale del gioco: orchestra componenti, input, punteggio e flusso
/// (menu → partita → game over). Tiene separati stato, rendering e input.
class BattleHymnGame extends FlameGame with KeyboardEvents {
  final GameState state = GameState();
  final GameSettings settings = GameSettings();
  final AudioManager audio = AudioManager();

  /// Acquisto in-app facoltativo "Offrimi un caffè" (mancia, solo Android).
  final IapManager iap = IapManager();

  late final Wizard wizard;
  late final PianoKeyboard keyboard;
  late final Spawner spawner;

  /// Note/beat attualmente in gioco (fonte di verità per il matching input).
  final List<NoteData> notes = [];

  /// Nota-bersaglio corrente: la più vicina alla linea (va colpita per prima).
  /// Ricalcolata ogni frame in [update].
  NoteData? activeTarget;

  /// Pulsazione a tempo (0..1): impostata a 1 a ogni beat, decade nel frame.
  double beatPulse = 0;

  /// Record (high score) persistente e flag "nuovo record" dell'ultima partita.
  int highScore = 0;
  bool newRecord = false;
  SharedPreferences? _prefs;

  /// Progressione roguelite (cristalli + potenziamenti persistenti).
  final Upgrades upgrades = Upgrades();

  /// Cristalli guadagnati nell'ultima partita (per la schermata game over).
  int lastCrystalsEarned = 0;

  /// Vero al primissimo avvio (nessun tutorial ancora visto).
  bool _firstRun = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await audio.init(GameConfig.classCount);

    // Inizializza il billing (no-op sul web / se non disponibile).
    iap.init();

    // Record + impostazioni + progressione salvati localmente.
    bool firstRun = true;
    try {
      _prefs = await SharedPreferences.getInstance();
      highScore = _prefs?.getInt('highScore') ?? 0;
      if (_prefs != null) {
        upgrades.load(_prefs!);
        settings.load(_prefs!);
        firstRun = !(_prefs!.getBool('seenTutorial') ?? false);
      }
    } catch (_) {
      highScore = 0;
    }
    _firstRun = firstRun;

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
    // Al primissimo avvio mostra il tutorial sopra il menu.
    if (_firstRun) {
      overlays.add(Overlays.howTo);
      _prefs?.setBool('seenTutorial', true);
    }
    pauseEngine();
  }

  @override
  void render(Canvas canvas) {
    // Scossa schermo: trasla tutto il rendering di un piccolo offset.
    // Disattivata se "riduci animazioni" è attivo.
    final Offset o =
        settings.reduceMotion ? Offset.zero : state.shakeOffset();
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
    if (beatPulse > 0) beatPulse = (beatPulse - dt * 4).clamp(0.0, 1.0);

    // Transizione a game over.
    if (state.isGameOver && !overlays.isActive(Overlays.gameOver)) {
      // Aggiorna il record se superato.
      newRecord = state.score > highScore;
      if (newRecord) {
        highScore = state.score;
        _prefs?.setInt('highScore', highScore);
      }
      // Cristalli roguelite guadagnati.
      lastCrystalsEarned = Upgrades.crystalsFor(state.score);
      upgrades.crystals += lastCrystalsEarned;
      if (_prefs != null) upgrades.save(_prefs!);

      overlays.add(Overlays.gameOver);
      audio.stopBgm();
      pauseEngine();
    }
  }

  // ---------------------------------------------------------------------------
  // Flusso di gioco
  // ---------------------------------------------------------------------------

  /// Apre/chiude la schermata Opzioni (dal menu).
  void openOptions() {
    overlays.remove(Overlays.menu);
    overlays.add(Overlays.options);
  }

  void closeOptions() {
    saveSettings();
    overlays.remove(Overlays.options);
    overlays.add(Overlays.menu);
  }

  /// Apre/chiude la schermata Potenziamenti (dal menu).
  void openUpgrades() {
    overlays.remove(Overlays.menu);
    overlays.add(Overlays.upgrades);
  }

  void closeUpgrades() {
    overlays.remove(Overlays.upgrades);
    overlays.add(Overlays.menu);
  }

  /// Apre/chiude il tutorial "Come si gioca" (dal menu).
  void openHowTo() => overlays.add(Overlays.howTo);
  void closeHowTo() => overlays.remove(Overlays.howTo);

  /// Salva le impostazioni (chiamato dalla schermata Opzioni).
  void saveSettings() {
    if (_prefs != null) settings.save(_prefs!);
  }

  /// Salva la progressione roguelite (chiamato dalla schermata Potenziamenti).
  void saveUpgrades() {
    if (_prefs != null) upgrades.save(_prefs!);
  }

  /// Applica le impostazioni audio (volume / on-off).
  void applyAudioSettings() {
    audio.master = settings.volume;
    audio.enabled = settings.audioEnabled;
  }

  /// Avvia una nuova partita da capo.
  void startGame() {
    applyAudioSettings();
    Tuning.apply(settings.difficulty);
    upgrades.applyToTuning(); // potenziamenti roguelite sopra la difficoltà
    _clearBeats();
    state.reset();
    state.practice = settings.practiceMode;
    state.lives = Tuning.startLives; // vite iniziali (difficoltà + potenziamenti)
    spawner.reset();
    overlays.remove(Overlays.menu);
    overlays.remove(Overlays.gameOver);
    overlays.remove(Overlays.pause);
    resumeEngine();
    audio.startBgm();
  }

  /// Torna al menu principale (dalla pausa o dal game over).
  void goToMenu() {
    _clearBeats();
    state.reset();
    spawner.reset();
    audio.stopBgm();
    overlays.remove(Overlays.gameOver);
    overlays.remove(Overlays.pause);
    overlays.add(Overlays.menu);
    pauseEngine();
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
    final Vector2? pos = _enemyPos(note);
    if (pos != null) _burst(pos, const Color(0xFFFF5252), big: true);
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

    _hitTarget(target);
  }

  /// Colpo a segno sul bersaglio. I nemici resistenti (corazzato/boss)
  /// richiedono più colpi: solo l'ultimo li distrugge.
  void _hitTarget(NoteData note) {
    final Judgment judgment = note.evaluate();
    final bool gem =
        judgment == Judgment.perfect || judgment == Judgment.good;

    note.judgment = judgment;
    note.hitsTaken += 1;
    state.registerHit(judgment, gem);
    wizard.cast(note.angle);
    _spawnSpellTo(note);

    final Vector2? pos = _enemyPos(note);
    if (note.hitsTaken >= note.hits) {
      note.state = BeatState.resolved; // distrutto
      activeTarget = null;
      if (pos != null) _burst(pos, note.color, big: true);
    } else if (pos != null) {
      _burst(pos, note.color, big: false); // colpo incassato (armatura)
    }
    // Altrimenti il nemico sopravvive e resta il bersaglio (armatura).
  }

  /// Posizione corrente del nemico associato a una nota (o null se assente).
  Vector2? _enemyPos(NoteData note) {
    for (final Enemy e in children.whereType<Enemy>()) {
      if (e.note == note) return e.position.clone();
    }
    return null;
  }

  /// Lancia una magia (cosmetica) dal mago verso il nemico della nota.
  void _spawnSpellTo(NoteData note) {
    final Vector2 targetPos = _enemyPos(note) ??
        wizard.homePosition + Vector2(cos(note.angle), sin(note.angle)) * 200;

    add(Spell(
      start: wizard.homePosition.clone(),
      target: targetPos,
      color: note.color,
    ));
  }

  /// Esplosione di particelle (saltata se "riduci animazioni" è attivo).
  void _burst(Vector2 pos, Color color, {required bool big}) {
    if (settings.reduceMotion) return;
    add(Burst(
      origin: pos,
      color: color,
      count: big ? 18 : 8,
      speed: big ? 150 : 90,
      maxLife: big ? 0.6 : 0.4,
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
