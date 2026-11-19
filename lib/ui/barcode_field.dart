// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../design/adaptive.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/barcode_lookup.dart';
import '../domain/gtin.dart';
import '../domain/photos.dart';
import '../domain/scanned_code.dart';
import '../l10n/app_localizations.dart';
import '../sync/mode.dart';
import 'budget_parts.dart';
import 'parts.dart';
import 'scanner.dart';
import 'state.dart';

/// The photo of [answer] re-encoded as any photo is (upright, without
/// metadata, at most 2560 px), or `null` when it cannot be (web ADR 0083:
/// "re-encoded, without EXIF").
Future<ProcessedPhoto?> processFoundPhoto(
  AppState state,
  BarcodeAnswer answer,
) async {
  final bytes = answer.photo;
  if (bytes == null) return null;
  try {
    return await state.photoProcessor(bytes);
  } on Object {
    return null;
  }
}

/// The kinds of code a barcode field reads: those of products.
const productCodes = {CodeFormat.ean8, CodeFormat.ean13, CodeFormat.upcA};

/// The barcode of an item or a stock item (web ADR 0083,
/// docs/adr/0015-barcode-lookup.md): typed by hand, always, or scanned with
/// the scanner of the labels. A scan looks the code up (alone, once the
/// person allowed it; with a server, through the server), and shows what
/// was found; only *Use these values* fills the form, its empty fields only,
/// through [onFill]. Nothing is saved until the form is.
class BarcodeField extends StatefulWidget {
  const BarcodeField({
    super.key,
    required this.controller,
    required this.homeId,
    required this.target,
    required this.onFill,
    this.hasPhoto = false,
  });

  final TextEditingController controller;
  final String homeId;
  final LookupTarget target;

  /// Gets the values of the empty fields, and the answer whose photo the
  /// person chose to keep (`null`: none).
  final void Function(Map<String, String> values, BarcodeAnswer? photo) onFill;

  /// Whether the record has a photo (or a label) already: the photo found
  /// is then only shown, never offered.
  final bool hasPhoto;

  @override
  State<BarcodeField> createState() => BarcodeFieldState();
}

class BarcodeFieldState extends State<BarcodeField> {
  BarcodeAnswer? _answer;
  bool _looking = false;
  bool _keepPhoto = true;

  /// The last answer, for the tests.
  BarcodeAnswer? get answer => _answer;

  Future<void> _scan() async {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final camera = state.codeCamera?.call();
    if (camera == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.barcodeNoCamera)));
      return;
    }
    final scanned = await Navigator.of(context).push(
      hcRouteOf<ScannedCode>(
        CodeScannerScreen(
          camera: camera,
          formats: productCodes,
          title: l10n.barcodeScanTitle,
          hint: l10n.barcodeScanHint,
        ),
      ),
    );
    if (scanned == null || !mounted) return;
    await scannedCode(scanned.text);
  }

  /// What a scan does with the code read: it fills the field, then looks
  /// the code up when it may.
  Future<void> scannedCode(String text) async {
    final state = AppScope.of(context);
    final code = cleanGtin(text);
    widget.controller.text = code;
    setState(() => _answer = null);
    if (!isValidGtin(code)) {
      setState(() => _answer = BarcodeAnswer(code, LookupState.failed));
      return;
    }
    if (state.syncMode == SyncMode.alone &&
        state.barcodeLookupAllowed == null) {
      final allowed = await Navigator.of(context)
          .push(hcRouteOf<bool>(const BarcodeConsentScreen()));
      if (!mounted) return;
      // Going back without choosing asks again at the next scan.
      if (allowed != null) await state.setBarcodeLookup(allowed);
      if (!mounted) return;
    }
    setState(() => _looking = true);
    final answer = await state.lookUpBarcode(widget.homeId, code);
    if (!mounted) return;
    setState(() {
      _looking = false;
      _keepPhoto = true;
      // A code typed meanwhile is the person's: the answer is not for it.
      if (cleanGtin(widget.controller.text) == code) _answer = answer;
    });
  }

  void _use() {
    final answer = _answer;
    if (answer == null) return;
    widget.onFill(
      fillValues(answer, widget.target),
      _keepPhoto && answer.photo != null && !widget.hasPhoto ? answer : null,
    );
    setState(() => _answer = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hcText(
          l10n.barcodeField,
          widget.controller,
          key: const Key('ean-field'),
          keyboard: TextInputType.number,
          sentences: false,
          validator: (v) {
            final code = cleanGtin(v ?? '');
            return code.isEmpty || isValidGtin(code)
                ? null
                : l10n.errEanInvalid;
          },
        ),
        fieldHelp(l10n.barcodeHelp),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            key: const Key('ean-scan'),
            style: hcSmallButtonStyle(),
            onPressed: _looking ? null : _scan,
            child: Text(
              l10n.barcodeScan,
              semanticsLabel: l10n.barcodeScanLabel,
            ),
          ),
        ),
        if (_looking)
          Padding(
            padding: const EdgeInsets.only(top: HcSpace.s2),
            child: Semantics(
              liveRegion: true,
              child: Text(l10n.barcodeLooking, style: HcText.bodySmall),
            ),
          )
        else if (_answer != null)
          Padding(
            padding: const EdgeInsets.only(top: HcSpace.s2),
            child: Semantics(
              liveRegion: true,
              container: true,
              child: _AnswerPanel(
                answer: _answer!,
                target: widget.target,
                offerPhoto: !widget.hasPhoto,
                keepPhoto: _keepPhoto,
                onKeepPhoto: (v) => setState(() => _keepPhoto = v),
                onUse: _use,
              ),
            ),
          ),
        const SizedBox(height: HcSpace.s3),
      ],
    );
  }
}

