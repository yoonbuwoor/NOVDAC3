# Catalogue de cours DroneAtlas

Ce dossier est le centre de contenu distant de l’application. Il est lu directement depuis la branche `main` du dépôt `yoonbuwoor/DroneLearn3`.

- `manifest.json` annonce la version du catalogue et la liste des cours.
- `courses/` contient un fichier JSON complet par cours.
- `templates/course-template.json` sert de modèle pour une future leçon.

Après un commit sur GitHub, l’application détecte automatiquement une version de contenu supérieure, affiche la nouveauté dans le centre de mises à jour et conserve les cours téléchargés hors connexion.

Pour publier une nouvelle version :

1. ajouter ou modifier le fichier du cours ;
2. l’ajouter dans `manifest.json` ;
3. augmenter `contentVersion` ;
4. faire un seul commit.

Le workflow `Validate DroneAtlas Content` vérifie automatiquement les identifiants, les URLs, les questions et les réponses.
