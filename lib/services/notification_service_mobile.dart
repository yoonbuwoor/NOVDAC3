import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/remote_content_models.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _updateChannelId = 'droneatlas_updates';
  static const String _learningChannelId = 'droneatlas_learning';
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return androidGranted ?? iosGranted ?? true;
  }

  Future<void> showUpdateAvailable(ContentManifest manifest) async {
    await initialize();
    await _plugin.show(
      id: 2100 + manifest.contentVersion,
      title: 'Nouveaux cours DroneAtlas',
      body: '${manifest.title} • ${manifest.courses.length} contenu(s) disponible(s)',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _updateChannelId,
          'Mises à jour pédagogiques',
          channelDescription: 'Nouveaux cours, quiz et missions DroneAtlas',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'content-update',
    );
  }

  Future<void> showCoursesInstalled(int count) async {
    await initialize();
    await _plugin.show(
      id: 2201,
      title: 'Mise à jour terminée',
      body: '$count nouveau(x) cours sont maintenant disponibles hors connexion.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _updateChannelId,
          'Mises à jour pédagogiques',
          channelDescription: 'Nouveaux cours, quiz et missions DroneAtlas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'content-installed',
    );
  }

  Future<void> showLearningReminder() async {
    await initialize();
    await _plugin.show(
      id: 2301,
      title: 'Prêt pour une mission ?',
      body: 'Consacre quelques minutes à ton parcours DroneAtlas aujourd’hui.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _learningChannelId,
          'Rappels d’apprentissage',
          channelDescription: 'Rappels locaux pour poursuivre la formation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'learning-reminder',
    );
  }
}
