import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _professionController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final controller = AppScope.of(context);
    final success = await controller.saveLearnerProfile(
      name: _nameController.text,
      profession: _professionController.text,
      email: _emailController.text,
    );

    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.registrationError ??
              'Impossible d’enregistrer les informations.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final submitting = controller.registrationSubmitting;

    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _OnboardingBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D202B).withOpacity(.96),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 36,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Image.asset('assets/images/logo.webp'),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BIENVENUE SUR DRONEATLAS',
                                      style: TextStyle(
                                        color: cyan,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Configure ton cockpit apprenant',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Ton profil personnalise le cockpit, la progression et les recommandations. Ensuite, cours, missions, le laboratoire et Drobot restent accessibles hors connexion.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: electricBlue.withOpacity(.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: electricBlue.withOpacity(.35)),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.wifi_rounded, color: electricBlue, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Une connexion Internet est nécessaire pour transmettre ce formulaire à Novateur221. Après un envoi réussi, ces informations ne seront pas renvoyées automatiquement.',
                                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.45, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _nameController,
                            enabled: !submitting,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Nom complet',
                              hintText: 'Ex. Seydou Ka',
                              prefixIcon: Icon(Icons.person_rounded),
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().length < 2) {
                                return 'Renseigne ton nom.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _professionController,
                            enabled: !submitting,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Profession ou domaine',
                              hintText: 'Ex. Géomaticien, étudiant, télépilote…',
                              prefixIcon: Icon(Icons.work_rounded),
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().length < 2) {
                                return 'Renseigne ta profession ou ton domaine.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            enabled: !submitting,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Adresse e-mail',
                              hintText: 'nom@exemple.com',
                              prefixIcon: Icon(Icons.email_rounded),
                            ),
                            validator: (value) {
                              final email = (value ?? '').trim();
                              final valid = RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(email);
                              return valid ? null : 'Saisis une adresse e-mail valide.';
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  color: Colors.white54, size: 17),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aucun compte ni espace communautaire n’est créé. Tes informations de profil restent aussi enregistrées sur cet appareil.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (controller.registrationError != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: orange.withOpacity(.10),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: orange.withOpacity(.45)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      controller.registrationError!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: submitting ? null : _submit,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17),
                              ),
                              icon: submitting
                                  ? const SizedBox(
                                      width: 19,
                                      height: 19,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                submitting
                                    ? 'Envoi à Novateur221…'
                                    : 'Envoyer et commencer',
                              ),
                            ),
                          ),
                          if (controller.registrationError != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: submitting
                                    ? null
                                    : controller.continueWithoutRegistrationSync,
                                icon: const Icon(Icons.offline_bolt_rounded),
                                label: const Text('Continuer hors connexion'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = cyan.withOpacity(.055)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 52) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += 52) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [cyan.withOpacity(.16), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .82, size.height * .18),
          radius: size.shortestSide * .55,
        ),
      );
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
