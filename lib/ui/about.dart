// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/tokens.dart';
import '../l10n/app_localizations.dart';
import '../version.dart';

/// About: the author attribution required by NOTICE (AGPL-3.0, section 7(b)),
/// the version, the licence, the address of the source code, and the
/// licences of the packages the app includes.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: const EdgeInsets.all(HcSpace.s6),
        children: [
          Text(l10n.appTitle, style: text.headlineMedium),
          const SizedBox(height: HcSpace.s2),
          Text(l10n.aboutAttribution, style: text.titleMedium),
          Text(l10n.aboutVersion(appVersion), style: text.bodyMedium),
          const SizedBox(height: HcSpace.s4),
          Text(l10n.aboutLicence, style: text.bodyMedium),
          const SizedBox(height: HcSpace.s2),
          SelectableText(
            l10n.aboutSource(sourceAddress),
            style: text.bodyMedium,
          ),
          const SizedBox(height: HcSpace.s2),
          Text(l10n.aboutAi, style: text.bodyMedium),
          const SizedBox(height: HcSpace.s6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: appVersion,
                applicationLegalese: l10n.aboutAttribution,
              ),
              child: Text(l10n.aboutLicences),
            ),
          ),
        ],
      ),
    );
  }
}
