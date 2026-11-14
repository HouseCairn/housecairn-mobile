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
}
