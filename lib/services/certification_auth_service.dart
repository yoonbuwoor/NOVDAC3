import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../config/certification_config.dart';

class CertificationAuthService {
  CertificationAuthService._();

  static bool _initialized = false;

  static bool get isConfigured => FirebaseCertificationConfig.isConfigured;
  static bool get isInitialized => _initialized;

  static FirebaseAuth? get auth {
    if (!_initialized) return null;
    return FirebaseAuth.instance;
  }

  static User? get currentUser => auth?.currentUser;

  static Stream<User?> authStateChanges() {
    final instance = auth;
    if (instance == null) return Stream<User?>.value(null);
    return instance.authStateChanges();
  }

  static Future<void> initializeIfConfigured() async {
    if (_initialized || !isConfigured) return;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: FirebaseCertificationConfig.options);
    }
    _initialized = true;
  }

  static Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    await initializeIfConfigured();
    final instance = auth;
    if (instance == null) {
      throw StateError('Firebase Authentication n’est pas configuré.');
    }
    final credential = await instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.sendEmailVerification();
    return credential;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    await initializeIfConfigured();
    final instance = auth;
    if (instance == null) {
      throw StateError('Firebase Authentication n’est pas configuré.');
    }
    return instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> sendPasswordReset(String email) async {
    await initializeIfConfigured();
    final instance = auth;
    if (instance == null) {
      throw StateError('Firebase Authentication n’est pas configuré.');
    }
    await instance.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> signOut() async {
    await auth?.signOut();
  }
}
