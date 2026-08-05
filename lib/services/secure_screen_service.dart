import 'package:flutter/services.dart';

class SecureScreenService {
  SecureScreenService._();

  static const MethodChannel _channel = MethodChannel('droneatlas/security');

  static Future<void> enable() async {
    try {
      await _channel.invokeMethod<void>('enableSecure');
    } on PlatformException {
      // Le mode sécurisé est renforcé sur Android. Sur une plateforme non prise
      // en charge, l’examen reste utilisable sans interrompre l’application.
    }
  }

  static Future<void> disable() async {
    try {
      await _channel.invokeMethod<void>('disableSecure');
    } on PlatformException {
      // Voir commentaire dans enable().
    }
  }
}
