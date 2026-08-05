class ContentConfig {
  const ContentConfig._();

  /// Sources statiques du catalogue de cours. L’application essaie chaque
  /// adresse automatiquement afin de rester disponible même si l’une d’elles
  /// répond momentanément plus lentement.
  static const List<String> manifestUrls = <String>[
    'https://yoonbuwoor.github.io/DroneLearn3/content/manifest.json',
    'https://raw.githubusercontent.com/yoonbuwoor/DroneLearn3/main/content/manifest.json',
    'https://raw.githubusercontent.com/yoonbuwoor/DroneLearn3/master/content/manifest.json',
  ];

  static const Duration requestTimeout = Duration(seconds: 18);
  static const Duration backgroundCheckFrequency = Duration(hours: 6);
  static const String backgroundTaskName = 'droneatlas-content-check';
  static const String backgroundTaskId = 'droneatlas-periodic-content-check';
}
