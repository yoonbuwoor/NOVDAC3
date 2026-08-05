import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/academy_data.dart';
import '../models/academy_models.dart';
import '../widgets/common.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.title = 'Quiz général',
    this.subtitle,
    this.questions,
  });

  final String title;
  final String? subtitle;
  final List<QuizQuestion>? questions;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _selected;
  bool _checked = false;
  int _score = 0;

  List<QuizQuestion> get _questions => widget.questions ?? quizQuestions;

  void _check() {
    if (_selected == null) return;
    setState(() {
      _checked = true;
      if (_selected == _questions[_index].correct) _score++;
    });
  }

  void _next() {
    if (_index == _questions.length - 1) {
      setState(() => _index++);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _checked = false;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _selected = null;
      _checked = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = _questions;
    final finished = _index >= questions.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: widget.subtitle == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
      ),
      body: finished
          ? _Result(
              score: _score,
              total: questions.length,
              onRestart: _restart,
            )
          : _QuestionView(
              questions: questions,
              index: _index,
              selected: _selected,
              checked: _checked,
              score: _score,
              onSelect: (value) {
                if (!_checked) setState(() => _selected = value);
              },
              onCheck: _check,
              onNext: _next,
            ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.questions,
    required this.index,
    required this.selected,
    required this.checked,
    required this.score,
    required this.onSelect,
    required this.onCheck,
    required this.onNext,
  });

  final List<QuizQuestion> questions;
  final int index;
  final int? selected;
  final bool checked;
  final int score;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final question = questions[index];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: MaxWidthBox(
            maxWidth: 820,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Question ${index + 1}/${questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    Text(
                      '$score bonne(s)',
                      style: const TextStyle(
                        color: cyan,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (index + 1) / questions.length,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(99),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: MaxWidthBox(
              maxWidth: 820,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(
                        label: question.category.toUpperCase(),
                        icon: Icons.category_rounded,
                        color: violet,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        question.question,
                        style: TextStyle(
                          fontSize: MediaQuery.sizeOf(context).width < 430 ? 20 : 24,
                          height: 1.24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(question.answers.length, (answerIndex) {
                        final active = selected == answerIndex;
                        final correct = answerIndex == question.correct;
                        Color? color;
                        if (!checked && active) color = cyan;
                        if (checked && correct) color = success;
                        if (checked && active && !correct) color = danger;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: color?.withOpacity(.11) ?? Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              onTap: () => onSelect(answerIndex),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: color?.withOpacity(.55) ??
                                        Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: color?.withOpacity(.16),
                                      foregroundColor: color,
                                      child: Text(
                                        String.fromCharCode(65 + answerIndex),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        question.answers[answerIndex],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (checked && correct)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: success,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      if (checked)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: orange.withOpacity(.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_rounded, color: orange),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  question.explanation,
                                  style: const TextStyle(
                                    height: 1.45,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: checked
                              ? onNext
                              : selected == null
                                  ? null
                                  : onCheck,
                          icon: Icon(
                            checked
                                ? Icons.arrow_forward_rounded
                                : Icons.check_rounded,
                          ),
                          label: Text(
                            checked
                                ? (index == questions.length - 1
                                    ? 'Voir le résultat'
                                    : 'Question suivante')
                                : 'Valider',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.score,
    required this.total,
    required this.onRestart,
  });

  final int score;
  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : score / total;
    final color = percent >= .75
        ? success
        : percent >= .5
            ? orange
            : danger;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: MaxWidthBox(
          maxWidth: 660,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  ProgressRing(
                    value: percent,
                    label: '${(percent * 100).round()} %',
                    size: 120,
                    color: color,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    percent >= .75
                        ? 'Très bon niveau !'
                        : percent >= .5
                            ? 'Bases acquises'
                            : 'Continue ton parcours',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '$score réponse(s) correcte(s) sur $total',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Recommencer le quiz'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.dashboard_rounded),
                      label: const Text('Retour aux quiz'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
