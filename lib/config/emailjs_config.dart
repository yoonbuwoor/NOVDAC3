/// Configuration EmailJS de DroneAtlas.
///
/// Ces identifiants sont des identifiants publics côté client EmailJS.
/// Ils permettent à l'application d'envoyer le mini-formulaire d'inscription.
abstract final class EmailJsConfig {
  static const String serviceId = String.fromEnvironment(
    'EMAILJS_SERVICE_ID',
    defaultValue: 'service_726u54k',
  );

  static const String templateId = String.fromEnvironment(
    'EMAILJS_TEMPLATE_ID',
    defaultValue: 'template_9y2rmzx',
  );

  static const String publicKey = String.fromEnvironment(
    'EMAILJS_PUBLIC_KEY',
    defaultValue: 'fxWkKI41fWVZAmts5',
  );

  static const String receiverEmail = 'novateur221@gmail.com';

  static bool get isConfigured =>
      serviceId.trim().isNotEmpty &&
      templateId.trim().isNotEmpty &&
      publicKey.trim().isNotEmpty;
}
