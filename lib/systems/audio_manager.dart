/// Seleziona l'implementazione audio in base alla piattaforma:
/// - Web  → Web Audio API del browser (audio_manager_web.dart)
/// - Altro → audioplayers (audio_manager_io.dart)
///
/// Entrambe espongono la stessa classe [AudioManager].
export 'audio_manager_io.dart'
    if (dart.library.js_interop) 'audio_manager_web.dart';
