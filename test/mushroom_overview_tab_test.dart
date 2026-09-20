import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tuinier_app/data/mushroom_overview_data.dart';
import 'package:tuinier_app/data/vegetable_repository.dart';
import 'package:tuinier_app/widgets/plant_encyclopedia/mushroom_overview_tab.dart';

void main() {
  testWidgets('MushroomOverviewTab shows mushroom-specific stats', (tester) async {
    final repository = VegetableRepository();
    final oesterzwam = repository.byId('oesterzwam');
    expect(oesterzwam, isNotNull);

    final layout = buildMushroomOverviewLayout(oesterzwam!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomOverviewTab(
            vegetable: oesterzwam,
            layout: layout,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Kweeklocatie'), findsOneWidget);
    expect(find.text('Luchtvochtigheid'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Belangrijkste momenten'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Belangrijkste momenten'), findsOneWidget);
    expect(find.text('Enten'), findsOneWidget);
    expect(find.text('Eetbaarheid'), findsOneWidget);
    expect(find.text('Geschikt voor beginners'), findsOneWidget);
    expect(find.text('Goed om te weten'), findsOneWidget);
  });
}
