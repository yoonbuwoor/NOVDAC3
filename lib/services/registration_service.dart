import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/emailjs_config.dart';

class RegistrationException implements Exception {
  const RegistrationException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class RegistrationService {
  RegistrationService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _endpoint =
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  final http.Client _client;

  Future<void> submit({
    required String name,
    required String profession,
    required String email,
  }) async {
    if (!EmailJsConfig.isConfigured) {
      throw const RegistrationException(
        'EmailJS n’est pas configuré dans cette version de l’application.',
      );
    }

    final cleanName = name.trim();
    final cleanProfession = profession.trim();
    final cleanEmail = email.trim().toLowerCase();

    try {
      final response = await _client
          .post(
            _endpoint,
            headers: const <String, String>{
              'Accept': 'application/json, text/plain, */*',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'service_id': EmailJsConfig.serviceId,
              'template_id': EmailJsConfig.templateId,
              'user_id': EmailJsConfig.publicKey,
              'template_params': <String, String>{
                // Le modèle EmailJS utilise uniquement ces trois champs.
                'name': cleanName,
                'profession': cleanProfession,
                'email': cleanEmail,

                // Paramètres standards utiles pour la destination et la réponse.
                'to_email': EmailJsConfig.receiverEmail,
                'to_name': 'Novateur221',
                'from_name': cleanName,
                'reply_to': cleanEmail,
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final details = response.body.trim();
        throw RegistrationException(
          details.isEmpty
              ? 'EmailJS a refusé l’envoi (code ${response.statusCode}).'
              : 'EmailJS ${response.statusCode} : $details',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw const RegistrationException(
        'Le serveur EmailJS ne répond pas. Vérifie Internet puis réessaie.',
      );
    } on http.ClientException catch (error) {
      throw RegistrationException(
        'Connexion à EmailJS impossible : ${error.message}',
      );
    } on RegistrationException {
      rethrow;
    } catch (error) {
      throw RegistrationException(
        'Erreur d’envoi EmailJS : $error',
      );
    }
  }

  void dispose() => _client.close();
}
