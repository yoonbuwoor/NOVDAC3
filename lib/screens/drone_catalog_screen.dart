import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../data/drone_catalog_data.dart';
import '../models/drone_catalog_models.dart';
import '../widgets/common.dart';
import 'drone_history_screen.dart';
import 'regulation_screen.dart';

// WhatsApp attend le numéro international sans le préfixe 00.
const _novateur221SalesPhone = '221782780302';

String _novateur221SalesWhatsAppUrl([String? droneName]) {
  final subject = droneName ?? 'un drone DJI';
  final message =
      'Bonjour Novateur221, je souhaite recevoir des renseignements sur '
      '$subject via DroneAtlas Academy. Pouvez-vous m’aider à vérifier le '
      'prix, la disponibilité et à identifier un fournisseur certifié adapté '
      'à mon besoin ?';
  return 'https://wa.me/$_novateur221SalesPhone?text=${Uri.encodeComponent(message)}';
}

class DroneCatalogScreen extends StatefulWidget {
  const DroneCatalogScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<DroneCatalogScreen> createState() => _DroneCatalogScreenState();
}

class _DroneCatalogScreenState extends State<DroneCatalogScreen> {
  DroneNeed _need = DroneNeed.smallMapping;
  DroneBudget _budget = DroneBudget.any;
  bool _mappingOnly = false;
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DroneCatalogItem> get _visible {
    final q = _query.trim().toLowerCase();
    final result = djiDroneCatalog.where((drone) {
      if (_mappingOnly && !drone.professionalMapping) return false;
      if (!_budget.accepts(drone)) return false;
      if (q.isNotEmpty) {
        final haystack = [
          drone.name,
          drone.family,
          drone.profile,
          drone.sensor,
          drone.bestFor,
          ...drone.tags,
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final score = (b.needScores[_need] ?? 0)
            .compareTo(a.needScores[_need] ?? 0);
        if (score != 0) return score;
        return (a.officialPriceCfa ?? 999999999)
            .compareTo(b.officialPriceCfa ?? 999999999);
      });
    return result;
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir ce lien.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final drones = _visible;
    final top = drones.take(3).toList();

    return AmbientBackground(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: BrandBar(
                isDark: widget.isDark,
                onToggleTheme: widget.onToggleTheme,
                title: 'Choisir un drone',
                subtitle:
                    '${djiDroneCatalog.length} plateformes • budget • domaine • repère ANACIM',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                child: _SelectorHero(
                  need: _need,
                  budget: _budget,
                  mappingOnly: _mappingOnly,
                  onNeedChanged: (value) => setState(() => _need = value),
                  onBudgetChanged: (value) => setState(() => _budget = value),
                  onMappingChanged: (value) =>
                      setState(() => _mappingOnly = value),
                  onContact: () => _open(_novateur221SalesWhatsAppUrl()),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher : RTK, LiDAR, thermique, compact…',
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DroneHistoryScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.history_edu_rounded),
                        label: const Text('Histoire des drones'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegulationScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.gavel_rounded),
                        label: const Text('Régime ANACIM'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: SectionHeading(
                  eyebrow: 'SÉLECTION PERSONNALISÉE',
                  title: top.isEmpty ? 'Aucun résultat' : _need.label,
                  subtitle: top.isEmpty
                      ? 'Élargis le budget ou retire un filtre.'
                      : 'Classement par adéquation au besoin, puis par prix public disponible.',
                ),
              ),
            ),
          ),
          if (top.isNotEmpty)
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: SizedBox(
                  height: 346,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: top.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _RecommendationCard(
                      drone: top[index],
                      score: top[index].needScores[_need] ?? 0,
                      rank: index + 1,
                      need: _need,
                      onOpen: () => _showDrone(top[index]),
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
                child: SectionHeading(
                  title: '${drones.length} drone(s) compatible(s)',
                  subtitle:
                      'Photos produit, prix indicatifs en F CFA, usages et repère de classification.',
                ),
              ),
            ),
          ),
          if (drones.isEmpty)
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  child: _EmptyState(
                    onReset: () => setState(() {
                      _budget = DroneBudget.any;
                      _mappingOnly = false;
                      _query = '';
                      _search.clear();
                    }),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent >= 950
                      ? 3
                      : constraints.crossAxisExtent >= 620
                          ? 2
                          : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? .90 : .78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _DroneCard(
                        drone: drones[index],
                        need: _need,
                        score: drones[index].needScores[_need] ?? 0,
                        onOpen: () => _showDrone(drones[index]),
                      ),
                      childCount: drones.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showDrone(DroneCatalogItem drone) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DroneDetails(
        drone: drone,
        need: _need,
        onOpenOfficial: drone.officialProductUrl == null
            ? null
            : () => _open(drone.officialProductUrl!),
        onContact: () => _open(_novateur221SalesWhatsAppUrl(drone.name)),
      ),
    );
  }
}

class _SelectorHero extends StatelessWidget {
  const _SelectorHero({
    required this.need,
    required this.budget,
    required this.mappingOnly,
    required this.onNeedChanged,
    required this.onBudgetChanged,
    required this.onMappingChanged,
    required this.onContact,
  });

