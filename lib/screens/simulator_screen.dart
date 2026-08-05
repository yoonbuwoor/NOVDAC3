import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../data/anacim_rules.dart';
import '../widgets/common.dart';
import '../widgets/learning_visuals.dart';
import 'regulation_screen.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

enum _SimulatorMode { plan, camera, fragments, pipeline }

class _SimulatorScreenState extends State<SimulatorScreen> {
  _SimulatorMode _mode = _SimulatorMode.plan;
  bool _dayOperation = true;
  bool _vlos = true;
  bool _nearAerodrome = false;
  bool _controlledAirspace = false;
  bool _congestedArea = false;
  bool _hasAuthorization = false;

  @override
  Widget build(BuildContext context) {
    // Le laboratoire conserve une typographie stable même si une très grande
    // taille de police est activée dans Android. Les autres écrans gardent les
    // réglages d’accessibilité du téléphone.
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: BrandBar(
                isDark: widget.isDark,
                onToggleTheme: widget.onToggleTheme,
                title: 'Simulateur de vol',
                subtitle: 'Planifie, vérifie les règles et teste sans risquer une mission réelle',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                child: _ModeSelector(
                  selected: _mode,
                  onSelected: (mode) => setState(() => _mode = mode),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: switch (_mode) {
                    _SimulatorMode.plan => _PlanLab(
                        key: const ValueKey('plan'),
                        dayOperation: _dayOperation,
                        vlos: _vlos,
                        nearAerodrome: _nearAerodrome,
                        controlledAirspace: _controlledAirspace,
                        congestedArea: _congestedArea,
                        hasAuthorization: _hasAuthorization,
                        onDayOperationChanged: (value) => setState(() => _dayOperation = value),
                        onVlosChanged: (value) => setState(() => _vlos = value),
                        onNearAerodromeChanged: (value) => setState(() => _nearAerodrome = value),
                        onControlledAirspaceChanged: (value) => setState(() => _controlledAirspace = value),
                        onCongestedAreaChanged: (value) => setState(() => _congestedArea = value),
                        onAuthorizationChanged: (value) => setState(() => _hasAuthorization = value),
                      ),
                    _SimulatorMode.camera => const _CameraLab(key: ValueKey('camera')),
                    _SimulatorMode.fragments => const _FragmentLab(key: ValueKey('fragments')),
                    _SimulatorMode.pipeline => const _PipelineLab(key: ValueKey('pipeline')),
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

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selected,
    required this.onSelected,
  });

  final _SimulatorMode selected;
  final ValueChanged<_SimulatorMode> onSelected;

  static const _items = <(_SimulatorMode, IconData, String, String)>[
    (_SimulatorMode.plan, Icons.route_rounded, 'Plan', 'Plan de vol'),
    (_SimulatorMode.camera, Icons.camera_alt_rounded, 'Caméra', 'Caméra'),
    (_SimulatorMode.fragments, Icons.image_search_rounded, 'Images', 'Fragments'),
    (_SimulatorMode.pipeline, Icons.schema_rounded, 'Process', 'Traitement'),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: _items.map((item) {
          final (mode, icon, shortLabel, fullLabel) = item;
          final active = mode == selected;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Semantics(
                button: true,
                selected: active,
                label: fullLabel,
                child: InkWell(
                  borderRadius: BorderRadius.circular(17),
                  onTap: () => onSelected(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    constraints: const BoxConstraints(minHeight: 62),
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 4 : 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: active ? cyan.withOpacity(.16) : Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: active ? cyan.withOpacity(.30) : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: compact ? 21 : 23,
                          color: active ? cyan : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            compact ? shortLabel : fullLabel,
                            maxLines: 1,
                            style: TextStyle(
                              color: active ? scheme.onSurface : scheme.onSurfaceVariant,
                              fontSize: compact ? 10.5 : 12,
                              fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlanLab extends StatelessWidget {
  const _PlanLab({
    super.key,
    required this.dayOperation,
    required this.vlos,
    required this.nearAerodrome,
    required this.controlledAirspace,
    required this.congestedArea,
    required this.hasAuthorization,
    required this.onDayOperationChanged,
    required this.onVlosChanged,
    required this.onNearAerodromeChanged,
    required this.onControlledAirspaceChanged,
    required this.onCongestedAreaChanged,
    required this.onAuthorizationChanged,
  });

  final bool dayOperation;
  final bool vlos;
  final bool nearAerodrome;
  final bool controlledAirspace;
  final bool congestedArea;
  final bool hasAuthorization;
  final ValueChanged<bool> onDayOperationChanged;
  final ValueChanged<bool> onVlosChanged;
  final ValueChanged<bool> onNearAerodromeChanged;
  final ValueChanged<bool> onControlledAirspaceChanged;
  final ValueChanged<bool> onCongestedAreaChanged;
  final ValueChanged<bool> onAuthorizationChanged;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final gsd = controller.altitude * .035;
    final footprintWidth = 4000 * gsd / 100;
    final footprintHeight = 3000 * gsd / 100;
    final effectiveWidth = footprintWidth * (1 - controller.sideOverlap / 100);
    final effectiveHeight = footprintHeight * (1 - controller.frontOverlap / 100);
    final imageCount = (controller.areaHectares * 10000 / math.max(1, effectiveWidth * effectiveHeight)).ceil();
    final flightLength = controller.areaHectares * 10000 / math.max(10, effectiveWidth) * 1.08;
    final duration = flightLength / controller.speed / 60;
    final batteries = math.max(1, (duration / 17).ceil());
    final quality = _planQuality(controller.frontOverlap, controller.sideOverlap, controller.altitude, controller.speed);
    final compliance = assessAnacimSimulation(
      AnacimSimulationInput(
        altitudeMeters: controller.altitude,
        speedMetersPerSecond: controller.speed,
        dayOperation: dayOperation,
        vlos: vlos,
        nearAerodrome: nearAerodrome,
        controlledAirspace: controlledAirspace,
        congestedArea: congestedArea,
        hasAuthorization: hasAuthorization,
      ),
    );

    return Column(
      key: const ValueKey('plan-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Simulateur de plan de vol',
          subtitle: 'Les valeurs sont pédagogiques et illustrent les compromis entre détail, couverture, durée et robustesse.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 860;
            final preview = Column(
              children: [
                FlightPlanPreview(
                  frontOverlap: controller.frontOverlap,
                  sideOverlap: controller.sideOverlap,
                  altitude: controller.altitude,
                ),
                const SizedBox(height: 12),
                _PlanAdvice(quality: quality, controller: controller),
                const SizedBox(height: 12),
                _AnacimComplianceCard(
                  result: compliance,
                  onOpenRules: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegulationScreen()),
                  ),
                ),
              ],
            );
            final controls = _PlannerControls(
              controller: controller,
              dayOperation: dayOperation,
              vlos: vlos,
              nearAerodrome: nearAerodrome,
              controlledAirspace: controlledAirspace,
              congestedArea: congestedArea,
              hasAuthorization: hasAuthorization,
              onDayOperationChanged: onDayOperationChanged,
              onVlosChanged: onVlosChanged,
              onNearAerodromeChanged: onNearAerodromeChanged,
              onControlledAirspaceChanged: onControlledAirspaceChanged,
              onCongestedAreaChanged: onCongestedAreaChanged,
              onAuthorizationChanged: onAuthorizationChanged,
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: preview),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: controls),
                ],
              );
            }
            return Column(children: [preview, const SizedBox(height: 16), controls]);
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: columns == 4 ? 1.3 : 1.28,
              children: [
                MetricCard(value: '${gsd.toStringAsFixed(1)} cm', label: 'GSD simulé', icon: Icons.grid_4x4_rounded),
                MetricCard(value: '$imageCount', label: 'Images estimées', icon: Icons.photo_library_rounded, accent: orange),
                MetricCard(value: '${duration.toStringAsFixed(0)} min', label: 'Durée de vol', icon: Icons.timer_rounded, accent: violet),
                MetricCard(value: '$batteries', label: 'Batterie(s) conseillée(s)', icon: Icons.battery_charging_full_rounded, accent: success),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lecture DroneAtlas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                _InsightRow(icon: Icons.photo_size_select_large_rounded, color: cyan, title: 'Empreinte d’une image', text: '${footprintWidth.toStringAsFixed(0)} × ${footprintHeight.toStringAsFixed(0)} m environ'),
                _InsightRow(icon: Icons.repeat_rounded, color: orange, title: 'Pas utile entre images', text: '${effectiveHeight.toStringAsFixed(1)} m dans le sens du vol'),
                _InsightRow(icon: Icons.view_week_rounded, color: violet, title: 'Espacement des lignes', text: '${effectiveWidth.toStringAsFixed(1)} m environ'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static int _planQuality(double front, double side, double altitude, double speed) {
    var score = 100;
    if (front < 70) {
      score -= 28;
    }
    if (side < 60) {
      score -= 28;
    }
    if (altitude > anacimMaxAltitudeMeters) {
      score -= 35;
    } else if (altitude >= 80) {
      score -= 5;
    }
    if (altitude < 45) {
      score -= 8;
    }
    if (speed > 10) {
      score -= 15;
    }
    if (front > 88 || side > 82) {
      score -= 5;
    }
    return score.clamp(0, 100).toInt();
  }
}

class _PlannerControls extends StatelessWidget {
  const _PlannerControls({
    required this.controller,
    required this.dayOperation,
    required this.vlos,
    required this.nearAerodrome,
    required this.controlledAirspace,
    required this.congestedArea,
    required this.hasAuthorization,
    required this.onDayOperationChanged,
    required this.onVlosChanged,
    required this.onNearAerodromeChanged,
    required this.onControlledAirspaceChanged,
    required this.onCongestedAreaChanged,
    required this.onAuthorizationChanged,
  });

  final AppController controller;
  final bool dayOperation;
  final bool vlos;
  final bool nearAerodrome;
  final bool controlledAirspace;
  final bool congestedArea;
  final bool hasAuthorization;
  final ValueChanged<bool> onDayOperationChanged;
  final ValueChanged<bool> onVlosChanged;
  final ValueChanged<bool> onNearAerodromeChanged;
  final ValueChanged<bool> onControlledAirspaceChanged;
  final ValueChanged<bool> onCongestedAreaChanged;
  final ValueChanged<bool> onAuthorizationChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                GradientIcon(icon: Icons.tune_rounded, size: 44),
                SizedBox(width: 12),
                Expanded(child: Text('Paramètres de mission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
              ],
            ),
            const SizedBox(height: 18),
            _SliderControl(
              label: 'Surface',
              value: controller.areaHectares,
              min: 5,
              max: 80,
              divisions: 15,
              unit: 'ha',
              onChanged: (value) => controller.updatePlanner(newArea: value),
            ),
            _SliderControl(
              label: 'Altitude',
              value: controller.altitude,
              min: 35,
              max: 150,
              divisions: 23,
              unit: 'm',
              onChanged: (value) => controller.updatePlanner(newAltitude: value),
            ),
            _SliderControl(
              label: 'Recouvrement longitudinal',
              value: controller.frontOverlap,
              min: 60,
              max: 90,
              divisions: 6,
              unit: '%',
              onChanged: (value) => controller.updatePlanner(newFrontOverlap: value),
            ),
            _SliderControl(
              label: 'Recouvrement latéral',
              value: controller.sideOverlap,
              min: 50,
              max: 85,
              divisions: 7,
              unit: '%',
              onChanged: (value) => controller.updatePlanner(newSideOverlap: value),
            ),
            _SliderControl(
              label: 'Vitesse',
              value: controller.speed,
              min: 3,
              max: 13,
              divisions: 10,
              unit: 'm/s',
              onChanged: (value) => controller.updatePlanner(newSpeed: value),
            ),
            const Divider(height: 30),
            const Text(
              'Scénario réglementaire',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Ces options déclenchent les contrôles pédagogiques de l’Annexe 5 au RAS 06.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            _ScenarioSwitch(
              icon: Icons.light_mode_rounded,
              title: 'Opération de jour',
              value: dayOperation,
              onChanged: onDayOperationChanged,
            ),
            _ScenarioSwitch(
              icon: Icons.visibility_rounded,
              title: 'Vol en visibilité directe (VLOS)',
              value: vlos,
              onChanged: onVlosChanged,
            ),
            _ScenarioSwitch(
              icon: Icons.flight_land_rounded,
              title: 'Proche d’un aérodrome',
              value: nearAerodrome,
              onChanged: onNearAerodromeChanged,
            ),
            _ScenarioSwitch(
              icon: Icons.radar_rounded,
              title: 'Espace aérien contrôlé',
              value: controlledAirspace,
              onChanged: onControlledAirspaceChanged,
            ),
            _ScenarioSwitch(
              icon: Icons.location_city_rounded,
              title: 'Zone urbaine / encombrée',
              value: congestedArea,
              onChanged: onCongestedAreaChanged,
            ),
            _ScenarioSwitch(
              icon: Icons.verified_user_rounded,
              title: 'Autorisation applicable confirmée',
              value: hasAuthorization,
              onChanged: onAuthorizationChanged,
              positive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioSwitch extends StatelessWidget {
  const _ScenarioSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.positive = false,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final activeColor = positive ? success : orange;
    return SwitchListTile.adaptive(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: value,
      activeColor: activeColor,
      onChanged: onChanged,
      secondary: Icon(icon, color: value ? activeColor : Theme.of(context).colorScheme.onSurfaceVariant, size: 21),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
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
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: cyan.withOpacity(.12), borderRadius: BorderRadius.circular(99)),
                child: Text('${value.round()} $unit', style: const TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
          Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _PlanAdvice extends StatelessWidget {
  const _PlanAdvice({required this.quality, required this.controller});

  final int quality;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final color = quality >= 80 ? success : quality >= 60 ? orange : danger;
    final title = quality >= 80 ? 'Plan robuste' : quality >= 60 ? 'Plan perfectible' : 'Plan risqué';
    final issues = <String>[];
    if (controller.frontOverlap < 70) {
      issues.add('Augmente le recouvrement longitudinal.');
    }
    if (controller.sideOverlap < 60) {
      issues.add('Les bandes risquent de ne pas assez se rejoindre.');
    }
    if (controller.speed > 10) {
      issues.add(
        'La vitesse peut augmenter le flou et espacer les déclenchements.',
      );
    }
    if (controller.altitude > anacimMaxAltitudeMeters) {
      issues.insert(
        0,
        'Altitude supérieure à 300 ft AGL : NO-GO sans permission applicable.',
      );
    } else if (controller.altitude >= 80) {
      issues.add(
        'Altitude proche de la limite générale : surveille le relief et la hauteur AGL.',
      );
    }
    if (controller.frontOverlap > 88 || controller.sideOverlap > 82) {
      issues.add(
        'Le nombre d’images augmente fortement sans toujours apporter un gain utile.',
      );
    }
    if (issues.isEmpty) {
      issues.add(
        'Les paramètres forment un bon équilibre pour une zone plane et texturée.',
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: color.withOpacity(.11), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(.24))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressRing(value: quality / 100, label: '$quality', size: 58, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 5),
                Text(issues.first, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnacimComplianceCard extends StatelessWidget {
  const _AnacimComplianceCard({required this.result, required this.onOpenRules});

  final AnacimComplianceResult result;
  final VoidCallback onOpenRules;

  @override
  Widget build(BuildContext context) {
    final color = switch (result.level) {
      AnacimComplianceLevel.compliant => success,
      AnacimComplianceLevel.caution => orange,
      AnacimComplianceLevel.blocked => danger,
    };
    final icon = switch (result.level) {
      AnacimComplianceLevel.compliant => Icons.check_circle_rounded,
      AnacimComplianceLevel.caution => Icons.warning_amber_rounded,
      AnacimComplianceLevel.blocked => Icons.block_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.title,
                  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final message in result.messages.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: CircleAvatar(radius: 3, backgroundColor: color),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(message, style: const TextStyle(height: 1.38, fontSize: 12))),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpenRules,
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('Voir l’Annexe 5 résumée'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraLab extends StatelessWidget {
  const _CameraLab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final blur = math.max(0.0, (650 - controller.shutter) / 160).toDouble();
    final brightness = controller.brightness;
    final brightnessOffset = brightness * 130;
    final matrix = <double>[
      1, 0, 0, 0, brightnessOffset,
      0, 1, 0, 0, brightnessOffset,
      0, 0, 1, 0, brightnessOffset,
      0, 0, 0, 1, 0,
    ];
    final quality = (100 - blur * 17 - brightness.abs() * 35 - controller.cameraAngle.abs() * .45).round().clamp(0, 100).toInt();

    return Column(
      key: const ValueKey('camera-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Laboratoire caméra',
          subtitle: 'Observe comment vitesse d’obturation, luminosité et angle influencent un fragment aérien.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 820;
            final preview = Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1.35,
                        child: Transform.rotate(
                          angle: controller.cameraAngle * math.pi / 720,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(matrix),
                            child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset('assets/images/tel1.webp', fit: BoxFit.cover),
                                  if (blur > .05)
                                    BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                                      child: Container(color: Colors.transparent),
                                    ),
                                  Positioned(
                                    left: 12,
                                    top: 12,
                                    child: Pill(
                                      label: quality >= 80 ? 'IMAGE EXPLOITABLE' : quality >= 55 ? 'À CONTRÔLER' : 'IMAGE RISQUÉE',
                                      icon: quality >= 80 ? Icons.check_rounded : Icons.warning_amber_rounded,
                                      color: quality >= 80 ? success : quality >= 55 ? orange : danger,
                                    ),
                                  ),
                                ],
                              ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ProgressRing(value: quality / 100, label: '$quality', size: 58, color: quality >= 80 ? success : quality >= 55 ? orange : danger),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            _cameraAdvice(controller.shutter, brightness, controller.cameraAngle),
                            style: const TextStyle(height: 1.42, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
            final controls = Card(
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Réglages simulés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 18),
                    _SliderControl(label: 'Vitesse d’obturation', value: controller.shutter, min: 200, max: 1600, divisions: 14, unit: '1/s', onChanged: (value) => controller.updateCamera(newShutter: value)),
                    _SliderControl(label: 'Correction de luminosité', value: controller.brightness, min: -.65, max: .65, divisions: 13, unit: 'EV', onChanged: (value) => controller.updateCamera(newBrightness: value)),
                    _SliderControl(label: 'Angle caméra', value: controller.cameraAngle, min: 0, max: 60, divisions: 12, unit: '°', onChanged: (value) => controller.updateCamera(newCameraAngle: value)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: violet.withOpacity(.10), borderRadius: BorderRadius.circular(16)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: violet),
                          SizedBox(width: 10),
                          Expanded(child: Text('Cette simulation exagère volontairement certains effets pour faciliter l’apprentissage.', style: TextStyle(height: 1.4, fontSize: 12))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
            if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 6, child: preview), const SizedBox(width: 16), Expanded(flex: 5, child: controls)]);
            return Column(children: [preview, const SizedBox(height: 16), controls]);
          },
        ),
      ],
    );
  }

  static String _cameraAdvice(double shutter, double brightness, double angle) {
    if (shutter < 500) return 'La vitesse est lente pour une plateforme en mouvement : les détails risquent de se mélanger et l’appariement peut échouer.';
    if (brightness.abs() > .45) return brightness > 0 ? 'Les zones claires perdent de la texture. Réduis l’exposition ou choisis un créneau plus homogène.' : 'Les ombres deviennent difficiles à lire. Une exposition plus équilibrée donnera davantage de détails.';
    if (angle > 45) return 'L’oblique forte montre les façades, mais augmente les différences d’échelle et les zones masquées.';
    if (angle > 15) return 'Angle utile pour la 3D : combine ces vues avec une couverture nadirale organisée.';
    return 'Réglage cohérent pour une acquisition nadirale nette et homogène.';
  }
}

class _FragmentLab extends StatefulWidget {
  const _FragmentLab({super.key});

  @override
  State<_FragmentLab> createState() => _FragmentLabState();
}

class _FragmentLabState extends State<_FragmentLab> {
  int _current = 0;
  String? _answer;
  bool _checked = false;
  int _score = 0;

  static const _items = [
    _FragmentItem(asset: 'assets/images/tel1.webp', issue: 'Bonne', prompt: 'Ce fragment est-il suffisamment net et équilibré ?'),
    _FragmentItem(asset: 'assets/images/tel2.webp', issue: 'Floue', prompt: 'Quel défaut principal est simulé ici ?', blur: 5),
    _FragmentItem(asset: 'assets/images/tel3.webp', issue: 'Surexposée', prompt: 'Quel défaut principal est simulé ici ?', washout: .55),
    _FragmentItem(asset: 'assets/images/gal3.webp', issue: 'Oblique', prompt: 'Quelle géométrie de prise de vue reconnais-tu ?', angle: .09),
  ];

  void _validate() {
    if (_answer == null) return;
    setState(() {
      _checked = true;
      if (_answer == _items[_current].issue) _score += 25;
    });
  }

  void _next() {
    if (_current == _items.length - 1) {
      setState(() {
        _current = 0;
        _answer = null;
        _checked = false;
        _score = 0;
      });
      return;
    }
    setState(() {
      _current++;
      _answer = null;
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_current];
    final correct = _answer == item.issue;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      key: const ValueKey('fragment-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Diagnostic de fragments',
          subtitle: 'Classe les fragments préchargés comme lors d’un contrôle après vol. Score actuel : $_score/100.',
        ),
        const SizedBox(height: 16),
        MaxWidthBox(
          maxWidth: 820,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Pill(label: 'FRAGMENT ${_current + 1}/${_items.length}', icon: Icons.crop_rounded),
                      const Spacer(),
                      Text('$_score pts', style: const TextStyle(color: orange, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 17),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AspectRatio(
                      aspectRatio: 1.45,
                      child: Transform.rotate(
                        angle: item.angle,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(item.asset, fit: BoxFit.cover),
                            if (item.blur > 0)
                              BackdropFilter(filter: ImageFilter.blur(sigmaX: item.blur, sigmaY: item.blur), child: Container(color: Colors.transparent)),
                            if (item.washout > 0) Container(color: Colors.white.withOpacity(item.washout)),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(painter: _CrosshairPainter()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(item.prompt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: ['Bonne', 'Floue', 'Surexposée', 'Oblique']
                        .map(
                          (label) {
                            final selected = _answer == label;
                            return ChoiceChip(
                              selected: selected,
                              showCheckmark: true,
                              selectedColor: isDark ? cyan.withOpacity(.28) : cyan.withOpacity(.22),
                              backgroundColor: isDark ? const Color(0xFF122235) : const Color(0xFFEAF4FF),
                              disabledColor: isDark ? const Color(0xFF182737) : const Color(0xFFF3F6FA),
                              side: BorderSide(
                                color: selected
                                    ? cyan.withOpacity(.75)
                                    : scheme.outline.withOpacity(isDark ? .30 : .22),
                              ),
                              label: Text(
                                label,
                                style: TextStyle(
                                  color: selected
                                      ? (isDark ? Colors.white : const Color(0xFF06263D))
                                      : (isDark ? scheme.onSurface : const Color(0xFF102A43)),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onSelected: _checked ? null : (_) => setState(() => _answer = label),
                            );
                          },
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  if (!_checked)
                    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _answer == null ? null : _validate, icon: const Icon(Icons.search_rounded), label: const Text('Analyser le fragment'))),
                  if (_checked) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: (correct ? success : orange).withOpacity(.11), borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(correct ? Icons.check_circle_rounded : Icons.lightbulb_rounded, color: correct ? success : orange),
                          const SizedBox(width: 11),
                          Expanded(child: Text(correct ? 'Bien vu ! ${_fragmentExplanation(item.issue)}' : 'Réponse attendue : ${item.issue}. ${_fragmentExplanation(item.issue)}', style: const TextStyle(height: 1.45, fontWeight: FontWeight.w700))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _next, icon: Icon(_current == _items.length - 1 ? Icons.replay_rounded : Icons.arrow_forward_rounded), label: Text(_current == _items.length - 1 ? 'Recommencer' : 'Fragment suivant'))),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _fragmentExplanation(String issue) {
    return switch (issue) {
      'Bonne' => 'Les textures restent lisibles et les contrastes sont suffisants pour rechercher des correspondances.',
      'Floue' => 'Les contours étalés réduisent fortement les points caractéristiques fiables.',
      'Surexposée' => 'Les hautes lumières écrasées ne contiennent plus de texture exploitable.',
      'Oblique' => 'La vue inclinée montre davantage les façades et volumes, mais doit être intégrée dans une acquisition cohérente.',
      _ => '',
    };
  }
}

class _FragmentItem {
  const _FragmentItem({required this.asset, required this.issue, required this.prompt, this.blur = 0, this.washout = 0, this.angle = 0});

  final String asset;
  final String issue;
  final String prompt;
  final double blur;
  final double washout;
  final double angle;
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = cyan.withOpacity(.55)..strokeWidth = 1;
    canvas.drawLine(Offset(size.width / 2 - 28, size.height / 2), Offset(size.width / 2 + 28, size.height / 2), paint);
    canvas.drawLine(Offset(size.width / 2, size.height / 2 - 28), Offset(size.width / 2, size.height / 2 + 28), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 18, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PipelineLab extends StatefulWidget {
  const _PipelineLab({super.key});

  @override
  State<_PipelineLab> createState() => _PipelineLabState();
}

class _PipelineLabState extends State<_PipelineLab> {
  int _step = 0;
  bool _running = false;

  static const _steps = [
    ('Lecture des fragments', Icons.photo_library_rounded, 'Métadonnées, résolution et cohérence de la série.'),
    ('Détection des détails', Icons.auto_awesome_motion_rounded, 'Recherche d’angles, textures et motifs distinctifs.'),
    ('Appariement', Icons.compare_arrows_rounded, 'Association des mêmes détails entre plusieurs images.'),
    ('Estimation des caméras', Icons.videocam_rounded, 'Calcul des positions et orientations relatives.'),
    ('Nuage clairsemé', Icons.scatter_plot_rounded, 'Première représentation tridimensionnelle de la scène.'),
    ('Densification', Icons.grain_rounded, 'Calcul d’un grand nombre de points 3D supplémentaires.'),
    ('Surface et orthophoto', Icons.layers_rounded, 'Création des produits simulés et géoréférencés.'),
  ];

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _step = 0;
    });
    for (var i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() => _step = i + 1);
    }
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final finished = _step == _steps.length;
    return Column(
      key: const ValueKey('pipeline-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Traitement photogrammétrique simulé',
          subtitle: 'Aucun calcul lourd : DroneAtlas anime la logique de la chaîne pour expliquer ce que fait un logiciel réel.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 820;
            final visual = Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: SizedBox(
                        key: ValueKey(_step),
                        height: 300,
                        child: _step < 5
                            ? _PipelineVisual(step: _step)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(_step == 5 ? 'assets/images/mbatalpreview.webp' : 'assets/images/khelcompreview.webp', fit: BoxFit.cover),
                                    Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, navy.withOpacity(.7)]))),
                                    Positioned(left: 16, bottom: 15, child: Pill(label: _step == 5 ? 'NUAGE / MAILLAGE' : 'ORTHOPHOTO SIMULÉE', icon: Icons.layers_rounded)),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: _step / _steps.length, minHeight: 8, borderRadius: BorderRadius.circular(99)),
                    const SizedBox(height: 13),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _running ? null : _run,
                        icon: Icon(finished ? Icons.replay_rounded : Icons.play_arrow_rounded),
                        label: Text(_running ? 'Traitement simulé…' : finished ? 'Rejouer la simulation' : 'Lancer la simulation'),
                      ),
                    ),
                  ],
                ),
              ),
            );
            final timeline = Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pipeline', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    ...List.generate(_steps.length, (index) {
                      final active = index == _step && _running;
                      final done = index < _step;
                      final data = _steps[index];
                      return _TimelineStep(
                        icon: data.$2,
                        title: data.$1,
                        description: data.$3,
                        active: active,
                        done: done,
                        last: index == _steps.length - 1,
                      );
                    }),
                  ],
                ),
              ),
            );
            if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 6, child: visual), const SizedBox(width: 16), Expanded(flex: 5, child: timeline)]);
            return Column(children: [visual, const SizedBox(height: 16), timeline]);
          },
        ),
      ],
    );
  }
}

