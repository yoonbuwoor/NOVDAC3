import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/certification_models.dart';
import '../services/certification_api_service.dart';
import '../services/secure_screen_service.dart';
import 'certificate_identity_screen.dart';

class CertificationExamScreen extends StatefulWidget {
  const CertificationExamScreen({
    super.key,
    required this.pathId,
    required this.pathTitle,
    required this.exam,
  });

  final String pathId;
  final String pathTitle;
  final CertificationExamSummary exam;

  @override
  State<CertificationExamScreen> createState() => _CertificationExamScreenState();
}

class _CertificationExamScreenState extends State<CertificationExamScreen>
    with WidgetsBindingObserver {
  CertificationExamSession? _session;
  final Map<String, String> _answers = <String, String>{};
  Timer? _timer;
  int _remainingSeconds = 0;
  int _questionIndex = 0;
  int _interruptions = 0;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SecureScreenService.enable();
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    SecureScreenService.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_session == null || _submitting) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _interruptions++;
      if (_interruptions >= 3 && mounted) {
        _timer?.cancel();
        setState(() {
          _error = 'Examen interrompu après plusieurs sorties de l’application. Recommence l’épreuve.';
          _session = null;
        });
      }
    }
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await CertificationApiService.instance.startExam(
        pathId: widget.pathId,
        examId: widget.exam.id,
      );
      if (!mounted) return;
      setState(() {
        _session = session;
        _remainingSeconds = session.durationSeconds;
        _loading = false;
        _questionIndex = 0;
        _answers.clear();
        _interruptions = 0;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _submitting) return;
        if (_remainingSeconds <= 1) {
          _timer?.cancel();
          setState(() => _remainingSeconds = 0);
          _submit(autoSubmit: true);
        } else {
          setState(() => _remainingSeconds--);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submit({bool autoSubmit = false}) async {
    final session = _session;
    if (session == null || _submitting) return;
    if (!autoSubmit && _answers.length < session.questions.length) {
      final continueAnyway = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Réponses incomplètes'),
          content: Text(
            '${session.questions.length - _answers.length} question(s) restent sans réponse. Souhaites-tu rendre l’examen quand même ?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuer l’examen')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Rendre')),
          ],
        ),
      );
      if (continueAnyway != true) return;
    }

    _timer?.cancel();
    setState(() => _submitting = true);
    try {
      final result = await CertificationApiService.instance.submitExam(
        token: session.token,
        answers: _answers,
        interruptions: _interruptions,
      );
      if (!mounted) return;
      await _showResult(result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _submitting = false;
      });
    }
  }

  Future<void> _showResult(CertificationExamResult result) async {
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          result.passed ? Icons.check_circle_rounded : Icons.replay_rounded,
          color: result.passed ? success : orange,
          size: 48,
        ),
        title: Text(result.passed ? 'Épreuve validée' : 'Épreuve non validée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${result.score} %',
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text('Seuil requis : ${result.passScore} %'),
            if (result.message != null) ...[
              const SizedBox(height: 12),
              Text(result.message!, textAlign: TextAlign.center),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              result.certificateEligible
                  ? 'Générer mon certificat'
                  : result.passed
                      ? 'Continuer'
                      : 'Fermer',
            ),
          ),
        ],
      ),
    );
    if (!mounted || proceed != true) return;
    if (result.certificateEligible) {
      final issued = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CertificateIdentityScreen(
            pathId: widget.pathId,
            pathTitle: widget.pathTitle,
          ),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, issued == true);
    } else {
      Navigator.pop(context, result.passed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return PopScope(
      canPop: session == null || _submitting,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || session == null || _submitting) return;
        final exit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter l’examen ?'),
            content: const Text('La tentative en cours sera perdue.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Rester')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quitter')),
            ],
          ),
        );
        if (exit == true && mounted) Navigator.pop(context, false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.exam.title),
          actions: [
            if (session != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      color: _remainingSeconds < 120 ? Colors.redAccent : null,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: SelectionContainer.disabled(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorState(message: _error!, onRetry: _start)
                    : session == null
                        ? _ErrorState(message: 'La session d’examen n’est plus active.', onRetry: _start)
                        : _buildExam(session),
          ),
        ),
      ),
    );
  }

  Widget _buildExam(CertificationExamSession session) {
    final question = session.questions[_questionIndex];
    final selected = _answers[question.id];
    final progress = (_questionIndex + 1) / session.questions.length;
    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 5),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Text(
                    'QUESTION ${_questionIndex + 1}/${session.questions.length}',
                    style: const TextStyle(color: cyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .6),
                  ),
                  const Spacer(),
                  Text('Sorties : $_interruptions/3', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                question.prompt,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.25),
              ),
              const SizedBox(height: 20),
              for (final option in question.options)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: selected == option.id ? cyan : Theme.of(context).dividerColor,
                      width: selected == option.id ? 2 : 1,
                    ),
                    color: selected == option.id ? cyan.withOpacity(.10) : Theme.of(context).cardTheme.color,
                  ),
                  child: RadioListTile<String>(
                    value: option.id,
                    groupValue: selected,
                    onChanged: _submitting
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() => _answers[question.id] = value);
                          },
                    title: Text(option.text, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35)),
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: orange.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_rounded, color: orange, size: 20),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Les captures d’écran et la sélection de texte sont désactivées sur les pages d’examen. Les questions sont mélangées côté serveur.',
                        style: TextStyle(fontSize: 11.5, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _questionIndex == 0 || _submitting
                        ? null
                        : () => setState(() => _questionIndex--),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Précédente'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submitting
                        ? null
                        : _questionIndex < session.questions.length - 1
                            ? () => setState(() => _questionIndex++)
                            : () => _submit(),
                    icon: _submitting
                        ? const SizedBox.square(dimension: 17, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(_questionIndex < session.questions.length - 1 ? Icons.arrow_forward_rounded : Icons.send_rounded),
                    label: Text(_questionIndex < session.questions.length - 1 ? 'Suivante' : 'Rendre'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: orange),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Recommencer')),
          ],
        ),
      ),
    );
  }
}