/// What a lookup found, or why it found nothing, under the field (the web's
/// `barcodes/_lookup.html`).
class _AnswerPanel extends StatelessWidget {
  const _AnswerPanel({
    required this.answer,
    required this.target,
    required this.offerPhoto,
    required this.keepPhoto,
    required this.onKeepPhoto,
    required this.onUse,
  });

  final BarcodeAnswer answer;
  final LookupTarget target;
  final bool offerPhoto;
  final bool keepPhoto;
  final ValueChanged<bool> onKeepPhoto;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    Widget small(String text) => Text(
      text,
      key: Key('ean-answer-${answer.state.name}'),
      style: HcText.bodySmall,
    );
    switch (answer.state) {
      case LookupState.done:
        break;
      case LookupState.notFound:
        return small(l10n.barcodeNotFound);
      case LookupState.failed:
        return small(
          isValidGtin(answer.code) ? l10n.barcodeFailed : l10n.barcodeInvalid,
        );
      case LookupState.offline:
        return small(l10n.barcodeOffline);
      case LookupState.limited:
        return small(l10n.barcodeLimited);
      case LookupState.running:
        return small(l10n.barcodeTakingLong);
      case LookupState.unavailable:
        return small(l10n.barcodeServerUnavailable);
      case LookupState.off:
        return small(
          state.syncMode == SyncMode.alone
              ? l10n.barcodeOffAlone
              : l10n.barcodeOffServer,
        );
    }
    final fill = fillValues(answer, target);
    final photo = answer.photo;
    return HcCard(
      key: const Key('ean-answer-done'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.barcodeFound(answer.sourceLabel), style: HcText.bodySmall),
          const SizedBox(height: HcSpace.s2),
          for (final (label, value) in [
            (l10n.fieldName, answer.name),
            (l10n.itemBrand, answer.brand),
            (l10n.itemModel, answer.model),
            (l10n.barcodeCategory, answer.category),
          ])
            if (value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: HcSpace.s1),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$label: ', style: HcText.fieldLabel),
                      TextSpan(text: value, style: HcText.body),
                    ],
                  ),
                ),
              ),
          if (photo != null) ...[
            const SizedBox(height: HcSpace.s2),
            Semantics(
              image: true,
              label: l10n.barcodePhoto,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(HcRadius.sm),
                ),
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Image.memory(
                    photo,
                    key: const Key('ean-answer-photo'),
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: HcSpace.s1),
            PhotoCredit(answer.attribution),
            if (offerPhoto)
              MergeSemantics(
                child: InkWell(
                  onTap: () => onKeepPhoto(!keepPhoto),
                  child: Row(
                    children: [
                      Checkbox(
                        key: const Key('ean-keep-photo'),
                        value: keepPhoto,
                        onChanged: (v) => onKeepPhoto(v ?? false),
                      ),
                      Expanded(
                        child: Text(l10n.barcodeKeepPhoto, style: HcText.body),
                      ),
                    ],
                  ),
                ),
              ),
          ] else if (answer.sourceLabel.isNotEmpty)
            Text(
              [
                answer.sourceLabel,
                if (answer.license.isNotEmpty) answer.license,
              ].join(' · '),
              style: HcText.bodySmall,
            ),
          if (fill.isNotEmpty) ...[
            const SizedBox(height: HcSpace.s2),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton(
                key: const Key('ean-use'),
                style: hcSmallButtonStyle(),
                onPressed: onUse,
                child: Text(l10n.barcodeUse),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The credit of a photo from an open database, under it (the web's
/// `barcodes/_attribution.html`): who added it, the source and the licence,
/// the source and the licence opening their pages.
class PhotoCredit extends StatelessWidget {
  const PhotoCredit(this.attribution, {super.key});

  final Map<String, String> attribution;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final author = attribution['author'] ?? '';
    final source = attribution['source'] ?? '';
    final sourceUrl = attribution['source_url'] ?? '';
    final license = (attribution['license'] ?? '').isEmpty
        ? LookupSource.license
        : attribution['license']!;
    final licenseUrl = attribution['license_url'] ?? '';
    final text = [
      if (author.isNotEmpty) l10n.photoBy(author),
      if (source.isNotEmpty) source,
      license,
    ].join(', ');
    final open = sourceUrl.startsWith('https://')
        ? sourceUrl
        : licenseUrl.startsWith('https://')
        ? licenseUrl
        : null;
    final caption = Text(
      text,
      key: const Key('photo-credit'),
      style: HcText.bodySmall.copyWith(
        decoration: open == null ? null : TextDecoration.underline,
      ),
    );
    if (open == null) return caption;
    return Semantics(
      link: true,
      child: InkWell(
        onTap: () => state.openUrl(Uri.parse(open)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HcLayout.touchTarget),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: caption,
          ),
        ),
      ),
    );
  }
}

