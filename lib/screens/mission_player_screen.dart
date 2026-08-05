import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../models/academy_models.dart';
import '../widgets/common.dart';
import 'report_screen.dart';

class MissionPlayerScreen extends StatefulWidget {
  const MissionPlayerScreen({super.key, required this.mission});

  final TrainingMission mission;

  @override
  State<MissionPlayerScreen> createState() => _MissionPlayerScreenState();
}

class _MissionPlayerScreenState extends State<MissionPlayerScreen> {
  int _step = 0;
  int? _selected;
  bool _validated = false;
  int _score = 0;
  final List<int> _answers = [];

  MissionStep get current => widget.mission.steps[_step];

  void _validate() {
    if (_selected == null) return;
    final points = current.choices[_selected!].score;
    setState(() {
      _validated = true;
      _score += points;
      _answers.add(_selected!);
    });
  }

  void _next() {
    if (_step == widget.mission.steps.length - 1) {
      AppScope.of(context).completeMission(widget.mission.id, _score);
      setState(() => _step++);
      return;
    }
    setState(() {
      _step++;
      _selected = null;
      _validated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final finished = _step >= widget.mission.steps.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mission.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Pill(label: '$_score PTS', icon: Icons.bolt_rounded, color: orange),
          ),
        ],
      ),
      body: finished ? _MissionResult(mission: widget.mission, score: _score, answers: _answers) : _MissionStepView(
        mission: widget.mission,
        step: current,
        index: _step,
        selected: _selected,
        validated: _validated,
        onSelect: (value) {
          if (!_validated) setState(() => _selected = value);
        },
        onValidate: _validate,
        onNext: _next,
      ),
    );
  }
}

class _MissionStepView extends StatelessWidget {
  const _MissionStepView({
    required this.mission,
    required this.step,
    required this.index,
    required this.selected,
    required this.validated,
    required this.onSelect,
    required this.onValidate,
    required this.onNext,
  });

  final TrainingMission mission;
  final MissionStep step;
  final int index;
  final int? selected;
  final bool validated;
  final ValueChanged<int> onSelect;
  final VoidCallback onValidate;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = index == mission.steps.length - 1;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: MaxWidthBox(
            maxWidth: 960,
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Décision ${index + 1}/${mission.steps.length}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('${((index + 1) / mission.steps.length * 100).round()} %', style: const TextStyle(color: cyan, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: (index + 1) / mission.steps.length, minHeight: 7, borderRadius: BorderRadius.circular(99)),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            child: MaxWidthBox(
              maxWidth: 960,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final contextCard = Container(
                    height: wide ? 520 : 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: DecorationImage(image: AssetImage(mission.image), fit: BoxFit.cover),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [navy.withOpacity(.06), navy.withOpacity(.96)])),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Pill(label: step.title.toUpperCase(), icon: Icons.location_searching_rounded),
                          const SizedBox(height: 14),
                          Text(step.context, style: const TextStyle(color: Colors.white, fontSize: 22, height: 1.3, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 13),
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: orange, size: 19),
                              SizedBox(width: 8),
                              Expanded(child: Text('Analyse la situation avant de choisir.', style: TextStyle(color: Colors.white70, fontSize: 12))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  final decisionCard = Card(
                    child: Padding(
                      padding: const EdgeInsets.all(21),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Pill(label: 'TA DÉCISION', icon: Icons.psychology_rounded, color: violet),
                          const SizedBox(height: 16),
                          Text(step.question, style: const TextStyle(fontSize: 23, height: 1.22, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 18),
                          ...List.generate(step.choices.length, (choiceIndex) {
                            final choice = step.choices[choiceIndex];
                            final active = selected == choiceIndex;
                            Color? color;
                            if (active && !validated) color = cyan;
                            if (active && validated) color = choice.score >= 18 ? success : choice.score >= 7 ? orange : danger;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: color?.withOpacity(.11) ?? Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  onTap: () => onSelect(choiceIndex),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: color?.withOpacity(.5) ?? Theme.of(context).dividerColor)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(radius: 16, backgroundColor: color?.withOpacity(.18), foregroundColor: color, child: Text(String.fromCharCode(65 + choiceIndex), style: const TextStyle(fontWeight: FontWeight.w900))),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(choice.label, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (validated && selected != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: _feedbackColor(step.choices[selected!].score).withOpacity(.1), borderRadius: BorderRadius.circular(18)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.auto_awesome_rounded, color: _feedbackColor(step.choices[selected!].score)),
                                  const SizedBox(width: 11),
                                  Expanded(child: Text('${step.choices[selected!].feedback}\n\n+${step.choices[selected!].score} points', style: const TextStyle(height: 1.42, fontWeight: FontWeight.w700))),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: validated ? onNext : selected == null ? null : onValidate,
                              icon: Icon(validated ? (isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded) : Icons.check_rounded),
                              label: Text(validated ? (isLast ? 'Voir mon bilan' : 'Décision suivante') : 'Confirmer mon choix'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 5, child: contextCard), const SizedBox(width: 16), Expanded(flex: 6, child: decisionCard)]);
                  return Column(children: [contextCard, const SizedBox(height: 16), decisionCard]);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Color _feedbackColor(int score) => score >= 18 ? success : score >= 7 ? orange : danger;
}

class _MissionResult extends StatelessWidget {
  const _MissionResult({required this.mission, required this.score, required this.answers});

  final TrainingMission mission;
  final int score;
  final List<int> answers;

  @override
  Widget build(BuildContext context) {
    final color = score >= 80 ? success : score >= 55 ? orange : danger;
    final title = score >= 80 ? 'Mission maîtrisée !' : score >= 55 ? 'Mission réussie, à consolider' : 'Mission à reprendre';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: MaxWidthBox(
        maxWidth: 900,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(colors: [color.withOpacity(.23), cyan.withOpacity(.06)]),
                border: Border.all(color: color.withOpacity(.25)),
              ),
              child: Column(
                children: [
                  Container(width: 88, height: 88, decoration: BoxDecoration(color: color.withOpacity(.14), shape: BoxShape.circle), child: Icon(score >= 80 ? Icons.emoji_events_rounded : Icons.insights_rounded, size: 48, color: color)),
                  const SizedBox(height: 16),
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('$score/100', style: TextStyle(color: color, fontSize: 42, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Mission enregistrée • +120 XP', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bilan des décisions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 15),
                    ...List.generate(mission.steps.length, (index) {
                      final choice = mission.steps[index].choices[answers[index]];
                      final itemColor = choice.score >= 18 ? success : choice.score >= 7 ? orange : danger;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 18, backgroundColor: itemColor.withOpacity(.14), foregroundColor: itemColor, child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(mission.steps[index].title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(choice.feedback, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.35))])),
                            Text('+${choice.score}', style: TextStyle(color: itemColor, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GradientIcon(icon: Icons.description_rounded, color: violet, size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Passe à la restitution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 5),
                          Text('Utilise l’atelier de rapport avec le contexte et les livrables de cette mission.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 13),
                          FilledButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportScreen(mission: mission))),
                            icon: const Icon(Icons.edit_document),
                            label: const Text('Rédiger le rapport'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded), label: const Text('Retour aux missions'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
