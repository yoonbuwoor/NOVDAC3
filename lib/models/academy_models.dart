import 'package:flutter/material.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.summary,
    required this.icon,
    required this.pages,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.explanation,
  });

  final String id;
  final String title;
  final String duration;
  final String summary;
  final IconData icon;
  final List<LessonPage> pages;
  final String question;
  final List<String> answers;
  final int correctAnswer;
  final String explanation;
}

class LessonPage {
  const LessonPage({
    required this.title,
    required this.body,
    this.highlight,
    this.tip,
    this.visual,
    this.imageAsset,
    this.imageCaption,
    this.imageCredit,
  });

  final String title;
  final String body;
  final String? highlight;
  final String? tip;
  final LessonVisual? visual;
  final String? imageAsset;
  final String? imageCaption;
  final String? imageCredit;
}

enum LessonVisual {
  droneParts,
  cameraTriangle,
  overlap,
  gsd,
  flightPlan,
  matching,
  pointCloud,
  quality,
  mapLayout,
  report,
}

class AcademyModule {
  const AcademyModule({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.lessons,
  });

  final String id;
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<Lesson> lessons;
}

class ApplicationDomain {
  const ApplicationDomain({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.icon,
    required this.objective,
    required this.products,
    required this.flight,
    required this.watchouts,
  });

  final String id;
  final String title;
  final String subtitle;
  final String image;
  final IconData icon;
  final String objective;
  final List<String> products;
  final List<String> flight;
  final List<String> watchouts;
}

class MissionChoice {
  const MissionChoice({
    required this.label,
    required this.feedback,
    required this.score,
  });

  final String label;
  final String feedback;
  final int score;
}

class MissionStep {
  const MissionStep({
    required this.title,
    required this.context,
    required this.question,
    required this.choices,
  });

  final String title;
  final String context;
  final String question;
  final List<MissionChoice> choices;
}

class TrainingMission {
  const TrainingMission({
    required this.id,
    required this.title,
    required this.level,
    required this.duration,
    required this.image,
    required this.brief,
    required this.deliverable,
    required this.steps,
  });

  final String id;
  final String title;
  final String level;
  final String duration;
  final String image;
  final String brief;
  final String deliverable;
  final List<MissionStep> steps;
}

class QuizQuestion {
  const QuizQuestion({
    required this.category,
    required this.question,
    required this.answers,
    required this.correct,
    required this.explanation,
  });

  final String category;
  final String question;
  final List<String> answers;
  final int correct;
  final String explanation;
}

class GlossaryEntry {
  const GlossaryEntry(this.term, this.definition, this.category);

  final String term;
  final String definition;
  final String category;
}
