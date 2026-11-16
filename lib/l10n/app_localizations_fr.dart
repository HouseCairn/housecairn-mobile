// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Housecairn';

  @override
  String get navToday => 'Aujourd\'hui';

  @override
  String get navRooms => 'Pièces';

  @override
  String get navProjects => 'Projets';

  @override
  String get navBudget => 'Budget';

  @override
  String get navMore => 'Plus';

  @override
  String get moreHelpGroup => 'Aide';

  @override
  String get about => 'À propos';

  @override
  String get aboutAttribution => 'Housecairn, by Robvred';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutLicence => 'Logiciel libre sous licence AGPL-3.0.';

  @override
  String aboutSource(String address) {
    return 'Code source et signalement de sécurité : $address';
  }

  @override
  String get aboutAi => 'Développé avec un agent IA, sous revue humaine.';

  @override
  String get aboutLicences => 'Licences open source';

  @override
  String get aboutBeta => 'Bêta iPhone (TestFlight)';

  @override
  String get aboutBetaOpen => 'Ouvrir le lien';

  @override
  String get aboutBetaCopy => 'Copier le lien';

  @override
  String get aboutBetaCopied => 'Lien copié';

  @override
  String get aboutBetaCannotOpen =>
      'Rien sur ce téléphone ne peut ouvrir ce lien.';

  @override
  String get moreHomeGroup => 'Logement';

  @override
  String get moreMeGroup => 'Moi';

  @override
  String get moreReportsText => 'Problèmes signalés dans ce logement';

  @override
  String get moreContractorsText =>
      'Les personnes et entreprises qui interviennent dans le logement';

  @override
  String get moreHomesText => 'Ajouter un logement ou en ouvrir un autre';

  @override
  String get notifications => 'Notifications';

  @override
  String get moreNotificationsText =>
      'Quand le téléphone vous rappelle une tâche';

  @override
  String get homes => 'Mes logements';

  @override
  String get brandName => 'HouseCairn';

  @override
  String get helpTooltip => 'Aide sur cette page';

  @override
  String get homeSelectorTooltip => 'Choisir un logement';

  @override
  String get allHomes => 'Tous les logements';

  @override
  String get todayOverdue => 'En retard';

  @override
  String get todayToday => 'Aujourd\'hui';

  @override
  String get todayComingUp => 'À venir';

  @override
  String get todayNoDate => 'Sans date';

  @override
  String get todayEmpty => 'Rien à faire pour l\'instant.';

  @override
  String dueOn(String date) {
    return 'Échéance : $date';
  }

  @override
  String postponedTo(String date) {
    return 'Reportée au $date';
  }

  @override
  String get actionDone => 'Fait';

  @override
  String get actionMore => 'Autres actions';

  @override
  String get actionSkip => 'Ignorer cette fois';

  @override
  String get actionPostpone => 'Reporter';

  @override
  String doneMessage(String title) {
    return 'Fait : $title';
  }

  @override
  String skippedMessage(String title) {
    return 'Ignorée : $title';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get newTask => 'Nouvelle tâche';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get task => 'Tâche';

  @override
  String get taskTitle => 'Titre';

  @override
  String get taskDueDate => 'Échéance';

  @override
  String get taskChooseDate => 'Choisir une date';

  @override
  String get taskClearDate => 'Retirer la date';

  @override
  String get repeat => 'Répétition';

  @override
  String get repeatOnce => 'Une fois';

  @override
  String get repeatFixed => 'Date fixe';

  @override
  String get repeatAfterLast => 'Après la dernière fois';

  @override
  String get repeatEvery => 'Tous les';

  @override
  String get unitDays => 'jours';

  @override
  String get unitWeeks => 'semaines';

  @override
  String get unitMonths => 'mois';

  @override
  String get unitYears => 'ans';

  @override
  String get season => 'Saison';

  @override
  String get seasonWholeYear => 'Toute l\'année';

  @override
  String get seasonSpring => 'Printemps';

  @override
  String get seasonSummer => 'Été';

  @override
  String get seasonAutumn => 'Automne';

  @override
  String get seasonWinter => 'Hiver';

  @override
  String get seasonCustom => 'Mois personnalisés';

  @override
  String get taskNotes => 'Notes';

  @override
  String get taskNextDates => 'Prochaines dates';

  @override
  String get taskHistory => 'Historique';

  @override
  String historyDone(String date) {
    return 'Faite le $date';
  }

  @override
  String get historySkipped => 'Ignorée';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get pickerDone => 'OK';

  @override
  String get homesArchived => 'Archivés';

  @override
  String get newHome => 'Nouveau logement';

  @override
  String get addHome => 'Ajouter un logement';

  @override
  String get homeName => 'Nom';

  @override
  String get homeCurrency => 'Devise';

  @override
  String get homeHemisphere => 'Hémisphère';

  @override
  String get hemisphereNorth => 'Nord';

  @override
  String get hemisphereSouth => 'Sud';

  @override
  String get homeArchive => 'Archiver ce logement';

  @override
  String get homeUnarchive => 'Remettre ce logement en service';

  @override
  String get homeArchivedNotice =>
      'Ce logement est archivé : il est en lecture seule.';

  @override
  String get homeDelete => 'Supprimer ce logement';

  @override
  String homeDeleteTitle(String home) {
    return 'Supprimer $home ?';
  }

  @override
  String get homeDeleteBody =>
      'Toutes les tâches, pièces, équipements et photos de ce logement sont supprimés de ce téléphone, définitivement. Tapez le nom du logement pour confirmer.';

  @override
  String get homeDeleteConfirm => 'Supprimer définitivement';

  @override
  String get firstHomeName => 'Ma maison';

  @override
  String get errTitleRequired => 'Donnez-lui un nom ou un titre.';

  @override
  String get errTooLong => 'Ce texte est trop long.';

  @override
  String get errIntervalOutOfRange => 'Cet intervalle est hors limites.';

  @override
  String get errSeasonMonths =>
      'Indiquez le premier et le dernier mois de la saison.';

  @override
  String get errFixedNeedsDate =>
      'Une tâche qui se répète à date fixe a besoin d\'une date.';

  @override
  String get errDateOutOfRange =>
      'Choisissez une date à moins de 100 ans d\'aujourd\'hui.';

  @override
  String get errFutureDate => 'La date ne peut pas être dans le futur.';

  @override
  String get errPastDate => 'Choisissez une date qui n\'est pas passée.';

  @override
  String get errAlreadyClosed => 'Cette occurrence est déjà clôturée.';

  @override
  String get errNotClosed =>
      'Seule une tâche marquée comme faite ou ignorée peut être annulée.';

  @override
  String get errNextChanged =>
      'L\'occurrence suivante a été modifiée depuis : l\'annulation n\'est plus possible.';

  @override
  String get errHomeArchived =>
      'Ce logement est archivé : il est en lecture seule.';

  @override
  String get errLastActiveHome =>
      'Le dernier logement actif ne peut être ni archivé ni supprimé.';

  @override
  String get errNameMismatch => 'Tapez le nom exact du logement.';

  @override
  String get errCurrencyInvalid =>
      'Utilisez un code ISO 4217, par exemple EUR.';

  @override
  String get errNotFound => 'Cela n\'existe plus.';

  @override
  String get dueToday => 'Aujourd\'hui';

  @override
  String get dayLate => '1 jour de retard';

  @override
  String daysLate(int count) {
    return '$count jours de retard';
  }

  @override
  String get roomKindLiving => 'Salon';

  @override
  String get roomKindKitchen => 'Cuisine';

  @override
  String get roomKindBathroom => 'Salle de bain';

  @override
  String get roomKindBedroom => 'Chambre';

  @override
  String get roomKindHallway => 'Couloir';

  @override
  String get roomKindOffice => 'Bureau';

  @override
  String get roomKindUtility => 'Local technique';

  @override
  String get roomKindGarage => 'Garage';

  @override
  String get roomKindCellar => 'Cave';

  @override
  String get roomKindAttic => 'Grenier';

  @override
  String get roomKindOutdoor => 'Extérieur';

  @override
  String get roomKindOther => 'Autre';

  @override
  String get itemKindEquipment => 'Équipement';

  @override
  String get itemKindSurface => 'Surface';

  @override
  String get tradePlumber => 'Plombier';

  @override
  String get tradeElectrician => 'Électricien';

  @override
  String get tradeHeatingEngineer => 'Chauffagiste';

  @override
  String get tradeRoofer => 'Couvreur';

  @override
  String get tradeCarpenter => 'Menuisier';

  @override
  String get tradePainter => 'Peintre';

  @override
  String get tradeMason => 'Maçon';

  @override
  String get tradeGardener => 'Jardinier';

  @override
  String get tradeLocksmith => 'Serrurier';

  @override
  String get tradeChimneySweep => 'Ramoneur';

  @override
  String get tradeOther => 'Autre';

  @override
  String get photoCategoryGeneral => 'Général';

  @override
  String get photoCategoryBehindWalls => 'Derrière les murs';

  @override
  String get photoCategoryBefore => 'Avant les travaux';

  @override
  String get photoCategoryAfter => 'Après les travaux';

  @override
  String get photoCategoryOther => 'Autre';

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get tasks => 'Tâches';

  @override
  String get tasksEmpty => 'Aucune tâche pour l\'instant.';

  @override
  String get addRoom => 'Ajouter une pièce';

  @override
  String get newRoom => 'Nouvelle pièce';

  @override
  String get room => 'Pièce';

  @override
  String get roomsEmpty => 'Aucune pièce pour l\'instant.';

  @override
  String roomSummary(String kind, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '$count élément',
    );
    return '$kind · $_temp0';
  }

  @override
  String get editRoom => 'Modifier la pièce';

  @override
  String get deleteRoom => 'Supprimer la pièce';

  @override
  String get deleteRoomBody =>
      'La pièce, ses éléments et leurs photos sont supprimés de ce téléphone. Ses tâches sont conservées, sans pièce.';

  @override
  String get roomMemory => 'Mémoire de la pièce';

  @override
  String get roomMemoryEmpty =>
      'Rien de noté pour l\'instant : peinture, revêtements de sol et de murs, et ce qui passe derrière les murs.';

  @override
  String get editMemory => 'Modifier la mémoire';

  @override
  String get paintColour => 'Couleur de la peinture';

  @override
  String get paintBrand => 'Marque de la peinture';

  @override
  String get paintReference => 'Référence de la peinture';

  @override
  String get paintBatch => 'Lot de la peinture';

  @override
  String get floorCovering => 'Revêtement de sol';

  @override
  String get wallCovering => 'Revêtement de mur';

  @override
  String get memoryNotes => 'Notes de mémoire';

  @override
  String get items => 'Éléments';

  @override
  String get addItem => 'Ajouter un élément';

  @override
  String get itemsEmpty => 'Aucun élément dans cette pièce pour l\'instant.';

  @override
  String get newItem => 'Nouvel élément';

  @override
  String get item => 'Élément';

  @override
  String get editItem => 'Modifier l\'élément';

  @override
  String get deleteItem => 'Supprimer l\'élément';

  @override
  String get deleteItemBody =>
      'L\'élément et ses photos sont supprimés de ce téléphone. Ses tâches sont conservées, sans élément.';

  @override
  String get itemBrand => 'Marque';

  @override
  String get itemModel => 'Modèle';

  @override
  String get itemBrandModel => 'Marque, modèle';

  @override
  String get itemSerial => 'Numéro de série';

  @override
  String get itemInstalledOn => 'Posé le';

  @override
  String get itemWarrantyEndsOn => 'Fin de garantie';

  @override
  String get itemWarranty => 'Garantie';

  @override
  String warrantyEnded(String date) {
    return 'terminée le $date';
  }

  @override
  String warrantyUntil(String date) {
    return 'jusqu\'au $date';
  }

  @override
  String get maintenanceContract => 'Contrat d\'entretien';

  @override
  String get contractProvider => 'Prestataire';

  @override
  String get contractNone => 'Aucun';

  @override
  String get contractNumber => 'Numéro';

  @override
  String get contractLink => 'Lien';

  @override
  String get links => 'Liens';

  @override
  String get linkLabel => 'Étiquette';

  @override
  String get linkAddress => 'Adresse';

  @override
  String get addLink => 'Ajouter un lien';

  @override
  String get removeLink => 'Retirer le lien';

  @override
  String get photos => 'Photos';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get photoTake => 'Prendre une photo';

  @override
  String get photoPick => 'Choisir dans la galerie';

  @override
  String get photosEmpty => 'Aucune photo pour l\'instant.';

  @override
  String photoLabel(String category) {
    return 'Photo, $category';
  }

  @override
  String get photoCategoryField => 'Catégorie';

  @override
  String get photoCaption => 'Légende';

  @override
  String get photoDelete => 'Supprimer la photo';

  @override
  String get photoDeleted => 'Photo supprimée.';

  @override
  String get photoNotHere => 'Photo absente de ce téléphone';

  @override
  String get photoDenied =>
      'Housecairn n\'a pas le droit d\'utiliser l\'appareil photo ou les photos. Vous pouvez l\'autoriser dans les réglages du téléphone.';

  @override
  String get photoNoCamera =>
      'Ce téléphone n\'a pas d\'appareil photo utilisable. Vous pouvez choisir une photo dans la galerie.';

  @override
  String get contractors => 'Intervenants';

  @override
  String get contractorsEmpty =>
      'Aucun intervenant pour l\'instant. Les personnes et les entreprises qui travaillent dans ce logement, avec leur métier et le moyen de les joindre, sont gardées ici.';

  @override
  String get addContractor => 'Ajouter un intervenant';

  @override
  String get newContractor => 'Nouvel intervenant';

  @override
  String get contractor => 'Intervenant';

  @override
  String get contractorTrade => 'Métier';

  @override
  String get contractorTradeOther => 'Quel métier';

  @override
  String get contractorPhone => 'Téléphone';

  @override
  String get contractorEmail => 'Adresse e-mail';

  @override
  String get contractorAddress => 'Adresse';

  @override
  String get contractorNote => 'Note';

  @override
  String get contractorCall => 'Appeler';

  @override
  String get contractorWrite => 'Envoyer un e-mail';

  @override
  String get contractorNoTasks => 'Aucune tâche n\'est liée à cet intervenant.';

  @override
  String get contractorCannotOpen =>
      'Rien sur ce téléphone ne peut ouvrir cela.';

  @override
  String get deleteContractor => 'Supprimer l\'intervenant';

  @override
  String get deleteContractorBody =>
      'L\'intervenant est supprimé de ce téléphone. Les éléments et les tâches qui le citaient sont conservés, sans intervenant.';

  @override
  String get addFromTemplate => 'Ajouter depuis un modèle';

  @override
  String get templatesIntro =>
      'Des tâches courantes d\'un logement, avec un intervalle indicatif et sa source. Cochez celles dont vous avez besoin : chacune devient une tâche du logement courant, que vous pourrez modifier ensuite.';

  @override
  String get templatesRoom => 'Pièce (facultatif)';

  @override
  String get templatesNoRoom => 'Aucune pièce';

  @override
  String get templatesDue => 'Première échéance (facultatif)';

  @override
  String get templatesAdd => 'Ajouter les tâches';

  @override
  String get templatesNoneTicked => 'Cochez au moins un modèle.';

  @override
  String templatesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches ajoutées.',
      one: '1 tâche ajoutée.',
    );
    return '$_temp0';
  }

  @override
  String templateRegion(String region) {
    return 'règle de $region';
  }

  @override
  String templateEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: 'jours',
    );
    return 'tous les $_temp0';
  }

  @override
  String templateEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'toutes les $count semaines',
      one: 'chaque semaine',
    );
    return '$_temp0';
  }

  @override
  String templateEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tous les $count mois',
      one: 'chaque mois',
    );
    return '$_temp0';
  }

  @override
  String templateEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tous les $count ans',
      one: 'chaque année',
    );
    return '$_temp0';
  }

  @override
  String templateMaterial(String list) {
    return 'Matériel : $list.';
  }

  @override
  String templateSource(String title, String url) {
    return 'Intervalle d\'après : $title, $url';
  }

  @override
  String get reminders => 'Rappels';

  @override
  String get remindersExplain =>
      'Le téléphone vous rappelle la veille de l\'échéance d\'une tâche, à 8 h, puis à nouveau jusqu\'à ce qu\'elle soit faite. Rien n\'est envoyé depuis le téléphone.';

  @override
  String get remindersDenied =>
      'Les notifications ne sont pas autorisées. Vous pouvez les autoriser dans les réglages du téléphone.';

  @override
  String reminderTitleHome(String home, String task) {
    return '$home : $task';
  }

  @override
  String reminderSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres tâches à faire',
      one: '1 autre tâche à faire',
    );
    return '$_temp0';
  }

  @override
  String reminderSummaryLineHome(String home, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
    );
    return '$home : $_temp0';
  }

  @override
  String reminderSummaryLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
    );
    return '$_temp0';
  }

  @override
  String get remindersChannel => 'Rappels';

  @override
  String get errPhoneInvalid => 'Chiffres, espaces et + ( ) - . / seulement.';

  @override
  String get errEmailInvalid => 'Saisissez une adresse e-mail valide.';

  @override
  String get errUrlInvalid =>
      'Saisissez une adresse web qui commence par http:// ou https://.';

  @override
  String get errTooManyLinks => '10 liens au plus.';

  @override
  String get errTradeOther => 'Dites de quel métier il s\'agit.';

  @override
  String get errChoiceInvalid => 'Choisissez une valeur dans la liste.';

  @override
  String get errNotInHome => 'Cela n\'est pas dans ce logement.';

  @override
  String get errTooManyPhotos => '30 photos au plus ici.';

  @override
  String get errPhotoUnreadable =>
      'Ce fichier n\'est pas une photo que l\'application sait lire.';

  @override
  String get errPhotoTooLarge =>
      'Cette photo est trop grande (20 Mio au plus).';

  @override
  String get errQuantityInvalid =>
      'Donnez un nombre, avec deux décimales au plus.';

  @override
  String get errQuantityNotPositive =>
      'La quantité doit être supérieure à zéro.';

  @override
  String errStockShort(String available) {
    return 'Il n\'y en a que $available en stock.';
  }

  @override
  String get errUnitOther => 'Dites de quelle unité il s\'agit.';

  @override
  String get errMaterialListed => 'Cet article figure déjà sur la tâche.';

  @override
  String get errTooManyMaterials => 'Une tâche liste 50 articles au plus.';

  @override
  String get stock => 'Matériel';

  @override
  String get stockSearch => 'Rechercher par nom, référence ou fournisseur';

  @override
  String get stockTabAll => 'Tous';

  @override
  String get stockEmpty => 'Aucun article pour l\'instant.';

  @override
  String get stockNoMatch => 'Aucun article ne correspond.';

  @override
  String get addArticle => 'Ajouter un article';

  @override
  String get addArticleButton => 'Ajouter l\'article';

  @override
  String get editArticle => 'Modifier l\'article';

  @override
  String get deleteArticle => 'Supprimer l\'article';

  @override
  String get deleteArticleBody =>
      'L\'article, ses fournisseurs et ses mouvements disparaissent des écrans.';

  @override
  String get articleLowStock => 'Stock bas';

  @override
  String get articleThreshold => 'Seuil';

  @override
  String get articleThresholdHelp =>
      'Le stock est signalé quand il descend à cette quantité ou en dessous.';

  @override
  String get articleUnitPrice => 'Prix unitaire';

  @override
  String articleUnitPriceHelp(String currency) {
    return 'Ce que coûte une unité, en $currency, pour prévoir le coût des tâches qui l\'utilisent.';
  }

  @override
  String get articleReference => 'Référence fabricant';

  @override
  String get articleDimensions => 'Dimensions';

  @override
  String get articleStorage => 'Emplacement de rangement';

  @override
  String get articleStorageHelp => 'Par exemple : garage, deuxième étagère.';

  @override
  String get articleUnit => 'Unité';

  @override
  String get articleUnitOther => 'Quelle unité';

  @override
  String get articleUnitOtherHelp =>
      'Seulement avec l\'unité Autre. Exemple : sac.';

  @override
  String get articleCompatible => 'Éléments compatibles';

  @override
  String get articleCompatibleHelp =>
      'L\'équipement concerné, par exemple la chaudière pour laquelle un filtre est fait.';

  @override
  String get articleNoCompatible => 'Aucun élément compatible choisi.';

  @override
  String get articleRoomsHelp =>
      'Où il sert, en plus des pièces de l\'équipement auquel il convient.';

  @override
  String get articleTasks => 'Demandé par des tâches';

  @override
  String get unitNone => 'Aucune';

  @override
  String get unitPieceChoice => 'Pièce';

  @override
  String get unitLitreChoice => 'Litre';

  @override
  String get unitMetreChoice => 'Mètre';

  @override
  String get unitKilogramChoice => 'Kilogramme';

  @override
  String get unitRollChoice => 'Rouleau';

  @override
  String get unitBoxChoice => 'Boîte';

  @override
  String get unitOtherChoice => 'Autre';

  @override
  String unitPiece(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pièces',
      one: 'pièce',
    );
    return '$_temp0';
  }

  @override
  String unitLitre(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'litres',
      one: 'litre',
    );
    return '$_temp0';
  }

  @override
  String unitMetre(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mètres',
      one: 'mètre',
    );
    return '$_temp0';
  }

  @override
  String unitKilogram(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kilogrammes',
      one: 'kilogramme',
    );
    return '$_temp0';
  }

  @override
  String unitRoll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rouleaux',
      one: 'rouleau',
    );
    return '$_temp0';
  }

  @override
  String unitBox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'boîtes',
      one: 'boîte',
    );
    return '$_temp0';
  }

  @override
  String get recordMovement => 'Enregistrer un mouvement';

  @override
  String get movementQuantity => 'Quantité';

  @override
  String get movementDate => 'Date';

  @override
  String get movementNote => 'Note';

  @override
  String get movementEntryAction => 'Ajouter au stock';

  @override
  String get movementExitAction => 'Sortir du stock';

  @override
  String get movementInventoryAction => 'Fixer le compte';

  @override
  String get movementHelp =>
      '« Fixer le compte » indique ce que vous avez compté sur l\'étagère ; le stock est corrigé en conséquence.';

  @override
  String get movementRecorded => 'Mouvement enregistré.';

  @override
  String get movements => 'Mouvements';

  @override
  String get movementsEmpty => 'Aucun mouvement pour l\'instant.';

  @override
  String get movementEntry => 'Entrée';

  @override
  String get movementExit => 'Sortie';

  @override
  String get movementInventory => 'Inventaire';

  @override
  String movementCounted(String count) {
    return 'compté : $count';
  }

  @override
  String get suppliers => 'Fournisseurs';

  @override
  String get suppliersEmpty => 'Aucun fournisseur pour l\'instant.';

  @override
  String get addSupplier => 'Ajouter un fournisseur';

  @override
  String get addSupplierButton => 'Ajouter le fournisseur';

  @override
  String get editSupplier => 'Modifier le fournisseur';

  @override
  String editSupplierOf(String name) {
    return 'Modifier le fournisseur $name';
  }

  @override
  String get deleteSupplier => 'Supprimer le fournisseur';

  @override
  String get deleteSupplierBody => 'Le fournisseur disparaît de l\'article.';

  @override
  String get supplierReference => 'Référence fournisseur';

  @override
  String get supplierLastPrice => 'Dernier prix payé';

  @override
  String get supplierUrl => 'Lien d\'achat';

  @override
  String supplierHelp(String currency) {
    return 'Le prix est en $currency, la devise du logement. Le lien est seulement enregistré : Housecairn ne l\'ouvre jamais.';
  }

  @override
  String get materials => 'Fournitures';

  @override
  String get materialsEmpty => 'Aucun article demandé.';

  @override
  String get materialsHelp =>
      'Marquer la tâche faite prend ces quantités dans le stock ; annuler les remet.';

  @override
  String materialNeeds(String needed, String stocked) {
    return 'demande $needed · $stocked en stock';
  }

  @override
  String get materialShort => 'Stock insuffisant';

  @override
  String get materialArticle => 'Article';

  @override
  String get addMaterial => 'Ajouter l\'article';

  @override
  String removeMaterial(String name) {
    return 'Retirer $name';
  }

  @override
  String get materialsNoArticle =>
      'Le matériel de ce logement n\'a encore aucun article : ajoutez-en un dans Pièces, Matériel.';

  @override
  String stockShortAfterDone(String list) {
    return 'Stock insuffisant, le stock est à zéro : $list.';
  }

  @override
  String get remove => 'Retirer';

  @override
  String get waysTitle => 'Comment voulez-vous utiliser Housecairn ?';

  @override
  String get waysContinue => 'Continuer';

  @override
  String get waysGroup => 'Utilisation de Housecairn';

  @override
  String get wayAloneTitle => 'Seul sur ce téléphone';

  @override
  String get wayAloneText =>
      'Vos logements restent sur ce téléphone. Rien n\'est envoyé nulle part. Vous pourrez activer le partage plus tard.';

  @override
  String get wayFamilyTitle => 'Synchronisation en famille';

  @override
  String get wayFamilyText =>
      'Partagez vos logements avec les téléphones de votre famille. Tout est chiffré sur vos téléphones avant d\'en sortir : notre serveur ne peut pas le lire. Nécessite un abonnement.';

  @override
  String get wayServerTitle => 'Mon serveur Housecairn';

  @override
  String get wayServerText =>
      'Utilisez les logements de votre propre Housecairn, l\'application web ou le module complémentaire Home Assistant. Votre serveur enregistre vos logements et peut les lire, comme ses pages web. Tout ce qui est sur ce téléphone est conservé sur le serveur ; un achat unique le débloque.';

  @override
  String get wayComingLater => 'Prévu plus tard';

  @override
  String get wayInUse => 'Utilisé';

  @override
  String get errMoneyInvalid => 'Indiquez un montant, par exemple 1250,50.';

  @override
  String get errDecimalMark =>
      'Saisissez un nombre avec un point comme séparateur décimal, par exemple 12.5.';

  @override
  String get errQuoteNeedsLine =>
      'Choisissez la ligne de budget sur laquelle le devis est engagé.';

  @override
  String get errNotInProject =>
      'Cette ligne de budget n\'est pas dans ce projet.';

  @override
  String get errValidityBeforeDate =>
      'La validité ne peut pas finir avant la date du devis.';

  @override
  String get errTooManyFiles => '5 fichiers au plus pour un devis.';

  @override
  String get errFileType => 'Choisissez un PDF ou une photo.';

  @override
  String get errTaskInProject => 'Cette tâche est déjà dans un projet.';

  @override
  String get errOnePlace => 'Choisissez un seul lieu.';

  @override
  String get errReportNotOpen =>
      'Seul un signalement ouvert peut être transformé en tâche.';

  @override
  String get errReportNotClosed =>
      'Seul un signalement classé peut être rouvert.';

  @override
  String get projectInProgress => 'En cours';

  @override
  String get projectPlanned => 'Prévu';

  @override
  String get projectFinished => 'Terminé';

  @override
  String get projectAbandoned => 'Abandonné';

  @override
  String get projectIdea => 'Idée';

  @override
  String get projectsInProgress => 'En cours';

  @override
  String get projectsIdeas => 'Idées';

  @override
  String get projectsFinished => 'Terminés';

  @override
  String get natureMaterial => 'Fournitures';

  @override
  String get natureLabour => 'Main-d\'œuvre';

  @override
  String get natureRental => 'Location';

  @override
  String get natureOther => 'Autre';

  @override
  String get quoteRequested => 'Demandé';

  @override
  String get quoteReceived => 'Reçu';

  @override
  String get quoteAccepted => 'Accepté';

  @override
  String get quoteRejected => 'Refusé';

  @override
  String overBudgetBy(String amount) {
    return 'Budget dépassé de $amount';
  }

  @override
  String amountLeft(String amount) {
    return '$amount restants';
  }

  @override
  String get onBudget => 'Budget respecté';

  @override
  String get amountPlanned => 'Prévu';

  @override
  String get amountCommitted => 'Engagé';

  @override
  String get amountPaid => 'Payé';

  @override
  String get amountGap => 'Écart';

  @override
  String get amountUsed => 'Consommé';

  @override
  String percentUsed(int percent) {
    return '$percent % consommé';
  }

  @override
  String get stillToPay => 'Reste à payer';

  @override
  String get budgetYear => 'Année';

  @override
  String envelopeOfYear(int year) {
    return 'Enveloppe budgétaire $year';
  }

  @override
  String get envelopeNone => 'Aucune enveloppe fixée pour cette année.';

  @override
  String get envelope => 'Enveloppe';

  @override
  String get envelopePlannedActive => 'Prévu pour les projets en cours';

  @override
  String get envelopePaidSoFar => 'Payé jusqu\'ici';

  @override
  String get envelopeLeft => 'Reste dans l\'enveloppe';

  @override
  String overTheEnvelope(String amount) {
    return '$amount (au-delà de l\'enveloppe)';
  }

  @override
  String get envelopeSet => 'Fixer l\'enveloppe';

  @override
  String get projectsEmpty =>
      'Aucun projet pour l\'instant. Un projet est un chantier qui a une fin, comme refaire la salle de bain.';

  @override
  String get projectsNoneInTab => 'Aucun projet dans cet onglet.';

  @override
  String plannedAmount(String amount) {
    return 'Prévu : $amount';
  }

  @override
  String get noBudgetYet => 'Pas encore de budget';

  @override
  String get highPriority => 'Priorité haute';

  @override
  String get lowPriority => 'Priorité basse';

  @override
  String get addProject => 'Ajouter un projet';

  @override
  String get projectGoal => 'Objectif';

  @override
  String get roomsConcerned => 'Pièces concernées';

  @override
  String get editProject => 'Modifier le projet';

  @override
  String get deleteProject => 'Supprimer le projet';

  @override
  String get deleteProjectBody =>
      'Le projet, ses lignes de budget, devis, liens et fichiers disparaissent des écrans ; ses tâches restent.';

  @override
  String get budgetHeading => 'Budget';

  @override
  String get linesEmpty =>
      'Aucune ligne de budget pour l\'instant. Ajoutez-en une pour dire ce que vous prévoyez de dépenser.';

  @override
  String get total => 'Total';

  @override
  String get committedExplained =>
      'L\'engagé est la somme des devis acceptés. L\'écart est le montant prévu moins le plus élevé de l\'engagé et du payé.';

  @override
  String get addLine => 'Ajouter une ligne de budget';

  @override
  String get editLine => 'Modifier la ligne de budget';

  @override
  String get deleteLine => 'Supprimer la ligne de budget';

  @override
  String get deleteLineBody =>
      'Ses devis acceptés reviennent à Reçu, engagés sur rien.';

  @override
  String get lineLabel => 'Libellé';

  @override
  String get nature => 'Nature';

  @override
  String get linePaidHelp =>
      'Ce qui a été payé jusqu\'ici. Le montant engagé vient des devis acceptés.';

  @override
  String amountsAreIn(String currency) {
    return 'Les montants sont en $currency.';
  }

  @override
  String amountIsIn(String currency) {
    return 'Le montant est en $currency.';
  }

  @override
  String get quotes => 'Devis';

  @override
  String get quotesEmpty => 'Aucun devis pour l\'instant.';

  @override
  String get noContractor => 'Aucun intervenant';

  @override
  String committedOn(String line) {
    return 'Engagé sur $line';
  }

  @override
  String get committedOnLabel => 'Engagé sur';

  @override
  String get committedOnHelp =>
      'La ligne de budget sur laquelle un devis accepté est engagé.';

  @override
  String filesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers',
      one: '1 fichier',
    );
    return '$_temp0';
  }

  @override
  String get addLineToAccept =>
      'Ajoutez une ligne de budget pour accepter un devis : son montant y est engagé.';

  @override
  String get addQuote => 'Ajouter un devis';

  @override
  String get editQuote => 'Modifier le devis';

  @override
  String get deleteQuote => 'Supprimer le devis';

  @override
  String get deleteQuoteBody =>
      'Le devis et ses fichiers disparaissent des écrans.';

  @override
  String get amount => 'Montant';

  @override
  String get quoteDate => 'Date';

  @override
  String get validUntil => 'Valable jusqu\'au';

  @override
  String get note => 'Note';

  @override
  String get quoteFiles => 'Fichiers du devis';

  @override
  String get quoteFilesEmpty =>
      'Aucun fichier pour l\'instant : joignez le PDF du devis.';

  @override
  String get attachQuoteFile => 'Joindre un PDF ou une photo';

  @override
  String get quoteFile => 'Fichier d\'un devis';

  @override
  String get photo => 'Photo';

  @override
  String get projectFiles => 'Fichiers';

  @override
  String get tasksHeading => 'Tâches';

  @override
  String get projectTasksEmpty =>
      'Aucune tâche dans ce projet pour l\'instant.';

  @override
  String get taskDoneLabel => 'Fait';

  @override
  String get addProjectTask => 'Ajouter une tâche au projet';

  @override
  String get attachTask => 'Mettre une tâche existante dans le projet';

  @override
  String get inspiration => 'Inspiration';

  @override
  String get linksEmpty => 'Aucun lien pour l\'instant.';

  @override
  String get linkNotRead =>
      'Le lien est gardé tel que vous l\'avez saisi : l\'application ne lit pas les pages. Il s\'ouvre dans le navigateur du téléphone.';

  @override
  String get addLinkButton => 'Ajouter le lien';

  @override
  String get linkPageAddress => 'Adresse de la page';

  @override
  String get linkTitle => 'Titre';

  @override
  String deleteLinkOf(String title) {
    return 'Supprimer $title';
  }

  @override
  String get status => 'Statut';

  @override
  String get priority => 'Priorité';

  @override
  String get priorityHigh => 'Haute';

  @override
  String get priorityNormal => 'Normale';

  @override
  String get priorityLow => 'Basse';

  @override
  String get annualEnvelope => 'Enveloppe annuelle';

  @override
  String get envelopeHelp =>
      'Ce que vous voulez dépenser en travaux cette année, dans la devise du logement. Vide : pas d\'enveloppe.';

  @override
  String get budgetSummary => 'Synthèse';

  @override
  String get budgetRooms => 'Pièces';

  @override
  String get budgetProjects => 'Projets';

  @override
  String get budgetUpkeep => 'Entretien';

  @override
  String envelopeYear(int year) {
    return 'Enveloppe $year';
  }

  @override
  String get envelopeNoneSummary =>
      'Aucune enveloppe fixée pour cette année : les chiffres sont ceux du prévu.';

  @override
  String get spent => 'Dépensé';

  @override
  String get left => 'Reste';

  @override
  String overBy(String amount) {
    return 'Dépassement de $amount';
  }

  @override
  String get spentAgainst => 'Dépensé par rapport à l\'enveloppe ou au prévu';

  @override
  String percentSpent(int percent) {
    return '$percent % dépensé';
  }

  @override
  String percentSpentOver(int percent) {
    return '$percent % dépensé : budget dépassé';
  }

  @override
  String get detailsOfYear => 'Détail de l\'année';

  @override
  String get plannedAll => 'Prévu, projets et entretien';

  @override
  String get leftToPlan => 'Reste à prévoir';

  @override
  String plansExceed(String amount) {
    return '$amount (le prévu dépasse l\'enveloppe)';
  }

  @override
  String plannedPaid(String planned, String paid) {
    return 'prévu $planned, payé $paid';
  }

  @override
  String get spentExplained =>
      'Le dépensé est le plus élevé de l\'engagé et du payé, ligne par ligne.';

  @override
  String byNature(int year) {
    return 'Par nature, $year';
  }

  @override
  String get natureExplained =>
      'Le coût saisi sur une tâche faite est réparti entre Matériel et Main-d\'œuvre comme son estimation ; une tâche sans estimation n\'a pas cette répartition, et son coût est compté dans Autre.';

  @override
  String get byYear => 'Par année';

  @override
  String get last12Months => '12 derniers mois';

  @override
  String rollingExplained(String since, String until) {
    return 'Du $since au $until, l\'entretien qui a été fait. Les paiements des projets n\'ont pas de date : ils ne sont pas dans ce chiffre.';
  }

  @override
  String get whereItStands => 'Où en est le budget';

  @override
  String missingCosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tâches ont été faites sans coût : leurs estimations sont comptées, rien n\'est payé.',
      one: '1 tâche a été faite sans coût : son estimation est comptée, rien n\'est payé.',
    );
    return '$_temp0';
  }

  @override
  String get roomsBudgetEmpty =>
      'Pas encore de budget cette année. Donnez une ligne de budget à un projet, ou une estimation à une tâche.';

  @override
  String get noRoom => 'Aucune pièce';

  @override
  String roomsExplained(int year) {
    return 'Les projets comptés en $year sont répartis à parts égales entre leurs pièces ; l\'entretien d\'une tâche va à sa pièce.';
  }

  @override
  String get projectsEmptyShort => 'Aucun projet pour l\'instant.';

  @override
  String countedIn(int year) {
    return 'Compté en $year';
  }

  @override
  String plannedByTasks(String amount) {
    return 'Prévu par ses tâches : $amount';
  }

  @override
  String get projectsCountedExplained =>
      'Chaque projet est compté dans une seule année, celle où il commence. Un projet abandonné ne prévoit plus rien : ce qui a été payé dessus apparaît comme dépensé sans prévu.';

  @override
  String get projectsPlannedExplained =>
      'Le prévu, ce sont les lignes de budget du projet, et ce que ses tâches prévoient au-delà des lignes de même nature, matériel ou main-d\'œuvre : une estimation qu\'une ligne couvre déjà n\'est pas comptée deux fois.';

  @override
  String get upkeepEmpty =>
      'Aucune tâche n\'a encore d\'estimation ni de coût. Donnez un budget de main-d\'œuvre ou de matériel à une tâche.';

  @override
  String get estimateEachTime => 'Estimation par fois';

  @override
  String get ofWhichStock => 'dont articles en stock';

  @override
  String get costAYear => 'Coût par an';

  @override
  String get paidInAll => 'Payé au total';

  @override
  String unpricedMaterials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count articles n\'ont pas de prix unitaire : ils ne comptent pour rien.',
      one: '1 article n\'a pas de prix unitaire : il ne compte pour rien.',
    );
    return '$_temp0';
  }

  @override
  String unlistedTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches sans estimation ni coût ne sont pas listées.',
      one: '1 tâche sans estimation ni coût n\'est pas listée.',
    );
    return '$_temp0';
  }

  @override
  String get costAYearExplained =>
      'Le coût par an suit la répétition : une tâche tous les 3 ans coûte un tiers de son estimation par an. Une tâche qui ne se répète pas sur le calendrier n\'en a pas.';

  @override
  String get reportOpen => 'Ouvert';

  @override
  String get reportMadeTask => 'Transformé en tâche';

  @override
  String get reportResolved => 'Résolu';

  @override
  String get reportNoAction => 'Classé sans suite';

  @override
  String problemsReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problèmes signalés',
      one: '1 problème signalé',
    );
    return '$_temp0';
  }

  @override
  String get seeReports => 'Voir les signalements';

  @override
  String get reportProblem => 'Signaler un problème';

  @override
  String get reports => 'Signalements';

  @override
  String get reportsOpen => 'Ouverts';

  @override
  String get reportsClosed => 'Classés';

  @override
  String get reportsAll => 'Tous';

  @override
  String get reportsEmpty => 'Rien à traiter.';

  @override
  String get reportWhere => 'Où ?';

  @override
  String get reportWhereFact => 'Où';

  @override
  String get reportedOn => 'Signalé le';

  @override
  String get closedOn => 'Classé le';

  @override
  String get reportTask => 'Tâche';

  @override
  String get reportPhoto => 'Photo du problème';

  @override
  String get makeItATask => 'En faire une tâche';

  @override
  String get markResolved => 'Marquer comme résolu';

  @override
  String get closeWithoutAction => 'Classer sans suite';

  @override
  String get reopen => 'Rouvrir';

  @override
  String get sendReport => 'Envoyer le signalement';

  @override
  String get whatIsWrong => 'Qu\'est-ce qui ne va pas ?';

  @override
  String get errSayWhatIsWrong => 'Dites ce qui ne va pas.';

  @override
  String get photoChosen => 'Photo ajoutée : en choisir une autre';

  @override
  String get materialBudget => 'Budget matériel';

  @override
  String get labourBudget => 'Budget main d\'œuvre';

  @override
  String taskBudgetHelp(String currency) {
    return 'Ce qu\'une fois de la tâche doit coûter, en $currency. Vide : pas d\'estimation.';
  }

  @override
  String get realCostTitle => 'Coût réel';

  @override
  String realCost(String amount) {
    return 'Coût réel : $amount';
  }

  @override
  String get costNotTyped => 'Aucun coût saisi : touchez pour l\'indiquer';

  @override
  String get paintArticle => 'Peinture restante en stock';

  @override
  String get paintArticleNone => 'Aucune';

  @override
  String get tasksTabAll => 'Toutes';

  @override
  String get tasksTitle => 'Tâches';

  @override
  String get tasksToDo => 'À faire';

  @override
  String get tasksDoneFilter => 'Faites';

  @override
  String get tasksAllRooms => 'Toutes les pièces';

  @override
  String get tasksNone => 'Rien à faire. Ajoutez une tâche pour commencer.';

  @override
  String tasksHidden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches sont masquées jusqu\'à ce que leur date approche.',
      one: '$count tâche est masquée jusqu\'à ce que sa date approche.',
    );
    return '$_temp0';
  }

  @override
  String get tasksShowHidden => 'Les afficher';

  @override
  String get pagePrevious => 'Précédent';

  @override
  String get pageNext => 'Suivant';

  @override
  String pageOf(int number, int total) {
    return 'Page $number sur $total';
  }

  @override
  String filtersCount(int count) {
    return 'Filtres ($count)';
  }

  @override
  String get filtersClearAll => 'Effacer les filtres';

  @override
  String get searchClear => 'Effacer la recherche';

  @override
  String get tasksSearchLabel => 'Rechercher par tâche, pièce ou élément';

  @override
  String get historyFilters => 'Filtres';

  @override
  String get historySearch => 'Rechercher';

  @override
  String get historyAllItems => 'Tous les éléments';

  @override
  String get historyEveryone => 'Tout le monde';

  @override
  String get historyOutcome => 'Résultat';

  @override
  String get historyDoneOrSkipped => 'Faites ou ignorées';

  @override
  String get historyOutcomeDone => 'Faites';

  @override
  String get historyOutcomeSkipped => 'Ignorée';

  @override
  String get historyFrom => 'Du';

  @override
  String get historyTo => 'Au';

  @override
  String get historyClear => 'Effacer';

  @override
  String get historyNothingMatches => 'Rien ne correspond.';

  @override
  String get historyNothingDone => 'Rien de fait pour l\'instant.';

  @override
  String historyEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '$count entrée',
    );
    return '$_temp0';
  }

  @override
  String historyCost(String total, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '$count entrée',
    );
    return 'coût réel : $total, saisi sur $_temp0';
  }

  @override
  String get seasonSection => 'De saison';

  @override
  String get taskDelete => 'Supprimer la tâche';

  @override
  String taskDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get taskDeleteBody =>
      'La tâche, son historique et ses fichiers disparaissent des écrans.';

  @override
  String get taskDuration => 'Durée estimée';

  @override
  String get taskDurationUnit => 'Unité de la durée';

  @override
  String get unitMinutes => 'minutes';

  @override
  String get unitHours => 'heures';

  @override
  String get taskHideDays => 'Masquer jusqu\'à ce nombre de jours avant';

  @override
  String get taskHideDaysHelp => '0 affiche la tâche dès qu\'elle existe.';

  @override
  String get errHideDays => 'Indiquez un nombre de jours de 0 à 365.';

  @override
  String get errDuration =>
      'Indiquez une durée d\'au moins 1 et d\'un an au plus.';

  @override
  String get taskProcedure => 'Comment faire';

  @override
  String get taskAddRoom => 'Ajouter une pièce…';

  @override
  String get taskNewRoom => 'Nouvelle pièce';

  @override
  String get taskNewRoomName => 'Nom de la nouvelle pièce';

  @override
  String get taskNewRoomKind => 'Type de pièce';

  @override
  String get taskAddItem => 'Ajouter un élément…';

  @override
  String get taskNewItem => 'Nouvel élément';

  @override
  String get taskNewItemName => 'Nom du nouvel élément';

  @override
  String get taskAddContractor => 'Ajouter un intervenant…';

  @override
  String get taskNewContractor => 'Nouvel intervenant';

  @override
  String get taskNewContractorName => 'Nom du nouvel intervenant';

  @override
  String get taskPostponedPill => 'Reportée';

  @override
  String get taskHighPriority => 'Priorité haute';

  @override
  String get taskLowPriority => 'Priorité basse';

  @override
  String get taskWhen => 'Quand';

  @override
  String get taskPhotosOfItem => 'Photos de l\'élément';

  @override
  String get taskPhotosOfRoom => 'Photos de la pièce';

  @override
  String get taskAllPhotosOfItem => 'Toutes les photos de l\'élément';

  @override
  String get taskAllPhotosOfRoom => 'Toutes les photos de la pièce';

  @override
  String get occurrenceTitle => 'Détails de ce qui a été fait';

  @override
  String get occurrenceDoneOn => 'Fait le';

  @override
  String get occurrenceDetails => 'Détails';

  @override
  String get taskEditTask => 'Modifier la tâche';

  @override
  String get taskAddTitle => 'Ajouter une tâche';

  @override
  String get taskDueOn => 'Échéance';

  @override
  String get taskPostponedFrom => 'Reportée depuis le';

  @override
  String get taskHiddenUntil => 'Masquée jusqu\'à';

  @override
  String taskHiddenDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jours avant la date',
      one: '$n jour avant la date',
    );
    return '$_temp0';
  }

  @override
  String get taskThen => 'Ensuite';

  @override
  String get taskDetails => 'Détails';

  @override
  String get taskCost => 'Coût';

  @override
  String get taskOfWhichStock => 'Dont articles en stock';

  @override
  String get taskPaidSoFar => 'Payé jusqu\'ici';

  @override
  String get taskWho => 'Qui';

  @override
  String get taskTimeAndBudget => 'Durée et budget';

  @override
  String repeatEveryDay(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Tous les $n jours',
      one: 'Tous les jours',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeek(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Toutes les $n semaines',
      one: 'Toutes les semaines',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonth(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Tous les $n mois',
      one: 'Tous les mois',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Tous les $n ans',
      one: 'Tous les ans',
    );
    return '$_temp0';
  }

  @override
  String repeatDaysAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jours après la dernière fois',
      one: 'Un jour après la dernière fois',
    );
    return '$_temp0';
  }

  @override
  String repeatWeeksAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n semaines après la dernière fois',
      one: 'Une semaine après la dernière fois',
    );
    return '$_temp0';
  }

  @override
  String repeatMonthsAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mois après la dernière fois',
      one: 'Un mois après la dernière fois',
    );
    return '$_temp0';
  }

  @override
  String repeatYearsAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ans après la dernière fois',
      one: 'Un an après la dernière fois',
    );
    return '$_temp0';
  }

  @override
  String repeatMonths(String start, String end) {
    return 'de $start à $end';
  }

  @override
  String durationMin(int n) {
    return '$n min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours h $minutes';
  }

  @override
  String durationDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jours',
      one: '$n jour',
    );
    return '$_temp0';
  }

  @override
  String durationWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n semaines',
      one: '$n semaine',
    );
    return '$_temp0';
  }

  @override
  String durationMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mois',
      one: '$n mois',
    );
    return '$_temp0';
  }

  @override
  String durationYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ans',
      one: '$n an',
    );
    return '$_temp0';
  }

  @override
  String get taskAddSubmit => 'Ajouter la tâche';

  @override
  String get unitMillilitreChoice => 'Millilitre (mL)';

  @override
  String get unitMillilitre => 'mL';

  @override
  String get errWarrantyDuration => 'Une garantie dure de 1 à 99 mois ou ans.';

  @override
  String get equipmentTab => 'Équipements';

  @override
  String get itemsSearch =>
      'Rechercher par nom, marque, modèle ou numéro de série';

  @override
  String get itemsEveryRoom => 'Toutes les pièces';

  @override
  String itemsNext(String title) {
    return 'Prochaine : $title';
  }

  @override
  String get itemsNoTask => 'Aucune tâche à venir';

  @override
  String itemsWarrantyUntil(String date) {
    return 'garantie jusqu\'au $date';
  }

  @override
  String itemsWarrantyEnded(String date) {
    return 'garantie terminée le $date';
  }

  @override
  String get itemsAllEmpty =>
      'Aucun élément pour l\'instant. Ajoutez-en un depuis la page d\'une pièce.';

  @override
  String get itemsEmptyShort => 'Aucun élément pour l\'instant.';

  @override
  String get itemsNoMatch => 'Aucun élément ne correspond.';

  @override
  String get itemManufacturerWarranty => 'Garantie constructeur';

  @override
  String get itemPurchasedOn => 'Acheté le';

  @override
  String get warrantyDuration => 'Garantie : durée';

  @override
  String get warrantyDurationUnit => 'Garantie : en';

  @override
  String get warrantyProvider => 'Garantie : donnée par';

  @override
  String get warrantyProviderName =>
      'Garantie : nom du fabricant ou du magasin';

  @override
  String get warrantyStartsOn => 'Garantie : départ le';

  @override
  String get warrantyMonthsChoice => 'mois';

  @override
  String get warrantyYearsChoice => 'ans';

  @override
  String get warrantyByManufacturer => 'Le fabricant';

  @override
  String get warrantyByShop => 'Le magasin';

  @override
  String warrantyMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '$count mois',
    );
    return '$_temp0';
  }

  @override
  String warrantyYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '$count an',
    );
    return '$_temp0';
  }

  @override
  String warrantyFrom(String date) {
    return 'depuis le $date';
  }

  @override
  String get warrantyDurationHelp =>
      'La garantie du fabricant ou du magasin, en mois ou en années.';

  @override
  String get warrantyProviderNameHelp =>
      'Exemple : Acme, ou le magasin où vous l\'avez acheté.';

  @override
  String get warrantyStartsOnHelp => 'Vide : à partir de la date d\'achat.';

  @override
  String get warrantyEndsOnHelp =>
      'Calculée à partir du départ et de la durée. Ne la saisissez que si vous ne les connaissez pas.';

  @override
  String get saved => 'Enregistré';

  @override
  String get serverAddressHelp =>
      'Saisissez l\'adresse de votre Housecairn : l\'application web, ou le port du module Home Assistant. Vous vous connectez ensuite sur la page de votre serveur, dans le navigateur.';

  @override
  String get serverAddressLabel => 'Adresse du serveur';

  @override
  String get serverAddressInvalid =>
      'Ce n\'est pas l\'adresse d\'un serveur. Saisissez-la sous la forme https://housecairn.example.com.';

  @override
  String get serverHttpNeedsLocalIp =>
      'Utilisez https://. Le simple http:// ne marche qu\'avec l\'adresse IP d\'un serveur de votre réseau, jamais avec un nom, même terminé par .local.';

  @override
  String get serverHttpWarning =>
      'Cette connexion n\'est pas chiffrée : toute personne sur ce réseau peut lire ce que le téléphone envoie, et l\'accès à votre serveur. Ne l\'utilisez que sur votre propre réseau.';

  @override
  String get serverHttpContinue => 'Continuer sans chiffrement';

  @override
  String get serverSignIn => 'Se connecter';

  @override
  String get serverSigningIn =>
      'Connectez-vous sur la page de votre serveur dans le navigateur, puis revenez ici.';

  @override
  String get serverConfirmTitle => 'Confirmation';

  @override
  String get serverSeesEverything =>
      'Ce serveur verra tout de ces logements : tâches, pièces, notes, montants et photos. Tout comme les personnes qui l\'administrent, les membres de ces logements sur ce serveur, et ses sauvegardes. Ne continuez qu\'avec un serveur de confiance.';

  @override
  String get serverHomesHeading => 'Logements de cet accès';

  @override
  String get serverNoHomes =>
      'Cet accès ne couvre aucun logement. Choisissez-en au moins un sur la page de votre serveur.';

  @override
  String get serverReadOnly => 'Lecture seule';

  @override
  String get serverNotEncrypted => 'Non chiffré';

  @override
  String get serverConnect => 'Se connecter';

  @override
  String get serverCancel => 'Annuler';

  @override
  String serverTooOld(String version) {
    return 'Ce serveur est trop ancien pour l\'application. Mettez-le à jour vers Housecairn $version ou plus récent.';
  }

  @override
  String get serverMobileAppOff =>
      'Ce serveur n\'autorise pas l\'application mobile. Son administrateur peut l\'activer dans les réglages de l\'instance.';

  @override
  String get serverSignInCancelled =>
      'La connexion a été annulée sur la page du serveur.';

  @override
  String get serverSignInFailed => 'La connexion n\'a pas abouti. Réessayez.';

  @override
  String get serverInsecureRefused =>
      'Le serveur refuse cette connexion sans chiffrement. Utilisez son adresse en https://.';

  @override
  String get serverDisconnected =>
      'Ce téléphone a été déconnecté du serveur. Reconnectez-vous pour reprendre la synchronisation ; vos logements restent sur ce téléphone.';

  @override
  String get serverUpdateApp =>
      'Le serveur demande une version plus récente de l\'application avant que ce téléphone puisse envoyer ses modifications.';

  @override
  String get serverCertificate =>
      'Le certificat de ce serveur n\'est pas valide. L\'application ne s\'y connecte pas.';

  @override
  String get serverOtherHost =>
      'Le serveur a renvoyé l\'application vers une autre adresse. L\'application ne parle qu\'à l\'adresse que vous avez saisie.';

  @override
  String get serverUnreachable =>
      'Le serveur est injoignable. Vérifiez l\'adresse et le réseau.';

  @override
  String get serverDeviceName => 'Application mobile Housecairn';

  @override
  String get errReadOnlyHome =>
      'Vous êtes membre en lecture seule de ce logement sur votre serveur : rien ne peut y être modifié depuis ce téléphone.';

  @override
  String get errOwnersOnly =>
      'Seul un propriétaire de ce logement sur votre serveur peut l\'archiver ou le rétablir.';

  @override
  String get errDeleteOnServer =>
      'Un logement de votre serveur se supprime sur la page web du serveur, par un propriétaire. Il disparaît alors aussi de ce téléphone.';

  @override
  String get wayMoveToServerLater =>
      'Garder les logements de ce téléphone sur un serveur Housecairn viendra avec une prochaine version de l\'application. Rien n\'a changé sur ce téléphone.';

  @override
  String get wayLeaveServerTitle =>
      'Arrêter la synchronisation avec le serveur ?';

  @override
  String get wayLeaveServerText =>
      'Ce téléphone garde une copie de ses logements tels qu\'ils étaient à la dernière synchronisation. Ils ne se synchroniseront plus, et l\'accès de ce téléphone est révoqué sur le serveur.';

  @override
  String wayLeaveServerUnsent(int count) {
    return 'Modifications pas encore envoyées : $count. Elles sont envoyées d\'abord.';
  }

  @override
  String get wayLeaveServerConfirm => 'Arrêter la synchronisation';

  @override
  String get wayLeaveServerUnreachable =>
      'Le serveur est injoignable, ces modifications ne peuvent pas être envoyées. Si vous arrêtez maintenant, elles restent sur ce téléphone seulement :';

  @override
  String get wayLeaveServerDrop =>
      'Arrêter et les garder sur ce téléphone seulement';

  @override
  String wayLeaveServerOther(int count) {
    return 'Autres modifications : $count';
  }

  @override
  String get settingsServerAddress => 'Connecté à';

  @override
  String get settingsServerDisconnect => 'Déconnecter';

  @override
  String get settingsServerDisconnectText =>
      'Révoque l\'accès de ce téléphone. Vos logements y restent.';

  @override
  String get settingsServerDisconnectTitle => 'Se déconnecter de ce serveur ?';

  @override
  String get settingsServerSignInAgain => 'Se reconnecter';

  @override
  String settingsServerReconnectDropped(String names) {
    return 'Ces logements ne font pas partie de l\'accès choisi et quitteront ce téléphone à la prochaine synchronisation : $names';
  }

  @override
  String get syncTitle => 'Synchronisation avec le serveur';

  @override
  String get syncText =>
      'Les modifications de ce téléphone partent vers le serveur peu après, et celles du serveur arrivent quand l\'appli s\'ouvre ou revient au premier plan.';

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncRunning => 'Synchronisation en cours…';

  @override
  String syncLast(String time) {
    return 'Dernière synchronisation : $time';
  }

  @override
  String get syncNever => 'Pas encore synchronisé.';

  @override
  String get syncUnreachable =>
      'Le serveur est injoignable pour l\'instant. Vos modifications restent sur ce téléphone et partiront à la prochaine synchronisation.';

  @override
  String get syncFailed =>
      'La dernière synchronisation n\'a pas abouti. Elle sera retentée automatiquement.';

  @override
  String get syncRefusedTitle => 'Modifications refusées par le serveur';

  @override
  String syncRefusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications refusées par le serveur',
      one: '1 modification refusée par le serveur',
    );
    return '$_temp0';
  }

  @override
  String get syncRefusedHelp =>
      'Le serveur n\'a pas pris ces modifications ; elles sont toujours sur ce téléphone. Renvoyez-en une une fois sa cause corrigée, ou arrêtez de l\'envoyer : le téléphone reprend alors la valeur du serveur.';

  @override
  String get syncSendAgain => 'Renvoyer';

  @override
  String get syncStopSending => 'Ne plus envoyer';

  @override
  String get syncRefusedUnnamed => 'Une modification sans nom';

  @override
  String get syncRefusedForbidden =>
      'Votre rôle dans ce logement sur le serveur ne permet pas cette modification.';

  @override
  String get syncRefusedReference =>
      'Elle désigne un élément qui n\'est pas dans ce logement sur le serveur.';

  @override
  String get syncRefusedClock =>
      'La date de ce téléphone est en avance : vérifiez-la dans les réglages du téléphone, puis renvoyez.';

  @override
  String get syncRefusedIdTaken =>
      'Le serveur a déjà un autre élément avec le même identifiant.';

  @override
  String get syncRefusedMalformed =>
      'Le serveur n\'a pas pu lire cette modification.';

  @override
  String get syncRefusedTooLarge =>
      'Cette modification est trop grande pour le serveur.';

  @override
  String get syncRefusedDevice =>
      'Le serveur connaît ce téléphone sous un autre identifiant. Reconnectez ce téléphone.';

  @override
  String get syncRefusedSignIn =>
      'Ce logement demande une connexion par son propre service de connexion. Reconnectez ce téléphone avec ce service, puis renvoyez.';

  @override
  String get syncRefusedConflict =>
      'Le serveur a déjà reçu d\'autres modifications sous le numéro de cet envoi. Renvoyez.';

  @override
  String syncRefusedOther(String code) {
    return 'Le serveur a refusé cette modification (code $code).';
  }

  @override
  String get syncNoticesTitle => 'Depuis les dernières synchronisations';

  @override
  String syncNoticesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count informations sur la synchronisation',
      one: '1 information sur la synchronisation',
    );
    return '$_temp0';
  }

  @override
  String get syncNoticeUndoReverted =>
      'Une annulation a été reprise : la prochaine échéance de cette tâche a été modifiée entre-temps sur un autre appareil.';

  @override
  String get syncNoticeDropped =>
      'Un élément supprimé sur le serveur a été retiré de ce téléphone.';

  @override
  String get syncNoticesRead => 'Marquer comme lu';

  @override
  String get settingsFilesTitle => 'Photos et fichiers à envoyer';

  @override
  String settingsFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos ou fichiers attendent d\'être envoyés.',
      one: '1 photo ou fichier attend d\'être envoyé.',
      zero: 'Rien n\'attend d\'être envoyé.',
    );
    return '$_temp0';
  }

  @override
  String get settingsFilesSendNow => 'Envoyer maintenant';

  @override
  String get filesRefusedTooLarge =>
      'Un fichier est plus gros que ce que le serveur accepte. Il reste sur ce téléphone.';

  @override
  String get filesRefusedQuota =>
      'Le serveur n\'a plus de place pour d\'autres fichiers. Libérez de l\'espace dessus, puis renvoyez.';

  @override
  String get filesRefusedType =>
      'Le serveur n\'accepte pas ce type de fichier. Il reste sur ce téléphone.';

  @override
  String get filesRefusedMalformed =>
      'Un fichier ne correspondait pas à ce que ce téléphone a envoyé : le serveur ne l\'a pas gardé. Il reste sur ce téléphone.';

  @override
  String get filesRefusedForbidden =>
      'Votre rôle dans ce logement sur le serveur ne permet pas d\'envoyer des fichiers.';

  @override
  String get filesRefusedConflict =>
      'Le serveur a déjà un autre fichier sous le même nom.';

  @override
  String get filesRefusedSeveral =>
      'Le serveur n\'a pas pris certains fichiers.';

  @override
  String filesRefusedOther(String code) {
    return 'Le serveur n\'a pas pris un fichier (code $code).';
  String get roomKindHelp =>
      'Détermine l\'icône et les filtres de la pièce et, plus tard, les modèles de tâches proposés pour elle. Choisissez Autre si aucun ne convient.';

  @override
  String get roomNameHelp =>
      'Se remplit tout seul d\'après le type ; modifiez-le pour nommer la pièce.';

  @override
  String get itemRoomHelp =>
      'Où se trouve l\'élément. Choisissez une autre pièce pour le déplacer.';

  @override
  String get homeCurrencyHelp =>
      'Code ISO 4217 de la devise du budget de ce logement.';

  @override
  String get homeHemisphereHelp =>
      'Où se trouve le logement, pour les saisons : le printemps commence en mars dans l\'hémisphère nord, en septembre dans l\'hémisphère sud.';

  @override
  String get editHome => 'Modifier le logement';

  @override
  String get projectSectionRooms => 'Pièces, durée et saison';

  @override
  String get projectSeason => 'Saison souhaitée';

  @override
  String get projectSeasonAnyTime => 'Toute l\'année';

  @override
  String projectSeasonHemisphereHelp(String hemisphere) {
    return 'La saison suit l\'hémisphère du logement ($hemisphere) : modifiez-le dans les réglages du logement.';
  }

  @override
  String get materialsFormHelp =>
      'Articles dont la tâche a besoin, avec la quantité. Marquer la tâche faite prend ces quantités dans le stock.';

  @override
  String get addMaterialLine => 'Ajouter une ligne';

  @override
  String get removeMaterialLine => 'Retirer cette ligne';

  @override
  String materialsLimit(int max) {
    return 'Une tâche liste $max articles au plus.';
  }

  @override
  String reportPhotoHelpSize(String max) {
    return 'La photo est facultative : une image JPEG, PNG ou WebP, $max au plus. Sa localisation et ses autres métadonnées sont supprimées.';
  }

  @override
  String sizeMegabytes(int count) {
    return '$count Mo';
  }
}
