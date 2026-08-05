import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../models/remote_content_models.dart';
import '../widgets/common.dart';

class RemoteCourseDetailScreen extends StatefulWidget {
  const RemoteCourseDetailScreen({
    super.key,
    required this.course,
  });

  final RemoteCourse course;

  @override
  State<RemoteCourseDetailScreen> createState() =>
      _RemoteCourseDetailScreenState();
}

class _RemoteCourseDetailScreenState
    extends State<RemoteCourseDetailScreen> {
  int _pageIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;

  bool get _onQuiz => _pageIndex >= widget.course.pages.length;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final totalSteps = widget.course.pages.length + 1;
    final progress = (_pageIndex + 1) / totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Pill(
                label: widget.course.category.toUpperCase(),
                icon: Icons.cloud_done_rounded,
                color: violet,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: MaxWidthBox(
          maxWidth: 900,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _onQuiz
                                ? 'Validation finale'
                                : 'Étape ${_pageIndex + 1}/${widget.course.pages.length}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()} %',
                          style: const TextStyle(
                            color: cyan,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: _onQuiz
                      ? _buildQuiz(context)
                      : _buildPage(widget.course.pages[_pageIndex]),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    if (_pageIndex > 0)
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _pageIndex--;
                          _selectedAnswer = null;
                          _answered = false;
                        }),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Précédent'),
                      ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _onQuiz
                          ? (_answered
                              ? () {
                                  controller.completeLesson(
                                    'remote_${widget.course.id}',
                                  );
                                  Navigator.pop(context);
                                }
                              : null)
                          : () => setState(() => _pageIndex++),
                      icon: Icon(
                        _onQuiz
                            ? Icons.verified_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _onQuiz ? 'Valider le cours' : 'Continuer',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(RemoteCoursePage page) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pill(
          label: '${widget.course.level.toUpperCase()} • ${widget.course.duration}',
          icon: Icons.auto_stories_rounded,
          color: cyan,
        ),
        const SizedBox(height: 18),
        Text(
          page.title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          page.body,
          style: TextStyle(
            height: 1.65,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (page.highlight != null) ...[
          const SizedBox(height: 22),
          _InfoBox(
            icon: Icons.lightbulb_rounded,
            color: orange,
            title: 'À retenir',
            text: page.highlight!,
          ),
        ],
        if (page.tip != null) ...[
          const SizedBox(height: 14),
          _InfoBox(
            icon: Icons.tips_and_updates_rounded,
            color: success,
            title: 'Conseil DroneAtlas',
            text: page.tip!,
          ),
        ],
        if (_pageIndex == 0 && widget.course.objectives.isNotEmpty) ...[
          const SizedBox(height: 28),
          const SectionHeading(
            title: 'Objectifs du cours',
            subtitle: 'À la fin de cette leçon, tu sauras :',
          ),
          const SizedBox(height: 12),
          ...widget.course.objectives.map(
            (objective) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: cyan, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(objective)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuiz(BuildContext context) {
    final quiz = widget.course.quiz;
    final hasAnswers = quiz.answers.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Pill(
          label: 'QUIZ DE VALIDATION',
          icon: Icons.quiz_rounded,
          color: violet,
        ),
        const SizedBox(height: 18),
        Text(
          quiz.question,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        if (!hasAnswers)
          const EmptyState(
            icon: Icons.fact_check_rounded,
            title: 'Cours terminé',
            message: 'Ce cours ne contient pas encore de question de validation.',
          )
        else
          ...List.generate(quiz.answers.length, (index) {
            final selected = _selectedAnswer == index;
            final correct = _answered && index == quiz.correctAnswer;
            final wrong = _answered && selected && index != quiz.correctAnswer;
            final color = correct
                ? success
                : wrong
                    ? danger
                    : selected
                        ? cyan
                        : Theme.of(context).dividerColor;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: color, width: selected || correct ? 1.6 : 1),
                ),
                child: RadioListTile<int>(
                  value: index,
                  groupValue: _selectedAnswer,
                  onChanged: _answered
                      ? null
                      : (value) => setState(() => _selectedAnswer = value),
                  title: Text(
                    quiz.answers[index],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  secondary: _answered
                      ? Icon(
                          correct
                              ? Icons.check_circle_rounded
                              : wrong
                                  ? Icons.cancel_rounded
                                  : Icons.circle_outlined,
                          color: color,
                        )
                      : null,
                ),
              ),
            );
          }),
        const SizedBox(height: 10),
        if (hasAnswers && !_answered)
          FilledButton.icon(
            onPressed: _selectedAnswer == null
                ? null
                : () => setState(() => _answered = true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Vérifier ma réponse'),
          ),
        if (_answered) ...[
          const SizedBox(height: 16),
          _InfoBox(
            icon: _selectedAnswer == quiz.correctAnswer
                ? Icons.celebration_rounded
                : Icons.school_rounded,
            color: _selectedAnswer == quiz.correctAnswer ? success : orange,
            title: _selectedAnswer == quiz.correctAnswer
                ? 'Bonne réponse !'
                : 'À revoir',
            text: quiz.explanation,
          ),
        ],
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(text, style: const TextStyle(height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
