// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';

/// The homes of the phone as the screens see them: every home, the active
/// ones, the current one, and whether Today shows all of them
/// (docs/spec.md, "Homes"). Screens read it through [AppScope] and write
/// through [repository], then call [refresh].
class AppState extends ChangeNotifier {
  AppState(this.repository);

  final Repository repository;

  List<HomeRow> homes = const [];
  HomeRow? current;
  bool todayAllHomes = false;

  /// Grows on every change, so that a screen knows its data is stale.
  int revision = 0;

  List<HomeRow> get activeHomes =>
      homes.where((h) => h.archivedAt == null).toList();

  /// The selector is shown from two active homes on (`homes/current.py:31-32`).
  bool get showsSelector => activeHomes.length >= 2;

  /// Reads the homes again, and makes the first home at the first start.
  Future<void> refresh({String? firstHomeName}) async {
    if (firstHomeName != null && (await repository.homes()).isEmpty) {
      await repository.createHome(name: firstHomeName);
    }
    homes = await repository.homes();
    current = await repository.currentHome();
    todayAllHomes = await repository.todayShowsAllHomes();
    revision++;
    notifyListeners();
  }

  Future<void> choose(String homeId) async {
    await repository.chooseHome(homeId);
    await refresh();
  }

  Future<void> showAllHomes() async {
    await repository.showAllHomesOnToday();
    await refresh();
  }
}

/// Gives [AppState] to the screens below it.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
