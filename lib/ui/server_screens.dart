// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/app_localizations.dart';
import '../sync/server_address.dart';
import '../sync/server_http.dart';
import '../sync/server_sign_in.dart';
import '../sync/server_transport.dart';
import 'state.dart';

/// The words of why connecting to a server failed.
String serverProblem(AppLocalizations l10n, Object error) => switch (error) {
  SignInException(error: SignInError.tooOld) => l10n.serverTooOld(
    minimumServerVersion,
  ),
  ServerStopped(reason: ServerStop.tooOld) => l10n.serverTooOld(
    minimumServerVersion,
  ),
  SignInException(error: SignInError.mobileAppOff) ||
  ServerStopped(reason: ServerStop.mobileAppOff) => l10n.serverMobileAppOff,
  SignInException(error: SignInError.cancelled) => l10n.serverSignInCancelled,
  SignInException() => l10n.serverSignInFailed,
  ServerStopped(reason: ServerStop.insecureTransport) =>
    l10n.serverInsecureRefused,
  ServerStopped(reason: ServerStop.disconnected) => l10n.serverDisconnected,
  ServerStopped(reason: ServerStop.updateApp) => l10n.serverUpdateApp,
  ServerHttpException(failure: ServerHttpFailure.certificate) =>
    l10n.serverCertificate,
  ServerHttpException(failure: ServerHttpFailure.otherHost) =>
    l10n.serverOtherHost,
  _ => l10n.serverUnreachable,
};

/// The second screen of the third way (docs/adr/0010): the server's
/// address, then the sign-in in the system browser. `http://` is taken only
/// towards a local IP literal, after a warning (docs/protocol.md section
/// 2.10).
class ServerAddressScreen extends StatefulWidget {
  const ServerAddressScreen({super.key});

  @override
  State<ServerAddressScreen> createState() => _ServerAddressScreenState();
}

class _ServerAddressScreenState extends State<ServerAddressScreen> {
  final _text = TextEditingController();
  String? _error;
  ServerAddress? _plainHttp;
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _continue({bool plainHttpAccepted = false}) async {
    final l10n = AppLocalizations.of(context);
    final (address, error) = ServerAddress.parse(_text.text);
    if (address == null) {
      setState(() {
        _plainHttp = null;
        _error = error == ServerAddressError.httpNeedsLocalIp
            ? l10n.serverHttpNeedsLocalIp
            : l10n.serverAddressInvalid;
      });
      return;
    }
    if (address.plainHttp && !plainHttpAccepted) {
      setState(() {
        _error = null;
        _plainHttp = address;
      });
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    try {
      await state.signInToServer(address);
      final homes = await state.serverHomesOffered(address);
      if (!mounted) return;
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ServerConfirmScreen(address: address, homes: homes),
        ),
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = serverProblem(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wayServerTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HcSpace.s4),
          children: [
            Text(l10n.serverAddressHelp, style: HcText.body),
            const SizedBox(height: HcSpace.s4),
            HcField(
              label: l10n.serverAddressLabel,
              child: TextField(
                key: const Key('server-address'),
                controller: _text,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  hintText: 'https://housecairn.example.com',
                  errorText: _error,
                  errorMaxLines: 4,
                ),
                onSubmitted: (_) => _continue(),
              ),
            ),
            if (_plainHttp != null) ...[
              const SizedBox(height: HcSpace.s4),
              HcCard(
                child: Padding(
                  padding: const EdgeInsets.all(HcSpace.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key: const Key('server-http-warning'),
                        l10n.serverHttpWarning,
                        style: HcText.body,
                      ),
                      const SizedBox(height: HcSpace.s3),
                      OutlinedButton(
                        key: const Key('server-http-continue'),
                        onPressed: _busy
                            ? null
                            : () => _continue(plainHttpAccepted: true),
                        child: Text(l10n.serverHttpContinue),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: HcSpace.s4),
            if (_busy) ...[
              Text(l10n.serverSigningIn, style: HcText.body),
              const SizedBox(height: HcSpace.s3),
            ],
            FilledButton(
              key: const Key('server-sign-in'),
              onPressed: _busy || _plainHttp != null ? null : _continue,
              child: Text(l10n.serverSignIn),
            ),
          ],
        ),
      ),
    );
  }
}

/// The confirmation before anything of the homes is sent or received: it
/// names the server and says what it gets (docs/adr/0010, "What the screen
/// says"), with the homes the access covers.
class ServerConfirmScreen extends StatefulWidget {
  const ServerConfirmScreen({
    super.key,
    required this.address,
    required this.homes,
  });

  final ServerAddress address;
  final List<ServerHome> homes;

  @override
  State<ServerConfirmScreen> createState() => _ServerConfirmScreenState();
}

class _ServerConfirmScreenState extends State<ServerConfirmScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await state.startServer(widget.address);
      navigator.popUntil((route) => route.isFirst);
    } on Object catch (e) {
      if (mounted) setState(() => _error = serverProblem(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    await state.forgetServer(widget.address);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.serverConfirmTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(HcSpace.s4),
                children: [
                  Text(
                    widget.address.display,
                    key: const Key('server-confirm-address'),
                    style: HcText.cardTitle,
                  ),
                  if (widget.address.plainHttp) ...[
                    const SizedBox(height: HcSpace.s2),
                    HcPill(l10n.serverNotEncrypted, tone: HcPillTone.warning),
                  ],
                  const SizedBox(height: HcSpace.s3),
                  Text(
                    l10n.serverSeesEverything,
                    key: const Key('server-sees-everything'),
                    style: HcText.body,
                  ),
                  const SizedBox(height: HcSpace.s4),
                  HcSectionHeading(l10n.serverHomesHeading),
                  if (widget.homes.isEmpty)
                    HcEmpty(l10n.serverNoHomes)
                  else
                    HcCardList(
                      children: [
                        for (final home in widget.homes)
                          HcRow(
                            key: Key('server-home-${home.id}'),
                            title: home.name,
                            text: home.members.map((m) => m.name).join(', '),
                            pills: [
                              if (home.readOnly) HcPill(l10n.serverReadOnly),
                            ],
                          ),
                      ],
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: HcSpace.s3),
                    Text(
                      _error!,
                      style: HcText.body.copyWith(color: HcColors.danger),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(HcSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    key: const Key('server-connect'),
                    onPressed: _busy || widget.homes.isEmpty ? null : _connect,
                    child: Text(l10n.serverConnect),
                  ),
                  const SizedBox(height: HcSpace.s2),
                  TextButton(
                    key: const Key('server-cancel'),
                    onPressed: _busy ? null : _cancel,
                    child: Text(l10n.serverCancel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
