import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/certification_config.dart';
import '../models/certification_models.dart';
import 'certification_auth_service.dart';

class CertificationApiException implements Exception {
  const CertificationApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class CertificationApiService {
  CertificationApiService._();

  static final CertificationApiService instance = CertificationApiService._();

  Uri _uri(String action, [Map<String, String>? query]) {
    if (!CertificationConfig.apiConfigured) {
      throw const CertificationApiException(
        'Le serveur de certification n’est pas configuré.',
      );
    }
    final base = Uri.parse(CertificationConfig.apiBaseUrl);
    return base.replace(
      queryParameters: <String, String>{
        ...base.queryParameters,
        'action': action,
        ...?query,
      },
    );
  }

  Future<Map<String, String>> _headers({bool jsonBody = true}) async {
    final User? user = CertificationAuthService.currentUser;
    if (user == null) {
      throw const CertificationApiException(
        'Connecte-toi pour accéder aux examens certifiants.',
        statusCode: 401,
      );
    }
    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw const CertificationApiException(
        'Impossible de sécuriser la session Firebase.',
        statusCode: 401,
      );
    }
    return <String, String>{
      'Authorization': 'Bearer $token',
      if (jsonBody) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    Map<String, dynamic> payload = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      try {
        payload = Map<String, dynamic>.from(
          jsonDecode(utf8.decode(response.bodyBytes)) as Map,
        );
      } catch (_) {
        payload = <String, dynamic>{'message': response.body};
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CertificationApiException(
        payload['message'] as String? ??
            'Le serveur de certification a refusé la demande.',
        statusCode: response.statusCode,
      );
    }
    return payload;
  }

  Future<List<CertificationPathSummary>> loadPaths() async {
    final response = await http.get(
      _uri('paths'),
      headers: await _headers(jsonBody: false),
    );
    final payload = await _decode(response);
    return (payload['paths'] as List<dynamic>? ?? const [])
        .map((item) => CertificationPathSummary.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList(growable: false);
  }

  Future<CertificationExamSession> startExam({
    required String pathId,
    required String examId,
  }) async {
    final response = await http.post(
      _uri('startExam'),
      headers: await _headers(),
      body: jsonEncode(<String, dynamic>{
        'pathId': pathId,
        'examId': examId,
      }),
    );
    return CertificationExamSession.fromJson(await _decode(response));
  }

  Future<CertificationExamResult> submitExam({
    required String token,
    required Map<String, String> answers,
    required int interruptions,
  }) async {
    final response = await http.post(
      _uri('submitExam'),
      headers: await _headers(),
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'answers': answers,
        'interruptions': interruptions,
      }),
    );
    return CertificationExamResult.fromJson(await _decode(response));
  }

  Future<IssuedCertificate> issueCertificate({
    required String pathId,
    required String fullName,
  }) async {
    final response = await http.post(
      _uri('issueCertificate'),
      headers: await _headers(),
      body: jsonEncode(<String, dynamic>{
        'pathId': pathId,
        'fullName': fullName.trim(),
      }),
    );
    return IssuedCertificate.fromJson(await _decode(response));
  }

  Future<Uint8List> loadPreview(String certificateId) async {
    final response = await http.get(
      _uri('preview', <String, String>{'certificateId': certificateId}),
      headers: await _headers(jsonBody: false),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await _decode(response);
    }
    return response.bodyBytes;
  }
}
