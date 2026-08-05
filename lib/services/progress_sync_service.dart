import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/progress_sync_config.dart';

class ProgressSyncException implements Exception {
  const ProgressSyncException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ProgressSyncService {
  ProgressSyncService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> sync(Map<String, dynamic> payload) async {
    if (!ProgressSyncConfig.isConfigured) {
      throw const ProgressSyncException(
        'Le service de synchronisation n’est pas configuré.',
      );
    }

    try {
      final response = await _client
          .post(
            Uri.parse(ProgressSyncConfig.endpoint),
            headers: const <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      Map<String, dynamic> body = const <String, dynamic>{};
      if (response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProgressSyncException(
          body['message']?.toString() ??
              'Le serveur a refusé la progression (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
      return body;
    } on TimeoutException {
      throw const ProgressSyncException(
        'Le serveur de progression ne répond pas pour le moment.',
      );
    } on http.ClientException catch (error) {
      throw ProgressSyncException(
        'Connexion au serveur impossible : ${error.message}',
      );
    } on FormatException {
      throw const ProgressSyncException(
        'La réponse du serveur de progression est invalide.',
      );
    } on ProgressSyncException {
      rethrow;
    } catch (error) {
      throw ProgressSyncException('Erreur de synchronisation : $error');
    }
  }

  void dispose() => _client.close();
}
