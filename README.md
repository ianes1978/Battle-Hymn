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
  massimo di nemici), **tempo** (slider in BPM, 30–200), **etichette**
  (Solfège / Lettere / Nessuna) e **colori tastiera** (ON/OFF). La difficoltà
  cresce comunque nel tempo.

---

## Lingua

L'interfaccia è **multilingua** e segue automaticamente la lingua del
dispositivo. Lingue supportate: **inglese, italiano, spagnolo, francese,
tedesco, portoghese**; per qualsiasi altra lingua si usa l'**inglese**. Le
stringhe sono in [`lib/i18n/strings.dart`](lib/i18n/strings.dart).

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

Tutto l'audio è **sintetizzato a runtime** (nessun file, nessun copyright):
- i **suoni delle note** (uno per ciascuna delle 12 classi);
- una **base ritmica** (kick + hi-hat) scandita sul BPM scelto;
- le note seguono una **melodia in tonalità** (Do maggiore) e arrivano **a
  tempo** sulla linea, con un **crescendo** che aggiunge l'hi-hat al salire
  della combo.

Parte al primo tasto/tocco (i browser richiedono un gesto utente per l'audio).

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

## Pubblicazione Android (APK / Play Store)

L'app è configurata con `applicationId = com.ianes.battlehymn` e nome
**Battle Hymn** (vedi [`tool/configure_android.sh`](tool/configure_android.sh)).

### APK di prova (subito, senza firma di rilascio)

Il workflow [`.github/workflows/android.yml`](.github/workflows/android.yml)
builda un **APK** ad ogni push e lo pubblica come artifact (e come Release
`v0.1.0`). Va bene per installarlo a mano sul telefono, **non** per il Play
Store.

### AAB firmato per il Play Store

Google Play richiede un **Android App Bundle (`.aab`) firmato** con la *tua*
chiave. Il workflow [`.github/workflows/release.yml`](.github/workflows/release.yml)
lo produce. La chiave di firma **resta solo tua**: non è mai nel repository,
viene letta dai *GitHub Secrets*.

**1. Crea il keystore** (una volta sola, sul tuo PC con la JDK installata):

```bash
keytool -genkey -v -keystore battlehymn-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Conserva il file `battlehymn-upload.jks` e le password **in un posto sicuro**:
se le perdi non potrai più aggiornare l'app sul Play Store.

**2. Converti il keystore in base64** (per incollarlo come segreto):

```bash
base64 -w0 battlehymn-upload.jks > keystore.b64   # Linux
# macOS:  base64 -i battlehymn-upload.jks -o keystore.b64
```

**3. Aggiungi i GitHub Secrets** (Settings → Secrets and variables → Actions →
*New repository secret*):

| Nome del segreto            | Valore                                   |
|-----------------------------|------------------------------------------|
| `ANDROID_KEYSTORE_BASE64`   | il contenuto di `keystore.b64`           |
| `ANDROID_KEYSTORE_PASSWORD` | la password dello *store*                |
| `ANDROID_KEY_ALIAS`         | `upload` (o l'alias scelto)              |
| `ANDROID_KEY_PASSWORD`      | la password della *chiave*               |

**4. Genera l'AAB**: tab **Actions → Build AAB (Play Store) → Run workflow**.
Al termine scarica l'artifact `battle-hymn-aab` (`app-release.aab`).

**5. Carica su Google Play**: nella
[Play Console](https://play.google.com/console) crea l'app, compila la scheda
e in *Produzione → Crea nuova release* carica `app-release.aab`.

> Suggerimento: con **Play App Signing** (consigliato da Google) la chiave qui
> sopra è la tua chiave di *upload*; Google gestisce la chiave finale di firma.

### Acquisto in-app "Offrimi un caffè" (mancia)

Il gioco è **gratuito**. C'è un pulsante facoltativo **☕ Offrimi un caffè** che
avvia un acquisto in-app (mancia) tramite **Google Play Billing**: non sblocca
nulla, supporta solo lo sviluppo. È un prodotto **consumabile**, quindi può
essere ripetuto. Sul web il pulsante è nascosto (lì il billing non esiste).

Per attivarlo devi creare il prodotto nella Play Console:

1. Play Console → la tua app → **Monetizza → Prodotti → Prodotti in-app →
   Crea prodotto**.
2. **ID prodotto**: `coffee_tip` (deve combaciare con
   `IapManager.coffeeProductId` in
   [`lib/systems/iap_manager.dart`](lib/systems/iap_manager.dart)).
3. Tipo **consumabile**, nome (es. "Caffè"), prezzo **1,18 €**, stato
   **attivo**.
   - Perché 1,18 € e non 1,15 €: la commissione Google (15% nel programma per
     piccoli sviluppatori) si calcola **sul prezzo di vendita**. Per incassare
     **netto ~1,00 €** serve `1,00 ÷ 0,85 = 1,18 €` (su 1,18 € Google trattiene
     ~0,18 €). Con 1,15 € incasseresti solo ~0,98 €.
   - Nota IVA: nell'UE il prezzo mostrato è IVA inclusa e Google versa l'IVA per
     tuo conto, quindi il payout reale può essere leggermente inferiore a seconda
     del Paese dell'acquirente.
4. Pubblica l'app almeno in **test interno**: il billing funziona solo su build
   firmate scaricate da Google Play (non sull'APK installato a mano). Aggiungi
   il tuo account come tester.

Finché il prodotto non è attivo e l'app non è distribuita da Play, il pulsante
resta nascosto automaticamente (billing non disponibile).

> Nota policy: trattandosi di un acquisto in-app gestito da Google Play, è
> conforme alle regole dello Store. Dichiara l'acquisto facoltativo nel form
> *Data safety* (il pagamento è gestito da Google).

### Materiali per la scheda Play Store (checklist)

- **Informativa privacy**: [`PRIVACY.md`](PRIVACY.md) — pubblicala a un URL
  (es. GitHub Pages) e incolla il link nella Play Console. Il gioco **non
  raccoglie dati personali**.
- **Icona** 512×512 (generata da [`flutter_launcher_icons`]).
- **Feature graphic** 1024×500.
- **Screenshot** del telefono (almeno 2, in verticale).
- **Descrizione** breve e lunga, categoria (Giochi → Musica/Arcade),
  classificazione contenuti (questionario IARC), Paese e prezzo.
- **Data safety form**: dichiara "nessun dato raccolto/condiviso".

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
