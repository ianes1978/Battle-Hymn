# Cartella audio

Il gioco funziona **senza audio** (i suoni sono opzionali e caricati in modo
"crash-free"): se i file non sono presenti, il gioco gira lo stesso in silenzio.

Per abilitare i suoni, inserisci qui i file con questi nomi esatti:

## Note di pianoforte (campioni)
Una nota per ogni semitono dell'ottava cromatica (13 file: 8 bianchi + 5 neri):

```
note_0.wav    # Do
note_1.wav    # Do#
note_2.wav    # Re
note_3.wav    # Re#
note_4.wav    # Mi
note_5.wav    # Fa
note_6.wav    # Fa#
note_7.wav    # Sol
note_8.wav    # Sol#
note_9.wav    # La
note_10.wav   # La#
note_11.wav   # Si
note_12.wav   # Do (ottava sopra)
```

Sono accettati anche `.mp3` / `.ogg`, ma aggiorna l'estensione in
`lib/systems/audio_manager.dart` (costante `noteExtension`).

## Musica di sottofondo (opzionale)
```
bgm.mp3      # loop di sottofondo
```

## Dove trovare campioni liberi
- Campioni di pianoforte CC0/Public Domain (es. progetti come "University of Iowa
  Electronic Music Studios", freesound.org con licenza CC0, ecc.).
- Assicurati che la licenza permetta l'uso e la ridistribuzione.

> NON inserire qui asset protetti da copyright.
