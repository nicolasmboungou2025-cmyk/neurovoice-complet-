import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/user_settings.dart';
import 'vosk_service.dart';

/// Service hybride :
///   1. Vosk (hors ligne) si modèle disponible
///   2. SpeechToText Google/Apple (online) comme fallback
class HybridSpeechService {
  final VoskService _vosk = VoskService();
  final SpeechToText _stt = SpeechToText();

  bool _voskReady = false;
  bool _sttReady  = false;
  bool _isListening = false;
  String _mode = 'none'; // 'vosk' | 'stt' | 'none'

  bool get isListening => _isListening;
  String get mode => _mode;

  // ── Init ──────────────────────────────────────────
  Future<void> init(UserSettings settings) async {
    // 1. Essayer Vosk (hors ligne)
    if (settings.language != 'ln-CD') {
      _voskReady = await _vosk.init(settings.language);
    }

    // 2. Toujours initialiser le fallback online
    _sttReady = await _stt.initialize(
      onError: (_) => _isListening = false,
    );

    _mode = _voskReady ? 'vosk' : (_sttReady ? 'stt' : 'none');
  }

  // ── Vérifier la connexion ─────────────────────────
  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ── Écoute ────────────────────────────────────────
  Future<void> startListening({
    required String locale,
    required void Function(String words) onResult,
    required void Function() onDone,
  }) async {
    if (_isListening) return;
    _isListening = true;

    // Priorité 1 : Vosk hors ligne
    if (_voskReady) {
      _mode = 'vosk';
      await _vosk.startListening(
        onResult: (words) {
          _isListening = false;
          onResult(words);
        },
        onDone: () {
          if (_isListening) {
            _isListening = false;
            onDone();
          }
        },
      );
      return;
    }

    // Priorité 2 : STT online (si internet disponible)
    if (_sttReady) {
      final online = await _hasInternet();
      if (!online) {
        _isListening = false;
        // Retourner un message d'erreur
        onResult('__no_internet__');
        onDone();
        return;
      }

      _mode = 'stt';
      await _stt.listen(
        localeId: locale,
        onResult: (r) {
          if (r.finalResult) {
            _isListening = false;
            onResult(r.recognizedWords);
            onDone();
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
      return;
    }

    _isListening = false;
    onDone();
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _vosk.stopListening();
    await _stt.stop();
  }

  void dispose() {
    _vosk.dispose();
    _stt.cancel();
  }
}
