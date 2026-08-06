class AccountDeletionConfig {
  const AccountDeletionConfig._();

  static const String endpoint = String.fromEnvironment(
    'ACCOUNT_DELETE_API_URL',
    defaultValue:
        'https://droneatlas.xyz/.netlify/functions/account-delete-api',
  );

  static bool get isConfigured => endpoint.trim().isNotEmpty;
}
