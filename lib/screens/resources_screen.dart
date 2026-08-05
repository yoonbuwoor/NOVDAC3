import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/resource_library.dart';
import '../widgets/common.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _category = 'Tout';

  List<String> get categories => [
        'Tout',
        ...{...academyResources.map((item) => item.category)},
      ];

  List<AcademyResource> get featured => academyResources
      .where((resource) => resource.featured && resource.visualAsset != null)
      .toList(growable: false);

  List<AcademyResource> get visible => academyResources.where((resource) {
        if (_category != 'Tout' && resource.category != _category) return false;
        final q = _query.trim().toLowerCase();
        if (q.isEmpty) return true;
        return [
          resource.title,
          resource.summary,
          resource.category,
          resource.level,
          ...resource.content,
        ].join(' ').toLowerCase().contains(q);
      }).toList(growable: false);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeScale = math.min(media.textScaler.scale(1), 1.18);
    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.linear(safeScale)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ressources & fiches terrain')),
        body: AmbientBackground(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: _ResourceHero(
                      total: academyResources.length,
                      visuals: featured.length,
                      categories: categories.length - 1,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: SectionHeading(
                      eyebrow: 'ATLAS VISUEL HORS LIGNE',
                      title: '${featured.length} fiches illustrées haute définition',
                      subtitle:
                          'Des mémos complets à consulter sur le terrain, même sans connexion.',
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: SizedBox(
                    height: 300,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: featured.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final resource = featured[index];
                        return _VisualResourceCard(
                          resource: resource,
                          onTap: () => _showResource(context, resource),
                        );
                      },
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
                        hintText: 'Rechercher : GSD, ANACIM, LiDAR, batterie…',
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
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final count = category == 'Tout'
                            ? academyResources.length
                            : academyResources
                                .where((item) => item.category == category)
                                .length;
                        return ChoiceChip(
                          label: Text('$category · $count'),
                          selected: _category == category,
                          onSelected: (_) => setState(() => _category = category),
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
                      eyebrow: 'BIBLIOTHÈQUE COMPLÈTE',
                      title: '${visible.length} ressource(s)',
                      subtitle:
                          'Checklists, méthodes, réglementation, choix du matériel et métier.',
                    ),
                  ),
                ),
              ),
              if (visible.isEmpty)
                const SliverToBoxAdapter(
                  child: MaxWidthBox(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Aucune ressource ne correspond à la recherche.')),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _ResourceCard(
                      resource: visible[index],
                      onTap: () => _showResource(context, visible[index]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResource(BuildContext context, AcademyResource resource) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResourceDetails(resource: resource),
    );
  }
}

class _ResourceHero extends StatelessWidget {
  const _ResourceHero({
    required this.total,
    required this.visuals,
    required this.categories,
  });

  final int total;
  final int visuals;
  final int categories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A102F), Color(0xFF25122E), Color(0xFF071D27)],
        ),
        border: Border.all(color: orange.withOpacity(.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientIcon(icon: Icons.auto_stories_rounded, size: 64, color: orange),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bibliothèque DroneAtlas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Une base opérationnelle enrichie pour préparer, voler, traiter et livrer.',
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
              Expanded(child: _HeroStat(value: '$total', label: 'fiches', icon: Icons.library_books_rounded, color: cyan)),
              const SizedBox(width: 9),
              Expanded(child: _HeroStat(value: '$visuals', label: 'visuels HD', icon: Icons.image_rounded, color: orange)),
              const SizedBox(width: 9),
              Expanded(child: _HeroStat(value: '$categories', label: 'domaines', icon: Icons.category_rounded, color: success)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label, required this.icon, required this.color});

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

class _VisualResourceCard extends StatelessWidget {
  const _VisualResourceCard({required this.resource, required this.onTap});

  final AcademyResource resource;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = resource.accentColor;
    return SizedBox(
      width: 215,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(resource.visualAsset!, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xF0050A12)],
                    stops: [.38, 1],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pill(label: resource.category, color: color),
                    const SizedBox(height: 8),
                    Text(
                      resource.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, height: 1.15),
                    ),
                    const SizedBox(height: 7),
                    Text('${resource.content.length} points pratiques', style: const TextStyle(color: Colors.white70, fontSize: 11)),
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

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource, required this.onTap});

  final AcademyResource resource;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = resource.accentColor;
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(18)),
                child: Icon(resource.icon, color: color, size: 29),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      children: [
                        Pill(label: resource.category, color: color),
                        if (resource.visualAsset != null)
                          const Pill(label: 'FICHE HD', color: cyan),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(resource.title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(resource.summary, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.38)),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(Icons.checklist_rounded, size: 15, color: color),
                        const SizedBox(width: 5),
                        Text('${resource.content.length} points', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 13),
                        Icon(Icons.schedule_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('${resource.minutes} min', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceDetails extends StatelessWidget {
  const _ResourceDetails({required this.resource});

  final AcademyResource resource;

  @override
  Widget build(BuildContext context) {
    final color = resource.accentColor;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .86,
      minChildSize: .55,
      maxChildSize: .97,
      builder: (context, controller) => Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        clipBehavior: Clip.antiAlias,
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 42),
          children: [
            Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(.18), borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 16),
            if (resource.visualAsset != null) ...[
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => _FullVisualScreen(resource: resource)),
                ),
                child: Hero(
                  tag: resource.visualAsset!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: .75,
                      child: Image.asset(resource.visualAsset!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.zoom_in_rounded, size: 16, color: color),
                  const SizedBox(width: 5),
                  Text('Touchez la fiche pour l’ouvrir en plein écran', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                CircleAvatar(radius: 29, backgroundColor: color.withOpacity(.15), child: Icon(resource.icon, color: color, size: 29)),
                const SizedBox(width: 12),
                Expanded(child: Pill(label: resource.category, color: color)),
              ],
            ),
            const SizedBox(height: 14),
            Text(resource.title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, height: 1.15)),
            const SizedBox(height: 8),
            Text(resource.summary, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15, height: 1.45)),
            const SizedBox(height: 20),
            ...List.generate(
              resource.content.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(10)),
                      child: Text('${index + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(child: Text(resource.content[index], style: const TextStyle(height: 1.48))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: orange.withOpacity(.08), borderRadius: BorderRadius.circular(18), border: Border.all(color: orange.withOpacity(.2))),
              child: const Text(
                'Fiche pédagogique : adapte toujours la méthode au manuel du fabricant, au site, au client et à la réglementation officielle en vigueur.',
                style: TextStyle(fontSize: 11.5, height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullVisualScreen extends StatelessWidget {
  const _FullVisualScreen({required this.resource});

  final AcademyResource resource;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02060B),
      appBar: AppBar(title: Text(resource.title)),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: .8,
          maxScale: 5,
          child: Center(
            child: Hero(
              tag: resource.visualAsset!,
              child: Image.asset(resource.visualAsset!, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
