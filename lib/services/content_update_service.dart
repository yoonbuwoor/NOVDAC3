import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/content_config.dart';
import '../models/remote_content_models.dart';

class ContentUpdateException implements Exception {
  const ContentUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ContentUpdateService {
  ContentUpdateService({http.Client? client}) : _client = client ?? http.Client();

  static const String _installedVersionKey = 'content.installedVersion';
  static const String _installedCourseIdsKey = 'content.installedCourseIds';
  static const String _lastManifestKey = 'content.lastManifest';
  static const String _lastManifestUrlKey = 'content.lastManifestUrl';
  static const String _lastCheckedKey = 'content.lastCheckedAt';
  static const String _lastNotifiedVersionKey = 'content.lastNotifiedVersion';
  static const String _coursePrefix = 'content.course.';

  final http.Client _client;
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<UpdateCheckResult> checkForUpdates() async {
    for (final source in ContentConfig.manifestUrls) {
      try {
        final response = await _client
            .get(Uri.parse(source))
            .timeout(ContentConfig.requestTimeout);
        if (response.statusCode != 200) {
          continue;
        }

        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is! Map<String, dynamic>) {
          continue;
        }

        final manifest = ContentManifest.fromJson(decoded);
        await _prefs.setString(_lastManifestKey, manifest.encode());
        await _prefs.setString(_lastManifestUrlKey, source);
        await _prefs.setString(
          _lastCheckedKey,
          DateTime.now().toUtc().toIso8601String(),
        );
        final installedVersion = await getInstalledVersion();
        return UpdateCheckResult(
          manifest: manifest,
          installedVersion: installedVersion,
        );
      } catch (_) {
        // Essaie automatiquement la source suivante.
      }
    }

    throw ContentUpdateException(
      'Le catalogue pédagogique est momentanément inaccessible. '
      'Vérifie ta connexion Internet puis réessaie.',
    );
  }

  Future<List<RemoteCourse>> install(ContentManifest manifest) async {
    final preferredSource = await _prefs.getString(_lastManifestUrlKey);
    final sources = <String>[
      if (preferredSource != null) preferredSource,
      ...ContentConfig.manifestUrls.where((url) => url != preferredSource),
    ];
    final downloaded = <RemoteCourse>[];

    for (final summary in manifest.courses) {
      if (summary.id.isEmpty || summary.url.isEmpty) continue;
      RemoteCourse? course;
      Object? lastError;

      for (final source in sources) {
        try {
          final courseUri = Uri.parse(source).resolve(summary.url);
          final response = await _client
              .get(courseUri)
              .timeout(ContentConfig.requestTimeout);
          if (response.statusCode != 200) {
            lastError = 'code ${response.statusCode}';
            continue;
          }
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is! Map<String, dynamic>) {
            lastError = 'fichier JSON invalide';
            continue;
          }
          final candidate = RemoteCourse.fromJson(decoded);
          if (candidate.id.isEmpty || candidate.id != summary.id) {
            lastError = 'identifiant incohérent';
            continue;
          }
          course = candidate;
          await _prefs.setString(_lastManifestUrlKey, source);
          break;
        } catch (error) {
          lastError = error;
        }
      }

      if (course == null) {
        throw ContentUpdateException(
          'Impossible de télécharger « ${summary.title} » '
          '(${lastError ?? 'source indisponible'}).',
        );
      }
      await _prefs.setString('$_coursePrefix${course.id}', course.encode());
      downloaded.add(course);
    }

    await _prefs.setStringList(
      _installedCourseIdsKey,
      downloaded.map((course) => course.id).toList(growable: false),
    );
    await _prefs.setInt(_installedVersionKey, manifest.contentVersion);
    await _prefs.setString(_lastManifestKey, manifest.encode());
    return downloaded;
  }

  Future<List<RemoteCourse>> loadInstalledCourses() async {
    final ids =
        await _prefs.getStringList(_installedCourseIdsKey) ?? const <String>[];
    final courses = <RemoteCourse>[];
    for (final id in ids) {
      final raw = await _prefs.getString('$_coursePrefix$id');
      if (raw == null || raw.isEmpty) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          courses.add(RemoteCourse.fromJson(decoded));
        }
      } on FormatException {
        // Ignore un ancien cours corrompu sans bloquer l’application.
      }
    }
    return courses;
  }

  Future<ContentManifest?> loadLastManifest() async {
    final raw = await _prefs.getString(_lastManifestKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? ContentManifest.fromJson(decoded)
          : null;
    } on FormatException {
      return null;
    }
  }

  Future<int> getInstalledVersion() async =>
      await _prefs.getInt(_installedVersionKey) ?? 0;

  Future<DateTime?> getLastCheckedAt() async {
    final raw = await _prefs.getString(_lastCheckedKey);
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  }

  Future<int> getLastNotifiedVersion() async =>
      await _prefs.getInt(_lastNotifiedVersionKey) ?? 0;

  Future<void> markVersionNotified(int version) async {
    await _prefs.setInt(_lastNotifiedVersionKey, version);
  }

  Future<void> clearDownloadedContent() async {
    final ids =
        await _prefs.getStringList(_installedCourseIdsKey) ?? const <String>[];
    for (final id in ids) {
      await _prefs.remove('$_coursePrefix$id');
    }
    await _prefs.remove(_installedCourseIdsKey);
    await _prefs.remove(_installedVersionKey);
  }

  void dispose() => _client.close();
}
