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

  @override
  String get dueToday => 'Today';

  @override
  String get dayLate => '1 day late';

  @override
  String daysLate(int count) {
    return '$count days late';
  }

  @override
  String get roomKindLiving => 'Living room';

  @override
  String get roomKindKitchen => 'Kitchen';

  @override
  String get roomKindBathroom => 'Bathroom';

  @override
  String get roomKindBedroom => 'Bedroom';

  @override
  String get roomKindHallway => 'Hallway';

  @override
  String get roomKindOffice => 'Office';

  @override
  String get roomKindUtility => 'Utility room';

  @override
  String get roomKindGarage => 'Garage';

  @override
  String get roomKindCellar => 'Cellar';

  @override
  String get roomKindAttic => 'Attic';

  @override
  String get roomKindOutdoor => 'Outdoor';

  @override
  String get roomKindOther => 'Other';

  @override
  String get itemKindEquipment => 'Equipment';

  @override
  String get itemKindSurface => 'Surface';

  @override
  String get tradePlumber => 'Plumber';

  @override
  String get tradeElectrician => 'Electrician';

  @override
  String get tradeHeatingEngineer => 'Heating engineer';

  @override
  String get tradeRoofer => 'Roofer';

  @override
  String get tradeCarpenter => 'Carpenter';

  @override
  String get tradePainter => 'Painter';

  @override
  String get tradeMason => 'Mason';

  @override
  String get tradeGardener => 'Gardener';

  @override
  String get tradeLocksmith => 'Locksmith';

  @override
  String get tradeChimneySweep => 'Chimney sweep';

  @override
  String get tradeOther => 'Other';

  @override
  String get photoCategoryGeneral => 'General';

  @override
  String get photoCategoryBehindWalls => 'Behind the walls';

  @override
  String get photoCategoryBefore => 'Before the work';

  @override
  String get photoCategoryAfter => 'After the work';

  @override
  String get photoCategoryOther => 'Other';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get tasks => 'Tasks';

  @override
  String get tasksEmpty => 'No task yet.';

  @override
  String get addRoom => 'Add a room';

  @override
  String get newRoom => 'New room';

  @override
  String get room => 'Room';

  @override
  String get roomsEmpty => 'No room yet.';

  @override
  String roomSummary(String kind, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$kind · $_temp0';
  }

  @override
  String get editRoom => 'Edit the room';

  @override
  String get deleteRoom => 'Delete the room';

  @override
  String get deleteRoomBody =>
      'The room, its items and their photos are deleted from this phone. Its tasks are kept, with no room.';

  @override
  String get roomMemory => 'Room memory';

  @override
  String get roomMemoryEmpty =>
      'Nothing noted yet: paint, floor and wall coverings, and what runs behind the walls.';

  @override
  String get paintColour => 'Paint colour';

  @override
  String get paintBrand => 'Paint brand';

  @override
  String get paintReference => 'Paint reference';

  @override
  String get paintBatch => 'Paint batch';

  @override
  String get floorCovering => 'Floor covering';

  @override
  String get wallCovering => 'Wall covering';

  @override
  String get memoryNotes => 'Memory notes';

  @override
  String get items => 'Items';

  @override
  String get addItem => 'Add an item';

  @override
  String get itemsEmpty => 'No item in this room yet.';

  @override
  String get newItem => 'New item';

  @override
  String get item => 'Item';

  @override
  String get editItem => 'Edit the item';

  @override
  String get deleteItem => 'Delete the item';

  @override
  String get deleteItemBody =>
      'The item and its photos are deleted from this phone. Its tasks are kept, with no item.';

  @override
  String get itemBrand => 'Brand';

  @override
  String get itemModel => 'Model';

  @override
  String get itemBrandModel => 'Brand, model';

  @override
  String get itemSerial => 'Serial number';

  @override
  String get itemInstalledOn => 'Installed on';

  @override
  String get itemWarrantyEndsOn => 'Warranty ends on';

  @override
  String get itemWarranty => 'Warranty';

  @override
  String warrantyEnded(String date) {
    return 'ended on $date';
  }

  @override
  String warrantyUntil(String date) {
    return 'until $date';
  }

  @override
  String get maintenanceContract => 'Maintenance contract';

  @override
  String get contractProvider => 'Provider';

  @override
  String get contractNone => 'None';

  @override
  String get contractNumber => 'Number';

  @override
  String get contractLink => 'Link';

  @override
  String get links => 'Links';

  @override
  String get linkLabel => 'Label';

  @override
  String get linkAddress => 'Address';

  @override
  String get addLink => 'Add a link';

  @override
  String get removeLink => 'Remove the link';

  @override
  String get photos => 'Photos';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get photoTake => 'Take a photo';

  @override
  String get photoPick => 'Choose from the gallery';

  @override
  String get photosEmpty => 'No photo yet.';

  @override
  String photoLabel(String category) {
    return 'Photo, $category';
  }

  @override
  String get photoCategoryField => 'Category';

  @override
  String get photoCaption => 'Caption';

  @override
  String get photoDelete => 'Delete the photo';

  @override
  String get photoDeleted => 'Photo deleted.';

  @override
  String get photoNotHere => 'Photo not on this phone';

  @override
  String get photoDenied =>
      'Housecairn is not allowed to use the camera or the photos. You can allow it in the settings of your phone.';

  @override
  String get contractors => 'Contractors';

  @override
  String get contractorsEmpty =>
      'No contractor yet. People and companies who work in this home, with their trade and how to reach them, are kept here.';

  @override
  String get addContractor => 'Add a contractor';

  @override
  String get newContractor => 'New contractor';

  @override
  String get contractor => 'Contractor';

  @override
  String get contractorTrade => 'Trade';

  @override
  String get contractorTradeOther => 'Which trade';

  @override
  String get contractorPhone => 'Phone';

  @override
  String get contractorEmail => 'Email address';

  @override
  String get contractorAddress => 'Address';

  @override
  String get contractorNote => 'Note';

  @override
  String get contractorCall => 'Call';

  @override
  String get contractorWrite => 'Send an e-mail';

  @override
  String get contractorNoTasks => 'No task is linked to this contractor.';

  @override
  String get contractorCannotOpen => 'Nothing on this phone can open this.';

  @override
  String get deleteContractor => 'Delete the contractor';

  @override
  String get deleteContractorBody =>
      'The contractor is deleted from this phone. The items and tasks that named them are kept, with no contractor.';

  @override
  String get addFromTemplate => 'Add from a template';

  @override
  String get templatesIntro =>
      'Common tasks of a home, with an indicative interval and its source. Tick those you need: each becomes a task of the current home, which you can change afterwards.';

  @override
  String get templatesRoom => 'Room (optional)';

  @override
  String get templatesNoRoom => 'No room';

  @override
  String get templatesDue => 'First due date (optional)';

  @override
  String get templatesAdd => 'Add the tasks';

  @override
  String get templatesNoneTicked => 'Tick at least one template.';

  @override
  String templatesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks added.',
      one: '1 task added.',
    );
    return '$_temp0';
  }

  @override
  String templateRegion(String region) {
    return 'rule of $region';
  }

  @override
  String templateEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: 'day',
    );
    return 'every $_temp0';
  }

  @override
  String templateEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: 'week',
    );
    return 'every $_temp0';
  }

  @override
  String templateEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: 'month',
    );
    return 'every $_temp0';
  }

  @override
  String templateEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: 'year',
    );
    return 'every $_temp0';
  }

  @override
  String templateMaterial(String list) {
    return 'Material: $list.';
  }

  @override
  String templateSource(String title, String url) {
    return 'Interval from: $title, $url';
  }

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersExplain =>
      'The phone reminds you the day before a task is due, at 8:00, and again until it is done. Nothing is sent from the phone.';

  @override
  String get remindersDenied =>
      'Notifications are not allowed. You can allow them in the settings of your phone.';

  @override
  String reminderTitleHome(String home, String task) {
    return '$home: $task';
  }

  @override
  String reminderSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more tasks to do',
      one: '1 more task to do',
    );
    return '$_temp0';
  }

  @override
  String reminderSummaryLineHome(String home, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$home: $_temp0';
  }

  @override
  String reminderSummaryLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get remindersChannel => 'Reminders';

  @override
  String get errPhoneInvalid => 'Digits, spaces and + ( ) - . / only.';

  @override
  String get errEmailInvalid => 'Enter a valid email address.';

  @override
  String get errUrlInvalid =>
      'Enter a web address that starts with http:// or https://.';

  @override
  String get errTooManyLinks => 'At most 10 links.';

  @override
  String get errTradeOther => 'Say which trade.';

  @override
  String get errChoiceInvalid => 'Choose a value from the list.';

  @override
  String get errNotInHome => 'This is not in this home.';

  @override
  String get errTooManyPhotos => 'At most 30 photos here.';

  @override
  String get errPhotoUnreadable => 'This file is not a photo the app can read.';

  @override
  String get errPhotoTooLarge => 'This photo is too large (20 MiB at most).';
}
