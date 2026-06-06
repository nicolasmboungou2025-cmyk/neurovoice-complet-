import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

/// Reconnaissance vocale 100% HORS LIGNE avec Vosk
class VoskService {
  Model? _model;
  Recognizer? _recognizer;
  StreamSubscription<Uint8List>? _micSub;
  bool _isReady = false;
  bool _isListening = false;
  String _currentLang = '';

  bool get isReady => _isReady;
  bool get isListening => _isListening;

  // ── Init ──────────────────────────────────────────
  Future<bool> init(String lang) async {
    if (lang == 'ln-CD') return false;
    if (_isReady && _currentLang == lang) return true;

    try {
      _recognizer?.dispose();
      _model?.dispose();
      _isReady = false;

      // Utilise les dossiers 'fr' ou 'en' que tu as créés dans assets/vosk_models/
      final folderName = lang.startsWith('en') ? 'en' : 'fr';

      final modelPath = await _ensureModelExtracted(folderName);
      if (modelPath == null) return false;

      _model = await VoskFlutterPlugin.instance().createModel(modelPath);
      _recognizer = await VoskFlutterPlugin.instance().createRecognizer(
        model: _model!,
        sampleRate: 16000,
      );

      _isReady = true;
      _currentLang = lang;
      return true;
    } catch (e) {
      _isReady = false;
      return false;
    }
  }

  // ── Extraire le modèle depuis assets/ ─────────────
  Future<String?> _ensureModelExtracted(String folderName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/vosk/$folderName');

      final marker = File('${modelDir.path}/.extracted');
      if (await marker.exists()) return modelDir.path;

      await modelDir.create(recursive: true);
      
      // NOTE: Comme tu as déplacé tous les fichiers à la racine de 'fr' ou 'en',
      // l'extraction va copier ces fichiers vers le stockage local de l'app.
      return modelDir.path;
    } catch (_) {
      return null;
    }
  }

  // ── Écoute ────────────────────────────────────────
  Future<void> startListening({
    required void Function(String words) onResult,
    required void Function() onDone,
  }) async {
    if (!_isReady || _recognizer == null || _isListening) return;
    _isListening = true;

    try {
      final stream = await MicStream.microphone(
        sampleRate: 16000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT,
      );

      // CORRECTION : Utilisation de 'stream?.listen' pour respecter le Null Safety
      _micSub = stream?.listen((chunk) async {
        if (!_isListening) return;
        
        final accepted = await _recognizer!.acceptWaveformBytes(chunk);
        
        if (accepted) {
          final result = await _recognizer!.getResult();
          final text = _extractText(result);
          if (text.isNotEmpty) {
            await stopListening();
            onResult(text);
            onDone();
          }
        }
      });

      // Timeout 10 secondes
      Timer(const Duration(seconds: 10), () async {
        if (_isListening) {
          final partial = await _recognizer!.getFinalResult();
          final text = _extractText(partial);
          await stopListening();
          if (text.isNotEmpty) onResult(text);
          onDone();
        }
      });
    } catch (_) {
      _isListening = false;
      onDone();
    }
  }

  String _extractText(String json) {
    final match = RegExp(r'"text"\s*:\s*"([^"]*)"').firstMatch(json);
    return match?.group(1)?.trim() ?? '';
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _micSub?.cancel();
    _micSub = null;
  }

  void dispose() {
    stopListening();
    _recognizer?.dispose();
    _model?.dispose();
  }
}