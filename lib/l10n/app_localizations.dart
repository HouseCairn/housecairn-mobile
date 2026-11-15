import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Name of the app, shown by the system and on the About screen. A name, not translated.
  ///
  /// In en, this message translates to:
  /// **'Housecairn'**
  String get appTitle;

  /// Section of the bottom bar: what to do, and when. Web catalogue: Aujourd'hui.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// Section of the bottom bar: where, and with what. Web catalogue: Pièces.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get navRooms;

  /// Section of the bottom bar: which works. Web catalogue: Projets.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// Section of the bottom bar: for how much. Web catalogue: Budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// Section of the bottom bar: everything else. Web catalogue: Plus.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Shown in a section that has no content in this early version.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get emptySection;

  /// Heading of the group Help of the More screen. Web catalogue: Aide.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get moreHelpGroup;

  /// Entry of More and title of the About screen. Web catalogue: À propos.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Author attribution required by the NOTICE file (AGPL-3.0 section 7(b)). Never translated, never changed.
  ///
  /// In en, this message translates to:
  /// **'Housecairn, by Robvred'**
  String get aboutAttribution;

  /// Version of the app on the About screen. Web catalogue: version %(version)s.
  ///
  /// In en, this message translates to:
  /// **'version {version}'**
  String aboutVersion(String version);

  /// Licence of the app. Web catalogue: Logiciel libre sous licence AGPL-3.0.
  ///
  /// In en, this message translates to:
  /// **'Free software under the AGPL-3.0 licence.'**
  String get aboutLicence;

  /// Where the source code is, followed by its web address (not a link: the app opens nothing by itself).
  ///
  /// In en, this message translates to:
  /// **'Source code and security reports: {address}'**
  String aboutSource(String address);

  /// How the app is made. Web catalogue: Développé avec un agent IA, sous revue humaine.
  ///
  /// In en, this message translates to:
  /// **'Developed with an AI agent, under human review.'**
  String get aboutAi;

  /// Button that opens the licences of the packages the app includes.
  ///
  /// In en, this message translates to:
  /// **'Open source licences'**
  String get aboutLicences;

  /// Heading of the group Household of the More screen.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get moreHouseholdGroup;

  /// Entry of More and title of the Homes screen. Web catalogue: Logements.
  ///
  /// In en, this message translates to:
  /// **'Homes'**
  String get homes;

  /// Tooltip of the home selector of the app bar.
  ///
  /// In en, this message translates to:
  /// **'Choose a home'**
  String get homeSelectorTooltip;

  /// Choice of the home selector on Today: the tasks of every active home. Web catalogue: Tous les logements.
  ///
  /// In en, this message translates to:
  /// **'All homes'**
  String get allHomes;

  /// Group of Today: tasks whose date has passed. Web catalogue: En retard.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get todayOverdue;

  /// Group of Today: tasks due today. Web catalogue: Aujourd'hui.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayToday;

  /// Group of Today: tasks due within the coming week. Web catalogue: À venir.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get todayComingUp;

  /// Group of Today, and the date of a task that has none. Web catalogue: Sans date.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get todayNoDate;

  /// Shown on Today when no task is due.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do for now.'**
  String get todayEmpty;

  /// Date of a task on its screen and in its reminder (not on Today, where the pill is the date alone).
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// Date of a postponed task on Today, and message after postponing. Web catalogue: Reportée.
  ///
  /// In en, this message translates to:
  /// **'Postponed to {date}'**
  String postponedTo(String date);

  /// Button that marks a task done in one tap. Web catalogue: Fait.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Tooltip of the menu of a task on Today.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get actionMore;

  /// Closes a task without doing it this time. Web catalogue: Ignorer cette fois.
  ///
  /// In en, this message translates to:
  /// **'Skip this time'**
  String get actionSkip;

  /// Moves a task to a later day. Web catalogue: Reporter.
  ///
  /// In en, this message translates to:
  /// **'Postpone'**
  String get actionPostpone;

  /// Message of the undo bar after a task was marked done.
  ///
  /// In en, this message translates to:
  /// **'Done: {title}'**
  String doneMessage(String title);

  /// Message of the undo bar after a task was skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped: {title}'**
  String skippedMessage(String title);

  /// Action of the undo bar: takes back the last done or skip. Web catalogue: Annuler.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Button and title of the screen that creates a task. Web catalogue: Nouvelle tâche.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// Button after a list of tasks that creates a task. Web catalogue: Ajouter une tâche.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get addTask;

  /// Title of the screen of an existing task. Web catalogue: Tâche.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// Field of the task form, the only one required. Web catalogue: Titre.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitle;

  /// Field of the task form. Web catalogue: Échéance.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskDueDate;

  /// Button of the task form that opens the calendar.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get taskChooseDate;

  /// Button of the task form that removes the due date.
  ///
  /// In en, this message translates to:
  /// **'Remove the date'**
  String get taskClearDate;

  /// Field of the task form. Web catalogue: Répétition.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// Choice of Repeat. Web catalogue: Une fois.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatOnce;

  /// Choice of Repeat. Web catalogue: Date fixe.
  ///
  /// In en, this message translates to:
  /// **'Fixed date'**
  String get repeatFixed;

  /// Choice of Repeat. Web catalogue: Après la dernière fois.
  ///
  /// In en, this message translates to:
  /// **'After the last time'**
  String get repeatAfterLast;

  /// Field of the task form: the interval of the repetition. Web catalogue: tous les.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get repeatEvery;

  /// Unit of the repetition. Web catalogue: jours.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get unitDays;

  /// Unit of the repetition. Web catalogue: semaines.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get unitWeeks;

  /// Unit of the repetition. Web catalogue: mois.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get unitMonths;

  /// Unit of the repetition. Web catalogue: ans.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get unitYears;

  /// Field of the task form. Web catalogue: Saison.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// Choice of Season: no season.
  ///
  /// In en, this message translates to:
  /// **'Whole year'**
  String get seasonWholeYear;

  /// Choice of Season. Web catalogue: Printemps.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonSpring;

  /// Choice of Season. Web catalogue: Été.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// Choice of Season. Web catalogue: Automne.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get seasonAutumn;

  /// Choice of Season. Web catalogue: Hiver.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonWinter;

  /// Choice of Season, for a task whose season has its own months. Web catalogue: Mois personnalisés.
  ///
  /// In en, this message translates to:
  /// **'Custom months'**
  String get seasonCustom;

  /// Field of the task form. Web catalogue: Notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get taskNotes;

  /// Heading of the preview of the next five dates of a task that repeats.
  ///
  /// In en, this message translates to:
  /// **'Next dates'**
  String get taskNextDates;

  /// Heading of the past occurrences of a task. Web catalogue: Historique.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get taskHistory;

  /// A past occurrence that was done.
  ///
  /// In en, this message translates to:
  /// **'Done on {date}'**
  String historyDone(String date);

  /// A past occurrence that was skipped. Web catalogue: Ignorée.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get historySkipped;

  /// Button that saves a form. Web catalogue: Enregistrer.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button that closes a dialog without change. Web catalogue: Annuler.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Heading of the archived homes on the Homes screen.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get homesArchived;

  /// Button and title of the screen that creates a home.
  ///
  /// In en, this message translates to:
  /// **'New home'**
  String get newHome;

  /// Button after the list of homes that creates a home. Web catalogue: Ajouter un logement.
  ///
  /// In en, this message translates to:
  /// **'Add a home'**
  String get addHome;

  /// Field of the home form. Web catalogue: Nom.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get homeName;

  /// Field of the home form. Web catalogue: Devise.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get homeCurrency;

  /// Field of the home form: it drives the predefined seasons. Web catalogue: Hémisphère.
  ///
  /// In en, this message translates to:
  /// **'Hemisphere'**
  String get homeHemisphere;

  /// Choice of Hemisphere. Web catalogue: Nord.
  ///
  /// In en, this message translates to:
  /// **'Northern'**
  String get hemisphereNorth;

  /// Choice of Hemisphere. Web catalogue: Sud.
  ///
  /// In en, this message translates to:
  /// **'Southern'**
  String get hemisphereSouth;

  /// Button that archives a home: hidden from Today and the selector, read only.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get homeArchive;

  /// Button that brings an archived home back.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get homeUnarchive;

  /// Shown on the settings of an archived home.
  ///
  /// In en, this message translates to:
  /// **'This home is archived: it is read only.'**
  String get homeArchivedNotice;

  /// Button that deletes a home, after its name is typed. Web catalogue: Supprimer.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homeDelete;

  /// Title of the dialog that deletes a home.
  ///
  /// In en, this message translates to:
  /// **'Delete {home}?'**
  String homeDeleteTitle(String home);

  /// Body of the dialog that deletes a home.
  ///
  /// In en, this message translates to:
  /// **'Every task, room, item and photo of this home is deleted from this phone, for good. Type the name of the home to confirm.'**
  String get homeDeleteBody;

  /// Button of the dialog that deletes a home.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get homeDeleteConfirm;

  /// Name of the home made at the first start; the person can rename it.
  ///
  /// In en, this message translates to:
  /// **'My home'**
  String get firstHomeName;

  /// Error: the name of a home or the title of a task is empty.
  ///
  /// In en, this message translates to:
  /// **'Give it a name or a title.'**
  String get errTitleRequired;

  /// Error: a text is longer than allowed.
  ///
  /// In en, this message translates to:
  /// **'This text is too long.'**
  String get errTooLong;

  /// Error of the task form. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'This interval is out of range.'**
  String get errIntervalOutOfRange;

  /// Error of the task form. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Give the first and the last month of the season.'**
  String get errSeasonMonths;

  /// Error of the task form. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'A task that repeats on a fixed date needs a date.'**
  String get errFixedNeedsDate;

  /// Error: a date too far away. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Choose a date within 100 years of today.'**
  String get errDateOutOfRange;

  /// Error: a completion date in the future. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'The date cannot be in the future.'**
  String get errFutureDate;

  /// Error: a postponement to a past day. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Choose a date that is not in the past.'**
  String get errPastDate;

  /// Error. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'This occurrence is already closed.'**
  String get errAlreadyClosed;

  /// Error. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Only a task that was marked done or skipped can be undone.'**
  String get errNotClosed;

  /// Error of undo. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'The next occurrence has been changed since: it cannot be undone any more.'**
  String get errNextChanged;

  /// Error: a change in an archived home.
  ///
  /// In en, this message translates to:
  /// **'This home is archived: it is read only.'**
  String get errHomeArchived;

  /// Error of archive and delete.
  ///
  /// In en, this message translates to:
  /// **'The last active home can be neither archived nor deleted.'**
  String get errLastActiveHome;

  /// Error of the dialog that deletes a home.
  ///
  /// In en, this message translates to:
  /// **'Type the exact name of the home.'**
  String get errNameMismatch;

  /// Error of the home form. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Use an ISO 4217 code, such as EUR.'**
  String get errCurrencyInvalid;

  /// Error: the row was deleted meanwhile.
  ///
  /// In en, this message translates to:
  /// **'This no longer exists.'**
  String get errNotFound;

  /// Pill of a task due today, on Today and on its screen (web: the pill "Today" of tasks/_due.html).
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dueToday;

  /// Pill of a task due yesterday (web: "%(counter)s day late").
  ///
  /// In en, this message translates to:
  /// **'1 day late'**
  String get dayLate;

  /// Pill of a task due two days ago or more (web: "%(counter)s days late").
  ///
  /// In en, this message translates to:
  /// **'{count} days late'**
  String daysLate(int count);

  /// Kind of a room. Web catalogue: Salon.
  ///
  /// In en, this message translates to:
  /// **'Living room'**
  String get roomKindLiving;

  /// Kind of a room. Web catalogue: Cuisine.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get roomKindKitchen;

  /// Kind of a room. Web catalogue: Salle de bain.
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get roomKindBathroom;

  /// Kind of a room. Web catalogue: Chambre.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get roomKindBedroom;

  /// Kind of a room. Web catalogue: Couloir.
  ///
  /// In en, this message translates to:
  /// **'Hallway'**
  String get roomKindHallway;

  /// Kind of a room. Web catalogue: Bureau.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get roomKindOffice;

  /// Kind of a room. Web catalogue: Local technique.
  ///
  /// In en, this message translates to:
  /// **'Utility room'**
  String get roomKindUtility;

  /// Kind of a room. Web catalogue: Garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get roomKindGarage;

  /// Kind of a room. Web catalogue: Cave.
  ///
  /// In en, this message translates to:
  /// **'Cellar'**
  String get roomKindCellar;

  /// Kind of a room. Web catalogue: Grenier.
  ///
  /// In en, this message translates to:
  /// **'Attic'**
  String get roomKindAttic;

  /// Kind of a room. Web catalogue: Extérieur.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get roomKindOutdoor;

  /// Kind of a room. Web catalogue: Autre.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get roomKindOther;

  /// Kind of an item. Web catalogue: Équipement.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get itemKindEquipment;

  /// Kind of an item. Web catalogue: Surface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get itemKindSurface;

  /// Trade of a contractor. Web catalogue: Plombier.
  ///
  /// In en, this message translates to:
  /// **'Plumber'**
  String get tradePlumber;

  /// Trade of a contractor. Web catalogue: Électricien.
  ///
  /// In en, this message translates to:
  /// **'Electrician'**
  String get tradeElectrician;

  /// Trade of a contractor. Web catalogue: Chauffagiste.
  ///
  /// In en, this message translates to:
  /// **'Heating engineer'**
  String get tradeHeatingEngineer;

  /// Trade of a contractor. Web catalogue: Couvreur.
  ///
  /// In en, this message translates to:
  /// **'Roofer'**
  String get tradeRoofer;

  /// Trade of a contractor. Web catalogue: Menuisier.
  ///
  /// In en, this message translates to:
  /// **'Carpenter'**
  String get tradeCarpenter;

  /// Trade of a contractor. Web catalogue: Peintre.
  ///
  /// In en, this message translates to:
  /// **'Painter'**
  String get tradePainter;

  /// Trade of a contractor. Web catalogue: Maçon.
  ///
  /// In en, this message translates to:
  /// **'Mason'**
  String get tradeMason;

  /// Trade of a contractor. Web catalogue: Jardinier.
  ///
  /// In en, this message translates to:
  /// **'Gardener'**
  String get tradeGardener;

  /// Trade of a contractor. Web catalogue: Serrurier.
  ///
  /// In en, this message translates to:
  /// **'Locksmith'**
  String get tradeLocksmith;

  /// Trade of a contractor. Web catalogue: Ramoneur.
  ///
  /// In en, this message translates to:
  /// **'Chimney sweep'**
  String get tradeChimneySweep;

  /// Trade of a contractor. Web catalogue: Autre.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get tradeOther;

  /// Category of a photo. Web catalogue: Général.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get photoCategoryGeneral;

  /// Category of a photo. Web catalogue: Derrière les murs.
  ///
  /// In en, this message translates to:
  /// **'Behind the walls'**
  String get photoCategoryBehindWalls;

  /// Category of a photo. Web catalogue: Avant les travaux.
  ///
  /// In en, this message translates to:
  /// **'Before the work'**
  String get photoCategoryBefore;

  /// Category of a photo. Web catalogue: Après les travaux.
  ///
  /// In en, this message translates to:
  /// **'After the work'**
  String get photoCategoryAfter;

  /// Category of a photo. Web catalogue: Autre.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get photoCategoryOther;

  /// Label of the name field of a room, an item or a contractor.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// Label of the kind of a room or an item. Web catalogue: Type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// Label of a notes field. Web catalogue: Notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// Button that opens the form of what is shown. Web catalogue: Modifier.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button that deletes what is shown. Web catalogue: Supprimer.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Heading of the tasks of a room, an item or a contractor. Web catalogue: Tâches.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Shown when a room or an item has no task.
  ///
  /// In en, this message translates to:
  /// **'No task yet.'**
  String get tasksEmpty;

  /// Button that creates a room. Web catalogue: Ajouter une pièce.
  ///
  /// In en, this message translates to:
  /// **'Add a room'**
  String get addRoom;

  /// Title of the form that creates a room.
  ///
  /// In en, this message translates to:
  /// **'New room'**
  String get newRoom;

  /// Title of the screen of a room and label of the room of a task. Web catalogue: Pièce.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// Shown when a home has no room. Web catalogue: Aucune pièce pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'No room yet.'**
  String get roomsEmpty;

  /// Second line of a room in the list: its kind and how many items it has.
  ///
  /// In en, this message translates to:
  /// **'{kind} · {count, plural, one{{count} item} other{{count} items}}'**
  String roomSummary(String kind, int count);

  /// Button that opens the form of a room. Web catalogue: Modifier la pièce.
  ///
  /// In en, this message translates to:
  /// **'Edit the room'**
  String get editRoom;

  /// Button and title of the confirmation that deletes a room. Web catalogue: Supprimer la pièce.
  ///
  /// In en, this message translates to:
  /// **'Delete the room'**
  String get deleteRoom;

  /// Text of the confirmation that deletes a room.
  ///
  /// In en, this message translates to:
  /// **'The room, its items and their photos are deleted from this phone. Its tasks are kept, with no room.'**
  String get deleteRoomBody;

  /// Heading of what was used and fitted in a room. Web catalogue: Mémoire de la pièce.
  ///
  /// In en, this message translates to:
  /// **'Room memory'**
  String get roomMemory;

  /// Shown when a room has no memory. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Nothing noted yet: paint, floor and wall coverings, and what runs behind the walls.'**
  String get roomMemoryEmpty;

  /// Field of the room memory. Web catalogue: Couleur de la peinture.
  ///
  /// In en, this message translates to:
  /// **'Paint colour'**
  String get paintColour;

  /// Field of the room memory. Web catalogue: Marque de la peinture.
  ///
  /// In en, this message translates to:
  /// **'Paint brand'**
  String get paintBrand;

  /// Field of the room memory. Web catalogue: Référence de la peinture.
  ///
  /// In en, this message translates to:
  /// **'Paint reference'**
  String get paintReference;

  /// Field of the room memory. Web catalogue: Lot de la peinture.
  ///
  /// In en, this message translates to:
  /// **'Paint batch'**
  String get paintBatch;

  /// Field of the room memory. Web catalogue: Revêtement de sol.
  ///
  /// In en, this message translates to:
  /// **'Floor covering'**
  String get floorCovering;

  /// Field of the room memory. Web catalogue: Revêtement de mur.
  ///
  /// In en, this message translates to:
  /// **'Wall covering'**
  String get wallCovering;

  /// Field of the room memory. Web catalogue: Notes de mémoire.
  ///
  /// In en, this message translates to:
  /// **'Memory notes'**
  String get memoryNotes;

  /// Heading of the items of a room. Web catalogue: Éléments.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// Button that creates an item. Web catalogue: Ajouter un élément.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get addItem;

  /// Shown when a room has no item. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'No item in this room yet.'**
  String get itemsEmpty;

  /// Title of the form that creates an item.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newItem;

  /// Title of the screen of an item. Web catalogue: Élément.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// Button that opens the form of an item. Web catalogue: Modifier l'élément.
  ///
  /// In en, this message translates to:
  /// **'Edit the item'**
  String get editItem;

  /// Button and title of the confirmation that deletes an item. Web catalogue: Supprimer l'élément.
  ///
  /// In en, this message translates to:
  /// **'Delete the item'**
  String get deleteItem;

  /// Text of the confirmation that deletes an item.
  ///
  /// In en, this message translates to:
  /// **'The item and its photos are deleted from this phone. Its tasks are kept, with no item.'**
  String get deleteItemBody;

  /// Field of an item.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get itemBrand;

  /// Field of an item.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get itemModel;

  /// Line of an item that has a brand or a model. Web catalogue: Marque, modèle.
  ///
  /// In en, this message translates to:
  /// **'Brand, model'**
  String get itemBrandModel;

  /// Field of an item. Web catalogue: Numéro de série.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get itemSerial;

  /// Field of an item. Web catalogue: Posé le.
  ///
  /// In en, this message translates to:
  /// **'Installed on'**
  String get itemInstalledOn;

  /// Field of an item. Web catalogue: fin de garantie.
  ///
  /// In en, this message translates to:
  /// **'Warranty ends on'**
  String get itemWarrantyEndsOn;

  /// Line of an item that has a warranty. Web catalogue: Garantie.
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get itemWarranty;

  /// Pill of an item whose warranty ended. Web catalogue: terminée le.
  ///
  /// In en, this message translates to:
  /// **'ended on {date}'**
  String warrantyEnded(String date);

  /// Pill of an item under warranty. Web catalogue: jusqu'au.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String warrantyUntil(String date);

  /// Heading of the contract of an item. Web catalogue: Contrat d'entretien.
  ///
  /// In en, this message translates to:
  /// **'Maintenance contract'**
  String get maintenanceContract;

  /// Field of the contract of an item: one of the contractors of the home.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get contractProvider;

  /// Choice of no contractor.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get contractNone;

  /// Field of the contract of an item.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get contractNumber;

  /// Field of the contract of an item.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get contractLink;

  /// Heading of the links of an item. Web catalogue: Liens.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// Field of a link.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get linkLabel;

  /// Field of a link: the web address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get linkAddress;

  /// Button that adds a link to an item.
  ///
  /// In en, this message translates to:
  /// **'Add a link'**
  String get addLink;

  /// Button that removes a link of an item.
  ///
  /// In en, this message translates to:
  /// **'Remove the link'**
  String get removeLink;

  /// Heading of the photos of a room or an item. Web catalogue: Photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// Button that adds a photo. Web catalogue: Ajouter une photo.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// Choice of the camera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoTake;

  /// Choice of the gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from the gallery'**
  String get photoPick;

  /// Shown when a room or an item has no photo. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'No photo yet.'**
  String get photosEmpty;

  /// Spoken label of a photo in the grid.
  ///
  /// In en, this message translates to:
  /// **'Photo, {category}'**
  String photoLabel(String category);

  /// Field of a photo. Web catalogue: Catégorie.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get photoCategoryField;

  /// Field of a photo. Web catalogue: Légende.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get photoCaption;

  /// Button that deletes a photo.
  ///
  /// In en, this message translates to:
  /// **'Delete the photo'**
  String get photoDelete;

  /// Message after a photo was deleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted.'**
  String get photoDeleted;

  /// Placeholder of a photo whose file is not on this phone.
  ///
  /// In en, this message translates to:
  /// **'Photo not on this phone'**
  String get photoNotHere;

  /// Message when the person refused the camera or the gallery.
  ///
  /// In en, this message translates to:
  /// **'Housecairn is not allowed to use the camera or the photos. You can allow it in the settings of your phone.'**
  String get photoDenied;

  /// Message when the phone has no camera.
  ///
  /// In en, this message translates to:
  /// **'This phone has no camera to use. You can pick a photo from the gallery instead.'**
  String get photoNoCamera;

  /// Entry of More and title of the screen of contractors. Web catalogue: Intervenants.
  ///
  /// In en, this message translates to:
  /// **'Contractors'**
  String get contractors;

  /// Shown when a home has no contractor. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'No contractor yet. People and companies who work in this home, with their trade and how to reach them, are kept here.'**
  String get contractorsEmpty;

  /// Button that creates a contractor. Web catalogue: Ajouter un intervenant.
  ///
  /// In en, this message translates to:
  /// **'Add a contractor'**
  String get addContractor;

  /// Title of the form that creates a contractor.
  ///
  /// In en, this message translates to:
  /// **'New contractor'**
  String get newContractor;

  /// Title of the screen of a contractor.
  ///
  /// In en, this message translates to:
  /// **'Contractor'**
  String get contractor;

  /// Field of a contractor. Web catalogue: Métier.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get contractorTrade;

  /// Field of a contractor with the trade Other. Web catalogue: quel métier.
  ///
  /// In en, this message translates to:
  /// **'Which trade'**
  String get contractorTradeOther;

  /// Field of a contractor. Web catalogue: Téléphone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contractorPhone;

  /// Field of a contractor. Web catalogue: Adresse e-mail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get contractorEmail;

  /// Field of a contractor. Web catalogue: Adresse.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get contractorAddress;

  /// Field of a contractor. Web catalogue: Note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get contractorNote;

  /// Button that calls a contractor.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get contractorCall;

  /// Button that writes to a contractor.
  ///
  /// In en, this message translates to:
  /// **'Send an e-mail'**
  String get contractorWrite;

  /// Shown when no task names a contractor. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'No task is linked to this contractor.'**
  String get contractorNoTasks;

  /// Message when the phone has no app to call or to write.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this phone can open this.'**
  String get contractorCannotOpen;

  /// Button and title of the confirmation that deletes a contractor.
  ///
  /// In en, this message translates to:
  /// **'Delete the contractor'**
  String get deleteContractor;

  /// Text of the confirmation that deletes a contractor.
  ///
  /// In en, this message translates to:
  /// **'The contractor is deleted from this phone. The items and tasks that named them are kept, with no contractor.'**
  String get deleteContractorBody;

  /// Entry of More and title of the screen of task templates. Web catalogue: Ajouter depuis un modèle.
  ///
  /// In en, this message translates to:
  /// **'Add from a template'**
  String get addFromTemplate;

  /// Introduction of the screen of task templates.
  ///
  /// In en, this message translates to:
  /// **'Common tasks of a home, with an indicative interval and its source. Tick those you need: each becomes a task of the current home, which you can change afterwards.'**
  String get templatesIntro;

  /// Field of the screen of task templates: the room the tasks are attached to.
  ///
  /// In en, this message translates to:
  /// **'Room (optional)'**
  String get templatesRoom;

  /// Choice of no room.
  ///
  /// In en, this message translates to:
  /// **'No room'**
  String get templatesNoRoom;

  /// Field of the screen of task templates.
  ///
  /// In en, this message translates to:
  /// **'First due date (optional)'**
  String get templatesDue;

  /// Button of the screen of task templates. Web catalogue: Ajouter les tâches.
  ///
  /// In en, this message translates to:
  /// **'Add the tasks'**
  String get templatesAdd;

  /// Message when no template is ticked.
  ///
  /// In en, this message translates to:
  /// **'Tick at least one template.'**
  String get templatesNoneTicked;

  /// Message after tasks were made from templates.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 task added.} other{{count} tasks added.}}'**
  String templatesAdded(int count);

  /// Mention of a template that is the rule of one country. Web catalogue: règle de.
  ///
  /// In en, this message translates to:
  /// **'rule of {region}'**
  String templateRegion(String region);

  /// Interval of a template.
  ///
  /// In en, this message translates to:
  /// **'every {count, plural, one{day} other{{count} days}}'**
  String templateEveryDays(int count);

  /// Interval of a template.
  ///
  /// In en, this message translates to:
  /// **'every {count, plural, one{week} other{{count} weeks}}'**
  String templateEveryWeeks(int count);

  /// Interval of a template.
  ///
  /// In en, this message translates to:
  /// **'every {count, plural, one{month} other{{count} months}}'**
  String templateEveryMonths(int count);

  /// Interval of a template.
  ///
  /// In en, this message translates to:
  /// **'every {count, plural, one{year} other{{count} years}}'**
  String templateEveryYears(int count);

  /// Line of the notes of a task made from a template. Web catalogue: Matériel.
  ///
  /// In en, this message translates to:
  /// **'Material: {list}.'**
  String templateMaterial(String list);

  /// Line of the notes of a task made from a template. Web catalogue: Intervalle d'après.
  ///
  /// In en, this message translates to:
  /// **'Interval from: {title}, {url}'**
  String templateSource(String title, String url);

  /// Entry of More: notifications of the tasks to do.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// Explains reminders on the Reminders row.
  ///
  /// In en, this message translates to:
  /// **'The phone reminds you the day before a task is due, at 8:00, and again until it is done. Nothing is sent from the phone.'**
  String get remindersExplain;

  /// Message when the person refused notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not allowed. You can allow them in the settings of your phone.'**
  String get remindersDenied;

  /// Title of a reminder when the family has two homes or more.
  ///
  /// In en, this message translates to:
  /// **'{home}: {task}'**
  String reminderTitleHome(String home, String task);

  /// Title of the daily summary of the tasks that have no reminder of their own.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 more task to do} other{{count} more tasks to do}}'**
  String reminderSummaryTitle(int count);

  /// Line of the daily summary: the tasks of one home.
  ///
  /// In en, this message translates to:
  /// **'{home}: {count, plural, one{1 task} other{{count} tasks}}'**
  String reminderSummaryLineHome(String home, int count);

  /// Line of the daily summary with one home.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 task} other{{count} tasks}}'**
  String reminderSummaryLine(int count);

  /// Name of the notification channel on Android.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersChannel;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Digits, spaces and + ( ) - . / only.'**
  String get errPhoneInvalid;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errEmailInvalid;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Enter a web address that starts with http:// or https://.'**
  String get errUrlInvalid;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'At most 10 links.'**
  String get errTooManyLinks;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Say which trade.'**
  String get errTradeOther;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Choose a value from the list.'**
  String get errChoiceInvalid;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'This is not in this home.'**
  String get errNotInHome;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'At most 30 photos here.'**
  String get errTooManyPhotos;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'This file is not a photo the app can read.'**
  String get errPhotoUnreadable;

  /// Message of a refusal. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'This photo is too large (20 MiB at most).'**
  String get errPhotoTooLarge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