  final DroneNeed need;
  final DroneBudget budget;
  final bool mappingOnly;
  final ValueChanged<DroneNeed> onNeedChanged;
  final ValueChanged<DroneBudget> onBudgetChanged;
  final ValueChanged<bool> onMappingChanged;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B102D), Color(0xFF26102D), Color(0xFF091B25)],
        ),
        border: Border.all(color: orange.withOpacity(.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientIcon(icon: Icons.tune_rounded, size: 52, color: orange),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trouve le bon drone',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Choisis ton domaine et ton budget. DroneAtlas compare les capteurs, la précision, la productivité et la logistique. Novateur221 ne vend pas directement les drones : nous facilitons la mise en relation avec des fournisseurs certifiés.',
                      style: TextStyle(color: Colors.white70, height: 1.42),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<DroneNeed>(
            value: need,
            decoration: const InputDecoration(
              labelText: 'Domaine d’utilisation',
              prefixIcon: Icon(Icons.workspaces_rounded),
            ),
            items: DroneNeed.values
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.label),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) onNeedChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DroneBudget>(
            value: budget,
            decoration: const InputDecoration(
              labelText: 'Budget maximum',
              prefixIcon: Icon(Icons.account_balance_wallet_rounded),
            ),
            items: DroneBudget.values
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.label),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) onBudgetChanged(value);
            },
          ),
          const SizedBox(height: 6),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: mappingOnly,
            onChanged: onMappingChanged,
            title: const Text(
              'Photogrammétrie professionnelle uniquement',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Privilégie les plateformes RTK, obturateur mécanique, multispectral ou LiDAR.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.chat_rounded),
            label: const Text('Recevoir un conseil personnalisé'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Prix indicatifs convertis depuis les tarifs neufs du DJI Store officiel au taux fixe euro/F CFA. Hors livraison, douane, taxes locales, batteries supplémentaires et accessoires. Certains systèmes professionnels sont uniquement sur devis. Novateur221 ne vend pas directement les drones et facilite la mise en relation avec des fournisseurs certifiés.',
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.drone,
    required this.score,
    required this.rank,
    required this.need,
    required this.onOpen,
  });

  final DroneCatalogItem drone;
  final int score;
  final int rank;
  final DroneNeed need;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = drone.accentColor;
    return SizedBox(
      width: 292,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DroneImage(drone: drone, height: 130),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Pill(label: '#$rank', color: accent),
                          const Spacer(),
                          Pill(
                            label: '$score % compatible',
                            icon: Icons.auto_awesome_rounded,
                            color: accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        drone.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        drone.priceLabel,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '${drone.anacimCodeFor(need)} • ${drone.anacimClass}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 7),
                      Expanded(
                        child: Text(
                          drone.bestFor,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DroneCard extends StatelessWidget {
  const _DroneCard({
    required this.drone,
    required this.need,
    required this.score,
    required this.onOpen,
  });

  final DroneCatalogItem drone;
  final DroneNeed need;
  final int score;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = drone.accentColor;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DroneImage(drone: drone, height: 155),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                drone.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                drone.family,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Pill(label: '$score %', color: accent),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Text(
                      drone.priceLabel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill(
                          label: drone.anacimCodeFor(need),
                          icon: Icons.gavel_rounded,
                          color: orange,
                        ),
                        Pill(label: drone.anacimClass, color: cyan),
                        ...drone.tags.take(2).map((tag) => Pill(label: tag, color: accent)),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Expanded(
                      child: Text(
                        drone.profile,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.38,
                          fontSize: 12.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            drone.sensor,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
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

class _DroneImage extends StatelessWidget {
  const _DroneImage({required this.drone, required this.height});

  final DroneCatalogItem drone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final accent = drone.accentColor;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(.24), const Color(0xFF081721)],
        ),
      ),
      child: drone.imageAsset == null
          ? Icon(Icons.flight_rounded, size: 70, color: accent)
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                drone.imageAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.flight_rounded, size: 70, color: accent),
              ),
            ),
    );
  }
}

