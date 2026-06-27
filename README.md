# Battle Hymn 🎹⚔️

Un **rhythm bullet-heaven** scritto in **Flutter** con il motore di gioco
**Flame**: un mago fisso al centro-basso dello schermo si difende da nemici che
arrivano da ogni direzione. Sopra di lui scorre uno **spartito**; ogni nota in
arrivo è un nemico. Suona la nota giusta al momento giusto sulla **tastiera di
pianoforte** e il mago lancia una magia che lo distrugge.

> Stato: **Fase 1 — MVP giocabile**. Vedi [Roadmap](#roadmap).

---

## Come funziona (design)

- Ogni **nota** sullo spartito ↔ un **nemico** sul campo (stesso `NoteData`).
- La **posizione orizzontale** della nota = **distanza** del nemico dal mago.
  Nota lontana = nemico lontano; nota sulla linea = nemico che sta per colpire.
- L'**altezza/pitch** della nota = **direzione** da cui arriva il nemico (settore
  a 360°) e **colore/elemento** della magia.
- Premi il tasto corretto **mentre la nota è vicino alla linea di esecuzione**:
  - tempismo ottimo → **Perfect** (più punti);
  - tempismo buono → **Good**;
  - nota non suonata che raggiunge la linea → **Miss**, il mago perde HP.
- A **0 HP** → game over. La difficoltà cresce nel tempo (nemici più frequenti
  e più veloci).

---

## Requisiti

- [Flutter](https://docs.flutter.dev/get-started/install) (ultima stabile) con
  Dart `>=3.3`.
- Per il desktop, abilita la piattaforma desiderata:
  ```bash
  flutter config --enable-linux-desktop   # oppure --enable-macos-desktop / --enable-windows-desktop
  flutter config --enable-web
  ```

## Installazione

Questo repository contiene il codice del gioco (`lib/`, `pubspec.yaml`,
`assets/`) ma **non** le cartelle di piattaforma (`linux/`, `web/`, ecc.), che
sono rigenerabili. Generale e scarica le dipendenze:

```bash
# 1) Genera le cartelle di piattaforma mancanti (non tocca lib/ né pubspec.yaml)
flutter create .

# 2) Scarica le dipendenze
flutter pub get
```

## Avvio

Scegli un target:

```bash
# Web (browser)
flutter run -d chrome

# Linux desktop
flutter run -d linux

# macOS desktop
flutter run -d macos

# Windows desktop
flutter run -d windows
```

Per vedere i dispositivi disponibili: `flutter devices`.

---

## Controlli

| Azione            | Tastiera fisica            | Mouse / Touch                |
|-------------------|----------------------------|------------------------------|
| Suona Do…Do²      | `A S D F G H J K`          | Clicca/tappa i tasti a video |
| Pausa             | `P` o `ESC`                | Pulsante in pausa            |
| Avvia / Riprova   | `Invio` o `Spazio`         | Pulsante a video             |

Mappatura note: `A=Do  S=Re  D=Mi  F=Fa  G=Sol  H=La  J=Si  K=Do²`.

---

## Audio (opzionale)

Il gioco gira **anche senza audio**: i suoni vengono caricati in modo
crash-free e, se i file mancano, restano semplicemente disattivati.

Per abilitarli, metti i campioni in `assets/audio/` con i nomi indicati nel
[README della cartella](assets/audio/README.md):
`note_0.wav` … `note_7.wav` (le note) e, opzionalmente, `bgm.mp3` (musica).

> Usa solo asset liberi (CC0 / Public Domain) o creati da te.

---

## Struttura del progetto

```
lib/
├── main.dart                  # entrypoint + GameWidget + overlay
├── game/
│   ├── battle_hymn_game.dart  # FlameGame: orchestrazione, input, scoring
│   ├── config.dart            # costanti, scala, timing, layout, colori
│   ├── game_state.dart        # HP, punteggio, combo, timer
│   └── note_data.dart         # modello dati nota/nemico
├── components/                # rendering & comportamento (Flame)
│   ├── background.dart  staff.dart  wizard.dart
│   ├── enemy.dart  note_component.dart  spell.dart
│   ├── piano_keyboard.dart  hud.dart
├── systems/
│   ├── spawner.dart           # spawn + curva di difficoltà
│   └── audio_manager.dart     # audio opzionale crash-free
├── input/
│   └── key_mapping.dart       # tastiera fisica → pitch
└── ui/                        # overlay Flutter (menu, pausa, game over)
```

Architettura: logica di gioco (`game/`, `systems/`), rendering/comportamento
(`components/`) e input (`input/`) sono separati. Il game loop usa `update(dt)`
di Flame, quindi è **indipendente dal frame rate**.

---

## Roadmap

- [x] **Fase 1 — MVP**: mago fisso, spartito che scorre, nemici a 360°, sparo su
      nota corretta, HP, punteggio, combo, giudizi, game over, difficoltà
      crescente, tastiera fisica + on-screen, pausa/restart.
- [ ] **Fase 2 — Feel & ritmo**: campioni reali, BGM sincronizzata, più
      particelle e screen shake.
- [ ] **Fase 3 — Varietà**: tipi di nemici, magie per elemento, ondate/boss.
- [ ] **Fase 4 — Roguelite**: potenziamenti tra un run e l'altro.

---

## Licenza

Codice fornito a scopo dimostrativo/educativo. Nessun asset protetto da
copyright incluso: forme generate a runtime e suoni da aggiungere a parte.
