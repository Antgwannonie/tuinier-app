import 'package:flutter_test/flutter_test.dart';

import 'package:tuinier_app/data/ai_settings_store.dart';
import 'package:tuinier_app/data/calendar_display_prefs_store.dart';
import 'package:tuinier_app/data/daily_tip_prefs_store.dart';
import 'package:tuinier_app/data/garden_history_store.dart';
import 'package:tuinier_app/data/garden_notes_store.dart';
import 'package:tuinier_app/data/garden_profile_store.dart';
import 'package:tuinier_app/data/garden_scan_prefs_store.dart';
import 'package:tuinier_app/data/insect_scan_store.dart';
import 'package:tuinier_app/data/my_garden_store.dart';
import 'package:tuinier_app/data/recipe_notification_store.dart';
import 'package:tuinier_app/data/vegetable_repository.dart';
import 'package:tuinier_app/data/weather_prefs_store.dart';
import 'package:tuinier_app/data/weed_scan_store.dart';
import 'package:tuinier_app/main.dart';
import 'package:tuinier_app/widgets/tuinier_scan_stores_scope.dart';

void main() {
  testWidgets('Startscherm toont titel Tuinier', (tester) async {
    final gardenStore = MyGardenStore();
    final profileStore = GardenProfileStore();
    final weatherPrefs = WeatherPrefsStore();
    await tester.pumpWidget(TuinierScanStoresScope(
      insectScanStore: InsectScanStore(),
      weedScanStore: WeedScanStore(),
      child: TuinierApp(
        repository: VegetableRepository(),
        gardenStore: gardenStore,
        profileStore: profileStore,
        weatherPrefs: weatherPrefs,
        aiSettings: AiSettingsStore(),
        scanPrefs: GardenScanPrefsStore(),
        calendarPrefs: CalendarDisplayPrefsStore(),
        recipeNotificationStore: RecipeNotificationStore(),
        notesStore: GardenNotesStore(),
        historyStore: GardenHistoryStore(),
        insectScanStore: InsectScanStore(),
        weedScanStore: WeedScanStore(),
        dailyTipPrefs: DailyTipPrefsStore(),
      ),
    ));
    await tester.pump();
    expect(find.text('Tuinier'), findsOneWidget);
  });
}
