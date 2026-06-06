import 'package:contacts_service/contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_settings.dart';
import 'voice_service.dart';
import 'gemini_service.dart';

/// Traite les commandes vocales :
///  1. Commandes téléphoniques (appel, raccrocher…)  → logique locale
///  2. Tout le reste                                  → Gemini IA
class CommandService {
  final VoiceService _voice;
  final UserSettings _settings;
  late final GeminiService _ai;

  CommandService(this._voice, this._settings) {
    _ai = GeminiService(_settings);
  }

  // ─────────────────────────────────────────────────
  //  Point d'entrée principal
  // ─────────────────────────────────────────────────
  Future<String> process(String command) async {
    // Commande vide ou erreur micro
    if (command.isEmpty || command == '__no_internet__') {
      const reply = 'Pas de connexion internet. Activez le Wi-Fi ou installez le modèle hors ligne.';
      await _voice.speak(reply);
      return reply;
    }

    final cmd = command.toLowerCase().trim();

    // ── Commandes téléphoniques (priorité max) ──
    if (_matchesCall(cmd))   return await _handleCall(cmd);
    if (_matchesAnswer(cmd)) return _handleAnswer();
    if (_matchesReject(cmd)) return _handleReject();
    if (_matchesHangUp(cmd)) return _handleHangUp();

    // ── Tout le reste → Gemini IA ───────────────
    return await _handleAI(command);
  }

  // ─────────────────────────────────────────────────
  //  IA Gemini
  // ─────────────────────────────────────────────────
  Future<String> _handleAI(String message) async {
    final reply = await _ai.ask(message);
    await _voice.speak(reply);
    return reply;
  }

  // ─────────────────────────────────────────────────
  //  Détection intentions téléphoniques
  // ─────────────────────────────────────────────────
  bool _matchesCall(String cmd) =>
      _l10n['call']!.any((t) => cmd.contains(t));
  bool _matchesAnswer(String cmd) =>
      _l10n['answer']!.any((t) => cmd.contains(t));
  bool _matchesReject(String cmd) =>
      _l10n['reject']!.any((t) => cmd.contains(t));
  bool _matchesHangUp(String cmd) =>
      _l10n['hangup']!.any((t) => cmd.contains(t));

  // ─────────────────────────────────────────────────
  //  Actions téléphoniques
  // ─────────────────────────────────────────────────
  Future<String> _handleCall(String cmd) async {
    String contactName = '';
    for (final trigger in _l10n['call']!) {
      if (cmd.contains(trigger)) {
        contactName = cmd.replaceFirst(trigger, '').trim();
        break;
      }
    }

    if (contactName.isEmpty) {
      final reply = _l10n['askWho']![0];
      await _voice.speak(reply);
      return reply;
    }

    try {
      final contacts = await ContactsService.getContacts(
        query: contactName,
        withThumbnails: false,
      );

      if (contacts.isEmpty) {
        final reply = _fmt(_l10n['contactNotFound']![0], contactName);
        await _voice.speak(reply);
        return reply;
      }

      if (contacts.length > 1) {
        final names = contacts
            .take(3)
            .map((c) => c.displayName ?? '')
            .join(', ');
        final reply = _fmt(_l10n['ambiguous']![0], names);
        await _voice.speak(reply);
        return reply;
      }

      final contact = contacts.first;
      final phone = contact.phones?.isNotEmpty == true
          ? contact.phones!.first.value
          : null;

      if (phone == null) {
        final reply = _fmt(_l10n['noPhone']![0], contact.displayName ?? contactName);
        await _voice.speak(reply);
        return reply;
      }

      final reply = _fmt(_l10n['calling']![0], contact.displayName ?? contactName);
      await _voice.speak(reply);
      await Future.delayed(const Duration(milliseconds: 800));
      await launchUrl(Uri.parse('tel:${phone.replaceAll(' ', '')}'));
      return reply;
    } catch (_) {
      final reply = _l10n['permissionNeeded']![0];
      await _voice.speak(reply);
      return reply;
    }
  }

  String _handleAnswer() {
    const reply = 'Je décroche.';
    _voice.speak(reply);
    return reply;
  }

  String _handleReject() {
    const reply = 'J\'ai rejeté l\'appel.';
    _voice.speak(reply);
    return reply;
  }

  String _handleHangUp() {
    const reply = 'J\'ai raccroché.';
    _voice.speak(reply);
    return reply;
  }

  String _fmt(String t, String v) => t.replaceAll('{0}', v);

  // ─────────────────────────────────────────────────
  //  Mots-clés multilingues
  // ─────────────────────────────────────────────────
  Map<String, List<String>> get _l10n {
    switch (_settings.language) {
      case 'en-US':
        return {
          'call':            ['call ', 'phone ', 'dial '],
          'answer':          ['answer', 'pick up', 'accept call'],
          'reject':          ['reject', 'decline', 'ignore call'],
          'hangup':          ['hang up', 'end call', 'stop call'],
          'askWho':          ['Who do you want to call?'],
          'calling':         ['Calling {0}…'],
          'contactNotFound': ['I could not find {0} in your contacts.'],
          'ambiguous':       ['I found several contacts: {0}. Which one?'],
          'noPhone':         ['{0} has no phone number.'],
          'permissionNeeded':['I need permission to access your contacts.'],
        };
      case 'ln-CD':
        return {
          'call':            ['benga ', 'sema na '],
          'answer':          ['yamba', 'tia appel'],
          'reject':          ['boya', 'tika appel'],
          'hangup':          ['suka', 'tika'],
          'askWho':          ['Ozali kolinga kobenga nani?'],
          'calling':         ['Nabenga {0}…'],
          'contactNotFound': ['Nazwaki te {0} na ba contacts na yo.'],
          'ambiguous':       ['Nazwaki ba moto mingi: {0}. Nabenga nani?'],
          'noPhone':         ['{0} azali na numero te.'],
          'permissionNeeded':['Nalingi permission ya koyeba ba contacts.'],
        };
      default: // fr-FR
        return {
          'call':            ['appelle ', 'appeler ', 'appel à ', 'téléphone à ', 'compose le '],
          'answer':          ['réponds', 'décroche', 'accepte l\'appel', 'prendre l\'appel'],
          'reject':          ['rejette', 'refuse l\'appel', 'ignore l\'appel'],
          'hangup':          ['raccroche', 'termine l\'appel', 'fin d\'appel', 'coupe'],
          'askWho':          ['Qui voulez-vous appeler ?'],
          'calling':         ['J\'appelle {0}…'],
          'contactNotFound': ['Je n\'ai pas trouvé {0} dans vos contacts.'],
          'ambiguous':       ['J\'ai trouvé plusieurs contacts : {0}. Lequel dois-je appeler ?'],
          'noPhone':         ['{0} n\'a pas de numéro enregistré.'],
          'permissionNeeded':['J\'ai besoin de votre permission pour accéder aux contacts.'],
        };
    }
  }
}
