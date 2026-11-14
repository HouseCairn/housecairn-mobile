// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import 'design/theme.dart';
import 'l10n/app_localizations.dart';
import 'ui/shell.dart';
import 'ui/state.dart';

/// The app: theme, languages, the homes of the phone and the shell with its
/// five sections.
class HousecairnApp extends StatelessWidget {
  const HousecairnApp({super.key, required this.state, this.locale});

  /// The homes of the phone and the repository that writes them.
  final AppState state;

  /// Language forced by a test; `null` follows the phone.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
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
        home: const _FirstStart(child: Shell()),
      ),
    );
  }
}

/// Reads the homes once the language is known, and makes the first home,
/// named in that language, at the first start (docs/spec.md, "Homes").
class _FirstStart extends StatefulWidget {
  const _FirstStart({required this.child});

  final Widget child;

  @override
  State<_FirstStart> createState() => _FirstStartState();
}

class _FirstStartState extends State<_FirstStart> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    AppScope.of(context)
        .refresh(firstHomeName: AppLocalizations.of(context).firstHomeName);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
