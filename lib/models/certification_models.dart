class CertificationExamSummary {
  const CertificationExamSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.isFinal,
    required this.passed,
    required this.locked,
    required this.passScore,
    required this.questionCount,
    this.bestScore,
    this.lockReason,
  });

  final String id;
  final String title;
  final String description;
  final bool isFinal;
  final bool passed;
  final bool locked;
  final int passScore;
  final int questionCount;
  final int? bestScore;
  final String? lockReason;

  factory CertificationExamSummary.fromJson(Map<String, dynamic> json) {
    return CertificationExamSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isFinal: json['isFinal'] as bool? ?? false,
      passed: json['passed'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
      passScore: (json['passScore'] as num?)?.toInt() ?? 70,
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt(),
      lockReason: json['lockReason'] as String?,
    );
  }
}

class CertificationPathSummary {
  const CertificationPathSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.exams,
    required this.completed,
    this.certificateId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String code;
  final List<CertificationExamSummary> exams;
  final bool completed;
  final String? certificateId;

  factory CertificationPathSummary.fromJson(Map<String, dynamic> json) {
    return CertificationPathSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      code: json['code'] as String? ?? '',
      exams: (json['exams'] as List<dynamic>? ?? const [])
          .map((item) => CertificationExamSummary.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
      completed: json['completed'] as bool? ?? false,
      certificateId: json['certificateId'] as String?,
    );
  }
}

class CertificationQuestion {
  const CertificationQuestion({
    required this.id,
    required this.prompt,
    required this.options,
  });

  final String id;
  final String prompt;
  final List<CertificationOption> options;

  factory CertificationQuestion.fromJson(Map<String, dynamic> json) {
    return CertificationQuestion(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>)
          .map((item) => CertificationOption.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
    );
  }
}

class CertificationOption {
  const CertificationOption({required this.id, required this.text});

  final String id;
  final String text;

  factory CertificationOption.fromJson(Map<String, dynamic> json) {
    return CertificationOption(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }
}

class CertificationExamSession {
  const CertificationExamSession({
    required this.token,
    required this.title,
    required this.durationSeconds,
    required this.questions,
  });

  final String token;
  final String title;
  final int durationSeconds;
  final List<CertificationQuestion> questions;

  factory CertificationExamSession.fromJson(Map<String, dynamic> json) {
    return CertificationExamSession(
      token: json['token'] as String,
      title: json['title'] as String,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((item) => CertificationQuestion.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
    );
  }
}

class CertificationExamResult {
  const CertificationExamResult({
    required this.passed,
    required this.score,
    required this.passScore,
    required this.isFinal,
    required this.certificateEligible,
    this.message,
  });

  final bool passed;
  final int score;
  final int passScore;
  final bool isFinal;
  final bool certificateEligible;
  final String? message;

  factory CertificationExamResult.fromJson(Map<String, dynamic> json) {
    return CertificationExamResult(
      passed: json['passed'] as bool? ?? false,
      score: (json['score'] as num?)?.toInt() ?? 0,
      passScore: (json['passScore'] as num?)?.toInt() ?? 0,
      isFinal: json['isFinal'] as bool? ?? false,
      certificateEligible: json['certificateEligible'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

class IssuedCertificate {
  const IssuedCertificate({
    required this.id,
    required this.pathTitle,
    required this.fullName,
  });

  final String id;
  final String pathTitle;
  final String fullName;

  factory IssuedCertificate.fromJson(Map<String, dynamic> json) {
    return IssuedCertificate(
      id: json['certificateId'] as String,
      pathTitle: json['pathTitle'] as String,
      fullName: json['fullName'] as String,
    );
  }
}
