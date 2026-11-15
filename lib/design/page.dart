// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'theme.dart';
import 'tokens.dart';

/// The header of a screen (design/patterns.md of the web, "Header: title,
/// back, actions"): a compact bar with the back button on the left and one
/// action at most on the right, then the title as the `h1` (24/800) at the
/// top of the content, where it wraps instead of being cut ("Report a pro…").
///
/// On an iPhone the title folds into the bar once the content is scrolled
/// (large title of iOS, platform adaptation 6); on Android it scrolls away
/// with the content, as on the web. A form opened as a sheet on iOS
/// ([hcRoute], adaptation 7) has Cancel on the left of its bar and its save,
/// with the web's label, on the right.
class HcScaffold extends StatefulWidget {
  const HcScaffold({
    super.key,
    this.title,
    this.actions = const [],
    this.body = const SizedBox.shrink(),
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  /// The `h1` of the screen; null for a screen still loading.
  final String? title;

  /// The action of the bar: Edit on a record, the save of a form, or the
  /// selector of the home on a section root.
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  State<HcScaffold> createState() => _HcScaffoldState();
}

/// Whether the app draws the controls of iOS (design/patterns.md, Platform
/// adaptations): on an iPhone, and on a Mac.
bool hcCupertino(TargetPlatform platform) =>
    platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

class _HcScaffoldState extends State<HcScaffold> {
  bool _folded = false;

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final folded = n.metrics.pixels > HcSpace.s8;
    if (folded != _folded) setState(() => _folded = folded);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cupertino = hcCupertino(Theme.of(context).platform);
    final route = ModalRoute.of(context);
    final sheet = cupertino && route is PageRoute && route.fullscreenDialog;
    final title = widget.title;
    return Scaffold(
      appBar: AppBar(
        // The bar shows the title only on iOS, once the h1 is scrolled away.
        title: title != null && cupertino
            ? AnimatedOpacity(
                opacity: _folded ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Text(
                  title,
                  style: HcText.rowTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        centerTitle: cupertino,
        automaticallyImplyLeading: !sheet,
        leadingWidth: sheet ? HcSpace.s12 + HcSpace.s12 + HcSpace.s4 : null,
        leading: sheet
            ? MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: TextButton(
                  key: const Key('sheet-cancel'),
                  style: TextButton.styleFrom(textStyle: HcText.buttonSmall),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(AppLocalizations.of(context).cancel),
                ),
              )
            : null,
        actions: widget.actions,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: HcPageTitle(title: title, child: widget.body),
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}

/// The title of the screen, for the list of its content ([HcLargeTitle] is
/// drawn first by `HcScreenList`).
class HcPageTitle extends InheritedWidget {
  const HcPageTitle({super.key, required this.title, required super.child});

  final String? title;

  static String? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HcPageTitle>()?.title;

  @override
  bool updateShouldNotify(HcPageTitle oldWidget) => title != oldWidget.title;
}

/// The `h1` of a screen, at the top of its content: 24/800, wrapping, a
/// heading for screen readers.
class HcLargeTitle extends StatelessWidget {
  const HcLargeTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      HcSpace.s1,
      HcSpace.s2,
      HcSpace.s1,
      HcSpace.s2,
    ),
    child: Semantics(
      header: true,
      child: Text(title, key: const Key('page-title'), style: HcText.pageTitle),
    ),
  );
}

/// A screen that is a form: on iOS it opens as a modal sheet ([hcRoute]).
abstract interface class HcFormScreen {
  /// Whether it opens as a sheet. The task screen is still the page of the
  /// task until it has its own page to read (lot D2): only its creation is a
  /// sheet.
  bool get opensAsSheet;
}

/// The route of [page]: a page, or a modal sheet for a form on iOS
/// (design/patterns.md, Platform adaptations 7). On Android a form stays a
/// page, its back button being Cancel.
Route<void> hcRoute(Widget page) => MaterialPageRoute<void>(
  builder: (_) => page,
  fullscreenDialog:
      (page as Object) is HcFormScreen &&
      (page as HcFormScreen).opensAsSheet &&
      hcCupertino(defaultTargetPlatform),
);
