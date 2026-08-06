# Drone Atlas Academy 3.5.1 — Suppression du compte

Cette mise à jour ajoute une suppression de compte conforme au parcours attendu par Google Play.

## Dans l’application

- Chemin : **Profil > Mon compte > Supprimer définitivement mon compte**.
- Le bouton n’est actif que lorsqu’un compte Firebase est connecté.
- Le mot de passe est redemandé afin de sécuriser l’opération.
- Une confirmation irréversible est affichée avant la suppression.
- Après succès, l’application revient à l’écran initial.

## Données supprimées automatiquement

- compte Firebase Authentication ;
- progression synchronisée Backblaze B2 ;
- scores et validations ;
- sessions, résultats et certificats liés au compte ;
- données locales du profil et de progression ;
- rappels et synchronisations liés au profil supprimé.

## Ressource Web Play Store

URL à déclarer dans Play Console :

`https://droneatlas.xyz/supprimer-compte`

La page ne contient pas de formulaire. Elle explique le parcours dans l’application et propose un bouton e-mail pour les utilisateurs qui n’ont plus accès à l’application.

## Déploiement requis

Déployer Netlify afin d’activer :

- `netlify/functions/account-delete-api.mjs`
- `netlify/public/supprimer-compte.html`

Le build Android doit recevoir les secrets Firebase existants. Le secret GitHub facultatif `ACCOUNT_DELETE_API_URL` peut surcharger l’URL par défaut.

## Permission Backblaze requise

La clé B2 utilisée par Netlify doit autoriser la lecture, la liste et la suppression des fichiers du bucket (`listFiles`, `readFiles`, `writeFiles`, `deleteFiles`). Sans `deleteFiles`, le compte Firebase restera intact et l’application affichera une erreur afin que l’utilisateur puisse réessayer.
