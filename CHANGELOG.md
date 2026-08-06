# 3.5.1+20 — Suppression du compte

- Bouton **Supprimer définitivement mon compte** dans le profil.
- Connexion et confirmation sécurisées par mot de passe.
- Suppression du compte Firebase et des données Backblaze B2 associées.
- Nettoyage du profil, de la progression, des scores et des rappels locaux.
- Page Web Play Store `/supprimer-compte` sans formulaire externe.
- Workflow Android mis à jour pour transmettre la configuration Firebase.
- Mode sombre de nouveau utilisé par défaut, conformément au correctif visuel demandé.

# 3.5.0+19 — Mode jour, progression cloud et communauté

- Mode jour par défaut avec préférence persistante.
- Progression locale persistante et synchronisation automatique au retour d’Internet.
- API Netlify de progression avec stockage Backblaze B2 et fusion multi-appareils.
- Communauté WhatsApp intégrée sans afficher de numéro de téléphone.
- Nom public : Drone Atlas Academy.

# Version 3.4.1 — Publication Play Store initiale

- Les parcours certifiants sont annoncés comme bientôt disponibles.
- Les écrans de connexion, d’examen et de génération de certificat ne sont plus accessibles dans cette publication.
- Ajout d’un écran de préparation invitant à explorer les cours, les quiz, les outils et les simulations.
- Suppression de l’initialisation Firebase Certification au démarrage.
- Le workflow Android ne demande plus les secrets Firebase ou du serveur de certification.
- Ajout de la signature Google Play automatique lorsque les secrets de clé d’importation sont présents.
- Mise à jour du numéro de version Android vers `3.4.1+18`.

# Version 3.0.2 — Correctif analyse Flutter

- Suppression du `const` invalide sur le `ConstrainedBox` de l’accueil.
- Conservation de `const` uniquement sur `BoxConstraints` et `Text`.
- Suppression de la variable locale inutilisée `imageHeightPx` dans Nova Labs.
- Mise à jour du numéro de version Android vers `3.0.2+12`.
- Artefact GitHub Actions renommé `DroneAtlas-Nova-3.0.2-Android`.

# 3.0.1 — Correctif GitHub Actions

- L’analyse Flutter ne bloque plus sur les simples informations `prefer_const_constructors`.
- Les véritables erreurs Dart restent bloquantes.
- Le rapport d’analyse est téléchargeable dans les artefacts GitHub Actions.

# Changelog

## 3.0.0 — Nova

- Refonte totale du design et de la navigation.
- Nouveau cockpit responsive.
- Ajout de Nova Labs et de son calculateur opérationnel.
- Ajout d’une checklist terrain interactive.
- Ajout d’un décodeur de produits.
- Parcours étendu à 12 modules et 36 leçons intégrées.
- Ajout de 3 missions avancées.
- Ajout de 4 domaines d’application.
- Drobot devient Drobot Nova et reçoit de nouvelles connaissances sur les capteurs avancés, l’IA géospatiale et le métier.
- Mise à jour du splash, de l’onboarding et du workflow Android.
- Conservation de la configuration EmailJS et des mises à jour de contenu.

## 2.5.2

- Correction des entrées Drobot qui ne fournissaient pas le paramètre `details`.

## 2.5.1

- Amélioration des erreurs EmailJS et ajout du renvoi du profil.