class _PipelineVisual extends StatelessWidget {
  const _PipelineVisual({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0A2634), Color(0xFF07131F)]),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (step == 0)
            const Center(child: Icon(Icons.play_circle_fill_rounded, size: 86, color: cyan)),
          if (step == 1)
            Padding(padding: const EdgeInsets.all(26), child: Image.asset('assets/images/kaolack_preview.webp', fit: BoxFit.contain)),
          if (step == 2)
            const Center(child: Icon(Icons.auto_awesome_motion_rounded, size: 100, color: orange)),
          if (step == 3)
            const Center(child: Icon(Icons.compare_arrows_rounded, size: 120, color: violet)),
          if (step == 4)
            CustomPaint(painter: _PointFieldPainter()),
          Positioned(left: 16, top: 16, child: Pill(label: step == 0 ? 'PRÊT' : 'ÉTAPE $step', icon: Icons.memory_rounded)),
        ],
      ),
    );
  }
}

class _PointFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12);
    for (var i = 0; i < 420; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * .72 - random.nextDouble() * 130 - math.sin(x / 45) * 24;
      final color = i % 7 == 0 ? orange : i % 5 == 0 ? violet : cyan;
      canvas.drawCircle(Offset(x, y), 1 + random.nextDouble() * 2.2, Paint()..color = color.withOpacity(.72));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.icon, required this.title, required this.description, required this.active, required this.done, required this.last});

  final IconData icon;
  final String title;
  final String description;
  final bool active;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done ? success : active ? cyan : Theme.of(context).colorScheme.onSurfaceVariant;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(.14),
                  foregroundColor: color,
                  child: Icon(done ? Icons.check_rounded : icon, size: 19),
                ),
                if (!last) Expanded(child: Container(width: 2, color: color.withOpacity(.18))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: active || done ? color : null, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(description, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.35)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.icon, required this.color, required this.title, required this.text});

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))])),
        ],
      ),
    );
  }
}
