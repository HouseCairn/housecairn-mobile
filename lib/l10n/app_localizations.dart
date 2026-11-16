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

  /// Heading of the group Home of More (web: core/more.py, msgctxt "group of More").
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get moreHomeGroup;

  /// Heading of the group Me of More (web: core/more.py).
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get moreMeGroup;

  /// Subtitle of Reports in More (web: core/more.py).
  ///
  /// In en, this message translates to:
  /// **'Problems reported in this home'**
  String get moreReportsText;

  /// Subtitle of Contractors in More (web: core/more.py).
  ///
  /// In en, this message translates to:
  /// **'The people and companies who work on the home'**
  String get moreContractorsText;

  /// Subtitle of My homes in More (web: core/more.py).
  ///
  /// In en, this message translates to:
  /// **'Add a home or open another one'**
  String get moreHomesText;

  /// Entry of Me in More, and title of its screen (web: core/more.py).
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Subtitle of Notifications in More. The web says where and when reminders go; the phone has only its own alarms.
  ///
  /// In en, this message translates to:
  /// **'When the phone reminds you of a task'**
  String get moreNotificationsText;

  /// Help under the photo of the report form (web: reports/report_form.html, without the size, which the phone does not limit).
  ///
  /// In en, this message translates to:
  /// **'A photo is optional. Its location and other metadata are removed.'**
  String get reportPhotoHelp;

  /// Entry of More and title of the Homes screen. Web catalogue: Mes logements.
  ///
  /// In en, this message translates to:
  /// **'My homes'**
  String get homes;

  /// The name beside the cairn in the bar of a section root, and the label of the brand for screen readers (web: shell/brand.html, instance name). A name, not translated; written HouseCairn here, Housecairn (appTitle) in running text.
  ///
  /// In en, this message translates to:
  /// **'HouseCairn'**
  String get brandName;

  /// Tooltip and label of the help button of the app bar, which opens the page of the documentation that describes the screen. Web catalogue: Aide sur cette page.
  ///
  /// In en, this message translates to:
  /// **'Help for this page'**
  String get helpTooltip;

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

  /// Button of the date or list picker of iOS that keeps the choice (design lot D5). The word iOS shows in that place: OK in French.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get pickerDone;

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

  /// Refusal: a quantity or an amount that is not a number of the model (max_digits 10, decimal_places 2).
  ///
  /// In en, this message translates to:
  /// **'Give a number, with at most two decimals.'**
  String get errQuantityInvalid;

  /// Web catalogue (stock or tasks): La quantité doit être supérieure à zéro.
  ///
  /// In en, this message translates to:
  /// **'The quantity must be more than zero.'**
  String get errQuantityNotPositive;

  /// Web catalogue (stock or tasks): Il n'y en a que %(available)s en stock.
  ///
  /// In en, this message translates to:
  /// **'Only {available} in stock.'**
  String errStockShort(String available);

  /// Web catalogue (stock or tasks): Dites de quelle unité il s'agit.
  ///
  /// In en, this message translates to:
  /// **'Say which unit.'**
  String get errUnitOther;

  /// Web catalogue (stock or tasks): Cet article figure déjà sur la tâche.
  ///
  /// In en, this message translates to:
  /// **'This stock item is already listed on the task.'**
  String get errMaterialListed;

  /// Web catalogue (stock or tasks): Une tâche liste %(max)s articles au plus.
  ///
  /// In en, this message translates to:
  /// **'A task lists at most 50 stock items.'**
  String get errTooManyMaterials;

  /// Title of the stock section, a tab of Rooms as on the web. Web catalogue (stock or tasks): Matériel.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// Web catalogue (stock or tasks): Rechercher par nom, référence ou fournisseur.
  ///
  /// In en, this message translates to:
  /// **'Search by name, reference or supplier'**
  String get stockSearch;

  /// Web catalogue (stock or tasks): Stock bas seulement.
  ///
  /// In en, this message translates to:
  /// **'Low stock only'**
  String get stockLowOnly;

  /// Pill of an article at or below its threshold, in the list. Web catalogue (stock or tasks): Basse.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get stockLow;

  /// Web catalogue (stock or tasks): Aucun article pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'No stock item yet.'**
  String get stockEmpty;

  /// Web catalogue (stock or tasks): Aucun article ne correspond.
  ///
  /// In en, this message translates to:
  /// **'No stock item matches.'**
  String get stockNoMatch;

  /// Web catalogue (stock or tasks): Ajouter un article.
  ///
  /// In en, this message translates to:
  /// **'Add a stock item'**
  String get addArticle;

  /// Web catalogue (stock or tasks): Ajouter l'article.
  ///
  /// In en, this message translates to:
  /// **'Add the stock item'**
  String get addArticleButton;

  /// Web catalogue (stock or tasks): Modifier l'article.
  ///
  /// In en, this message translates to:
  /// **'Edit the stock item'**
  String get editArticle;

  /// Web catalogue (stock or tasks): Supprimer l'article.
  ///
  /// In en, this message translates to:
  /// **'Delete the stock item'**
  String get deleteArticle;

  /// Web catalogue (stock or tasks): L'article, ses fournisseurs et ses mouvements disparaissent des écrans.
  ///
  /// In en, this message translates to:
  /// **'The stock item, its suppliers and its movements disappear from the screens.'**
  String get deleteArticleBody;

  /// Web catalogue (stock or tasks): Stock bas.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get articleLowStock;

  /// Web catalogue (stock or tasks): Seuil.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get articleThreshold;

  /// Web catalogue (stock or tasks): Le stock est signalé quand il descend à cette quantité ou en dessous.
  ///
  /// In en, this message translates to:
  /// **'The stock is flagged when it falls to this quantity or below.'**
  String get articleThresholdHelp;

  /// Web catalogue (stock or tasks): Prix unitaire.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get articleUnitPrice;

  /// Web catalogue (stock or tasks): Ce que coûte une unité, pour prévoir le coût des tâches qui l'utilisent. The app names the currency of the home.
  ///
  /// In en, this message translates to:
  /// **'What one unit costs, in {currency}, to plan the cost of the tasks that use it.'**
  String articleUnitPriceHelp(String currency);

  /// Web catalogue (stock or tasks): Référence fabricant.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer reference'**
  String get articleReference;

  /// Web catalogue (stock or tasks): Dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get articleDimensions;

  /// Web catalogue (stock or tasks): Emplacement de rangement.
  ///
  /// In en, this message translates to:
  /// **'Storage location'**
  String get articleStorage;

  /// Web catalogue (stock or tasks): Par exemple : garage, deuxième étagère.
  ///
  /// In en, this message translates to:
  /// **'For example: garage, second shelf.'**
  String get articleStorageHelp;

  /// Web catalogue (stock or tasks): unité.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get articleUnit;

  /// Web catalogue (stock or tasks): quelle unité.
  ///
  /// In en, this message translates to:
  /// **'Which unit'**
  String get articleUnitOther;

  /// Web catalogue (stock or tasks): Seulement avec l'unité Autre. Exemple : sac.
  ///
  /// In en, this message translates to:
  /// **'Only with the unit Other. Example: bag.'**
  String get articleUnitOtherHelp;

  /// Web catalogue (stock or tasks): Éléments compatibles.
  ///
  /// In en, this message translates to:
  /// **'Compatible items'**
  String get articleCompatible;

  /// Web catalogue (stock or tasks): L'équipement concerné, par exemple la chaudière pour laquelle un filtre est fait.
  ///
  /// In en, this message translates to:
  /// **'The equipment this fits, such as the boiler a filter is made for.'**
  String get articleCompatibleHelp;

  /// Web catalogue (stock or tasks): Aucun élément compatible choisi.
  ///
  /// In en, this message translates to:
  /// **'No compatible item chosen.'**
  String get articleNoCompatible;

  /// Web catalogue (stock or tasks): Où il sert, en plus des pièces de l'équipement auquel il convient.
  ///
  /// In en, this message translates to:
  /// **'Where it is used, besides the rooms of the equipment it fits.'**
  String get articleRoomsHelp;

  /// Web catalogue (stock or tasks): Demandé par des tâches.
  ///
  /// In en, this message translates to:
  /// **'Needed by tasks'**
  String get articleTasks;

  /// The empty choice of the unit list (a dash on the web).
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get unitNone;

  /// Web catalogue (stock or tasks): Pièce.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitPieceChoice;

  /// Web catalogue (stock or tasks): Litre.
  ///
  /// In en, this message translates to:
  /// **'Litre'**
  String get unitLitreChoice;

  /// Web catalogue (stock or tasks): Mètre.
  ///
  /// In en, this message translates to:
  /// **'Metre'**
  String get unitMetreChoice;

  /// Web catalogue (stock or tasks): Kilogramme.
  ///
  /// In en, this message translates to:
  /// **'Kilogram'**
  String get unitKilogramChoice;

  /// Web catalogue (stock or tasks): Rouleau.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get unitRollChoice;

  /// Web catalogue (stock or tasks): Boîte.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get unitBoxChoice;

  /// Web catalogue (stock or tasks): Autre.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get unitOtherChoice;

  /// Unit after a quantity. Web catalogue (stock or tasks): pièce / pièces.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{piece} other{pieces}}'**
  String unitPiece(int count);

  /// Unit after a quantity. Web catalogue (stock or tasks): litre / litres.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{litre} other{litres}}'**
  String unitLitre(int count);

  /// Unit after a quantity. Web catalogue (stock or tasks): mètre / mètres.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{metre} other{metres}}'**
  String unitMetre(int count);

  /// Unit after a quantity. Web catalogue (stock or tasks): kilogramme / kilogrammes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{kilogram} other{kilograms}}'**
  String unitKilogram(int count);

  /// Unit after a quantity. Web catalogue (stock or tasks): rouleau / rouleaux.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{roll} other{rolls}}'**
  String unitRoll(int count);

  /// Unit after a quantity. Web catalogue (stock or tasks): boîte / boîtes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{box} other{boxes}}'**
  String unitBox(int count);

  /// Web catalogue (stock or tasks): Enregistrer un mouvement.
  ///
  /// In en, this message translates to:
  /// **'Record a movement'**
  String get recordMovement;

  /// Web catalogue (stock or tasks): Quantité.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get movementQuantity;

  /// Web catalogue (stock or tasks): Date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get movementDate;

  /// Web catalogue (stock or tasks): Note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get movementNote;

  /// Web catalogue (stock or tasks): Ajouter au stock.
  ///
  /// In en, this message translates to:
  /// **'Add to stock'**
  String get movementEntryAction;

  /// Web catalogue (stock or tasks): Sortir du stock.
  ///
  /// In en, this message translates to:
  /// **'Take from stock'**
  String get movementExitAction;

  /// Web catalogue (stock or tasks): Fixer le compte.
  ///
  /// In en, this message translates to:
  /// **'Set the count'**
  String get movementInventoryAction;

  /// Web catalogue (stock or tasks): « Fixer le compte » indique ce que vous avez compté sur l'étagère ; le stock est corrigé en conséquence.
  ///
  /// In en, this message translates to:
  /// **'Set the count states what you counted on the shelf; the stock is corrected to it.'**
  String get movementHelp;

  /// Web catalogue (stock or tasks): Mouvement enregistré.
  ///
  /// In en, this message translates to:
  /// **'Movement recorded.'**
  String get movementRecorded;

  /// Web catalogue (stock or tasks): Mouvements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get movements;

  /// Web catalogue (stock or tasks): Aucun mouvement pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'No movement yet.'**
  String get movementsEmpty;

  /// Web catalogue (stock or tasks): Entrée.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get movementEntry;

  /// Web catalogue (stock or tasks): Sortie.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get movementExit;

  /// Web catalogue (stock or tasks): Inventaire.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get movementInventory;

  /// Web catalogue (stock or tasks): compté : %(count)s.
  ///
  /// In en, this message translates to:
  /// **'counted {count}'**
  String movementCounted(String count);

  /// Web catalogue (stock or tasks): Fournisseurs.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// Web catalogue (stock or tasks): Aucun fournisseur pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'No supplier yet.'**
  String get suppliersEmpty;

  /// Web catalogue (stock or tasks): Ajouter un fournisseur.
  ///
  /// In en, this message translates to:
  /// **'Add a supplier'**
  String get addSupplier;

  /// Web catalogue (stock or tasks): Ajouter le fournisseur.
  ///
  /// In en, this message translates to:
  /// **'Add the supplier'**
  String get addSupplierButton;

  /// Web catalogue (stock or tasks): Modifier le fournisseur.
  ///
  /// In en, this message translates to:
  /// **'Edit the supplier'**
  String get editSupplier;

  /// Label of the edit button of a supplier, with its name (the web adds it as hidden text).
  ///
  /// In en, this message translates to:
  /// **'Edit the supplier {name}'**
  String editSupplierOf(String name);

  /// Web catalogue (stock or tasks): Supprimer le fournisseur.
  ///
  /// In en, this message translates to:
  /// **'Delete the supplier'**
  String get deleteSupplier;

  /// Web catalogue (stock or tasks): Le fournisseur disparaît de l'article.
  ///
  /// In en, this message translates to:
  /// **'The supplier disappears from the stock item.'**
  String get deleteSupplierBody;

  /// Web catalogue (stock or tasks): Référence fournisseur.
  ///
  /// In en, this message translates to:
  /// **'Supplier reference'**
  String get supplierReference;

  /// Web catalogue (stock or tasks): Dernier prix payé.
  ///
  /// In en, this message translates to:
  /// **'Last price paid'**
  String get supplierLastPrice;

  /// Web catalogue (stock or tasks): Lien d'achat.
  ///
  /// In en, this message translates to:
  /// **'Purchase link'**
  String get supplierUrl;

  /// Web catalogue (stock or tasks): Le prix est en %(currency)s, la devise du logement. Le lien est seulement enregistré : HouseCairn ne l'ouvre jamais.
  ///
  /// In en, this message translates to:
  /// **'The price is in {currency}, the currency of the home. The link is only stored: Housecairn never opens it.'**
  String supplierHelp(String currency);

  /// Web catalogue (stock or tasks): Fournitures.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// Web catalogue (stock or tasks): Aucun article demandé.
  ///
  /// In en, this message translates to:
  /// **'No stock item needed.'**
  String get materialsEmpty;

  /// Web catalogue (stock or tasks): Marquer la tâche faite prend ces quantités dans le stock ; annuler les remet.
  ///
  /// In en, this message translates to:
  /// **'Marking the task done takes these quantities from the stock; undoing puts them back.'**
  String get materialsHelp;

  /// Web catalogue (stock or tasks): demande %(needed)s · %(stocked)s en stock.
  ///
  /// In en, this message translates to:
  /// **'needs {needed} · {stocked} in stock'**
  String materialNeeds(String needed, String stocked);

  /// Web catalogue (stock or tasks): Stock insuffisant.
  ///
  /// In en, this message translates to:
  /// **'Not enough in stock'**
  String get materialShort;

  /// Web catalogue (stock or tasks): Article.
  ///
  /// In en, this message translates to:
  /// **'Stock item'**
  String get materialArticle;

  /// Web catalogue (stock or tasks): Ajouter l'article (task materials).
  ///
  /// In en, this message translates to:
  /// **'Add the stock item'**
  String get addMaterial;

  /// Label of the button that removes an article from a task.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeMaterial(String name);

  /// Shown on a task when the home has no stock item to choose.
  ///
  /// In en, this message translates to:
  /// **'The stock of this home has no item yet: add one in Rooms, Stock.'**
  String get materialsNoArticle;

  /// Web catalogue (stock or tasks): Stock insuffisant, le stock est à zéro : %(list)s.
  ///
  /// In en, this message translates to:
  /// **'Not enough in stock, the stock is at zero: {list}.'**
  String stockShortAfterDone(String list);

  /// Visible text of the button that removes an article from a task; its accessible label names the article (removeMaterial).
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Title of the first-start screen, above the three ways to use the app.
  ///
  /// In en, this message translates to:
  /// **'How do you want to use Housecairn?'**
  String get waysTitle;

  /// Button of the first-start screen: starts with the selected way.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get waysContinue;

  /// Heading of the group of More that shows the way the app is used, and the two others.
  ///
  /// In en, this message translates to:
  /// **'How you use Housecairn'**
  String get waysGroup;

  /// First way to use the app: everything stays on the phone.
  ///
  /// In en, this message translates to:
  /// **'Alone on this phone'**
  String get wayAloneTitle;

  /// Explains the first way (alone on this phone).
  ///
  /// In en, this message translates to:
  /// **'Your homes stay on this phone. Nothing is sent anywhere. You can turn on sharing later.'**
  String get wayAloneText;

  /// Second way to use the app: sync through the end-to-end encrypted relay.
  ///
  /// In en, this message translates to:
  /// **'Family sync'**
  String get wayFamilyTitle;

  /// Explains the second way (family sync through the relay). The relay cannot read the data.
  ///
  /// In en, this message translates to:
  /// **'Share your homes with the phones of your family. Everything is encrypted on your phones before it leaves them: our server cannot read it. Needs a subscription.'**
  String get wayFamilyText;

  /// Third way to use the app: the person's own Housecairn server, web application or Home Assistant add-on.
  ///
  /// In en, this message translates to:
  /// **'My Housecairn server'**
  String get wayServerTitle;

  /// Explains the third way (my Housecairn server). Must say that the server stores and can read the homes, that all the homes of the phone are kept on it, and that a one-time purchase unlocks the way. Never a price.
  ///
  /// In en, this message translates to:
  /// **'Use the homes of your own Housecairn, the web application or the Home Assistant add-on. Your server stores your homes and can read them, like its web pages do. Everything of this phone is kept on the server; a one-time purchase unlocks it.'**
  String get wayServerText;

  /// Label of a way to use the app that is not available yet.
  ///
  /// In en, this message translates to:
  /// **'Coming later'**
  String get wayComingLater;

  /// Label of the way to use the app that this phone is in.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get wayInUse;

  /// Web catalogue (projects, budget or reports): Indiquez un montant, par exemple 1250,50.
  ///
  /// In en, this message translates to:
  /// **'Give an amount of money, such as 1250.50.'**
  String get errMoneyInvalid;

  /// Web catalogue (projects, budget or reports): Choisissez la ligne de budget sur laquelle le devis est engagé.
  ///
  /// In en, this message translates to:
  /// **'Choose the budget line the quote is committed on.'**
  String get errQuoteNeedsLine;

  /// Web catalogue (projects, budget or reports): Cette ligne de budget n'est pas dans ce projet.
  ///
  /// In en, this message translates to:
  /// **'This budget line is not in this project.'**
  String get errNotInProject;

  /// Web catalogue (projects, budget or reports): La validité ne peut pas finir avant la date du devis.
  ///
  /// In en, this message translates to:
  /// **'The validity cannot end before the date of the quote.'**
  String get errValidityBeforeDate;

  /// Web catalogue (projects, budget or reports): %(max)d fichiers au plus pour un devis.
  ///
  /// In en, this message translates to:
  /// **'At most 5 files for a quote.'**
  String get errTooManyFiles;

  /// Refusal: a file of a quote that is neither a PDF nor a photo.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF or a photo.'**
  String get errFileType;

  /// Web catalogue (projects, budget or reports): Cette tâche est déjà dans un projet.
  ///
  /// In en, this message translates to:
  /// **'This task is already in a project.'**
  String get errTaskInProject;

  /// Web catalogue (projects, budget or reports): Choisissez un seul lieu.
  ///
  /// In en, this message translates to:
  /// **'Choose one place.'**
  String get errOnePlace;

  /// Web catalogue (projects, budget or reports): Seul un signalement ouvert peut être transformé en tâche.
  ///
  /// In en, this message translates to:
  /// **'Only an open report can be made into a task.'**
  String get errReportNotOpen;

  /// Web catalogue (projects, budget or reports): Seul un signalement classé peut être rouvert.
  ///
  /// In en, this message translates to:
  /// **'Only a closed report can be reopened.'**
  String get errReportNotClosed;

  /// Web catalogue (projects, budget or reports): En cours. Status of a project.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get projectInProgress;

  /// Web catalogue (projects, budget or reports): Planned (status of a project).
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get projectPlanned;

  /// Web catalogue (projects, budget or reports): Finished (status of a project).
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get projectFinished;

  /// Web catalogue (projects, budget or reports): Abandonné.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get projectAbandoned;

  /// Web catalogue (projects, budget or reports): Idée.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get projectIdea;

  /// Tab of Projects (in progress and planned). Web catalogue (projects, budget or reports): En cours.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get projectsInProgress;

  /// Tab of Projects. Web catalogue (projects, budget or reports): Idées.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get projectsIdeas;

  /// Tab of Projects (finished and abandoned). Web catalogue (projects, budget or reports): Terminés.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get projectsFinished;

  /// Web catalogue (projects, budget or reports): Fournitures.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get natureMaterial;

  /// Web catalogue (projects, budget or reports): Main-d'œuvre.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get natureLabour;

  /// Web catalogue (projects, budget or reports): Location.
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get natureRental;

  /// Web catalogue (projects, budget or reports): Autre.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get natureOther;

  /// Web catalogue (projects, budget or reports): Demandé.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get quoteRequested;

  /// Web catalogue (projects, budget or reports): Reçu.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get quoteReceived;

  /// Web catalogue (projects, budget or reports): Accepté.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get quoteAccepted;

  /// Web catalogue (projects, budget or reports): Refusé.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get quoteRejected;

  /// Web catalogue (projects, budget or reports): Budget dépassé de %(amount)s.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String overBudgetBy(String amount);

  /// Web catalogue (projects, budget or reports): %(amount)s restants.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String amountLeft(String amount);

  /// Web catalogue (projects, budget or reports): Budget respecté.
  ///
  /// In en, this message translates to:
  /// **'On budget'**
  String get onBudget;

  /// Web catalogue (projects, budget or reports): Prévu (context amount).
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get amountPlanned;

  /// Web catalogue (projects, budget or reports): Engagé.
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get amountCommitted;

  /// Web catalogue (projects, budget or reports): Payé.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get amountPaid;

  /// Web catalogue (projects, budget or reports): Consommé.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get amountUsed;

  /// The gauge of a row: engaged against planned. Web: %(percent)s %% used.
  ///
  /// In en, this message translates to:
  /// **'{percent} % used'**
  String percentUsed(int percent);

  /// Web catalogue (projects, budget or reports): Reste à payer.
  ///
  /// In en, this message translates to:
  /// **'Still to pay'**
  String get stillToPay;

  /// Web catalogue (projects, budget or reports): Année.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get budgetYear;

  /// Web catalogue (projects, budget or reports): Enveloppe budgétaire %(year)s.
  ///
  /// In en, this message translates to:
  /// **'Budget envelope {year}'**
  String envelopeOfYear(int year);

  /// Web catalogue (projects, budget or reports): Aucune enveloppe fixée pour cette année.
  ///
  /// In en, this message translates to:
  /// **'No envelope set for this year.'**
  String get envelopeNone;

  /// Web catalogue (projects, budget or reports): Enveloppe.
  ///
  /// In en, this message translates to:
  /// **'Envelope'**
  String get envelope;

  /// Web catalogue (projects, budget or reports): Prévu pour les projets en cours.
  ///
  /// In en, this message translates to:
  /// **'Planned for the projects going on'**
  String get envelopePlannedActive;

  /// Web catalogue (projects, budget or reports): Payé jusqu'ici.
  ///
  /// In en, this message translates to:
  /// **'Paid so far'**
  String get envelopePaidSoFar;

  /// Web catalogue (projects, budget or reports): Reste dans l'enveloppe.
  ///
  /// In en, this message translates to:
  /// **'Left in the envelope'**
  String get envelopeLeft;

  /// Web catalogue (projects, budget or reports): %(amount)s (au-delà de l'enveloppe).
  ///
  /// In en, this message translates to:
  /// **'{amount} (over the envelope)'**
  String overTheEnvelope(String amount);

  /// Web catalogue (projects, budget or reports): Fixer l'enveloppe.
  ///
  /// In en, this message translates to:
  /// **'Set the envelope'**
  String get envelopeSet;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'No project yet. A project is a piece of work with an end, such as redoing the bathroom.'**
  String get projectsEmpty;

  /// Web catalogue (projects, budget or reports): Aucun projet dans cet onglet.
  ///
  /// In en, this message translates to:
  /// **'No project in this tab.'**
  String get projectsNoneInTab;

  /// Web catalogue (projects, budget or reports): Prévu : %(planned)s.
  ///
  /// In en, this message translates to:
  /// **'Planned {amount}'**
  String plannedAmount(String amount);

  /// Web catalogue (projects, budget or reports): Pas encore de budget.
  ///
  /// In en, this message translates to:
  /// **'No budget yet'**
  String get noBudgetYet;

  /// Web catalogue (projects, budget or reports): Priorité haute.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get highPriority;

  /// Web catalogue (projects, budget or reports): Priorité basse.
  ///
  /// In en, this message translates to:
  /// **'Low priority'**
  String get lowPriority;

  /// Web catalogue (projects, budget or reports): Ajouter un projet.
  ///
  /// In en, this message translates to:
  /// **'Add a project'**
  String get addProject;

  /// Field of a project (`goal`).
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get projectGoal;

  /// Web catalogue (projects, budget or reports): Pièces concernées.
  ///
  /// In en, this message translates to:
  /// **'Rooms concerned'**
  String get roomsConcerned;

  /// Web catalogue (projects, budget or reports): Modifier le projet.
  ///
  /// In en, this message translates to:
  /// **'Edit the project'**
  String get editProject;

  /// Web catalogue (projects, budget or reports): Supprimer le projet.
  ///
  /// In en, this message translates to:
  /// **'Delete the project'**
  String get deleteProject;

  /// Body of the confirmation of deleting a project (`delete_project`).
  ///
  /// In en, this message translates to:
  /// **'The project, its budget lines, quotes, links and files disappear from the screens; its tasks stay.'**
  String get deleteProjectBody;

  /// Web catalogue (projects, budget or reports): Budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetHeading;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'No budget line yet. Add one to say what you plan to spend.'**
  String get linesEmpty;

  /// Web catalogue (projects, budget or reports): Total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Committed is the sum of the accepted quotes. The gap is the planned amount less the more of committed and paid.'**
  String get committedExplained;

  /// Web catalogue (projects, budget or reports): Ajouter une ligne de budget.
  ///
  /// In en, this message translates to:
  /// **'Add a budget line'**
  String get addLine;

  /// Web catalogue (projects, budget or reports): Modifier la ligne de budget.
  ///
  /// In en, this message translates to:
  /// **'Edit the budget line'**
  String get editLine;

  /// Web catalogue (projects, budget or reports): Supprimer la ligne de budget.
  ///
  /// In en, this message translates to:
  /// **'Delete the budget line'**
  String get deleteLine;

  /// Body of the confirmation of deleting a budget line (`delete_line`).
  ///
  /// In en, this message translates to:
  /// **'Its accepted quotes go back to Received, committed on nothing.'**
  String get deleteLineBody;

  /// Web catalogue (projects, budget or reports): Libellé.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get lineLabel;

  /// Web catalogue (projects, budget or reports): Nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'What has been paid so far. The committed amount comes from accepted quotes.'**
  String get linePaidHelp;

  /// Web catalogue (projects, budget or reports): Les montants sont en %(currency)s.
  ///
  /// In en, this message translates to:
  /// **'Amounts are in {currency}.'**
  String amountsAreIn(String currency);

  /// Web catalogue (projects, budget or reports): Le montant est en %(currency)s.
  ///
  /// In en, this message translates to:
  /// **'The amount is in {currency}.'**
  String amountIsIn(String currency);

  /// Web catalogue (projects, budget or reports): Devis.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotes;

  /// Web catalogue (projects, budget or reports): Aucun devis pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'No quote yet.'**
  String get quotesEmpty;

  /// Web catalogue (projects, budget or reports): Aucun intervenant.
  ///
  /// In en, this message translates to:
  /// **'No contractor'**
  String get noContractor;

  /// Web catalogue (projects, budget or reports): Engagé sur.
  ///
  /// In en, this message translates to:
  /// **'Committed on {line}'**
  String committedOn(String line);

  /// Web catalogue (projects, budget or reports): Engagé sur.
  ///
  /// In en, this message translates to:
  /// **'Committed on'**
  String get committedOnLabel;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'The budget line an accepted quote is committed on.'**
  String get committedOnHelp;

  /// Number of files of a quote.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 file} other{{count} files}}'**
  String filesCount(int count);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Add a budget line to accept a quote: its amount is committed on it.'**
  String get addLineToAccept;

  /// Web catalogue (projects, budget or reports): Ajouter un devis.
  ///
  /// In en, this message translates to:
  /// **'Add a quote'**
  String get addQuote;

  /// Web catalogue (projects, budget or reports): Modifier le devis.
  ///
  /// In en, this message translates to:
  /// **'Edit the quote'**
  String get editQuote;

  /// Web catalogue (projects, budget or reports): Supprimer le devis.
  ///
  /// In en, this message translates to:
  /// **'Delete the quote'**
  String get deleteQuote;

  /// Body of the confirmation of deleting a quote.
  ///
  /// In en, this message translates to:
  /// **'The quote and its files disappear from the screens.'**
  String get deleteQuoteBody;

  /// Web catalogue (projects, budget or reports): Montant.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Web catalogue (projects, budget or reports): Date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get quoteDate;

  /// Web catalogue (projects, budget or reports): Valable jusqu'au.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntil;

  /// Web catalogue (projects, budget or reports): Note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// Web catalogue (projects, budget or reports): Fichiers du devis.
  ///
  /// In en, this message translates to:
  /// **'Files of the quote'**
  String get quoteFiles;

  /// Empty list of the files of a quote.
  ///
  /// In en, this message translates to:
  /// **'No file yet: attach the PDF of the quote.'**
  String get quoteFilesEmpty;

  /// Button that opens the Files app (iOS) or the document picker (Android).
  ///
  /// In en, this message translates to:
  /// **'Attach a PDF or a photo'**
  String get attachQuoteFile;

  /// Kind of a file of a project.
  ///
  /// In en, this message translates to:
  /// **'File of a quote'**
  String get quoteFile;

  /// Kind of a file of a project.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// Heading of the files of a project.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get projectFiles;

  /// Web catalogue (projects, budget or reports): Tâches.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksHeading;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'No task in this project yet.'**
  String get projectTasksEmpty;

  /// A task of a project with no open occurrence.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskDoneLabel;

  /// Web catalogue (projects, budget or reports): Ajouter une tâche au projet.
  ///
  /// In en, this message translates to:
  /// **'Add a task to the project'**
  String get addProjectTask;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Put an existing task in the project'**
  String get attachTask;

  /// Web catalogue (projects, budget or reports): Inspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get inspiration;

  /// Web catalogue (projects, budget or reports): Aucun lien pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'No link yet.'**
  String get linksEmpty;

  /// Adapted from the web ("this instance does not read the pages"): no network in the app.
  ///
  /// In en, this message translates to:
  /// **'The link is kept as you typed it: the app does not read the pages. It opens in the browser of the phone.'**
  String get linkNotRead;

  /// Web catalogue (projects, budget or reports): Ajouter le lien.
  ///
  /// In en, this message translates to:
  /// **'Add the link'**
  String get addLinkButton;

  /// Web catalogue (projects, budget or reports): Address of the page.
  ///
  /// In en, this message translates to:
  /// **'Address of the page'**
  String get linkPageAddress;

  /// Web catalogue (projects, budget or reports): Titre.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get linkTitle;

  /// Tooltip of the button that deletes a link.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}'**
  String deleteLinkOf(String title);

  /// Web catalogue (projects, budget or reports): Statut.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Web catalogue (projects, budget or reports): Priorité.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// Web catalogue (projects, budget or reports): Haute.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Web catalogue (projects, budget or reports): Normale.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// Web catalogue (projects, budget or reports): Basse.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// Web catalogue (projects, budget or reports): Enveloppe annuelle.
  ///
  /// In en, this message translates to:
  /// **'Annual envelope'**
  String get annualEnvelope;

  /// Web catalogue (projects, budget or reports): (first sentence).
  ///
  /// In en, this message translates to:
  /// **'What you want to spend on work this year, in the currency of the home. Empty: no envelope.'**
  String get envelopeHelp;

  /// Web catalogue (projects, budget or reports): Synthèse.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get budgetSummary;

  /// Web catalogue (projects, budget or reports): Pièces (budget tab).
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get budgetRooms;

  /// Web catalogue (projects, budget or reports): Projets (budget tab).
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get budgetProjects;

  /// Web catalogue (projects, budget or reports): Entretien.
  ///
  /// In en, this message translates to:
  /// **'Upkeep'**
  String get budgetUpkeep;

  /// Web catalogue (projects, budget or reports): Enveloppe %(year)s.
  ///
  /// In en, this message translates to:
  /// **'Envelope {year}'**
  String envelopeYear(int year);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'No envelope set for this year: the figures are those of the plans.'**
  String get envelopeNoneSummary;

  /// Web catalogue (projects, budget or reports): Dépensé.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// Web catalogue (projects, budget or reports): Reste.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// Web catalogue (projects, budget or reports): Dépassement de %(amount)s.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String overBy(String amount);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Spent against the envelope or the plans'**
  String get spentAgainst;

  /// Web: %(percent)s %% spent.
  ///
  /// In en, this message translates to:
  /// **'{percent} % spent'**
  String percentSpent(int percent);

  /// Web: %(percent)s %% spent: over budget.
  ///
  /// In en, this message translates to:
  /// **'{percent} % spent: over budget'**
  String percentSpentOver(int percent);

  /// Web catalogue (projects, budget or reports): Détail de l'année.
  ///
  /// In en, this message translates to:
  /// **'Details of the year'**
  String get detailsOfYear;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Planned, projects and upkeep'**
  String get plannedAll;

  /// Web catalogue (projects, budget or reports): Reste à prévoir.
  ///
  /// In en, this message translates to:
  /// **'Left to plan'**
  String get leftToPlan;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'{amount} (the plans exceed the envelope)'**
  String plansExceed(String amount);

  /// Web catalogue (projects, budget or reports): prévu %(planned)s, payé %(paid)s.
  ///
  /// In en, this message translates to:
  /// **'planned {planned}, paid {paid}'**
  String plannedPaid(String planned, String paid);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Spent is the more of committed and paid, line by line.'**
  String get spentExplained;

  /// Web catalogue (projects, budget or reports): Par nature, %(year)s.
  ///
  /// In en, this message translates to:
  /// **'By nature, {year}'**
  String byNature(int year);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'The cost typed on a done task is shared between Materials and Labour as its estimate is; a task with no estimate has no such share, and its cost is counted under Other.'**
  String get natureExplained;

  /// Web catalogue (projects, budget or reports): Par année.
  ///
  /// In en, this message translates to:
  /// **'By year'**
  String get byYear;

  /// Web catalogue (projects, budget or reports): 12 derniers mois.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get last12Months;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'From {since} to {until}, the upkeep that was done. Payments on projects carry no date, so they are not in this figure.'**
  String rollingExplained(String since, String until);

  /// Web catalogue (projects, budget or reports): Où en est le budget.
  ///
  /// In en, this message translates to:
  /// **'Where it stands'**
  String get whereItStands;

  /// Web, plural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 task was done without a cost: its estimate is counted, nothing is paid.} other{{count} tasks were done without a cost: their estimates are counted, nothing is paid.}}'**
  String missingCosts(int count);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'No budget yet for this year. Give a project a budget line, or a task an estimate.'**
  String get roomsBudgetEmpty;

  /// Web catalogue (projects, budget or reports): Aucune pièce.
  ///
  /// In en, this message translates to:
  /// **'No room'**
  String get noRoom;

  /// Note of the budget by room (web budget/rooms.html, shortened).
  ///
  /// In en, this message translates to:
  /// **'Projects counted in {year} are shared evenly between their rooms; the upkeep of a task goes to its room.'**
  String roomsExplained(int year);

  /// Web catalogue (projects, budget or reports): Aucun projet pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'No project yet.'**
  String get projectsEmptyShort;

  /// Web catalogue (projects, budget or reports): Compté en.
  ///
  /// In en, this message translates to:
  /// **'Counted in {year}'**
  String countedIn(int year);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Planned by its tasks: {amount}'**
  String plannedByTasks(String amount);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Each project is counted in one year, the year it starts. An abandoned project plans nothing any more: what was paid on it shows as spent without a plan.'**
  String get projectsCountedExplained;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'Planned is the budget lines of the project, and what its tasks plan beyond the lines of the same nature, materials or labour: an estimate a line already holds is not counted twice.'**
  String get projectsPlannedExplained;

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'No task has an estimate or a cost yet. Give a task a labour or material budget.'**
  String get upkeepEmpty;

  /// Web catalogue (projects, budget or reports): Estimation par fois.
  ///
  /// In en, this message translates to:
  /// **'Estimate each time'**
  String get estimateEachTime;

  /// Web catalogue (projects, budget or reports): dont articles en stock : %(amount)s.
  ///
  /// In en, this message translates to:
  /// **'of which stock'**
  String get ofWhichStock;

  /// Web catalogue (projects, budget or reports): Coût par an.
  ///
  /// In en, this message translates to:
  /// **'Cost a year'**
  String get costAYear;

  /// Web catalogue (projects, budget or reports): Payé au total.
  ///
  /// In en, this message translates to:
  /// **'Paid in all'**
  String get paidInAll;

  /// Stock items of a task without a unit price (web budget/tasks.html).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 stock item has no unit price: it counts for nothing.} other{{count} stock items have no unit price: they count for nothing.}}'**
  String unpricedMaterials(int count);

  /// Note of the budget of the upkeep (web budget/tasks.html).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 task has no estimate nor cost and is not listed.} other{{count} tasks have no estimate nor cost and are not listed.}}'**
  String unlistedTasks(int count);

  /// Web catalogue (projects, budget or reports): (same).
  ///
  /// In en, this message translates to:
  /// **'The cost a year follows the repetition: a task every 3 years costs a third of its estimate a year. A task that does not repeat on the calendar has none.'**
  String get costAYearExplained;

  /// Web catalogue (projects, budget or reports): Ouvert.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get reportOpen;

  /// Web catalogue (projects, budget or reports): Transformé en tâche.
  ///
  /// In en, this message translates to:
  /// **'Made into a task'**
  String get reportMadeTask;

  /// Web catalogue (projects, budget or reports): Résolu.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get reportResolved;

  /// Web catalogue (projects, budget or reports): Classé sans suite.
  ///
  /// In en, this message translates to:
  /// **'Closed without action'**
  String get reportNoAction;

  /// The open reports on Today (web reports/_today.html).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 problem reported} other{{count} problems reported}}'**
  String problemsReported(int count);

  /// Web catalogue (projects, budget or reports): Voir les signalements.
  ///
  /// In en, this message translates to:
  /// **'See the reports'**
  String get seeReports;

  /// Web catalogue (projects, budget or reports): Signaler un problème.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// Web catalogue (projects, budget or reports): Signalements.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Web catalogue (projects, budget or reports): Classés.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get reportsClosed;

  /// Filter of the reports (all of them).
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reportsAll;

  /// Web catalogue (projects, budget or reports): Rien à traiter.
  ///
  /// In en, this message translates to:
  /// **'Nothing to deal with.'**
  String get reportsEmpty;

  /// Web catalogue (projects, budget or reports): Où.
  ///
  /// In en, this message translates to:
  /// **'Where?'**
  String get reportWhere;

  /// Web catalogue (projects, budget or reports): Signalé le.
  ///
  /// In en, this message translates to:
  /// **'Reported on'**
  String get reportedOn;

  /// Web catalogue (projects, budget or reports): Classé le.
  ///
  /// In en, this message translates to:
  /// **'Closed on'**
  String get closedOn;

  /// Web catalogue (projects, budget or reports): Tâche.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get reportTask;

  /// Label of the photo of a report, for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Photo of the problem'**
  String get reportPhoto;

  /// Web catalogue (projects, budget or reports): En faire une tâche.
  ///
  /// In en, this message translates to:
  /// **'Make it a task'**
  String get makeItATask;

  /// Web catalogue (projects, budget or reports): Marquer comme résolu.
  ///
  /// In en, this message translates to:
  /// **'Mark as resolved'**
  String get markResolved;

  /// Web catalogue (projects, budget or reports): Classer sans suite.
  ///
  /// In en, this message translates to:
  /// **'Close without action'**
  String get closeWithoutAction;

  /// Web catalogue (projects, budget or reports): Rouvrir.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// Action of the form of a report, the web's label (reports/report_form.html).
  ///
  /// In en, this message translates to:
  /// **'Send the report'**
  String get sendReport;

  /// Web catalogue (projects, budget or reports): ce qui ne va pas.
  ///
  /// In en, this message translates to:
  /// **'What is wrong?'**
  String get whatIsWrong;

  /// Web catalogue (projects, budget or reports): Dites ce qui ne va pas.
  ///
  /// In en, this message translates to:
  /// **'Say what is wrong.'**
  String get errSayWhatIsWrong;

  /// Button of the report form once a photo is chosen.
  ///
  /// In en, this message translates to:
  /// **'Photo added: choose another'**
  String get photoChosen;

  /// Web catalogue (projects, budget or reports): Budget matériel.
  ///
  /// In en, this message translates to:
  /// **'Material budget'**
  String get materialBudget;

  /// Web catalogue (projects, budget or reports): Budget main d'œuvre.
  ///
  /// In en, this message translates to:
  /// **'Labour budget'**
  String get labourBudget;

  /// Help of the budgets of a task.
  ///
  /// In en, this message translates to:
  /// **'What one time of the task is planned to cost, in {currency}. Empty: no estimate.'**
  String taskBudgetHelp(String currency);

  /// Web catalogue (projects, budget or reports): Coût réel.
  ///
  /// In en, this message translates to:
  /// **'Actual cost'**
  String get realCostTitle;

  /// The cost of a done occurrence, in the history of a task.
  ///
  /// In en, this message translates to:
  /// **'Actual cost: {amount}'**
  String realCost(String amount);

  /// A done occurrence without a cost, in the history of a task.
  ///
  /// In en, this message translates to:
  /// **'No cost typed: tap to give it'**
  String get costNotTyped;

  /// Web catalogue (projects, budget or reports): paint left in stock.
  ///
  /// In en, this message translates to:
  /// **'Paint left in stock'**
  String get paintArticle;

  /// No stock article for the paint of a room.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get paintArticleNone;

  /// Tab of Today beside Today: the list of every task of the home. Web catalogue: Toutes.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tasksTabAll;

  /// Title of the list of every task of the home. Web catalogue: Tâches.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// Label of the choice between the tasks to do and the history. Web catalogue: Afficher.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get tasksFilterShow;

  /// Choice of the list of tasks: the open ones. Web catalogue: À faire.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get tasksToDo;

  /// Choice of the list of tasks: the history of what was done. Web catalogue: Faites.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tasksDoneFilter;

  /// Choice of the room filter: no filter. Web catalogue: Toutes les pièces.
  ///
  /// In en, this message translates to:
  /// **'All rooms'**
  String get tasksAllRooms;

  /// Empty list of tasks. Web catalogue: Rien à faire. Ajoutez une tâche pour commencer.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do. Add a task to start.'**
  String get tasksNone;

  /// Line under the list: tasks hidden until their date gets closer. Web catalogue: tâche masquée jusqu'à ce que sa date approche.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} task is hidden until its date gets closer.} other{{count} tasks are hidden until their date gets closer.}}'**
  String tasksHidden(int count);

  /// Button that shows the hidden tasks. Web catalogue: Les afficher.
  ///
  /// In en, this message translates to:
  /// **'Show them'**
  String get tasksShowHidden;

  /// Button to the previous page of a list. Web catalogue: Précédent.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get pagePrevious;

  /// Button to the next page of a list. Web catalogue: Suivant.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get pageNext;

  /// Position in a paged list. Web catalogue: Page %(number)s sur %(total)s.
  ///
  /// In en, this message translates to:
  /// **'Page {number} of {total}'**
  String pageOf(int number, int total);

  /// Heading of the filters of the history. Web catalogue: Filtres.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get historyFilters;

  /// Label of the search field of the history. Web catalogue: Rechercher.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get historySearch;

  /// Choice of the item filter: no filter. Web catalogue: Tous les éléments.
  ///
  /// In en, this message translates to:
  /// **'All items'**
  String get historyAllItems;

  /// Choice of the contractor filter: no filter. Web catalogue: Tout le monde.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get historyEveryone;

  /// Label of the filter on done or skipped. Web catalogue: Résultat.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get historyOutcome;

  /// Choice of the outcome filter: no filter. Web catalogue: Faites ou ignorées.
  ///
  /// In en, this message translates to:
  /// **'Done or skipped'**
  String get historyDoneOrSkipped;

  /// Choice of the outcome filter: what was done. Web catalogue: Faites.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get historyOutcomeDone;

  /// Choice of the outcome filter: what was skipped. Web catalogue: Ignorée.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get historyOutcomeSkipped;

  /// Label of the first day of the history filter. Web catalogue: Du.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get historyFrom;

  /// Label of the last day of the history filter. Web catalogue: Au.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get historyTo;

  /// Button that removes the filters of the history. Web catalogue: Effacer.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get historyClear;

  /// Empty history under a filter. Web catalogue: Rien ne correspond.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches.'**
  String get historyNothingMatches;

  /// Empty history. Web catalogue: Rien de fait pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'Nothing done yet.'**
  String get historyNothingDone;

  /// Number of entries of the history. Web catalogue: entrée.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry} other{{count} entries}}'**
  String historyEntries(int count);

  /// What the selection of the history really cost, over the entries where a cost was typed. Web catalogue: coût réel.
  ///
  /// In en, this message translates to:
  /// **'real cost: {total}, entered on {count, plural, one{{count} entry} other{{count} entries}}'**
  String historyCost(String total, int count);

  /// Group of Today: tasks of a season that is on, further than a week or without a date. Web catalogue: De saison.
  ///
  /// In en, this message translates to:
  /// **'In season'**
  String get seasonSection;

  /// Button that deletes a task. Web catalogue: Supprimer la tâche.
  ///
  /// In en, this message translates to:
  /// **'Delete the task'**
  String get taskDelete;

  /// Title of the confirmation before a task is deleted. Web catalogue: Supprimer %(name)s ?
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String taskDeleteTitle(String name);

  /// Body of the confirmation before a task is deleted. Web catalogue: La tâche, son historique et ses fichiers disparaissent des écrans.
  ///
  /// In en, this message translates to:
  /// **'The task, its history and its files disappear from the screens.'**
  String get taskDeleteBody;

  /// Label of the duration of a task. Web catalogue: Durée estimée.
  ///
  /// In en, this message translates to:
  /// **'Estimated duration'**
  String get taskDuration;

  /// Label of the unit of the duration of a task. Web catalogue: Unité.
  ///
  /// In en, this message translates to:
  /// **'Unit of the duration'**
  String get taskDurationUnit;

  /// Unit of a duration. Web catalogue: minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get unitMinutes;

  /// Unit of a duration. Web catalogue: heures.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get unitHours;

  /// Label of the days a task stays hidden before its date. Web catalogue: masquer jusqu'à ce nombre de jours avant.
  ///
  /// In en, this message translates to:
  /// **'Hide until this many days before'**
  String get taskHideDays;

  /// Help of the days a task stays hidden. Web catalogue: 0 affiche la tâche dès qu'elle existe.
  ///
  /// In en, this message translates to:
  /// **'0 shows the task as soon as it exists.'**
  String get taskHideDaysHelp;

  /// Error of the days a task stays hidden.
  ///
  /// In en, this message translates to:
  /// **'Give a number of days from 0 to 365.'**
  String get errHideDays;

  /// Error of the duration of a task.
  ///
  /// In en, this message translates to:
  /// **'Give a duration of at least 1 and at most one year.'**
  String get errDuration;

  /// Label of the procedure of a task, in Markdown. Web catalogue: Comment faire.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get taskProcedure;

  /// Last choice of the rooms of a task form: a new room. Web catalogue: Ajouter une pièce….
  ///
  /// In en, this message translates to:
  /// **'Add a room…'**
  String get taskAddRoom;

  /// Heading of the fields of a room added with a task. Web catalogue: Nouvelle pièce.
  ///
  /// In en, this message translates to:
  /// **'New room'**
  String get taskNewRoom;

  /// Label of the name of a room added with a task. Web catalogue: Nom de la nouvelle pièce.
  ///
  /// In en, this message translates to:
  /// **'Name of the new room'**
  String get taskNewRoomName;

  /// Label of the kind of a room added with a task. Web catalogue: Type de pièce.
  ///
  /// In en, this message translates to:
  /// **'Type of room'**
  String get taskNewRoomKind;

  /// Last choice of the items of a task form: a new item. Web catalogue: Ajouter un élément….
  ///
  /// In en, this message translates to:
  /// **'Add an item…'**
  String get taskAddItem;

  /// Heading of the fields of an item added with a task. Web catalogue: Nouvel élément.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get taskNewItem;

  /// Label of the name of an item added with a task. Web catalogue: Nom du nouvel élément.
  ///
  /// In en, this message translates to:
  /// **'Name of the new item'**
  String get taskNewItemName;

  /// Last choice of the contractors of a task form: a new contractor. Web catalogue: Ajouter un intervenant….
  ///
  /// In en, this message translates to:
  /// **'Add a contractor…'**
  String get taskAddContractor;

  /// Heading of the fields of a contractor added with a task. Web catalogue: Nouvel intervenant.
  ///
  /// In en, this message translates to:
  /// **'New contractor'**
  String get taskNewContractor;

  /// Label of the name of a contractor added with a task. Web catalogue: Nom du nouvel intervenant.
  ///
  /// In en, this message translates to:
  /// **'Name of the new contractor'**
  String get taskNewContractorName;

  /// Pill of a task whose date was moved. Web catalogue: Reportée.
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get taskPostponedPill;

  /// Pill of a task of high priority. Web catalogue: Priorité haute.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get taskHighPriority;

  /// Pill of a task of low priority. Web catalogue: Priorité basse.
  ///
  /// In en, this message translates to:
  /// **'Low priority'**
  String get taskLowPriority;

  /// Heading of the repetition and the dates of a task. Web catalogue: Quand.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get taskWhen;

  /// Heading of the photos of the item of a task. Web catalogue: Photos de l'élément.
  ///
  /// In en, this message translates to:
  /// **'Photos of the item'**
  String get taskPhotosOfItem;

  /// Heading of the photos of the room of a task. Web catalogue: Photos de la pièce.
  ///
  /// In en, this message translates to:
  /// **'Photos of the room'**
  String get taskPhotosOfRoom;

  /// Link to the item, which holds all its photos. Web catalogue: Toutes les photos de l'élément.
  ///
  /// In en, this message translates to:
  /// **'All photos of the item'**
  String get taskAllPhotosOfItem;

  /// Link to the room, which holds all its photos. Web catalogue: Toutes les photos de la pièce.
  ///
  /// In en, this message translates to:
  /// **'All photos of the room'**
  String get taskAllPhotosOfRoom;

  /// Title of the screen that completes a done occurrence. Web catalogue: Détails de ce qui a été fait.
  ///
  /// In en, this message translates to:
  /// **'Details of what was done'**
  String get occurrenceTitle;

  /// Label of the day a task was done. Web catalogue: fait le.
  ///
  /// In en, this message translates to:
  /// **'Done on'**
  String get occurrenceDoneOn;

  /// Button of a done line of the history of a task, to complete it. Web catalogue: Détails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get occurrenceDetails;

  /// Button of the page of a task that opens its form, and title of that form. Web catalogue: Modifier la tâche.
  ///
  /// In en, this message translates to:
  /// **'Edit the task'**
  String get taskEditTask;

  /// Title of the form that creates a task. Web catalogue: Ajouter une tâche.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get taskAddTitle;

  /// Label of the due date on the page of a task. Web catalogue: Échéance.
  ///
  /// In en, this message translates to:
  /// **'Due on'**
  String get taskDueOn;

  /// Label of the first date of a postponed task. Web catalogue: Reportée depuis le.
  ///
  /// In en, this message translates to:
  /// **'Postponed from'**
  String get taskPostponedFrom;

  /// Label of how long before its date a task stays hidden. Web catalogue: Masquée jusqu'à.
  ///
  /// In en, this message translates to:
  /// **'Hidden until'**
  String get taskHiddenUntil;

  /// Value of Hidden until. Web catalogue: %(counter)s jour avant la date.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{{n} day before the date} other{{n} days before the date}}'**
  String taskHiddenDays(int n);

  /// Label of the next dates of a task. Web catalogue: Ensuite.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get taskThen;

  /// Heading of the duration, budgets, contractor and notes of a task. Web catalogue: Détails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get taskDetails;

  /// Heading of the cost of a task. Web catalogue: Coût.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get taskCost;

  /// Part of the estimate that comes from the stock. Web catalogue: Dont articles en stock.
  ///
  /// In en, this message translates to:
  /// **'Of which stock'**
  String get taskOfWhichStock;

  /// What the times done of a task cost. Web catalogue: Payé jusqu'ici.
  ///
  /// In en, this message translates to:
  /// **'Paid so far'**
  String get taskPaidSoFar;

  /// Section of the task form: priority and contractor. Web catalogue: Qui.
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get taskWho;

  /// Section of the task form: duration and budgets. Web catalogue: Durée et budget.
  ///
  /// In en, this message translates to:
  /// **'Time and budget'**
  String get taskTimeAndBudget;

  /// Repetition of a task on fixed dates. Web catalogue: Tous les jours.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every day} other{Every {n} days}}'**
  String repeatEveryDay(int n);

  /// Repetition of a task on fixed dates. Web catalogue: Toutes les semaines.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every week} other{Every {n} weeks}}'**
  String repeatEveryWeek(int n);

  /// Repetition of a task on fixed dates. Web catalogue: Tous les mois.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every month} other{Every {n} months}}'**
  String repeatEveryMonth(int n);

  /// Repetition of a task on fixed dates. Web catalogue: Tous les ans.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every year} other{Every {n} years}}'**
  String repeatEveryYear(int n);

  /// Repetition counted from the day the task is done. Web catalogue: Un jour après la dernière fois.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{A day after the last time} other{{n} days after the last time}}'**
  String repeatDaysAfter(int n);

  /// Repetition counted from the day the task is done. Web catalogue: Une semaine après la dernière fois.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{A week after the last time} other{{n} weeks after the last time}}'**
  String repeatWeeksAfter(int n);

  /// Repetition counted from the day the task is done. Web catalogue: Un mois après la dernière fois.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{A month after the last time} other{{n} months after the last time}}'**
  String repeatMonthsAfter(int n);

  /// Repetition counted from the day the task is done. Web catalogue: Un an après la dernière fois.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{A year after the last time} other{{n} years after the last time}}'**
  String repeatYearsAfter(int n);

  /// Months of the season of a task, after its repetition. Web catalogue: de %(start)s à %(end)s.
  ///
  /// In en, this message translates to:
  /// **'from {start} to {end}'**
  String repeatMonths(String start, String end);

  /// An estimated duration under an hour. Web catalogue: %(n)d min.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String durationMin(int n);

  /// An estimated duration in whole hours. Web catalogue: 1 h.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// An estimated duration in hours and minutes, the minutes on two digits. Web catalogue: 1 h 30.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes}'**
  String durationHoursMinutes(int hours, String minutes);

  /// Part of an estimated duration. Web catalogue: %(n)d jour.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{{n} day} other{{n} days}}'**
  String durationDays(int n);

  /// Part of an estimated duration. Web catalogue: %(n)d semaine.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{{n} week} other{{n} weeks}}'**
  String durationWeeks(int n);

  /// Part of an estimated duration. Web catalogue: %(n)d mois.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{{n} month} other{{n} months}}'**
  String durationMonths(int n);

  /// Part of an estimated duration. Web catalogue: %(n)d an.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{{n} year} other{{n} years}}'**
  String durationYears(int n);

  /// Button that ends the form of a new task. Web catalogue: Ajouter la tâche.
  ///
  /// In en, this message translates to:
  /// **'Add the task'**
  String get taskAddSubmit;

  /// Web catalogue (stock): Millilitre (mL).
  ///
  /// In en, this message translates to:
  /// **'Millilitre (mL)'**
  String get unitMillilitreChoice;

  /// Unit after a quantity, the same in the singular and the plural. Web catalogue (stock): mL.
  ///
  /// In en, this message translates to:
  /// **'mL'**
  String get unitMillilitre;

  /// Error of the item form: the duration of the warranty is out of range (MAX_WARRANTY_DURATION of the web).
  ///
  /// In en, this message translates to:
  /// **'A warranty lasts from 1 to 99 months or years.'**
  String get errWarrantyDuration;

  /// Tab of Rooms: every item of the home. Web catalogue (context tab): Équipements.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipmentTab;

  /// Search field of the list of every item. Web catalogue: Rechercher par nom, marque, modèle ou numéro de série.
  ///
  /// In en, this message translates to:
  /// **'Search by name, brand, model or serial number'**
  String get itemsSearch;

  /// First choice of the room filter of the list of every item. Web catalogue: Toutes les pièces.
  ///
  /// In en, this message translates to:
  /// **'Every room'**
  String get itemsEveryRoom;

  /// Line of an item in the list of every item: its next task. Web catalogue: Prochaine :.
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String itemsNext(String title);

  /// Line of an item without an open task. Web catalogue: Aucune tâche à venir.
  ///
  /// In en, this message translates to:
  /// **'No task to come'**
  String get itemsNoTask;

  /// Pill of an item under warranty, in the list of every item. Web catalogue: garantie jusqu'au.
  ///
  /// In en, this message translates to:
  /// **'warranty until {date}'**
  String itemsWarrantyUntil(String date);

  /// Pill of an item whose warranty ended, in the list of every item. Web catalogue: garantie terminée le.
  ///
  /// In en, this message translates to:
  /// **'warranty ended {date}'**
  String itemsWarrantyEnded(String date);

  /// Empty list of every item. Web catalogue: Aucun élément pour l'instant.
  ///
  /// In en, this message translates to:
  /// **'No item yet. Add one from the page of a room.'**
  String get itemsAllEmpty;

  /// The filters of the list of every item leave nothing. Web catalogue: Aucun élément ne correspond.
  ///
  /// In en, this message translates to:
  /// **'No item matches.'**
  String get itemsNoMatch;

  /// Line and section of an item. Web catalogue: Garantie constructeur.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer\'s warranty'**
  String get itemManufacturerWarranty;

  /// Field of an item. Web catalogue: Acheté le.
  ///
  /// In en, this message translates to:
  /// **'Purchased on'**
  String get itemPurchasedOn;

  /// Field of an item. Web catalogue: garantie : durée.
  ///
  /// In en, this message translates to:
  /// **'Warranty: duration'**
  String get warrantyDuration;

  /// Field of an item: months or years. Web catalogue: garantie : en.
  ///
  /// In en, this message translates to:
  /// **'Warranty: in'**
  String get warrantyDurationUnit;

  /// Field of an item. Web catalogue: garantie : donnée par.
  ///
  /// In en, this message translates to:
  /// **'Warranty: given by'**
  String get warrantyProvider;

  /// Field of an item. Web catalogue: garantie : nom du fabricant ou du magasin.
  ///
  /// In en, this message translates to:
  /// **'Warranty: name of the manufacturer or shop'**
  String get warrantyProviderName;

  /// Field of an item. Web catalogue: garantie : départ le.
  ///
  /// In en, this message translates to:
  /// **'Warranty: starts on'**
  String get warrantyStartsOn;

  /// Unit of a warranty. Web catalogue (rooms): mois.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get warrantyMonthsChoice;

  /// Unit of a warranty. Web catalogue (rooms): ans.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get warrantyYearsChoice;

  /// Who gives a warranty. Web catalogue: Le fabricant.
  ///
  /// In en, this message translates to:
  /// **'The manufacturer'**
  String get warrantyByManufacturer;

  /// Who gives a warranty. Web catalogue: Le magasin.
  ///
  /// In en, this message translates to:
  /// **'The shop'**
  String get warrantyByShop;

  /// Duration of a warranty. Web catalogue: %(counter)s mois.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} month} other{{count} months}}'**
  String warrantyMonths(int count);

  /// Duration of a warranty. Web catalogue: %(counter)s an / ans.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} year} other{{count} years}}'**
  String warrantyYears(int count);

  /// Start of a warranty, after its duration. Web catalogue: depuis le.
  ///
  /// In en, this message translates to:
  /// **'from {date}'**
  String warrantyFrom(String date);

  /// Help of the item form. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'The warranty of the manufacturer or of the shop, in months or years.'**
  String get warrantyDurationHelp;

  /// Help of the item form. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Example: Acme, or the shop where you bought it.'**
  String get warrantyProviderNameHelp;

  /// Help of the item form. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Empty: from the purchase date.'**
  String get warrantyStartsOnHelp;

  /// Help of the item form. Web catalogue.
  ///
  /// In en, this message translates to:
  /// **'Worked out from the start and the duration. Type it only when you do not know them.'**
  String get warrantyEndsOnHelp;

  /// Discreet status of a sheet saved as it is changed, said by the screen reader. Web catalogue (core): Enregistré.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;
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
