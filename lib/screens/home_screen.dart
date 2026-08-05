import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../data/academy_data.dart';
import '../data/drone_catalog_data.dart';
import '../data/quiz_catalog.dart';
import '../data/resource_library.dart';
import '../models/academy_models.dart';
import '../widgets/common.dart';
import '../widgets/flight_readiness_card.dart';
import 'course_detail_screen.dart';
import 'domain_detail_screen.dart';
import 'glossary_screen.dart';
import 'mission_player_screen.dart';
import 'quiz_hub_screen.dart';
import 'regulation_screen.dart';
import 'report_screen.dart';
import 'resources_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onOpenAcademy,
    required this.onOpenLab,
    required this.onOpenMissions,
    required this.onOpenDrobot,
    required this.onOpenDrones,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenLab;
  final VoidCallback onOpenMissions;
  final VoidCallback onOpenDrobot;
  final VoidCallback onOpenDrones;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final progress = controller.courseProgress(totalLessonCount);
    final next = _nextLesson(controller);
    final totalQuizQuestions = quizPacks.fold<int>(
      0,
      (total, pack) => total + pack.questions.length,
    );

    return AmbientBackground(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: BrandBar(
                isDark: isDark,
                onToggleTheme: onToggleTheme,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                child: _NovaHero(
                  learnerName: controller.learnerName,
                  progress: progress,
                  next: next,
                  onContinue: () => _openLesson(context, next.$1, next.$2),
                  onOpenLab: onOpenLab,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: columns == 4 ? 1.14 : .90,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        MetricCard(
                          value: '${controller.completedLessons.length}/$totalLessonCount',
                          label: 'Leçons maîtrisées',
                          icon: Icons.school_rounded,
                          delta: '${(progress * 100).round()}%',
                        ),
                        MetricCard(
                          value: '${quizPacks.length}',
                          label: 'Parcours quiz',
                          icon: Icons.quiz_rounded,
                          accent: danger,
                          delta: '$totalQuizQuestions QUESTIONS',
                        ),
                        MetricCard(
                          value: '${academyResources.length}',
                          label: 'Ressources terrain',
                          icon: Icons.auto_stories_rounded,
                          accent: cyan,
                          delta: '${academyResources.where((item) => item.visualAsset != null).length} FICHES HD',
                        ),
                        MetricCard(
                          value: '${djiDroneCatalog.length}',
                          label: 'Drones & configurations',
                          icon: Icons.flight_rounded,
                          accent: orange,
                          delta: 'BUDGET + USAGE',
                        ),
                        MetricCard(
                          value: '${controller.xp}',
                          label: 'Points d’expérience',
                          icon: Icons.bolt_rounded,
                          accent: orange,
                          delta: 'NIV ${math.max(1, controller.xp ~/ 500 + 1)}',
                        ),
                        MetricCard(
                          value: '${controller.completedMissions.length}/${missions.length}',
                          label: 'Missions certifiées',
                          icon: Icons.verified_rounded,
                          accent: success,
                          delta: '${controller.missionScores.values.fold<int>(0, (a, b) => a + b)} pts',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'FIELD KIT',
                  title: 'Météo locale & décision de vol',
                  subtitle: 'Analyse les conditions de ta position et déroule une vraie checklist avant décollage.',
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: FlightReadinessCard(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'TON COCKPIT',
                  title: 'Aujourd’hui dans DroneAtlas',
                  subtitle: 'Continue là où tu t’es arrêté et renforce les compétences les plus utiles.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 850;
                    final continueCard = _ContinueCard(
                      module: next.$1,
                      lesson: next.$2,
                      controller: controller,
                      onTap: () => _openLesson(context, next.$1, next.$2),
                    );
                    final radar = _SkillCard(controller: controller);
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: continueCard),
                          const SizedBox(width: 12),
                          Expanded(flex: 4, child: radar),
                        ],
                      );
                    }
                    return Column(children: [continueCard, const SizedBox(height: 12), radar]);
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'RACCOURCIS',
                  title: 'Passe directement à l’action',
                  subtitle: 'Simule, révise, vérifie les règles et progresse.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900
                        ? 4
                        : constraints.maxWidth >= 560
                            ? 2
                            : 1;
                    return GridView.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? 2.05 : 1.08,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _QuickAction(
                          icon: Icons.science_rounded,
                          color: cyan,
                          title: 'Laboratoire',
                          subtitle: 'Calculs, checklist et simulations',
                          onTap: onOpenLab,
                        ),
                        _QuickAction(
                          icon: Icons.smart_toy_rounded,
                          color: electricBlue,
                          title: 'Drobot Expert',
                          subtitle: 'Pose une question technique',
                          onTap: onOpenDrobot,
                        ),
                        _QuickAction(
                          icon: Icons.description_rounded,
                          color: violet,
                          title: 'Rapport Studio',
                          subtitle: 'Construis un livrable professionnel',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportScreen()),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.quiz_rounded,
                          color: orange,
                          title: 'Quiz & défis',
                          subtitle: '${quizPacks.length} parcours · $totalQuizQuestions questions',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QuizHubScreen()),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.auto_stories_rounded,
                          color: cyan,
                          title: 'Ressources terrain',
                          subtitle: '${academyResources.length} fiches dont un atlas visuel HD',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ResourcesScreen()),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.flight_takeoff_rounded,
                          color: success,
                          title: 'Choisir un drone',
                          subtitle: '${djiDroneCatalog.length} options selon budget et domaine',
                          onTap: onOpenDrones,
                        ),
                        _QuickAction(
                          icon: Icons.gavel_rounded,
                          color: danger,
                          title: 'Règles ANACIM',
                          subtitle: 'Annexe 5 et limites de vol',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegulationScreen()),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.school_rounded,
                          color: success,
                          title: 'Académie',
                          subtitle: 'Cours riches et parcours guidés',
                          onTap: onOpenAcademy,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'PACK TOTAL HORS LIGNE',
                  title: 'Réviser, consulter et choisir au même endroit',
                  subtitle: 'Les quiz, les fiches terrain illustrées et le catalogue de drones sont maintenant au premier plan.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TotalContentStrip(
                  quizzes: quizPacks.length,
                  questions: totalQuizQuestions,
                  resources: academyResources.length,
                  visuals: academyResources.where((item) => item.visualAsset != null).length,
                  drones: djiDroneCatalog.length,
                  onOpenDrones: onOpenDrones,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 12),
                child: SectionHeading(
                  eyebrow: 'ACADEMY PATH',
                  title: '${modules.length} modules pour devenir autonome',
                  subtitle: 'Un parcours complet du pilotage à l’IA géospatiale et au métier.',
                  actionLabel: 'Explorer',
                  onAction: onOpenAcademy,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: SizedBox(
                height: 225,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: modules.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    final done = module.lessons
                        .where((lesson) => controller.lessonCompleted(lesson.id))
                        .length;
                    return _ModuleTeaser(
                      module: module,
                      done: done,
                      onTap: () => _openLesson(context, module, module.lessons.first),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 12),
                child: SectionHeading(
                  eyebrow: 'SCÉNARIO',
                  title: 'Mission recommandée',
                  subtitle: 'Prends des décisions comme dans une vraie opération.',
                  actionLabel: 'Toutes',
                  onAction: onOpenMissions,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MissionSpotlight(mission: _recommendedMission(controller)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'DROBOT INTELLIGENCE',
                  title: 'Un expert embarqué dans ta poche',
                  subtitle: 'Drone, photogrammétrie, géomatique, capteurs, qualité, QGIS, IA et carrière.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DrobotCommandCard(onOpenDrobot: onOpenDrobot),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'APPLICATIONS',
                  title: 'Explore les domaines de mission',
                  subtitle: 'Découvre les produits, paramètres et pièges propres à chaque secteur.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: SizedBox(
                height: 250,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: domains.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _DomainCard(domain: domains[index]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 130),
                child: _KnowledgeFooter(
                  onGlossary: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GlossaryScreen()),
                  ),
                  onAcademy: onOpenAcademy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (AcademyModule, Lesson) _nextLesson(AppController controller) {
    for (final module in modules) {
      for (final lesson in module.lessons) {
        if (!controller.lessonCompleted(lesson.id)) return (module, lesson);
      }
    }
    return (modules.first, modules.first.lessons.first);
  }

  TrainingMission _recommendedMission(AppController controller) {
    for (final mission in missions) {
      if (!controller.missionCompleted(mission.id)) return mission;
    }
    return missions.first;
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


class _TotalContentStrip extends StatelessWidget {
  const _TotalContentStrip({
    required this.quizzes,
    required this.questions,
    required this.resources,
    required this.visuals,
    required this.drones,
    required this.onOpenDrones,
  });

  final int quizzes;
  final int questions;
  final int resources;
  final int visuals;
  final int drones;
  final VoidCallback onOpenDrones;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final cards = [
          _TotalContentCard(
            icon: Icons.quiz_rounded,
            color: orange,
            title: '$quizzes quiz',
            subtitle: '$questions questions expliquées',
            button: 'Réviser maintenant',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHubScreen())),
          ),
          _TotalContentCard(
            icon: Icons.auto_stories_rounded,
            color: cyan,
            title: '$resources ressources',
            subtitle: '$visuals fiches HD hors ligne',
            button: 'Ouvrir la bibliothèque',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourcesScreen())),
          ),
          _TotalContentCard(
            icon: Icons.flight_rounded,
            color: success,
            title: '$drones drones',
            subtitle: 'Choix par besoin et budget',
            button: 'Trouver ma configuration',
            onTap: onOpenDrones,
          ),
        ];
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i != cards.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              cards[i],
              if (i != cards.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _TotalContentCard extends StatelessWidget {
  const _TotalContentCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(.20), Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(18)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.35)),
                    const SizedBox(height: 8),
                    Text(button, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NovaHero extends StatelessWidget {
  const _NovaHero({
    required this.learnerName,
    required this.progress,
    required this.next,
    required this.onContinue,
    required this.onOpenLab,
  });

  final String learnerName;
  final double progress;
  final (AcademyModule, Lesson) next;
  final VoidCallback onContinue;
  final VoidCallback onOpenLab;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 460),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        image: const DecorationImage(
          image: AssetImage('assets/images/gal6.webp'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: cyan.withOpacity(.11), blurRadius: 38, offset: const Offset(0, 18)),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0x3D0A8A88), Color(0xD9071422), Color(0xFA040A12)],
                  stops: [0, .46, 1],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: CustomPaint(painter: _HeroRoutePainter())),
          Positioned(
            right: -40,
            top: -65,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [cyan.withOpacity(.25), cyan.withOpacity(0)],
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 460),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: LayoutBuilder(
                builder: (context, constraints) {
                final wide = constraints.maxWidth > 760;
                final intro = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        Pill(label: 'DRONEATLAS ACADEMY', icon: Icons.auto_awesome_rounded),
                        Pill(label: '100 % HORS LIGNE', icon: Icons.offline_bolt_rounded, color: success),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Prêt à décoller,\n$learnerName ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: wide ? 51 : 40,
                        height: .97,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 610),
                      child: const Text(
                        'Maîtrise le drone, la photographie aérienne, la photogrammétrie, le SIG et l’analyse géospatiale dans une expérience entièrement repensée.',
                        style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.48),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: onContinue,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Continuer le parcours'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onOpenLab,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                          ),
                          icon: const Icon(Icons.science_rounded),
                          label: const Text('Ouvrir le laboratoire'),
                        ),
                      ],
                    ),
                  ],
                );
                final flightPanel = _HeroFlightPanel(progress: progress, next: next);
                if (wide) {
                  return Row(
                    children: [
                      Expanded(flex: 6, child: intro),
                      const SizedBox(width: 30),
                      Expanded(flex: 4, child: flightPanel),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    intro,
                    const SizedBox(height: 24),
                    flightPanel,
                  ],
                );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroRoutePainter extends CustomPainter {
  const _HeroRoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withOpacity(.045)
      ..strokeWidth = 1;
    const step = 38.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final route = Paint()
      ..color = cyan.withOpacity(.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * .58, size.height * .20)
      ..quadraticBezierTo(size.width * .83, size.height * .10, size.width * .82, size.height * .34)
      ..quadraticBezierTo(size.width * .79, size.height * .56, size.width * .94, size.height * .72);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroFlightPanel extends StatelessWidget {
  const _HeroFlightPanel({required this.progress, required this.next});

  final double progress;
  final (AcademyModule, Lesson) next;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.28),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(radius: 4, backgroundColor: success),
              SizedBox(width: 8),
              Text(
                'PARCOURS EN LIGNE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ProgressRing(
                value: progress,
                label: '${(progress * 100).round()}%',
                size: 86,
                strokeWidth: 8,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progression globale', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      '${next.$1.number} • ${next.$1.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.07)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: next.$1.accent.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(next.$2.icon, color: next.$1.accent, size: 21),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prochaine leçon', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(
                        next.$2.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Text(next.$2.duration, style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.module,
    required this.lesson,
    required this.controller,
    required this.onTap,
  });

  final AcademyModule module;
  final Lesson lesson;
  final AppController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = module.lessons.where((item) => controller.lessonCompleted(item.id)).length;
    final progress = done / module.lessons.length;
    return NovaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [module.accent.withOpacity(.19), module.accent.withOpacity(.035)],
      ),
      borderColor: module.accent.withOpacity(.20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 500;
          final icon = GradientIcon(icon: module.icon, color: module.accent, size: 68);
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Pill(label: 'MODULE ${module.number}', icon: Icons.route_rounded, color: module.accent),
                  const Spacer(),
                  Text('$done/${module.lessons.length}', style: TextStyle(color: module.accent, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 18),
              Text(module.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.7)),
              const SizedBox(height: 7),
              Text(
                lesson.title,
                style: TextStyle(color: module.accent, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                lesson.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: module.accent.withOpacity(.12),
                valueColor: AlwaysStoppedAnimation(module.accent),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 17, color: module.accent),
                  const SizedBox(width: 6),
                  Text(lesson.duration, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  const Spacer(),
                  Text('Reprendre', style: TextStyle(color: module.accent, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward_rounded, size: 17, color: module.accent),
                ],
              ),
            ],
          );
          if (compact) return content;
          return Row(
            children: [Expanded(child: content), const SizedBox(width: 22), icon],
          );
        },
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.courseProgress(totalLessonCount);
    final missionProgress = missions.isEmpty ? 0.0 : controller.completedMissions.length / missions.length;
    final values = <double>[
      (.18 + p * .82).clamp(0, 1).toDouble(),
      (.12 + p * .72).clamp(0, 1).toDouble(),
      (.08 + missionProgress * .86).clamp(0, 1).toDouble(),
      (.20 + p * .65).clamp(0, 1).toDouble(),
      (.15 + missionProgress * .72).clamp(0, 1).toDouble(),
      (.10 + p * .76).clamp(0, 1).toDouble(),
    ];
    const labels = ['Drone', 'Photo', 'Terrain', 'Traitem.', 'SIG', 'Rapport'];
    return NovaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              GradientIcon(icon: Icons.radar_rounded, color: electricBlue, size: 48),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Radar de compétences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text('Évolue avec tes validations', style: TextStyle(color: electricBlue, fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(child: SkillRadar(values: values, size: 180, color: electricBlue)),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 9,
            runSpacing: 7,
            children: List.generate(labels.length, (index) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index.isEven ? electricBlue : cyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(labels[index], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIcon(icon: icon, color: color, size: 48),
              const Spacer(),
              Icon(Icons.arrow_outward_rounded, color: color, size: 20),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _ModuleTeaser extends StatelessWidget {
  const _ModuleTeaser({required this.module, required this.done, required this.onTap});

  final AcademyModule module;
  final int done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = done / module.lessons.length;
    return SizedBox(
      width: 278,
      child: NovaCard(
        onTap: onTap,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GradientIcon(icon: module.icon, color: module.accent, size: 50),
                const Spacer(),
                Text(
                  module.number,
                  style: TextStyle(color: module.accent, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
              ],
            ),
            const Spacer(),
            Text(module.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              '${module.lessons.length} leçons • ${module.subtitle}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11.5, height: 1.3),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(99),
                    backgroundColor: module.accent.withOpacity(.12),
                    valueColor: AlwaysStoppedAnimation(module.accent),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(progress * 100).round()}%', style: TextStyle(color: module.accent, fontSize: 11, fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionSpotlight extends StatelessWidget {
  const _MissionSpotlight({required this.mission});

  final TrainingMission mission;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 310),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(image: AssetImage(mission.image), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(color: violet.withOpacity(.10), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [navy.withOpacity(.16), navy.withOpacity(.96)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 700;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Pill(label: mission.level.toUpperCase(), icon: Icons.signal_cellular_alt_rounded),
                    Pill(label: mission.duration, icon: Icons.timer_outlined, color: orange),
                    Pill(label: '${mission.steps.length} décisions', icon: Icons.account_tree_rounded, color: violet),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  mission.title,
                  style: TextStyle(color: Colors.white, fontSize: wide ? 32 : 27, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    mission.brief,
                    style: const TextStyle(color: Colors.white70, height: 1.45),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MissionPlayerScreen(mission: mission)),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Accepter la mission'),
                ),
              ],
            );
            if (!wide) return content;
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 24),
                Container(
                  width: 180,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.28),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2_rounded, color: cyan, size: 36),
                      const SizedBox(height: 10),
                      const Text('LIVRABLE', style: TextStyle(color: cyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
                      const SizedBox(height: 7),
                      Text(
                        mission.deliverable,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DrobotCommandCard extends StatelessWidget {
  const _DrobotCommandCard({required this.onOpenDrobot});

  final VoidCallback onOpenDrobot;

  @override
  Widget build(BuildContext context) {
    const prompts = [
      'Planifier 50 ha',
      'Photos non alignées',
      'Choisir un CRS',
      'Contrôler un RMSE',
      'Multispectral ou RGB',
    ];
    return NovaCard(
      onTap: onOpenDrobot,
      padding: const EdgeInsets.all(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D2B38), Color(0xFF111A31), Color(0xFF251A39)],
      ),
      borderColor: Colors.white12,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 720;
          final avatar = Container(
            width: wide ? 122 : 88,
            height: wide ? 122 : 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [cyan, electricBlue]),
              boxShadow: [
                BoxShadow(color: cyan.withOpacity(.28), blurRadius: 34, spreadRadius: 2),
              ],
            ),
            child: Icon(Icons.smart_toy_rounded, color: navy, size: wide ? 65 : 46),
          );
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pill(label: 'DROBOT • EXPERT EMBARQUÉ', icon: Icons.auto_awesome_rounded),
              const SizedBox(height: 14),
              Text(
                'Décris ton problème.\nDrobot construit la méthode.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: wide ? 28 : 24,
                  height: 1.06,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.9,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Il répond avec une synthèse, une procédure, des contrôles et des avertissements adaptés à la mission.',
                style: TextStyle(color: Colors.white70, height: 1.45),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: prompts
                    .map((prompt) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.06),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(prompt, style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w700)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onOpenDrobot,
                icon: const Icon(Icons.chat_bubble_rounded),
                label: const Text('Ouvrir Drobot'),
              ),
            ],
          );
          if (wide) {
            return Row(children: [Expanded(child: content), const SizedBox(width: 30), avatar]);
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [avatar, const SizedBox(height: 20), content]);
        },
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  const _DomainCard({required this.domain});

  final ApplicationDomain domain;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 286,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DomainDetailScreen(domain: domain)),
        ),
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            image: DecorationImage(image: AssetImage(domain.image), fit: BoxFit.cover),
          ),
          child: Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, navy.withOpacity(.96)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: cyan, borderRadius: BorderRadius.circular(14)),
                      child: Icon(domain.icon, color: navy, size: 21),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_outward_rounded, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 13),
                Text(domain.title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(
                  domain.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KnowledgeFooter extends StatelessWidget {
  const _KnowledgeFooter({required this.onGlossary, required this.onAcademy});

  final VoidCallback onGlossary;
  final VoidCallback onAcademy;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 650;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('La connaissance reste disponible hors connexion.', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                'Cours, glossaire, simulations, missions et Drobot sont intégrés dans l’application. Aucune image réelle n’est nécessaire.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.42),
              ),
            ],
          );
          final buttons = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onGlossary,
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Glossaire'),
              ),
              FilledButton.icon(
                onPressed: onAcademy,
                icon: const Icon(Icons.school_rounded),
                label: const Text('Académie'),
              ),
            ],
          );
          if (wide) {
            return Row(
              children: [
                const GradientIcon(icon: Icons.offline_bolt_rounded, color: success, size: 60),
                const SizedBox(width: 17),
                Expanded(child: text),
                const SizedBox(width: 20),
                buttons,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GradientIcon(icon: Icons.offline_bolt_rounded, color: success, size: 60),
              const SizedBox(height: 15),
              text,
              const SizedBox(height: 16),
              buttons,
            ],
          );
        },
      ),
    );
  }
}
