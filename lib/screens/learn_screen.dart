import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../data/academy_data.dart';
import '../models/academy_models.dart';
import '../models/remote_content_models.dart';
import '../widgets/common.dart';
import 'course_detail_screen.dart';
import 'glossary_screen.dart';
import 'quiz_hub_screen.dart';
import 'regulation_screen.dart';
import 'resources_screen.dart';
import 'remote_course_detail_screen.dart';
import 'update_center_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final filtered = modules.where((module) {
      final q = _query.toLowerCase();
      if (q.isEmpty) return true;
      return module.title.toLowerCase().contains(q) ||
          module.subtitle.toLowerCase().contains(q) ||
          module.lessons.any((lesson) => lesson.title.toLowerCase().contains(q));
    }).toList();
    final remoteFiltered = controller.remoteCourses.where((course) {
      final q = _query.toLowerCase();
      if (q.isEmpty) return true;
      return course.title.toLowerCase().contains(q) ||
          course.summary.toLowerCase().contains(q) ||
          course.category.toLowerCase().contains(q);
    }).toList();

    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: CustomScrollView(
        slivers: [
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: _AcademyTopBar(
              isDark: widget.isDark,
              onToggleTheme: widget.onToggleTheme,
              moduleCount: modules.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
              child: _AcademyHeader(controller: controller),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _AcademyQuickAccess(
                onQuiz: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHubScreen())),
                onResources: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourcesScreen())),
                onRegulation: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegulationScreen())),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une notion ou une leçon…',
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
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Glossaire',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlossaryScreen())),
                    icon: const Icon(Icons.menu_book_rounded),
                    style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Quiz global',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHubScreen())),
                    icon: const Icon(Icons.quiz_rounded),
                    style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
                  ),
                  const SizedBox(width: 8),
                  Badge(
                    isLabelVisible: controller.updateAvailable,
                    label: const Text('!'),
                    child: IconButton.filledTonal(
                      tooltip: 'Mises à jour',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateCenterScreen())),
                      icon: Icon(controller.updateAvailable ? Icons.new_releases_rounded : Icons.cloud_sync_rounded),
                      style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (remoteFiltered.isNotEmpty)
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: const SectionHeading(
                  title: 'Nouveautés téléchargées',
                  subtitle: 'Cours ajoutés après l’installation de l’application.',
                ),
              ),
            ),
          ),
        if (remoteFiltered.isNotEmpty)
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: SizedBox(
                height: 194,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: remoteFiltered.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _RemoteCourseCard(
                    course: remoteFiltered[index],
                    completed: controller.lessonCompleted('remote_${remoteFiltered[index].id}'),
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: _CompactSectionHeading(
                title: _query.isEmpty ? 'Parcours en ${modules.length} modules' : '${filtered.length + remoteFiltered.length} résultat(s)',
                subtitle: _query.isEmpty
                    ? 'Chaque module associe théorie, démonstration et vérification.'
                    : 'Les modules correspondant à ta recherche.',
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          sliver: SliverToBoxAdapter(
            child: MaxWidthBox(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000
                      ? 3
                      : constraints.maxWidth >= 650
                          ? 2
                          : 1;
                  return GridView.builder(
                    itemCount: filtered.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: columns == 1 ? 372 : 356,
                    ),
                    itemBuilder: (context, index) => _ModuleCard(
                      module: filtered[index],
                      controller: controller,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}



class _AcademyTopBar extends StatelessWidget {
  const _AcademyTopBar({
    required this.isDark,
    required this.onToggleTheme,
    required this.moduleCount,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;
  final int moduleCount;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 22, 16, compact ? 16 : 22, 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: cyan.withOpacity(.22)),
              boxShadow: [
                BoxShadow(
                  color: cyan.withOpacity(.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset('assets/images/logo.webp'),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Académie',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 27 : 30,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$moduleCount modules • drone, capteurs, SIG, IA et métier',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(.82),
                    fontSize: compact ? 14 : 15,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: isDark ? 'Mode clair' : 'Mode sombre',
            onPressed: onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
        ],
      ),
    );
  }
}


class _CompactAcademyPill extends StatelessWidget {
  const _CompactAcademyPill();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: orange.withOpacity(.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: orange.withOpacity(.48), width: 1.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_rounded, size: 18, color: orange),
            SizedBox(width: 6),
            Text(
              'PARCOURS DRONEATLAS',
              style: TextStyle(
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: .35,
                color: orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactSectionHeading extends StatelessWidget {
  const _CompactSectionHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 25 : 29,
            height: 1.16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 15 : 16,
            height: 1.48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.82),
          ),
        ),
      ],
    );
  }
}

class _AcademyQuickAccess extends StatelessWidget {
  const _AcademyQuickAccess({
    required this.onQuiz,
    required this.onResources,
    required this.onRegulation,
  });

  final VoidCallback onQuiz;
  final VoidCallback onResources;
  final VoidCallback onRegulation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 580;
        final cards = [
          _AcademyAccessCard(
            title: 'Quiz & défis',
            subtitle: '190 questions : ANACIM, sécurité, photo, SIG et DJI',
            icon: Icons.quiz_rounded,
            color: orange,
            onTap: onQuiz,
          ),
          _AcademyAccessCard(
            title: 'Ressources',
            subtitle: '107 ressources : terrain, traitement, SIG et métier',
            icon: Icons.library_books_rounded,
            color: cyan,
            onTap: onResources,
          ),
          _AcademyAccessCard(
            title: 'ANACIM',
            subtitle: 'Classification, autorisations, PER et limites',
            icon: Icons.gavel_rounded,
            color: violet,
            onTap: onRegulation,
          ),
        ];
        if (compact) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 9),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _AcademyAccessCard extends StatelessWidget {
  const _AcademyAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(.82),
                        fontSize: 14,
                        height: 1.42,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 17, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcademyHeader extends StatelessWidget {
  const _AcademyHeader({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final total = totalLessonCount + controller.remoteCourses.length;
    final progress = controller.courseProgress(total);
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 430 ? 21 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cyan.withOpacity(.22), violet.withOpacity(.20), orange.withOpacity(.08)],
        ),
        border: Border.all(color: cyan.withOpacity(.36), width: 1.2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 620;
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CompactAcademyPill(),
              const SizedBox(height: 11),
              Text(
                'De novice à opérateur augmenté',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: MediaQuery.sizeOf(context).width < 430 ? 28 : 32,
                  height: 1.14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${totalLessonCount + controller.remoteCourses.length} leçons courtes : pilotage, photo, planification, terrain, traitement, SIG, sécurité, capteurs avancés, IA géospatiale et activité professionnelle.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.86),
                  height: 1.52,
                  fontSize: MediaQuery.sizeOf(context).width < 430 ? 15 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
          final progressCard = Container(
            width: wide ? 210 : double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color?.withOpacity(.62),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisSize: wide ? MainAxisSize.min : MainAxisSize.max,
              children: [
                ProgressRing(value: progress, label: '${(progress * 100).round()} %', color: violet),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.completedLessons.length} leçons',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sur $total validées',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(.82),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          if (wide) {
            return Row(children: [Expanded(child: info), const SizedBox(width: 20), progressCard]);
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [info, const SizedBox(height: 18), progressCard]);
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.controller});

  final AcademyModule module;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final done = module.lessons.where((lesson) => controller.lessonCompleted(lesson.id)).length;
    final progress = done / module.lessons.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openLesson(context, module, module.lessons.first),
        child: Padding(
          padding: const EdgeInsets.all(21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GradientIcon(icon: module.icon, color: module.accent, size: 50),
                  const Spacer(),
                  Text(module.number, style: TextStyle(color: module.accent, fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                module.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                module.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.82),
                  height: 1.48,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              ...module.lessons.take(2).map(
                    (lesson) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(controller.lessonCompleted(lesson.id) ? Icons.check_circle_rounded : Icons.play_circle_outline_rounded, size: 17, color: controller.lessonCompleted(lesson.id) ? success : module.accent),
                          const SizedBox(width: 7),
                          Expanded(child: Text(lesson.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, height: 1.28, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(99),
                      backgroundColor: module.accent.withOpacity(.12),
                      valueColor: AlwaysStoppedAnimation(module.accent),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$done/${module.lessons.length}', style: TextStyle(color: module.accent, fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, AcademyModule module, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(module: module, initialLesson: lesson),
      ),
    );
  }
}


class _RemoteCourseCard extends StatelessWidget {
  const _RemoteCourseCard({required this.course, required this.completed});

  final RemoteCourse course;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RemoteCourseDetailScreen(course: course),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GradientIcon(
                      icon: completed ? Icons.verified_rounded : Icons.cloud_done_rounded,
                      color: completed ? success : violet,
                      size: 48,
                    ),
                    const Spacer(),
                    Pill(
                      label: course.duration,
                      icon: Icons.schedule_rounded,
                      color: violet,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 19, height: 1.2, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  course.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(.82),
                  ),
                ),
                const Spacer(),
                Text(
                  completed ? 'Cours validé' : '${course.category} • ${course.level}',
                  style: TextStyle(
                    color: completed ? success : violet,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
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
