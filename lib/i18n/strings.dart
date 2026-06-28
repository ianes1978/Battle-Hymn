import 'dart:ui' as ui;

/// Lingue supportate dall'interfaccia.
enum Lang { en, it, es, fr, de, pt }

/// Localizzazione leggera dell'interfaccia.
///
/// La lingua viene rilevata dal sistema all'avvio ([detect]) tra quelle
/// supportate (inglese, italiano, spagnolo, francese, tedesco, portoghese);
/// in tutti gli altri casi si usa l'inglese. Tutte le stringhe visibili passano
/// da qui tramite semplici getter.
class L {
  L._();

  /// Lingua corrente (default: inglese).
  static Lang lang = Lang.en;

  /// Rileva la lingua di sistema. Va chiamata dopo l'init dei binding.
  static void detect() {
    final String code = ui.PlatformDispatcher.instance.locale.languageCode;
    lang = switch (code) {
      'it' => Lang.it,
      'es' => Lang.es,
      'fr' => Lang.fr,
      'de' => Lang.de,
      'pt' => Lang.pt,
      _ => Lang.en,
    };
  }

  /// Sceglie la traduzione per la lingua corrente; ripiega sull'inglese.
  static String _p(Map<Lang, String> m) => m[lang] ?? m[Lang.en]!;

  // --- Menu -----------------------------------------------------------------
  static String get tagline => 'rhythm bullet-heaven';

  static String get play => _p({
        Lang.en: 'PLAY',
        Lang.it: 'GIOCA',
        Lang.es: 'JUGAR',
        Lang.fr: 'JOUER',
        Lang.de: 'SPIELEN',
        Lang.pt: 'JOGAR',
      });

  static String get options => _p({
        Lang.en: 'OPTIONS',
        Lang.it: 'OPZIONI',
        Lang.es: 'OPCIONES',
        Lang.fr: 'OPTIONS',
        Lang.de: 'OPTIONEN',
        Lang.pt: 'OPÇÕES',
      });

  static String get upgrades => _p({
        Lang.en: 'UPGRADES',
        Lang.it: 'POTENZIAMENTI',
        Lang.es: 'MEJORAS',
        Lang.fr: 'AMÉLIORATIONS',
        Lang.de: 'VERBESSERUNGEN',
        Lang.pt: 'MELHORIAS',
      });

  static String get record => _p({
        Lang.en: 'Best',
        Lang.it: 'Record',
        Lang.es: 'Récord',
        Lang.fr: 'Record',
        Lang.de: 'Bestwert',
        Lang.pt: 'Recorde',
      });

  static String get menuHint => _p({
        Lang.en: 'Hit the HIGHLIGHTED note by pressing the right key.\n'
            'The note matters, not the octave. On beat = gem; 5 gems = +1 life.',
        Lang.it: 'Colpisci la nota EVIDENZIATA premendo il tasto giusto.\n'
            'Conta la nota, non l\'ottava. A tempo = gemma; 5 gemme = +1 vita.',
        Lang.es: 'Toca la nota RESALTADA pulsando la tecla correcta.\n'
            'Importa la nota, no la octava. A tiempo = gema; 5 gemas = +1 vida.',
        Lang.fr: 'Touche la note SURLIGNÉE avec la bonne touche.\n'
            'C\'est la note qui compte, pas l\'octave. Dans le rythme = gemme ; '
            '5 gemmes = +1 vie.',
        Lang.de: 'Triff die HERVORGEHOBENE Note mit der richtigen Taste.\n'
            'Die Note zählt, nicht die Oktave. Im Takt = Edelstein; '
            '5 Edelsteine = +1 Leben.',
        Lang.pt: 'Acerte a nota DESTACADA pressionando a tecla certa.\n'
            'Importa a nota, não a oitava. No tempo = gema; 5 gemas = +1 vida.',
      });

  // --- Opzioni --------------------------------------------------------------
  static String get optionsTitle => options;

  static String get difficulty => _p({
        Lang.en: 'Difficulty',
        Lang.it: 'Difficoltà',
        Lang.es: 'Dificultad',
        Lang.fr: 'Difficulté',
        Lang.de: 'Schwierigkeit',
        Lang.pt: 'Dificuldade',
      });

  static String get easy => _p({
        Lang.en: 'Easy',
        Lang.it: 'Facile',
        Lang.es: 'Fácil',
        Lang.fr: 'Facile',
        Lang.de: 'Leicht',
        Lang.pt: 'Fácil',
      });

