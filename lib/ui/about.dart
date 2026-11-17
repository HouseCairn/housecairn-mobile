// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import 'help_button.dart';
import '../l10n/app_localizations.dart';
import '../version.dart';
import 'state.dart';

/// About, as the web's `core/about.html`: a centred card with the cairn, the
/// name, the version and build number read from the platform at run time,
/// the author attribution required by NOTICE (AGPL-3.0, section 7(b)), the
/// licence and the link to the source code; then a card of links, as the
/// web's `core/about_links.py`, with the iPhone beta, which can be opened or
/// copied. The licences of the packages the app includes are a link of the
/// first card.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // The version and the build number of the installed app, as the platform
  // knows them (CFBundleShortVersionString and CFBundleVersion on iOS,
  // versionName and versionCode on Android): both come from pubspec.yaml.
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  Future<void> _open(BuildContext context, String address) async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await state.openUrl(Uri.parse(address))) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.aboutBetaCannotOpen)));
    }
  }

  Future<void> _copyBeta(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(const ClipboardData(text: testFlightAddress));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.aboutBetaCopied)));
  }

  Future<void> _licences(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final info = await _info;
    if (!context.mounted) return;
    showLicensePage(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: info.version,
      applicationLegalese: l10n.aboutAttribution,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget small(String text) => Padding(
      padding: const EdgeInsets.only(bottom: HcSpace.s2),
      child: Text(text, textAlign: TextAlign.center, style: HcText.rowText),
    );
    return HcScaffold(
      title: l10n.about,
      actions: const [HelpButton(page: HelpPages.about)],
      body: HcScreenList(
        children: [
          HcCard(
            key: const Key('about-card'),
            child: Column(
              children: [
                Image.asset(
                  'assets/brand/housecairn-icon.png',
                  key: const Key('about-logo'),
                  width: HcComponent.aboutLogo,
                  height: HcComponent.aboutLogo,
                  excludeFromSemantics: true,
                ),
                HcSectionHeading(l10n.brandName),
                FutureBuilder<PackageInfo>(
                  future: _info,
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    if (info == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: HcSpace.s2),
                      child: SelectableText(
                        l10n.aboutVersion(info.version, info.buildNumber),
                        key: const Key('about-version'),
                        textAlign: TextAlign.center,
                        style: HcText.body.copyWith(fontWeight: HcFont.heavy),
                      ),
                    );
                  },
                ),
                small(l10n.aboutAttribution),
                small(l10n.aboutLicence),
                HcLink(
                  l10n.aboutSourceLink,
                  key: const Key('about-source'),
                  onTap: () => _open(context, 'https://$sourceAddress'),
                ),
                small(l10n.aboutAi),
                HcLink(
                  l10n.aboutLicences,
                  key: const Key('about-licences'),
                  onTap: () => _licences(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: HcSpace.s3),
          HcCard(
            key: const Key('about-links'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HcSectionHeading(l10n.aboutLinks),
                Wrap(
                  spacing: HcSpace.s2,
                  runSpacing: HcSpace.s2,
                  children: [
                    for (final (key, icon, label, address) in [
                      ('site', HcIcons.globe, l10n.linkWebsite, siteAddress),
                      ('docs', HcIcons.book, l10n.linkDocs, docsAddress),
                      ('app', HcIcons.code, l10n.linkAppCode, webSourceAddress),
                      ('addon', HcIcons.puzzle, l10n.linkAddon, addonAddress),
                      (
                        'integration',
                        HcIcons.plug,
                        l10n.linkIntegration,
                        integrationAddress,
                      ),
                      (
                        'mobile',
                        HcIcons.phone,
                        l10n.linkMobile,
                        'https://$sourceAddress',
                      ),
                    ])
                      _LinkTile(
                        key: Key('about-link-$key'),
                        icon: icon,
                        label: label,
                        onTap: () => _open(context, address),
                      ),
                    _LinkTile(
                      key: const Key('about-link-android'),
                      icon: HcIcons.phoneDownload,
                      label: l10n.linkAndroid,
                      soon: l10n.comingSoon,
                    ),
                  ],
                ),
                const SizedBox(height: HcSpace.s4),
                Text(l10n.aboutBeta, style: HcText.rowTitle),
                Wrap(
                  spacing: HcSpace.s6,
                  children: [
                    HcLink(
                      l10n.aboutBetaOpen,
                      key: const Key('about-beta-open'),
                      onTap: () => _open(context, testFlightAddress),
                    ),
                    HcLink(
                      l10n.aboutBetaCopy,
                      key: const Key('about-beta-copy'),
                      onTap: () => _copyBeta(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A link of About (`.about-link`): its icon and label in a framed tile, a
/// target of 48. Without an address yet ([soon]), the same tile muted, with
/// the pill "Coming soon" and no action (`.about-link-soon`).
class _LinkTile extends StatelessWidget {
  const _LinkTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.soon,
  });

  final HcIcons icon;
  final String label;
  final VoidCallback? onTap;
  final String? soon;

  @override
  Widget build(BuildContext context) {
    final muted = soon != null;
    final colour = muted ? HcColors.textMuted : HcColors.primary;
    final tile = DecoratedBox(
      decoration: BoxDecoration(
        color: muted ? HcColors.surfaceMuted : null,
        border: Border.all(color: HcColors.border),
        borderRadius: BorderRadius.circular(HcRadius.md),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: HcLayout.touchTargetLg,
          minHeight: HcLayout.touchTargetLg,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HcSpace.s3,
            vertical: HcSpace.s2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HcIcon(icon, color: colour),
              const SizedBox(width: HcSpace.s2),
              Flexible(
                child: Text(
                  label,
                  style: HcText.buttonSmall.copyWith(color: colour),
                ),
              ),
              if (soon != null) ...[
                const SizedBox(width: HcSpace.s2),
                HcPill(soon!, tone: HcPillTone.ghost),
              ],
            ],
          ),
        ),
      ),
    );
    if (onTap == null) return tile;
    return Semantics(
      link: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HcRadius.md),
          child: tile,
        ),
      ),
    );
  }
}