class _DroneDetails extends StatelessWidget {
  const _DroneDetails({
    required this.drone,
    required this.need,
    required this.onOpenOfficial,
    required this.onContact,
  });

  final DroneCatalogItem drone;
  final DroneNeed need;
  final VoidCallback? onOpenOfficial;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final accent = drone.accentColor;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .88,
      minChildSize: .60,
      maxChildSize: .97,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 34),
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _DroneImage(drone: drone, height: 210),
          ),
          const SizedBox(height: 18),
          Text(
            drone.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            drone.family,
            style: TextStyle(color: accent, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withOpacity(.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(.23)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drone.priceLabel,
                  style: TextStyle(
                    color: accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (drone.officialPriceEur != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Référence DJI : ${drone.officialPriceEur} €',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
                const SizedBox(height: 7),
                Text(
                  drone.priceNote.isEmpty
                      ? 'Prix et disponibilité à confirmer auprès du fournisseur. Novateur221 facilite uniquement la mise en relation avec des fournisseurs certifiés et ne vend pas directement les drones.'
                      : drone.priceNote,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailLine(icon: Icons.camera_alt_rounded, title: 'Capteur', text: drone.sensor, color: accent),
          _DetailLine(icon: Icons.gps_fixed_rounded, title: 'Positionnement', text: drone.positioning, color: cyan),
          _DetailLine(icon: Icons.battery_charging_full_rounded, title: 'Opération', text: drone.endurance, color: success),
          _DetailLine(icon: Icons.task_alt_rounded, title: 'Idéal pour', text: drone.bestFor, color: orange),
          _DetailLine(icon: Icons.warning_amber_rounded, title: 'À savoir', text: drone.limitations, color: danger),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: orange.withOpacity(.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: orange.withOpacity(.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Repère réglementaire ANACIM',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '${drone.anacimClass} • scénario ${drone.anacimCodeFor(need)}',
                  style: const TextStyle(color: orange, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  drone.authorizationHintFor(need),
                  style: const TextStyle(height: 1.42),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Repère pédagogique : la classe dépend de la masse totale et la catégorie dépend de l’usage réel. L’ANACIM reste seule compétente pour confirmer le régime applicable.',
                  style: TextStyle(fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.chat_rounded),
            label: const Text('Vérifier prix et disponibilité'),
          ),
          if (onOpenOfficial != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onOpenOfficial,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Voir la source officielle DJI'),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegulationScreen()),
            ),
            icon: const Icon(Icons.gavel_rounded),
            label: const Text('Vérifier la classification et l’autorisation'),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.filter_alt_off_rounded, size: 52, color: orange),
            const SizedBox(height: 12),
            const Text(
              'Aucun drone ne correspond à tous les filtres',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Essaie un budget plus large ou affiche aussi les drones d’apprentissage.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Réinitialiser'),
            ),
          ],
        ),
      ),
    );
  }
}
