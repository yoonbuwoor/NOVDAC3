import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../config/drobot_config.dart';
import '../data/anacim_rules.dart';
import '../data/drone_catalog_data.dart';
import '../data/drobot_knowledge.dart';
import '../models/drone_catalog_models.dart';
import '../models/drobot_models.dart';

class DrobotService {
  DrobotService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<DrobotReply> answer({
    required String question,
    List<DrobotTurn> history = const <DrobotTurn>[],
  }) async {
    final cleanQuestion = question.trim();
    if (cleanQuestion.isEmpty) {
      return const DrobotReply(
        text: 'Écris une question sur le drone, la photogrammétrie ou la géomatique.',
        source: 'Drobot',
      );
    }

    final contextualQuestion = _withConversationContext(cleanQuestion, history);
    final local = _offlineAnswer(contextualQuestion);
    if (!DrobotConfig.onlineEnabled) return local;

    try {
      final remote = await _onlineAnswer(
        question: contextualQuestion,
        history: history,
        offlineContext: local.text,
      );
      if (remote != null) return remote;
    } catch (_) {
      // Le moteur hors ligne garantit que Drobot reste utilisable sans réseau.
    }
    return DrobotReply(
      text: '${local.text}\n\nMode en ligne indisponible : réponse fournie par la base experte locale.',
      source: 'Base experte hors ligne',
      suggestions: local.suggestions,
    );
  }

  DrobotReply _offlineAnswer(String question) {
    final normalized = _normalize(question);

    final missionPlan = _tryMissionPlanner(normalized, question);
    if (missionPlan != null) return missionPlan;

    final droneRecommendation = _tryDroneRecommendation(normalized);
    if (droneRecommendation != null) return droneRecommendation;

    final regulation = _tryAnacimGuidance(normalized, question);
    if (regulation != null) return regulation;

    final calculator = _tryCalculator(normalized, question);
    if (calculator != null) return calculator;

    if (_containsAny(normalized, <String>['bonjour', 'bonsoir', 'salut', 'hello', 'coucou'])) {
      return const DrobotReply(
        text: 'Bonjour 👋 Je suis Drobot. Je peux analyser une mission complète, estimer un plan de vol, expliquer les drones actuels, diagnostiquer un problème de traitement et préparer une checklist terrain.\n\nEssaie : « Planifie une mission photogrammétrique de 50 ha à 100 m ».',
        source: 'Drobot',
        suggestions: <String>[
          'Planifier une mission complète',
          'Calculer le GSD',
          'Comprendre GCP et checkpoints',
        ],
      );
    }

    final ranked = drobotKnowledge
        .map((entry) => MapEntry(entry, _score(entry, normalized)))
        .where((item) => item.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (ranked.isEmpty || ranked.first.value < 4) {
      return const DrobotReply(
        text: 'Je n’ai pas identifié un sujet assez précis. Essaie de mentionner un concept comme : altitude, GSD, recouvrement, plan de vol, GCP, RTK, orthophoto, DSM/DTM, QGIS, LiDAR, multispectral, précision ou rapport.\n\nPour une réglementation locale ou une exigence de constructeur, vérifie aussi la source officielle la plus récente.',
        source: 'Base experte hors ligne',
        suggestions: <String>[
          'Explique le workflow photogrammétrique',
          'Comment choisir le bon CRS ?',
          'Donne une checklist avant vol',
        ],
      );
    }

    final first = ranked.first.key;
    final wantsSteps = _containsAny(normalized, <String>[
      'comment',
      'etape',
      'procedure',
      'workflow',
      'methode',
      'planifier',
      'faire',
    ]);
    final wantsComparison = _containsAny(normalized, <String>[
      'difference',
      'versus',
      ' vs ',
      'compare',
      'meilleur',
      'choisir',
    ]);
    final wantsShort = _containsAny(normalized, <String>['resume', 'court', 'simplement', 'definition']);

    final buffer = StringBuffer()
      ..writeln('**${first.title}**')
      ..writeln()
      ..writeln(first.summary);

    if (!wantsShort) {
      buffer
        ..writeln()
        ..writeln(first.details);
    }

    if ((wantsSteps || first.steps.isNotEmpty) && first.steps.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Étapes conseillées :');
      for (var i = 0; i < first.steps.length; i++) {
        buffer.writeln('${i + 1}. ${first.steps[i]}');
      }
    }

    if (first.caution != null) {
      buffer
        ..writeln()
        ..writeln('⚠️ ${first.caution}');
    }

    if (wantsComparison && ranked.length > 1 && ranked[1].value >= ranked.first.value - 3) {
      final second = ranked[1].key;
      if (second.id != first.id) {
        buffer
          ..writeln()
          ..writeln('À comparer aussi — ${second.title} : ${second.summary}');
      }
    }

    final relatedEntries = _relatedEntries(first, ranked.map((e) => e.key).toList());
    final suggestions = relatedEntries.take(3).map((e) => e.title).toList();
    if (suggestions.isEmpty) {
      suggestions.addAll(first.related.take(3));
    }

    return DrobotReply(
      text: buffer.toString().trim(),
      source: 'Base experte Drobot',
      suggestions: suggestions,
    );
  }

  Future<DrobotReply?> _onlineAnswer({
    required String question,
    required List<DrobotTurn> history,
    required String offlineContext,
  }) async {
    final endpoint = Uri.tryParse(DrobotConfig.apiUrl.trim());
    if (endpoint == null || !endpoint.hasScheme) return null;

    final recentHistory = history.length <= 10
        ? history
        : history.sublist(history.length - 10);

    final response = await _client
        .post(
          endpoint,
          headers: const <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'question': question,
            'history': recentHistory.map((turn) => turn.toJson()).toList(),
            'offline_context': offlineContext,
            'language': 'fr',
            'assistant': 'Drobot',
            'domain': 'drones, photogrammetry, geomatics, GIS and remote sensing',
          }),
        )
        .timeout(const Duration(seconds: 22));

    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final body = jsonDecode(response.body);
    final text = _extractRemoteText(body);
    if (text == null || text.trim().length < 20) return null;

