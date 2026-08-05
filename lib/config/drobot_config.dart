/// Configuration facultative du mode IA en ligne de Drobot.
///
/// Sans URL, Drobot fonctionne immédiatement avec sa base experte hors ligne.
/// Pour une IA générative, configurez un proxy sécurisé avec :
/// --dart-define=DROBOT_API_URL=https://votre-proxy.example.com/drobot
///
/// Le proxy doit accepter un POST JSON contenant `question`, `history` et
/// `offline_context`, puis renvoyer au choix :
/// {"answer":"..."}, {"message":"..."} ou une réponse OpenAI-compatible.
abstract final class DrobotConfig {
  static const String apiUrl = String.fromEnvironment(
    'DROBOT_API_URL',
    defaultValue: '',
  );

  static bool get onlineEnabled => apiUrl.trim().isNotEmpty;
}
