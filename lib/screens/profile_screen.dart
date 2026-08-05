import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../data/academy_data.dart';
import '../widgets/common.dart';
import 'glossary_screen.dart';
import 'quiz_screen.dart';
import 'report_screen.dart';
import 'update_center_screen.dart';
import 'certification_hub_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final totalCourses = totalLessonCount + controller.remoteCourses.length;
    final progress = controller.courseProgress(totalCourses);
    final level = 1 + controller.xp ~/ 500;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: BrandBar(
              isDark: isDark,
              onToggleTheme: onToggleTheme,
              title: 'Profil apprenant',
              subtitle: 'Progression, badges et outils personnels',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: _ProfileHeader(controller: controller, level: level, progress: progress, totalCourses: totalCourses),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: const SectionHeading(title: 'Tes badges', subtitle: 'Ils se débloquent selon ta progression dans l’académie et les missions.'),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: SizedBox(
              height: 180,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _badges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 11),
                itemBuilder: (context, index) {
                  final badge = _badges[index];
                  final unlocked = badge.condition(controller);
                  return _BadgeCard(badge: badge, unlocked: unlocked);
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CertificationHubScreen(),
                  ),
                ),
                child: Ink(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7E173A), Color(0xFFFF6B38)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 38),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Parcours certifiants',
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Color(0x33FFFFFF),
                                    borderRadius: BorderRadius.all(Radius.circular(999)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                    child: Text(
                                      'BIENTÔT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Bientôt disponibles. Explore d’abord les cours, les quiz et les autres fonctionnalités pour te préparer.',
                              style: TextStyle(color: Colors.white, height: 1.35, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: const SectionHeading(
                eyebrow: 'NOVATEUR221',
                title: 'Contactez-nous',
                subtitle: 'Échange sur DroneAtlas, une formation, un partenariat ou un projet drone.',
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 650;
                  final cards = <Widget>[
                    _ContactCard(
                      icon: Icons.chat_rounded,
                      color: success,
                      title: 'WhatsApp Novateur221',
                      subtitle: '+221 78 278 03 02',
                      onTap: () => _openExternalLink(
                        context,
                        'https://wa.me/221782780302?text=Bonjour%20Novateur221%2C%20je%20vous%20contacte%20depuis%20DroneAtlas.',
                      ),
                    ),
                    _ContactCard(
                      icon: Icons.business_center_rounded,
                      color: electricBlue,
                      title: 'LinkedIn Novateur221',
                      subtitle: 'Voir le profil professionnel',
                      onTap: () => _openExternalLink(
                        context,
                        'https://www.linkedin.com/in/novateur-4b3820286/',
                      ),
                    ),
                  ];
                  if (wide) {
                    return Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 12),
                        Expanded(child: cards[1]),
                      ],
                    );
                  }
                  return Column(
                    children: [cards[0], const SizedBox(height: 12), cards[1]],
                  );
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: const SectionHeading(title: 'Boîte à outils'),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000
                      ? 4
                      : constraints.maxWidth >= 650
                          ? 2
                          : 1;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: columns == 1 ? 3.1 : 1.42,
                    children: [
                      _ToolCard(icon: Icons.quiz_rounded, color: orange, title: 'Quiz général', subtitle: 'Teste les notions essentielles.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()))),
                      _ToolCard(icon: Icons.menu_book_rounded, color: cyan, title: 'Glossaire', subtitle: 'Retrouve rapidement les termes.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlossaryScreen()))),
                      _ToolCard(icon: Icons.description_rounded, color: violet, title: 'Atelier de rapport', subtitle: 'Construis une restitution complète.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()))),
                      _ToolCard(icon: controller.updateAvailable ? Icons.new_releases_rounded : Icons.system_update_alt_rounded, color: controller.updateAvailable ? orange : success, title: controller.updateAvailable ? 'Nouveaux cours' : 'Mises à jour', subtitle: controller.updateAvailable ? 'Une mise à jour pédagogique est prête.' : 'Application à jour.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateCenterScreen()))),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller, required this.level, required this.progress, required this.totalCourses});

  final AppController controller;
  final int level;
  final double progress;
  final int totalCourses;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF183D49), Color(0xFF081722)]),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 650;
          final identity = Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(radius: 42, backgroundColor: cyan.withOpacity(.16), child: const Icon(Icons.flight_takeoff_rounded, color: cyan, size: 42)),
                  Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 14, backgroundColor: orange, foregroundColor: navy, child: Text('$level', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)))),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.learnerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Modifier le profil',
                          onPressed: () => _showProfileDialog(context, controller),
                          icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 19),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.learnerProfession.isEmpty
                          ? 'Apprenant DroneAtlas'
                          : controller.learnerProfession,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: cyan, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      controller.learnerEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          controller.registrationSynced
                              ? Icons.cloud_done_rounded
                              : Icons.cloud_upload_outlined,
                          color: controller.registrationSynced ? success : orange,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            controller.registrationSynced
                                ? 'Formulaire transmis une seule fois'
                                : 'Formulaire en attente de connexion',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: controller.registrationSynced ? success : orange,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!controller.registrationSynced) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: controller.registrationSubmitting
                              ? null
                              : () async {
                                  final sent = await controller.sendPendingLearnerProfile();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        sent
                                            ? 'Informations envoyées à Novateur221.'
                                            : controller.registrationError ?? 'L’envoi a échoué.',
                                      ),
                                    ),
                                  );
                                },
                          icon: controller.registrationSubmitting
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send_rounded, size: 17),
                          label: Text(
                            controller.registrationSubmitting
                                ? 'Envoi…'
                                : 'Envoyer les informations',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Text('${controller.xp} XP • Niveau $level • Domaine : ${controller.selectedDomain}', maxLines: 2, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
            ],
          );
          final progressCard = Container(
            width: wide ? 250 : double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)),
            child: Row(
              children: [
                ProgressRing(value: progress, label: '${(progress * 100).round()} %', size: 68),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Parcours global', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('${controller.completedLessons.length}/$totalCourses leçons', style: const TextStyle(color: Colors.white60, fontSize: 12)), const SizedBox(height: 4), Text('${controller.completedMissions.length} mission(s)', style: const TextStyle(color: orange, fontSize: 12, fontWeight: FontWeight.w800))])),
              ],
            ),
          );
          if (wide) return Row(children: [Expanded(child: identity), const SizedBox(width: 18), progressCard]);
          return Column(children: [identity, const SizedBox(height: 18), progressCard]);
        },
      ),
    );
  }
}

