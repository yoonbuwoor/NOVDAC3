import 'package:flutter/material.dart';

enum DroneNeed {
  smallMapping,
  mediumMapping,
  largeMapping,
  agriculture,
  lidar,
  thermalInspection,
  budgetLearning,
}

extension DroneNeedLabel on DroneNeed {
  String get label => switch (this) {
        DroneNeed.smallMapping => 'Cartographie < 100 ha',
        DroneNeed.mediumMapping => 'Cartographie 100–500 ha',
        DroneNeed.largeMapping => 'Grande couverture > 500 ha',
        DroneNeed.agriculture => 'Agriculture multispectrale',
        DroneNeed.lidar => 'LiDAR & relief complexe',
        DroneNeed.thermalInspection => 'Inspection thermique',
        DroneNeed.budgetLearning => 'Apprentissage / petit budget',
      };

  IconData get icon => switch (this) {
        DroneNeed.smallMapping => Icons.crop_square_rounded,
        DroneNeed.mediumMapping => Icons.map_rounded,
        DroneNeed.largeMapping => Icons.public_rounded,
        DroneNeed.agriculture => Icons.eco_rounded,
        DroneNeed.lidar => Icons.radar_rounded,
        DroneNeed.thermalInspection => Icons.thermostat_rounded,
        DroneNeed.budgetLearning => Icons.school_rounded,
      };

  bool get professional => this != DroneNeed.budgetLearning;
}

enum DroneBudget {
  any,
  under500k,
  from500kTo1m,
  from1mTo2m,
  from2mTo4m,
  from4mTo8m,
  over8m,
  quoteOnly,
}

extension DroneBudgetLabel on DroneBudget {
  String get label => switch (this) {
        DroneBudget.any => 'Tous les budgets',
        DroneBudget.under500k => 'Moins de 500 000 F CFA',
        DroneBudget.from500kTo1m => '500 000 à 1 million',
        DroneBudget.from1mTo2m => '1 à 2 millions',
        DroneBudget.from2mTo4m => '2 à 4 millions',
        DroneBudget.from4mTo8m => '4 à 8 millions',
        DroneBudget.over8m => 'Plus de 8 millions',
        DroneBudget.quoteOnly => 'Sur devis / configuration pro',
      };

  bool accepts(DroneCatalogItem drone) {
    final price = drone.officialPriceCfa;
    return switch (this) {
      DroneBudget.any => true,
      DroneBudget.under500k => price != null && price < 500000,
      DroneBudget.from500kTo1m => price != null && price >= 500000 && price < 1000000,
      DroneBudget.from1mTo2m => price != null && price >= 1000000 && price < 2000000,
      DroneBudget.from2mTo4m => price != null && price >= 2000000 && price < 4000000,
      DroneBudget.from4mTo8m => price != null && price >= 4000000 && price < 8000000,
      DroneBudget.over8m => price != null && price >= 8000000,
      DroneBudget.quoteOnly => price == null || drone.priceIsStartingFrom,
    };
  }
}

class DroneCatalogItem {
  const DroneCatalogItem({
    required this.id,
    required this.name,
    required this.family,
    required this.profile,
    required this.sensor,
    required this.positioning,
    required this.endurance,
    required this.bestFor,
    required this.limitations,
    required this.tags,
    required this.needScores,
    this.professionalMapping = false,
    this.currentPlatform = true,
    this.accent = 0xFFFF684B,
    this.imageAsset,
    this.officialPriceCfa,
    this.officialPriceEur,
    this.officialProductUrl,
    this.priceIsStartingFrom = false,
    this.priceNote = '',
    this.takeoffMassKg,
  });

  final String id;
  final String name;
  final String family;
  final String profile;
  final String sensor;
  final String positioning;
  final String endurance;
  final String bestFor;
  final String limitations;
  final List<String> tags;
  final Map<DroneNeed, int> needScores;
  final bool professionalMapping;
  final bool currentPlatform;
  final int accent;
  final String? imageAsset;
  final int? officialPriceCfa;
  final int? officialPriceEur;
  final String? officialProductUrl;
  final bool priceIsStartingFrom;
  final String priceNote;
  final double? takeoffMassKg;

  Color get accentColor => Color(accent);

  String get priceLabel {
    if (officialPriceCfa == null) return 'Prix officiel sur devis';
    final prefix = priceIsStartingFrom ? 'À partir de ' : '';
    return '$prefix${formatCfa(officialPriceCfa!)} F CFA';
  }

  String get anacimClass {
    final mass = takeoffMassKg;
    if (mass == null) return 'Classe à confirmer';
    if (mass <= 5) return 'Classe 1';
    if (mass <= 25) return 'Classe 2';
    return 'Classe 3';
  }

  String anacimCodeFor(DroneNeed need) {
    final mass = takeoffMassKg;
    if (mass == null) return 'À confirmer';
    final classNumber = mass <= 5 ? 1 : (mass <= 25 ? 2 : 3);
    final category = need.professional ? 'C' : 'A';
    return '$classNumber$category';
  }

  String authorizationHintFor(DroneNeed need) {
    final code = anacimCodeFor(need);
    if (code == 'À confirmer') {
      return 'La masse totale et l’usage doivent être confirmés avant de déterminer le régime ANACIM.';
    }
    if (code == '2A' || code == '3A') {
      return '$code : non autorisé dans le tableau de catégorisation de l’Annexe 5.';
    }
    if (code == '3C') {
      return '$code : permis d’exploitation de RPAS (PER) requis.';
    }
    return '$code : autorisation d’exploiter de durée limitée, identification et exigences applicables.';
  }
}

String formatCfa(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    if (i > 0 && (raw.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(raw[i]);
  }
  return buffer.toString();
}
