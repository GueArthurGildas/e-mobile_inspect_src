# eInspec APP - Documentation technique

## Contexte

Cette documentation décrit les ajouts et modifications réalisés dans l'application **eINSPECTION**.

L'objectif principal a été de mettre en place le wizard d'inspection (multi-étapes), ainsi que la gestion hors-ligne via SQLite et la synchronisation des données.

J'ai adapté mon code à l'architecture déjà en place, afin d'assurer la compatibilité avec le travail existant.

## Écran de synchronisation : `SyncScreen`

- Fichier : `sync_screen.dart`
- Enum **`SyncStatus`** : `initializing`, `syncing`, `needsInternetToSync`, `readyToProceed`, `error`.

**Logique** :

1. Vérifie la connectivité (`Common.checkInternetConnection`).
2. Consulte un flag `SharedPreferences` (`AppPrefs`) pour savoir si une synchro a déjà eu lieu (`sync==true`).
3. Si **connecté** et **jamais synchronisé** → `syncAll()` via `SyncController`, puis flag `sync=true`, statut `readyToProceed`.
4. Si **hors‑ligne** :
    - jamais synchronisé → `needsInternetToSync` (bloquant),
    - déjà synchronisé → `readyToProceed` (autorise le mode offline avec le cache local).
    - **Navigation** : une fois `readyToProceed`, l'utilisateur peut aller vers le wizard.

## La page principale : `InspectionWizardScreen`

Fichier : `inspection_form_screen.dart`

Cette page matérialise le **wizard** :

- **`WizardOption`** : structure `{title, key, route}` définissant chaque étape (intitulé, identifiant logique, route de navigation).
- **`currentStep`** : index de l'étape sélectionnée (UI met en surbrillance la carte de l'étape).
- **Navigation** : appui sur une ligne d'étape -> met à jour `currentStep` (et/ou `Navigator.pushNamed` via `route`).
- **Dépendances clés** :
- `SyncController.instance` : charge les données (pays, ports, types, etc.)

***SyncController** correspond au controleur permettant de faire la synchronisation des données locales à celles en ligne lorsque l'utilisateur se connecte la première fois, et qu'il a accès à internet, et permet aussi de récupérer les données depuis la base de données lorsque la syncrhonisation est déjà faite.*

- `AppRoutes` : noms de routes vers les écrans d'étape (`step_1` → `step_6`).

**Rôle fonctionnel**

1. **Lister** les étapes dans l'ordre :
    - "Informations initiales" → `AppRoutes.inspectionInformationsInitiales`
    - "Informations responsables" → `AppRoutes.inspectionInfosResponsables`
    - "Informations sur les documents de l'inspection" → `AppRoutes.inspectionDocuments`
    - "Contrôle des engins" → `AppRoutes.<i>inspectionInformationsEngins</i>`
    - "Contrôle des captures" → `AppRoutes.inspectionControleCaptures`
    - "Conformité…/Dernière étape" → `AppRoutes.inspectionLastStep`
2. **Diriger** l'utilisateur vers l'écran ciblé.
3. **Réagir** à l'état de synchronisation (via `SyncController`) si l'accès à certains contenus nécessite des données locales.

<aside>
💡

À noter : la logique de validation est implémentée dans chaque écran via AppForm/FormControl. La page principale ne valide pas les champs ; elle orchestre seulement la navigation et la récupération des entrées lorsque les modifications sont enregistrées.

</aside>

## Écrans par étape & controllers

Chaque dossier `step_X` contient généralement :

- Un **écran** `Form…Screen` (UI + formulaire),
- Un **controller** `StepXController` (chargement des listes).

**Pages**

- **Step 1 – Informations initiales**
    - `informations_initiales.dart` : construit un `AppForm` avec des `FormControl` (pays, ports, activité, etc.),
    - `step_one_controller.dart` : charge `paysList`, `portsList`, `typesNavireList` via `SyncController` (et ses sous‑controllers : `PortsController`, etc.).
    - `extra_fields_page.dart` : *bottom‑sheet/page* pour champs additionnels dynamiques.
- **Step 2 – Responsables**
    - `informations_responsables.dart` : formulaire des responsables (capitaine, armateur, contacts…),
    - `step_two_controller.dart` : logique associée (chargement des données si nécessaires).
- **Step 4 – Engins**
    - `engins_listview.dart`, `engine_bottomsheet.dart`, `informations_engins.dart` : gestion des entrées par engin,
    - `step_four_controller.dart` : charge `etatsEngins` & `typesEngins` depuis `SyncController`.
- **Step 5 – Captures**
    - `controle_captures.dart`, `informations_captures_screen.dart` : lignes de capture, quantités, espèces,
    - `step_five_controller.dart` : logique associée.
- **Step 6 – Dernière étape / Récap**
    - `inspection_last_step.dart`
    - `step_six_controller.dart`

<aside>
💡

Principe : chaque écran déclare ses *FormControl* et confie la validation au Form global (via formKey), et ses contrôles sont utilisés par le widget AppForm pour créer le visuel. Les controllers d'étape chargent les listes (référentiels) depuis la base locale via SyncController.

</aside>

## Les *custom widgets* & logique associée

### `CustomAppBar` (`shared/app_bar.dart`)

- Hérite de `AppBar` et expose **des paramètres haut‑niveau** : `backgroundColor`, `foregroundColor`, `centerTitle`, `customActions`, etc.
- But : **standardiser** la barre d'app et réduire le code répétitif.

### `BaseButton` + `AppButton` (`shared/base_button.dart`, `shared/app_button.dart`)

