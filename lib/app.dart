// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import 'design/theme.dart';
import 'l10n/app_localizations.dart';
import 'ui/shell.dart';
import 'ui/state.dart';
import 'ui/ways.dart';

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

/// Reads the homes once the language is known. At the first start it shows
/// the three ways to use the app; the first home, named in that language, is
/// made when the person chooses one (docs/spec.md, "Homes"; ADR 0010).
class _FirstStart extends StatefulWidget {
  const _FirstStart({required this.child});

  final Widget child;

  @override
  State<_FirstStart> createState() => _FirstStartState();
}

class _FirstStartState extends State<_FirstStart> {
  bool _started = false;
  AppLifecycleListener? _lifecycle;

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final languageChanged = state.l10n?.localeName != l10n.localeName;
    // The words of the reminders follow the language of the phone.
    state.l10n = l10n;
    if (!_started) {
      _started = true;
      // The homes, the reminder tapped, and a sync with the server in the
      // third way; another each time the app comes back to the front.
      state.open(firstHomeName: l10n.firstHomeName);
      _lifecycle = AppLifecycleListener(onResume: state.resumed);
    } else if (languageChanged) {
      state.reschedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.loaded) return const Scaffold();
    if (state.firstStart) return const WaysScreen();
    return widget.child;
  }
}
