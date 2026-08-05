import 'package:firebase_core/firebase_core.dart';

class CertificationConfig {
  const CertificationConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'CERTIFICATION_API_URL',
    defaultValue: '',
  );

  static const String whatsappNumber = '221782780302';

  static bool get apiConfigured => apiBaseUrl.trim().isNotEmpty;
}

class FirebaseCertificationConfig {
  const FirebaseCertificationConfig._();

  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: '',
  );

  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  static FirebaseOptions get options {
    if (!isConfigured) {
      throw StateError('Firebase Authentication n’est pas configuré.');
    }
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain.isEmpty ? null : authDomain,
    );
  }
}
