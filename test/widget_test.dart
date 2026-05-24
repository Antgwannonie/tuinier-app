import 'package:flutter_test/flutter_test.dart';

import 'package:tuinier_app/data/garden_profile_store.dart';
import 'package:tuinier_app/data/my_garden_store.dart';
import 'package:tuinier_app/data/vegetable_repository.dart';
import 'package:tuinier_app/data/weather_prefs_store.dart';
import 'package:tuinier_app/main.dart';

void main() {
  testWidgets('Startscherm toont titel Tuinier', (tester) async {
    final gardenStore = MyGardenStore();
    final profileStore = GardenProfileStore();
    final weatherPrefs = WeatherPrefsStore();
    await tester.pumpWidget(TuinierApp(
      repository: VegetableRepository(),
      gardenStore: gardenStore,
      profileStore: profileStore,
      weatherPrefs: weatherPrefs,
    ));
    await tester.pump();
    expect(find.text('Tuinier'), findsOneWidget);
  });
}
