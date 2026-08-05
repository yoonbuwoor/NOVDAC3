import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/quiz_catalog.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class QuizHubScreen extends StatefulWidget {
  const QuizHubScreen({super.key});

  @override
  State<QuizHubScreen> createState() => _QuizHubScreenState();
}

class _QuizHubScreenState extends State<QuizHubScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _difficulty = 'Tous';

  List<String> get difficulties => [
        'Tous',
        ...{...quizPacks.map((pack) => pack.difficulty)},
      ];

  List<QuizPack> get visible => quizPacks.where((pack) {
        if (_difficulty != 'Tous' && pack.difficulty != _difficulty) return false;
        final q = _query.trim().toLowerCase();
        if (q.isEmpty) return true;
        return [pack.title, pack.subtitle, pack.difficulty]
            .join(' ')
            .toLowerCase()
            .contains(q);
      }).toList(growable: false);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = quizPacks.fold<int>(
      0,
      (total, pack) => total + pack.questions.length,
    );
    final featured = quizPacks.where((pack) => pack.featured).toList();
    final media = MediaQuery.of(context);
    final safeScale = math.min(media.textScaler.scale(1), 1.18);

    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.linear(safeScale)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Quiz & défis')),
        body: AmbientBackground(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: _QuizHero(
                      packs: quizPacks.length,
                      questions: totalQuestions,
                      featured: featured.length,
                      onStart: () => _openQuiz(context, featured.first),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: const SectionHeading(
                      eyebrow: 'DÉFIS ESSENTIELS',
                      title: 'Les parcours à faire en priorité',
                      subtitle:
                          'Réglementation, météo, sécurité et urgences : des réflexes indispensables avant le terrain.',
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: SizedBox(
                    height: 278,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: featured.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => _FeaturedQuizCard(
                        pack: featured[index],
                        rank: index + 1,
                        onTap: () => _openQuiz(context, featured[index]),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: TextField(
                      controller: _search,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Rechercher : ANACIM, LiDAR, météo, RTK…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: SizedBox(
                    height: 62,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                      scrollDirection: Axis.horizontal,
                      itemCount: difficulties.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final difficulty = difficulties[index];
                        final count = difficulty == 'Tous'
                            ? quizPacks.length
                            : quizPacks
                                .where((pack) => pack.difficulty == difficulty)
                                .length;
                        return ChoiceChip(
                          label: Text('$difficulty · $count'),
                          selected: _difficulty == difficulty,
                          onSelected: (_) => setState(() => _difficulty = difficulty),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
                    child: SectionHeading(
                      eyebrow: 'BIBLIOTHÈQUE DE QUIZ',
                      title: '${visible.length} parcours disponibles',
                      subtitle:
                          'Chaque réponse est corrigée et expliquée immédiatement pour transformer l’erreur en compétence.',
                    ),
                  ),
                ),
              ),
              if (visible.isEmpty)
                const SliverToBoxAdapter(
                  child: MaxWidthBox(
                    child: Padding(
                      padding: EdgeInsets.all(34),
                      child: Center(child: Text('Aucun quiz ne correspond à la recherche.')),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final columns = width >= 900 ? 3 : width >= 580 ? 2 : 1;
                      if (columns == 1) {
                        return SliverList.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 11),
                          itemBuilder: (context, index) {
                            final pack = visible[index];
                            return _QuizPackCard(
                              pack: pack,
                              onTap: () => _openQuiz(context, pack),
                            );
                          },
                        );
                      }
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: columns == 3 ? 1.13 : 1.18,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final pack = visible[index];
                            return _QuizGridCard(
                              pack: pack,
                              onTap: () => _openQuiz(context, pack),
                            );
                          },
                          childCount: visible.length,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQuiz(BuildContext context, QuizPack pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          title: pack.title,
          subtitle:
              '${pack.questions.length} questions • ${pack.minutes} min • ${pack.xp} XP',
          questions: pack.questions,
        ),
      ),
    );
  }
}

class _QuizHero extends StatelessWidget {
  const _QuizHero({
    required this.packs,
    required this.questions,
    required this.featured,
    required this.onStart,
  });

  final int packs;
  final int questions;
  final int featured;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B102F), Color(0xFF261238), Color(0xFF071D27)],
        ),
        border: Border.all(color: orange.withOpacity(.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientIcon(icon: Icons.quiz_rounded, size: 66, color: orange),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Academy Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Révise par thème, comprends chaque correction et prépare-toi aux décisions de terrain.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _StatTile(icon: Icons.route_rounded, value: '$packs', label: 'parcours', color: cyan)),
              const SizedBox(width: 9),
              Expanded(child: _StatTile(icon: Icons.help_center_rounded, value: '$questions', label: 'questions', color: orange)),
              const SizedBox(width: 9),
              Expanded(child: _StatTile(icon: Icons.local_fire_department_rounded, value: '$featured', label: 'prioritaires', color: success)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Lancer le défi prioritaire'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

class _FeaturedQuizCard extends StatelessWidget {
  const _FeaturedQuizCard({required this.pack, required this.rank, required this.onTap});

  final QuizPack pack;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = pack.accentColor;
    return SizedBox(
      width: 306,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(.28), Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: color.withOpacity(.18),
                      child: Icon(pack.icon, color: color, size: 28),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(99)),
                      child: Text('#$rank PRIORITÉ', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(pack.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.15)),
                const SizedBox(height: 7),
                Expanded(
                  child: Text(
                    pack.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.38),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 7,
                  children: [
                    Pill(label: pack.difficulty, color: color),
                    _Meta(icon: Icons.help_outline_rounded, label: '${pack.questions.length} questions'),
                    _Meta(icon: Icons.schedule_rounded, label: '${pack.minutes} min'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text('Commencer · +${pack.xp} XP'),
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

class _QuizPackCard extends StatelessWidget {
  const _QuizPackCard({required this.pack, required this.onTap});

  final QuizPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = pack.accentColor;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(19)),
                child: Icon(pack.icon, color: color, size: 31),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(pack.title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, height: 1.2))),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(pack.subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12.5, height: 1.38)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 9,
                      runSpacing: 7,
                      children: [
                        Pill(label: pack.difficulty, color: color),
                        _Meta(icon: Icons.help_outline_rounded, label: '${pack.questions.length} questions'),
                        _Meta(icon: Icons.schedule_rounded, label: '${pack.minutes} min'),
                        _Meta(icon: Icons.stars_rounded, label: '${pack.xp} XP'),
                      ],
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
}

class _QuizGridCard extends StatelessWidget {
  const _QuizGridCard({required this.pack, required this.onTap});

  final QuizPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = pack.accentColor;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(.18), Colors.transparent],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 23, backgroundColor: color.withOpacity(.16), child: Icon(pack.icon, color: color)),
                  const Spacer(),
                  Pill(label: pack.difficulty, color: color),
                ],
              ),
              const SizedBox(height: 13),
              Text(pack.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, height: 1.2)),
              const SizedBox(height: 6),
              Expanded(child: Text(pack.subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.35))),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Meta(icon: Icons.help_outline_rounded, label: '${pack.questions.length}'),
                  const SizedBox(width: 10),
                  _Meta(icon: Icons.schedule_rounded, label: '${pack.minutes} min'),
                  const Spacer(),
                  Text('+${pack.xp} XP', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
