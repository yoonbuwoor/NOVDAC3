import 'package:droneatlas/models/remote_content_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le catalogue pédagogique est correctement interprété', () {
    final manifest = ContentManifest.fromJson(<String, dynamic>{
      'schemaVersion': 1,
      'contentVersion': 2,
      'publishedAt': '2026-07-30T00:00:00Z',
      'title': 'Cours de test',
      'description': 'Validation du modèle',
      'changelog': <String>['Nouveau cours'],
      'courses': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'test-01',
          'version': 1,
          'title': 'Planification',
          'url': 'courses/test-01.json',
        },
      ],
    });

    expect(manifest.contentVersion, 2);
    expect(manifest.courses, hasLength(1));
    expect(manifest.courses.first.id, 'test-01');
  });
}
