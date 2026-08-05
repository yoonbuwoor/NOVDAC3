import 'dart:convert';

class ContentManifest {
  const ContentManifest({
    required this.schemaVersion,
    required this.contentVersion,
    required this.publishedAt,
    required this.title,
    required this.description,
    required this.changelog,
    required this.courses,
  });

  final int schemaVersion;
  final int contentVersion;
  final DateTime publishedAt;
  final String title;
  final String description;
  final List<String> changelog;
  final List<RemoteCourseSummary> courses;

  factory ContentManifest.fromJson(Map<String, dynamic> json) {
    return ContentManifest(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      contentVersion: (json['contentVersion'] as num?)?.toInt() ?? 0,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      title: json['title'] as String? ?? 'Mise à jour DroneAtlas',
      description: json['description'] as String? ?? '',
      changelog: (json['changelog'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      courses: (json['courses'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(RemoteCourseSummary.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'schemaVersion': schemaVersion,
        'contentVersion': contentVersion,
        'publishedAt': publishedAt.toUtc().toIso8601String(),
        'title': title,
        'description': description,
        'changelog': changelog,
        'courses': courses.map((item) => item.toJson()).toList(),
      };

  String encode() => jsonEncode(toJson());
}

class RemoteCourseSummary {
  const RemoteCourseSummary({
    required this.id,
    required this.version,
    required this.title,
    required this.summary,
    required this.category,
    required this.duration,
    required this.url,
    required this.accent,
    required this.icon,
  });

  final String id;
  final int version;
  final String title;
  final String summary;
  final String category;
  final String duration;
  final String url;
  final String accent;
  final String icon;

  factory RemoteCourseSummary.fromJson(Map<String, dynamic> json) {
    return RemoteCourseSummary(
      id: json['id'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? 'Nouveau cours',
      summary: json['summary'] as String? ?? '',
      category: json['category'] as String? ?? 'DroneAtlas',
      duration: json['duration'] as String? ?? '10 min',
      url: json['url'] as String? ?? '',
      accent: json['accent'] as String? ?? 'cyan',
      icon: json['icon'] as String? ?? 'school',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'version': version,
        'title': title,
        'summary': summary,
        'category': category,
        'duration': duration,
        'url': url,
        'accent': accent,
        'icon': icon,
      };
}

class RemoteCourse {
  const RemoteCourse({
    required this.id,
    required this.version,
    required this.title,
    required this.summary,
    required this.category,
    required this.duration,
    required this.level,
    required this.objectives,
    required this.pages,
    required this.quiz,
  });

  final String id;
  final int version;
  final String title;
  final String summary;
  final String category;
  final String duration;
  final String level;
  final List<String> objectives;
  final List<RemoteCoursePage> pages;
  final RemoteCourseQuiz quiz;

  factory RemoteCourse.fromJson(Map<String, dynamic> json) {
    return RemoteCourse(
      id: json['id'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? 'Cours DroneAtlas',
      summary: json['summary'] as String? ?? '',
      category: json['category'] as String? ?? 'DroneAtlas',
      duration: json['duration'] as String? ?? '10 min',
      level: json['level'] as String? ?? 'Débutant',
      objectives: (json['objectives'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      pages: (json['pages'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(RemoteCoursePage.fromJson)
          .toList(growable: false),
      quiz: RemoteCourseQuiz.fromJson(
        json['quiz'] is Map<String, dynamic>
            ? json['quiz'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'version': version,
        'title': title,
        'summary': summary,
        'category': category,
        'duration': duration,
        'level': level,
        'objectives': objectives,
        'pages': pages.map((item) => item.toJson()).toList(),
        'quiz': quiz.toJson(),
      };

  String encode() => jsonEncode(toJson());
}

class RemoteCoursePage {
  const RemoteCoursePage({
    required this.title,
    required this.body,
    this.highlight,
    this.tip,
  });

  final String title;
  final String body;
  final String? highlight;
  final String? tip;

  factory RemoteCoursePage.fromJson(Map<String, dynamic> json) {
    return RemoteCoursePage(
      title: json['title'] as String? ?? 'Étape',
      body: json['body'] as String? ?? '',
      highlight: json['highlight'] as String?,
      tip: json['tip'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'body': body,
        if (highlight != null) 'highlight': highlight,
        if (tip != null) 'tip': tip,
      };
}

class RemoteCourseQuiz {
  const RemoteCourseQuiz({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.explanation,
  });

  final String question;
  final List<String> answers;
  final int correctAnswer;
  final String explanation;

  factory RemoteCourseQuiz.fromJson(Map<String, dynamic> json) {
    return RemoteCourseQuiz(
      question: json['question'] as String? ?? 'As-tu compris ce cours ?',
      answers: (json['answers'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      correctAnswer: (json['correctAnswer'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'question': question,
        'answers': answers,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
      };
}

enum UpdateState { idle, checking, available, downloading, current, error }

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.manifest,
    required this.installedVersion,
  });

  final ContentManifest manifest;
  final int installedVersion;

  bool get updateAvailable => manifest.contentVersion > installedVersion;
}
