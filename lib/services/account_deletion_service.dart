import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/account_deletion_config.dart';
import 'certification_auth_service.dart';

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

class AccountDeletionService {
  AccountDeletionService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> deleteCurrentAccount({required String password}) async {
    if (!AccountDeletionConfig.isConfigured) {
      throw const AccountDeletionException(
        'Le service de suppression du compte n’est pas configuré.',
        code: 'not-configured',
      );
    }

    await CertificationAuthService.initializeIfConfigured();
    final user = CertificationAuthService.currentUser;
    final email = user?.email?.trim();
    if (user == null || email == null || email.isEmpty) {
      throw const AccountDeletionException(
        'Aucun compte Drone Atlas Academy n’est connecté.',
        code: 'no-current-user',
      );
    }
    if (password.trim().isEmpty) {
      throw const AccountDeletionException(
        'Saisis ton mot de passe pour confirmer la suppression.',
        code: 'password-required',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw const AccountDeletionException(
          'Impossible de sécuriser la demande de suppression.',
          code: 'missing-token',
        );
      }

      final response = await _client
          .delete(
            Uri.parse(AccountDeletionConfig.endpoint),
            headers: <String, String>{
              'Accept': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> body = const <String, dynamic>{};
      if (response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AccountDeletionException(
          body['message']?.toString() ??
              'Le serveur a refusé la suppression (${response.statusCode}).',
          code: body['code']?.toString(),
          statusCode: response.statusCode,
        );
      }

      // Le serveur supprime également l’utilisateur Firebase. On nettoie la
      // session locale pour que l’application revienne immédiatement à zéro.
      await CertificationAuthService.signOut();
    } on FirebaseAuthException catch (error) {
      throw AccountDeletionException(
        _firebaseMessage(error),
        code: error.code,
      );
    } on TimeoutException {
      throw const AccountDeletionException(
        'Le serveur ne répond pas. Vérifie Internet puis réessaie.',
        code: 'timeout',
      );
    } on http.ClientException catch (error) {
      throw AccountDeletionException(
        'Connexion au serveur impossible : ${error.message}',
        code: 'network-error',
      );
    } on FormatException {
      throw const AccountDeletionException(
        'La réponse du serveur de suppression est invalide.',
        code: 'invalid-response',
      );
    } on AccountDeletionException {
      rethrow;
    } catch (error) {
      throw AccountDeletionException(
        'Impossible de supprimer le compte : $error',
        code: 'unknown',
      );
    }
  }

  static String _firebaseMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'wrong-password' || 'invalid-credential' =>
        'Mot de passe incorrect. Vérifie-le puis réessaie.',
      'too-many-requests' =>
        'Trop de tentatives. Patiente quelques minutes avant de réessayer.',
      'network-request-failed' =>
        'Connexion Internet indisponible. Réessaie lorsque le réseau revient.',
      'user-disabled' => 'Ce compte a été désactivé.',
      'user-not-found' => 'Ce compte n’existe plus.',
      'requires-recent-login' =>
        'Reconnecte-toi puis relance la suppression du compte.',
      _ => error.message ?? 'Authentification impossible.',
    };
  }

  void dispose() => _client.close();
}
