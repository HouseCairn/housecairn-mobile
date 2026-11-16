// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'brand.dart';
import 'icons.dart';
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
    this.drawsTitle = true,
    this.brand = false,
    this.belowTitle,
  });

  /// The `h1` of the screen; null for a screen still loading.
  final String? title;

  /// Whether the list of the content draws [title] as its first line; false
  /// for a screen that draws its `h1` itself (the page of a task, under its
  /// pills, lot D2). The title still folds into the bar on iOS.
  final bool drawsTitle;

  /// Whether the bar shows the brand (icon and name), on the roots of the
  /// five sections only, as the web's phone bar does (`.has-nav.subpage
  /// .brand { display: none }`). The `h1` stays under it, and does not fold
  /// into the bar on iOS: the brand keeps the place.
  final bool brand;

  /// What the content shows under the `h1` of a section root: the selector of
  /// the current home, a compact line (design/patterns.md of the web,
  /// "Header"). Drawn by [HcScreenList], never in the bar.
  final Widget? belowTitle;

  /// The action of the bar: Edit on a record, the save of a form, or the help
  /// button of a page that has no other action.
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

  /// The back button of iOS: the chevron and the title of the previous page,
  /// as the web's `‹ Rooms` (platform adaptation 5).
  Widget _iosBack(BuildContext context, ModalRoute<Object?> route) {
    final previous = HcBackTitles.previousTitle(route);
    return HcBackButton(title: previous);
  }

  double _backWidth(BuildContext context, ModalRoute<Object?> route) {
    final previous = HcBackTitles.previousTitle(route);
    return HcBackButton.widthFor(context, previous);
  }

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
    if (title != null && route != null) HcBackTitles.remember(route, title);
    final iosBack = cupertino && !sheet && route != null && route.canPop;
    return Scaffold(
      appBar: AppBar(
        // The bar shows the title only on iOS, once the h1 is scrolled away.
        title: widget.brand
            ? const HcBrand()
            : title != null && cupertino
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
        centerTitle: cupertino && !widget.brand,
        automaticallyImplyLeading: !sheet && !iosBack,
        leadingWidth: sheet
            ? HcSpace.s12 + HcSpace.s12 + HcSpace.s4
            : iosBack
            ? _backWidth(context, route)
            : null,
        leading: iosBack
            ? _iosBack(context, route)
            : sheet
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
        child: HcPageTitle(
          title: widget.drawsTitle ? title : null,
          belowTitle: widget.belowTitle,
          child: widget.body,
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}

/// The title of the screen, for the list of its content ([HcLargeTitle] is
/// drawn first by `HcScreenList`).
class HcPageTitle extends InheritedWidget {
  const HcPageTitle({
    super.key,
    required this.title,
    this.belowTitle,
    required super.child,
  });

  final String? title;

  /// The line under the `h1` ([HcScaffold.belowTitle]).
  final Widget? belowTitle;

  static String? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HcPageTitle>()?.title;

  static Widget? belowOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HcPageTitle>()?.belowTitle;

  @override
  bool updateShouldNotify(HcPageTitle oldWidget) =>
      title != oldWidget.title || belowTitle != oldWidget.belowTitle;
}

/// The titles of the pages of a navigator, for the back button of iOS, which
/// names the page it goes back to (`‹ Rooms`, platform adaptation 5). A
/// [NavigatorObserver] records which route lies under each pushed route; each
/// [HcScaffold] records its title on its own route.
class HcBackTitles extends NavigatorObserver {
  static final _under = Expando<Route<Object?>>();
  static final _titles = Expando<String>();

  static void remember(Route<Object?> route, String title) =>
      _titles[route] = title;

  /// The title of the page under [route], null when there is none.
  static String? previousTitle(Route<Object?> route) {
    final under = _under[route];
    return under == null ? null : _titles[under];
  }

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) =>
      _under[route] = previousRoute;

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) {
    if (newRoute != null) {
      _under[newRoute] = oldRoute == null ? null : _under[oldRoute];
    }
  }
}

/// The back button of iOS: the chevron and the title of the previous page,
/// in the primary colour, at most two fifths of the bar wide.
class HcBackButton extends StatelessWidget {
  const HcBackButton({super.key, required this.title});

  final String? title;

  static const _gap = HcSpace.s1;

  /// The width the button needs: the chevron and [title] on one line.
  static double widthFor(BuildContext context, String? title) {
    final icon = HcLayout.touchTargetLg;
    if (title == null) return icon;
    final text = TextPainter(
      // The style the title is drawn in: the theme's text style under the
      // role's own (the font family comes from the theme).
      text: TextSpan(
        text: title,
        style: DefaultTextStyle.of(context).style.merge(HcText.rowTitle),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    // The start padding, the chevron, the gap and the title, and a pixel
    // for the rounding of the text.
    final needed = HcSpace.s2 + HcComponent.iconSize + _gap + text.width + 1;
    text.dispose();
    final most = MediaQuery.sizeOf(context).width * 2 / 5;
    return needed < icon ? icon : (needed > most ? most : needed);
  }

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final ltr = Directionality.of(context) == TextDirection.ltr;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      excludeSemantics: true,
      child: InkWell(
        key: const Key('ios-back'),
        onTap: () => Navigator.of(context).maybePop(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HcLayout.touchTargetLg),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: HcSpace.s2),
            child: Row(
              children: [
                Transform.flip(
                  flipX: ltr,
                  child: const HcIcon(
                    HcIcons.chevron,
                    size: HcComponent.iconSize,
                    color: HcColors.primary,
                  ),
                ),
                if (title != null) ...[
                  const SizedBox(width: _gap),
                  Flexible(
                    child: Text(
                      title,
                      key: const Key('ios-back-title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HcText.rowTitle.copyWith(color: HcColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
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
  /// Whether it opens as a sheet. The task screen is the page of a task that
  /// exists (lot D2): only its creation is a sheet; the form of the task,
  /// opened by Edit the task, always is.
  bool get opensAsSheet;
}

/// The route of [page]: a page, or a modal sheet for a form on iOS
/// (design/patterns.md, Platform adaptations 7). On Android a form stays a
/// page, its back button being Cancel.
Route<void> hcRoute(Widget page) => hcRouteOf<void>(page);

/// [hcRoute] for a screen that gives back a [T] when it closes (the form of
/// a task says whether the task is kept).
Route<T> hcRouteOf<T>(Widget page) => MaterialPageRoute<T>(
  builder: (_) => page,
  fullscreenDialog:
      (page as Object) is HcFormScreen &&
      (page as HcFormScreen).opensAsSheet &&
      hcCupertino(defaultTargetPlatform),
);
