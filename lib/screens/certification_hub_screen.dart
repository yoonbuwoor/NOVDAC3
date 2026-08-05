import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/community_card.dart';

/// Écran public temporaire utilisé pour la première publication Play Store.
///
/// Les services de connexion, les examens et l'émission des certificats restent
/// volontairement inaccessibles jusqu'à leur activation dans une mise à jour.
class CertificationHubScreen extends StatelessWidget {
  const CertificationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcours certifiants'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7E173A), Color(0xFFFF6B38)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E173A).withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ComingSoonBadge(),
                  SizedBox(height: 20),
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Les parcours certifiants arrivent bientôt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Restez connectés pour découvrir les prochaines mises à jour de Drone Atlas Academy.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF151F35) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: dark ? Colors.white12 : const Color(0xFFE3E8F1),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Préparez-vous dès maintenant',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explorez d’abord les cours, les quiz et les autres fonctionnalités de l’application. Les connaissances et compétences acquises vous seront utiles pour réussir les différentes certifications.',
                    style: TextStyle(
                      height: 1.55,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _PreparationTile(
              icon: Icons.menu_book_rounded,
              title: 'Suivez les cours',
              text: 'Consolidez les bases du drone, de la photogrammétrie, de la géomatique et des opérations terrain.',
            ),
            const SizedBox(height: 12),
            const _PreparationTile(
              icon: Icons.quiz_rounded,
              title: 'Entraînez-vous avec les quiz',
              text: 'Testez régulièrement vos connaissances et identifiez les notions à revoir avant les futures épreuves.',
            ),
            const SizedBox(height: 12),
            const _PreparationTile(
              icon: Icons.explore_rounded,
              title: 'Explorez toutes les fonctionnalités',
              text: 'Utilisez les outils, simulations, ressources et conseils proposés dans l’application pour progresser.',
            ),
            const SizedBox(height: 20),
            const CommunityCard(compact: true),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.school_rounded),
              label: const Text('Continuer mon apprentissage'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Aucun compte ni paiement n’est nécessaire pour profiter des contenus actuellement disponibles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.34)),
      ),
      child: const Text(
        'BIENTÔT DISPONIBLE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _PreparationTile extends StatelessWidget {
  const _PreparationTile({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF151F35) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? Colors.white12 : const Color(0xFFE3E8F1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: orange.withOpacity(dark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(height: 1.45, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
