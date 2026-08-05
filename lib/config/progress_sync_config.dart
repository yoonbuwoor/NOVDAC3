class ProgressSyncConfig {
  const ProgressSyncConfig._();

  /// Peut être remplacée pendant le build avec :
  /// --dart-define=PROGRESS_SYNC_URL=https://.../.netlify/functions/progress-api
  static const String endpoint = String.fromEnvironment(
    'PROGRESS_SYNC_URL',
    defaultValue: 'https://droneatlas.xyz/.netlify/functions/progress-api',
  );

  static bool get isConfigured => endpoint.trim().isNotEmpty;
}
