import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../data/anacim_rules.dart';
import '../widgets/common.dart';
import 'quiz_hub_screen.dart';

class RegulationScreen extends StatefulWidget {
  const RegulationScreen({super.key});

  @override
  State<RegulationScreen> createState() => _RegulationScreenState();
}

class _RegulationScreenState extends State<RegulationScreen> {
  final TextEditingController _massController =
      TextEditingController(text: '0.9');
  RpasUseType _use = RpasUseType.professional;
  RpasClassificationResult _result = classifyRpas(
    massKg: .9,
    use: RpasUseType.professional,
  );

  @override
  void dispose() {
    _massController.dispose();
    super.dispose();
  }

  void _calculate() {
    final value = double.tryParse(_massController.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre une masse totale valide en kg.')),
      );
      return;
    }
    setState(() => _result = classifyRpas(massKg: value, use: _use));
  }

  Future<void> _openOfficialText() async {
    final uri = Uri.parse(anacimOfficialRegulationUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir le document officiel.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scale = media.textScaler.scale(1).clamp(.95, 1.05).toDouble();
    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Réglementation ANACIM'),
          actions: [
            IconButton(
              tooltip: 'Lire le texte officiel',
              onPressed: _openOfficialText,
              icon: const Icon(Icons.open_in_new_rounded),
            ),
          ],
        ),
        body: AmbientBackground(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: _Hero(onOpenOfficial: _openOfficialText),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: const SectionHeading(
                      eyebrow: 'OUTIL PÉDAGOGIQUE',
                      title: 'Quelle classe et quelle catégorie ?',
                      subtitle:
                          'La classe dépend de la masse totale du RPAS. La catégorie dépend de l’usage réel.',
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: _Classifier(
                      massController: _massController,
                      use: _use,
                      result: _result,
                      onUseChanged: (value) => setState(() => _use = value),
                      onCalculate: _calculate,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                    child: const SectionHeading(
                      eyebrow: 'ANNEXE 5 — CHAPITRE 2',
                      title: 'Matrice de classification RPAS',
                      subtitle:
                          'Classe 1 : ≤ 5 kg • Classe 2 : > 5 à 25 kg • Classe 3 : > 25 kg.',
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                    child: const _ClassificationMatrix(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: const SectionHeading(
                      eyebrow: 'AUTORISATIONS',
                      title: 'Préparer le bon dossier',
                      subtitle:
                          'Ouvre chaque section pour voir les obligations et les pièces à réunir.',
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                    child: const _AuthorizationSections(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: const SectionHeading(
                      eyebrow: 'RÈGLES DE L’AIR & LIMITES',
                      title: 'Contrôles avant chaque vol',
                      subtitle:
                          'Ces repères sont aussi utilisés par le simulateur DroneAtlas.',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: anacimRuleSummaries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _RuleCard(rule: anacimRuleSummaries[index]),
                ),
              ),
              SliverToBoxAdapter(
                child: MaxWidthBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                    child: _FooterActions(
                      onOfficial: _openOfficialText,
                      onQuiz: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuizHubScreen(),
                        ),
                      ),
                    ),
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

class _Hero extends StatelessWidget {
  const _Hero({required this.onOpenOfficial});

  final VoidCallback onOpenOfficial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF661230), Color(0xFF2A102D), Color(0xFF071C25)],
        ),
        border: Border.all(color: orange.withOpacity(.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientIcon(icon: Icons.gavel_rounded, size: 56, color: orange),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Annexe 5 au RAS 06',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Systèmes d’aéronefs télépilotés au Sénégal',
                      style: TextStyle(
                        color: orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'DroneAtlas transforme le règlement en fiches, checklists, quiz et alertes de simulation. Ce contenu facilite la préparation, mais ne remplace pas une décision, une autorisation ou une mise à jour officielle de l’ANACIM.',
            style: TextStyle(color: Colors.white70, height: 1.48),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onOpenOfficial,
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('Lire toute la réglementation officielle'),
          ),
        ],
      ),
    );
  }
}

class _Classifier extends StatelessWidget {
  const _Classifier({
    required this.massController,
    required this.use,
    required this.result,
    required this.onUseChanged,
    required this.onCalculate,
  });

  final TextEditingController massController;
  final RpasUseType use;
  final RpasClassificationResult result;
  final ValueChanged<RpasUseType> onUseChanged;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    final color = result.allowed
        ? (result.code == '3C' ? orange : success)
        : danger;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: massController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Masse totale au décollage (kg)',
                prefixIcon: Icon(Icons.scale_rounded),
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RpasUseType>(
              value: use,
              decoration: const InputDecoration(
                labelText: 'Usage réel de l’opération',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: RpasUseType.values
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) onUseChanged(value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCalculate,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Déterminer le régime indicatif'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: color.withOpacity(.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(.28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(.18),
                        child: Text(
                          result.code,
                          style: TextStyle(color: color, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Classe ${result.classNumber} • Catégorie ${result.category.categoryLetter}',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              result.document,
                              style: TextStyle(color: color, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(result.summary, style: const TextStyle(height: 1.45)),
                  const SizedBox(height: 9),
                  const Text(
                    'Résultat pédagogique à confirmer selon la masse réelle avec charge, les caractéristiques du RPAS, la zone, le scénario et les décisions de l’ANACIM.',
                    style: TextStyle(fontSize: 11, height: 1.4),
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

class _ClassificationMatrix extends StatelessWidget {
  const _ClassificationMatrix();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const _MatrixHeader(),
            const SizedBox(height: 8),
            ...List.generate(3, (classIndex) {
              final classNumber = classIndex + 1;
              final mass = switch (classNumber) {
                1 => '≤ 5 kg',
                2 => '> 5 à 25 kg',
                _ => '> 25 kg',
              };
              final cells = rpasClassificationMatrix
                  .where((cell) => cell.code.startsWith('$classNumber'))
                  .toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 12,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Classe $classNumber',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            Text(mass, style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...cells.map((cell) => Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: _MatrixCell(cell: cell),
                          ),
                        )),
                  ],
                ),
              );
            }),
            const SizedBox(height: 6),
            Text(
              'A = loisir/privé • B = aéromodélisme/sport • C = professionnel. Les RPAS professionnels de plus de 25 kg relèvent en principe de 3C/PER, sous réserve des précisions de l’Annexe.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatrixHeader extends StatelessWidget {
  const _MatrixHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 12, child: SizedBox()),
        SizedBox(width: 6),
        Expanded(flex: 10, child: _HeaderCell(label: 'A\nLoisir')),
        SizedBox(width: 5),
        Expanded(flex: 10, child: _HeaderCell(label: 'B\nSport')),
        SizedBox(width: 5),
        Expanded(flex: 10, child: _HeaderCell(label: 'C\nPro')),
        SizedBox(width: 5),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
    );
  }
}

