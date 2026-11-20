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
  String get moreHelpGroup => 'Help';

  @override
  String get about => 'About';

  @override
  String get aboutAttribution => 'Housecairn, by Robvred';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutLicence => 'Free software under the AGPL-3.0 licence.';

  @override
  String get aboutSourceLink => 'Source code and security reports on GitHub.';

  @override
  String get aboutAi => 'Developed with an AI agent, under human review.';

  @override
  String get aboutLicences => 'Open source licences';

  @override
  String get aboutLinks => 'Links';

  @override
  String get linkWebsite => 'Website';

  @override
  String get linkDocs => 'Documentation';

  @override
  String get linkAppCode => 'Application code';

  @override
  String get linkAddon => 'Home Assistant app';

  @override
  String get linkIntegration => 'Home Assistant integration';

  @override
  String get linkMobile => 'Mobile application';

  @override
  String get linkAndroid => 'Android';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get aboutBeta => 'iPhone beta (TestFlight)';

  @override
  String get aboutBetaOpen => 'Open the link';

  @override
  String get aboutBetaCopy => 'Copy the link';

  @override
  String get aboutBetaCopied => 'Link copied';

  @override
  String get aboutBetaCannotOpen => 'Nothing on this phone can open this link.';

  @override
  String get moreHomeGroup => 'Home';

  @override
  String get moreMeGroup => 'Me';

  @override
  String get moreReportsText => 'Problems reported in this home';

  @override
  String get moreContractorsText =>
      'The people and companies who work on the home';

  @override
  String get moreHomesText => 'Add a home or open another one';

  @override
  String get notifications => 'Notifications';

  @override
  String get moreNotificationsText => 'When the phone reminds you of a task';

  @override
  String get homes => 'My homes';

  @override
  String get brandName => 'HouseCairn';

  @override
  String get helpTooltip => 'Help for this page';

  @override
  String get homeSelectorTooltip => 'Choose a home';

  @override
  String get allHomes => 'All homes';

  @override
  String get todayOverdue => 'Overdue';

  @override
  String get todayToday => 'Today';

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
  String get addTask => 'Add a task';

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
  String get pickerDone => 'Done';

  @override
  String get homesArchived => 'Archived';

  @override
  String get newHome => 'New home';

  @override
  String get addHome => 'Add a home';

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
  String get homeArchive => 'Archive this home';

  @override
  String get homeUnarchive => 'Bring this home back';

  @override
  String get homeArchivedNotice => 'This home is archived: it is read only.';

  @override
  String get homeDelete => 'Delete this home';

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
  String get editMemory => 'Edit the memory';

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
  String get photoNoCamera =>
      'This phone has no camera to use. You can pick a photo from the gallery instead.';

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
  String get templateSourceLink => 'source';

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

  @override
  String get errQuantityInvalid => 'Give a number, with at most two decimals.';

  @override
  String get errQuantityNotPositive => 'The quantity must be more than zero.';

  @override
  String errStockShort(String available) {
    return 'Only $available in stock.';
  }

  @override
  String get errUnitOther => 'Say which unit.';

  @override
  String get errMaterialListed =>
      'This stock item is already listed on the task.';

  @override
  String get errTooManyMaterials => 'A task lists at most 50 stock items.';

  @override
  String get stock => 'Stock';

  @override
  String get stockSearch => 'Search by name, reference or supplier';

  @override
  String get stockTabAll => 'All';

  @override
  String get stockEmpty => 'No stock item yet.';

  @override
  String get stockNoMatch => 'No stock item matches.';

  @override
  String get addArticle => 'Add a stock item';

  @override
  String get addArticleButton => 'Add the stock item';

  @override
  String get editArticle => 'Edit the stock item';

  @override
  String get deleteArticle => 'Delete the stock item';

  @override
  String get deleteArticleBody =>
      'The stock item, its suppliers and its movements disappear from the screens.';

  @override
  String get articleLowStock => 'Low stock';

  @override
  String get articleThreshold => 'Threshold';

  @override
  String get articleThresholdHelp =>
      'The stock is flagged when it falls to this quantity or below.';

  @override
  String get articleUnitPrice => 'Unit price';

  @override
  String articleUnitPriceHelp(String currency) {
    return 'What one unit costs, in $currency, to plan the cost of the tasks that use it.';
  }

  @override
  String get articleReference => 'Manufacturer reference';

  @override
  String get articleDimensions => 'Dimensions';

  @override
  String get articleStorage => 'Storage location';

  @override
  String get articleStorageHelp => 'For example: garage, second shelf.';

  @override
  String get articleUnit => 'Unit';

  @override
  String get articleUnitOther => 'Which unit';

  @override
  String get articleUnitOtherHelp => 'Only with the unit Other. Example: bag.';

  @override
  String get articleCompatible => 'Compatible items';

  @override
  String get articleCompatibleHelp =>
      'The equipment this fits, such as the boiler a filter is made for.';

  @override
  String get articleNoCompatible => 'No compatible item chosen.';

  @override
  String get articleRoomsHelp =>
      'Where it is used, besides the rooms of the equipment it fits.';

  @override
  String get articleTasks => 'Needed by tasks';

  @override
  String get unitNone => 'None';

  @override
  String get unitPieceChoice => 'Piece';

  @override
  String get unitLitreChoice => 'Litre';

  @override
  String get unitMetreChoice => 'Metre';

  @override
  String get unitKilogramChoice => 'Kilogram';

  @override
  String get unitRollChoice => 'Roll';

  @override
  String get unitBoxChoice => 'Box';

  @override
  String get unitOtherChoice => 'Other';

  @override
  String unitPiece(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
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
      other: 'metres',
      one: 'metre',
    );
    return '$_temp0';
  }

  @override
  String unitKilogram(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kilograms',
      one: 'kilogram',
    );
    return '$_temp0';
  }

  @override
  String unitRoll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rolls',
      one: 'roll',
    );
    return '$_temp0';
  }

  @override
  String unitBox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'boxes',
      one: 'box',
    );
    return '$_temp0';
  }

  @override
  String get recordMovement => 'Record a movement';

  @override
  String get movementQuantity => 'Quantity';

  @override
  String get movementDate => 'Date';

  @override
  String get movementNote => 'Note';

  @override
  String get movementEntryAction => 'Add to stock';

  @override
  String get movementExitAction => 'Take from stock';

  @override
  String get movementInventoryAction => 'Set the count';

  @override
  String get movementHelp =>
      'Set the count states what you counted on the shelf; the stock is corrected to it.';

  @override
  String get movementRecorded => 'Movement recorded.';

  @override
  String get movements => 'Movements';

  @override
  String get movementsEmpty => 'No movement yet.';

  @override
  String get movementEntry => 'Entry';

  @override
  String get movementExit => 'Exit';

  @override
  String get movementInventory => 'Inventory';

  @override
  String movementCounted(String count) {
    return 'counted $count';
  }

  @override
  String get suppliers => 'Suppliers';

  @override
  String get suppliersEmpty => 'No supplier yet.';

  @override
  String get addSupplier => 'Add a supplier';

  @override
  String get addSupplierButton => 'Add the supplier';

  @override
  String get editSupplier => 'Edit the supplier';

  @override
  String editSupplierOf(String name) {
    return 'Edit the supplier $name';
  }

  @override
  String get deleteSupplier => 'Delete the supplier';

  @override
  String get deleteSupplierBody =>
      'The supplier disappears from the stock item.';

  @override
  String get supplierReference => 'Supplier reference';

  @override
  String get supplierLastPrice => 'Last price paid';

  @override
  String get supplierUrl => 'Purchase link';

  @override
  String supplierHelp(String currency) {
    return 'The price is in $currency, the currency of the home. The link is only stored: Housecairn never opens it.';
  }

  @override
  String get materials => 'Materials';

  @override
  String get materialsEmpty => 'No stock item needed.';

  @override
  String get materialsHelp =>
      'Marking the task done takes these quantities from the stock; undoing puts them back.';

  @override
  String materialNeeds(String needed, String stocked) {
    return 'needs $needed · $stocked in stock';
  }

  @override
  String get materialShort => 'Not enough in stock';

  @override
  String get materialArticle => 'Stock item';

  @override
  String get addMaterial => 'Add the stock item';

  @override
  String removeMaterial(String name) {
    return 'Remove $name';
  }

  @override
  String get materialsNoArticle =>
      'The stock of this home has no item yet: add one in Rooms, Stock.';

  @override
  String stockShortAfterDone(String list) {
    return 'Not enough in stock, the stock is at zero: $list.';
  }

  @override
  String get remove => 'Remove';

  @override
  String get waysTitle => 'How do you want to use Housecairn?';

  @override
  String get waysContinue => 'Continue';

  @override
  String get waysGroup => 'How you use Housecairn';

  @override
  String get wayAloneTitle => 'Alone on this phone';

  @override
  String get wayAloneText =>
      'Your homes stay on this phone. Nothing leaves the phone, except a product\'s barcode to open product databases when you allow it. You can turn on sharing later.';

  @override
  String get wayFamilyTitle => 'Family sync';

  @override
  String get wayFamilyText =>
      'Share your homes with the phones of your family. Everything is encrypted on your phones before it leaves them: our server cannot read it. Needs a subscription.';

  @override
  String get wayServerTitle => 'My Housecairn server';

  @override
  String get wayServerText =>
      'Use the homes of your own Housecairn, the web application or the Home Assistant add-on. Your server stores your homes and can read them, like its web pages do. Everything of this phone is kept on the server; a one-time purchase unlocks it.';

  @override
  String get wayComingLater => 'Coming later';

  @override
  String get wayInUse => 'In use';

  @override
  String get errMoneyInvalid => 'Give an amount of money, such as 1250.50.';

  @override
  String get errDecimalMark =>
      'Enter a number with a point as the decimal mark, for example 12.5.';

  @override
  String get errQuoteNeedsLine =>
      'Choose the budget line the quote is committed on.';

  @override
  String get errNotInProject => 'This budget line is not in this project.';

  @override
  String get errValidityBeforeDate =>
      'The validity cannot end before the date of the quote.';

  @override
  String get errTooManyFiles => 'At most 5 files for a quote.';

  @override
  String get errFileType => 'Choose a PDF or a photo.';

  @override
  String get errTaskInProject => 'This task is already in a project.';

  @override
  String get errOnePlace => 'Choose one place.';

  @override
  String get errReportNotOpen => 'Only an open report can be made into a task.';

  @override
  String get errReportNotClosed => 'Only a closed report can be reopened.';

  @override
  String get projectInProgress => 'In progress';

  @override
  String get projectPlanned => 'Planned';

  @override
  String get projectFinished => 'Finished';

  @override
  String get projectAbandoned => 'Abandoned';

  @override
  String get projectIdea => 'Idea';

  @override
  String get projectsInProgress => 'In progress';

  @override
  String get projectsIdeas => 'Ideas';

  @override
  String get projectsFinished => 'Finished';

  @override
  String get natureMaterial => 'Materials';

  @override
  String get natureLabour => 'Labour';

  @override
  String get natureRental => 'Rental';

  @override
  String get natureOther => 'Other';

  @override
  String get quoteRequested => 'Requested';

  @override
  String get quoteReceived => 'Received';

  @override
  String get quoteAccepted => 'Accepted';

  @override
  String get quoteRejected => 'Rejected';

  @override
  String overBudgetBy(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String amountLeft(String amount) {
    return '$amount left';
  }

  @override
  String get onBudget => 'On budget';

  @override
  String get amountPlanned => 'Planned';

  @override
  String get amountCommitted => 'Committed';

  @override
  String get amountPaid => 'Paid';

  @override
  String get amountGap => 'Gap';

  @override
  String get amountUsed => 'Used';

  @override
  String percentUsed(int percent) {
    return '$percent % used';
  }

  @override
  String get stillToPay => 'Still to pay';

  @override
  String get budgetYear => 'Year';

  @override
  String envelopeOfYear(int year) {
    return 'Budget envelope $year';
  }

  @override
  String get envelopeNone => 'No envelope set for this year.';

  @override
  String get envelope => 'Envelope';

  @override
  String get envelopePlannedActive => 'Planned for the projects going on';

  @override
  String get envelopePaidSoFar => 'Paid so far';

  @override
  String get envelopeLeft => 'Left in the envelope';

  @override
  String overTheEnvelope(String amount) {
    return '$amount (over the envelope)';
  }

  @override
  String get envelopeSet => 'Set the envelope';

  @override
  String get projectsEmpty =>
      'No project yet. A project is a piece of work with an end, such as redoing the bathroom.';

  @override
  String get projectsNoneInTab => 'No project in this tab.';

  @override
  String plannedAmount(String amount) {
    return 'Planned $amount';
  }

  @override
  String get noBudgetYet => 'No budget yet';

  @override
  String get highPriority => 'High priority';

  @override
  String get lowPriority => 'Low priority';

  @override
  String get addProject => 'Add a project';

  @override
  String get projectGoal => 'Goal';

  @override
  String get roomsConcerned => 'Rooms concerned';

  @override
  String get editProject => 'Edit the project';

  @override
  String get deleteProject => 'Delete the project';

  @override
  String get deleteProjectBody =>
      'The project, its budget lines, quotes, links and files disappear from the screens; its tasks stay.';

  @override
  String get budgetHeading => 'Budget';

  @override
  String get linesEmpty =>
      'No budget line yet. Add one to say what you plan to spend.';

  @override
  String get total => 'Total';

  @override
  String get committedExplained =>
      'Committed is the sum of the accepted quotes. The gap is the planned amount less the more of committed and paid.';

  @override
  String get addLine => 'Add a budget line';

  @override
  String get editLine => 'Edit the budget line';

  @override
  String get deleteLine => 'Delete the budget line';

  @override
  String get deleteLineBody =>
      'Its accepted quotes go back to Received, committed on nothing.';

  @override
  String get lineLabel => 'Label';

  @override
  String get nature => 'Nature';

  @override
  String get linePaidHelp =>
      'What has been paid so far. The committed amount comes from accepted quotes.';

  @override
  String amountsAreIn(String currency) {
    return 'Amounts are in $currency.';
  }

  @override
  String amountIsIn(String currency) {
    return 'The amount is in $currency.';
  }

  @override
  String get quotes => 'Quotes';

  @override
  String get quotesEmpty => 'No quote yet.';

  @override
  String get noContractor => 'No contractor';

  @override
  String committedOn(String line) {
    return 'Committed on $line';
  }

  @override
  String get committedOnLabel => 'Committed on';

  @override
  String get committedOnHelp =>
      'The budget line an accepted quote is committed on.';

  @override
  String filesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String get addLineToAccept =>
      'Add a budget line to accept a quote: its amount is committed on it.';

  @override
  String get addQuote => 'Add a quote';

  @override
  String get editQuote => 'Edit the quote';

  @override
  String get deleteQuote => 'Delete the quote';

  @override
  String get deleteQuoteBody =>
      'The quote and its files disappear from the screens.';

  @override
  String get amount => 'Amount';

  @override
  String get quoteDate => 'Date';

  @override
  String get validUntil => 'Valid until';

  @override
  String get note => 'Note';

  @override
  String get quoteFiles => 'Files of the quote';

  @override
  String get quoteFilesEmpty => 'No file yet: attach the PDF of the quote.';

  @override
  String get attachQuoteFile => 'Attach a PDF or a photo';

  @override
  String get quoteFile => 'File of a quote';

  @override
  String get photo => 'Photo';

  @override
  String get projectFiles => 'Files';

  @override
  String get tasksHeading => 'Tasks';

  @override
  String get projectTasksEmpty => 'No task in this project yet.';

  @override
  String get taskDoneLabel => 'Done';

  @override
  String get addProjectTask => 'Add a task to the project';

  @override
  String get attachTask => 'Put an existing task in the project';

  @override
  String get inspiration => 'Inspiration';

  @override
  String get linksEmpty => 'No link yet.';

  @override
  String get linkNotRead =>
      'The link is kept as you typed it: the app does not read the pages. It opens in the browser of the phone.';

  @override
  String get addLinkButton => 'Add the link';

  @override
  String get linkPageAddress => 'Address of the page';

  @override
  String get linkTitle => 'Title';

  @override
  String deleteLinkOf(String title) {
    return 'Delete $title';
  }

  @override
  String get status => 'Status';

  @override
  String get priority => 'Priority';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityLow => 'Low';

  @override
  String get annualEnvelope => 'Annual envelope';

  @override
  String get envelopeHelp =>
      'What you want to spend on work this year, in the currency of the home. Empty: no envelope.';

  @override
  String get budgetSummary => 'Summary';

  @override
  String get budgetRooms => 'Rooms';

  @override
  String get budgetProjects => 'Projects';

  @override
  String get budgetUpkeep => 'Upkeep';

  @override
  String get budgetByRoom => 'Budget by room';

  @override
  String get budgetByProject => 'Budget by project';

  @override
  String get budgetOfUpkeep => 'Budget of the upkeep';

  @override
  String envelopeYear(int year) {
    return 'Envelope $year';
  }

  @override
  String get envelopeNoneSummary =>
      'No envelope set for this year: the figures are those of the plans.';

  @override
  String get spent => 'Spent';

  @override
  String get left => 'Left';

  @override
  String overBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String get spentAgainst => 'Spent against the envelope or the plans';

  @override
  String percentSpent(int percent) {
    return '$percent % spent';
  }

  @override
  String percentSpentOver(int percent) {
    return '$percent % spent: over budget';
  }

  @override
  String get detailsOfYear => 'Details of the year';

  @override
  String get plannedAll => 'Planned, projects and upkeep';

  @override
  String get leftToPlan => 'Left to plan';

  @override
  String plansExceed(String amount) {
    return '$amount (the plans exceed the envelope)';
  }

  @override
  String plannedPaid(String planned, String paid) {
    return 'planned $planned, paid $paid';
  }

  @override
  String get spentExplained =>
      'Spent is the more of committed and paid, line by line.';

  @override
  String byNature(int year) {
    return 'By nature, $year';
  }

  @override
  String get natureExplained =>
      'The cost typed on a done task is shared between Materials and Labour as its estimate is; a task with no estimate has no such share, and its cost is counted under Other.';

  @override
  String get byYear => 'By year';

  @override
  String get last12Months => 'Last 12 months';

  @override
  String rollingExplained(String since, String until) {
    return 'From $since to $until, the upkeep that was done. Payments on projects carry no date, so they are not in this figure.';
  }

  @override
  String get whereItStands => 'Where it stands';

  @override
  String missingCosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tasks were done without a cost: their estimates are counted, nothing is paid.',
      one: '1 task was done without a cost: its estimate is counted, nothing is paid.',
    );
    return '$_temp0';
  }

  @override
  String get roomsBudgetEmpty =>
      'No budget yet for this year. Give a project a budget line, or a task an estimate.';

  @override
  String get noRoom => 'No room';

  @override
  String roomsExplained(int year) {
    return 'Projects counted in $year, shared evenly between their rooms, and the upkeep of $year.';
  }

  @override
  String upkeepExplained(int year) {
    return 'The tasks that are in no project, with the occurrences of $year: those done, the one open, and those the repetition will still bring before the end of the year. An open task with no date counts in the current year. A task of a project counts in its project.';
  }

  @override
  String get projectsEmptyShort => 'No project yet.';

  @override
  String countedIn(int year) {
    return 'Counted in $year';
  }

  @override
  String plannedByTasks(String amount) {
    return 'Planned by its tasks: $amount';
  }

  @override
  String get projectsCountedExplained =>
      'Each project is counted in one year, the year it starts. An abandoned project plans nothing any more: what was paid on it shows as spent without a plan.';

  @override
  String get projectsPlannedExplained =>
      'Planned is the budget lines of the project, and what its tasks plan beyond the lines of the same nature, materials or labour: an estimate a line already holds is not counted twice.';

  @override
  String get upkeepEmpty =>
      'No task has an estimate or a cost yet. Give a task a labour or material budget.';

  @override
  String get estimateEachTime => 'Estimate each time';

  @override
  String get materialsFromStock => 'materials from the stock';

  @override
  String get costAYear => 'Cost a year';

  @override
  String get paidInAll => 'Paid in all';

  @override
  String unpricedMaterials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stock items have no unit price: they count for nothing.',
      one: '1 stock item has no unit price: it counts for nothing.',
    );
    return '$_temp0';
  }

  @override
  String unlistedTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks have no estimate nor cost and are not listed.',
      one: '1 task has no estimate nor cost and is not listed.',
    );
    return '$_temp0';
  }

  @override
  String get costAYearExplained =>
      'The cost a year follows the repetition: a task every 3 years costs a third of its estimate a year. A task that does not repeat on the calendar has none.';

  @override
  String get reportOpen => 'Open';

  @override
  String get reportMadeTask => 'Made into a task';

  @override
  String get reportResolved => 'Resolved';

  @override
  String get reportNoAction => 'Closed without action';

  @override
  String problemsReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems reported',
      one: '1 problem reported',
    );
    return '$_temp0';
  }

  @override
  String get seeReports => 'See the reports';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get reports => 'Reports';

  @override
  String get reportsOpen => 'Open';

  @override
  String get reportsClosed => 'Closed';

  @override
  String get reportsAll => 'All';

  @override
  String get reportsEmpty => 'Nothing to deal with.';

  @override
  String get reportWhere => 'Where?';

  @override
  String get reportWhereFact => 'Where';

  @override
  String get reportedOn => 'Reported on';

  @override
  String get closedOn => 'Closed on';

  @override
  String get reportTask => 'Task';

  @override
  String get reportPhoto => 'Photo of the problem';

  @override
  String get taskReportedProblem => 'Reported problem';

  @override
  String taskReportedOn(String day) {
    return 'Reported on $day';
  }

  @override
  String reportPhotoOf(String title) {
    return 'Photo of the problem: $title';
  }

  @override
  String get reportPhotoPill => 'Photo';

  @override
  String get makeItATask => 'Make it a task';

  @override
  String get markResolved => 'Mark as resolved';

  @override
  String get closeWithoutAction => 'Close without action';

  @override
  String get reopen => 'Reopen';

  @override
  String get sendReport => 'Send the report';

  @override
  String get whatIsWrong => 'What is wrong?';

  @override
  String get errSayWhatIsWrong => 'Say what is wrong.';

  @override
  String get photoChosen => 'Photo added: choose another';

  @override
  String get materialBudget => 'Material budget';

  @override
  String get labourBudget => 'Labour budget';

  @override
  String taskBudgetHelp(String currency) {
    return 'What one time of the task is planned to cost, in $currency. Empty: no estimate.';
  }

  @override
  String get realCostTitle => 'Actual cost';

  @override
  String realCost(String amount) {
    return 'Actual cost: $amount';
  }

  @override
  String get costNotTyped => 'No cost typed: tap to give it';

  @override
  String get paintArticle => 'Paint left in stock';

  @override
  String get paintArticleNone => 'None';

  @override
  String get tasksTabAll => 'All';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksToDo => 'To do';

  @override
  String get tasksDoneFilter => 'Done';

  @override
  String get tasksAllRooms => 'All rooms';

  @override
  String get tasksNone => 'Nothing to do. Add a task to start.';

  @override
  String tasksHidden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks are hidden until their date gets closer.',
      one: '$count task is hidden until its date gets closer.',
    );
    return '$_temp0';
  }

  @override
  String get tasksShowHidden => 'Show them';

  @override
  String get pagePrevious => 'Previous';

  @override
  String get pageNext => 'Next';

  @override
  String pageOf(int number, int total) {
    return 'Page $number of $total';
  }

  @override
  String filtersCount(int count) {
    return 'Filters ($count)';
  }

  @override
  String get filtersClearAll => 'Clear filters';

  @override
  String get searchClear => 'Clear the search';

  @override
  String get tasksSearchLabel => 'Search by task, room or item';

  @override
  String get historyFilters => 'Filters';

  @override
  String get historySearch => 'Search';

  @override
  String get historyAllItems => 'All items';

  @override
  String get historyEveryone => 'Everyone';

  @override
  String get historyOutcome => 'Outcome';

  @override
  String get historyDoneOrSkipped => 'Done or skipped';

  @override
  String get historyOutcomeDone => 'Done';

  @override
  String get historyOutcomeSkipped => 'Skipped';

  @override
  String get historyFrom => 'From';

  @override
  String get historyTo => 'To';

  @override
  String get historyClear => 'Clear';

  @override
  String get historyNothingMatches => 'Nothing matches.';

  @override
  String get historyNothingDone => 'Nothing done yet.';

  @override
  String historyEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String historyCost(String total, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return 'real cost: $total, entered on $_temp0';
  }

  @override
  String get seasonSection => 'In season';

  @override
  String get taskDelete => 'Delete the task';

  @override
  String taskDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get taskDeleteBody =>
      'The task, its history and its files disappear from the screens.';

  @override
  String get taskDuration => 'Estimated duration';

  @override
  String get taskDurationUnit => 'Unit of the duration';

  @override
  String get unitMinutes => 'minutes';

  @override
  String get unitHours => 'hours';

  @override
  String get taskHideDays => 'Hide until this many days before';

  @override
  String get taskHideDaysHelp => '0 shows the task as soon as it exists.';

  @override
  String get errHideDays => 'Give a number of days from 0 to 365.';

  @override
  String get errDuration =>
      'Give a duration of at least 1 and at most one year.';

  @override
  String get taskProcedure => 'How to do it';

  @override
  String get taskAddRoom => 'Add a room…';

  @override
  String get taskNewRoom => 'New room';

  @override
  String get taskNewRoomName => 'Name of the new room';

  @override
  String get taskNewRoomKind => 'Type of room';

  @override
  String get taskAddItem => 'Add an item…';

  @override
  String get taskNewItem => 'New item';

  @override
  String get taskNewItemName => 'Name of the new item';

  @override
  String get taskAddContractor => 'Add a contractor…';

  @override
  String get taskNewContractor => 'New contractor';

  @override
  String get taskNewContractorName => 'Name of the new contractor';

  @override
  String get errNewContractorName => 'Give the name of the new contractor.';

  @override
  String errNewContractorTaken(String name) {
    return '$name is already a contractor of this home: choose it in the list.';
  }

  @override
  String get taskPostponedPill => 'Postponed';

  @override
  String get taskHighPriority => 'High priority';

  @override
  String get taskLowPriority => 'Low priority';

  @override
  String get taskWhen => 'When';

  @override
  String get taskPhotosOfItem => 'Photos of the item';

  @override
  String get taskPhotosOfRoom => 'Photos of the room';

  @override
  String get taskAllPhotosOfItem => 'All photos of the item';

  @override
  String get taskAllPhotosOfRoom => 'All photos of the room';

  @override
  String get occurrenceTitle => 'Details of what was done';

  @override
  String get occurrenceDoneOn => 'Done on';

  @override
  String get occurrenceDetails => 'Details';

  @override
  String get taskEditTask => 'Edit the task';

  @override
  String get taskAddTitle => 'Add a task';

  @override
  String get taskDueOn => 'Due on';

  @override
  String get taskPostponedFrom => 'Postponed from';

  @override
  String get taskHiddenUntil => 'Hidden until';

  @override
  String taskHiddenDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days before the date',
      one: '$n day before the date',
    );
    return '$_temp0';
  }

  @override
  String get taskThen => 'Then';

  @override
  String get taskDetails => 'Details';

  @override
  String get taskCost => 'Cost';

  @override
  String get taskCostPlanned => 'Planned';

  @override
  String get taskCostReal => 'Real';

  @override
  String get taskMaterialsFromStock => 'Materials, from the stock';

  @override
  String get taskMaterialsFromStockHelp =>
      'The materials are calculated from the stock items of the task: quantity times unit price.';

  @override
  String taskMaterialFromStockField(String amount) {
    return '$amount each time, calculated from the stock items of the task.';
  }

  @override
  String get taskPaidSoFar => 'Paid so far';

  @override
  String get taskWho => 'Who';

  @override
  String get taskTimeAndBudget => 'Time and budget';

  @override
  String repeatEveryDay(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeek(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonth(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String repeatDaysAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days after the last time',
      one: 'A day after the last time',
    );
    return '$_temp0';
  }

  @override
  String repeatWeeksAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n weeks after the last time',
      one: 'A week after the last time',
    );
    return '$_temp0';
  }

  @override
  String repeatMonthsAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n months after the last time',
      one: 'A month after the last time',
    );
    return '$_temp0';
  }

  @override
  String repeatYearsAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n years after the last time',
      one: 'A year after the last time',
    );
    return '$_temp0';
  }

  @override
  String repeatMonths(String start, String end) {
    return 'from $start to $end';
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
      other: '$n days',
      one: '$n day',
    );
    return '$_temp0';
  }

  @override
  String durationWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n weeks',
      one: '$n week',
    );
    return '$_temp0';
  }

  @override
  String durationMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n months',
      one: '$n month',
    );
    return '$_temp0';
  }

  @override
  String durationYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n years',
      one: '$n year',
    );
    return '$_temp0';
  }

  @override
  String get taskAddSubmit => 'Add the task';

  @override
  String get unitMillilitreChoice => 'Millilitre (mL)';

  @override
  String get unitMillilitre => 'mL';

  @override
  String get errWarrantyDuration =>
      'A warranty lasts from 1 to 99 months or years.';

  @override
  String get equipmentTab => 'Equipment';

  @override
  String get itemsSearch => 'Search by name, brand, model or serial number';

  @override
  String get itemsEveryRoom => 'Every room';

  @override
  String itemsNext(String title) {
    return 'Next: $title';
  }

  @override
  String get itemsNoTask => 'No task to come';

  @override
  String itemsWarrantyUntil(String date) {
    return 'warranty until $date';
  }

  @override
  String itemsWarrantyEnded(String date) {
    return 'warranty ended $date';
  }

  @override
  String get itemsAllEmpty => 'No item yet. Add one from the page of a room.';

  @override
  String get itemsEmptyShort => 'No item yet.';

  @override
  String get itemsNoMatch => 'No item matches.';

  @override
  String get itemManufacturerWarranty => 'Manufacturer\'s warranty';

  @override
  String get itemPurchasedOn => 'Purchased on';

  @override
  String get warrantyDuration => 'Warranty: duration';

  @override
  String get warrantyDurationUnit => 'Warranty: in';

  @override
  String get warrantyProvider => 'Warranty: given by';

  @override
  String get warrantyProviderName =>
      'Warranty: name of the manufacturer or shop';

  @override
  String get warrantyStartsOn => 'Warranty: starts on';

  @override
  String get warrantyMonthsChoice => 'months';

  @override
  String get warrantyYearsChoice => 'years';

  @override
  String get warrantyByManufacturer => 'The manufacturer';

  @override
  String get warrantyByShop => 'The shop';

  @override
  String warrantyMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '$count month',
    );
    return '$_temp0';
  }

  @override
  String warrantyYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '$count year',
    );
    return '$_temp0';
  }

  @override
  String warrantyFrom(String date) {
    return 'from $date';
  }

  @override
  String get warrantyDurationHelp =>
      'The warranty of the manufacturer or of the shop, in months or years.';

  @override
  String get warrantyProviderNameHelp =>
      'Example: Acme, or the shop where you bought it.';

  @override
  String get warrantyStartsOnHelp => 'Empty: from the purchase date.';

  @override
  String get warrantyEndsOnHelp =>
      'Worked out from the start and the duration. Type it only when you do not know them.';

  @override
  String get saved => 'Saved';

  @override
  String get serverAddressHelp =>
      'Type the address of your Housecairn: the web application, or the port of the Home Assistant add-on. You then sign in on your server\'s own page, in the browser.';

  @override
  String get serverAddressLabel => 'Address of the server';

  @override
  String get serverAddressInvalid =>
      'This is not the address of a server. Type it as https://housecairn.example.com.';

  @override
  String get serverHttpNeedsLocalIp =>
      'Use https://. Plain http:// works only with the IP address of a server on your own network, never with a name, not even one ending in .local.';

  @override
  String get serverHttpWarning =>
      'This connection is not encrypted: anyone on this network can read what the phone sends, and the access to your server. Use it only on your own network.';

  @override
  String get serverHttpContinue => 'Continue without encryption';

  @override
  String get serverSignIn => 'Sign in';

  @override
  String get serverSigningIn =>
      'Sign in on your server\'s page in the browser, then come back here.';

  @override
  String get serverConfirmTitle => 'Connect to this server';

  @override
  String get serverSeesEverything =>
      'This server will see everything in these homes: tasks, rooms, notes, amounts and photos. So can the people who run it, the people who are members of these homes on it, and its backups. Continue only with a server you trust.';

  @override
  String get serverHomesHeading => 'Homes of this access';

  @override
  String get serverNoHomes =>
      'This access covers no home. Choose at least one on your server\'s page.';

  @override
  String get serverReadOnly => 'Read only';

  @override
  String get serverNotEncrypted => 'Not encrypted';

  @override
  String get serverConnect => 'Connect';

  @override
  String get serverCancel => 'Cancel';

  @override
  String serverTooOld(String version) {
    return 'This server is too old for the app. Update it to Housecairn $version or later.';
  }

  @override
  String get serverMobileAppOff =>
      'This server does not allow the mobile app. Its administrator can turn it on in the instance settings.';

  @override
  String get serverSignInCancelled =>
      'The sign-in was cancelled on the server\'s page.';

  @override
  String get serverSignInFailed => 'The sign-in did not finish. Try again.';

  @override
  String get serverInsecureRefused =>
      'The server refuses this connection without encryption. Use its https:// address.';

  @override
  String get serverDisconnected =>
      'This phone was disconnected from the server. Sign in again to go on syncing; your homes stay on this phone.';

  @override
  String get serverUpdateApp =>
      'The server asks for a newer version of the app before this phone can send changes.';

  @override
  String get serverCertificate =>
      'The certificate of this server is not valid. The app does not connect to it.';

  @override
  String get serverOtherHost =>
      'The server sent the app to another address. The app talks only to the address you typed.';

  @override
  String get serverUnreachable =>
      'The server cannot be reached. Check the address and the network.';

  @override
  String get serverDeviceName => 'Housecairn mobile app';

  @override
  String get errReadOnlyHome =>
      'You are a read-only member of this home on your server: nothing can be changed in it from this phone.';

  @override
  String get errOwnersOnly =>
      'Only an owner of this home on your server can archive it or bring it back.';

  @override
  String get errDeleteOnServer =>
      'A home of your server is deleted on the server\'s web page, by an owner. It then goes from this phone too.';

  @override
  String get errExampleExists =>
      'You already have an example home. Delete it to make another.';

  @override
  String get wayMoveToServerLater =>
      'Keeping this phone\'s homes on a Housecairn server comes with a later version of the app. Nothing on this phone has changed.';

  @override
  String get wayLeaveServerTitle => 'Stop syncing with the server?';

  @override
  String get wayLeaveServerText =>
      'This phone keeps a copy of its homes as they were at the last sync. They will no longer sync, and the access of this phone is revoked on the server.';

  @override
  String wayLeaveServerUnsent(int count) {
    return 'Changes not yet sent: $count. They are sent first.';
  }

  @override
  String get wayLeaveServerConfirm => 'Stop syncing';

  @override
  String get wayLeaveServerUnreachable =>
      'The server cannot be reached, so these changes cannot be sent. If you stop now, they stay on this phone only:';

  @override
  String get wayLeaveServerDrop => 'Stop and keep them on this phone only';

  @override
  String wayLeaveServerOther(int count) {
    return 'Other changes: $count';
  }

  @override
  String get settingsServerAddress => 'Connected to';

  @override
  String get settingsServerDisconnect => 'Disconnect';

  @override
  String get settingsServerDisconnectText =>
      'Revoke the access of this phone. Your homes stay on it.';

  @override
  String get settingsServerDisconnectTitle => 'Disconnect from this server?';

  @override
  String get settingsServerSignInAgain => 'Sign in again';

  @override
  String settingsServerReconnectDropped(String names) {
    return 'These homes are not in the access you chose and will leave this phone at the next sync: $names';
  }

  @override
  String get syncTitle => 'Sync with the server';

  @override
  String get syncText =>
      'The changes of this phone go to the server a moment after you make them; the server\'s come when the app opens or comes back.';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncRunning => 'Syncing…';

  @override
  String syncLast(String time) {
    return 'Last sync: $time';
  }

  @override
  String get syncNever => 'Not synced yet.';

  @override
  String get syncUnreachable =>
      'The server cannot be reached for now. Your changes stay on this phone and go with the next sync.';

  @override
  String get syncFailed =>
      'The last sync did not finish. It is tried again by itself.';

  @override
  String get syncRefusedTitle => 'Changes the server refused';

  @override
  String syncRefusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes refused by the server',
      one: '1 change refused by the server',
    );
    return '$_temp0';
  }

  @override
  String get syncRefusedHelp =>
      'The server did not take these changes; they are still on this phone. Send one again once its cause is fixed, or stop sending it: the phone then takes back the value the server has.';

  @override
  String get syncSendAgain => 'Send again';

  @override
  String get syncStopSending => 'Stop sending';

  @override
  String get syncRefusedUnnamed => 'A change without a name';

  @override
  String get syncRefusedForbidden =>
      'Your role in this home on the server does not allow this change.';

  @override
  String get syncRefusedReference =>
      'It names something that is not in this home on the server.';

  @override
  String get syncRefusedClock =>
      'The date of this phone is ahead: check it in the phone\'s settings, then send again.';

  @override
  String get syncRefusedIdTaken =>
      'The server already has another row with the same id.';

  @override
  String get syncRefusedMalformed =>
      'The server could not read this change. It stays on this phone: an update of the app that fixes it sends it again by itself.';

  @override
  String syncRefusedConcerns(String thing) {
    return 'Concerns: $thing';
  }

  @override
  String syncRefusedAnswer(String detail) {
    return 'The server\'s answer: $detail';
  }

  @override
  String get syncRefusedTooLarge => 'This change is too large for the server.';

  @override
  String get syncRefusedDevice =>
      'The server knows this phone under another id. Sign in again on this phone.';

  @override
  String get syncRefusedSignIn =>
      'This home asks for a sign-in with its own sign-in service. Sign in again on this phone with that service, then send it again.';

  @override
  String get syncRefusedConflict =>
      'The server already took other changes under the number of this send. Send it again.';

  @override
  String syncRefusedOther(String code) {
    return 'The server refused this change (code $code).';
  }

  @override
  String get syncNoticesTitle => 'Since the last syncs';

  @override
  String syncNoticesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things to read about the sync',
      one: '1 thing to read about the sync',
    );
    return '$_temp0';
  }

  @override
  String get syncNoticeUndoReverted =>
      'An undo was taken back: the next time of this task was changed on another device meanwhile.';

  @override
  String get syncNoticeDropped =>
      'Something deleted on the server was removed from this phone.';

  @override
  String get syncNoticeViewChanged =>
      'What you can see in this home changed. This phone was updated.';

  @override
  String get syncNoticesRead => 'Mark as read';

  @override
  String get settingsFilesTitle => 'Photos and files to send';

  @override
  String settingsFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos or files are waiting to be sent.',
      one: '1 photo or file is waiting to be sent.',
      zero: 'Nothing is waiting to be sent.',
    );
    return '$_temp0';
  }

  @override
  String get settingsFilesSendNow => 'Send now';

  @override
  String get filesRefusedTooLarge =>
      'A file is larger than the server takes. It stays on this phone.';

  @override
  String get filesRefusedQuota =>
      'The server has no room left for more files. Free some space on it, then send again.';

  @override
  String get filesRefusedType =>
      'The server does not take this kind of file. It stays on this phone.';

  @override
  String get filesRefusedMalformed =>
      'A file did not match what this phone sent, so the server did not keep it. It stays on this phone.';

  @override
  String get filesRefusedForbidden =>
      'Your role in this home on the server does not allow sending files.';

  @override
  String get filesRefusedConflict =>
      'The server already holds another file under the same name.';

  @override
  String get filesRefusedSeveral => 'The server did not take some files.';

  @override
  String filesRefusedOther(String code) {
    return 'The server did not take a file (code $code).';
  }

  @override
  String get roomKindHelp =>
      'Sets the icon and the filters of the room and, later, the task templates offered for it. Choose Other if none fits.';

  @override
  String get roomNameHelp =>
      'Fills in by itself from the type; change it to name the room.';

  @override
  String get itemRoomHelp =>
      'Where the item is. Choose another room to move it.';

  @override
  String get homeCurrencyHelp =>
      'ISO 4217 code of the currency used for this home\'s budget.';

  @override
  String get homeHemisphereHelp =>
      'Where the home is, for the seasons: spring in the north starts in March, in the south in September.';

  @override
  String get editHome => 'Edit the home';

  @override
  String get projectSectionRooms => 'Rooms, duration and season';

  @override
  String get projectSeason => 'Preferred season';

  @override
  String get projectSeasonAnyTime => 'Any time';

  @override
  String projectSeasonHemisphereHelp(String hemisphere) {
    return 'The season follows the hemisphere of the home ($hemisphere): change it in the settings of the home.';
  }

  @override
  String get materialsFormHelp =>
      'Stock items the task needs, with the quantity. Marking the task done takes these quantities from the stock.';

  @override
  String get addMaterialLine => 'Add a line';

  @override
  String get removeMaterialLine => 'Remove this line';

  @override
  String materialsLimit(int max) {
    return 'A task lists at most $max stock items.';
  }

  @override
  String reportPhotoHelpSize(String max) {
    return 'A photo is optional: a JPEG, PNG or WebP image, $max at most. Its location and other metadata are removed.';
  }

  @override
  String sizeMegabytes(int count) {
    return '$count MB';
  }

  @override
  String get attachmentsHeading => 'Photos and files';

  @override
  String get addAttachments => 'Add photos or files';

  @override
  String get attachmentsEmpty => 'No file yet.';

  @override
  String get attachmentPickFile => 'Choose a file (PDF or photo)';

  @override
  String attachmentPhotoLabel(String name) {
    return 'Photo: $name';
  }

  @override
  String get attachmentDelete => 'Delete';

  @override
  String attachmentDeleteBody(String name) {
    return '$name disappears from the task.';
  }

  @override
  String get attachmentDeleted => 'File deleted.';

  @override
  String get errTooManyAttachments => 'At most 30 attachments for a task.';

  @override
  String get fileNotHere => 'File not on this phone';

  @override
  String get fileOpen => 'Open';

  @override
  String get fileOpenFailed => 'No app of this phone opens this file.';

  @override
  String fileSizeBytes(int count) {
    return '$count bytes';
  }

  @override
  String fileSizeKb(String count) {
    return '$count KB';
  }

  @override
  String fileSizeMb(String count) {
    return '$count MB';
  }

  @override
  String articleLabelPhoto(String name) {
    return 'Label of $name';
  }

  @override
  String get guide => 'Guide';

  @override
  String get moreGuideText => 'Five scenarios to try on an example home';

  @override
  String get guideLead =>
      'Five short scenarios, done for real on an example home with fictional values. You delete the example home in one press when you are done.';

  @override
  String guideNumbered(int number, String title) {
    return '$number. $title';
  }

  @override
  String guideStepNumbered(int scenario, String step, String title) {
    return '$scenario.$step $title';
  }

  @override
  String guideProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get guideScenarioDone => 'Done';

  @override
  String get guideStepDone => 'Done';

  @override
  String get guideOptional => 'Optional';

  @override
  String get guideFill => 'Fill in for me';

  @override
  String get guideOpen => 'Open';

  @override
  String get guideMarkDone => 'Mark as done';

  @override
  String get guideNeedsHome =>
      'Add the example home first, in the first scenario.';

  @override
  String get guideCatchUpText =>
      'The earlier scenarios are not all done. The guide can add what they make to the example home, so that you can start here.';

  @override
  String get guideCatchUpNoHome =>
      'There is no example home yet. The guide can make it, with what the earlier scenarios add, so that you can start here.';

  @override
  String get guideCatchUp => 'Add what the earlier scenarios make';

  @override
  String get guideCaughtUp =>
      'The earlier scenarios are done in the example home.';

  @override
  String get guideBack => 'Back to the guide';

  @override
  String get exampleHome => 'Example home';

  @override
  String get exampleBannerText =>
      'Fictional values, to try Housecairn for real. It stays on this phone.';

  @override
  String get exampleDelete => 'Delete the example home';

  @override
  String get exampleDeleteTitle => 'Delete the example home?';

  @override
  String get exampleDeleteBody =>
      'Everything in it goes, for good. Your other homes do not change.';

  @override
  String get exampleDeleted => 'The example home was deleted.';

  @override
  String get exampleMark => 'Example';

  @override
  String get exampleNewHomeNotice =>
      'This is the example home of the guide: its values are fictional, and you delete it in one press when you are done.';

  @override
  String get todayGuideText =>
      'Not sure where to start? Try Housecairn on an example home, in five short scenarios.';

  @override
  String get todayGuideOpen => 'Open the guide';

  @override
  String guidePrevious(String title) {
    return '‹ $title';
  }

  @override
  String guideNext(String title) {
    return '$title ›';
  }

  @override
  String get qrLabels => 'QR labels';

  @override
  String get qrLabel => 'QR label';

  @override
  String get moreLabelsText =>
      'Stickers that open a room, an item or an article';

  @override
  String get scanLabel => 'Scan a label';

  @override
  String get makeQrLabel => 'Make a QR label';

  @override
  String labelOf(String name) {
    return 'QR label of $name';
  }

  @override
  String labelQrOf(String name) {
    return 'QR code of $name';
  }

  @override
  String get labelHolds =>
      'The QR code holds this code and nothing else, no address:';

  @override
  String get labelOpenPage => 'Open the page';

  @override
  String get labelPrint => 'Print';

  @override
  String get labelLayout => 'Layout';

  @override
  String get labelLayoutA4 => 'A4 sheet, 3 by 8 labels (63.5 by 33.9 mm)';

  @override
  String get labelLayoutRoll =>
      '62 mm roll, one label per page (label printer)';

  @override
  String get labelPrintThis => 'Print this label';

  @override
  String get labelLostTitle => 'If the sticker is lost or shared';

  @override
  String get labelLostText =>
      'A new label has a new code; the old sticker stops opening anything.';

  @override
  String get labelRegenerate => 'Make a new label';

  @override
  String get labelRevoke => 'Revoke the label';

  @override
  String get labelRevokeTitle => 'Revoke the label?';

  @override
  String get labelRevokeBody =>
      'The sticker will no longer open anything. A revoked label cannot be brought back.';

  @override
  String get labelRevoked =>
      'QR label revoked: the sticker no longer opens anything.';

  @override
  String get labelRegenerated =>
      'The old sticker no longer opens anything. Print the new label.';

  @override
  String get labelsIntro =>
      'Tick what to label, choose a layout and print the sheet. Scanning a sticker with this phone opens the page of the object.';

  @override
  String get labelNoneYet => 'No label yet';

  @override
  String get labelNone => 'No label';

  @override
  String labelsMax(int max) {
    return 'Up to $max labels at a time.';
  }

  @override
  String get labelsMadeForTicked =>
      'A label is made for each object ticked that has none.';

  @override
  String get labelsReadOnly =>
      'You can print the labels that exist; members who can edit make new ones.';

  @override
  String get labelsPrint => 'Print the labels';

  @override
  String get labelsEmpty =>
      'Nothing to label yet: add rooms, items or stock items first.';

  @override
  String get labelsChoose => 'Choose the objects from the list.';

  @override
  String get labelSectionRooms => 'Rooms';

  @override
  String get labelSectionItems => 'Items';

  @override
  String get labelSectionArticles => 'Stock items';

  @override
  String get labelKindRoom => 'Room';

  @override
  String get labelKindItem => 'Item';

  @override
  String get labelKindArticle => 'Stock item';

  @override
  String get scanHint => 'Point the camera at the QR code of a label.';

  @override
  String get scanCamera => 'Camera';

  @override
  String get scanDenied =>
      'Housecairn needs the camera to read a code. Allow it in the settings of the phone, then try again.';

  @override
  String get scanUnavailable => 'This phone has no camera to read a code.';

  @override
  String get scanNotLabel => 'This QR code is not a Housecairn label.';

  @override
  String get scanUnknown =>
      'This label is not known on this phone. It was made on another phone or on the web, or its home is not on this phone.';

  @override
  String get scanRevoked =>
      'This label was revoked: it no longer opens anything.';

  @override
  String get scanGone => 'What this label opened was deleted.';

  @override
  String get errTooManyLabels => 'Choose between 1 and 200 labels.';

  @override
  String get compareProjects => 'Compare projects';

  @override
  String get compareTicked => 'Compare the ticked projects';

  @override
  String get compareTickTwo =>
      'Tick at least two projects in the list to compare them.';

  @override
  String get compareCaption => 'The projects side by side';

  @override
  String get compareProject => 'Project';

  @override
  String get comparePlannedCost => 'Planned cost';

  @override
  String get compareDuration => 'Duration';

  @override
  String get selectRows => 'Select';

  @override
  String get barcodeField => 'Barcode (EAN)';

  @override
  String get barcodeHelp =>
      'The 8 to 14 digits under the bars. Scan it, or type it.';

  @override
  String get barcodeScan => 'Scan';

  @override
  String get barcodeScanLabel => 'Scan the barcode with the camera';

  @override
  String get barcodeScanTitle => 'Scan a barcode';

  @override
  String get barcodeScanHint => 'Hold the barcode in front of the camera.';

  @override
  String get barcodeNoCamera =>
      'No camera could be used. Type the digits under the bars.';

  @override
  String get barcodeLooking => 'Looking this code up…';

  @override
  String get barcodeTakingLong =>
      'The lookup is taking long. Scan the code again in a moment.';

  @override
  String barcodeFound(String source) {
    return 'Found in $source. Check before you use it: only the empty fields are filled, nothing is saved until you save the form.';
  }

  @override
  String get barcodeCategory => 'Category';

  @override
  String get barcodePhoto => 'Photo of the product';

  @override
  String get barcodeKeepPhoto => 'Keep this photo, if the sheet has none';

  @override
  String get barcodeUse => 'Use these values';

  @override
  String get barcodeNotFound =>
      'This code is in none of the open databases. Fill the sheet by hand.';

  @override
  String get barcodeFailed =>
      'The open databases could not be read. Try again later, or fill the sheet by hand.';

  @override
  String get barcodeInvalid =>
      'This code is not a valid barcode: check its digits.';

  @override
  String get barcodeLimited =>
      'Too many codes looked up in a short time. Try again in a minute.';

  @override
  String get barcodeOffline =>
      'No connection: the code is kept with the sheet. Fill it by hand, or scan again later.';

  @override
  String get barcodeOffAlone =>
      'The code is kept with the sheet. Looking it up in the open databases is off on this phone (Settings, in More).';

  @override
  String get barcodeOffServer =>
      'The code is kept with the sheet. Looking it up in the open databases is off on this server.';

  @override
  String get barcodeServerUnavailable =>
      'The code is kept with the sheet. This server does not look codes up for the app yet.';

  @override
  String photoBy(String author) {
    return 'Photo by $author';
  }

  @override
  String get barcodeConsentTitle => 'Look up barcodes';

  @override
  String get barcodeConsentIntro =>
      'The phone can ask open databases what a scanned code is, to fill the name, the brand and a photo for you.';

  @override
  String get barcodeConsentWhatTitle => 'What leaves the phone';

  @override
  String get barcodeConsentWhat =>
      'The code you scan, and nothing else: no name, no home, no account. Only when you scan.';

  @override
  String get barcodeConsentWhoTitle => 'To whom';

  @override
  String get barcodeConsentWho =>
      'Open Products Facts, then Open Food Facts, two open databases of the Open Food Facts project. Like any website, they see the address of your connection.';

  @override
  String get barcodeConsentLicenceTitle => 'Licences';

  @override
  String get barcodeConsentLicence =>
      'Their data is under the ODbL and their photos under CC BY-SA 3.0: a photo kept shows its author and its source under it.';

  @override
  String get barcodeConsentChange =>
      'You can change this at any time in Settings, in More. Without it, a scan only fills the code.';

  @override
  String get barcodeConsentAllow => 'Allow the lookup';

  @override
  String get barcodeConsentRefuse => 'Keep only the code';

  @override
  String get barcodeLookupSetting => 'Online lookup of barcodes';

  @override
  String get barcodeLookupSettingText =>
      'Ask Open Products Facts, then Open Food Facts, what a scanned code is. Only the code is sent, nothing else. Off: a code is only kept.';

  @override
  String get errEanInvalid =>
      'Not a valid barcode: type the 8, 12, 13 or 14 digits under the bars (EAN-8, UPC-A, EAN-13 or GTIN-14).';

  @override
  String get materialAddArticle => 'Add a stock item…';

  @override
  String get materialNewArticle => 'New stock item';

  @override
  String get materialNewArticleName => 'Name of the new stock item';

  @override
  String get materialNewArticleHelp =>
      'Only used with Add a stock item… in the list above. The item joins the stock of the home when you save the task; complete it on its sheet.';

  @override
  String get errNewArticleName => 'Give the name of the new stock item.';

  @override
  String errNewArticleInStock(String name) {
    return '$name is already in the stock of this home: choose it in the list.';
  }

  @override
  String errNewArticleTwice(String name) {
    return '$name is already added by another line: a stock item is listed once.';
  }

  @override
  String get roomStockEmpty => 'No stock item for this room yet.';

  @override
  String get itemMaterials => 'Materials';

  @override
  String get itemStockEmpty => 'No stock item linked to this yet.';

  @override
  String itemStockUnitPrice(String price) {
    return '$price each';
  }

  @override
  String get itemStockLink => 'Link a stock item…';

  @override
  String get itemStockNew => 'New stock item…';

  @override
  String get itemStockLinkTitle => 'Link stock items';

  @override
  String get itemStockLinkIntro =>
      'The stock items of this home that do not fit this item yet. Those you tick fit it, as in their Compatible items.';

  @override
  String get itemStockLinkAction => 'Link';

  @override
  String get itemStockLinkNone =>
      'Every stock item of this home already fits this item.';

  @override
  String get itemStockNoneTicked => 'Tick at least one stock item.';
}
