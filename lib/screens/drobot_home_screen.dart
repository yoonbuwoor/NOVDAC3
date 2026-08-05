import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/drobot_sheet.dart';

class DrobotHomeScreen extends StatelessWidget {
  const DrobotHomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: BrandBar(
                isDark: isDark,
                onToggleTheme: onToggleTheme,
                title: 'Drobot IA',
                subtitle: 'Assistant intelligent drone, géomatique et photogrammétrie',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4D1431), Color(0xFF131421)],
                    ),
                    border: Border.all(color: orange.withOpacity(.28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          GradientIcon(
                            icon: Icons.smart_toy_rounded,
                            size: 64,
                            color: orange,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ton copilote expert',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Décris un besoin réel : Drobot construit une méthode et des estimations.',
                                  style: TextStyle(color: Colors.white70, height: 1.38),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => showDrobotAssistant(context),
                          icon: const Icon(Icons.chat_bubble_rounded),
                          label: const Text('Ouvrir la conversation'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: const SectionHeading(
                  title: 'Drobot sait faire',
                  subtitle: 'Des réponses structurées, pas seulement une définition rapide.',
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.crossAxisExtent >= 820 ? 3 : 1;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: columns == 1 ? 2.25 : 1.2,
                  ),
                  delegate: SliverChildListDelegate.fixed(
                    const [
                      _CapabilityCard(
                        icon: Icons.route_rounded,
                        color: orange,
                        title: 'Planifier une mission',
                        text: 'Surface, altitude, GSD, recouvrements, photos, durée, batteries et contrôles réglementaires.',
                      ),
                      _CapabilityCard(
                        icon: Icons.photo_camera_rounded,
                        color: cyan,
                        title: 'Diagnostiquer la qualité',
                        text: 'Flou, trous, mauvais alignement, GCP, checkpoints, RTK/PPK et précision finale.',
                      ),
                      _CapabilityCard(
                        icon: Icons.map_rounded,
                        color: violet,
                        title: 'Structurer les livrables',
                        text: 'Orthophoto, MNS/MNT, nuage de points, maillage 3D, QGIS, métadonnées et rapport.',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(.13),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(
                    text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
