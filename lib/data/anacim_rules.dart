import 'package:flutter/material.dart';

const String anacimOfficialRegulationUrl =
    'https://www.anacim.sn/IMG/pdf/annexe_5_au_ras_06_-_systemes_d_aeronefs_telepilotes_rpas_.pdf';
const double anacimMaxAltitudeFeet = 300;
const double anacimMaxAltitudeMeters = 91.44;
const double anacimMaxLevelSpeedKmh = 150;
const double anacimMinimumVisibilityKm = 1;

enum RpasUseType { leisurePrivate, aeromodellingSport, professional }

extension RpasUseTypeLabel on RpasUseType {
  String get label => switch (this) {
        RpasUseType.leisurePrivate => 'Loisir et/ou privé',
        RpasUseType.aeromodellingSport => 'Aéromodélisme / sport',
        RpasUseType.professional => 'Professionnel / commercial',
      };

  String get categoryLetter => switch (this) {
        RpasUseType.leisurePrivate => 'A',
        RpasUseType.aeromodellingSport => 'B',
        RpasUseType.professional => 'C',
      };
}

class RpasClassificationResult {
  const RpasClassificationResult({
    required this.classNumber,
    required this.category,
    required this.code,
    required this.allowed,
    required this.document,
    required this.summary,
  });

  final int classNumber;
  final RpasUseType category;
  final String code;
  final bool allowed;
  final String document;
  final String summary;
}

RpasClassificationResult classifyRpas({
  required double massKg,
  required RpasUseType use,
}) {
  final classNumber = massKg <= 5 ? 1 : (massKg <= 25 ? 2 : 3);
  final code = '$classNumber${use.categoryLetter}';
  final allowed = code != '2A' && code != '3A' && code != '3B';

  if (!allowed) {
    return RpasClassificationResult(
      classNumber: classNumber,
      category: use,
      code: code,
      allowed: false,
      document: 'Non autorisé dans le tableau de catégorisation',
      summary:
          'Le couple masse/usage $code est indiqué comme non autorisé par l’Annexe 5. Choisis un régime compatible ou demande une clarification formelle à l’ANACIM.',
    );
  }

  if (code == '3C') {
    return RpasClassificationResult(
      classNumber: classNumber,
      category: use,
      code: code,
      allowed: true,
      document: 'Permis d’exploitation de RPAS (PER)',
      summary:
          'Les opérations professionnelles avec un RPAS de plus de 25 kg relèvent du PER, avec exigences renforcées de navigabilité, de formation, d’organisation et de gestion de la sécurité.',
    );
  }

  return RpasClassificationResult(
    classNumber: classNumber,
    category: use,
    code: code,
    allowed: true,
    document: 'Autorisation d’exploiter de durée limitée',
    summary:
        'Le régime $code est admis sous autorisation, identification du RPAS et respect des conditions opérationnelles. Une activité professionnelle reste en catégorie C même avec un drone léger.',
  );
}

class RpasMatrixCell {
  const RpasMatrixCell({
    required this.code,
    required this.allowed,
    required this.document,
  });

  final String code;
  final bool allowed;
  final String document;
}

const rpasClassificationMatrix = <RpasMatrixCell>[
  RpasMatrixCell(code: '1A', allowed: true, document: 'Autorisation limitée'),
  RpasMatrixCell(code: '1B', allowed: true, document: 'Autorisation limitée'),
  RpasMatrixCell(code: '1C', allowed: true, document: 'Autorisation limitée'),
  RpasMatrixCell(code: '2A', allowed: false, document: 'Non autorisé'),
  RpasMatrixCell(code: '2B', allowed: true, document: 'Autorisation limitée'),
  RpasMatrixCell(code: '2C', allowed: true, document: 'Autorisation limitée'),
  RpasMatrixCell(code: '3A', allowed: false, document: 'Non autorisé'),
  RpasMatrixCell(code: '3B', allowed: false, document: 'Non autorisé'),
  RpasMatrixCell(code: '3C', allowed: true, document: 'PER'),
];

const professionalAuthorizationChecklist = <String>[
  'Copie certifiée conforme de la pièce d’identification du postulant.',
  'Photo d’identité récente de moins de trois mois.',
  'Pour un postulant étranger : mandat, contrat de prestation avec une société immatriculée au Sénégal/UEMOA ou ordre de mission d’une entité de l’État.',
  'Explication détaillée du projet : topographie, cartographie, photogrammétrie, agriculture, inspection, etc.',
  'Nom et contacts du point focal.',
  'Formulaire de demande d’autorisation dûment renseigné.',
  'Statuts, registre de commerce, NINEA, contacts et adresse de la société.',
  'Formulaire d’étude d’impact sur la sécurité renseigné.',
  'Indicatif d’appel pour les besoins de radiotéléphonie.',
  'Copies des licences, certificats ou attestations de formation des télépilotes.',
  'Manuel d’activités particulières, manuel de maintenance et manuel d’utilisation des RPAS.',
  'Description détaillée et cartographie des zones d’opération avec coordonnées géographiques.',
  'Demande de NOTAM à transmettre avant le début de l’activité lorsque nécessaire.',
  'Informations sur la charge utile embarquée.',
  'Autorisation du ministère de l’Intérieur lorsque le RPAS est équipé d’une caméra.',
  'Assurance responsabilité civile couvrant les opérations.',
  'Preuve de paiement des frais liés à l’autorisation.',
];

