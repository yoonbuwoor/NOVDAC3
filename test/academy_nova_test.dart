import 'package:droneatlas/data/academy_data.dart';
import 'package:droneatlas/data/drobot_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Nova contient les parcours et scénarios attendus', () {
    expect(modules, hasLength(12));
    expect(totalLessonCount, greaterThanOrEqualTo(36));
    expect(missions, hasLength(6));
    expect(domains, hasLength(10));
  });

  test('les identifiants de leçons sont uniques', () {
    final ids = modules.expand((module) => module.lessons).map((lesson) => lesson.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('Drobot Nova possède une base experte étendue', () {
    expect(drobotKnowledge.length, greaterThanOrEqualTo(35));
    expect(
      drobotKnowledge.any((entry) => entry.id == 'ai-segmentation'),
      isTrue,
    );
    expect(
      drobotKnowledge.any((entry) => entry.id == 'multispectral-calibration'),
      isTrue,
    );
  });
}
