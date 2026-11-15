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
  String get emptySection => 'Rien ici pour l\'instant.';

  @override
  String get moreHelpGroup => 'Aide';

  @override
  String get about => 'À propos';

  @override
  String get aboutAttribution => 'Housecairn, by Robvred';

  @override
  String aboutVersion(String version) {
    return 'version $version';
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
  String get moreHouseholdGroup => 'Foyer';

  @override
  String get homes => 'Logements';

  @override
  String get homeSelectorTooltip => 'Choisir un logement';

  @override
  String get allHomes => 'Tous les logements';

  @override
  String get todayOverdue => 'En retard';

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
  String get homeArchive => 'Archiver';

  @override
  String get homeUnarchive => 'Désarchiver';

  @override
  String get homeArchivedNotice =>
      'Ce logement est archivé : il est en lecture seule.';

  @override
  String get homeDelete => 'Supprimer';

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
}
