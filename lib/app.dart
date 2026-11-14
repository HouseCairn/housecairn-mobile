// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import 'design/theme.dart';
import 'l10n/app_localizations.dart';
import 'ui/shell.dart';

/// The app: theme, languages and the shell with its five sections.
class HousecairnApp extends StatelessWidget {
  const HousecairnApp({super.key, this.locale});

  /// Language forced by a test; `null` follows the phone.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: housecairnTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      // The delegates of material_ui (Material, Cupertino, widgets): the ones
      // of the generated AppLocalizations.localizationsDelegates are those of
      // flutter_localizations, deprecated since Flutter 3.47 and not read by
      // the widgets of material_ui.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: const Shell(),
    );
  }
}
