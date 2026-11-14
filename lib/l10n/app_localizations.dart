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
