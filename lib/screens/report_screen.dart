import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/academy_models.dart';
import '../widgets/common.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, this.mission});

  final TrainingMission? mission;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final TextEditingController _title;
  late final TextEditingController _zone;
  late final TextEditingController _context;
  late final TextEditingController _objective;
  late final TextEditingController _method;
  late final TextEditingController _results;
  late final TextEditingController _limits;
  late final TextEditingController _recommendations;
  int _section = 0;

  @override
  void initState() {
    super.initState();
    final mission = widget.mission;
    _title = TextEditingController(text: mission == null ? 'Rapport de mission photogrammétrique' : mission.title);
    _zone = TextEditingController(text: mission == null ? 'Zone d’étude simulée' : 'Zone d’étude de la mission virtuelle');
    _context = TextEditingController(text: mission?.brief ?? 'Présente ici la demande, les acteurs concernés et le contexte de la mission.');
    _objective = TextEditingController(text: mission == null ? 'Définir le produit attendu, l’usage et la précision nécessaire.' : 'Produire : ${mission.deliverable}');
    _method = TextEditingController(text: 'Décrire la préparation, le plan de vol, les paramètres, les contrôles terrain et les étapes du traitement simulé.');
    _results = TextEditingController(text: mission == null ? 'Présenter les produits obtenus, les mesures et les principales observations.' : 'Le livrable simulé comprend : ${mission.deliverable}');
    _limits = TextEditingController(text: 'Préciser les zones moins fiables, les erreurs observées et les usages déconseillés.');
    _recommendations = TextEditingController(text: 'Formuler des actions réalistes, hiérarchisées et directement liées aux résultats.');
  }

  @override
  void dispose() {
    for (final controller in [_title, _zone, _context, _objective, _method, _results, _limits, _recommendations]) {
      controller.dispose();
    }
    super.dispose();
  }

  List<_ReportSection> get _sections => [
        _ReportSection('Identification', Icons.badge_rounded, [
          _ReportField('Titre de la mission', _title, 'Ex. Cartographie photogrammétrique de…'),
          _ReportField('Zone d’étude', _zone, 'Localisation et emprise'),
        ]),
        _ReportSection('Contexte et objectifs', Icons.flag_rounded, [
          _ReportField('Contexte', _context, 'Pourquoi cette mission est-elle réalisée ?', lines: 6),
          _ReportField('Objectifs', _objective, 'Quels produits et décisions sont attendus ?', lines: 5),
        ]),
        _ReportSection('Méthodologie', Icons.route_rounded, [
          _ReportField('Protocole', _method, 'Matériel, planification, acquisition, contrôle et traitement', lines: 8),
        ]),
        _ReportSection('Résultats', Icons.layers_rounded, [
          _ReportField('Résultats et livrables', _results, 'Produits, mesures et observations', lines: 8),
        ]),
        _ReportSection('Qualité et limites', Icons.verified_rounded, [
          _ReportField('Contrôle qualité', _limits, 'Erreurs, incertitudes et limites d’usage', lines: 7),
        ]),
        _ReportSection('Recommandations', Icons.lightbulb_rounded, [
          _ReportField('Conclusion et suite', _recommendations, 'Actions prioritaires et prochaines acquisitions', lines: 7),
        ]),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atelier de rapport'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Pill(label: '${_section + 1}/${_sections.length}', icon: Icons.edit_document, color: violet),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 950;
          if (wide) {
            return Row(
              children: [
                SizedBox(width: 270, child: _ReportSidebar(sections: _sections, selected: _section, onSelect: (value) => setState(() => _section = value))),
                Expanded(child: _Editor(section: _sections[_section], index: _section, total: _sections.length, onBack: _section == 0 ? null : () => setState(() => _section--), onNext: _section == _sections.length - 1 ? null : () => setState(() => _section++), onPreview: () => _showPreview(context))),
              ],
            );
          }
          return Column(
            children: [
              SizedBox(
                height: 55,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  scrollDirection: Axis.horizontal,
                  itemCount: _sections.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 7),
                  itemBuilder: (context, index) => ChoiceChip(selected: _section == index, label: Text('${index + 1}. ${_sections[index].title}'), onSelected: (_) => setState(() => _section = index)),
                ),
              ),
              Expanded(child: _Editor(section: _sections[_section], index: _section, total: _sections.length, onBack: _section == 0 ? null : () => setState(() => _section--), onNext: _section == _sections.length - 1 ? null : () => setState(() => _section++), onPreview: () => _showPreview(context))),
            ],
          );
        },
      ),
    );
  }

  void _showPreview(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: .94,
        child: _ReportPreview(
          title: _title.text,
          zone: _zone.text,
          contextText: _context.text,
          objective: _objective.text,
          method: _method.text,
          results: _results.text,
          limits: _limits.text,
          recommendations: _recommendations.text,
        ),
      ),
    );
  }
}

class _ReportSection {
  const _ReportSection(this.title, this.icon, this.fields);