/// The question of the first scan, when the phone is alone
/// (docs/adr/0015-barcode-lookup.md): what leaves the phone (the code,
/// nothing else), to whom, under which licences, and that it can be changed
/// in Settings. Closes with `true` (allowed), `false` (refused), or nothing
/// (back: asked again at the next scan).
class BarcodeConsentScreen extends StatelessWidget {
  const BarcodeConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    return HcScaffold(
      title: l10n.barcodeConsentTitle,
      body: HcScreenList(
        children: [
          const SizedBox(height: HcSpace.s2),
          HcCard(
            key: const Key('barcode-consent'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.barcodeConsentIntro, style: HcText.body),
                const SizedBox(height: HcSpace.s3),
                for (final (title, text) in [
                  (l10n.barcodeConsentWhatTitle, l10n.barcodeConsentWhat),
                  (l10n.barcodeConsentWhoTitle, l10n.barcodeConsentWho),
                  (l10n.barcodeConsentLicenceTitle, l10n.barcodeConsentLicence),
                ]) ...[
                  Semantics(
                    header: true,
                    child: Text(title, style: HcText.fieldLabel),
                  ),
                  const SizedBox(height: HcSpace.s1),
                  Text(text, style: HcText.body),
                  const SizedBox(height: HcSpace.s3),
                ],
                Text(l10n.barcodeConsentChange, style: HcText.bodySmall),
                const SizedBox(height: HcSpace.s4),
                FilledButton(
                  key: const Key('barcode-consent-allow'),
                  onPressed: () => navigator.pop(true),
                  child: Text(l10n.barcodeConsentAllow),
                ),
                const SizedBox(height: HcSpace.s2),
                OutlinedButton(
                  key: const Key('barcode-consent-refuse'),
                  onPressed: () => navigator.pop(false),
                  child: Text(l10n.barcodeConsentRefuse),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The switch of the lookup in Settings, when the phone is alone.
class BarcodeLookupRow extends StatelessWidget {
  const BarcodeLookupRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return HcRow(
      key: const Key('barcode-lookup-row'),
      title: l10n.barcodeLookupSetting,
      text: l10n.barcodeLookupSettingText,
      trailing: Semantics(
        label: l10n.barcodeLookupSetting,
        child: HcSwitch(
          key: const Key('barcode-lookup-switch'),
          value: state.barcodeLookupAllowed == true,
          onChanged: state.setBarcodeLookup,
        ),
      ),
    );
  }
}
