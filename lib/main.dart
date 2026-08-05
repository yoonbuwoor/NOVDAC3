import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app.dart';
import 'services/background_update_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Garde-fous visuels : aucune surimpression de diagnostic ne doit apparaître
  // dans les écrans de cours ou de simulation.
  debugPaintBaselinesEnabled = false;
  debugPaintTextLayoutBoxes = false;

  try {
    await NotificationService.instance.initialize();
    await BackgroundUpdateService.initialize();
  } catch (_) {
    // Les fonctions pédagogiques restent accessibles si Android refuse
    // momentanément un service système au démarrage.
  }
  runApp(const DroneAtlasApp());
}
