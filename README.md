# Drone Atlas Academy 3.5.0

Application Flutter pédagogique de Novateur221 consacrée aux drones, à la photogrammétrie, à la géomatique, à la météo opérationnelle, aux capteurs et à l’IA géospatiale.

## Version Play Store actuelle

- mode jour par défaut ;
- cours, quiz, missions, laboratoire, Drobot et ressources accessibles ;
- parcours certifiants annoncés comme **bientôt disponibles** ;
- progression sauvegardée hors connexion ;
- synchronisation automatique au retour d’Internet ;
- meilleurs scores des quiz et missions conservés ;
- communauté WhatsApp officielle intégrée ;
- aucun numéro de téléphone affiché dans le profil.

## Compiler sur GitHub

1. Copiez tout le contenu de ce dossier à la racine du dépôt GitHub.
2. Vérifiez les quatre secrets de signature Android.
3. Ouvrez **Actions**.
4. Choisissez **Build Drone Atlas Academy Android**.
5. Cliquez sur **Run workflow**.
6. Téléchargez l’artefact **Drone-Atlas-Academy-3.5.0-PlayStore**.

L’artefact contient l’APK de test et l’AAB destiné au Play Store.

## Synchronisation de la progression

La fonction serveur est incluse dans :

```text
netlify/functions/progress-api.mjs
```

Elle utilise Backblaze B2 pour conserver et fusionner la progression. L’URL par défaut de l’application est :

```text
https://droneatlas.xyz/.netlify/functions/progress-api
```

Pour utiliser une autre adresse, créez sur GitHub le secret facultatif :

```text
PROGRESS_SYNC_URL
```

Le dépôt Netlify doit disposer des variables B2 listées dans `VERSION_PLAYSTORE_3_5_0.md`.

## Drobot en ligne

La base experte hors ligne reste accessible sans clé. Pour connecter un proxy IA, créez le secret GitHub :

```text
DROBOT_API_URL
```

Ne placez jamais une clé privée d’API directement dans l’APK.