    return DrobotReply(
      text: text.trim(),
      source: 'IA en ligne + base experte',
      suggestions: const <String>[
        'Donne un exemple concret',
        'Fais une checklist',
        'Explique les erreurs fréquentes',
      ],
    );
  }

  String? _extractRemoteText(dynamic body) {
    if (body is String) return body;
    if (body is! Map) return null;

    final direct = body['answer'] ?? body['message'] ?? body['response'] ?? body['text'];
    if (direct is String) return direct;
    if (direct is Map && direct['content'] is String) {
      return direct['content'] as String;
    }

    final choices = body['choices'];
    if (choices is List && choices.isNotEmpty && choices.first is Map) {
      final first = choices.first as Map;
      final message = first['message'];
      if (message is Map && message['content'] is String) {
        return message['content'] as String;
      }
      if (first['text'] is String) return first['text'] as String;
    }
    return null;
  }

  String _withConversationContext(
    String question,
    List<DrobotTurn> history,
  ) {
    final normalized = _normalize(question);
    final isFollowUp = normalized.length < 45 && _containsAny(normalized, <String>[
      'continue',
      'vas y',
      'fais le',
      'detaille',
      'adapte',
      'et pour',
      'avec mon',
      'sans gcp',
      'montre moi',
      'donne les calculs',
    ]);
    if (!isFollowUp || history.isEmpty) return question;

    for (final turn in history.reversed) {
      if (turn.role == 'user' && turn.content.trim().isNotEmpty) {
        return '${turn.content.trim()}\nPrécision de suivi : $question';
      }
    }
    return question;
  }

  DrobotReply? _tryMissionPlanner(String normalized, String original) {
    final hectares = _extractHectares(original);
    final missionIntent = _containsAny(normalized, <String>[
      'planifier',
      'plan de vol',
      'mission photogrammetrique',
      'mission de',
      'cartographier',
      'couvrir',
    ]);
    if (hectares == null || !missionIntent || hectares <= 0) return null;

    final altitude = _labeledNumber(original, <String>['altitude', 'hauteur']) ?? 100;
    final frontOverlap = (_labeledNumber(
              original,
              <String>['recouvrement longitudinal', 'recouvrement avant', 'frontal'],
            ) ??
            80)
        .clamp(50, 95)
        .toDouble();
    final sideOverlap = (_labeledNumber(
              original,
              <String>['recouvrement lateral', 'latéral', 'lateral'],
            ) ??
            70)
        .clamp(40, 90)
        .toDouble();
    final flightSpeed = (_labeledNumber(original, <String>['vitesse', 'speed']) ?? 8)
        .clamp(2, 20)
        .toDouble();
    final sensorWidthMm =
        _labeledNumber(original, <String>['largeur capteur', 'capteur']) ?? 13.2;
    final sensorHeightMm =
        _labeledNumber(original, <String>['hauteur capteur']) ?? 8.8;
    final focalMm = _labeledNumber(original, <String>['focale', 'focal']) ?? 8.8;
    final imageWidthPx =
        _labeledNumber(original, <String>['largeur image', 'pixels', 'image']) ?? 5472;

    if (altitude <= 0 || focalMm <= 0 || imageWidthPx <= 0) return null;

    final areaM2 = hectares * 10000;
    final approximateSideM = math.sqrt(areaM2);
    final footprintWidthM = altitude * sensorWidthMm / focalMm;
    final footprintHeightM = altitude * sensorHeightMm / focalMm;
    final lineSpacingM = footprintWidthM * (1 - sideOverlap / 100);
    final photoSpacingM = footprintHeightM * (1 - frontOverlap / 100);
    if (lineSpacingM <= 0 || photoSpacingM <= 0) return null;

    final lineCount = math.max(2, (approximateSideM / lineSpacingM).ceil() + 1);
    final photosPerLine = math.max(2, (approximateSideM / photoSpacingM).ceil() + 1);
    final rawPhotoCount = lineCount * photosPerLine;
    final estimatedPhotos = (rawPhotoCount * 1.08).ceil();
    final routeDistanceM =
        (lineCount * approximateSideM + (lineCount - 1) * lineSpacingM) * 1.08;
    final flightMinutes = routeDistanceM / flightSpeed / 60 + 4;
    final usableMinutesPerBattery = 20.0;
    final operationalBatteries = math.max(1, (flightMinutes / usableMinutesPerBattery).ceil());
    final storageGb = estimatedPhotos * 8 / 1024;
    final gsdCm = altitude * sensorWidthMm * 100 / (focalMm * imageWidthPx);
    final regulatoryNote = altitude > anacimMaxAltitudeMeters
        ? '⛔ ALERTE ANACIM : ${_fmt(altitude)} m dépasse 300 ft AGL (≈ 91,4 m). Ce scénario est NO-GO sans permission de l’Autorité et accord applicable des services de navigation aérienne.'
        : altitude >= 80
            ? '⚠️ PRUDENCE ANACIM : altitude proche de 300 ft AGL. Contrôle le relief et la hauteur réelle au-dessus du sol.'
            : '✅ Repère ANACIM : l’altitude saisie reste sous 300 ft AGL, sous réserve des autres règles et autorisations.';

    final buffer = StringBuffer()
      ..writeln('**Plan opérationnel estimatif — ${_fmt(hectares)} ha**')
      ..writeln()
      ..writeln('Hypothèses utilisées : altitude ${_fmt(altitude)} m, recouvrements ${_fmt(frontOverlap, 0)}/${_fmt(sideOverlap, 0)} %, vitesse ${_fmt(flightSpeed)} m/s, capteur ${_fmt(sensorWidthMm)} × ${_fmt(sensorHeightMm)} mm, focale ${_fmt(focalMm)} mm.')
      ..writeln()
      ..writeln(regulatoryNote)
      ..writeln()
      ..writeln('Résultats géométriques :')
      ..writeln('• GSD théorique : ${_fmt(gsdCm, 2)} cm/pixel')
      ..writeln('• Empreinte d’une image : ${_fmt(footprintWidthM, 0)} × ${_fmt(footprintHeightM, 0)} m')
      ..writeln('• Espacement des lignes : ${_fmt(lineSpacingM, 1)} m')
      ..writeln('• Déclenchement environ tous les ${_fmt(photoSpacingM, 1)} m')
      ..writeln('• Environ $lineCount lignes et $estimatedPhotos images avec marge')
      ..writeln('• Distance de trajectoire : ${_fmt(routeDistanceM / 1000, 1)} km')
      ..writeln('• Temps de vol théorique : ${_fmt(flightMinutes, 0)} min')
      ..writeln('• Batteries : $operationalBatteries opérationnelle(s) + 1 réserve')
      ..writeln('• Stockage indicatif : ${_fmt(storageGb, 1)} Go si une photo pèse environ 8 Mo')
      ..writeln()
      ..writeln('Préparation terrain :')
      ..writeln('1. Dessine l’emprise réelle et ajoute une marge de bord de 20 à 40 m.')
      ..writeln('2. Oriente les longues lignes selon la forme du terrain et évite un vent de face permanent.')
      ..writeln('3. Vérifie relief, obstacles, espace aérien, personnes et zones d’atterrissage de secours.')
      ..writeln('4. Place des GCP si le projet l’exige et réserve des checkpoints indépendants pour mesurer l’erreur.')
      ..writeln('5. Découpe la mission en blocs si le retour automatique, le relief ou la batterie rendent une seule grille risquée.')
      ..writeln('6. Lance un court vol test, inspecte netteté, exposition, recouvrement et géolocalisation, puis démarre la production.')
      ..writeln('7. Sur le terrain, sauvegarde les images et note météo, batteries, incidents et paramètres.')
      ..writeln()
      ..writeln('Contrôle après vol : images nettes à 100 %, aucune rupture de grille, recouvrement réel cohérent, journal GNSS complet et couverture des bords.')
      ..writeln()
      ..writeln('⚠️ C’est une estimation pédagogique pour une emprise approximativement carrée. Donne-moi le modèle exact du drone, le capteur, le GSD cible, le relief et la forme de la parcelle pour l’adapter. Les limites constructeur, les autorisations et la météo du site priment toujours.');

    return DrobotReply(
      text: buffer.toString().trim(),
      source: 'Planificateur avancé Drobot',
      suggestions: <String>[
        'Adapte ce plan à une parcelle longue et étroite',
        'Ajoute une stratégie GCP et checkpoints',
        'Fais la checklist terrain de cette mission',
      ],
    );
  }

  DrobotReply? _tryDroneRecommendation(String normalized) {
    final intent = _containsAny(normalized, <String>[
      'quel drone',
      'choisir drone',
      'drone pour',
      'recommande drone',
      'meilleur drone',
      'dji pour',
      'liste drone dji',
      'types de drones',
      'marques de drones',
    ]);
    if (!intent) return null;

    final need = _containsAny(normalized, <String>['multispectral', 'agriculture', 'ndvi', 'culture'])
        ? DroneNeed.agriculture
        : _containsAny(normalized, <String>['lidar', 'foret', 'forêt', 'canopée', 'relief complexe'])
            ? DroneNeed.lidar
            : _containsAny(normalized, <String>['thermique', 'inspection', 'solaire', 'toiture'])
                ? DroneNeed.thermalInspection
                : _containsAny(normalized, <String>['grande surface', 'plus de 500', '> 500', 'corridor'])
                    ? DroneNeed.largeMapping
                    : _containsAny(normalized, <String>['100 500', '100-500', 'moyenne surface'])
                        ? DroneNeed.mediumMapping
                        : _containsAny(normalized, <String>['budget', 'debut', 'début', 'apprendre', 'formation'])
                            ? DroneNeed.budgetLearning
                            : DroneNeed.smallMapping;

    final ranked = djiDroneCatalog.toList()
      ..sort(
        (a, b) => (b.needScores[need] ?? 0).compareTo(a.needScores[need] ?? 0),
      );
    final best = ranked.take(4).toList();
    final buffer = StringBuffer()
      ..writeln('**Suggestions DJI — ${need.label}**')
      ..writeln()
      ..writeln('Drobot compare l’usage, le capteur, le positionnement, la productivité et la logistique :');
    for (var index = 0; index < best.length; index++) {
      final drone = best[index];
      buffer
        ..writeln()
        ..writeln('${index + 1}. **${drone.name}** — ${drone.needScores[need] ?? 0} %')
        ..writeln('   ${drone.bestFor}')
        ..writeln('   Capteur : ${drone.sensor}');
    }
    buffer
      ..writeln()
      ..writeln('Ouvre l’onglet **Drones** pour comparer les ${djiDroneCatalog.length} configurations, leurs limites et les recommandations par besoin.')
      ..writeln()
      ..writeln('⚠️ Vérifie toujours la disponibilité, la documentation du fabricant, les autorisations et la compatibilité des charges utiles avant achat ou mission.');

    return DrobotReply(
      text: buffer.toString().trim(),
      source: 'Conseiller matériel Drobot',
      suggestions: const <String>[
        'Compare Matrice 4E et Mavic 3E',
        'Quel drone pour le LiDAR ?',
        'Quel drone pour le multispectral ?',
      ],
    );
  }

  DrobotReply? _tryAnacimGuidance(String normalized, String original) {
    final intent = _containsAny(normalized, <String>[
      'anacim',
      'annexe 5',
      'ras 06',
      'reglement drone',
      'réglementation drone',
      'limite altitude',
      '300 pieds',
      'vol de nuit',
      'proche aerodrome',
      'proche aérodrome',
      'espace controle',
      'espace contrôlé',
    ]);
    if (!intent) return null;

    final altitude = _labeledNumber(original, <String>['altitude', 'hauteur']);
    final altitudeMessage = altitude == null
        ? '• Altitude générale : ne pas dépasser 300 ft AGL, soit environ 91,4 m, sans permission applicable.'
        : altitude > anacimMaxAltitudeMeters
            ? '⛔ Altitude ${_fmt(altitude)} m : dépassement de 300 ft AGL. Le simulateur doit afficher un NO-GO sans permission applicable.'
            : '✅ Altitude ${_fmt(altitude)} m : sous 300 ft AGL, mais les autres règles restent à vérifier.';

    return DrobotReply(
      text: '''**Repères ANACIM intégrés**

$altitudeMessage
• Les opérations de nuit nécessitent une autorisation spéciale.
• Le BVLOS exige notamment une étude de sécurité acceptée.
• Un espace aérien contrôlé demande une autorisation ATS.
• Le voisinage des aérodromes comporte des rayons de protection selon la longueur de piste.
• Le survol d’une zone urbaine ou encombrée nécessite une autorisation spéciale.

Le module Réglementation présente le résumé pédagogique de l’Annexe 5. Pour une mission réelle, consulte la version officielle à jour et les autorisations applicables.''',
      source: 'Annexe 5 au RAS 06 • résumé pédagogique',
      suggestions: const <String>[
        'Explique la limite des 300 pieds',
        'Quelles règles près d’un aérodrome ?',
        'Que faut-il pour un vol BVLOS ?',
      ],
    );
  }

  double? _extractHectares(String input) {
    final match = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:ha|hectare|hectares)\b',
      caseSensitive: false,
    ).firstMatch(input);
    return _parseNumber(match?.group(1));
  }

  DrobotReply? _tryCalculator(String normalized, String original) {
    if (_containsAny(normalized, <String>['calcul gsd', 'calculer gsd', 'gsd avec', 'gsd pour'])) {
      final altitude = _labeledNumber(original, <String>['altitude', 'hauteur', 'h']);
      final sensor = _labeledNumber(original, <String>['capteur', 'sensor', 'largeur capteur']);
      final focal = _labeledNumber(original, <String>['focale', 'focal']);
      final pixels = _labeledNumber(original, <String>['pixels', 'largeur image', 'image']);

      if (altitude != null && sensor != null && focal != null && pixels != null && focal > 0 && pixels > 0) {
        final gsdCm = altitude * sensor * 100 / (focal * pixels);
        final footprintM = altitude * sensor / focal;
        return DrobotReply(
          text: '**Calcul du GSD**\n\nGSD ≈ altitude × largeur capteur ÷ (focale × largeur image).\n\nAvec altitude ${_fmt(altitude)} m, capteur ${_fmt(sensor)} mm, focale ${_fmt(focal)} mm et image ${_fmt(pixels)} px :\n• GSD ≈ ${_fmt(gsdCm, 2)} cm/pixel\n• largeur couverte ≈ ${_fmt(footprintM, 1)} m\n\nCe résultat est théorique. La netteté, le relief, l’obturateur, la calibration et le géoréférencement influencent la qualité réelle.',
          source: 'Calculateur Drobot',
          suggestions: const <String>[
            'Quel recouvrement utiliser ?',
            'Comment convertir un GSD cible en altitude ?',
            'Comment contrôler la précision ?',
          ],
        );
      }

      return const DrobotReply(
        text: '**Calcul du GSD**\n\nDonne les quatre valeurs avec leurs noms :\n`altitude 100 m, capteur 13.2 mm, focale 8.8 mm, image 5472 pixels`\n\nDrobot calculera le GSD et la largeur couverte.',
        source: 'Calculateur Drobot',
      );
    }

    if (_containsAny(normalized, <String>['surface hectare', 'hectare en m2', 'ha en m2'])) {
      final values = _allNumbers(original);
      if (values.isNotEmpty) {
        final hectares = values.first;
        return DrobotReply(
          text: '${_fmt(hectares)} hectare(s) = ${_fmt(hectares * 10000, 0)} m² = ${_fmt(hectares * 0.01, 3)} km².',
          source: 'Calculateur Drobot',
        );
      }
    }

    if (_containsAny(normalized, <String>['autonomie mission', 'temps de vol', 'nombre batterie'])) {
      final duration = _labeledNumber(original, <String>['mission', 'durée', 'duree', 'temps']);
      final battery = _labeledNumber(original, <String>['batterie', 'autonomie']);
      if (duration != null && battery != null && battery > 0) {
        final usable = battery * 0.75;
        final count = math.max(1, (duration / usable).ceil());
        return DrobotReply(
          text: 'Avec une autonomie nominale de ${_fmt(battery)} min, Drobot retient environ 75 % utilisables, soit ${_fmt(usable, 1)} min par batterie. Pour ${_fmt(duration)} min de mission, prévois au minimum $count batterie(s), puis ajoute une batterie de secours si la logistique le permet.',
          source: 'Estimateur Drobot',
        );
      }
    }

    return null;
  }

  int _score(DrobotKnowledgeEntry entry, String question) {
    var score = 0;
    final title = _normalize(entry.title);
    final category = _normalize(entry.category);

    if (question.contains(title)) score += 18;
    if (question.contains(category)) score += 4;

    for (final keyword in entry.keywords) {
      final normalizedKeyword = _normalize(keyword);
      if (question.contains(normalizedKeyword)) {
        score += normalizedKeyword.contains(' ') ? 8 : 4;
      } else {
        final words = normalizedKeyword.split(' ').where((word) => word.length >= 4);
        for (final word in words) {
          if (question.contains(word)) score += 1;
        }
      }
    }

    final titleWords = title.split(' ').where((word) => word.length >= 5);
    for (final word in titleWords) {
      if (question.contains(word)) score += 2;
    }

    return score;
  }

  List<DrobotKnowledgeEntry> _relatedEntries(
    DrobotKnowledgeEntry first,
    List<DrobotKnowledgeEntry> ranked,
  ) {
    final results = <DrobotKnowledgeEntry>[];
    for (final entry in ranked) {
      if (entry.id != first.id && entry.category == first.category) {
        results.add(entry);
      }
    }
    for (final related in first.related) {
      for (final entry in drobotKnowledge) {
        if (entry.id != first.id && _normalize(entry.title).contains(_normalize(related)) && !results.contains(entry)) {
          results.add(entry);
        }
      }
    }
    return results;
  }

  double? _labeledNumber(String input, List<String> labels) {
    final escaped = labels.map(RegExp.escape).join('|');
    final labelBefore = RegExp(
      '(?:$escaped)\\s*[:=]?\\s*(\\d+(?:[.,]\\d+)?)',
      caseSensitive: false,
    );
    final matchBefore = labelBefore.firstMatch(input);
    if (matchBefore != null) return _parseNumber(matchBefore.group(1));

    final numberBefore = RegExp(
      '(\\d+(?:[.,]\\d+)?)\\s*(?:m|mm|min|minutes|px|pixels)?\\s*(?:$escaped)',
      caseSensitive: false,
    );
    final matchAfter = numberBefore.firstMatch(input);
    if (matchAfter != null) return _parseNumber(matchAfter.group(1));
    return null;
  }

  List<double> _allNumbers(String input) => RegExp(r'\d+(?:[.,]\d+)?')
      .allMatches(input)
      .map((match) => _parseNumber(match.group(0)))
      .whereType<double>()
      .toList();

  double? _parseNumber(String? value) =>
      value == null ? null : double.tryParse(value.replaceAll(',', '.'));

  String _fmt(double value, [int decimals = 1]) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(decimals).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  bool _containsAny(String input, List<String> values) =>
      values.any((value) => input.contains(_normalize(value)));

  String _normalize(String value) {
    const replacements = <String, String>{
      'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
      'ç': 'c',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'î': 'i', 'ï': 'i', 'í': 'i',
      'ô': 'o', 'ö': 'o', 'ó': 'o',
      'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
      'œ': 'oe',
    };
    var result = value.toLowerCase();
    replacements.forEach((key, replacement) {
      result = result.replaceAll(key, replacement);
    });
    return result.replaceAll(RegExp(r'[^a-z0-9%+./ -]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void dispose() => _client.close();
}
