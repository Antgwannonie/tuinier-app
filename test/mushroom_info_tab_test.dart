import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tuinier_app/data/mushroom_info_guide.dart';
import 'package:tuinier_app/data/mushroom_info_layout.dart';
import 'package:tuinier_app/data/vegetable_repository.dart';
import 'package:tuinier_app/widgets/plant_encyclopedia/mushroom_info_tab.dart';

Future<void> _tapMushroomTab(WidgetTester tester, String label) async {
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpAndSettle();

  final listFinder = find.byType(ListView);
  for (var i = 0; i < 20; i++) {
    if (find.text(label).evaluate().isNotEmpty) break;
    await tester.drag(listFinder.first, const Offset(-120, 0));
    await tester.pumpAndSettle();
  }

  final finder = find.text(label);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  test('mushroom info has 12 tabs with content for oesterzwam', () {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    final categories = mushroomInfoCategoriesFor(vegetable!);
    expect(categories.length, 12);
    expect(categories.map((c) => c.id.label).toList(), [
      'Substraat',
      'Enten',
      'Kolonisatie',
      'Vruchtvorming',
      'Omgeving',
      'Water',
      'Groei',
      'Oogsten',
      'Flushes',
      'Bewaren',
      'Problemen',
      'Weetjes',
    ]);

    for (final category in categories) {
      expect(
        category.guide.hasContent,
        isTrue,
        reason: '${category.id.label} should have content',
      );
    }
  });

  testWidgets('MushroomInfoTab shows mushroom-specific category tabs', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Substraat'), findsOneWidget);
    expect(find.text('Enten'), findsOneWidget);
    expect(find.text('Combinaties'), findsNothing);
    expect(find.text('Combinatie'), findsNothing);
    expect(find.text('Zaaien'), findsNothing);
    expect(find.text('Wat is substraat?'), findsOneWidget);
    expect(find.text('Waarvoor gebruik je het?'), findsOneWidget);
    expect(find.text('1. Beste substraat'), findsOneWidget);
    expect(find.text('11. Controlelijst'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows enten layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Enten'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Wat is enten?'), findsOneWidget);
    expect(find.text('Entmethode'), findsOneWidget);
    expect(find.text('Benodigdheden'), findsOneWidget);
    expect(find.text('Graanbroed'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows kolonisatie layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Kolonisatie'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Wat is kolonisatie?'), findsOneWidget);
    expect(find.text('Kolonisatieduur'), findsOneWidget);
    expect(find.text('Gezond mycelium herkennen'), findsOneWidget);
    expect(find.text('Groei controleren'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows omgeving layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Omgeving'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('De ideale omgeving'), findsOneWidget);
    expect(find.text('Kies je kweekomgeving'), findsOneWidget);
    expect(find.text('Ideale omgevingsfactoren'), findsOneWidget);
    expect(find.text('Omgeving per groeifase'), findsOneWidget);
    expect(find.text('Binnen'), findsWidgets);
  });

  testWidgets('MushroomInfoTab shows water layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Water'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Waarom is water belangrijk?'), findsOneWidget);
    expect(find.text('De ideale watercondities'), findsOneWidget);
    expect(find.text('Hoe geef je water?'), findsOneWidget);
    expect(find.text('Signalen: te droog of te nat'), findsOneWidget);
    expect(find.text('Te droog'), findsOneWidget);
    expect(find.text('Tips voor optimaal waterbeheer'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows groei layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Groei'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Wat gebeurt er tijdens de groei?'), findsOneWidget);
    expect(find.text('De groeifase in het kort'), findsOneWidget);
    expect(find.text('Ideale omstandigheden tijdens groei'), findsOneWidget);
    expect(find.text('Wat kun je verwachten?'), findsOneWidget);
    expect(find.text('Fasen van de groei'), findsOneWidget);
    expect(find.text('Tips voor een gezonde groei'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows problemen layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await _tapMushroomTab(tester, 'Problemen');

    expect(find.text('Problemen vroeg herkennen'), findsOneWidget);
    expect(find.text('Veelvoorkomende problemen'), findsOneWidget);
    expect(find.text('Schimmelgroei'), findsOneWidget);
    expect(find.text('Problemen snel herkennen'), findsOneWidget);
    expect(find.text('Groene schimmel'), findsOneWidget);
    expect(find.text('Algemene checklist bij problemen'), findsOneWidget);
    expect(find.text('Wanneer een blok weggooien?'), findsOneWidget);
    expect(find.text('Extra hulp nodig?'), findsOneWidget);
    expect(find.text('Notities maken'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows bewaren layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await _tapMushroomTab(tester, 'Bewaren');

    expect(find.text('Waarom goed bewaren belangrijk is'), findsOneWidget);
    expect(find.text('Bewaarmethoden'), findsOneWidget);
    expect(find.text('Stappen voor bewaren in de koelkast'), findsOneWidget);
    expect(find.text('Hoe lang kun je ze bewaren?'), findsOneWidget);
    expect(find.text('Tips voor optimaal bewaren'), findsOneWidget);
    expect(find.text('Verschillen in kwaliteit'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows flushes layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await _tapMushroomTab(tester, 'Flushes');

    expect(find.text('Wat zijn flushes?'), findsOneWidget);
    expect(find.text('De flush cyclus'), findsOneWidget);
    expect(find.text('Hoeveel flushes kun je verwachten?'), findsOneWidget);
    expect(find.text('Zo start je een nieuwe flush'), findsOneWidget);
    expect(find.text('Optimale omstandigheden na het oogsten'), findsOneWidget);
    expect(
      find.text('Veelvoorkomende problemen tussen flushes'),
      findsOneWidget,
    );
    expect(find.textContaining('Extra tip:'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows oogsten layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await _tapMushroomTab(tester, 'Oogsten');

    expect(find.text('Wanneer en hoe oogst je?'), findsOneWidget);
    expect(find.text('Wanneer is het tijd om te oogsten?'), findsOneWidget);
    expect(find.text('Hoe oogst je?'), findsOneWidget);
    expect(find.text('Na het oogsten'), findsOneWidget);
    expect(find.text('Tips voor een betere opbrengst'), findsOneWidget);
    expect(find.text('Wat kun je verwachten?'), findsOneWidget);
    expect(find.text('Veelgemaakte fouten'), findsOneWidget);
    expect(find.text('Juiste grootte'), findsOneWidget);
    expect(find.text('Draai en trek'), findsOneWidget);
  });

  testWidgets('MushroomInfoTab shows weetjes layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await _tapMushroomTab(tester, 'Weetjes');

    expect(
      find.text('Ontdek de fascinerende wereld van paddenstoelen'),
      findsOneWidget,
    );
    expect(find.text('Top 6 weetjes'), findsOneWidget);
    expect(find.text('Geen plant maar schimmel'), findsOneWidget);
    expect(find.text('Wist je dat?'), findsOneWidget);
    expect(find.text('Leuke feitjes over kweek'), findsOneWidget);
    expect(find.text('Soorten in de spotlight'), findsOneWidget);
    expect(find.text('Blijf nieuwsgierig!'), findsOneWidget);
    expect(find.text('Oesterzwam'), findsWidgets);
  });

  testWidgets('MushroomInfoTab shows vruchtvorming layout for oesterzwam', (tester) async {
    final vegetable = VegetableRepository().byId('oesterzwam');
    expect(vegetable, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MushroomInfoTab(vegetable: vegetable!),
        ),
      ),
    );
    await tester.pump();

    await _tapMushroomTab(tester, 'Vruchtvorming');

    expect(find.text('Wat is vruchtvorming?'), findsOneWidget);
    expect(find.text('Van pinhead tot oogst'), findsOneWidget);
    expect(find.text('Vruchtvorming stimuleren'), findsOneWidget);
    expect(find.text('Problemen bij vruchtvorming'), findsOneWidget);
    expect(find.text('Pinheads herkennen'), findsOneWidget);
  });
}
