import 'package:flutter_tts/flutter_tts.dart';
import '../models/user_settings.dart';
import 'hybrid_speech_service.dart';

/// Service principal qui combine :
///  - FlutterTts pour parler (TTS)
///  - HybridSpeechService pour écouter (Vosk offline + STT online)
class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final HybridSpeechService _speech = HybridSpeechService();

  bool _isListening = false;
  bool get isListening => _isListening;

  // Mode utilisé : 'vosk' | 'stt' | 'none'
  String get speechMode => _speech.mode;

  // ── Init ──────────────────────────────────────────
  Future<void> init(UserSettings settings) async {
    await _configureTts(settings);
    await _speech.init(settings);
  }

  Future<void> _configureTts(UserSettings settings) async {
    await _tts.setLanguage(settings.language);
    await _tts.setSpeechRate(0.52);
    await _tts.setVolume(1.0);
    await _tts.setPitch(settings.voiceType == 'male' ? 0.75 : 1.25);

    // Sélectionner la meilleure voix disponible
    final voices = await _tts.getVoices as List?;
    if (voices != null) {
      final langCode = settings.language.split('-')[0];
      final match = voices.cast<Map>().where((v) {
        final name   = (v['name']   as String? ?? '').toLowerCase();
        final locale = (v['locale'] as String? ?? '');
        final isLang = locale.toLowerCase().startsWith(langCode);
        final isGender = settings.voiceType == 'male'
            ? (name.contains('male') || name.contains('thomas') ||
               name.contains('pierre') || name.contains('fr-fr-x-fra'))
            : (name.contains('female') || name.contains('amelie') ||
               name.contains('marie')  || name.contains('fr-fr-x-frf'));
        return isLang && isGender;
      }).toList();
      if (match.isNotEmpty) {
        await _tts.setVoice({
          'name':   match.first['name'],
          'locale': match.first['locale'],
        });
      }
    }
  }

  // ── Parler ────────────────────────────────────────
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() => _tts.stop();

  // ── Écouter ───────────────────────────────────────
  Future<void> startListening({
    required String locale,
    required void Function(String words) onResult,
    required void Function() onDone,
  }) async {
    if (_isListening) return;
    _isListening = true;
    await _speech.startListening(
      locale: locale,
      onResult: (words) {
        _isListening = false;
        onResult(words);
      },
      onDone: () {
        _isListening = false;
        onDone();
      },
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stopListening();
  }

  // ── Aperçu voix ───────────────────────────────────
  Future<void> previewVoice(String type, String lang) async {
    await _tts.setPitch(type == 'male' ? 0.75 : 1.25);
    await _tts.setLanguage(lang);
    final text = lang.startsWith('en')
        ? 'Hello, I am your voice assistant. How can I help you?'
        : type == 'male'
            ? 'Bonjour Monsieur, je suis votre assistant vocal. Comment puis-je vous aider ?'
            : 'Bonjour Madame, je suis votre assistante vocale. Comment puis-je vous aider ?';
    await _tts.stop();
    await _tts.speak(text);
  }

  void dispose() {
    _tts.stop();
    _speech.dispose();
  }
}
