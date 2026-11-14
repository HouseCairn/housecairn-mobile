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
  String rowInHome(String home, String when) {
    return '$home · $when';
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
}
