# Mises à jour des cours DroneAtlas

Le système est déjà configuré pour le dépôt :

```text
https://github.com/yoonbuwoor/LearnAtlasDrone
```

L’application consulte automatiquement :

```text
content/manifest.json
```

## Ce qui est déjà automatisé

- vérification du catalogue au démarrage ;
- vérification Android en arrière-plan ;
- notification quand une version supérieure est détectée ;
- téléchargement de tous les nouveaux cours depuis le bouton de mise à jour ;
- conservation des cours hors connexion ;
- rappels locaux d’apprentissage ;
- validation automatique des fichiers JSON par GitHub Actions ;
- aucune recompilation Android pour une simple modification de `content/`.

## Publier plus tard un nouveau cours

Il faudra seulement faire un commit contenant :

1. le fichier du cours dans `content/courses/` ;
2. sa ligne dans `content/manifest.json` ;
3. une valeur `contentVersion` supérieure.

Le modèle prêt à remplir se trouve dans :

```text
content/templates/course-template.json
```

Les utilisateurs n’ont pas à réinstaller l’APK. DroneAtlas leur signale la nouveauté, puis le cours est téléchargé et reste consultable hors connexion.

## Notifications

Au premier lancement sur une version récente d’Android, le système demande l’autorisation d’afficher les notifications. C’est la seule validation qui ne peut pas être automatisée, car elle appartient aux protections du téléphone.

Les notifications sont entièrement locales : aucun compte, Firebase, serveur applicatif ou base de données n’est utilisé.
