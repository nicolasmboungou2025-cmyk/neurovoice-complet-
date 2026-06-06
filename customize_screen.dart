import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';
import '../services/voice_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'advanced_screen.dart';
import 'active_screen.dart';

class CustomizeScreen extends StatefulWidget {
  final UserSettings settings;
  final SettingsService settingsService;
  final VoiceService voiceService;

  const CustomizeScreen({
    super.key,
    required this.settings,
    required this.settingsService,
    required this.voiceService,
  });

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  late UserSettings _s;

  @override
  void initState() {
    super.initState();
    _s = widget.settings;
  }

  Future<void> _save() async {
    await widget.settingsService.save(_s);
    await widget.voiceService.init(_s);
  }

  // ── Name Panel ──────────────────────────────────
  void _openNamePanel() {
    final ctrl = TextEditingController(text: _s.assistantName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _Panel(
        title: 'Nom de l\'assistant',
        subtitle: 'C\'est le mot que vous direz pour activer votre robot',
        child: Column(
          children: [
            NvTextField(
              hint: 'Ex: Jarvis, Nova, Max…',
              controller: ctrl,
            ),
            const SizedBox(height: 8),
            const Text(
              '💡 Choisissez un nom court et facile à prononcer.',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            GradButton(
              label: 'Enregistrer',
              onTap: () {
                final v = ctrl.text.trim();
                if (v.isEmpty) return;
                setState(() => _s.assistantName = v);
                _save();
                Navigator.pop(context);
                _showToast('Nom enregistré : $v');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Voice Panel ─────────────────────────────────
  void _openVoicePanel() {
    String selected = _s.voiceType;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => _Panel(
          title: 'Voix de l\'assistant',
          subtitle: 'Écoutez un aperçu avant de choisir',
          child: Column(
            children: [
              _VoiceOption(
                label: 'Voix Homme',
                sublabel: 'Grave · Professionnel',
                selected: selected == 'male',
                iconColor: AppColors.purpleLight,
                onSelect: () => setLocal(() => selected = 'male'),
                onPreview: () => widget.voiceService.previewVoice('male', _s.language),
              ),
              const SizedBox(height: 10),
              _VoiceOption(
                label: 'Voix Femme',
                sublabel: 'Douce · Chaleureuse',
                selected: selected == 'female',
                iconColor: AppColors.pink,
                onSelect: () => setLocal(() => selected = 'female'),
                onPreview: () => widget.voiceService.previewVoice('female', _s.language),
              ),
              const SizedBox(height: 20),
              GradButton(
                label: 'Enregistrer',
                onTap: () {
                  setState(() => _s.voiceType = selected);
                  _save();
                  Navigator.pop(ctx);
                  _showToast('Voix enregistrée');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Identity Panel ──────────────────────────────
  void _openIdentityPanel() {
    final ctrl = TextEditingController(text: _s.userName);
    String gender = _s.userGender;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => _Panel(
          title: 'Identité de l\'utilisateur',
          subtitle: 'Votre assistant utilisera ces informations pour vous répondre',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Votre prénom'),
              NvTextField(hint: 'Ex: Nicolas, Maria…', controller: ctrl),
              const SizedBox(height: 18),
              const SectionLabel('Votre genre'),
              RadioOption(
                label: '👨 Homme',
                selected: gender == 'homme',
                onTap: () => setLocal(() => gender = 'homme'),
              ),
              RadioOption(
                label: '👩 Femme',
                selected: gender == 'femme',
                onTap: () => setLocal(() => gender = 'femme'),
              ),
              const SizedBox(height: 20),
              GradButton(
                label: 'Enregistrer',
                onTap: () {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;
                  setState(() {
                    _s.userName = name;
                    _s.userGender = gender;
                  });
                  _save();
                  Navigator.pop(ctx);
                  _showToast('Identité enregistrée');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ $msg', style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.cardGlass,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goAdvanced() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdvancedScreen(
          settings: _s,
          settingsService: widget.settingsService,
        ),
      ),
    );
    setState(() {});
  }

  void _launchRobot() async {
    await widget.voiceService.init(_s);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveScreen(
          settings: _s,
          voiceService: widget.voiceService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NvBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // Hero
                Text(
                  'NeuroVoice',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.purpleLight,
                    shadows: [
                      const Shadow(
                        color: Color(0x80A855F7),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

                const SizedBox(height: 16),

                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textWhite,
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(text: 'Bonjour, je suis votre '),
                      TextSpan(
                        text: 'assistant',
                        style: TextStyle(
                          color: AppColors.purpleLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: ' vocal '),
                      TextSpan(
                        text: 'intelligent',
                        style: TextStyle(
                          color: AppColors.purpleLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: ' qui vous obéit sans que vous touchiez '),
                      TextSpan(
                        text: 'votre écran',
                        style: TextStyle(
                          color: AppColors.purpleLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 36),

                // Settings card
                PurpleCard(
                  child: Column(
                    children: [
                      const Text(
                        'Personnaliser votre assistant',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 20),

                      MenuItemRow(
                        icon: const Icon(Icons.label_outline_rounded,
                            color: Colors.white, size: 20),
                        label: 'Le nom de l\'assistant',
                        subtitle: _s.assistantName.isNotEmpty
                            ? _s.assistantName
                            : 'Non défini',
                        onTap: _openNamePanel,
                      ),
                      const SizedBox(height: 10),

                      MenuItemRow(
                        icon: const Icon(Icons.mic_none_rounded,
                            color: Colors.white, size: 20),
                        label: 'La voix de l\'assistant',
                        subtitle: _s.voiceType.isNotEmpty
                            ? _s.voiceLabel
                            : 'Non définie',
                        onTap: _openVoicePanel,
                      ),
                      const SizedBox(height: 10),

                      MenuItemRow(
                        icon: const Icon(Icons.badge_outlined,
                            color: Colors.white, size: 20),
                        label: 'L\'identité de l\'utilisateur',
                        subtitle: _s.userName.isNotEmpty
                            ? '${_s.userGender == "femme" ? "Madame" : "Monsieur"} ${_s.userName}'
                            : 'Non définie',
                        onTap: _openIdentityPanel,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                const SizedBox(height: 20),

                // Advanced
                OutlineBtn(
                  label: 'Paramètres avancés',
                  icon: Icons.settings_outlined,
                  onTap: _goAdvanced,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 12),

                // Launch
                GestureDetector(
                  onTap: _launchRobot,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderPurple),
                    ),
                    child: const Text(
                      'Lancer le robot',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.purpleLight,
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  BOTTOM SHEET PANEL
// ══════════════════════════════════════════════════
class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F071B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0x668B5CF6), width: 1.5),
          left: BorderSide(color: Color(0x668B5CF6), width: 1.5),
          right: BorderSide(color: Color(0x668B5CF6), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  VOICE OPTION WIDGET
// ══════════════════════════════════════════════════
class _VoiceOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool selected;
  final Color iconColor;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const _VoiceOption({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.iconColor,
    required this.onSelect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.purpleLight.withOpacity(0.1)
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.purpleLight : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              IconCircle(
                icon: const Icon(Icons.person_outline, color: Colors.white, size: 18),
                color: iconColor,
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Play preview
              GestureDetector(
                onTap: onPreview,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.purpleLight.withOpacity(0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.purpleLight,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
