# Architecture — DroneAtlas Nova 3.0

## Vision

DroneAtlas Nova est une académie Flutter locale conçue comme un cockpit d’apprentissage. Elle combine cours, scénarios, simulateurs pédagogiques, outils de préparation terrain, progression et assistance experte. Elle ne remplace ni un logiciel de planification certifié ni un moteur photogrammétrique réel.

## Navigation

L’application s’organise en cinq espaces :

1. **Cockpit** : progression, prochaine leçon, radar de compétences et raccourcis.
2. **Académie** : 12 modules et 36 leçons embarquées.
3. **Nova Labs** : calculateur de mission, checklist, décodeur de produits et simulateurs.
4. **Missions** : 6 scénarios décisionnels notés.
5. **Profil** : identité locale, XP, badges, notifications et renvoi EmailJS.

Sur grand écran, la navigation utilise une barre latérale. Sur mobile, elle devient une barre flottante avec un bouton orbital Drobot.

## Couches

### Présentation

Les écrans sont adaptatifs et utilisent le design system Material 3 défini dans `lib/core/theme.dart`. Les composants partagés Nova se trouvent dans `lib/widgets/common.dart`.

### État et stockage local

`AppController` maintient la progression, les paramètres des simulateurs, l’état du catalogue, le profil et les préférences. `SharedPreferencesAsync` conserve les informations nécessaires sur l’appareil.

### Académie embarquée

`lib/data/academy_data.dart` contient les modules, leçons, quiz, glossaire, domaines et missions disponibles dès l’installation et hors connexion.

### Drobot Nova

`lib/data/drobot_knowledge.dart` contient la base experte locale. `DrobotService` classe les sujets, produit des procédures et exécute plusieurs calculateurs. Un proxy IA facultatif peut être déclaré avec `DROBOT_API_URL`.

### Nova Labs

`lib/screens/lab_hub_screen.dart` utilise les paramètres de mission du contrôleur pour fournir des estimations pédagogiques : GSD, images, durée, batteries, stockage et empreinte de prise de vue.

### Contenu évolutif

`content/manifest.json` annonce la version et les cours distants. `ContentUpdateService` télécharge, valide et met en cache le JSON. Une mise à jour de cours ne nécessite pas une nouvelle compilation de l’APK.

### Inscription EmailJS

Le profil est enregistré localement puis transmis par `RegistrationService` à EmailJS avec les variables principales `name`, `profession` et `email`. La variable `date` est facultative côté template.

### Notifications et arrière-plan

`flutter_local_notifications` affiche les nouveautés et rappels. `workmanager` peut vérifier périodiquement le catalogue, sous réserve des règles d’économie d’énergie d’Android.

## Flux de contenu

```text
Modification d’un cours dans content/
              ↓
Validation JSON
              ↓
Lecture du manifest par l’application
              ↓
Téléchargement et cache local
              ↓
Consultation hors connexion
```
