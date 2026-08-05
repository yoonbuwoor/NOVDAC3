# Correctif de compilation 2.5.2

Deux entrées de la base de connaissances de Drobot appelaient `DrobotKnowledgeEntry` sans fournir le paramètre obligatoire `details` :

- `processing-failure`
- `qgis`

Les deux descriptions ont été ajoutées dans `lib/data/drobot_knowledge.dart`.

Les avertissements `prefer_const_constructors` visibles dans GitHub Actions restent informatifs et ne bloquent pas la compilation, car le workflow utilise `--no-fatal-infos --no-fatal-warnings`.
