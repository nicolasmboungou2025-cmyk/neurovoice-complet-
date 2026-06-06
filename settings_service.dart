import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';

class SettingsService {
  static const _kAssistantName = 'assistantName';
  static const _kVoiceType     = 'voiceType';
  static const _kUserName      = 'userName';
  static const _kUserGender    = 'userGender';
  static const _kLanguage      = 'language';
  static const _kBatterySaver  = 'batterySaver';
  static const _kSensitivity   = 'sensitivity';

  Future<UserSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      assistantName: prefs.getString(_kAssistantName) ?? '',
      voiceType:     prefs.getString(_kVoiceType)     ?? 'female',
      userName:      prefs.getString(_kUserName)      ?? '',
      userGender:    prefs.getString(_kUserGender)    ?? 'homme',
      language:      prefs.getString(_kLanguage)      ?? 'fr-FR',
      batterySaver:  prefs.getBool(_kBatterySaver)    ?? false,
      sensitivity:   prefs.getDouble(_kSensitivity)   ?? 5.0,
    );
  }

  Future<void> save(UserSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAssistantName, s.assistantName);
    await prefs.setString(_kVoiceType,     s.voiceType);
    await prefs.setString(_kUserName,      s.userName);
    await prefs.setString(_kUserGender,    s.userGender);
    await prefs.setString(_kLanguage,      s.language);
    await prefs.setBool(_kBatterySaver,    s.batterySaver);
    await prefs.setDouble(_kSensitivity,   s.sensitivity);
  }
}
