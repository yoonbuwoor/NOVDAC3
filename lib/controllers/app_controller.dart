import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/remote_content_models.dart';
import '../services/background_update_service.dart';
import '../services/content_update_service.dart';
import '../services/notification_service.dart';
import '../services/registration_service.dart';

class AppController extends ChangeNotifier {
  AppController();

  static const String _notificationsEnabledKey = 'notifications.enabled';
  static const String _reminderFrequencyKey = 'notifications.reminderFrequency';
  static const String _learnerNameKey = 'profile.name';
  static const String _learnerProfessionKey = 'profile.profession';
  static const String _learnerEmailKey = 'profile.email';
  static const String _onboardingCompleteKey = 'profile.onboardingComplete';
  static const String _registrationSyncedKey = 'profile.registrationSynced';

  final Set<String> _completedLessons = <String>{};
  final Set<String> _completedMissions = <String>{};
  final Map<String, int> _missionScores = <String, int>{};
  final ContentUpdateService _contentService = ContentUpdateService();
  final RegistrationService _registrationService = RegistrationService();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  String learnerName = 'Explorateur';
  String learnerProfession = '';
  String learnerEmail = '';
  int xp = 120;
  int streak = 1;
  String selectedDomain = 'Cartographie & SIG';

  double altitude = 90;
  double areaHectares = 50;
  double frontOverlap = 80;
  double sideOverlap = 70;
  double speed = 7;
  double shutter = 800;
  double brightness = 0;
  double cameraAngle = 0;

  List<RemoteCourse> remoteCourses = const <RemoteCourse>[];
  ContentManifest? availableManifest;
  UpdateState updateState = UpdateState.idle;
  String? updateError;
  DateTime? lastContentCheck;
  int installedContentVersion = 0;
  bool notificationsEnabled = true;
  String reminderFrequency = 'daily';
  bool contentInitialized = false;

  bool onboardingComplete = false;
  bool registrationSynced = false;
  bool registrationSubmitting = false;
  String? registrationError;

  Set<String> get completedLessons => Set.unmodifiable(_completedLessons);
  Set<String> get completedMissions => Set.unmodifiable(_completedMissions);
  Map<String, int> get missionScores => Map.unmodifiable(_missionScores);
  bool get updateAvailable =>
      availableManifest != null &&
      availableManifest!.contentVersion > installedContentVersion;

  bool lessonCompleted(String id) => _completedLessons.contains(id);
  bool missionCompleted(String id) => _completedMissions.contains(id);

  Future<void> initialize() async {
    var shouldCheckOnline = true;
    try {
      learnerName = await _prefs.getString(_learnerNameKey) ?? 'Explorateur';
      learnerProfession =
          await _prefs.getString(_learnerProfessionKey) ?? '';
      learnerEmail = await _prefs.getString(_learnerEmailKey) ?? '';
      onboardingComplete =
          await _prefs.getBool(_onboardingCompleteKey) ?? false;
      registrationSynced =
          await _prefs.getBool(_registrationSyncedKey) ?? false;

      remoteCourses = await _contentService.loadInstalledCourses();
      installedContentVersion = await _contentService.getInstalledVersion();
      availableManifest = await _contentService.loadLastManifest();
      lastContentCheck = await _contentService.getLastCheckedAt();
      notificationsEnabled =
          await _prefs.getBool(_notificationsEnabledKey) ?? true;
      reminderFrequency =
          await _prefs.getString(_reminderFrequencyKey) ?? 'daily';

      if (onboardingComplete && notificationsEnabled && !kIsWeb) {
        final granted = await NotificationService.instance.requestPermission();
        if (!granted) {
          notificationsEnabled = false;
          await _prefs.setBool(_notificationsEnabledKey, false);
          await BackgroundUpdateService.refreshSchedule(enabled: false);
        }
      }

      updateState = updateAvailable ? UpdateState.available : UpdateState.idle;
    } catch (error) {
      updateError = error.toString();
      notificationsEnabled = false;
      shouldCheckOnline = false;
      updateState = UpdateState.idle;
    } finally {
      contentInitialized = true;
      notifyListeners();
    }

    if (onboardingComplete && !registrationSynced) {
      unawaited(_retryPendingRegistration());
    }
    if (shouldCheckOnline && onboardingComplete) {
      unawaited(checkForContentUpdates(silent: true));
    }
  }

