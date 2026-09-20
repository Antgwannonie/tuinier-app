import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tuinier_app/data/garden_profile_store.dart';
import 'package:tuinier_app/data/my_garden_store.dart';
import 'package:tuinier_app/data/plant_image_frame_prefs_store.dart';
import 'package:tuinier_app/data/vegetable_repository.dart';
import 'package:tuinier_app/screens/vegetable_detail_screen.dart';
import 'package:tuinier_app/widgets/plant_image_frame_scope.dart';

void main() {
  testWidgets('VegetableDetailScreen encyclopedia mode builds', (tester) async {
    final repository = VegetableRepository();
    final vegetable = repository.all.first;
    final gardenStore = MyGardenStore();
    final profileStore = GardenProfileStore();
    final framePrefs = PlantImageFramePrefsStore();

    await tester.pumpWidget(
      PlantImageFrameScope(
        store: framePrefs,
        child: MaterialApp(
          home: VegetableDetailScreen(
            vegetable: vegetable,
            repository: repository,
            gardenStore: gardenStore,
            profileStore: profileStore,
            presentation: VegetableDetailPresentation.encyclopedia,
          ),
        ),
      ),
    );
    await tester.pump();
    profileStore.notifyListeners();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Overzicht'), findsOneWidget);
    expect(find.text('Plant info'), findsOneWidget);
    expect(find.text(vegetable.nameNl), findsOneWidget);
  });
}