const perAdditionalChecklist = <String>[
  'Demande de PER déposée au moins trois mois avant le début prévu des opérations.',
  'Lettre officielle de demande de PER signée par le responsable de l’exploitant.',
  'Documentation de l’aéronef et de ses composants : navigabilité, identification, maintenance et manuels.',
  'Système de gestion de la sécurité (SGS) et programme de sûreté lorsque requis.',
  'Procédures normales, anormales et d’urgence, y compris perte de liaison C2.',
  'Description des postes de télépilotage, des lieux d’exploitation et des transferts éventuels entre RPS.',
  'Organisation, personnel qualifié, fonctions et responsabilités clairement établies.',
  'Casiers judiciaires de moins de trois mois des principaux responsables.',
  'Engagement signé de conformité aux règlements applicables.',
  'Préparation aux cinq phases de certification : pré-demande, demande formelle, étude documentaire, inspection/démonstration et délivrance.',
];

const leisureAuthorizationChecklist = <String>[
  'Demander et obtenir une autorisation de l’ANACIM avant toute opération.',
  'Utiliser les zones et horaires approuvés ; les activités de loisirs et de sport s’effectuent dans le cadre prévu par l’Autorité.',
  'Fournir au minimum identité, contacts, description du RPAS, zone, date et objet de l’opération selon la procédure applicable.',
  'Identifier le RPAS auprès de l’Autorité avant exploitation.',
  'Souscrire une assurance responsabilité civile couvrant les dommages aux tiers.',
  'Respecter les limites de jour, VLOS, altitude, aérodromes, zones interdites et protection de la vie privée.',
];

const identificationAndLicenceChecklist = <String>[
  'Nul ne doit exploiter un RPAS au Sénégal sans identification par l’Autorité et numéro délivré.',
  'Les marques d’identification utilisent le préfixe SN.UAS suivi d’une combinaison de lettres et de chiffres.',
  'Le certificat d’identification doit être mis à jour dans les trente jours en cas d’ajout, retrait, destruction ou changement de propriétaire.',
  'Depuis janvier 2022, le télépilote opérant depuis le Sénégal doit détenir une licence délivrée ou validée par l’Autorité, sous réserve des exceptions prévues.',
  'Les autorisations, licences et certificats ne sont ni cessibles, ni transférables, ni transmissibles.',
];

