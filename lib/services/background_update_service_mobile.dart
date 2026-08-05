import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../config/content_config.dart';
import 'content_update_service.dart';
import 'notification_service.dart';

const String _notificationsEnabledKey = 'notifications.enabled';
const String _reminderFrequencyKey = 'notifications.reminderFrequency';
const String _lastReminderKey = 'notifications.lastReminderAt';

@pragma('vm:entry-point')
void droneAtlasCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final prefs = SharedPreferencesAsync();
    final notificationsEnabled =
        await prefs.getBool(_notificationsEnabledKey) ?? true;
    if (!notificationsEnabled) return true;

    final notificationService = NotificationService.instance;
    await notificationService.initialize();

    final contentService = ContentUpdateService();
    try {
      final result = await contentService.checkForUpdates();
      final lastNotified = await contentService.getLastNotifiedVersion();
      if (result.updateAvailable &&
          result.manifest.contentVersion > lastNotified) {
        await notificationService.showUpdateAvailable(result.manifest);
        await contentService.markVersionNotified(result.manifest.contentVersion);
      }
    } catch (_) {
      // Une indisponibilité réseau ne doit pas mettre la tâche en échec.
    } finally {
      contentService.dispose();
    }

    final frequency = await prefs.getString(_reminderFrequencyKey) ?? 'daily';
    if (frequency != 'off') {
      final now = DateTime.now();
      final rawLastReminder = await prefs.getString(_lastReminderKey);
      final lastReminder = rawLastReminder == null
          ? null
          : DateTime.tryParse(rawLastReminder)?.toLocal();
      final minimumGap = switch (frequency) {
        'daily' => const Duration(hours: 22),
        'three_per_week' => const Duration(hours: 54),
        _ => const Duration(days: 6),
      };
      if (lastReminder == null || now.difference(lastReminder) >= minimumGap) {
        await notificationService.showLearningReminder();
        await prefs.setString(_lastReminderKey, now.toUtc().toIso8601String());
      }
    }
    return true;
  });
}

class BackgroundUpdateService {
  static Future<void> initialize() async {
    await Workmanager().initialize(droneAtlasCallbackDispatcher);
    final prefs = SharedPreferencesAsync();
    final enabled = await prefs.getBool(_notificationsEnabledKey) ?? true;
    await refreshSchedule(enabled: enabled);
  }

  static Future<void> refreshSchedule({required bool enabled}) async {
    if (!enabled) {
      await Workmanager().cancelByUniqueName(ContentConfig.backgroundTaskId);
      return;
    }
    await Workmanager().registerPeriodicTask(
      ContentConfig.backgroundTaskId,
      ContentConfig.backgroundTaskName,
      frequency: ContentConfig.backgroundCheckFrequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 20),
    );
  }
}
