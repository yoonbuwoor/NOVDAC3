import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../widgets/common.dart';

class FlightReadinessScreen extends StatefulWidget {
  const FlightReadinessScreen({super.key});

  @override
  State<FlightReadinessScreen> createState() => _FlightReadinessScreenState();
}

class _FlightReadinessScreenState extends State<FlightReadinessScreen> {
  final WeatherService _weatherService = WeatherService();
  final List<bool> _checked = List<bool>.filled(_checks.length, false);

  FlightWeatherSnapshot? _snapshot;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await _weatherService.fetchLocalFlightWeather();
      if (!mounted) return;
      setState(() => _snapshot = snapshot);
    } on WeatherServiceException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de récupérer la météo locale.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _checked.where((value) => value).length;
    final weatherAllows = _snapshot?.assessment.decision != FlightDecision.noGo;
    final ready = completed == _checks.length && _snapshot != null && weatherAllows;

    return Scaffold(
      appBar: AppBar(title: const Text('Field Kit — préparation du vol')),
      body: AmbientBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
          children: [
            MaxWidthBox(
              maxWidth: 900,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading(
                    eyebrow: 'MÉTÉO + TERRAIN + MACHINE',
                    title: 'Décision de vol assistée',
                    subtitle: 'La météo locale aide à décider, mais ne remplace ni le manuel du drone, ni un anémomètre sur site, ni les autorisations.',
                  ),
                  const SizedBox(height: 14),
                  _WeatherPanel(
                    snapshot: _snapshot,
                    loading: _loading,
                    error: _error,
                    onRefresh: _loadWeather,
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const GradientIcon(icon: Icons.fact_check_rounded, color: cyan),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Checklist opérationnelle', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                                    Text('$completed/${_checks.length} contrôles validés', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              CircularProgressIndicator(value: completed / _checks.length),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_checks.length, (index) {
                            final item = _checks[index];
                            return CheckboxListTile(
                              value: _checked[index],
                              onChanged: (value) => setState(() => _checked[index] = value ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                              subtitle: Text(item.$2),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FinalDecisionBanner(
                    ready: ready,
                    hasWeather: _snapshot != null,
                    weatherNoGo: _snapshot?.assessment.decision == FlightDecision.noGo,
                    completed: completed,
                    total: _checks.length,
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

class _WeatherPanel extends StatelessWidget {
  const _WeatherPanel({
    required this.snapshot,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  final FlightWeatherSnapshot? snapshot;
  final bool loading;
  final String? error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final data = snapshot;
    final decisionColor = switch (data?.assessment.decision) {
      FlightDecision.noGo => danger,
      FlightDecision.caution => orange,
      FlightDecision.favorable => success,
      null => cyan,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GradientIcon(icon: Icons.air_rounded, color: decisionColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data?.assessment.title ?? 'Météo locale du site', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                      Text(data?.assessment.summary ?? 'Autorise la localisation puis charge les conditions actuelles.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: loading ? null : onRefresh,
                  icon: loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location_rounded),
                  label: Text(data == null ? 'Analyser' : 'Actualiser'),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 14),
              Text(error!, style: const TextStyle(color: danger, fontWeight: FontWeight.w800)),
            ],
            if (data != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _WeatherChip(icon: Icons.thermostat_rounded, label: '${data.weather.temperatureC.toStringAsFixed(1)} °C'),
                  _WeatherChip(icon: Icons.air_rounded, label: '${data.weather.windSpeedKmh.round()} km/h ${data.weather.windDirectionLabel}'),
                  _WeatherChip(icon: Icons.waves_rounded, label: 'Rafales ${data.weather.windGustsKmh.round()} km/h'),
                  _WeatherChip(icon: Icons.visibility_rounded, label: '${(data.weather.visibilityMeters / 1000).toStringAsFixed(1)} km'),
                  _WeatherChip(icon: Icons.water_drop_rounded, label: '${data.weather.relativeHumidity.round()} % HR'),
                  _WeatherChip(icon: Icons.cloud_rounded, label: '${data.weather.cloudCover.round()} % nuages'),
                  _WeatherChip(icon: Icons.compress_rounded, label: '${data.weather.pressureHpa.round()} hPa'),
                ],
              ),
              const SizedBox(height: 14),
              ...data.assessment.reasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 7, color: decisionColor),
                      const SizedBox(width: 9),
                      Expanded(child: Text(reason)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coordonnées utilisées : ${data.weather.latitude.toStringAsFixed(4)}, ${data.weather.longitude.toStringAsFixed(4)} • ${data.weather.conditionLabel}',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  ),
                  onPressed: () => launchUrl(
                    Uri.parse('https://open-meteo.com/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.cloud_outlined, size: 14),
                  label: const Text(
                    'Données météo : Open-Meteo • CC BY 4.0',
                    style: TextStyle(fontSize: 10.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  const _WeatherChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16, color: cyan), const SizedBox(width: 6), Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))],
      ),
    );
  }
}

class _FinalDecisionBanner extends StatelessWidget {
  const _FinalDecisionBanner({
    required this.ready,
    required this.hasWeather,
    required this.weatherNoGo,
    required this.completed,
    required this.total,
  });

  final bool ready;
  final bool hasWeather;
  final bool weatherNoGo;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final color = ready ? success : weatherNoGo ? danger : orange;
    final title = ready
        ? 'Checklist complète — décision GO à confirmer sur site'
        : weatherNoGo
            ? 'NO-GO : la météo contient un seuil bloquant'
            : !hasWeather
                ? 'Charge la météo avant de conclure'
                : 'Préparation incomplète : $completed/$total contrôles';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        border: Border.all(color: color.withOpacity(.38)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ready ? Icons.check_circle_rounded : Icons.warning_amber_rounded, color: color, size: 30),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                const Text('Le télépilote reste responsable de la décision finale, de la réglementation, des distances de sécurité et des limites du constructeur.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<(String, String)> _checks = <(String, String)>[
  ('Espace aérien et autorisations', 'Zone, restrictions temporaires, propriétaire du site et règles locales vérifiés.'),
  ('Personnes, routes et obstacles', 'Périmètre sécurisé, lignes, antennes, arbres et trajectoires d’urgence identifiés.'),
  ('Vent et rafales sur site', 'Mesure locale comparée aux limites du drone, pas seulement à la prévision.'),
  ('Pluie, visibilité et plafond', 'Aucune précipitation, visibilité suffisante et nuages compatibles avec l’opération.'),
  ('Cellule, hélices et nacelle', 'Aucun jeu, fissure, saleté ou élément desserré.'),
  ('Batteries et radiocommande', 'Charge, température, état, nombre opérationnel et réserve contrôlés.'),
  ('Stockage et capteur', 'Carte mémoire, format d’image, exposition, focus et heure vérifiés.'),
  ('GNSS, Home Point et RTH', 'Position stable, point de retour confirmé et hauteur RTH adaptée aux obstacles.'),
  ('Plan de mission', 'Altitude, GSD, recouvrements, vitesse, marge de bord et relief cohérents.'),
  ('Décollage et atterrissage', 'Zone plane, dégagée, protégée et solution alternative disponible.'),
  ('Équipe et urgence', 'Rôles, communication, perte de liaison, intrusion et batterie faible préparés.'),
  ('Données et livrables', 'Nom de mission, journal terrain, sauvegarde et critères qualité définis.'),
];
