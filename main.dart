import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_settings.dart';
import 'services/settings_service.dart';
import 'services/voice_service.dart';
import 'theme.dart';
import 'screens/signup_screen.dart';
import 'screens/customize_screen.dart';
import 'screens/accessibility_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  await _requestPermissions();

  final settingsService = SettingsService();
  final settings = await settingsService.load();
  final prefs = await SharedPreferences.getInstance();
  final accessibilityShown = prefs.getBool('accessibility_shown') ?? false;

  runApp(NeuroVoiceApp(
    settings: settings,
    settingsService: settingsService,
    accessibilityShown: accessibilityShown,
  ));
}

Future<void> _requestPermissions() async {
  await [
    Permission.microphone,
    Permission.contacts,
    Permission.phone,
  ].request();
}

class NeuroVoiceApp extends StatelessWidget {
  final UserSettings settings;
  final SettingsService settingsService;
  final bool accessibilityShown;

  const NeuroVoiceApp({
    super.key,
    required this.settings,
    required this.settingsService,
    required this.accessibilityShown,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroVoice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: _RootRouter(
        settings: settings,
        settingsService: settingsService,
        accessibilityShown: accessibilityShown,
      ),
    );
  }
}

class _RootRouter extends StatefulWidget {
  final UserSettings settings;
  final SettingsService settingsService;
  final bool accessibilityShown;

  const _RootRouter({
    required this.settings,
    required this.settingsService,
    required this.accessibilityShown,
  });

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  late bool _showSignup;
  late bool _showAccessibility;
  final VoiceService _voiceService = VoiceService();

  @override
  void initState() {
    super.initState();
    _showSignup = !widget.settings.isConfigured;
    // Montrer l'écran accessibilité seulement si pas encore affiché
    _showAccessibility = !widget.accessibilityShown;
  }

  Future<void> _doneAccessibility() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accessibility_shown', true);
    setState(() => _showAccessibility = false);
  }

  @override
  Widget build(BuildContext context) {
    // Étape 1 : Inscription
    if (_showSignup) {
      return SignupScreen(
        onDone: () => setState(() => _showSignup = false),
      );
    }

    // Étape 2 : Accessibilité (une seule fois)
    if (_showAccessibility) {
      return AccessibilitySetupScreen(
        onDone: _doneAccessibility,
      );
    }

    // Étape 3 : App principale
    return CustomizeScreen(
      settings: widget.settings,
      settingsService: widget.settingsService,
      voiceService: _voiceService,
    );
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