  static String get normal => _p({
        Lang.en: 'Normal',
        Lang.it: 'Normale',
        Lang.es: 'Normal',
        Lang.fr: 'Normal',
        Lang.de: 'Normal',
        Lang.pt: 'Normal',
      });

  static String get hard => _p({
        Lang.en: 'Hard',
        Lang.it: 'Difficile',
        Lang.es: 'Difícil',
        Lang.fr: 'Difficile',
        Lang.de: 'Schwer',
        Lang.pt: 'Difícil',
      });

  static String get diffHintEasy => _p({
        Lang.en: 'Basic enemies only',
        Lang.it: 'Solo nemici base',
        Lang.es: 'Solo enemigos básicos',
        Lang.fr: 'Ennemis de base seulement',
        Lang.de: 'Nur Standardgegner',
        Lang.pt: 'Apenas inimigos básicos',
      });

  static String get diffHintNormal => _p({
        Lang.en: '+ fast & armored',
        Lang.it: '+ veloci e corazzati',
        Lang.es: '+ rápidos y blindados',
        Lang.fr: '+ rapides et blindés',
        Lang.de: '+ schnelle & gepanzerte',
        Lang.pt: '+ rápidos e blindados',
      });

  static String get diffHintHard => _p({
        Lang.en: '+ mini-bosses (all)',
        Lang.it: '+ mini-boss (tutto)',
        Lang.es: '+ mini-jefes (todo)',
        Lang.fr: '+ mini-boss (tout)',
        Lang.de: '+ Mini-Bosse (alles)',
        Lang.pt: '+ mini-chefes (tudo)',
      });

  static String tempo(int bpm) => 'Tempo: $bpm BPM';

  static String get labels => _p({
        Lang.en: 'Labels',
        Lang.it: 'Etichette',
        Lang.es: 'Etiquetas',
        Lang.fr: 'Étiquettes',
        Lang.de: 'Beschriftungen',
        Lang.pt: 'Rótulos',
      });

  static String get labelsNone => _p({
        Lang.en: 'None',
        Lang.it: 'Nessuna',
        Lang.es: 'Ninguna',
        Lang.fr: 'Aucune',
        Lang.de: 'Keine',
        Lang.pt: 'Nenhum',
      });

  static String get keyboardColors => _p({
        Lang.en: 'Keyboard colors',
        Lang.it: 'Colori tastiera',
        Lang.es: 'Colores del teclado',
        Lang.fr: 'Couleurs du clavier',
        Lang.de: 'Tastaturfarben',
        Lang.pt: 'Cores do teclado',
      });

  static String get on => 'ON';
  static String get off => 'OFF';
  static String get audio => 'AUDIO';

  static String get sound => _p({
        Lang.en: 'Sound',
        Lang.it: 'Suono',
        Lang.es: 'Sonido',
        Lang.fr: 'Son',
        Lang.de: 'Ton',
        Lang.pt: 'Som',
      });

  static String volume(int pct) {
    final String w = _p({
      Lang.en: 'Volume',
      Lang.it: 'Volume',
      Lang.es: 'Volumen',
      Lang.fr: 'Volume',
      Lang.de: 'Lautstärke',
      Lang.pt: 'Volume',
    });
    return '$w: $pct%';
  }

  static String get back => _p({
        Lang.en: 'BACK',
        Lang.it: 'INDIETRO',
        Lang.es: 'ATRÁS',
        Lang.fr: 'RETOUR',
        Lang.de: 'ZURÜCK',
        Lang.pt: 'VOLTAR',
      });

  // --- Pausa ----------------------------------------------------------------
  static String get paused => _p({
        Lang.en: 'PAUSED',
        Lang.it: 'PAUSA',
        Lang.es: 'PAUSA',
        Lang.fr: 'PAUSE',
        Lang.de: 'PAUSE',
        Lang.pt: 'PAUSA',
      });

  static String get resume => _p({
        Lang.en: 'RESUME',
        Lang.it: 'RIPRENDI',
        Lang.es: 'REANUDAR',
        Lang.fr: 'REPRENDRE',
        Lang.de: 'FORTSETZEN',
        Lang.pt: 'CONTINUAR',
      });

  static String get restart => _p({
        Lang.en: 'Restart',
        Lang.it: 'Ricomincia',
        Lang.es: 'Reiniciar',
        Lang.fr: 'Recommencer',
        Lang.de: 'Neustart',
        Lang.pt: 'Reiniciar',
      });

