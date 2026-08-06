import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/remote_content_models.dart';
import '../services/account_deletion_service.dart';
import '../services/background_update_service.dart';
import '../services/content_update_service.dart';
import '../services/notification_service.dart';
import '../services/progress_sync_service.dart';
import '../services/registration_service.dart';

enum ProgressSyncState {
  idle,
  waitingForConnection,
  syncing,
  synced,
  error,
}

class AppController extends ChangeNotifier {
  AppController();

  static const String _notificationsEnabledKey = 'notifications.enabled';
  static const String _reminderFrequencyKey = 'notifications.reminderFrequency';
  static const String _learnerNameKey = 'profile.name';
  static const String _learnerProfessionKey = 'profile.profession';
  static const String _learnerEmailKey = 'profile.email';
  static const String _onboardingCompleteKey = 'profile.onboardingComplete';
  static const String _registrationSyncedKey = 'profile.registrationSynced';
  static const String _completedLessonsKey = 'progress.completedLessons';
  static const String _completedMissionsKey = 'progress.completedMissions';
  static const String _missionScoresKey = 'progress.missionScores';
  static const String _quizScoresKey = 'progress.quizScores';
  static const String _xpKey = 'progress.xp';
  static const String _progressPendingKey = 'progress.pendingSync';
  static const String _lastProgressSyncKey = 'progress.lastSyncedAt';
  static const String _communityInvitationHandledKey =
      'community.invitationHandled';

  final Set<String> _completedLessons = <String>{};
  final Set<String> _completedMissions = <String>{};
  final Map<String, int> _missionScores = <String, int>{};
  final Map<String, int> _quizScores = <String, int>{};
  final ContentUpdateService _contentService = ContentUpdateService();
  final RegistrationService _registrationService = RegistrationService();
  final ProgressSyncService _progressSyncService = ProgressSyncService();
  final AccountDeletionService _accountDeletionService = AccountDeletionService();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _networkAvailable = false;
  bool _progressSyncInFlight = false;

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

  ProgressSyncState progressSyncState = ProgressSyncState.idle;
  bool progressSyncPending = false;
  DateTime? lastProgressSyncedAt;
  String? progressSyncError;
  bool communityInvitationHandled = false;
  bool accountDeletionInProgress = false;
  String? accountDeletionError;

  Set<String> get completedLessons => Set.unmodifiable(_completedLessons);
  Set<String> get completedMissions => Set.unmodifiable(_completedMissions);
  Map<String, int> get missionScores => Map.unmodifiable(_missionScores);
  Map<String, int> get quizScores => Map.unmodifiable(_quizScores);
  String get progressSyncLabel {
    switch (progressSyncState) {
      case ProgressSyncState.waitingForConnection:
        return 'Progression enregistrée — en attente d’Internet';
      case ProgressSyncState.syncing:
        return 'Synchronisation de la progression…';
      case ProgressSyncState.synced:
        return 'Progression synchronisée';
      case ProgressSyncState.error:
        return 'Progression locale — nouvel essai automatique';
      case ProgressSyncState.idle:
        return progressSyncPending
            ? 'Progression enregistrée localement'
            : 'Progression protégée sur cet appareil';
    }
  }

  bool get canOfferCommunityInvitation =>
      !communityInvitationHandled &&
      (_completedLessons.isNotEmpty ||
          _completedMissions.isNotEmpty ||
          _quizScores.isNotEmpty);

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

      _completedLessons.addAll(
        await _prefs.getStringList(_completedLessonsKey) ?? const <String>[],
      );
      _completedMissions.addAll(
        await _prefs.getStringList(_completedMissionsKey) ?? const <String>[],
      );
      final storedScores = await _prefs.getString(_missionScoresKey);
      if (storedScores != null && storedScores.isNotEmpty) {
        final decoded = jsonDecode(storedScores);
        if (decoded is Map<String, dynamic>) {
          for (final entry in decoded.entries) {
            final value = entry.value;
            if (value is num) _missionScores[entry.key] = value.toInt();
          }
        }
      }
      final storedQuizScores = await _prefs.getString(_quizScoresKey);
      if (storedQuizScores != null && storedQuizScores.isNotEmpty) {
        final decoded = jsonDecode(storedQuizScores);
        if (decoded is Map<String, dynamic>) {
          for (final entry in decoded.entries) {
            final value = entry.value;
            if (value is num) _quizScores[entry.key] = value.toInt();
          }
        }
      }
      xp = await _prefs.getInt(_xpKey) ?? 120;
      progressSyncPending =
          await _prefs.getBool(_progressPendingKey) ?? false;
      final lastSyncRaw = await _prefs.getString(_lastProgressSyncKey);
      lastProgressSyncedAt = DateTime.tryParse(lastSyncRaw ?? '');
      progressSyncState = progressSyncPending
          ? ProgressSyncState.waitingForConnection
          : ProgressSyncState.idle;
      communityInvitationHandled =
          await _prefs.getBool(_communityInvitationHandledKey) ?? false;

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

