import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../models/academy_models.dart';
import '../widgets/common.dart';

class DomainDetailScreen extends StatelessWidget {
  const DomainDetailScreen({super.key, required this.domain});

  final ApplicationDomain domain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 330,
            pinned: true,
            title: Text(domain.title),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(domain.image, fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, navy.withOpacity(.94)]))),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: cyan, borderRadius: BorderRadius.circular(14)), child: Icon(domain.icon, color: navy)),
                        const SizedBox(height: 12),
                        Text(domain.title, style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 5),
                        Text(domain.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              maxWidth: 950,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeading(title: 'Objectif de la mission'),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientIcon(icon: domain.icon, size: 56),
                            const SizedBox(width: 15),
                            Expanded(child: Text(domain.objective, style: const TextStyle(fontSize: 16, height: 1.55, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 680;
                        final products = _InfoList(title: 'Produits attendus', icon: Icons.layers_rounded, color: violet, items: domain.products);
                        final flight = _InfoList(title: 'Principes de vol', icon: Icons.route_rounded, color: cyan, items: domain.flight);
                        if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: products), const SizedBox(width: 14), Expanded(child: flight)]);
                        return Column(children: [products, const SizedBox(height: 14), flight]);
                      },
                    ),
                    const SizedBox(height: 14),
                    _InfoList(title: 'Points de vigilance', icon: Icons.warning_amber_rounded, color: orange, items: domain.watchouts),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: cyan.withOpacity(.09), borderRadius: BorderRadius.circular(22), border: Border.all(color: cyan.withOpacity(.2))),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 600;
                          final text = const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Utiliser ce domaine dans le laboratoire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              SizedBox(height: 5),
                              Text('DroneAtlas adaptera le contexte pédagogique et mémorisera ton choix pour les prochaines simulations.'),
                            ],
                          );
                          final button = FilledButton.icon(
                            onPressed: () {
                              AppScope.of(context).setDomain(domain.title);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${domain.title} sélectionné comme domaine actif.')));
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Choisir ce domaine'),
                          );
                          if (wide) return Row(children: [Expanded(child: text), const SizedBox(width: 16), button]);
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, const SizedBox(height: 14), SizedBox(width: double.infinity, child: button)]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoList extends StatelessWidget {
  const _InfoList({required this.title, required this.icon, required this.color, required this.items});

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [GradientIcon(icon: icon, color: color, size: 44), const SizedBox(width: 11), Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))]),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.check_circle_rounded, color: color, size: 18), const SizedBox(width: 9), Expanded(child: Text(item, style: const TextStyle(height: 1.35, fontWeight: FontWeight.w600)))]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