  static String get mainMenu => _p({
        Lang.en: 'Main menu',
        Lang.it: 'Menu principale',
        Lang.es: 'Menú principal',
        Lang.fr: 'Menu principal',
        Lang.de: 'Hauptmenü',
        Lang.pt: 'Menu principal',
      });

  // --- Game over ------------------------------------------------------------
  static String get gameOver => 'GAME OVER';

  static String get score => _p({
        Lang.en: 'Score',
        Lang.it: 'Punteggio',
        Lang.es: 'Puntuación',
        Lang.fr: 'Score',
        Lang.de: 'Punkte',
        Lang.pt: 'Pontuação',
      });

  static String get accuracy => _p({
        Lang.en: 'Accuracy',
        Lang.it: 'Accuratezza',
        Lang.es: 'Precisión',
        Lang.fr: 'Précision',
        Lang.de: 'Genauigkeit',
        Lang.pt: 'Precisão',
      });

  static String get bestCombo => _p({
        Lang.en: 'Best combo',
        Lang.it: 'Combo migliore',
        Lang.es: 'Mejor combo',
        Lang.fr: 'Meilleur combo',
        Lang.de: 'Bester Combo',
        Lang.pt: 'Melhor combo',
      });

  static String get survived => _p({
        Lang.en: 'Survived',
        Lang.it: 'Sopravvissuto',
        Lang.es: 'Sobrevivido',
        Lang.fr: 'Survie',
        Lang.de: 'Überlebt',
        Lang.pt: 'Sobreviveu',
      });

  static String get newRecord => _p({
        Lang.en: 'NEW RECORD!',
        Lang.it: 'NUOVO RECORD!',
        Lang.es: '¡NUEVO RÉCORD!',
        Lang.fr: 'NOUVEAU RECORD !',
        Lang.de: 'NEUER REKORD!',
        Lang.pt: 'NOVO RECORDE!',
      });

  static String crystalsEarned(int n) => _p({
        Lang.en: '+$n crystals',
        Lang.it: '+$n cristalli',
        Lang.es: '+$n cristales',
        Lang.fr: '+$n cristaux',
        Lang.de: '+$n Kristalle',
        Lang.pt: '+$n cristais',
      });

  static String get retry => _p({
        Lang.en: 'RETRY',
        Lang.it: 'RIPROVA',
        Lang.es: 'REINTENTAR',
        Lang.fr: 'RÉESSAYER',
        Lang.de: 'NOCHMAL',
        Lang.pt: 'TENTAR DE NOVO',
      });

  // --- Potenziamenti --------------------------------------------------------
  static String get upgradesTitle => upgrades;

  static String crystals(int n) => _p({
        Lang.en: '$n crystals',
        Lang.it: '$n cristalli',
        Lang.es: '$n cristales',
        Lang.fr: '$n cristaux',
        Lang.de: '$n Kristalle',
        Lang.pt: '$n cristais',
      });

  static String get max => 'MAX';

  static String get upLifeTitle => _p({
        Lang.en: 'Starting life',
        Lang.it: 'Vita iniziale',
        Lang.es: 'Vida inicial',
        Lang.fr: 'Vie de départ',
        Lang.de: 'Startleben',
        Lang.pt: 'Vida inicial',
      });

  static String get upLifeDesc => _p({
        Lang.en: '+1 starting life',
        Lang.it: '+1 vita iniziale',
        Lang.es: '+1 vida inicial',
        Lang.fr: '+1 vie de départ',
        Lang.de: '+1 Startleben',
        Lang.pt: '+1 vida inicial',
      });

  static String get upSlowTitle => _p({
        Lang.en: 'Slower notes',
        Lang.it: 'Note più lente',
        Lang.es: 'Notas más lentas',
        Lang.fr: 'Notes plus lentes',
        Lang.de: 'Langsamere Noten',
        Lang.pt: 'Notas mais lentas',
      });

  static String get upSlowDesc => _p({
        Lang.en: 'Notes 8% slower',
        Lang.it: 'Note +8% più lente',
        Lang.es: 'Notas 8% más lentas',
        Lang.fr: 'Notes 8% plus lentes',
        Lang.de: 'Noten 8% langsamer',
        Lang.pt: 'Notas 8% mais lentas',
      });

  static String get upShieldTitle => _p({
        Lang.en: 'Shield',
        Lang.it: 'Scudo',
        Lang.es: 'Escudo',
        Lang.fr: 'Bouclier',
        Lang.de: 'Schild',
        Lang.pt: 'Escudo',
      });

