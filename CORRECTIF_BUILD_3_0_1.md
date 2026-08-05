# Correctif DroneAtlas Nova 3.0.1

Le workflow Android ne bloque plus sur de simples informations de style comme
`prefer_const_constructors`.

La vérification conserve son rôle :

- les vraies erreurs Dart marquées `error •` interrompent le workflow ;
- les informations et avertissements de style sont enregistrés sans empêcher l’APK ;
- le journal complet `flutter-analyze.log` est publié comme artefact GitHub pendant 7 jours ;
- les règles de style `prefer_const_*` ne sont plus activées comme contrôles du projet.

Le workflow compile ensuite l’APK et l’AAB avec la configuration EmailJS existante.
