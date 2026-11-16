// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../design/tokens.dart';
import '../design/widgets.dart';
import 'help_button.dart';
import '../l10n/app_localizations.dart';
import '../version.dart';
import 'state.dart';

/// About: the author attribution required by NOTICE (AGPL-3.0, section 7(b)),
/// the version and build number read from the platform at run time, the licence, the address of the source code, and the
/// licences of the packages the app includes.
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

  Future<void> _openBeta(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await state.openUrl(Uri.parse(testFlightAddress))) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return HcScaffold(
      title: l10n.about,
      actions: const [HelpButton(page: HelpPages.about)],
      body: ListView(
        padding: const EdgeInsets.all(HcSpace.s6),
        children: [
          HcLargeTitle(l10n.about),
          Text(l10n.appTitle, style: text.headlineMedium),
          const SizedBox(height: HcSpace.s2),
          Text(l10n.aboutAttribution, style: text.titleMedium),
          FutureBuilder<PackageInfo>(
            future: _info,
            builder: (context, snapshot) {
              final info = snapshot.data;
              if (info == null) return const SizedBox.shrink();
              return SelectableText(
                l10n.aboutVersion(info.version, info.buildNumber),
                key: const Key('about-version'),
                style: text.bodyMedium,
              );
            },
          ),
          const SizedBox(height: HcSpace.s4),
          Text(l10n.aboutLicence, style: text.bodyMedium),
          const SizedBox(height: HcSpace.s2),
          SelectableText(
            l10n.aboutSource(sourceAddress),
            style: text.bodyMedium,
          ),
          const SizedBox(height: HcSpace.s2),
          Text(l10n.aboutAi, style: text.bodyMedium),
          const SizedBox(height: HcSpace.s4),
          Text(l10n.aboutBeta, style: text.bodyMedium),
          Wrap(
            spacing: HcSpace.s6,
            children: [
              HcLink(
                l10n.aboutBetaOpen,
                key: const Key('about-beta-open'),
                onTap: () => _openBeta(context),
              ),
              HcLink(
                l10n.aboutBetaCopy,
                key: const Key('about-beta-copy'),
                onTap: () => _copyBeta(context),
              ),
            ],
          ),
          const SizedBox(height: HcSpace.s6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton(
              onPressed: () async {
                final info = await _info;
                if (!context.mounted) return;
                showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: info.version,
                  applicationLegalese: l10n.aboutAttribution,
                );
              },
              child: Text(l10n.aboutLicences),
            ),
          ),
        ],
      ),
    );
  }
}
