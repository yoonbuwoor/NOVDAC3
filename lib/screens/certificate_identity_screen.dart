import 'package:flutter/material.dart';

import '../models/certification_models.dart';
import '../services/certification_api_service.dart';
import 'certificate_preview_screen.dart';

class CertificateIdentityScreen extends StatefulWidget {
  const CertificateIdentityScreen({
    super.key,
    required this.pathId,
    required this.pathTitle,
  });

  final String pathId;
  final String pathTitle;

  @override
  State<CertificateIdentityScreen> createState() => _CertificateIdentityScreenState();
}

class _CertificateIdentityScreenState extends State<CertificateIdentityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _confirmed = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _issue() async {
    if (!_formKey.currentState!.validate() || !_confirmed) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final IssuedCertificate certificate =
          await CertificationApiService.instance.issueCertificate(
        pathId: widget.pathId,
        fullName: _nameController.text,
      );
      if (!mounted) return;
      final viewed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CertificatePreviewScreen(
            certificateId: certificate.id,
            pathTitle: certificate.pathTitle,
          ),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, viewed ?? true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nom sur le certificat')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.badge_rounded, size: 54),
                        const SizedBox(height: 14),
                        const Text(
                          'Félicitations !',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Tu as validé ${widget.pathTitle}. Saisis ton nom réel exactement comme il doit apparaître sur le certificat.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(height: 1.45),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Prénom(s) et nom',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.length < 5 || !name.contains(' ')) {
                              return 'Saisis au moins un prénom et un nom.';
                            }
                            if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' -]+$").hasMatch(name)) {
                              return 'Le nom contient des caractères non autorisés.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _confirmed,
                          onChanged: _loading ? null : (value) => setState(() => _confirmed = value ?? false),
                          title: const Text(
                            'Je certifie que ce nom est exact et j’accepte qu’il soit enregistré avec mon résultat.',
                            style: TextStyle(fontSize: 13, height: 1.35),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(_error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
                        ],
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loading || !_confirmed ? null : _issue,
                          icon: _loading
                              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.auto_awesome_rounded),
                          label: const Text('Générer automatiquement'),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'L’application affiche uniquement un aperçu fortement filigrané. La version officielle sans filigrane est générée au même moment, stockée dans Backblaze B2 et transmise automatiquement à Novateur221.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11.5, height: 1.4),
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
}
