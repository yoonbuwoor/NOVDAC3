import 'package:droneatlas/services/drobot_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Drobot répond sur le GSD hors ligne', () async {
    final service = DrobotService();
    final reply = await service.answer(question: 'À quoi sert le GSD ?');

    expect(reply.text.toLowerCase(), contains('gsd'));
    expect(reply.text.toLowerCase(), contains('pixel'));
    service.dispose();
  });

  test('Drobot calcule un GSD avec des valeurs nommées', () async {
    final service = DrobotService();
    final reply = await service.answer(
      question: 'Calcule le GSD avec altitude 100 m, capteur 13.2 mm, focale 8.8 mm et image 5472 pixels',
    );

    expect(reply.source, contains('Calculateur'));
    expect(reply.text, contains('cm/pixel'));
    service.dispose();
  });
}
