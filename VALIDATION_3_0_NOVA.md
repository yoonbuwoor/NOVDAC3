# Validation de l’archive Nova 3.0

Contrôles statiques exécutés avant la création de l’archive :

- équilibre lexical de tous les fichiers Dart ;
- résolution de tous les imports relatifs ;
- présence des ressources images référencées ;
- validation des fichiers JSON et YAML ;
- unicité des identifiants ;
- présence des paramètres obligatoires dans les modèles pédagogiques ;
- intégrité du ZIP final.

Inventaire vérifié :

- 12 modules ;
- 36 leçons ;
- 6 missions ;
- 10 domaines d’application ;
- 47 fiches de connaissances Drobot.

Le SDK Flutter n’étant pas installé dans l’environnement de préparation, la compilation native finale reste confiée au workflow GitHub Actions inclus. Celui-ci exécute `flutter analyze`, puis génère l’APK et l’AAB Release.
