import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';
import 'report_screen.dart';
import 'simulator_screen.dart';

class LabHubScreen extends StatefulWidget {
  const LabHubScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onOpenDrobot,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenDrobot;

  @override
  State<LabHubScreen> createState() => _LabHubScreenState();
}

class _LabHubScreenState extends State<LabHubScreen> {
  final List<bool> _checks = List<bool>.filled(8, false);
  int _productIndex = 0;

  int get _checkedCount => _checks.where((value) => value).length;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final estimate = _MissionEstimate.fromController(controller);

    return AmbientBackground(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: BrandBar(
                isDark: widget.isDark,
                onToggleTheme: widget.onToggleTheme,
                title: 'Laboratoire',
                subtitle: 'Planifie, calcule, simule et contrôle une mission complète',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                child: _LabHero(
                  estimate: estimate,
                  onOpenSimulator: () => _openSimulator(context),
                  onOpenDrobot: widget.onOpenDrobot,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'OUTILS RAPIDES',
                  title: 'Ton atelier de production',
                  subtitle: 'Des outils utilisables hors connexion pour préparer chaque étape.',
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
                    final columns = constraints.maxWidth >= 920
                        ? 4
                        : constraints.maxWidth >= 560
                            ? 2
                            : 1;
                    return GridView.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? 2.0 : 1.02,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ToolCard(
                          icon: Icons.route_rounded,
                          accent: cyan,
                          title: 'Simulateur intégral',
                          description: 'Plan de vol, caméra, fragments et pipeline.',
                          badge: '4 ateliers',
                          onTap: () => _openSimulator(context),
                        ),
                        _ToolCard(
                          icon: Icons.description_rounded,
                          accent: violet,
                          title: 'Rapport Studio',
                          description: 'Rédige une restitution pro étape par étape.',
                          badge: '6 sections',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportScreen()),
                          ),
                        ),
                        _ToolCard(
                          icon: Icons.quiz_rounded,
                          accent: orange,
                          title: 'Quiz adaptatif',
                          description: 'Teste tes réflexes de pilote et géomaticien.',
                          badge: 'multi-thèmes',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QuizScreen()),
                          ),
                        ),
                        _ToolCard(
                          icon: Icons.smart_toy_rounded,
                          accent: electricBlue,
                          title: 'Drobot Expert',
                          description: 'Diagnostic, protocole et explications ciblées.',
                          badge: 'hors ligne',
                          onTap: widget.onOpenDrobot,
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
                  eyebrow: 'MISSION CALCULATOR',
                  title: 'Pré-dimensionne ton vol',
                  subtitle: 'Modifie les paramètres et lis immédiatement les conséquences opérationnelles.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MissionCalculator(
                  controller: controller,
                  estimate: estimate,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'FIELD KIT',
                  title: 'Prêt pour le terrain ?',
                  subtitle: 'Une checklist de départ simple pour éviter les oublis critiques.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FieldReadiness(
                  checks: _checks,
                  checkedCount: _checkedCount,
                  onChanged: (index, value) {
                    setState(() => _checks[index] = value);
                  },
                  onReset: () => setState(() {
                    for (var i = 0; i < _checks.length; i++) {
                      _checks[i] = false;
                    }
                  }),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 12),
                child: const SectionHeading(
                  eyebrow: 'PRODUCT DECODER',
                  title: 'Comprends ce que tu livres',
                  subtitle: 'Chaque produit répond à une question différente et possède ses limites.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 125),
                child: _ProductDecoder(
                  selectedIndex: _productIndex,
                  onSelected: (value) => setState(() => _productIndex = value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSimulator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimulatorScreen(
          isDark: widget.isDark,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }
}

class _MissionEstimate {
  const _MissionEstimate({
    required this.gsdCm,
    required this.photos,
    required this.minutes,
    required this.batteries,
    required this.storageGb,
    required this.footprintWidth,
  });

  final double gsdCm;
  final int photos;
  final int minutes;
  final int batteries;
  final double storageGb;
  final double footprintWidth;

  factory _MissionEstimate.fromController(AppController controller) {
    const sensorWidthMm = 13.2;
    const sensorHeightMm = 8.8;
    const focalMm = 8.8;
    const imageWidthPx = 5472.0;

    final footprintWidth = controller.altitude * sensorWidthMm / focalMm;
    final footprintHeight = controller.altitude * sensorHeightMm / focalMm;
    final sideStep = math.max(
      1.0,
      footprintWidth * (1 - controller.sideOverlap / 100),
    );
    final frontStep = math.max(
      1.0,
      footprintHeight * (1 - controller.frontOverlap / 100),
    );
    final usefulAreaPerPhoto = sideStep * frontStep;
    final photoCount = math.max(
      12,
      (controller.areaHectares * 10000 / usefulAreaPerPhoto * 1.12).ceil(),
    ).toInt();
    final flightDistance = photoCount * frontStep;
    final minutes = math.max(
      4,
      (flightDistance / math.max(controller.speed, 1) / 60 + 4).ceil(),
    ).toInt();
    final batteries = math.max(1, (minutes / 18).ceil()).toInt();
    final gsd = controller.altitude * sensorWidthMm / focalMm / imageWidthPx * 100;
    final storage = photoCount * 6.5 / 1024;

    return _MissionEstimate(
      gsdCm: gsd,
      photos: photoCount,
      minutes: minutes,
      batteries: batteries,
      storageGb: storage,
      footprintWidth: footprintWidth,
    );
  }
}

class _LabHero extends StatelessWidget {
  const _LabHero({
    required this.estimate,
    required this.onOpenSimulator,
    required this.onOpenDrobot,
  });

  final _MissionEstimate estimate;
  final VoidCallback onOpenSimulator;
  final VoidCallback onOpenDrobot;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 330),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2F3A), Color(0xFF0B1830), Color(0xFF211A3A)],
        ),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(color: cyan.withOpacity(.10), blurRadius: 34, offset: const Offset(0, 18)),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _LabGridPainter())),
          Positioned(
            right: -50,
            top: -70,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [cyan.withOpacity(.25), cyan.withOpacity(0)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 760;
                final intro = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Pill(
                      label: 'MISSION CONTROL',
                      icon: Icons.science_rounded,
                      color: cyan,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'De l’idée au\nvol maîtrisé.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: wide ? 43 : 35,
                        height: .98,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Teste tes hypothèses, estime les ressources et entraîne ton regard avant d’aller sur le terrain.',
                      style: TextStyle(color: Colors.white70, height: 1.45, fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: onOpenSimulator,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Lancer une simulation'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onOpenDrobot,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          icon: const Icon(Icons.smart_toy_rounded),
                          label: const Text('Demander à Drobot'),
                        ),
                      ],
                    ),
                  ],
                );
                final console = _LiveConsole(estimate: estimate);
                if (wide) {
                  return Row(
                    children: [
                      Expanded(flex: 6, child: intro),
                      const SizedBox(width: 28),
                      Expanded(flex: 4, child: console),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [intro, const SizedBox(height: 24), console],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LabGridPainter extends CustomPainter {
  const _LabGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.035)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LiveConsole extends StatelessWidget {
  const _LiveConsole({required this.estimate});

  final _MissionEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('GSD estimé', '${estimate.gsdCm.toStringAsFixed(1)} cm/px', Icons.grid_4x4_rounded, cyan),
      ('Photos', '${estimate.photos}', Icons.photo_library_rounded, violet),
      ('Temps', '~${estimate.minutes} min', Icons.timer_rounded, orange),
      ('Batteries', '${estimate.batteries}', Icons.battery_charging_full_rounded, success),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.22),
        borderRadius: BorderRadius.circular(25),
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
                'ESTIMATION EN DIRECT',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.055),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white.withOpacity(.07)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(item.$3, size: 18, color: item.$4),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(item.$1, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIcon(icon: icon, color: accent, size: 48),
              const Spacer(),
              NovaDot(label: badge, color: accent),
            ],
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Ouvrir', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
              const SizedBox(width: 5),
              Icon(Icons.arrow_outward_rounded, size: 17, color: accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionCalculator extends StatelessWidget {
  const _MissionCalculator({
    required this.controller,
    required this.estimate,
  });

  final AppController controller;
  final _MissionEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 830;
          final controls = Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SliderControl(
                  label: 'Altitude',
                  value: controller.altitude,
                  min: 30,
                  max: 150,
                  divisions: 24,
                  suffix: 'm',
                  icon: Icons.height_rounded,
                  onChanged: (value) => controller.updatePlanner(newAltitude: value),
                ),
                _SliderControl(
                  label: 'Surface',
                  value: controller.areaHectares,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  suffix: 'ha',
                  icon: Icons.crop_square_rounded,
                  onChanged: (value) => controller.updatePlanner(newArea: value),
                ),
                _SliderControl(
                  label: 'Recouvrement frontal',
                  value: controller.frontOverlap,
                  min: 60,
                  max: 90,
                  divisions: 30,
                  suffix: '%',
                  icon: Icons.vertical_align_center_rounded,
                  onChanged: (value) => controller.updatePlanner(newFrontOverlap: value),
                ),
                _SliderControl(
                  label: 'Recouvrement latéral',
                  value: controller.sideOverlap,
                  min: 50,
                  max: 85,
                  divisions: 35,
                  suffix: '%',
                  icon: Icons.horizontal_distribute_rounded,
                  onChanged: (value) => controller.updatePlanner(newSideOverlap: value),
                ),
                _SliderControl(
                  label: 'Vitesse',
                  value: controller.speed,
                  min: 2,
                  max: 14,
                  divisions: 24,
                  suffix: 'm/s',
                  icon: Icons.speed_rounded,
                  onChanged: (value) => controller.updatePlanner(newSpeed: value),
                  isLast: true,
                ),
              ],
            ),
          );
          final summary = _EstimatePanel(estimate: estimate, controller: controller);
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: controls),
                Expanded(flex: 4, child: summary),
              ],
            );
          }
          return Column(children: [controls, summary]);
        },
      ),
    );
  }
}

