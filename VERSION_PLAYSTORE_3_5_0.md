# Drone Atlas Academy 3.5.0+19 — version Play Store

## Changements intégrés

- Mode jour activé par défaut au premier lancement.
- Choix clair/sombre conservé localement.
- Progression des cours, quiz et missions sauvegardée hors connexion.
- Synchronisation automatique au démarrage, après une activité et au retour d’Internet.
- Fusion conservatrice : le meilleur score, le niveau d’XP le plus élevé et toutes les activités validées sont conservés.
- État de synchronisation visible dans le profil avec un bouton de relance manuelle.
- Numéro de téléphone retiré de l’interface du profil.
- Communauté WhatsApp officielle intégrée à l’accueil, au profil et à la page des certifications.
- Nom public uniformisé : **Drone Atlas Academy**.
- Parcours certifiants toujours annoncés comme bientôt disponibles.

## Synchronisation serveur

Le projet contient `netlify/functions/progress-api.mjs`. Déployez le dépôt sur Netlify avec les variables Backblaze B2 déjà utilisées par le backend :

- `B2_S3_ENDPOINT`
- `B2_REGION`
- `B2_BUCKET`
- `B2_KEY_ID`
- `B2_APPLICATION_KEY`

L’URL par défaut est :

`https://droneatlas.xyz/.netlify/functions/progress-api`

Pour utiliser une autre URL, ajoutez le secret GitHub `PROGRESS_SYNC_URL`.

## Build Android

Le workflow génère l’artefact :

`Drone-Atlas-Academy-3.5.0-PlayStore`
