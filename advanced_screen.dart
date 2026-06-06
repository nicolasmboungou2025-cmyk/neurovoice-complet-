import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AdvancedScreen extends StatefulWidget {
  final UserSettings settings;
  final SettingsService settingsService;

  const AdvancedScreen({
    super.key,
    required this.settings,
    required this.settingsService,
  });

  @override
  State<AdvancedScreen> createState() => _AdvancedScreenState();
}

class _AdvancedScreenState extends State<AdvancedScreen> {
  late UserSettings _s;

  @override
  void initState() {
    super.initState();
    _s = widget.settings;
  }

  Future<void> _save() async {
    await widget.settingsService.save(_s);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✓ Paramètres enregistrés',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.cardGlass,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NvBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textGrey, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Retour',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Paramètres avancés',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Langue ──────────────────────────
                GlassCard(
                  radius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconCircle(
                            icon: Icon(Icons.language_rounded,
                                color: Colors.white, size: 18),
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Langue de l\'assistant',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RadioOption(
                        label: '🇫🇷 Français',
                        selected: _s.language == 'fr-FR',
                        onTap: () => setState(() => _s.language = 'fr-FR'),
                      ),
                      RadioOption(
                        label: '🇬🇧 English',
                        selected: _s.language == 'en-US',
                        onTap: () => setState(() => _s.language = 'en-US'),
                      ),
                      RadioOption(
                        label: '🇨🇩 Lingala',
                        selected: _s.language == 'ln-CD',
                        onTap: () => setState(() => _s.language = 'ln-CD'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Économie batterie ────────────────
                GlassCard(
                  radius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const IconCircle(
                        icon: Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 18),
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Mode économie de batterie',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Réduit la consommation d\'énergie',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _s.batterySaver,
                        onChanged: (v) => setState(() => _s.batterySaver = v),
                        activeColor: AppColors.purpleLight,
                        activeTrackColor: AppColors.purpleLight.withOpacity(0.3),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Sensibilité vocale ───────────────
                GlassCard(
                  radius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconCircle(
                            icon: Icon(Icons.campaign_outlined,
                                color: Colors.white, size: 18),
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Sensibilité vocale',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Distance d\'écoute du mot d\'activation',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.purpleLight,
                          inactiveTrackColor: AppColors.purpleLight.withOpacity(0.2),
                          thumbColor: AppColors.purpleLight,
                          overlayColor: AppColors.purpleLight.withOpacity(0.15),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                        ),
                        child: Slider(
                          value: _s.sensitivity,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (v) => setState(() => _s.sensitivity = v),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Faible',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 11,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'Niveau ${_s.sensitivity.round()}',
                            style: const TextStyle(
                              color: AppColors.purpleLight,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'Élevée',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 11,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Développeur ──────────────────────
                GlassCard(
                  radius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('À propos du développeur'),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.purpleLight.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.purpleLight.withOpacity(0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IconCircle(
                                  icon: Icon(Icons.code_rounded,
                                      color: Colors.white, size: 18),
                                  size: 40,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Nicolas Shekinah Mboungou',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Développeur de NeuroVoice',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: AppColors.purpleLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const NvDivider(),
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                Icon(Icons.email_outlined,
                                    color: AppColors.textGrey, size: 16),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'nicolasmboungou2025@gmail.com',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Pour tout projet ou collaboration, n\'hésitez pas à me contacter.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                GradButton(label: 'Enregistrer les paramètres', onTap: _save),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
