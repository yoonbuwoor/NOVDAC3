# Installation en une seule fois sur GitHub

Cette archive contient déjà le code Flutter, Android, les workflows GitHub Actions et le catalogue distant.

## Remplacement complet recommandé

1. Décompresser l’archive.
2. Remplacer le contenu du dépôt `LearnAtlasDrone` par le contenu du dossier décompressé.
3. Faire un seul commit sur `main`.

Les trois workflows seront alors disponibles :

- **Build DroneAtlas Android** : APK + AAB ;
- **Deploy DroneAtlas Web** : PWA GitHub Pages ;
- **Validate DroneAtlas Content** : contrôle des cours JSON.

Si l’interface GitHub ne transfère pas le dossier caché `.github`, les mêmes fichiers sont copiés en clair dans `GITHUB_ACTIONS_A_COPIER/`. Il suffit alors de placer ces trois YAML dans `.github/workflows/`.

## Accès aux mises à jour distantes

Le dépôt visible sur la capture est privé. Un téléphone ne peut pas télécharger anonymement un fichier brut privé. Le projet prévoit donc GitHub Pages en priorité et les URLs brutes publiques en secours. Il reste nécessaire que GitHub Pages soit autorisé pour ce dépôt, ou que le dépôt soit rendu public. Aucun code sérieux ne peut contourner cette protection sans exposer un jeton secret dans l’APK.