    await _startConnectivityMonitoring();

    if (onboardingComplete && !registrationSynced && _networkAvailable) {
      unawaited(_retryPendingRegistration());
    }
    if (shouldCheckOnline && onboardingComplete) {
      unawaited(checkForContentUpdates(silent: true));
    }
    if (onboardingComplete &&
        (_completedLessons.isNotEmpty ||
            _completedMissions.isNotEmpty ||
            _quizScores.isNotEmpty)) {
      unawaited(syncProgress());
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
      _markProgressChanged();
    }
  }

  void completeMission(String id, int score) {
    final firstCompletion = _completedMissions.add(id);
    final previous = _missionScores[id] ?? 0;
    final betterScore = score > previous;
    if (betterScore) _missionScores[id] = score;
    if (firstCompletion) xp += 120;
    if (firstCompletion || betterScore) {
      _markProgressChanged();
    } else {
      notifyListeners();
    }
  }

  void completeQuiz(String id, int scorePercent) {
    final safeScore = scorePercent.clamp(0, 100).toInt();
    final previous = _quizScores[id];
    final firstCompletion = previous == null;
    if (firstCompletion || safeScore > previous) {
      _quizScores[id] = safeScore;
      if (firstCompletion) xp += 80;
      _markProgressChanged();
    } else {
      notifyListeners();
    }
  }

  void _markProgressChanged() {
    progressSyncPending = true;
    progressSyncError = null;
    progressSyncState = _networkAvailable
        ? ProgressSyncState.idle
        : ProgressSyncState.waitingForConnection;
    notifyListeners();
    unawaited(_persistProgress());
    if (_networkAvailable) unawaited(syncProgress());
  }

  Future<void> _persistProgress() async {
    await Future.wait<void>([
      _prefs.setStringList(
        _completedLessonsKey,
        _completedLessons.toList()..sort(),
      ),
      _prefs.setStringList(
        _completedMissionsKey,
        _completedMissions.toList()..sort(),
      ),
      _prefs.setString(_missionScoresKey, jsonEncode(_missionScores)),
      _prefs.setString(_quizScoresKey, jsonEncode(_quizScores)),
      _prefs.setInt(_xpKey, xp),
      _prefs.setBool(_progressPendingKey, progressSyncPending),
    ]);
  }

  Future<void> _startConnectivityMonitoring() async {
    try {
      final connectivity = Connectivity();
      final initial = await connectivity.checkConnectivity();
      _handleConnectivity(initial);
      _connectivitySubscription = connectivity.onConnectivityChanged.listen(
        _handleConnectivity,
        onError: (_) {
          _networkAvailable = false;
          if (progressSyncPending) {
            progressSyncState = ProgressSyncState.waitingForConnection;
            notifyListeners();
          }
        },
      );
    } catch (_) {
      _networkAvailable = false;
      if (progressSyncPending) {
        progressSyncState = ProgressSyncState.waitingForConnection;
      }
    }
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    final wasOnline = _networkAvailable;
    _networkAvailable =
        results.any((result) => result != ConnectivityResult.none);

    if (!_networkAvailable) {
      if (progressSyncPending) {
        progressSyncState = ProgressSyncState.waitingForConnection;
        notifyListeners();
      }
      return;
    }

    if (!wasOnline || progressSyncPending) {
      if (onboardingComplete && !registrationSynced) {
        unawaited(_retryPendingRegistration());
      }
      if (progressSyncPending ||
          _completedLessons.isNotEmpty ||
          _completedMissions.isNotEmpty ||
          _quizScores.isNotEmpty) {
        unawaited(syncProgress());
      }
    }
  }

  Future<bool> syncProgress({bool force = false}) async {
    if (_progressSyncInFlight) return false;
    if (_completedLessons.isEmpty &&
        _completedMissions.isEmpty &&
        _quizScores.isEmpty) {
      return true;
    }
    if (learnerName.trim().isEmpty || !_isValidEmail(learnerEmail.trim())) {
      progressSyncPending = true;
      progressSyncState = ProgressSyncState.idle;
      await _persistProgress();
      notifyListeners();
      return false;
    }
    if (!_networkAvailable && !force) {
      progressSyncPending = true;
      progressSyncState = ProgressSyncState.waitingForConnection;
      await _persistProgress();
      notifyListeners();
      return false;
    }

    _progressSyncInFlight = true;
    progressSyncState = ProgressSyncState.syncing;
    progressSyncError = null;
    notifyListeners();

    try {
      final response = await _progressSyncService.sync(<String, dynamic>{
        'schemaVersion': 1,
        'appName': 'Drone Atlas Academy',
        'appVersion': '3.5.1',
        'profile': <String, String>{
          'name': learnerName.trim(),
          'profession': learnerProfession.trim(),
          'email': learnerEmail.trim().toLowerCase(),
        },
        'progress': <String, dynamic>{
          'completedLessons': _completedLessons.toList()..sort(),
          'completedMissions': _completedMissions.toList()..sort(),
          'missionScores': _missionScores,
          'quizScores': _quizScores,
          'xp': xp,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        },
      });

      final merged = response['progress'];
      if (merged is Map<String, dynamic>) {
        final lessons = merged['completedLessons'];
        if (lessons is List) {
          _completedLessons.addAll(lessons.whereType<String>());
        }
        final missions = merged['completedMissions'];
        if (missions is List) {
          _completedMissions.addAll(missions.whereType<String>());
        }
        final scores = merged['missionScores'];
        if (scores is Map<String, dynamic>) {
          for (final entry in scores.entries) {
            final value = entry.value;
            if (value is num && value.toInt() > (_missionScores[entry.key] ?? 0)) {
              _missionScores[entry.key] = value.toInt();
            }
          }
        }
        final quizScores = merged['quizScores'];
        if (quizScores is Map<String, dynamic>) {
          for (final entry in quizScores.entries) {
            final value = entry.value;
            if (value is num && value.toInt() > (_quizScores[entry.key] ?? 0)) {
              _quizScores[entry.key] = value.toInt();
            }
          }
        }
        final remoteXp = merged['xp'];
        if (remoteXp is num && remoteXp.toInt() > xp) xp = remoteXp.toInt();
      }

      progressSyncPending = false;
      progressSyncState = ProgressSyncState.synced;
      progressSyncError = null;
      lastProgressSyncedAt = DateTime.now();
      await _prefs.setString(
        _lastProgressSyncKey,
        lastProgressSyncedAt!.toUtc().toIso8601String(),
      );
      await _persistProgress();
      notifyListeners();
      return true;
    } on ProgressSyncException catch (error) {
      progressSyncPending = true;
      progressSyncError = error.message;
      progressSyncState = _networkAvailable
          ? ProgressSyncState.error
          : ProgressSyncState.waitingForConnection;
      await _persistProgress();
      notifyListeners();
      return false;
    } catch (error) {
      progressSyncPending = true;
      progressSyncError = error.toString();
      progressSyncState = ProgressSyncState.error;
      await _persistProgress();
      notifyListeners();
      return false;
    } finally {
      _progressSyncInFlight = false;
    }
  }


  Future<bool> deleteCurrentAccount({required String password}) async {
    if (accountDeletionInProgress) return false;

    accountDeletionInProgress = true;
    accountDeletionError = null;
    notifyListeners();

    try {
      await _accountDeletionService.deleteCurrentAccount(password: password);
      await _clearLocalPersonalData();
      accountDeletionInProgress = false;
      accountDeletionError = null;
      notifyListeners();
      return true;
    } on AccountDeletionException catch (error) {
      accountDeletionInProgress = false;
      accountDeletionError = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      accountDeletionInProgress = false;
      accountDeletionError = 'Impossible de supprimer le compte : $error';
      notifyListeners();
      return false;
    }
  }

  Future<void> _clearLocalPersonalData() async {
    await BackgroundUpdateService.refreshSchedule(enabled: false);

    await Future.wait<void>([
      _prefs.remove(_learnerNameKey),
      _prefs.remove(_learnerProfessionKey),
      _prefs.remove(_learnerEmailKey),
      _prefs.remove(_onboardingCompleteKey),
      _prefs.remove(_registrationSyncedKey),
      _prefs.remove(_completedLessonsKey),
      _prefs.remove(_completedMissionsKey),
      _prefs.remove(_missionScoresKey),
      _prefs.remove(_quizScoresKey),
      _prefs.remove(_xpKey),
      _prefs.remove(_progressPendingKey),
      _prefs.remove(_lastProgressSyncKey),
      _prefs.remove(_communityInvitationHandledKey),
      _prefs.remove(_notificationsEnabledKey),
      _prefs.remove(_reminderFrequencyKey),
    ]);

    _completedLessons.clear();
    _completedMissions.clear();
    _missionScores.clear();
    _quizScores.clear();

    learnerName = 'Explorateur';
    learnerProfession = '';
    learnerEmail = '';
    xp = 120;
    streak = 1;
    selectedDomain = 'Cartographie & SIG';
    onboardingComplete = false;
    registrationSynced = false;
    registrationSubmitting = false;
    registrationError = null;
    notificationsEnabled = false;
    reminderFrequency = 'daily';
    progressSyncState = ProgressSyncState.idle;
    progressSyncPending = false;
    lastProgressSyncedAt = null;
    progressSyncError = null;
    communityInvitationHandled = false;
  }

  Future<void> markCommunityInvitationHandled() async {
    communityInvitationHandled = true;
    await _prefs.setBool(_communityInvitationHandledKey, true);
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
    _connectivitySubscription?.cancel();
    _contentService.dispose();
    _registrationService.dispose();
    _progressSyncService.dispose();
    _accountDeletionService.dispose();
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
