import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/certification_config.dart';
import '../core/theme.dart';
import '../services/certification_api_service.dart';
import '../services/secure_screen_service.dart';

class CertificatePreviewScreen extends StatefulWidget {
  const CertificatePreviewScreen({
    super.key,
    required this.certificateId,
    required this.pathTitle,
  });

  final String certificateId;
  final String pathTitle;

  @override
  State<CertificatePreviewScreen> createState() => _CertificatePreviewScreenState();
}

class _CertificatePreviewScreenState extends State<CertificatePreviewScreen> {
  PdfControllerPinch? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    SecureScreenService.enable();
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    SecureScreenService.disable();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final Uint8List bytes = await CertificationApiService.instance.loadPreview(widget.certificateId);
      if (!mounted) return;
      setState(() {
        _controller = PdfControllerPinch(document: PdfDocument.openData(bytes));
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _openWhatsApp() async {
    final message = Uri.encodeComponent(
      'Bonjour Novateur221, j’ai validé la certification « ${widget.pathTitle} » dans DroneAtlas Academy. '
      'Mon identifiant est ${widget.certificateId}. Je souhaite recevoir la version officielle sans filigrane.',
    );
    final uri = Uri.parse(
      'https://wa.me/${CertificationConfig.whatsappNumber}?text=$message',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aperçu du certificat')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: orange.withOpacity(.12),
              child: const Text(
                'APERÇU PROTÉGÉ — NON VALABLE. La version officielle sans filigrane a déjà été générée et transmise à Novateur221.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, height: 1.35),
              ),
            ),
            Expanded(
              child: _error != null
                  ? Center(child: Padding(padding: const EdgeInsets.all(22), child: Text(_error!, textAlign: TextAlign.center)))
                  : _controller == null
                      ? const Center(child: CircularProgressIndicator())
                      : ColoredBox(
                          color: const Color(0xFF111820),
                          child: PdfViewPinch(
                            controller: _controller!,
                            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                              options: const DefaultBuilderOptions(),
                              documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                              pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                              errorBuilder: (_, error) => Center(child: Text('$error', style: const TextStyle(color: Colors.white))),
                            ),
                          ),
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('Recevoir la version officielle sans filigrane'),
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
