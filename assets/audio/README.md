# Cartella audio

Il gioco funziona **senza audio** (i suoni sono opzionali e caricati in modo
"crash-free"): se i file non sono presenti, il gioco gira lo stesso in silenzio.

Per abilitare i suoni, inserisci qui i file con questi nomi esatti:

## Note di pianoforte (campioni)
Una nota per ogni grado della scala (Do, Re, Mi, Fa, Sol, La, Si, Do²):

```
note_0.wav   # Do
note_1.wav   # Re
note_2.wav   # Mi
note_3.wav   # Fa
note_4.wav   # Sol
note_5.wav   # La
note_6.wav   # Si
note_7.wav   # Do (ottava sopra)
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
