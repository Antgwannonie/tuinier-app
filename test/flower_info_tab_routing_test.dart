import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tuinier_app/data/plant_encyclopedia_layout.dart';
import 'package:tuinier_app/data/vegetable_repository.dart';
import 'package:tuinier_app/widgets/plant_encyclopedia/plant_info_category_tab_bar.dart';
import 'package:tuinier_app/widgets/plant_encyclopedia/plant_info_tab.dart';

Future<void> _tapCategoryTab(WidgetTester tester, String label) async {
  final tab = find.descendant(
    of: find.byType(PlantInfoCategoryTabBar),
    matching: find.text(label),
  );
  expect(tab, findsOneWidget);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Flower PlantInfoTab uses flower standplaats layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapCategoryTab(tester, 'Standplaats');

    expect(find.text('Standplaats'), findsWidgets);
    expect(find.text('Ideale standplaats'), findsWidgets);
  });

  testWidgets('Flower PlantInfoTab uses flower water layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapCategoryTab(tester, 'Water');

    expect(find.text('Water'), findsWidgets);
    expect(find.text('Waterbehoefte'), findsWidgets);
  });

  testWidgets('Flower PlantInfoTab uses flower zaaien layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Binnen zaaien'), findsWidgets);
    expect(find.text('Kiemduur'), findsOneWidget);
    expect(find.text('Kiemtemperatuur'), findsOneWidget);
    expect(find.text('Zaaidetails'), findsOneWidget);
    expect(find.text('Licht tijdens kieming'), findsOneWidget);
    expect(find.text('Stapsgewijs zaaien'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
  });

  testWidgets('Flower PlantInfoTab uses flower uitplanten layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapCategoryTab(tester, 'Uitplanten');

    expect(find.text('Uitplantperiode'), findsOneWidget);
    expect(find.text('Uitplantvoorwaarden'), findsOneWidget);
    expect(find.text('Afharden'), findsOneWidget);
    expect(find.text('Plantafstand'), findsOneWidget);
    expect(find.text('Rijafstand'), findsOneWidget);
    expect(find.text('Plantdiepte'), findsOneWidget);
    expect(find.text('Tijd tot aanslaan'), findsOneWidget);
    expect(find.text('Tijd tot eerste groei'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
  });

  testWidgets('Flower PlantInfoTab uses flower groei layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapCategoryTab(tester, 'Groei');

    expect(find.text('Hoogte'), findsOneWidget);
    expect(find.text('Breedte'), findsOneWidget);
    expect(find.text('Groeifases'), findsOneWidget);
    expect(find.text('Groeiwijze'), findsOneWidget);
    expect(find.text('Seizoensgroei'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
  });

  testWidgets('Flower PlantInfoTab uses flower bloei layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapCategoryTab(tester, 'Bloei');

    expect(find.text('Bloeiperiode'), findsOneWidget);
    expect(find.text('Bloeiduur'), findsOneWidget);
    expect(find.text('Bestuivers'), findsOneWidget);
    expect(find.text('Bloeikalender'), findsOneWidget);
    expect(find.text('Extra tips voor een rijke bloei'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
    expect(find.text('Tijd tot vruchtvorming'), findsNothing);
  });

  testWidgets('Flower PlantInfoTab uses flower zaadoogst layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapCategoryTab(tester, 'Zaadoogst');

    expect(find.text('Wanneer oogsten'), findsOneWidget);
    expect(find.text('Zaadrijp herkennen'), findsOneWidget);
    expect(find.text('Zelf uitzaaien'), findsOneWidget);
    expect(find.text('Zaadoogst kalender'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
  });

  testWidgets('Flower PlantInfoTab uses flower verzorging layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapCategoryTab(tester, 'Verzorging');

    expect(find.text('Dagelijkse verzorging'), findsOneWidget);
    expect(find.text('Wekelijkse verzorging'), findsOneWidget);
    expect(find.text('Jaarlijkse onderhoudskalender'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
    expect(find.text('Verzorgingstips'), findsOneWidget);
  });

  testWidgets('Flower PlantInfoTab uses flower combinaties layout', (tester) async {
    final repository = VegetableRepository();
    final lavendel = repository.byId('lavendel');
    expect(lavendel, isNotNull);

    final layout = buildPlantEncyclopediaLayout(vegetable: lavendel!);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlantInfoTab(
            layout: layout,
            vegetable: lavendel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tab staat rechts in de balk (ListView.builder bouwt alleen zichtbare items).
    await tester.drag(
      find.byType(PlantInfoCategoryTabBar),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    await _tapCategoryTab(tester, 'Combinaties');

    expect(find.text('Goede buren'), findsOneWidget);
    expect(find.text('Slechte buren'), findsOneWidget);
    expect(find.text('Plantfamilie'), findsOneWidget);
    expect(find.text('Gezelschapsplanten'), findsOneWidget);
    expect(find.text('Combinatievoordelen'), findsOneWidget);
    expect(find.text('Veelgemaakte combinatiefouten'), findsOneWidget);
    expect(find.text('Combinatietips'), findsOneWidget);
    expect(find.text('Meer info'), findsNothing);
  });
}