- `BaseButton` : fine surcouche `CupertinoButton` (gestion `disabledColor`, padding/size neutres). C'est le **socle**.
- `AppButton` : déclinaisons **Material** prêtes à l'emploi :
- `AppButton.outline(...)`, `AppButton.solid(...)`, etc. avec icônes pré/suffixes, `borderRadius`, `padding`, `height/width`, `enabled`…
- **Décorrélation style/usage** : on utilise `AppButton` partout → cohérence visuelle + accessibilité centralisée.

### `AppForm` & `FormControl` (`shared/app_form.dart`, `shared/form_control.dart`)

**Cœur du système de formulaire**.

- **`ControlType`** (extrait) : `label`, `text`, `textarea`, `dropdown`, `dropdownSearch`, `date`, `time`, `switchTile`, `button`, `file`.
- **`FormControl`** : décrit **un champ** :
    - métadonnées : `key`, `label`, `placeholder`, `visible`, `enabled`, `style`, `separator`, `child`…
    - validation : `required`, `minLength`, `maxLength`, `pattern` (RegExp),
    - valeur : `initialValue`, `onChanged`,
    - structures : `fields` (composés), `fileItems`, `searchDropdownItems`, `asyncSearch`, `asyncSearchQuery`.
- **`AppForm`** :
    - prend `controls: List&lt;FormControl&gt;` + `formKey` + `children` optionnels,
    - **génère dynamiquement** les *Widgets* en fonction de `ControlType`, via un `switch` interne,
    - gère le **clavier** (dismiss on drag), les **marges/paddings**, et un **`SafeArea`** avec adaptation à l'inset bas,
    - délègue aux sous‑widgets spécialisés pour certains types (`AppDropdownSearch`, `FileManager`, pickers `Common`).

<aside>
💡

Intérêt : ajouter un champ ne nécessite pas de recoder l'UI ; on ajoute un FormControl. La validation reste centralisée et uniforme.

</aside>

### `AppDropdownSearch` (`shared/app_dropdown_search.dart`)

- Objet `DropdownItem { id, value, label, isSelected }`.
- Supporte :
    - **recherche locale** (dans `searchDropdownItems`),
    - **recherche asynchrone** (`asyncSearch=true` + `asyncSearchQuery`),
- UI : champ de recherche, liste scrollable, indicateur de sélection, **état contrôlé** (`selectedItem`).
- **Motif d'usage** : listes volumineuses (espèces, etc.) avec filtrage efficient.

**Fonctionnement** :

- **Recherche synchrone (locale)**
    - **Mécanisme** :
        
        → L'utilisateur tape du texte dans le champ de recherche.
        
        → La fonction `searchDropdownItems` parcourt la liste locale d'objets `DropdownItem` ; ces options sont chargées lors de l'initialisation du contrôle par le biais du controleur de la page où le contrôle est créé.
        
        → Un filtrage est fait sur `label` (en minuscule pour ignorer la casse).
        
        → Le widget met à jour la liste affichée en temps réel.
        
        - **Contexte d'usage** :
        
        → Quand la liste de données est déjà disponible dans l'application et facile à charger au niveau du controleur.
        
        → Typiquement : liste des **pays** ou **ports** déjà synchronisés dans la base locale.
        
- **Recherche asynchrone (API / service externe)**
    - **Mécanisme** :
        
        → Si `asyncSearch=true`, au lieu de filtrer la liste locale, le widget appelle la fonction `asyncSearchQuery` fournie en paramètre.
        
        → Cette fonction est une **requête SQLite différée**.
        
        → Les résultats retournés sont ensuite transformés en liste de `DropdownItem`.
        
        → Le widget met à jour son `state` avec ces résultats.
        
        - **Contexte d'usage** :
        
        → Quand la liste est **trop volumineuse** pour être récupérée lors du la page, pour éviter de ralentir le chargement (par exemple, des milliers d'espèces).
        
        → Pas encore actif, mais pourrait permettre de faire des recherches réseau, quand connecté à internet.
        

### `FileManager` (`shared/file_manager.dart`)

- Modèle `LocalFileItem { path, name, isSelected, isSaved, size, type }`.
- Opérations : **`_pickFiles()`** via `file_picker` → ajoute dans `_pickedFiles` (de type `LocalFileItem`).
- **Sélection multiple** / inversion, **suppression** (`_removeSelectedFiles()`),
- **Callbacks** `onPick`, `onDelete` pour remonter l'état au parent.
- UI : liste des fichiers choisis (nom, taille), cases de sélection, actions (Ajouter / Supprimer).

### `AppFABSpeedDial` (`shared/app_fab_speed_dial.dart`)

- `FABAction { icon, label, onPressed, fabBackground, foreground }`.
- Animations avec `AnimationController` + `ScaleTransition/FadeTransition`, ouverture/fermeture via `_toggleMenu()`.
- But : proposer **plusieurs actions rapides** (ex. "Sauvegarder", "Valider", "Partager") depuis un seul FAB.

### `Common` (`shared/common.dart`)

- Utilitaires UI : `pickDate()`, `pickTime()`, `showSnackBar()`, etc.
- **Réseau** : `checkInternetConnection()` (résolution DNS simple) pour déterminer l'accès.

### `AppPrefs` (`shared/app_preferences.dart`)

- Mince surcouche **SharedPreferences** : `setString/getString`, `setBool/getBool`, `setInt/getInt`.
- Utilisé notamment par `SyncScreen` pour mémoriser l'état de synchro.