  static String get upShieldDesc => _p({
        Lang.en: '-15% miss damage',
        Lang.it: '-15% danno da miss',
        Lang.es: '-15% daño por fallo',
        Lang.fr: '-15% dégâts de raté',
        Lang.de: '-15% Schaden bei Fehler',
        Lang.pt: '-15% dano por erro',
      });

  static String get upLuckTitle => _p({
        Lang.en: 'Gem luck',
        Lang.it: 'Fortuna gemme',
        Lang.es: 'Suerte de gemas',
        Lang.fr: 'Chance de gemmes',
        Lang.de: 'Edelstein-Glück',
        Lang.pt: 'Sorte de gemas',
      });

  static String get upLuckDesc => _p({
        Lang.en: 'Wider gem windows',
        Lang.it: 'Finestre gemma più larghe',
        Lang.es: 'Ventanas de gema más amplias',
        Lang.fr: 'Fenêtres de gemme plus larges',
        Lang.de: 'Größere Edelstein-Fenster',
        Lang.pt: 'Janelas de gema mais amplas',
      });

  // --- HUD ------------------------------------------------------------------
  static String get scoreLabel => _p({
        Lang.en: 'SCORE',
        Lang.it: 'PUNTEGGIO',
        Lang.es: 'PUNTOS',
        Lang.fr: 'SCORE',
        Lang.de: 'PUNKTE',
        Lang.pt: 'PONTOS',
      });

  static String get combo => 'COMBO';

  static String get perfect => _p({
        Lang.en: 'PERFECT  +GEM',
        Lang.it: 'PERFECT  +GEMMA',
        Lang.es: 'PERFECT  +GEMA',
        Lang.fr: 'PARFAIT  +GEMME',
        Lang.de: 'PERFEKT  +EDELSTEIN',
        Lang.pt: 'PERFEITO  +GEMA',
      });

  static String get good => _p({
        Lang.en: 'GOOD  +GEM',
        Lang.it: 'GOOD  +GEMMA',
        Lang.es: 'BIEN  +GEMA',
        Lang.fr: 'BIEN  +GEMME',
        Lang.de: 'GUT  +EDELSTEIN',
        Lang.pt: 'BOM  +GEMA',
      });

  static String get ok => 'OK';
  static String get miss => 'MISS';

  // --- Caffè (mancia in-app) ------------------------------------------------
  static String get coffee => _p({
        Lang.en: 'Buy me a coffee',
        Lang.it: 'Offrimi un caffè',
        Lang.es: 'Invítame a un café',
        Lang.fr: 'Offre-moi un café',
        Lang.de: 'Spendier mir einen Kaffee',
        Lang.pt: 'Pague-me um café',
      });

  static String get coffeeThanks => _p({
        Lang.en: 'Thanks for the coffee! ☕',
        Lang.it: 'Grazie per il caffè! ☕',
        Lang.es: '¡Gracias por el café! ☕',
        Lang.fr: 'Merci pour le café ! ☕',
        Lang.de: 'Danke für den Kaffee! ☕',
        Lang.pt: 'Obrigado pelo café! ☕',
      });

  static String get coffeePending => _p({
        Lang.en: 'Processing…',
        Lang.it: 'In elaborazione…',
        Lang.es: 'Procesando…',
        Lang.fr: 'Traitement…',
        Lang.de: 'Wird verarbeitet…',
        Lang.pt: 'Processando…',
      });

  static String get coffeeError => _p({
        Lang.en: 'Purchase not available right now.',
        Lang.it: 'Acquisto non disponibile al momento.',
        Lang.es: 'Compra no disponible ahora.',
        Lang.fr: 'Achat indisponible pour le moment.',
        Lang.de: 'Kauf derzeit nicht verfügbar.',
        Lang.pt: 'Compra indisponível no momento.',
      });

  // --- Banner ---------------------------------------------------------------
  static String get lifeGained => _p({
        Lang.en: '+1 LIFE!',
        Lang.it: '+1 VITA!',
        Lang.es: '+1 VIDA!',
        Lang.fr: '+1 VIE !',
        Lang.de: '+1 LEBEN!',
        Lang.pt: '+1 VIDA!',
      });

  static String get lifeLost => _p({
        Lang.en: 'LIFE LOST',
        Lang.it: 'VITA PERSA',
        Lang.es: 'VIDA PERDIDA',
        Lang.fr: 'VIE PERDUE',
        Lang.de: 'LEBEN VERLOREN',
        Lang.pt: 'VIDA PERDIDA',
      });
}
