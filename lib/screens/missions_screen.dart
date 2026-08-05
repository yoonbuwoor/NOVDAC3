import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../data/academy_data.dart';
import '../models/academy_models.dart';
import '../widgets/common.dart';
import 'mission_player_screen.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: BrandBar(
              isDark: isDark,
              onToggleTheme: onToggleTheme,
              title: 'Missions virtuelles',
              subtitle: 'Prends des décisions et défends tes choix',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
              child: _MissionHeader(controller: controller),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 13),
              child: const SectionHeading(
                title: 'Scénarios disponibles',
                subtitle: 'Chaque mission couvre toute la chaîne : besoin, planification, terrain, contrôle et restitution.',
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
                  final columns = constraints.maxWidth >= 980
                      ? 3
                      : constraints.maxWidth >= 620
                          ? 2
                          : 1;
                  return GridView.builder(
                    itemCount: missions.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: columns == 1 ? 1.18 : .88,
                    ),
                    itemBuilder: (context, index) => _MissionCard(
                      mission: missions[index],
                      completed: controller.missionCompleted(missions[index].id),
                      score: controller.missionScores[missions[index].id],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MissionHeader extends StatelessWidget {
  const _MissionHeader({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final completed = controller.completedMissions.length;
    return Container(
      constraints: const BoxConstraints(minHeight: 240),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF123A47), Color(0xFF081722)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 650;
          final text = const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Pill(label: 'APPRENDRE PAR LA DÉCISION', icon: Icons.psychology_rounded),
              SizedBox(height: 15),
              Text('Tu es le responsable\nde la mission.', style: TextStyle(color: Colors.white, fontSize: 34, height: 1.03, fontWeight: FontWeight.w900, letterSpacing: -1)),
              SizedBox(height: 12),
              Text('Analyse le contexte, choisis une stratégie et découvre immédiatement les conséquences techniques de ta décision.', style: TextStyle(color: Colors.white70, height: 1.45)),
            ],
          );
          final stat = Container(
            width: wide ? 230 : double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProgressRing(value: completed / missions.length, label: '$completed/${missions.length}', size: 82, color: success),
                const SizedBox(height: 12),
                const Text('MISSIONS TERMINÉES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8)),
                const SizedBox(height: 11),
                Text('${controller.completedMissions.length * 120} XP gagnés', style: const TextStyle(color: orange, fontWeight: FontWeight.w900)),
              ],
            ),
          );
          if (wide) return Row(children: [Expanded(child: text), const SizedBox(width: 22), stat]);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, const SizedBox(height: 20), stat]);
        },
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.completed, required this.score});

  final TrainingMission mission;
  final bool completed;
  final int? score;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MissionPlayerScreen(mission: mission))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(mission.image, fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, navy.withOpacity(.86)]))),
                  Positioned(left: 15, top: 15, child: Pill(label: mission.level, icon: Icons.signal_cellular_alt_rounded)),
                  if (completed)
                    Positioned(right: 15, top: 15, child: Pill(label: '$score/100', icon: Icons.verified_rounded, color: success)),
                  Positioned(
                    left: 17,
                    right: 17,
                    bottom: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mission.title, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 5),
                        Text('${mission.duration} • ${mission.steps.length} décisions', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.brief, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4)),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: Text(mission.deliverable, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                        const SizedBox(width: 8),
                        CircleAvatar(backgroundColor: cyan.withOpacity(.14), foregroundColor: cyan, child: const Icon(Icons.arrow_forward_rounded)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
