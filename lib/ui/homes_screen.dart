// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/tokens.dart';
import '../domain/recurrence.dart' as recurrence;
import '../l10n/app_localizations.dart';
import 'messages.dart';
import 'state.dart';

/// Homes (docs/spec.md, "Homes"): the active homes, then the archived ones;
/// create, rename, change currency or hemisphere, archive, unarchive, delete.
class HomesScreen extends StatelessWidget {
  const HomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final active = state.homes.where((h) => h.archivedAt == null);
    final archived = state.homes.where((h) => h.archivedAt != null);
    void open(HomeRow? home) => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => HomeScreen(homeId: home?.id)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homes)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => open(null),
        icon: const Icon(Icons.add),
        label: Text(l10n.newHome),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          for (final home in active)
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(home.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => open(home),
            ),
          if (archived.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HcSpace.s4,
                HcSpace.s4,
                HcSpace.s4,
                HcSpace.s2,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.homesArchived,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: HcColors.textMuted),
                ),
              ),
            ),
          for (final home in archived)
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(home.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => open(home),
            ),
        ],
      ),
    );
  }
}

/// A home: its form, and archive, unarchive, delete. Without [homeId], a new
/// home. An archived home is read only: only unarchive and delete.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.homeId});

  final String? homeId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _currency = TextEditingController(text: 'EUR');
  String _hemisphere = recurrence.north;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final home = _home(AppScope.of(context));
    if (home != null) {
      _name.text = home.name;
      _currency.text = home.currency;
      _hemisphere = home.hemisphere;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _currency.dispose();
    super.dispose();
  }

  HomeRow? _home(AppState state) => widget.homeId == null
      ? null
      : state.homes.where((h) => h.id == widget.homeId).firstOrNull;

  Future<void> _act(Future<void> Function(Repository repository) action) async {
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    try {
      await action(state.repository);
    } on Refused catch (refused) {
      if (mounted) showRefusal(context, refused);
      return;
    }
    await state.refresh();
    navigator.pop();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final name = _name.text;
    final currency = _currency.text.trim().toUpperCase();
    await _act(
      (repository) => widget.homeId == null
          ? repository.createHome(
              name: name,
              currency: currency,
              hemisphere: _hemisphere,
            )
          : repository.updateHome(
              widget.homeId!,
              name: name,
              currency: currency,
              hemisphere: _hemisphere,
            ),
    );
  }

  Future<void> _delete(HomeRow home) async {
    final confirmed = await showDialog<String>(
      context: context,
      builder: (_) => _DeleteDialog(home: home),
    );
    if (confirmed == null) return;
    await _act(
      (repository) => repository.deleteHome(home.id, typedName: confirmed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final home = _home(state);
    final archived = home?.archivedAt != null;
    final editable = !archived;
    return Scaffold(
      appBar: AppBar(
        title: Text(home?.name ?? l10n.newHome),
        actions: [
          if (editable) TextButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(HcSpace.s4),
          children: [
            if (archived)
              Padding(
                padding: const EdgeInsets.only(bottom: HcSpace.s4),
                child: Text(l10n.homeArchivedNotice),
              ),
            TextFormField(
              key: const Key('home-name'),
              controller: _name,
              enabled: editable,
              decoration: InputDecoration(labelText: l10n.homeName),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
            ),
            const SizedBox(height: HcSpace.s4),
            TextFormField(
              key: const Key('home-currency'),
              controller: _currency,
              enabled: editable,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.homeCurrency),
              validator: (value) =>
                  RegExp(r'^[A-Z]{3}$')
                      .hasMatch((value ?? '').trim().toUpperCase())
                  ? null
                  : l10n.errCurrencyInvalid,
            ),
            const SizedBox(height: HcSpace.s4),
            DropdownButtonFormField<String>(
              initialValue: _hemisphere,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.homeHemisphere),
              items: [
                DropdownMenuItem(
                  value: recurrence.north,
                  child: Text(l10n.hemisphereNorth),
                ),
                DropdownMenuItem(
                  value: recurrence.south,
                  child: Text(l10n.hemisphereSouth),
                ),
              ],
              onChanged: editable
                  ? (value) => setState(() => _hemisphere = value!)
                  : null,
            ),
            if (home != null) ...[
              const SizedBox(height: HcSpace.s6),
              Wrap(
                spacing: HcSpace.s2,
                runSpacing: HcSpace.s2,
                children: [
                  if (archived)
                    OutlinedButton(
                      onPressed: () => _act((r) => r.unarchiveHome(home.id)),
                      child: Text(l10n.homeUnarchive),
                    )
                  else
                    OutlinedButton(
                      onPressed: () => _act((r) => r.archiveHome(home.id)),
                      child: Text(l10n.homeArchive),
                    ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HcColors.danger,
                    ),
                    onPressed: () => _delete(home),
                    child: Text(l10n.homeDelete),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Asks for the exact name of the home before it is deleted
/// (`homes/services.py:239-252`); the button stays off until it matches.
class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({required this.home});

  final HomeRow home;

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matches = _typed.text == widget.home.name;
    return AlertDialog(
      // Scrolls at large text scales, name field and buttons stay reachable.
      scrollable: true,
      title: Text(l10n.homeDeleteTitle(widget.home.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homeDeleteBody),
          const SizedBox(height: HcSpace.s4),
          TextField(
            key: const Key('home-delete-name'),
            controller: _typed,
            decoration: InputDecoration(labelText: l10n.homeName),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HcColors.danger),
          onPressed: matches
              ? () => Navigator.of(context).pop(_typed.text)
              : null,
          child: Text(l10n.homeDeleteConfirm),
        ),
      ],
    );
  }
}
