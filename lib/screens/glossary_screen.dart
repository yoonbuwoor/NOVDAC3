import 'package:flutter/material.dart';

import '../data/academy_data.dart';
import '../widgets/common.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final entries = glossary.where((entry) {
      final q = _query.toLowerCase();
      return entry.term.toLowerCase().contains(q) || entry.definition.toLowerCase().contains(q) || entry.category.toLowerCase().contains(q);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Glossaire DroneAtlas')),
      body: MaxWidthBox(
        maxWidth: 850,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(hintText: 'Rechercher GSD, GCP, orthophoto…', prefixIcon: Icon(Icons.search_rounded)),
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? const EmptyState(icon: Icons.search_off_rounded, title: 'Aucun terme trouvé', message: 'Essaie une autre notion ou une catégorie plus large.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(child: Text(entry.term.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w900))),
                            title: Text(entry.term, style: const TextStyle(fontWeight: FontWeight.w900)),
                            subtitle: Text(entry.category, style: const TextStyle(fontSize: 11)),
                            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                            children: [Align(alignment: Alignment.centerLeft, child: Text(entry.definition, style: const TextStyle(height: 1.5)))],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
