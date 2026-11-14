// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Housecairn';

  @override
  String get navToday => 'Today';

  @override
  String get navRooms => 'Rooms';

  @override
  String get navProjects => 'Projects';

  @override
  String get navBudget => 'Budget';

  @override
  String get navMore => 'More';

  @override
  String get emptySection => 'Nothing here yet.';

  @override
  String get moreHelpGroup => 'Help';

  @override
  String get about => 'About';

  @override
  String get aboutAttribution => 'Housecairn, by Robvred';

  @override
  String aboutVersion(String version) {
    return 'version $version';
  }

  @override
  String get aboutLicence => 'Free software under the AGPL-3.0 licence.';

  @override
  String aboutSource(String address) {
    return 'Source code and security reports: $address';
  }

  @override
  String get aboutAi => 'Developed with an AI agent, under human review.';

  @override
  String get aboutLicences => 'Open source licences';

  @override
  String get moreHouseholdGroup => 'Household';

  @override
  String get homes => 'Homes';

  @override
  String get homeSelectorTooltip => 'Choose a home';

  @override
  String get allHomes => 'All homes';

  @override
  String get todayOverdue => 'Overdue';

  @override
  String get todayComingUp => 'Coming up';

  @override
  String get todayNoDate => 'No date';

  @override
  String get todayEmpty => 'Nothing to do for now.';

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String postponedTo(String date) {
    return 'Postponed to $date';
  }

  @override
  String rowInHome(String home, String when) {
    return '$home · $when';
  }

  @override
  String get actionDone => 'Done';

  @override
  String get actionMore => 'More actions';

  @override
  String get actionSkip => 'Skip this time';

  @override
  String get actionPostpone => 'Postpone';

  @override
  String doneMessage(String title) {
    return 'Done: $title';
  }

  @override
  String skippedMessage(String title) {
    return 'Skipped: $title';
  }

  @override
  String get undo => 'Undo';

  @override
  String get newTask => 'New task';

  @override
  String get task => 'Task';

  @override
  String get taskTitle => 'Title';

  @override
  String get taskDueDate => 'Due date';

  @override
  String get taskChooseDate => 'Choose a date';

  @override
  String get taskClearDate => 'Remove the date';

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatOnce => 'Once';

  @override
  String get repeatFixed => 'Fixed date';

  @override
  String get repeatAfterLast => 'After the last time';

  @override
  String get repeatEvery => 'Every';

  @override
  String get unitDays => 'days';

  @override
  String get unitWeeks => 'weeks';

  @override
  String get unitMonths => 'months';

  @override
  String get unitYears => 'years';

  @override
  String get season => 'Season';

  @override
  String get seasonWholeYear => 'Whole year';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonAutumn => 'Autumn';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonCustom => 'Custom months';

  @override
  String get taskNotes => 'Notes';

  @override
  String get taskNextDates => 'Next dates';

  @override
  String get taskHistory => 'History';

  @override
  String historyDone(String date) {
    return 'Done on $date';
  }

  @override
  String get historySkipped => 'Skipped';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get homesArchived => 'Archived';

  @override
  String get newHome => 'New home';

  @override
  String get homeName => 'Name';

  @override
  String get homeCurrency => 'Currency';

  @override
  String get homeHemisphere => 'Hemisphere';

  @override
  String get hemisphereNorth => 'Northern';

  @override
  String get hemisphereSouth => 'Southern';

  @override
  String get homeArchive => 'Archive';

  @override
  String get homeUnarchive => 'Unarchive';

  @override
  String get homeArchivedNotice => 'This home is archived: it is read only.';

  @override
  String get homeDelete => 'Delete';

  @override
  String homeDeleteTitle(String home) {
    return 'Delete $home?';
  }

  @override
  String get homeDeleteBody =>
      'Every task, room, item and photo of this home is deleted from this phone, for good. Type the name of the home to confirm.';

  @override
  String get homeDeleteConfirm => 'Delete for good';

  @override
  String get firstHomeName => 'My home';

  @override
  String get errTitleRequired => 'Give it a name or a title.';

  @override
  String get errTooLong => 'This text is too long.';

  @override
  String get errIntervalOutOfRange => 'This interval is out of range.';

  @override
  String get errSeasonMonths =>
      'Give the first and the last month of the season.';

  @override
  String get errFixedNeedsDate =>
      'A task that repeats on a fixed date needs a date.';

  @override
  String get errDateOutOfRange => 'Choose a date within 100 years of today.';

  @override
  String get errFutureDate => 'The date cannot be in the future.';

  @override
  String get errPastDate => 'Choose a date that is not in the past.';

  @override
  String get errAlreadyClosed => 'This occurrence is already closed.';

  @override
  String get errNotClosed =>
      'Only a task that was marked done or skipped can be undone.';

  @override
  String get errNextChanged =>
      'The next occurrence has been changed since: it cannot be undone any more.';

  @override
  String get errHomeArchived => 'This home is archived: it is read only.';

  @override
  String get errLastActiveHome =>
      'The last active home can be neither archived nor deleted.';

  @override
  String get errNameMismatch => 'Type the exact name of the home.';

  @override
  String get errCurrencyInvalid => 'Use an ISO 4217 code, such as EUR.';

  @override
  String get errNotFound => 'This no longer exists.';
}
