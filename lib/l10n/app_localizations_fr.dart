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
}
