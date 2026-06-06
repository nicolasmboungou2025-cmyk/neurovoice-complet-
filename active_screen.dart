import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_settings.dart';
import '../services/voice_service.dart';
import '../services/command_service.dart';
import '../services/call_detector_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ActiveScreen extends StatefulWidget {
  final UserSettings settings;
  final VoiceService voiceService;

  const ActiveScreen({
    super.key,
    required this.settings,
    required this.voiceService,
  });

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late CommandService _commands;
  late CallDetectorService _callDetector;

  bool _listening = false;
  bool _waitingForName = true;
  bool _aiThinking = false;
  String _statusText = '';
  final List<Map<String, String>> _history = [];

  // État appel entrant
  CallState _callState = CallState.idle;
  String _callerName = '';

  String get _speechMode => widget.voiceService.speechMode;

  @override
  void initState() {
    super.initState();
    _commands = CommandService(widget.voiceService, widget.settings);

    // Init détecteur d'appels
    _callDetector = CallDetectorService(widget.voiceService, widget.settings);
    _callDetector.onCallStateChanged = (state, caller) {
      if (!mounted) return;
      setState(() {
        _callState = state;
        _callerName = caller;
      });
    };
    _callDetector.startWatching();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final name = widget.settings.assistantName.isNotEmpty
        ? widget.settings.assistantName
        : 'NeuroVoice';
    _statusText = 'Dites "$name" pour activer';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.voiceService.speak(
        'Bonjour ${widget.settings.greeting}. Je suis prêt. '
        'Dites ${widget.settings.assistantName.isNotEmpty ? widget.settings.assistantName : "NeuroVoice"} pour m\'activer.',
      );
      _startListeningForWakeWord();
    });
  }

  void _startListeningForWakeWord() {
    if (!mounted) return;
    // Ne pas démarrer si un appel est en cours
    if (_callState == CallState.ringing) return;

    setState(() {
      _listening = true;
      _waitingForName = true;
      _aiThinking = false;
    });
    _waveCtrl.repeat(reverse: true);

    widget.voiceService.startListening(
      locale: widget.settings.language,
      onResult: _onWakeWordResult,
      onDone: () {
        if (mounted && _waitingForName && _callState != CallState.ringing) {
          _waveCtrl.stop();
          Future.delayed(const Duration(milliseconds: 400),
              _startListeningForWakeWord);
        }
      },
    );
  }

  void _onWakeWordResult(String words) {
    final name = widget.settings.assistantName.toLowerCase();
    if (name.isNotEmpty && words.toLowerCase().contains(name)) {
      _activate();
    } else {
      if (mounted && _waitingForName) _startListeningForWakeWord();
    }
  }

  Future<void> _activate() async {
    if (!mounted) return;
    setState(() {
      _waitingForName = false;
      _statusText = 'Je vous écoute…';
      _listening = false;
    });
    _waveCtrl.stop();

    final greet = widget.settings.userGender == 'femme'
        ? 'Me voici Madame'
        : 'Me voici Monsieur';
    final fullGreet = widget.settings.userName.isNotEmpty
        ? '$greet ${widget.settings.userName}. Que puis-je faire pour vous ?'
        : '$greet. Que puis-je faire pour vous ?';

    await widget.voiceService.speak(fullGreet);
    _listenForCommand();
  }

  void _listenForCommand() {
    if (!mounted) return;
    setState(() {
      _listening = true;
      _statusText = 'Je vous écoute…';
    });
    _waveCtrl.repeat(reverse: true);

    widget.voiceService.startListening(
      locale: widget.settings.language,
      onResult: _processCommand,
      onDone: () {
        if (mounted) {
          setState(() => _listening = false);
          _waveCtrl.stop();
        }
      },
    );
  }

  Future<void> _processCommand(String words) async {
    if (!mounted) return;
    setState(() {
      _listening = false;
      _aiThinking = true;
      _statusText = 'Je réfléchis…';
    });
    _waveCtrl.stop();

    setState(() {
      _history.insert(0, {'role': 'user', 'text': words});
      if (_history.length > 10) _history.removeLast();
    });

    final reply = await _commands.process(words);

    if (!mounted) return;
    setState(() {
      _aiThinking = false;
      _statusText = reply;
      _history.insert(0, {'role': 'assistant', 'text': reply});
      if (_history.length > 10) _history.removeLast();
    });

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      final name = widget.settings.assistantName.isNotEmpty
          ? widget.settings.assistantName
          : 'NeuroVoice';
      setState(() => _statusText = 'Dites "$name" pour activer');
      _startListeningForWakeWord();
    }
  }

  void _stop() async {
    await widget.voiceService.stopListening();
    await widget.voiceService.stopSpeaking();
    _callDetector.dispose();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _callDetector.dispose();
    widget.voiceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.settings.assistantName.isNotEmpty
        ? widget.settings.assistantName
        : 'NeuroVoice';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NvBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ── Contenu principal ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Barre status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.green, blurRadius: 8)],
                              ),
                            ).animate(onPlay: (c) => c.repeat())
                              .fadeIn(duration: 800.ms).then().fadeOut(duration: 800.ms),
                            const SizedBox(width: 8),
                            const Text('ROBOT ACTIF',
                              style: TextStyle(
                                color: AppColors.green,
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        // Badge mode
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _speechMode == 'vosk'
                                ? AppColors.green.withOpacity(0.15)
                                : AppColors.purpleLight.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _speechMode == 'vosk'
                                  ? AppColors.green.withOpacity(0.4)
                                  : AppColors.purpleLight.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _speechMode == 'vosk' ? Icons.wifi_off : Icons.wifi,
                                size: 12,
                                color: _speechMode == 'vosk'
                                    ? AppColors.green
                                    : AppColors.purpleLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _speechMode == 'vosk' ? 'HORS LIGNE' : 'EN LIGNE',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: _speechMode == 'vosk'
                                      ? AppColors.green
                                      : AppColors.purpleLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Orb
                    SizedBox(
                      width: 180, height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ...[36.0, 24.0, 12.0].asMap().entries.map((e) {
                            return AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) {
                                final val = (_pulseCtrl.value + e.key * 0.33) % 1.0;
                                return Opacity(
                                  opacity: (1 - val).clamp(0, 0.6),
                                  child: Container(
                                    width: 90 + e.value * 2 * val,
                                    height: 90 + e.value * 2 * val,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.purpleLight.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              color: _callState == CallState.ringing
                                  ? const Color(0xFF16A34A)
                                  : _aiThinking
                                      ? const Color(0xFF6D28D9)
                                      : AppColors.purpleLight,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_callState == CallState.ringing
                                          ? AppColors.green
                                          : AppColors.purpleLight)
                                      .withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              _callState == CallState.ringing
                                  ? Icons.call_rounded
                                  : _aiThinking
                                      ? Icons.psychology_rounded
                                      : Icons.mic_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        color: AppColors.purpleLight,
                        shadows: [Shadow(color: Color(0x80A855F7), blurRadius: 12)],
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (_listening)
                      _Waveform(controller: _waveCtrl)
                          .animate().fadeIn(duration: 300.ms)
                    else
                      const SizedBox(height: 36),

                    const SizedBox(height: 14),

                    // Status text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _aiThinking
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 14, height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.purpleLight.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('Je réfléchis…',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _statusText,
                              key: ValueKey(_statusText),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                    ),

                    const Spacer(),

                    // Historique
                    if (_history.isNotEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel('Conversation'),
                            ..._history.take(4).map((msg) => _ChatBubble(
                              text: msg['text']!,
                              isUser: msg['role'] == 'user',
                            )),
                          ],
                        ),
                      )
                    else
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel('Exemples de commandes'),
                            _exampleCmd('Appelle Maria'),
                            _exampleCmd('Quelle heure est-il ?'),
                            _exampleCmd('Raconte-moi une blague'),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    OutlineBtn(
                      label: 'Arrêter le robot',
                      icon: Icons.stop_circle_outlined,
                      onTap: _stop,
                      color: AppColors.red,
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // ── BANNIÈRE APPEL ENTRANT ─────────────
              if (_callState == CallState.ringing)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: _IncomingCallBanner(
                    callerName: _callerName,
                    onAnswer: () => _callDetector.answerCall(),
                    onReject: () => _callDetector.rejectCall(),
                  ).animate().slideY(begin: -1, duration: 400.ms, curve: Curves.easeOut),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exampleCmd(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.purpleLight.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('"', style: TextStyle(
            color: AppColors.purpleLight, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: const TextStyle(
            color: Color(0xFFE5E7EB), fontFamily: 'Poppins', fontSize: 13))),
        ],
      ),
    ),
  );
}

// ══════════════════════════════════════════════════
//  BANNIÈRE APPEL ENTRANT
// ══════════════════════════════════════════════════
class _IncomingCallBanner extends StatelessWidget {
  final String callerName;
  final VoidCallback onAnswer;
  final VoidCallback onReject;

  const _IncomingCallBanner({
    required this.callerName,
    required this.onAnswer,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF0F1A0F),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.green.withOpacity(0.5), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: AppColors.green.withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'APPEL ENTRANT',
              style: TextStyle(
                color: AppColors.green,
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Caller
        Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.green.withOpacity(0.3)),
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.green, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    callerName.isNotEmpty ? callerName : 'Numéro inconnu',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const Text(
                    'Dites OUI pour répondre · NON pour rejeter',
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

        const SizedBox(height: 16),

        // Boutons manuels (si l'utilisateur veut toucher l'écran)
        Row(
          children: [
            // Rejeter
            Expanded(
              child: GestureDetector(
                onTap: onReject,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_end_rounded, color: AppColors.red, size: 18),
                      SizedBox(width: 6),
                      Text('Rejeter', style: TextStyle(
                        color: AppColors.red,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      )),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Répondre
            Expanded(
              child: GestureDetector(
                onTap: onAnswer,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_rounded, color: AppColors.green, size: 18),
                      SizedBox(width: 6),
                      Text('Répondre', style: TextStyle(
                        color: AppColors.green,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════
//  CHAT BUBBLE
// ══════════════════════════════════════════════════
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) => Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.purpleLight.withOpacity(0.2)
            : AppColors.cardDark,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        border: Border.all(
          color: isUser
              ? AppColors.purpleLight.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: isUser ? AppColors.purpleLight : const Color(0xFFE5E7EB),
          height: 1.4,
        ),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════
//  WAVEFORM
// ══════════════════════════════════════════════════
class _Waveform extends StatelessWidget {
  final AnimationController controller;
  const _Waveform({required this.controller});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final phase = (controller.value + i * 0.14) % 1.0;
          final h = 6 + 24 * sin(phase * pi);
          return Container(
            width: 4,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: AppColors.purpleLight,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      )),
    ),
  );
}
