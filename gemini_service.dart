import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_settings.dart';

/// Service IA basé sur Google Gemini (gratuit)
/// Clé API gratuite sur : https://aistudio.google.com/app/apikey
class GeminiService {
  // ⚠️  Remplace cette clé par ta clé Gemini gratuite
  // Obtiens-la sur : https://aistudio.google.com/app/apikey
  static const String _apiKey = 'REMPLACE_PAR_TA_CLE_GEMINI';

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  final UserSettings _settings;

  // Historique de conversation (mémoire courte)
  final List<Map<String, String>> _history = [];

  GeminiService(this._settings);

  /// Envoie un message à Gemini et retourne la réponse
  Future<String> ask(String userMessage) async {
    // Si pas de clé API → réponse locale intelligente
    if (_apiKey == 'REMPLACE_PAR_TA_CLE_GEMINI') {
      return _localFallback(userMessage);
    }

    try {
      // Ajouter le message à l'historique
      _history.add({'role': 'user', 'content': userMessage});

      // Construire le prompt système
      final systemPrompt = _buildSystemPrompt();

      // Construire les messages pour Gemini
      final contents = <Map<String, dynamic>>[];

      // Historique (max 6 messages pour garder le contexte sans trop de tokens)
      final recentHistory = _history.length > 6
          ? _history.sublist(_history.length - 6)
          : _history;

      for (final msg in recentHistory) {
        contents.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [
            {'text': msg['content']}
          ],
        });
      }

      final body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': systemPrompt}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 200, // Réponses courtes pour être rapide
          'topP': 0.9,
        },
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates'][0]['content']['parts'][0]['text']
            as String;

        // Sauvegarder la réponse dans l'historique
        _history.add({'role': 'assistant', 'content': reply});

        // Nettoyer le texte (supprimer les * ** pour la synthèse vocale)
        return _cleanForSpeech(reply);
      } else {
        return _localFallback(userMessage);
      }
    } catch (e) {
      return _localFallback(userMessage);
    }
  }

  /// Prompt système : donne une personnalité à l'assistant
  String _buildSystemPrompt() {
    final name = _settings.assistantName.isNotEmpty
        ? _settings.assistantName
        : 'NeuroVoice';
    final greeting = _settings.greeting;
    final langLabel = _settings.langLabel;

    return '''
Tu es $name, un assistant vocal intelligent pour smartphone.
Ton maître s'appelle $greeting.
Tu parles en $langLabel.
Tu es rapide, précis, naturel — comme un humain.
Réponds TOUJOURS en moins de 2 phrases courtes (max 40 mots).
Ne mets jamais de puces, d'astérisques, de listes ou de markdown.
Tu peux faire : appels, messages, météo, calculs, questions générales.
Pour les actions (appel, message), dis ce que tu vas faire.
Sois chaleureux mais professionnel.
''';
  }

  /// Réponses locales intelligentes quand pas de connexion / pas de clé
  String _localFallback(String message) {
    final msg = message.toLowerCase();
    final name = _settings.assistantName.isNotEmpty
        ? _settings.assistantName
        : 'NeuroVoice';
    final greeting = _settings.greeting;

    // Salutations
    if (msg.contains('bonjour') || msg.contains('salut') || msg.contains('hello')) {
      return 'Bonjour $greeting ! Je suis $name, prêt à vous aider.';
    }

    // Heure
    if (msg.contains('heure') || msg.contains('time')) {
      final now = DateTime.now();
      return 'Il est ${now.hour}h${now.minute.toString().padLeft(2, '0')}.';
    }

    // Date
    if (msg.contains('date') || msg.contains('jour') || msg.contains('aujourd')) {
      final now = DateTime.now();
      const jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
      const mois = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
                    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
      return 'Nous sommes ${jours[now.weekday - 1]} ${now.day} ${mois[now.month - 1]} ${now.year}.';
    }

    // Calcul simple
    if (msg.contains('combien') || msg.contains('calcul') ||
        RegExp(r'\d+\s*[+\-×x*/÷]\s*\d+').hasMatch(msg)) {
      return _tryCalculate(msg);
    }

    // Météo (nécessite internet)
    if (msg.contains('météo') || msg.contains('temps') || msg.contains('weather')) {
      return 'Pour la météo j\'ai besoin d\'internet. Connectez-vous et réessayez.';
    }

    // Blague
    if (msg.contains('blague') || msg.contains('drôle') || msg.contains('joke')) {
      return 'Pourquoi les plongeurs plongent-ils toujours en arrière ? Parce que s\'ils plongeaient en avant, ils tomberaient dans le bateau !';
    }

    // Merci
    if (msg.contains('merci') || msg.contains('thank')) {
      return 'De rien $greeting, c\'est un plaisir de vous aider !';
    }

    // Au revoir
    if (msg.contains('au revoir') || msg.contains('bye') || msg.contains('bonne nuit')) {
      return 'Au revoir $greeting, à bientôt !';
    }

    // Réponse par défaut
    return 'Je n\'ai pas compris. Répétez ou connectez-vous à internet pour les questions complexes.';
  }

  String _tryCalculate(String msg) {
    try {
      final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*([+\-×x*/÷])\s*(\d+(?:[.,]\d+)?)').firstMatch(msg);
      if (match != null) {
        final a = double.parse(match.group(1)!.replaceAll(',', '.'));
        final op = match.group(2)!;
        final b = double.parse(match.group(3)!.replaceAll(',', '.'));
        double result;
        switch (op) {
          case '+': result = a + b; break;
          case '-': result = a - b; break;
          case '×': case 'x': case '*': result = a * b; break;
          case '/': case '÷': result = b != 0 ? a / b : 0; break;
          default: return 'Je ne peux pas faire ce calcul.';
        }
        final res = result == result.truncateToDouble() ? result.toInt().toString() : result.toStringAsFixed(2);
        return '$a $op $b égale $res.';
      }
    } catch (_) {}
    return 'Je ne peux pas faire ce calcul.';
  }

  /// Nettoie le texte pour la synthèse vocale
  String _cleanForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'\*{1,2}'), '')
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'`{1,3}'), '')
        .replaceAll('\n\n', '. ')
        .replaceAll('\n', ', ')
        .trim();
  }

  void clearHistory() => _history.clear();
}