class _SliderControl extends StatelessWidget {
  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.icon,
    required this.onChanged,
    this.isLast = false,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final IconData icon;
  final ValueChanged<double> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cyan.withOpacity(.11),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '${value.round()} $suffix',
                  style: const TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _EstimatePanel extends StatelessWidget {
  const _EstimatePanel({required this.estimate, required this.controller});

  final _MissionEstimate estimate;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final quality = _qualityLabel();
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cyan.withOpacity(.16), violet.withOpacity(.09)],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pill(label: 'SYNTHÈSE', icon: Icons.analytics_rounded),
          const SizedBox(height: 18),
          Text(
            '${estimate.gsdCm.toStringAsFixed(1)} cm / pixel',
            style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 5),
          Text(
            'Résolution estimée • profil caméra 1 pouce simulé',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 22),
          _EstimateRow(icon: Icons.photo_library_rounded, label: 'Images', value: '~${estimate.photos}'),
          _EstimateRow(icon: Icons.timer_rounded, label: 'Durée de vol', value: '~${estimate.minutes} min'),
          _EstimateRow(icon: Icons.battery_5_bar_rounded, label: 'Batteries', value: '${estimate.batteries} minimum'),
          _EstimateRow(icon: Icons.storage_rounded, label: 'Stockage', value: '~${estimate.storageGb.toStringAsFixed(1)} Go'),
          _EstimateRow(icon: Icons.aspect_ratio_rounded, label: 'Empreinte image', value: '${estimate.footprintWidth.round()} m de large'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: quality.$2.withOpacity(.12),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: quality.$2.withOpacity(.20)),
            ),
            child: Row(
              children: [
                Icon(quality.$3, color: quality.$2),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quality.$1, style: TextStyle(color: quality.$2, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(
                        quality.$4,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Estimation pédagogique : le capteur réel, le relief, les virages, le vent et les contraintes opérationnelles peuvent modifier ces valeurs.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData, String) _qualityLabel() {
    if (controller.frontOverlap >= 78 && controller.sideOverlap >= 68 && controller.speed <= 9) {
      return (
        'Configuration robuste',
        success,
        Icons.verified_rounded,
        'Bon équilibre pour une mission cartographique standard.',
      );
    }
    if (controller.frontOverlap < 70 || controller.sideOverlap < 60) {
      return (
        'Recouvrement fragile',
        danger,
        Icons.warning_amber_rounded,
        'Risque de trous ou d’alignement instable, surtout sur terrain complexe.',
      );
    }
    return (
      'Configuration à contrôler',
      orange,
      Icons.tune_rounded,
      'Adapte la vitesse, le recouvrement et la météo au sujet observé.',
    );
  }
}

class _EstimateRow extends StatelessWidget {
  const _EstimateRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _FieldReadiness extends StatelessWidget {
  const _FieldReadiness({
    required this.checks,
    required this.checkedCount,
    required this.onChanged,
    required this.onReset,
  });

  final List<bool> checks;
  final int checkedCount;
  final void Function(int index, bool value) onChanged;
  final VoidCallback onReset;

  static const items = [
    ('Zone et restrictions vérifiées', Icons.map_rounded),
    ('Météo et vent compatibles', Icons.air_rounded),
    ('Batteries chargées et identifiées', Icons.battery_charging_full_rounded),
    ('Hélices et cellule inspectées', Icons.settings_rounded),
    ('Carte mémoire vide et test caméra', Icons.sd_card_rounded),
    ('RTH et altitude de sécurité réglés', Icons.keyboard_return_rounded),
    ('Équipe briefée et zone sécurisée', Icons.groups_rounded),
    ('Plan B et journal de mission prêts', Icons.emergency_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final progress = checkedCount / items.length;
    final ready = checkedCount == items.length;
    return NovaCard(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 760;
          final checklist = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final width = wide
                  ? (constraints.maxWidth - 294) / 2 - 5
                  : constraints.maxWidth;
              return SizedBox(
                width: math.max(250.0, width),
                child: Material(
                  color: checks[index]
                      ? success.withOpacity(.10)
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.35),
                  borderRadius: BorderRadius.circular(17),
                  child: CheckboxListTile(
                    value: checks[index],
                    onChanged: (value) => onChanged(index, value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    title: Row(
                      children: [
                        Icon(item.$2, size: 17, color: checks[index] ? success : null),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.$1,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
          final status = SizedBox(
            width: wide ? 250 : double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProgressRing(
                  value: progress,
                  label: '$checkedCount/${items.length}',
                  size: 104,
                  strokeWidth: 9,
                  color: ready ? success : cyan,
                ),
                const SizedBox(height: 14),
                Text(
                  ready ? 'Décision GO' : 'Préparation en cours',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ready ? success : null,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ready
                      ? 'Tous les contrôles de base sont validés.'
                      : '${items.length - checkedCount} contrôle(s) restent à valider.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réinitialiser'),
                ),
              ],
            ),
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Expanded(child: checklist), const SizedBox(width: 24), status],
            );
          }
          return Column(children: [status, const SizedBox(height: 20), checklist]);
        },
      ),
    );
  }
}

class _ProductDecoder extends StatelessWidget {
  const _ProductDecoder({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const products = [
    _ProductInfo(
      'Orthomosaïque',
      Icons.map_rounded,
      cyan,
      'Image corrigée et géoréférencée',
      'Mesurer, numériser, comparer et produire un fond cartographique.',
      ['Perspective réduite', 'Résolution régulière', 'Compatible SIG'],
      'Ne pas confondre résolution visuelle et précision absolue.',
    ),
    _ProductInfo(
      'Nuage de points',
      Icons.grain_rounded,
      violet,
      'Reconstruction 3D composée de points',
      'Explorer la géométrie, mesurer des profils et produire d’autres surfaces.',
      ['XYZ + couleur', 'Très détaillé', 'Filtrable et classifiable'],
      'Les zones sans texture ou masquées peuvent être bruitées ou absentes.',
    ),
    _ProductInfo(
      'MNS / DSM',
      Icons.terrain_rounded,
      orange,
      'Altitude de la surface visible',
      'Calculer pentes, volumes, ombres, écoulements et hauteurs relatives.',
      ['Bâtiments inclus', 'Végétation incluse', 'Raster altimétrique'],
      'Un MNS n’est pas automatiquement un modèle du terrain nu.',
    ),
    _ProductInfo(
      'Maillage 3D',
      Icons.view_in_ar_rounded,
      electricBlue,
      'Surface triangulée et texturée',
      'Visualiser un site, présenter un patrimoine ou inspecter un ouvrage.',
      ['Immersif', 'Export web possible', 'Mesures 3D'],
      'Les textures séduisantes peuvent masquer des défauts géométriques.',
    ),
    _ProductInfo(
      'Carte d’analyse',
      Icons.layers_rounded,
      lime,
      'Interprétation dérivée des données',
      'Transformer les mesures en zonage, changement, indice ou priorité.',
      ['Décisionnelle', 'Synthétique', 'Adaptée au métier'],
      'Une carte d’analyse doit expliciter méthode, seuils et incertitudes.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = products[selectedIndex.clamp(0, products.length - 1).toInt()];
    return NovaCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 760;
          final selector = SizedBox(
            width: wide ? 280 : double.infinity,
            child: Column(
              children: List.generate(products.length, (index) {
                final item = products[index];
                final active = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: active
                        ? item.color.withOpacity(.13)
                        : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.30),
                    borderRadius: BorderRadius.circular(17),
                    child: ListTile(
                      onTap: () => onSelected(index),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                      leading: Icon(item.icon, color: active ? item.color : null),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: active ? item.color : null,
                        ),
                      ),
                      trailing: Icon(
                        active ? Icons.arrow_forward_rounded : Icons.chevron_right_rounded,
                        color: active ? item.color : null,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
          final detail = Padding(
            padding: EdgeInsets.only(left: wide ? 26 : 0, top: wide ? 0 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientIcon(icon: selected.icon, color: selected.color, size: 64),
                const SizedBox(height: 18),
                Text(selected.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(
                  selected.subtitle,
                  style: TextStyle(color: selected.color, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Text(selected.use, style: const TextStyle(height: 1.48)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selected.features
                      .map((item) => Pill(label: item, icon: Icons.check_rounded, color: selected.color))
                      .toList(),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: danger.withOpacity(.08),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: danger.withOpacity(.16)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: danger, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selected.caution,
                          style: const TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [selector, Expanded(child: detail)],
            );
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [selector, detail]);
        },
      ),
    );
  }
}

class _ProductInfo {
  const _ProductInfo(
    this.title,
    this.icon,
    this.color,
    this.subtitle,
    this.use,
    this.features,
    this.caution,
  );

  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;
  final String use;
  final List<String> features;
  final String caution;
}
