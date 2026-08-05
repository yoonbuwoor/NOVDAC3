import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../models/remote_content_models.dart';
import '../widgets/common.dart';
import 'remote_course_detail_screen.dart';

class UpdateCenterScreen extends StatelessWidget {
  const UpdateCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mises à jour & notifications')),
      body: SafeArea(
        child: MaxWidthBox(
          maxWidth: 960,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              _UpdateHero(controller: controller),
              const SizedBox(height: 26),
              const SectionHeading(
                title: 'Catalogue pédagogique',
                subtitle:
                    'Les nouveautés sont vérifiées en ligne puis conservées sur le téléphone pour rester accessibles hors connexion.',
              ),
              const SizedBox(height: 12),
              _CatalogCard(controller: controller),
              const SizedBox(height: 28),
              const SectionHeading(
                title: 'Notifications',
                subtitle:
                    'Choisis si DroneAtlas peut t’annoncer un nouveau cours ou te rappeler de poursuivre ta formation.',
              ),
              const SizedBox(height: 12),
              _NotificationCard(controller: controller),
              const SizedBox(height: 28),
              const SectionHeading(
                title: 'Cours téléchargés',
                subtitle: 'Ils restent disponibles hors connexion.',
              ),
              const SizedBox(height: 12),
              if (controller.remoteCourses.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.verified_rounded,
                      title: 'Application à jour',
                      message:
                          'Tous les contenus actuellement disponibles sont installés.',
                    ),
                  ),
                )
              else
                ...controller.remoteCourses.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const GradientIcon(
                          icon: Icons.auto_stories_rounded,
                          color: violet,
                        ),
                        title: Text(
                          course.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '${course.category} • ${course.duration}',
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RemoteCourseDetailScreen(course: course),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (controller.remoteCourses.isNotEmpty) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _confirmClear(context, controller),
                  icon: const Icon(Icons.delete_sweep_rounded),
                  label: const Text('Supprimer les contenus téléchargés'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    AppController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer les cours téléchargés ?'),
        content: const Text(
          'Les cours intégrés à l’application resteront disponibles. Les nouveautés pourront être téléchargées de nouveau plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.clearDownloadedContent();
  }
}

class _UpdateHero extends StatelessWidget {
  const _UpdateHero({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.updateState;
    final available = controller.updateAvailable;
    final busy =
        state == UpdateState.checking || state == UpdateState.downloading;
    final accent = available
        ? orange
        : state == UpdateState.error
            ? danger
            : success;
    final title = switch (state) {
      UpdateState.checking => 'Recherche des nouveautés…',
      UpdateState.downloading => 'Installation en cours…',
      UpdateState.available => 'Nouveau contenu disponible',
      UpdateState.error => 'Vérification impossible',
      UpdateState.current => 'Application à jour',
      UpdateState.idle => 'Application à jour',
    };
    final message = switch (state) {
      UpdateState.checking => 'Vérification du catalogue pédagogique.',
      UpdateState.downloading =>
        'Les nouveaux cours sont en cours d’installation.',
      UpdateState.available =>
        controller.availableManifest?.description ??
            'Une mise à jour pédagogique est disponible.',
      UpdateState.error =>
        controller.updateError ??
            'La vérification n’a pas abouti. Réessaie avec une connexion Internet.',
      UpdateState.current => 'Tous les cours disponibles sont installés.',
      UpdateState.idle => 'Tous les cours disponibles sont installés.',
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(.24), cyan.withOpacity(.06)],
        ),
        border: Border.all(color: accent.withOpacity(.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIcon(
                icon: available
                    ? Icons.new_releases_rounded
                    : Icons.verified_rounded,
                color: accent,
                size: 58,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (busy) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(minHeight: 8),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed:
                    busy ? null : () => controller.checkForContentUpdates(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Vérifier maintenant'),
              ),
              if (available)
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                          final success =
                              await controller.installAvailableContent();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Les nouveaux cours sont installés.'
                                    : controller.updateError ??
                                        'Le téléchargement a échoué.',
                              ),
                            ),
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: navy,
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Installer la mise à jour'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final manifest = controller.availableManifest;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ValueRow(
              label: 'État du catalogue',
              value: controller.updateAvailable
                  ? 'Nouveaux contenus disponibles'
                  : 'Application à jour',
            ),
            const Divider(height: 24),
            _ValueRow(
              label: 'Dernière vérification',
              value: _formatDate(controller.lastContentCheck),
            ),
            if (manifest != null &&
                controller.updateAvailable &&
                manifest.changelog.isNotEmpty) ...[
              const Divider(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  manifest.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 10),
              ...manifest.changelog.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.add_circle_rounded,
                        color: cyan,
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Automatique au démarrage';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} à $hour:$minute';
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SwitchListTile(
              value: controller.notificationsEnabled,
              secondary: const GradientIcon(
                icon: Icons.notifications_active_rounded,
                color: orange,
              ),
              title: const Text(
                'Autoriser les notifications',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Nouveaux cours et rappels d’apprentissage.',
              ),
              onChanged: (value) async {
                final accepted =
                    await controller.setNotificationsEnabled(value);
                if (!context.mounted || accepted || !value) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'L’autorisation de notification a été refusée par le téléphone.',
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              enabled: controller.notificationsEnabled,
              leading: const GradientIcon(
                icon: Icons.schedule_rounded,
                color: violet,
              ),
              title: const Text(
                'Fréquence des rappels',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Android choisit l’heure la plus adaptée.',
              ),
              trailing: DropdownButton<String>(
                value: controller.reminderFrequency,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'off', child: Text('Désactivés')),
                  DropdownMenuItem(value: 'daily', child: Text('Chaque jour')),
                  DropdownMenuItem(
                    value: 'three_per_week',
                    child: Text('3 fois/semaine'),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text('Chaque semaine'),
                  ),
                ],
                onChanged: controller.notificationsEnabled
                    ? (value) {
                        if (value != null) {
                          controller.setReminderFrequency(value);
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