class _BadgeData {
  const _BadgeData(this.title, this.subtitle, this.icon, this.color, this.condition);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool Function(AppController) condition;
}

final _badges = <_BadgeData>[
  _BadgeData('Premier décollage', 'Valider une leçon', Icons.flight_takeoff_rounded, cyan, (c) => c.completedLessons.isNotEmpty),
  _BadgeData('Planificateur', 'Valider 4 leçons', Icons.route_rounded, orange, (c) => c.completedLessons.length >= 4),
  _BadgeData('Photogrammètre', 'Valider 10 leçons', Icons.view_in_ar_rounded, violet, (c) => c.completedLessons.length >= 10),
  _BadgeData('Chef de mission', 'Réussir une mission', Icons.flag_rounded, success, (c) => c.completedMissions.isNotEmpty),
  _BadgeData('Expert DroneAtlas', 'Terminer tout le parcours', Icons.emoji_events_rounded, danger, (c) => c.completedLessons.length >= totalLessonCount),
];

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.unlocked});

  final _BadgeData badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  GradientIcon(icon: unlocked ? badge.icon : Icons.lock_rounded, color: unlocked ? badge.color : Colors.grey, size: 54),
                  if (unlocked) Positioned(right: 0, top: 0, child: Container(width: 18, height: 18, decoration: const BoxDecoration(color: success, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: navy, size: 13))),
                ],
              ),
              const Spacer(),
              Text(badge.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: unlocked ? null : Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(badge.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              GradientIcon(icon: icon, color: color, size: 52),
              const SizedBox(width: 13),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}



class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              GradientIcon(icon: icon, color: color, size: 50),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openExternalLink(BuildContext context, String rawUrl) async {
  final uri = Uri.parse(rawUrl);
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d’ouvrir ce lien sur le téléphone.')),
    );
  }
}

Future<void> _showProfileDialog(
  BuildContext context,
  AppController controller,
) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: controller.learnerName);
  final professionController =
      TextEditingController(text: controller.learnerProfession);
  final emailController = TextEditingController(text: controller.learnerEmail);
  var saving = false;

  await showDialog<void>(
    context: context,
    barrierDismissible: !saving,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Modifier mon profil'),
        content: SizedBox(
          width: 430,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.registrationSynced) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: success.withOpacity(.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Le formulaire a déjà été transmis. Ces modifications seront enregistrées uniquement sur cet appareil et ne déclencheront pas un nouvel envoi.',
                        style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: nameController,
                    enabled: !saving,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: (value) => (value ?? '').trim().length < 2
                        ? 'Renseigne ton nom.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: professionController,
                    enabled: !saving,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Profession ou domaine',
                      prefixIcon: Icon(Icons.work_rounded),
                    ),
                    validator: (value) => (value ?? '').trim().length < 2
                        ? 'Renseigne ta profession.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    enabled: !saving,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Adresse e-mail',
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                    validator: (value) {
                      final email = (value ?? '').trim();
                      return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                              .hasMatch(email)
                          ? null
                          : 'Adresse e-mail invalide.';
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            onPressed: saving
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    final success = await controller.updateLearnerProfile(
                      name: nameController.text,
                      profession: professionController.text,
                      email: emailController.text,
                    );
                    if (!dialogContext.mounted) return;
                    if (success) {
                      Navigator.pop(dialogContext);
                    } else {
                      setDialogState(() => saving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            controller.registrationError ??
                                'La modification a échoué.',
                          ),
                        ),
                      );
                    }
                  },
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(saving ? 'Enregistrement…' : 'Enregistrer'),
          ),
        ],
      ),
    ),
  );

  nameController.dispose();
  professionController.dispose();
  emailController.dispose();
}
