// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../domain/templates.dart';
import 'guide_screens.dart';
import 'help_button.dart';
import '../l10n/app_localizations.dart';
import 'choices.dart';
import 'parts.dart';
import 'state.dart';

/// Add from a template (docs/spec.md, "Screens of v1", 3): the library of
/// common tasks of a home, grouped by equipment; the person ticks what they
/// need and each becomes a task of the home, repeating after the last
/// time, with the interval, the duration, the procedure and the source of the
/// template (web ADR 0049). The templates never leave the phone.
class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key, this.homeId, this.roomId});

  /// The home the tasks go to: the one of the page it is opened from (a
  /// room of the example home adds to the example home), else the current
  /// home.
  final String? homeId;

  /// The room the tasks are attached to, when the screen is opened from one.
  final String? roomId;

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final _ticked = <String>{};
  TemplateLibrary? _library;
  List<RoomRow> _rooms = const [];
  String? _roomId;
  Day? _dueOn;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _roomId = widget.roomId;
    _load(AppScope.of(context));
  }

  Future<void> _load(AppState state) async {
    final library = await state.loadTemplates();
    final home = widget.homeId ?? state.current?.id;
    final rooms = home == null
        ? <RoomRow>[]
        : await state.repository.rooms(home);
    if (!mounted) return;
    setState(() {
      _library = library;
      _rooms = rooms;
    });
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final library = _library;
    final home = widget.homeId ?? state.current?.id;
    if (library == null || home == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (_ticked.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.templatesNoneTicked)));
      return;
    }
    final language = Localizations.localeOf(context).languageCode;
    final inputs = [
      for (final template in library.templates)
        if (_ticked.contains(template.id))
          template.input(
            language,
            material: l10n.templateMaterial,
            source: l10n.templateSource,
            roomId: _roomId,
            dueOn: _dueOn,
          ),
    ];
    if (await runChange(context, (r) => r.createTasks(home, inputs))) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.templatesAdded(inputs.length))),
      );
      navigator.pop();
    }
  }

  /// The public source of a template, in the browser of the phone.
  Future<void> _openSource(String address) async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await state.openUrl(Uri.parse(address))) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.aboutBetaCannotOpen)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = _library;
    final language = Localizations.localeOf(context).languageCode;
    return HcScaffold(
      title: l10n.addFromTemplate,
      belowTitle: ExampleHomeBanner(homeId: widget.homeId),
      actions: const [HelpButton(page: HelpPages.templates)],
      body: library == null
          ? const SizedBox.shrink()
          : HcScreenList(
              children: [
                const SizedBox(height: HcSpace.s2),
                Text(l10n.templatesIntro, style: HcText.rowText),
                for (final equipment in library.equipment)
                  if (library.of(equipment.id).isNotEmpty) ...[
                    HcSectionHeading(equipment.name.of(language)),
                    HcCardList(
                      children: [
                        for (final template in library.of(equipment.id))
                          CheckboxListTile(
                            key: Key('template-${template.id}'),
                            value: _ticked.contains(template.id),
                            onChanged: (on) => setState(
                              () => on == true
                                  ? _ticked.add(template.id)
                                  : _ticked.remove(template.id),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              template.title.of(language),
                              style: HcText.rowTitle,
                            ),
                            // The line of the web: the interval, the rule of
                            // a country, and the link to the source.
                            subtitle: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  [
                                    everyLabel(
                                      l10n,
                                      template.interval,
                                      template.unit,
                                    ),
                                    if (template.region.isNotEmpty)
                                      l10n.templateRegion(template.region),
                                    '',
                                  ].join(' · '),
                                  style: HcText.rowText,
                                ),
                                HcLink(
                                  l10n.templateSourceLink,
                                  key: Key('template-source-${template.id}'),
                                  onTap: () => _openSource(template.sourceUrl),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                const SizedBox(height: HcSpace.s4),
                HcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      hcChoice<String?>(
                        l10n.templatesRoom,
                        _roomId,
                        [
                          (null, l10n.templatesNoRoom),
                          for (final room in _rooms) (room.id, room.name),
                        ],
                        (v) => setState(() => _roomId = v),
                        key: const Key('templates-room'),
                      ),
                      HcDateField(
                        label: l10n.templatesDue,
                        value: _dueOn,
                        noDate: l10n.todayNoDate,
                        onChanged: (d) => setState(() => _dueOn = d),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HcSpace.s4),
                FilledButton(
                  key: const Key('templates-add'),
                  onPressed: _add,
                  child: Text(l10n.templatesAdd),
                ),
              ],
            ),
    );
  }
}
