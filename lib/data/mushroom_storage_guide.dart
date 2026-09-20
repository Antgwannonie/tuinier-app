import 'package:flutter/material.dart';

import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

enum StorageMethodIcon { fridge, dry, freeze, jar }

class StorageMethodCard {
  const StorageMethodCard({
    required this.title,
    required this.icon,
    required this.assetPath,
    required this.checkmarks,
  });

  final String title;
  final StorageMethodIcon icon;
  final String assetPath;
  final List<String> checkmarks;
}

class StorageFridgeStep {
  const StorageFridgeStep({
    required this.title,
    required this.body,
    this.assetPath,
    this.useClockIcon = false,
  });

  final String title;
  final String body;
  final String? assetPath;
  final bool useClockIcon;
}

class StorageShelfLifeRow {
  const StorageShelfLifeRow({
    required this.method,
    required this.shelfLife,
  });

  final String method;
  final String shelfLife;
}

enum StorageQualityLevel { fresh, warning, bad }

class StorageQualityCard {
  const StorageQualityCard({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.assetPath,
  });

  final String title;
  final String subtitle;
  final StorageQualityLevel level;
  final String assetPath;
}

class MushroomStorageGuide with MushroomGuideCardData {
  const MushroomStorageGuide({
    required this.heroBody,
    required this.methods,
    required this.fridgeSteps,
    required this.shelfLifeRows,
    required this.tips,
    required this.qualityCards,
    required this.mistakes,
    required this.footerTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String heroBody;
  final List<StorageMethodCard> methods;
  final List<StorageFridgeStep> fridgeSteps;
  final List<StorageShelfLifeRow> shelfLifeRows;
  final List<String> tips;
  final List<StorageQualityCard> qualityCards;
  final List<String> mistakes;
  final String footerTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_storage';

const _methods = [
  StorageMethodCard(
    title: 'Koelkast',
    icon: StorageMethodIcon.fridge,
    assetPath: '$_asset/storage_method_fridge.png',
    checkmarks: [
      '2–4 °C',
      '3–7 dagen vers',
    ],
  ),
  StorageMethodCard(
    title: 'Drogen',
    icon: StorageMethodIcon.dry,
    assetPath: '$_asset/storage_method_dry.png',
    checkmarks: [
      '40–50 °C',
      'Maanden tot een jaar',
    ],
  ),
  StorageMethodCard(
    title: 'Invriezen',
    icon: StorageMethodIcon.freeze,
    assetPath: '$_asset/storage_method_freeze.png',
    checkmarks: [
      '−18 °C',
      '3–6 maanden',
    ],
  ),
  StorageMethodCard(
    title: 'Pot/in olie',
    icon: StorageMethodIcon.jar,
    assetPath: '$_asset/storage_method_jar.png',
    checkmarks: [
      'Gesteriliseerd',
      'Weken tot maanden',
    ],
  ),
];

const _qualityCards = [
  StorageQualityCard(
    title: 'Vers (optimaal)',
    subtitle: 'Stevig, droog, frisse geur en heldere kleur.',
    level: StorageQualityLevel.fresh,
    assetPath: '$_asset/storage_quality_fresh.png',
  ),
  StorageQualityCard(
    title: 'Let op',
    subtitle: 'Licht vochtig, verkleuring of zachtere textuur.',
    level: StorageQualityLevel.warning,
    assetPath: '$_asset/storage_quality_warning.png',
  ),
  StorageQualityCard(
    title: 'Te lang bewaard',
    subtitle: 'Slijmerig, muffe geur of schimmel — niet meer eten.',
    level: StorageQualityLevel.bad,
    assetPath: '$_asset/storage_quality_bad.png',
  ),
];

MushroomStorageGuide storageGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final shelf = _shelfLifeFor(vegetable.id);

  final heroBody =
      'Goed bewaren houdt $name langer vers en behoudt smaak en voedingswaarde. '
      'Vers geoogste paddenstoelen zijn het meest kwetsbaar — koel, droog en luchtdoorlatend '
      'opslaan voorkomt slijmerigheid en bederf. ${overview.edibility}';

  final fridgeSteps = [
    const StorageFridgeStep(
      title: 'Oogsten',
      body: 'Oogst vers en verwerk zo snel mogelijk.',
      assetPath: '$_asset/storage_step_harvest.png',
    ),
    const StorageFridgeStep(
      title: 'Schoonmaken',
      body: 'Veeg schoon met een vochtige doek — niet wassen.',
      assetPath: '$_asset/storage_step_clean.png',
    ),
    const StorageFridgeStep(
      title: 'Verpakken',
      body: 'Papieren zak of luchtdoorlatende doos.',
      assetPath: '$_asset/storage_step_pack.png',
    ),
    const StorageFridgeStep(
      title: 'Koelkast',
      body: 'Bewaar bij 2–4 °C in de koelkast.',
      assetPath: '$_asset/storage_step_fridge.png',
    ),
    StorageFridgeStep(
      title: 'Gebruik binnen ${shelf.fridgeDays} dagen',
      body: 'Controleer dagelijks op verkleuring of geur.',
      useClockIcon: true,
    ),
  ];

  final shelfLifeRows = [
    StorageShelfLifeRow(method: 'Koelkast', shelfLife: shelf.fridgeDays),
    const StorageShelfLifeRow(method: 'Drogen', shelfLife: '6–12 maanden'),
    StorageShelfLifeRow(method: 'Invriezen', shelfLife: shelf.freezeMonths),
    const StorageShelfLifeRow(method: 'Pot/in olie', shelfLife: '2–4 weken'),
  ];

  final tips = [
    'Bewaar nooit in gesloten plastic — condens veroorzaakt bederf',
    'Oogst en verwerk op dezelfde dag voor beste kwaliteit',
    'Gebruik papieren zak of luchtdoorlatende doos in de koelkast',
    'Droog of vries overschot direct — niet te lang vers laten liggen',
    'Ruik en voel altijd voor gebruik — bij twijfel weggooien',
  ];

  final mistakes = [
    'In gesloten plastic bewaren — condens en slijmerigheid',
    'Paddenstoelen wassen vóór opslag — ze absorberen water',
    'Te warm bewaren — versnelde bederf buiten de koelkast',
    'Beschadigde of vieze paddenstoelen bewaren — besmet rest',
    'Te lang bewaren en alsnog gebruiken — gezondheidsrisico',
  ];

  return MushroomStorageGuide(
    heroBody: heroBody,
    methods: _methods,
    fridgeSteps: fridgeSteps,
    shelfLifeRows: shelfLifeRows,
    tips: tips,
    qualityCards: _qualityCards,
    mistakes: mistakes,
    footerTip:
        'Oogst $name vers en bewaar koel, droog en luchtdoorlatend — zo blijven ze het lekkerst!',
    cardSummaries: mushroomCardSummaries(
      tab: 'storage',
      vegetable: vegetable,
      titles: const [
        'Waarom goed bewaren belangrijk is',
        'Bewaarmethoden',
        'Stappen voor bewaren in de koelkast',
        'Hoe lang kun je ze bewaren?',
        'Tips voor optimaal bewaren',
        'Verschillen in kwaliteit',
        'Veelgemaakte fouten',
      ],
    ),
    cardDetails: {
      'Waarom goed bewaren belangrijk is': mushroomDetailBlocks(fullBody: heroBody),
      'Bewaarmethoden': [
        for (final m in _methods)
          PlantGuideDetailBlock(
            heading: m.title,
            body: m.checkmarks.join('\n'),
          ),
      ],
      'Stappen voor bewaren in de koelkast': [
        for (final s in fridgeSteps)
          PlantGuideDetailBlock(heading: s.title, body: s.body),
      ],
      'Hoe lang kun je ze bewaren?': mushroomDetailBlocks(
        fullBody: shelfLifeRows.map((r) => '${r.method}: ${r.shelfLife}').join('\n'),
      ),
      'Tips voor optimaal bewaren':
          mushroomDetailBlocks(fullBody: tips.map((t) => '• $t').join('\n')),
      'Verschillen in kwaliteit': [
        for (final q in _qualityCards)
          PlantGuideDetailBlock(heading: q.title, body: q.subtitle),
      ],
      'Veelgemaakte fouten':
          mushroomDetailBlocks(fullBody: mistakes.map((m) => '• $m').join('\n')),
    },
  );
}

class _ShelfLife {
  const _ShelfLife({
    required this.fridgeDays,
    required this.freezeMonths,
  });

  final String fridgeDays;
  final String freezeMonths;
}

_ShelfLife _shelfLifeFor(String id) {
  switch (id) {
    case 'shiitake':
      return const _ShelfLife(fridgeDays: '7–10 dagen', freezeMonths: '6 maanden');
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return const _ShelfLife(fridgeDays: '3–5 dagen', freezeMonths: '3 maanden');
    case 'morielzwam':
      return const _ShelfLife(fridgeDays: '2–4 dagen', freezeMonths: '3 maanden');
    default:
      return const _ShelfLife(fridgeDays: '5–7 dagen', freezeMonths: '4–6 maanden');
  }
}

IconData storageMethodIcon(StorageMethodIcon icon) {
  return switch (icon) {
    StorageMethodIcon.fridge => Icons.ac_unit_rounded,
    StorageMethodIcon.dry => Icons.wb_sunny_rounded,
    StorageMethodIcon.freeze => Icons.ac_unit_rounded,
    StorageMethodIcon.jar => Icons.inventory_2_outlined,
  };
}
