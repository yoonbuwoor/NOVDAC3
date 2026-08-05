enum FlightDecision { favorable, caution, noGo }

class CurrentFlightWeather {
  const CurrentFlightWeather({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.observedAt,
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.relativeHumidity,
    required this.precipitationMm,
    required this.rainMm,
    required this.weatherCode,
    required this.cloudCover,
    required this.pressureHpa,
    required this.windSpeedKmh,
    required this.windDirectionDegrees,
    required this.windGustsKmh,
    required this.visibilityMeters,
  });

  final double latitude;
  final double longitude;
  final String timezone;
  final DateTime? observedAt;
  final double temperatureC;
  final double apparentTemperatureC;
  final double relativeHumidity;
  final double precipitationMm;
  final double rainMm;
  final int weatherCode;
  final double cloudCover;
  final double pressureHpa;
  final double windSpeedKmh;
  final double windDirectionDegrees;
  final double windGustsKmh;
  final double visibilityMeters;

  String get conditionLabel {
    if (weatherCode == 0) return 'Ciel dégagé';
    if (weatherCode <= 3) return 'Partiellement nuageux';
    if (weatherCode == 45 || weatherCode == 48) return 'Brouillard';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Pluie ou bruine';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Neige';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Averses';
    if (weatherCode >= 85 && weatherCode <= 86) return 'Averses de neige';
    if (weatherCode >= 95) return 'Orage';
    return 'Conditions variables';
  }

  String get windDirectionLabel {
    const labels = <String>['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    final index = ((windDirectionDegrees % 360) / 45).round() % 8;
    return labels[index];
  }
}

class FlightWeatherAssessment {
  const FlightWeatherAssessment({
    required this.decision,
    required this.title,
    required this.summary,
    required this.reasons,
  });

  final FlightDecision decision;
  final String title;
  final String summary;
  final List<String> reasons;
}

class FlightWeatherSnapshot {
  const FlightWeatherSnapshot({
    required this.weather,
    required this.assessment,
  });

  final CurrentFlightWeather weather;
  final FlightWeatherAssessment assessment;
}
