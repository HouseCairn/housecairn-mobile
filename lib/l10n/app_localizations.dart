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

  /// Date of an open task on Today.
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
