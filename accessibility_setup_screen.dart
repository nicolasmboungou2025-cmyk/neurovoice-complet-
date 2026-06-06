import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Écran affiché UNE SEULE FOIS pour guider l'utilisateur
/// à activer le service d'accessibilité Android
class AccessibilitySetupScreen extends StatefulWidget {
  final VoidCallback onDone;
  const AccessibilitySetupScreen({super.key, required this.onDone});

  @override
  State<AccessibilitySetupScreen> createState() =>
      _AccessibilitySetupScreenState();
}

class _AccessibilitySetupScreenState extends State<AccessibilitySetupScreen> {
  static const _channel =
      MethodChannel('com.neurovoice.app/call_accessibility');

  bool _isEnabled = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _checking = true);
    try {
      final enabled =
          await _channel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
      setState(() {
        _isEnabled = enabled;
        _checking = false;
      });
      if (enabled) {
        await Future.delayed(const Duration(milliseconds: 800));
        widget.onDone();
      }
    } catch (_) {
      setState(() => _checking = false);
    }
  }

  Future<void> _openSettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
      // Attendre que l'utilisateur revienne et vérifier
      await Future.delayed(const Duration(seconds: 3));
      _checkStatus();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NvBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Icône
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.purpleLight.withOpacity(0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.accessibility_new_rounded,
                    color: AppColors.purpleLight,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Une permission\nest nécessaire',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.textWhite,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Pour répondre et rejeter les appels par la voix sans toucher l\'écran, NeuroVoice a besoin du service d\'accessibilité Android.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 36),

                // Étapes
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _Step(
                        num: '1',
                        text: 'Clique sur "Ouvrir les paramètres" ci-dessous',
                      ),
                      const SizedBox(height: 14),
                      _Step(
                        num: '2',
                        text: 'Trouve "NeuroVoice" dans la liste',
                      ),
                      const SizedBox(height: 14),
                      _Step(
                        num: '3',
                        text: 'Active le service et confirme',
                      ),
                      const SizedBox(height: 14),
                      _Step(
                        num: '4',
                        text: 'Reviens dans l\'app — c\'est prêt !',
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Status
                if (_checking)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.purpleLight,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Vérification…',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isEnabled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Service activé !',
                          style: TextStyle(
                            color: AppColors.green,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bouton principal
                GradButton(
                  label: 'Ouvrir les paramètres d\'accessibilité',
                  onTap: _openSettings,
                ),

                const SizedBox(height: 12),

                // Passer cette étape
                OutlineBtn(
                  label: 'Passer cette étape pour l\'instant',
                  onTap: widget.onDone,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String num;
  final String text;
  const _Step({required this.num, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: AppColors.purpleLight.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.purpleLight.withOpacity(0.4),
              ),
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.purpleLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textWhite,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
}