  final String title;
  final IconData icon;
  final List<_ReportField> fields;
}

class _ReportField {
  const _ReportField(this.label, this.controller, this.hint, {this.lines = 2});

  final String label;
  final TextEditingController controller;
  final String hint;
  final int lines;
}

class _ReportSidebar extends StatelessWidget {
  const _ReportSidebar({required this.sections, required this.selected, required this.onSelect});

  final List<_ReportSection> sections;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, border: Border(right: BorderSide(color: Theme.of(context).dividerColor))),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Text('STRUCTURE DU RAPPORT', style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8)),
          ),
          ...List.generate(sections.length, (index) {
            final active = selected == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => onSelect(index),
                selected: active,
                selectedTileColor: violet.withOpacity(.12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: CircleAvatar(backgroundColor: (active ? violet : cyan).withOpacity(.14), foregroundColor: active ? violet : cyan, child: Icon(sections[index].icon, size: 19)),
                title: Text(sections[index].title, style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w700, fontSize: 13)),
                trailing: Text('${index + 1}', style: TextStyle(color: active ? violet : null, fontWeight: FontWeight.w900)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.section, required this.index, required this.total, required this.onBack, required this.onNext, required this.onPreview});

  final _ReportSection section;
  final int index;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            child: MaxWidthBox(
              maxWidth: 850,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [GradientIcon(icon: section.icon, color: violet, size: 54), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(section.title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('Section ${index + 1} sur $total', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))]))]),
                      const SizedBox(height: 24),
                      ...section.fields.map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(field.label, style: const TextStyle(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              TextField(controller: field.controller, minLines: field.lines, maxLines: field.lines + 5, decoration: InputDecoration(hintText: field.hint, alignLabelWithHint: true)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: orange.withOpacity(.09), borderRadius: BorderRadius.circular(18)),
                        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.auto_awesome_rounded, color: orange), SizedBox(width: 11), Expanded(child: Text('Astuce DroneAtlas : distingue toujours ce qui a été observé, ce qui a été mesuré et ce qui a été interprété.', style: TextStyle(height: 1.45, fontWeight: FontWeight.w700)))]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
          child: MaxWidthBox(
            maxWidth: 850,
            child: Row(
              children: [
                OutlinedButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded), label: const Text('Précédent')),
                const Spacer(),
                if (onNext != null) FilledButton.icon(onPressed: onNext, icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Continuer')),
                if (onNext == null) FilledButton.icon(onPressed: onPreview, icon: const Icon(Icons.preview_rounded), label: const Text('Prévisualiser')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportPreview extends StatelessWidget {
  const _ReportPreview({required this.title, required this.zone, required this.contextText, required this.objective, required this.method, required this.results, required this.limits, required this.recommendations});

  final String title;
  final String zone;
  final String contextText;
  final String objective;
  final String method;
  final String results;
  final String limits;
  final String recommendations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu du rapport'),
        actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 760),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 30)]),
            child: DefaultTextStyle(
              style: const TextStyle(color: Color(0xFF17242C), height: 1.55, fontSize: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Container(width: 54, height: 54, padding: const EdgeInsets.all(7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE0E8EB))), child: Image.asset('assets/images/logo.webp')), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DRONEATLAS', style: TextStyle(color: navy, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 1.5)), Text('RAPPORT PÉDAGOGIQUE DE MISSION', style: TextStyle(color: Color(0xFF5B6B74), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8))]))]),
                  const SizedBox(height: 38),
                  Text(title.isEmpty ? 'Rapport de mission' : title, style: const TextStyle(color: navy, fontSize: 32, height: 1.08, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text(zone, style: const TextStyle(color: Color(0xFF667780), fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  const Text('Simulation DroneAtlas • Aucun traitement d’images réelles', style: TextStyle(color: Color(0xFF00AFA8), fontSize: 11, fontWeight: FontWeight.w900)),
                  const Divider(height: 48),
                  _PreviewSection(number: '01', title: 'Contexte', text: contextText),
                  _PreviewSection(number: '02', title: 'Objectifs', text: objective),
                  _PreviewSection(number: '03', title: 'Méthodologie', text: method),
                  _PreviewSection(number: '04', title: 'Résultats', text: results),
                  _PreviewSection(number: '05', title: 'Qualité et limites', text: limits),
                  _PreviewSection(number: '06', title: 'Conclusion et recommandations', text: recommendations),
                  const Divider(height: 42),
                  const Text('© 2026 Novateur221 • Document produit dans l’atelier pédagogique DroneAtlas', style: TextStyle(color: Color(0xFF78878E), fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.number, required this.title, required this.text});

  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text(number, style: const TextStyle(color: Color(0xFF00AFA8), fontWeight: FontWeight.w900)), const SizedBox(width: 10), Text(title.toUpperCase(), style: const TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: .4))]),
          const SizedBox(height: 10),
          Text(text.isEmpty ? 'Section à compléter.' : text),
        ],
      ),
    );
  }
}