  Future<bool> saveLearnerProfile({
    required String name,
    required String profession,
    required String email,
  }) async {
    if (registrationSubmitting) return false;

    final cleanName = name.trim();
    final cleanProfession = profession.trim();
    final cleanEmail = email.trim().toLowerCase();
    if (cleanName.length < 2 ||
        cleanProfession.length < 2 ||
        !_isValidEmail(cleanEmail)) {
      registrationError = 'Vérifie les informations renseignées.';
      notifyListeners();
      return false;
    }

    registrationSubmitting = true;
    registrationError = null;
    notifyListeners();

    try {
      await _storeLearnerProfile(
        name: cleanName,
        profession: cleanProfession,
        email: cleanEmail,
      );

      await _registrationService.submit(
        name: cleanName,
        profession: cleanProfession,
        email: cleanEmail,
      );

      registrationSynced = true;
      onboardingComplete = true;
      registrationError = null;
      await _prefs.setBool(_registrationSyncedKey, true);
      await _prefs.setBool(_onboardingCompleteKey, true);
      registrationSubmitting = false;
      notifyListeners();

      if (notificationsEnabled && !kIsWeb) {
        unawaited(setNotificationsEnabled(true));
      }
      unawaited(checkForContentUpdates(silent: true));
      return true;
    } on RegistrationException catch (error) {
      registrationSynced = false;
      onboardingComplete = false;
      registrationSubmitting = false;
      registrationError = error.message;
      await _prefs.setBool(_registrationSyncedKey, false);
      await _prefs.setBool(_onboardingCompleteKey, false);
      notifyListeners();
      return false;
    } catch (error) {
      registrationSynced = false;
      onboardingComplete = false;
      registrationSubmitting = false;
      registrationError = 'Impossible d’envoyer le profil : $error';
      await _prefs.setBool(_registrationSyncedKey, false);
      await _prefs.setBool(_onboardingCompleteKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLearnerProfile({
    required String name,
    required String profession,
    required String email,
  }) async {
    if (registrationSubmitting) return false;

    final cleanName = name.trim();
    final cleanProfession = profession.trim();
    final cleanEmail = email.trim().toLowerCase();
    if (cleanName.length < 2 ||
        cleanProfession.length < 2 ||
        !_isValidEmail(cleanEmail)) {
      registrationError = 'Vérifie les informations renseignées.';
      notifyListeners();
      return false;
    }

    registrationSubmitting = true;
    registrationError = null;
    notifyListeners();

    final wasAlreadyTransmitted = registrationSynced;
    try {
      await _storeLearnerProfile(
        name: cleanName,
        profession: cleanProfession,
        email: cleanEmail,
        markRegistrationPending: !wasAlreadyTransmitted,
      );

      // Une modification locale ne provoque jamais un second envoi si le
      // formulaire a déjà été transmis avec succès.
      if (wasAlreadyTransmitted) {
        registrationSynced = true;
        registrationSubmitting = false;
        await _prefs.setBool(_registrationSyncedKey, true);
        notifyListeners();
        return true;
      }

      await _registrationService.submit(
        name: cleanName,
        profession: cleanProfession,
        email: cleanEmail,
      );
      registrationSynced = true;
      registrationError = null;
      await _prefs.setBool(_registrationSyncedKey, true);
      registrationSubmitting = false;
      notifyListeners();
      return true;
    } on RegistrationException catch (error) {
      registrationSynced = false;
      registrationSubmitting = false;
      registrationError = error.message;
      await _prefs.setBool(_registrationSyncedKey, false);
      notifyListeners();
      return false;
    } catch (error) {
      registrationSynced = false;
      registrationSubmitting = false;
      registrationError = 'Impossible d’envoyer le profil : $error';
      await _prefs.setBool(_registrationSyncedKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPendingLearnerProfile() async {
    if (registrationSubmitting) return false;
    if (registrationSynced) {
      registrationError = null;
      notifyListeners();
      return true;
    }
    if (learnerName.trim().isEmpty ||
        learnerProfession.trim().isEmpty ||
        !_isValidEmail(learnerEmail.trim())) {
      registrationError = 'Le profil est incomplet. Modifie-le avant l’envoi.';
      notifyListeners();
      return false;
    }

    registrationSubmitting = true;
    registrationError = null;
    notifyListeners();
    try {
      await _registrationService.submit(
        name: learnerName,
        profession: learnerProfession,
        email: learnerEmail,
      );
      registrationSynced = true;
      registrationError = null;
      await _prefs.setBool(_registrationSyncedKey, true);
      registrationSubmitting = false;
      notifyListeners();
      return true;
    } on RegistrationException catch (error) {
      registrationSynced = false;
      registrationSubmitting = false;
      registrationError = error.message;
      await _prefs.setBool(_registrationSyncedKey, false);
      notifyListeners();
      return false;
    } catch (error) {
      registrationSynced = false;
      registrationSubmitting = false;
      registrationError = 'Impossible d’envoyer le profil : $error';
      await _prefs.setBool(_registrationSyncedKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<void> continueWithoutRegistrationSync() async {
    onboardingComplete = true;
    registrationSynced = false;
    registrationError =
        'Profil conservé sur l’appareil. Une connexion sera nécessaire pour effectuer l’unique transmission.';
    await _prefs.setBool(_onboardingCompleteKey, true);
    await _prefs.setBool(_registrationSyncedKey, false);
    notifyListeners();
  }

  Future<void> _storeLearnerProfile({
    required String name,
    required String profession,
    required String email,
    bool markRegistrationPending = true,
  }) async {
    learnerName = name;
    learnerProfession = profession;
    learnerEmail = email;
    await _prefs.setString(_learnerNameKey, name);
    await _prefs.setString(_learnerProfessionKey, profession);
    await _prefs.setString(_learnerEmailKey, email);
    if (markRegistrationPending) {
      registrationSynced = false;
      await _prefs.setBool(_registrationSyncedKey, false);
    }
  }

  Future<void> _retryPendingRegistration() async {
    if (learnerName.isEmpty || learnerProfession.isEmpty || learnerEmail.isEmpty) {
      return;
    }
    try {
      await _registrationService.submit(
        name: learnerName,
        profession: learnerProfession,
        email: learnerEmail,
      );
      registrationSynced = true;
      registrationError = null;
      await _prefs.setBool(_registrationSyncedKey, true);
      notifyListeners();
    } on RegistrationException catch (error) {
      registrationSynced = false;
      registrationError = error.message;
      notifyListeners();
    } catch (_) {
      // Un nouvel essai sera proposé depuis le profil et au prochain démarrage.
    }
  }

  bool _isValidEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);

  void completeLesson(String id) {
    if (_completedLessons.add(id)) {
      xp += 50;
      notifyListeners();
    }
  }

  void completeMission(String id, int score) {
    final firstCompletion = _completedMissions.add(id);
    final previous = _missionScores[id] ?? 0;
    if (score > previous) _missionScores[id] = score;
    if (firstCompletion) xp += 120;
    notifyListeners();
  }

  void setDomain(String value) {
    selectedDomain = value;
    notifyListeners();
  }

  void updatePlanner({
    double? newAltitude,
    double? newArea,
    double? newFrontOverlap,
    double? newSideOverlap,
    double? newSpeed,
  }) {
    altitude = newAltitude ?? altitude;
    areaHectares = newArea ?? areaHectares;
    frontOverlap = newFrontOverlap ?? frontOverlap;
    sideOverlap = newSideOverlap ?? sideOverlap;
    speed = newSpeed ?? speed;
    notifyListeners();
  }

  void updateCamera({
    double? newShutter,
    double? newBrightness,
    double? newCameraAngle,
  }) {
    shutter = newShutter ?? shutter;
    brightness = newBrightness ?? brightness;
    cameraAngle = newCameraAngle ?? cameraAngle;
    notifyListeners();
  }

  double courseProgress(int totalLessons) {
    if (totalLessons == 0) return 0;
    return (_completedLessons.length / totalLessons).clamp(0.0, 1.0).toDouble();
  }

  Future<void> checkForContentUpdates({bool silent = false}) async {
    if (updateState == UpdateState.checking ||
        updateState == UpdateState.downloading) {
      return;
    }
    updateState = UpdateState.checking;
    updateError = null;
    if (!silent) notifyListeners();

    try {
      final result = await _contentService.checkForUpdates();
      availableManifest = result.manifest;
      installedContentVersion = result.installedVersion;
      lastContentCheck = DateTime.now();
      updateState = result.updateAvailable
          ? UpdateState.available
          : UpdateState.current;

      if (result.updateAvailable && notificationsEnabled) {
        final lastNotified = await _contentService.getLastNotifiedVersion();
        if (result.manifest.contentVersion > lastNotified) {
          await NotificationService.instance
              .showUpdateAvailable(result.manifest);
          await _contentService
              .markVersionNotified(result.manifest.contentVersion);
        }
      }
    } catch (error) {
      updateError = error.toString();
      updateState = updateAvailable ? UpdateState.available : UpdateState.error;
    }
    notifyListeners();
  }

  Future<bool> installAvailableContent() async {
    final manifest = availableManifest;
    if (manifest == null || !updateAvailable) return false;

    updateState = UpdateState.downloading;
    updateError = null;
    notifyListeners();
    try {
      remoteCourses = await _contentService.install(manifest);
      installedContentVersion = manifest.contentVersion;
      updateState = UpdateState.current;
      xp += 30;
      if (notificationsEnabled) {
        await NotificationService.instance
            .showCoursesInstalled(remoteCourses.length);
      }
      notifyListeners();
      return true;
    } catch (error) {
      updateError = error.toString();
      updateState = UpdateState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> clearDownloadedContent() async {
    await _contentService.clearDownloadedContent();
    remoteCourses = const <RemoteCourse>[];
    installedContentVersion = 0;
    updateState = availableManifest == null
        ? UpdateState.idle
        : UpdateState.available;
    notifyListeners();
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        notificationsEnabled = false;
        await _prefs.setBool(_notificationsEnabledKey, false);
        await BackgroundUpdateService.refreshSchedule(enabled: false);
        notifyListeners();
        return false;
      }
    }
    notificationsEnabled = enabled;
    await _prefs.setBool(_notificationsEnabledKey, enabled);
    await BackgroundUpdateService.refreshSchedule(enabled: enabled);
    notifyListeners();
    return true;
  }

  Future<void> setReminderFrequency(String frequency) async {
    reminderFrequency = frequency;
    await _prefs.setString(_reminderFrequencyKey, frequency);
    notifyListeners();
  }


  @override
  void dispose() {
    _contentService.dispose();
    _registrationService.dispose();
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope introuvable dans le contexte');
    return scope!.notifier!;
  }
}
