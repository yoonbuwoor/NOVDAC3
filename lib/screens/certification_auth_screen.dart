import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/certification_auth_service.dart';

class CertificationAuthScreen extends StatefulWidget {
  const CertificationAuthScreen({super.key});

  @override
  State<CertificationAuthScreen> createState() => _CertificationAuthScreenState();
}

class _CertificationAuthScreenState extends State<CertificationAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _createMode = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_createMode) {
        await CertificationAuthService.createAccount(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await CertificationAuthService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (error) {
      setState(() => _error = _firebaseMessage(error));
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Saisis d’abord ton adresse e-mail.');
      return;
    }
    try {
      await CertificationAuthService.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un lien de réinitialisation a été envoyé.'),
        ),
      );
    } on FirebaseAuthException catch (error) {
      setState(() => _error = _firebaseMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(_createMode ? 'Créer mon compte' : 'Connexion certification')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [orange, Color(0xFFD91E5B)]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 34),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _createMode
                              ? 'Compte réservé aux certifications'
                              : 'Reprendre mon parcours certifiant',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'L’académie reste accessible sans compte. Une connexion est demandée uniquement pour sécuriser les examens, conserver les validations et émettre le certificat.',
                          style: TextStyle(
                            color: dark ? Colors.white70 : const Color(0xFF40566B),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Adresse e-mail',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Saisis une adresse e-mail valide.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          autofillHints: _createMode
                              ? const [AutofillHints.newPassword]
                              : const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').length < 8) {
                              return 'Utilise au moins 8 caractères.';
                            }
                            return null;
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.red.withOpacity(.25)),
                            ),
                            child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _loading ? null : _submit,
                          icon: _loading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(_createMode ? Icons.person_add_alt_1_rounded : Icons.login_rounded),
                          label: Text(_createMode ? 'Créer le compte' : 'Se connecter'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => setState(() {
                                    _createMode = !_createMode;
                                    _error = null;
                                  }),
                          child: Text(
                            _createMode
                                ? 'J’ai déjà un compte'
                                : 'Créer un compte pour me certifier',
                          ),
                        ),
                        if (!_createMode)
                          TextButton(
                            onPressed: _loading ? null : _resetPassword,
                            child: const Text('Mot de passe oublié'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _firebaseMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' => 'Cette adresse possède déjà un compte.',
      'invalid-email' => 'L’adresse e-mail est invalide.',
      'weak-password' => 'Le mot de passe est trop faible.',
      'invalid-credential' || 'wrong-password' || 'user-not-found' =>
        'E-mail ou mot de passe incorrect.',
      'too-many-requests' => 'Trop de tentatives. Réessaie un peu plus tard.',
      'network-request-failed' => 'Connexion Internet indisponible.',
      _ => error.message ?? 'Authentification impossible.',
    };
  }
}
