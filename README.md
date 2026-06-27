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
- L'**altezza/pitch** = **direzione** del nemico (360°) e **colore/elemento**.
  Le note coprono **2 ottave** sullo spartito (Do basso → La alto, con tagli
  addizionali), ma per colpire conta la **classe di nota, non l'ottava**: un
  `La` va bene sia alto che basso.
- **Si colpisce in ordine**: c'è sempre una sola **nota-bersaglio evidenziata**
  (la più vicina alla linea). La colpisci premendo la nota giusta **in qualsiasi
  momento** (il tempismo non è obbligatorio).
  - a tempo (**Perfect/Good**) → **+1 gemma**;
  - **5 gemme → +1 vita**;
  - nota-bersaglio che raggiunge la linea non suonata → **Miss**, perdi HP.
- A **0 HP**: se hai una vita, la consumi e continui; altrimenti **game over**.
- **Opzioni nel menu** (prima di giocare): **difficoltà** (Facile / Normale /
  Difficile — regola danno, ritmo, finestre per le gemme, vite iniziali e numero
  massimo di nemici), **tempo** (slider in BPM, 60–200), **etichette**
  (Solfège / Lettere / Nessuna) e **colori tastiera** (ON/OFF). La difficoltà
  cresce comunque nel tempo.

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

| Azione                | Tastiera fisica            | Mouse / Touch                  |
|-----------------------|----------------------------|--------------------------------|
| Tasti bianchi (naturali) | `A S D F G H J K`       | Clicca/tappa i tasti bianchi   |
| Tasti neri (diesis)   | `W E  T Y U`               | Clicca/tappa i tasti neri      |
| Pausa                 | `P` o `ESC`                | Pulsante in pausa              |
| Avvia / Riprova       | `Invio` o `Spazio`         | Pulsante a video               |

La tastiera è un'ottava (8 tasti bianchi + 5 neri) disposta come un pianoforte
vero. Conta la **classe di nota**, non l'ottava: `K` (Do²) e `A` (Do) suonano
la stessa nota. Ogni nemico mostra l'etichetta scelta nel menu (Do Re Mi… /
C D E… / nessuna).

Mappatura (stile piano da computer):

```
neri:    W   E       T   Y   U          (Do# Re# Fa# Sol# La#)
bianchi: A   S   D   F   G   H   J   K   (Do Re Mi Fa Sol La Si Do²)
```

---

## Audio

I suoni delle note sono **sintetizzati a runtime** (toni generati via codice,
uno per ciascuna delle 12 note): non serve alcun file e non c'è materiale
protetto da copyright. Partono al primo tasto/tocco (i browser richiedono un
gesto utente per l'audio). Per ora **non** c'è musica di sottofondo.

> Nota: i campioni di pianoforte CC0 in `assets/audio/` non sono più necessari;
> la cartella resta disponibile per un eventuale uso futuro.

---

## Pubblicazione web (GitHub Pages)

Il repo include un workflow GitHub Actions
([`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)) che, ad ogni
push sul branch di default, builda la web app e la pubblica su GitHub Pages.

**Setup una-tantum** (necessario perché il token delle Actions non può abilitare
Pages da solo):

1. Vai su **Settings → Pages** del repository.
2. In **Build and deployment → Source** scegli **GitHub Actions**.
3. Rilancia il workflow: tab **Actions → Deploy web su GitHub Pages → Run
   workflow** (oppure fai un nuovo push).

Al termine il gioco sarà online su:
`https://ianes1978.github.io/Battle-Hymn/`

> Il `base-href` nel workflow è impostato a `/Battle-Hymn/`; se rinomini il repo,
> aggiornalo di conseguenza.

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
