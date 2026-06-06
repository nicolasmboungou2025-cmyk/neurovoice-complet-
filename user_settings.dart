class UserSettings {
  String assistantName;
  String voiceType;      // 'male' | 'female'
  String userName;
  String userGender;     // 'homme' | 'femme'
  String language;       // 'fr-FR' | 'en-US' | 'ln-CD'
  bool batterySaver;
  double sensitivity;    // 1.0 – 10.0

  UserSettings({
    this.assistantName = '',
    this.voiceType = 'female',
    this.userName = '',
    this.userGender = 'homme',
    this.language = 'fr-FR',
    this.batterySaver = false,
    this.sensitivity = 5.0,
  });

  String get greeting {
    final title = userGender == 'femme' ? 'Madame' : 'Monsieur';
    return userName.isNotEmpty ? '$title $userName' : title;
  }

  String get langLabel {
    switch (language) {
      case 'en-US': return 'English';
      case 'ln-CD': return 'Lingala';
      default:      return 'Français';
    }
  }

  String get voiceLabel =>
      voiceType == 'male' ? 'Voix Homme' : 'Voix Femme';

  bool get isConfigured =>
      assistantName.isNotEmpty && userName.isNotEmpty;
}
