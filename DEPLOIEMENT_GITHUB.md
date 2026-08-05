# Déployer DroneAtlas avec GitHub Actions

Le projet est préconfiguré pour le dépôt `yoonbuwoor/LearnAtlasDrone`.

## Installation du dépôt

Décompresse l’archive, remplace le contenu du dépôt par tous les fichiers fournis, puis réalise un seul commit sur `main`.

Les workflows doivent être présents sous :

```text
.github/workflows/build-android.yml
.github/workflows/deploy-pages.yml
.github/workflows/validate-content.yml
```

Une copie visible est aussi fournie dans `GITHUB_ACTIONS_A_COPIER/` au cas où le dossier `.github` ne serait pas transféré par ton navigateur.

## Android

Le workflow **Build DroneAtlas Android** se lance après un changement du code Flutter. À la fin de l’exécution, l’artefact **DroneAtlas-Android-Release** contient :

```text
app-release.apk
app-release.aab
```

Une modification limitée au dossier `content/` ne recompile pas inutilement l’APK.

## Catalogue de cours

Le workflow **Validate DroneAtlas Content** vérifie chaque cours à chaque modification de `content/`.

Le workflow **Deploy DroneAtlas Web** publie simultanément :

- la PWA Flutter ;
- `content/manifest.json` ;
- tous les fichiers de `content/courses/`.

L’application Android essaie automatiquement les sources suivantes :

```text
https://yoonbuwoor.github.io/LearnAtlasDrone/content/manifest.json
https://raw.githubusercontent.com/yoonbuwoor/LearnAtlasDrone/main/content/manifest.json
https://raw.githubusercontent.com/yoonbuwoor/LearnAtlasDrone/master/content/manifest.json
```

Pour que les téléphones puissent lire les fichiers sans identifiant GitHub, il faut au moins l’une de ces deux conditions :

- GitHub Pages actif pour le dépôt ;
- dépôt public, afin que l’URL `raw.githubusercontent.com` soit accessible.

Le code ne contient volontairement aucun jeton GitHub privé.

## Signature Android

Le workflow utilise actuellement la clé de débogage pour produire immédiatement un APK installable. Pour Google Play, remplace cette signature par une clé de publication privée et conserve-la dans les secrets GitHub.
