import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../models/weather_models.dart';
import '../screens/flight_readiness_screen.dart';
import '../services/weather_service.dart';
import 'common.dart';

class FlightReadinessCard extends StatefulWidget {
  const FlightReadinessCard({super.key});

  @override
  State<FlightReadinessCard> createState() => _FlightReadinessCardState();
}

class _FlightReadinessCardState extends State<FlightReadinessCard> {
  final WeatherService _weatherService = WeatherService();
  FlightWeatherSnapshot? _snapshot;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final value = await _weatherService.fetchLocalFlightWeather();
      if (mounted) setState(() => _snapshot = value);
    } on WeatherServiceException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Impossible de charger la météo locale.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _snapshot;
    final color = switch (data?.assessment.decision) {
      FlightDecision.noGo => danger,
      FlightDecision.caution => orange,
      FlightDecision.favorable => success,
      null => cyan,
    };

    return NovaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIcon(icon: Icons.flight_takeoff_rounded, color: color, size: 54),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Field Kit', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(
                      data?.assessment.title ?? 'Météo locale et checklist avant vol',
                      style: TextStyle(color: color, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Checklist complète',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlightReadinessScreen())),
                icon: const Icon(Icons.fact_check_rounded),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            data?.assessment.summary ?? 'Utilise ta localisation pour lire température, vent, rafales, pluie, visibilité, humidité et pression avant la checklist terrain.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.42),
          ),
          if (data != null) ...[
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Pill(label: '${data.weather.temperatureC.toStringAsFixed(1)} °C', icon: Icons.thermostat_rounded, color: color),
                Pill(label: '${data.weather.windSpeedKmh.round()} km/h', icon: Icons.air_rounded, color: color),
                Pill(label: 'Raf. ${data.weather.windGustsKmh.round()}', icon: Icons.waves_rounded, color: color),
                Pill(label: '${(data.weather.visibilityMeters / 1000).toStringAsFixed(1)} km', icon: Icons.visibility_rounded, color: color),
              ],
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: danger, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loading ? null : _load,
                  icon: _loading
                      ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location_rounded),
                  label: Text(data == null ? 'Analyser ma météo' : 'Actualiser'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlightReadinessScreen())),
                  icon: const Icon(Icons.checklist_rounded),
                  label: const Text('Checklist complète'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Connexion et localisation nécessaires. Seuils génériques : le manuel du drone et la réglementation priment.',
            style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
      ),
    );
  }
}
