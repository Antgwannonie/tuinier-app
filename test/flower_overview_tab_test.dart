import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tuinier_app/data/flower_overview_data.dart';
import 'package:tuinier_app/data/vegetable_repository.dart';
import 'package:tuinier_app/widgets/plant_encyclopedia/flower_overview_tab.dart';

void main() {
  testWidgets('FlowerOverviewTab shows lavendel flower sections', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildFlowerOverviewLayout(lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlowerOverviewTab(
            vegetable: lavendel,
            layout: layout,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Standplaats'), findsOneWidget);
    expect(find.text('Grootte'), findsOneWidget);
    expect(find.text('Bloei'), findsWidgets);
    expect(find.text('Waarom deze bloem planten?'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Belangrijkste momenten'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Belangrijkste momenten'), findsOneWidget);
    expect(find.text('Zaaien (binnen)'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Geschikt voor'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Geschikt voor'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tip'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Tip'), findsOneWidget);
    expect(
      find.textContaining('Knip lavendel na de bloei'),
      findsOneWidget,
    );
  });
}
