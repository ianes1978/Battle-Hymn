# Guida alla pubblicazione su Google Play — Battle Hymn

Checklist passo-passo, in ordine. Spunta man mano. I dettagli tecnici stanno
anche in [`README.md`](README.md) e i testi in [`STORE.md`](STORE.md); qui trovi
tutto in sequenza, senza saltare tra i file.

Dati dell'app:
- **Nome**: Battle Hymn
- **applicationId**: `com.ianes.battlehymn`
- **Prodotto in-app (mancia)**: `coffee_tip` — consumabile, **1,18 €**
- **Privacy URL**: `https://ianes1978.github.io/Battle-Hymn/privacy.html`

---

## 0. Prerequisiti (una volta sola)

- [ ] **Account Google Play Developer** attivo (iscrizione una tantum ~25 $):
      https://play.google.com/console/signup
- [ ] **JDK installata** sul tuo PC (per il comando `keytool`). Verifica con
      `keytool -help` nel terminale. Se manca, installa Temurin/Adoptium JDK 17.

---

## 1. Crea il keystore di firma (sul TUO PC)

⚠️ La chiave è tua e va **conservata per sempre**: se la perdi non potrai più
aggiornare l'app. NON va mai messa nel repository.

- [ ] Esegui:
      ```bash
      keytool -genkey -v -keystore battlehymn-upload.jks \
        -keyalg RSA -keysize 2048 -validity 10000 -alias upload
      ```
- [ ] Annota in un posto sicuro: **password dello store**, **password della
      chiave**, **alias** (`upload`).
- [ ] Custodisci il file `battlehymn-upload.jks` (es. password manager / backup).

---

## 2. Converti il keystore in base64

- [ ] Linux:  `base64 -w0 battlehymn-upload.jks > keystore.b64`
      macOS:  `base64 -i battlehymn-upload.jks -o keystore.b64`
- [ ] Apri `keystore.b64` e copia tutto il contenuto (serve al passo 3).

---

## 3. Aggiungi i GitHub Secrets

Repo su GitHub → **Settings → Secrets and variables → Actions → New repository
secret**. Crea questi 4 segreti:

- [ ] `ANDROID_KEYSTORE_BASE64` → contenuto di `keystore.b64`
- [ ] `ANDROID_KEYSTORE_PASSWORD` → password dello store
- [ ] `ANDROID_KEY_ALIAS` → `upload`
- [ ] `ANDROID_KEY_PASSWORD` → password della chiave

---

## 4. Genera l'App Bundle firmato (.aab)

- [ ] GitHub → tab **Actions → Build AAB (Play Store) → Run workflow**
- [ ] Al termine scarica l'artifact **`battle-hymn-aab`** → contiene
      `app-release.aab`.

> Il workflow usa i Secret per firmare; la chiave non resta da nessuna parte
> sul server (i file sensibili vengono cancellati a fine job).

---

## 5. Crea l'app nella Play Console

- [ ] Play Console → **Crea app**.
- [ ] Nome app: **Battle Hymn**; lingua predefinita: **Inglese (Stati Uniti)**;
      tipo: **Gioco**; gratuita: **Sì**.
- [ ] Accetta le dichiarazioni richieste.

---

## 6. Carica l'AAB in test interno

Il billing funziona SOLO su build distribuite da Play: parti dal test interno.

- [ ] **Test → Test interno → Crea release**.
- [ ] Carica `app-release.aab` (dal passo 4).
- [ ] Aggiungi te stesso come **tester** (crea un elenco email e includi il tuo
      account Google).
- [ ] Salva e **pubblica nella traccia di test interno**.

---

## 7. Crea il prodotto in-app "caffè"

- [ ] **Monetizza → Prodotti → Prodotti in-app → Crea prodotto**.
- [ ] **ID prodotto**: `coffee_tip` (deve combaciare esattamente col codice).
- [ ] Tipo: **consumabile**; nome: es. "Caffè"; prezzo: **1,18 €**.
- [ ] Stato: **Attivo**.

> Promemoria prezzo: 1,18 € = `1,00 ÷ 0,85`, così dopo la commissione del 15%
> incassi ~1 € netto. (Nell'UE il prezzo è IVA inclusa: il payout reale può
> essere leggermente inferiore secondo il Paese dell'acquirente.)

---

## 8. Compila la scheda dello Store

- [ ] **Cresci → Presenza sullo Store → Scheda principale dello Store**.
- [ ] Incolla **nome / descrizione breve / descrizione completa** da
      [`STORE.md`](STORE.md). Imposta inglese come predefinita e aggiungi le
      traduzioni **IT, ES, FR, DE, PT**.
- [ ] Grafica:
  - [ ] **Icona** 512×512 (in `build/app/.../res` o rigenerabile da
        `flutter_launcher_icons`)
  - [ ] **Feature graphic** 1024×500 → [`store/feature_graphic.png`](store/feature_graphic.png)
  - [ ] **Screenshot telefono** (almeno 2, consigliati 4–6, verticali) → vedi
        passo 9
- [ ] Categoria: **Giochi → Musica** (o Arcade); tag: rhythm, music, arcade.
- [ ] Email di contatto: roberto.ianes.78@gmail.com

---

## 9. Cattura gli screenshot

Apri il gioco (telefono dal test interno, oppure la web app) e cattura in
**verticale**:

- [ ] Menu iniziale (logo + pulsanti)
- [ ] Partita in corso (spartito con note + nemici + mago)
- [ ] Momento d'azione (combo/giudizio "PERFECT")
- [ ] Schermata Potenziamenti
- [ ] Game over con voto (S/A/B)

> Gli screenshot del **telefono** sono i migliori per lo Store. Bastano
> 1080×1920 (o la risoluzione nativa del tuo telefono).

---

## 10. Privacy, Data safety e classificazione

- [ ] **Privacy policy URL**:
      `https://ianes1978.github.io/Battle-Hymn/privacy.html`
- [ ] **Data safety**: dichiara **nessun dato raccolto/condiviso**; segnala
      l'acquisto in-app facoltativo (pagamento gestito da Google).
- [ ] **Classificazione contenuti**: compila il questionario **IARC** (nessun
      contenuto sensibile → fascia per tutti).
- [ ] **Pubblico di destinazione**: imposta le fasce d'età come preferisci.

---

## 11. Prova l'acquisto del caffè (test interno)

- [ ] Installa l'app dal **link di test interno** (non l'APK a mano!).
- [ ] In gioco deve comparire il pulsante **☕ Offrimi un caffè (1,18 €)**.
- [ ] Completa un acquisto di prova: come tester di licenza non ti viene
      addebitato nulla. Verifica il messaggio "Grazie per il caffè! ☕".

> Se il pulsante non compare: il prodotto `coffee_tip` non è ancora **attivo**,
> oppure stai usando una build non scaricata da Play.

---

## 12. Pubblica in produzione

- [ ] Quando tutto è a posto: **Produzione → Crea nuova release** → carica lo
      stesso `app-release.aab`.
- [ ] Compila le **note di rilascio**.
- [ ] **Invia per la revisione**. La prima revisione può richiedere alcuni
      giorni.

---

## Aggiornamenti futuri

Per ogni nuova versione:
1. Aumenta il **versionCode** (e il versionName) in `pubspec.yaml`
   (es. `version: 0.1.1+2`).
2. Rilancia **Build AAB (Play Store)**.
3. Carica il nuovo `.aab` in una release (test → produzione).

> Usa SEMPRE lo stesso keystore del passo 1: è ciò che identifica la tua app
> agli occhi di Google.
