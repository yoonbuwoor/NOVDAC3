import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/community_config.dart';
import '../core/theme.dart';

Future<bool> openDroneAtlasCommunity(BuildContext context) async {
  final opened = await launchUrl(
    Uri.parse(CommunityConfig.whatsappGroupUrl),
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Impossible d’ouvrir WhatsApp. Vérifiez votre connexion puis réessayez.',
        ),
      ),
    );
  }
  return opened;
}


Future<bool> showDroneAtlasCommunityInvitation(BuildContext context) async {
  final join = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.celebration_rounded, color: success, size: 42),
      title: const Text('Première étape validée !'),
      content: const Text(
        'Votre progression dans Drone Atlas Academy a commencé. Rejoignez la communauté officielle pour recevoir les annonces sur les prochains cours, quiz et parcours certifiants.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Plus tard'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(dialogContext, true),
          icon: const Icon(Icons.groups_rounded),
          label: const Text('Rejoindre'),
        ),
      ],
    ),
  );
  if (join == true && context.mounted) {
    await openDroneAtlasCommunity(context);
  }
  return join == true;
}

class CommunityCard extends StatelessWidget {
  const CommunityCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(compact ? 17 : 21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF123C32), Color(0xFF0B2222)]
              : const [Color(0xFFE8FFF5), Color(0xFFF5FFFB)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: success.withOpacity(dark ? .30 : .22)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 620;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: success.withOpacity(.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.groups_rounded, color: success),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COMMUNAUTÉ OFFICIELLE',
                          style: TextStyle(
                            color: success,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          CommunityConfig.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                CommunityConfig.description,
                style: TextStyle(fontSize: 13, height: 1.48),
              ),
              const SizedBox(height: 8),
              Text(
                'L’adhésion est facultative. WhatsApp s’ouvrira uniquement après votre action.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          );
          final button = FilledButton.icon(
            onPressed: () => openDroneAtlasCommunity(context),
            icon: const Icon(Icons.chat_rounded),
            label: const Text('Rejoindre le groupe'),
            style: FilledButton.styleFrom(
              backgroundColor: success,
              foregroundColor: const Color(0xFF061A14),
              minimumSize: Size(wide ? 190 : double.infinity, 50),
            ),
          );
          if (wide) {
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 22),
                button,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [content, const SizedBox(height: 16), button],
          );
        },
      ),
    );
  }
}
