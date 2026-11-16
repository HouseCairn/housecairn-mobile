// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'theme.dart';
import 'tokens.dart';

/// The brand of the bar of a section root, as the web shows it on a phone
/// (`shell/brand.html`, `shell.css`): the cairn at `layout.logo-icon` (40),
/// then the name in bold 20/800, on one line. The icon is the web's
/// `housecairn-icon.svg` as a PNG at 1x, 2x and 3x (flutter_svg is not a
/// dependency, tool/generate_icons.py draws them). Read as one image named
/// "HouseCairn".
///
/// The name keeps its size whatever the text size of the phone, like the
/// labels of the bottom bar. Where the bar has no room for all of it (two
/// homes, a long name of home, a narrow phone, a large text), the name goes
/// and the cairn stays, rather than a name cut to two letters or actions
/// pushed off the screen.
class HcBrand extends StatelessWidget {
  const HcBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final brandName = AppLocalizations.of(context).brandName;
    final name = TextPainter(
      text: TextSpan(text: brandName, style: HcText.brand),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final needed = HcLayout.logoIcon + HcSpace.s2 + name.width;
    name.dispose();
    return Semantics(
      label: brandName,
      image: true,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: HcLayout.touchTargetLg),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/brand/housecairn-icon.png',
                key: const Key('brand-icon'),
                width: HcLayout.logoIcon,
                height: HcLayout.logoIcon,
                excludeFromSemantics: true,
              ),
              if (constraints.maxWidth >= needed) ...[
                const SizedBox(width: HcSpace.s2),
                Text(
                  brandName,
                  key: const Key('brand-name'),
                  maxLines: 1,
                  softWrap: false,
                  textScaler: TextScaler.noScaling,
                  style: HcText.brand,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