class _MatrixCell extends StatelessWidget {
  const _MatrixCell({required this.cell});

  final RpasMatrixCell cell;

  @override
  Widget build(BuildContext context) {
    final color = cell.allowed ? success : danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
      decoration: BoxDecoration(
        color: color.withOpacity(.11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            cell.code,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Icon(
            cell.allowed ? Icons.check_circle_rounded : Icons.block_rounded,
            size: 15,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _AuthorizationSections extends StatelessWidget {
  const _AuthorizationSections();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ChecklistExpansion(
          title: 'Loisir / privé — catégorie A',
          subtitle: 'Autorisation, identification, zone et assurance',
          icon: Icons.sports_esports_rounded,
          color: cyan,
          items: leisureAuthorizationChecklist,
        ),
        SizedBox(height: 10),
        _ChecklistExpansion(
          title: 'Professionnel / commercial — catégorie C',
          subtitle: 'Dossier d’autorisation détaillé',
          icon: Icons.business_center_rounded,
          color: orange,
          items: professionalAuthorizationChecklist,
        ),
        SizedBox(height: 10),
        _ChecklistExpansion(
          title: 'PER — opérations 3C',
          subtitle: 'Exigences supplémentaires pour les RPAS > 25 kg',
          icon: Icons.verified_user_rounded,
          color: violet,
          items: perAdditionalChecklist,
        ),
        SizedBox(height: 10),
        _ChecklistExpansion(
          title: 'Identification & licence',
          subtitle: 'SN.UAS, certificat et compétence du télépilote',
          icon: Icons.badge_rounded,
          color: success,
          items: identificationAndLicenceChecklist,
        ),
      ],
    );
  }
}

class _ChecklistExpansion extends StatelessWidget {
  const _ChecklistExpansion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
          ...List.generate(
            items.length,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.13),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(items[index], style: const TextStyle(height: 1.42))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule});

  final AnacimRuleSummary rule;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cyan.withOpacity(.13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(rule.icon, color: cyan),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          rule.title,
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          rule.value,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rule.detail,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.42,
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

class _FooterActions extends StatelessWidget {
  const _FooterActions({required this.onOfficial, required this.onQuiz});

  final VoidCallback onOfficial;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [orange.withOpacity(.15), violet.withOpacity(.10)],
        ),
        border: Border.all(color: orange.withOpacity(.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Passe de la lecture à la maîtrise',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            'Lis le document officiel, puis teste tes connaissances sur les classes, catégories, autorisations et limites d’exploitation.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOfficial,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Ouvrir l’Annexe 5 officielle'),
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onQuiz,
              icon: const Icon(Icons.quiz_rounded),
              label: const Text('Faire les quiz ANACIM'),
            ),
          ),
        ],
      ),
    );
  }
}
