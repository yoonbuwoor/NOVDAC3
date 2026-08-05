import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../models/academy_models.dart';
import '../widgets/common.dart';
import '../widgets/learning_visuals.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.module,
    required this.initialLesson,
  });

  final AcademyModule module;
  final Lesson initialLesson;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late int _lessonIndex;
  int _page = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  late final PageController _pageController;

  Lesson get _lesson => widget.module.lessons[_lessonIndex];

  @override
  void initState() {
    super.initState();
    _lessonIndex = widget.module.lessons.indexOf(widget.initialLesson);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectLesson(int index) {
    setState(() {
      _lessonIndex = index;
      _page = 0;
      _selectedAnswer = null;
      _showResult = false;
    });
    _pageController.jumpToPage(0);
  }

  void _nextPage() {
    if (_page < _lesson.pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _validate() {
    if (_selectedAnswer == null) return;
    setState(() => _showResult = true);
    if (_selectedAnswer == _lesson.correctAnswer) {
      AppScope.of(context).completeLesson(_lesson.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final completed = controller.lessonCompleted(_lesson.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Pill(label: completed ? 'VALIDÉE' : _lesson.duration, icon: completed ? Icons.check_rounded : Icons.timer_outlined, color: completed ? success : widget.module.accent),
          ),
        ],
      ),
      body: Row(
        children: [
          if (MediaQuery.sizeOf(context).width >= 900)
            SizedBox(
              width: 290,
              child: _LessonSidebar(
                module: widget.module,
                selected: _lessonIndex,
                controller: controller,
                onSelect: _selectLesson,
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _LessonHeader(
                  module: widget.module,
                  lesson: _lesson,
                  currentPage: _page,
                  totalPages: _lesson.pages.length,
                  onOpenOutline: MediaQuery.sizeOf(context).width >= 900
                      ? null
                      : () => _showOutline(context, controller),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _lesson.pages.length + 1,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemBuilder: (context, index) {
                      if (index == _lesson.pages.length) {
                        return _QuizPage(
                          lesson: _lesson,
                          selected: _selectedAnswer,
                          showResult: _showResult,
                          onSelect: (value) {
                            if (!_showResult) setState(() => _selectedAnswer = value);
                          },
                          onValidate: _validate,
                        );
                      }
                      return _ContentPage(page: _lesson.pages[index], accent: widget.module.accent);
                    },
                  ),
                ),
                _BottomControls(
                  page: _page,
                  totalContentPages: _lesson.pages.length,
                  showResult: _showResult,
                  correct: _selectedAnswer == _lesson.correctAnswer,
                  onPrevious: () => _pageController.previousPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut),
                  onNext: _nextPage,
                  onQuiz: () => _pageController.animateToPage(_lesson.pages.length, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                  onFinish: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOutline(BuildContext context, AppController controller) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: 430,
        child: _LessonSidebar(
          module: widget.module,
          selected: _lessonIndex,
          controller: controller,
          onSelect: (index) {
            Navigator.pop(context);
            _selectLesson(index);
          },
        ),
      ),
    );
  }
}

class _LessonSidebar extends StatelessWidget {
  const _LessonSidebar({
    required this.module,
    required this.selected,
    required this.controller,
    required this.onSelect,
  });

  final AcademyModule module;
  final int selected;
  final AppController controller;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              GradientIcon(icon: module.icon, color: module.accent, size: 48),
              const SizedBox(width: 12),
              Expanded(child: Text('Module ${module.number}', style: TextStyle(color: module.accent, fontWeight: FontWeight.w900))),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(module.lessons.length, (index) {
            final lesson = module.lessons[index];
            final active = index == selected;
            final done = controller.lessonCompleted(lesson.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: active ? module.accent.withOpacity(.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  onTap: () => onSelect(index),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: CircleAvatar(
                    backgroundColor: done ? success.withOpacity(.16) : module.accent.withOpacity(.12),
                    foregroundColor: done ? success : module.accent,
                    child: Icon(done ? Icons.check_rounded : lesson.icon, size: 20),
                  ),
                  title: Text(lesson.title, style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w700, fontSize: 13)),
                  subtitle: Text(lesson.duration, style: const TextStyle(fontSize: 11)),
                ),
              ),
            );
          }),
          const Divider(height: 28),
          const Text('Conseil', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          Text('Prends le temps d’observer les schémas puis réponds à la question sans revenir en arrière.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.module,
    required this.lesson,
    required this.currentPage,
    required this.totalPages,
    required this.onOpenOutline,
  });

  final AcademyModule module;
  final Lesson lesson;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onOpenOutline;

  @override
  Widget build(BuildContext context) {
    final totalWithQuiz = totalPages + 1;
    final displayPage = (currentPage + 1).clamp(1, totalWithQuiz).toInt();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              if (onOpenOutline != null) ...[
                IconButton.filledTonal(onPressed: onOpenOutline, icon: const Icon(Icons.format_list_bulleted_rounded)),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(currentPage < totalPages ? 'Partie $displayPage sur $totalPages' : 'Vérification des acquis', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Text('$displayPage/$totalWithQuiz', style: TextStyle(color: module.accent, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: displayPage / totalWithQuiz,
            minHeight: 6,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: module.accent.withOpacity(.12),
            valueColor: AlwaysStoppedAnimation(module.accent),
          ),
        ],
      ),
    );
  }
}

class _ContentPage extends StatelessWidget {
  const _ContentPage({required this.page, required this.accent});

  final LessonPage page;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      child: MaxWidthBox(
        maxWidth: 850,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 5, height: 34, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(99))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(page.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -.6))),
                  ],
                ),
                const SizedBox(height: 20),
                Text(page.body, style: const TextStyle(fontSize: 16, height: 1.65, fontWeight: FontWeight.w500)),
                if (page.imageAsset != null) ...[
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        page.imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_rounded, size: 42),
                        ),
                      ),
                    ),
                  ),
                  if (page.imageCaption != null || page.imageCredit != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      [page.imageCaption, page.imageCredit]
                          .whereType<String>()
                          .where((value) => value.trim().isNotEmpty)
                          .join(' • '),
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
                if (page.visual != null) ...[
                  const SizedBox(height: 24),
                  LessonVisualCard(visual: page.visual!),
                ],
                if (page.highlight != null) ...[
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(.11),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: accent.withOpacity(.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: accent),
                        const SizedBox(width: 12),
                        Expanded(child: Text(page.highlight!, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.45))),
                      ],
                    ),
                  ),
                ],
                if (page.tip != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(color: orange.withOpacity(.10), borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: orange),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Conseil terrain\n${page.tip!}', style: const TextStyle(height: 1.45, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizPage extends StatelessWidget {
  const _QuizPage({
    required this.lesson,
    required this.selected,
    required this.showResult,
    required this.onSelect,
    required this.onValidate,
  });

  final Lesson lesson;
  final int? selected;
  final bool showResult;
  final ValueChanged<int> onSelect;
  final VoidCallback onValidate;

  @override
  Widget build(BuildContext context) {
    final correct = selected == lesson.correctAnswer;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      child: MaxWidthBox(
        maxWidth: 820,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Pill(label: 'QUESTION DE VALIDATION', icon: Icons.quiz_rounded, color: orange),
                const SizedBox(height: 18),
                Text(lesson.question, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 22),
                ...List.generate(lesson.answers.length, (index) {
                  final isSelected = selected == index;
                  final isCorrect = index == lesson.correctAnswer;
                  Color? color;
                  if (showResult && isCorrect) color = success;
                  if (showResult && isSelected && !isCorrect) color = danger;
                  if (!showResult && isSelected) color = cyan;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: color?.withOpacity(.12) ?? Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => onSelect(index),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: color?.withOpacity(.6) ?? Theme.of(context).dividerColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: color?.withOpacity(.18) ?? Theme.of(context).colorScheme.surfaceContainerHighest,
                                foregroundColor: color,
                                child: Text(String.fromCharCode(65 + index), style: const TextStyle(fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(lesson.answers[index], style: const TextStyle(fontWeight: FontWeight.w700))),
                              if (showResult && isCorrect) const Icon(Icons.check_circle_rounded, color: success),
                              if (showResult && isSelected && !isCorrect) const Icon(Icons.cancel_rounded, color: danger),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                if (!showResult)
                  SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: selected == null ? null : onValidate, icon: const Icon(Icons.check_rounded), label: const Text('Valider ma réponse'))),
                if (showResult)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: (correct ? success : orange).withOpacity(.11),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(correct ? Icons.verified_rounded : Icons.lightbulb_rounded, color: correct ? success : orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(correct ? 'Leçon validée • +50 XP' : 'À retenir', style: TextStyle(color: correct ? success : orange, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 5),
                              Text(lesson.explanation, style: const TextStyle(height: 1.45)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.page,
    required this.totalContentPages,
    required this.showResult,
    required this.correct,
    required this.onPrevious,
    required this.onNext,
    required this.onQuiz,
    required this.onFinish,
  });

  final int page;
  final int totalContentPages;
  final bool showResult;
  final bool correct;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onQuiz;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final onQuizPage = page >= totalContentPages;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: MaxWidthBox(
        maxWidth: 850,
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: page == 0 ? null : onPrevious,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Précédent'),
            ),
            const Spacer(),
            if (!onQuizPage && page < totalContentPages - 1)
              FilledButton.icon(onPressed: onNext, icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Continuer')),
            if (!onQuizPage && page == totalContentPages - 1)
              FilledButton.icon(onPressed: onQuiz, icon: const Icon(Icons.quiz_rounded), label: const Text('Passer au quiz')),
            if (onQuizPage && showResult)
              FilledButton.icon(onPressed: onFinish, icon: Icon(correct ? Icons.celebration_rounded : Icons.replay_rounded), label: Text(correct ? 'Terminer' : 'Revoir plus tard')),
          ],
        ),
      ),
    );
  }
}
