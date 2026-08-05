import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_models.dart';

class WeatherServiceException implements Exception {
  const WeatherServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<FlightWeatherSnapshot> fetchLocalFlightWeather() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const WeatherServiceException(
        'Active la localisation du téléphone pour obtenir la météo du site.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const WeatherServiceException(
        'Autorisation de localisation refusée. Elle est nécessaire uniquement pour interroger la météo de ta position.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const WeatherServiceException(
        'La localisation est bloquée pour DroneAtlas. Autorise-la dans les paramètres Android.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', <String, String>{
      'latitude': position.latitude.toStringAsFixed(6),
      'longitude': position.longitude.toStringAsFixed(6),
      'current': [
        'temperature_2m',
        'relative_humidity_2m',
        'apparent_temperature',
        'precipitation',
        'rain',
        'weather_code',
        'cloud_cover',
        'pressure_msl',
        'wind_speed_10m',
        'wind_direction_10m',
        'wind_gusts_10m',
        'visibility',
      ].join(','),
      'wind_speed_unit': 'kmh',
      'timezone': 'auto',
      'forecast_days': '1',
    });

    http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 18));
    } catch (_) {
      throw const WeatherServiceException(
        'Connexion météo impossible. Vérifie Internet puis réessaie.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WeatherServiceException(
        'Le service météo est temporairement indisponible (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const WeatherServiceException('Réponse météo non reconnue.');
    }
    final current = decoded['current'];
    if (current is! Map<String, dynamic>) {
      throw const WeatherServiceException('Données météo actuelles absentes.');
    }

    double number(String key, [double fallback = 0]) {
      final value = current[key];
      return value is num ? value.toDouble() : fallback;
    }

    final observedAt = DateTime.tryParse('${current['time'] ?? ''}');
    final weather = CurrentFlightWeather(
      latitude: position.latitude,
      longitude: position.longitude,
      timezone: '${decoded['timezone'] ?? ''}',
      observedAt: observedAt,
      temperatureC: number('temperature_2m'),
      apparentTemperatureC: number('apparent_temperature'),
      relativeHumidity: number('relative_humidity_2m'),
      precipitationMm: number('precipitation'),
      rainMm: number('rain'),
      weatherCode: number('weather_code').round(),
      cloudCover: number('cloud_cover'),
      pressureHpa: number('pressure_msl'),
      windSpeedKmh: number('wind_speed_10m'),
      windDirectionDegrees: number('wind_direction_10m'),
      windGustsKmh: number('wind_gusts_10m'),
      visibilityMeters: number('visibility', 10000),
    );

    return FlightWeatherSnapshot(
      weather: weather,
      assessment: assess(weather),
    );
  }

  FlightWeatherAssessment assess(CurrentFlightWeather weather) {
    final blocking = <String>[];
    final cautions = <String>[];

    if (weather.precipitationMm > .1 || weather.rainMm > .1) {
      blocking.add('Précipitations détectées : protège le matériel et reporte le vol.');
    }
    if (weather.weatherCode >= 95) {
      blocking.add('Risque orageux : ne décolle pas.');
    }
    if (weather.visibilityMeters < 3000) {
      blocking.add('Visibilité inférieure à 3 km.');
    }
    if (weather.windGustsKmh >= 35) {
      blocking.add('Rafales fortes (${weather.windGustsKmh.round()} km/h).');
    }
    if (weather.temperatureC <= 0 || weather.temperatureC >= 40) {
      blocking.add('Température extrême (${weather.temperatureC.round()} °C).');
    }

    if (weather.windGustsKmh >= 25 && weather.windGustsKmh < 35) {
      cautions.add('Rafales sensibles (${weather.windGustsKmh.round()} km/h).');
    }
    if (weather.windSpeedKmh >= 20) {
      cautions.add('Vent moyen élevé (${weather.windSpeedKmh.round()} km/h).');
    }
    if ((weather.temperatureC <= 5 && weather.temperatureC > 0) ||
        (weather.temperatureC >= 35 && weather.temperatureC < 40)) {
      cautions.add('Température exigeante pour les batteries et l’électronique.');
    }
    if (weather.relativeHumidity >= 90) {
      cautions.add('Humidité très élevée : surveille condensation et brouillard.');
    }
    if (weather.visibilityMeters >= 3000 && weather.visibilityMeters < 5000) {
      cautions.add('Visibilité réduite à moins de 5 km.');
    }

    if (blocking.isNotEmpty) {
      return FlightWeatherAssessment(
        decision: FlightDecision.noGo,
        title: 'NO-GO météo',
        summary: 'Au moins un paramètre météo justifie de reporter ou de reconfigurer la mission.',
        reasons: <String>[...blocking, ...cautions],
      );
    }
    if (cautions.isNotEmpty) {
      return FlightWeatherAssessment(
        decision: FlightDecision.caution,
        title: 'Prudence renforcée',
        summary: 'Le vol peut être envisageable seulement après vérification du drone, du site et des limites constructeur.',
        reasons: cautions,
      );
    }
    return const FlightWeatherAssessment(
      decision: FlightDecision.favorable,
      title: 'Météo plutôt favorable',
      summary: 'Aucun seuil météo générique critique n’est détecté. Termine la checklist terrain avant toute décision GO.',
      reasons: <String>[
        'Contrôle obligatoire des rafales réelles au point de décollage.',
        'Les limites du manuel constructeur et les règles locales restent prioritaires.',
      ],
    );
  }

  void dispose() => _client.close();
}