class AnacimRuleSummary {
  const AnacimRuleSummary({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;
}

const anacimRuleSummaries = <AnacimRuleSummary>[
  AnacimRuleSummary(
    title: 'Altitude générale',
    value: '300 ft AGL ≈ 91,4 m',
    detail:
        'Au-delà, une permission de l’Autorité et l’accord des services de navigation aérienne sont requis.',
    icon: Icons.height_rounded,
  ),
  AnacimRuleSummary(
    title: 'Vol de jour',
    value: 'Lever → coucher du soleil',
    detail:
        'Le vol de nuit est interdit sauf autorisation spéciale de l’Autorité.',
    icon: Icons.light_mode_rounded,
  ),
  AnacimRuleSummary(
    title: 'Visibilité directe',
    value: 'VLOS par défaut',
    detail:
        'Le BVLOS exige notamment une étude de sécurité acceptée par l’Autorité.',
    icon: Icons.visibility_rounded,
  ),
  AnacimRuleSummary(
    title: 'Vitesse maximale',
    value: '150 km/h en palier',
    detail: 'La limite indiquée par l’Annexe 5 correspond à 81 nœuds.',
    icon: Icons.speed_rounded,
  ),
  AnacimRuleSummary(
    title: 'Visibilité météo',
    value: 'Au moins 1 km',
    detail: 'Le texte impose aussi des marges par rapport aux nuages.',
    icon: Icons.cloud_rounded,
  ),
  AnacimRuleSummary(
    title: 'Aérodromes',
    value: '1,5 / 3 / 10 km',
    detail:
        'Rayons selon la longueur de piste, sauf autorisation formelle.',
    icon: Icons.flight_land_rounded,
  ),
  AnacimRuleSummary(
    title: 'Zone urbaine',
    value: 'Autorisation spéciale',
    detail:
        'Le survol d’une zone encombrée, d’une ville, d’un village ou d’une localité n’est pas libre.',
    icon: Icons.location_city_rounded,
  ),
  AnacimRuleSummary(
    title: 'Espace contrôlé',
    value: 'Autorisation ATS',
    detail:
        'L’exploitation en espace aérien contrôlé nécessite l’autorisation des services de la circulation aérienne.',
    icon: Icons.radar_rounded,
  ),
];

enum AnacimComplianceLevel { compliant, caution, blocked }

class AnacimSimulationInput {
  const AnacimSimulationInput({
    required this.altitudeMeters,
    required this.speedMetersPerSecond,
    required this.dayOperation,
    required this.vlos,
    required this.nearAerodrome,
    required this.controlledAirspace,
    required this.congestedArea,
    required this.hasAuthorization,
  });

  final double altitudeMeters;
  final double speedMetersPerSecond;
  final bool dayOperation;
  final bool vlos;
  final bool nearAerodrome;
  final bool controlledAirspace;
  final bool congestedArea;
  final bool hasAuthorization;
}

class AnacimComplianceResult {
  const AnacimComplianceResult({
    required this.level,
    required this.title,
    required this.messages,
  });

  final AnacimComplianceLevel level;
  final String title;
  final List<String> messages;

  bool get blocked => level == AnacimComplianceLevel.blocked;
}

AnacimComplianceResult assessAnacimSimulation(AnacimSimulationInput input) {
  final blocking = <String>[];
  final cautions = <String>[];
  final speedKmh = input.speedMetersPerSecond * 3.6;

  if (input.altitudeMeters > anacimMaxAltitudeMeters) {
    final text =
        'Altitude ${input.altitudeMeters.round()} m : la limite générale de 300 ft AGL (≈ 91,4 m) est dépassée.';
    if (input.hasAuthorization) {
      cautions.add(
          '$text Confirme la permission de l’Autorité et l’accord des services de navigation aérienne.');
    } else {
      blocking.add(
          '$text Réduis l’altitude ou renseigne une autorisation applicable.');
    }
  } else if (input.altitudeMeters >= 80) {
    cautions.add(
        'Altitude proche de la limite : vérifie le relief, les obstacles et la hauteur réellement maintenue au-dessus du sol.');
  }

  if (speedKmh > anacimMaxLevelSpeedKmh) {
    blocking.add(
        'Vitesse ${speedKmh.round()} km/h : dépassement de la limite de 150 km/h en vol en palier.');
  }

  if (!input.dayOperation) {
    if (input.hasAuthorization) {
      cautions.add(
          'Opération de nuit : vérifie que l’autorisation spéciale et les conditions imposées couvrent ce scénario.');
    } else {
      blocking.add('Vol de nuit : interdit sans autorisation spéciale de l’Autorité.');
    }
  }

  if (!input.vlos) {
    if (input.hasAuthorization) {
      cautions.add(
          'Scénario BVLOS : l’autorisation seule ne suffit pas ; l’étude de sécurité et les procédures acceptées doivent être confirmées.');
    } else {
      blocking.add(
          'Scénario BVLOS : une étude de sécurité acceptée par l’Autorité est requise avant l’opération.');
    }
  }

  if (input.controlledAirspace) {
    if (input.hasAuthorization) {
      cautions.add(
          'Espace aérien contrôlé : confirme l’autorisation ATS et les conditions de coordination.');
    } else {
      blocking.add(
          'Espace aérien contrôlé : autorisation des services de la circulation aérienne requise.');
    }
  }

  if (input.nearAerodrome) {
    if (input.hasAuthorization) {
      cautions.add(
          'Voisinage d’aérodrome : contrôle le rayon applicable (1,5 km, 3 km ou 10 km selon la piste) et l’autorisation formelle.');
    } else {
      blocking.add(
          'Voisinage d’aérodrome : opération interdite dans les rayons réglementaires sans autorisation formelle.');
    }
  }

  if (input.congestedArea) {
    if (input.hasAuthorization) {
      cautions.add(
          'Zone encombrée ou localité : vérifie que l’autorisation spéciale couvre précisément la zone et les mesures de protection des tiers.');
    } else {
      blocking.add(
          'Survol d’une zone encombrée, ville, village ou localité : autorisation spéciale requise.');
    }
  }

  if (blocking.isNotEmpty) {
    return AnacimComplianceResult(
      level: AnacimComplianceLevel.blocked,
      title: 'NO-GO réglementaire simulé',
      messages: [...blocking, ...cautions],
    );
  }
  if (cautions.isNotEmpty) {
    return AnacimComplianceResult(
      level: AnacimComplianceLevel.caution,
      title: 'PRUDENCE — vérifications obligatoires',
      messages: cautions,
    );
  }
  return const AnacimComplianceResult(
    level: AnacimComplianceLevel.compliant,
    title: 'Paramètres généraux compatibles',
    messages: [
      'Aucune incompatibilité évidente n’est détectée dans ce scénario pédagogique.',
      'La vérification des autorisations, NOTAM, espace aérien, météo et conditions réelles reste obligatoire avant tout vol.',
    ],
  );
}
