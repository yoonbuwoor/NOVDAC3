# Drone Atlas Academy — version 3.5.1+20

## Notes de version Play Store

- Ajout de la suppression définitive du compte depuis le profil.
- Suppression automatique de la progression et des données associées.
- Réinitialisation locale après suppression.
- Ajout de la page publique de demande de suppression.
- Amélioration de la protection des données personnelles.

## URL de suppression à saisir dans Play Console

`https://droneatlas.xyz/supprimer-compte`

## Déploiement

1. Déployer le projet sur Netlify.
2. Vérifier que `/.netlify/functions/account-delete-api` répond.
3. Ajouter ou vérifier les secrets Firebase dans GitHub Actions.
4. Compiler l’AAB `3.5.1+20`.
5. Tester la suppression avec un compte Firebase de test avant l’envoi à Google Play.
