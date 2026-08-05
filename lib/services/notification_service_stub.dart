import '../models/remote_content_models.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {}
  Future<bool> requestPermission() async => false;
  Future<void> showUpdateAvailable(ContentManifest manifest) async {}
  Future<void> showCoursesInstalled(int count) async {}
  Future<void> showLearningReminder() async {}
}
