import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';

class DroneHistoryScreen extends StatelessWidget {
  const DroneHistoryScreen({super.key});

  static const _events = <_HistoryEvent>[
    _HistoryEvent(
      year: '1918',
      title: 'Kettering Bug',
      text: 'Un aéronef expérimental sans pilote utilisant des mécanismes de guidage bien avant le GNSS moderne.',
      image: 'assets/images/history_kettering.webp',
      credit: 'Greg Hume • CC BY-SA 3.0 • Wikimedia Commons',
    ),
    _HistoryEvent(
      year: '1950–1970',
      title: 'Ryan Firebee',
      text: 'Les drones-cibles et de reconnaissance accélèrent les progrès de la radiocommande, de la navigation et de la récupération.',
      image: 'assets/images/history_firebee.webp',
      credit: 'U.S. Air Force • Domaine public',
    ),
    _HistoryEvent(
      year: '1990',
      title: 'Drones d’endurance',
      text: 'Les systèmes pilotés à distance combinent longue endurance, capteurs stabilisés et transmission de données.',
      image: 'assets/images/history_predator.webp',
      credit: 'U.S. Air Force • Domaine public',
    ),
    _HistoryEvent(
      year: '2013',
      title: 'Révolution civile',
      text: 'Les multirotors compacts démocratisent la photographie aérienne, puis la cartographie automatisée.',
      image: 'assets/images/history_phantom.webp',
      credit: 'Maurizio Pesce • CC BY 2.0 • Wikimedia Commons',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histoire des drones')),
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4A112D), Color(0xFF111520)],
                      ),
                      border: Border.all(color: orange.withOpacity(.28)),
                    ),
                    child: const Row(
                      children: [
                        GradientIcon(
                          icon: Icons.history_edu_rounded,
                          size: 56,
                          color: orange,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Des pionniers à la donnée géospatiale',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Une chronologie illustrée avec des photographies historiques créditées.',
                                style: TextStyle(color: Colors.white70, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList.separated(
                itemCount: _events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) => _HistoryCard(event: _events[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEvent {
  const _HistoryEvent({
    required this.year,
    required this.title,
    required this.text,
    required this.image,
    required this.credit,
  });

  final String year;
  final String title;
  final String text;
  final String image;
  final String credit;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.event});

  final _HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 680;
          final image = AspectRatio(
            aspectRatio: wide ? 1.45 : 1.75,
            child: Image.asset(event.image, fit: BoxFit.cover),
          );
          final content = Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.year,
                  style: const TextStyle(color: orange, fontSize: 23, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(
                  event.text,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.45),
                ),
                const SizedBox(height: 11),
                Text(
                  event.credit,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 9.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
          if (wide) {
            return Row(
              children: [
                Expanded(flex: 5, child: image),
                Expanded(flex: 6, child: content),
              ],
            );
          }
          return Column(children: [image, content]);
        },
      ),
    );
  }
}
