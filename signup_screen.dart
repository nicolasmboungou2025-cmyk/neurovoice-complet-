import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SignupScreen({super.key, required this.onDone});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;

  void _signup() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _loading = false);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NvBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Logo
                const LogoPill(),
                const SizedBox(height: 48),

                // Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Créer un compte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 28),

                      NvTextField(hint: 'Nom complet', controller: _name),
                      const SizedBox(height: 14),
                      NvTextField(
                        hint: 'Adresse email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      NvTextField(
                        hint: 'Mot de passe',
                        controller: _pass,
                        obscure: true,
                      ),
                      const SizedBox(height: 20),

                      GradButton(
                        label: "S'inscrire — c'est gratuit",
                        onTap: _signup,
                        loading: _loading,
                      ),

                      const SizedBox(height: 28),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: NvDivider()),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Ou continuer avec',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const Expanded(child: NvDivider()),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Social buttons
                      Row(
                        children: [
                          Expanded(child: _socialBtn('Google', Icons.g_mobiledata_rounded)),
                          const SizedBox(width: 12),
                          Expanded(child: _socialBtn('Facebook', Icons.facebook_rounded)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login link
                      GestureDetector(
                        onTap: widget.onDone,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                            children: [
                              TextSpan(text: 'Déjà membre ? '),
                              TextSpan(
                                text: 'Se connecter',
                                style: TextStyle(
                                  color: AppColors.purpleLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialBtn(String label, IconData icon) => GestureDetector(
        onTap: widget.onDone,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _pass.dispose();
    super.dispose();
  }
}
