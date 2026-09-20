import '../models/vegetable.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'plant_guide_detail.dart';

const _asset = 'assets/images/flower_weetjes';

class FlowerWeetjesChip {
  const FlowerWeetjesChip({required this.label, required this.imageAsset});

  final String label;
  final String imageAsset;
}

class FlowerWeetjesSection {
  const FlowerWeetjesSection({
    required this.title,
    required this.body,
    this.imageAsset,
    this.chips = const [],
    this.details = const [],
  });

  final String title;
  final String body;
  final String? imageAsset;
  final List<FlowerWeetjesChip> chips;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerWeetjesGuideData {
  const FlowerWeetjesGuideData({
    required this.intro,
    required this.sections,
    required this.tip,
    required this.tipImage,
  });

  final String intro;
  final List<FlowerWeetjesSection> sections;
  final String tip;
  final String tipImage;
}

/// @Deprecated Prefer [flowerWeetjesGuideForVegetable].
const flowerWeetjesGuideData = FlowerWeetjesGuideData(
  intro: 'Ontdek oorsprong, geschiedenis en verrassende weetjes.',
  sections: [],
  tip: 'Combineer schoonheid en functionaliteit in jouw tuin.',
  tipImage: '$_asset/fw_tip.png',
);

List<PlantGuideDetailBlock> _wd(
  Vegetable v,
  FlowerGuideProfile p,
  String title,
) =>
    flowerSectionDetailsFor(
      tab: 'weetjes',
      title: title,
      vegetable: v,
      profile: p,
    );

List<FlowerWeetjesChip> _verrassingChips(FlowerGuideProfile p) {
  switch (p.key) {
    case FlowerProfileKey.annualCut:
      return const [
        FlowerWeetjesChip(label: 'Droogbloem', imageAsset: '$_asset/fw_chip_droogbloem.png'),
        FlowerWeetjesChip(label: 'Potpourri', imageAsset: '$_asset/fw_chip_natuurlijke_geuren.png'),
        FlowerWeetjesChip(label: 'Decoratie', imageAsset: '$_asset/fw_chip_decoratie.png'),
      ];
    case FlowerProfileKey.companionPest:
      return const [
        FlowerWeetjesChip(label: 'Eetbare bloem', imageAsset: '$_asset/fw_chip_companion.png'),
        FlowerWeetjesChip(label: 'Natuurlijke verfstof', imageAsset: '$_asset/fw_chip_verfstoffen.png'),
        FlowerWeetjesChip(label: 'Insectenwerend', imageAsset: '$_asset/fw_chip_plagen.png'),
      ];
    case FlowerProfileKey.pollinator:
      return const [
        FlowerWeetjesChip(label: 'Eetbare bloem', imageAsset: '$_asset/fw_chip_companion.png'),
        FlowerWeetjesChip(label: 'Kruidenthee', imageAsset: '$_asset/fw_chip_kruidenmengsels.png'),
        FlowerWeetjesChip(label: 'Medicinaal', imageAsset: '$_asset/fw_chip_cosmetica.png'),
      ];
    case FlowerProfileKey.greenManure:
      return const [
        FlowerWeetjesChip(label: 'Bijenhoning', imageAsset: '$_asset/fw_chip_bijenplant.png'),
        FlowerWeetjesChip(label: 'Bodemverbetering', imageAsset: '$_asset/fw_chip_biodiversiteit.png'),
        FlowerWeetjesChip(label: 'Mulchmateriaal', imageAsset: '$_asset/fw_chip_companion.png'),
      ];
    case FlowerProfileKey.mediterranean:
      return const [
        FlowerWeetjesChip(label: 'Cosmetica', imageAsset: '$_asset/fw_chip_cosmetica.png'),
        FlowerWeetjesChip(label: 'Geurzakjes', imageAsset: '$_asset/fw_chip_natuurlijke_geuren.png'),
        FlowerWeetjesChip(label: 'Culinair', imageAsset: '$_asset/fw_chip_kruidenmengsels.png'),
      ];
    case FlowerProfileKey.herbBloom:
      return const [
        FlowerWeetjesChip(label: 'Kruidenthee', imageAsset: '$_asset/fw_chip_kruidenmengsels.png'),
        FlowerWeetjesChip(label: 'Eetbare bloem', imageAsset: '$_asset/fw_chip_companion.png'),
        FlowerWeetjesChip(label: 'Geurplant', imageAsset: '$_asset/fw_chip_geurplant.png'),
      ];
    case FlowerProfileKey.treeBloom:
      return const [
        FlowerWeetjesChip(label: 'Bloesemthee', imageAsset: '$_asset/fw_chip_kruidenmengsels.png'),
        FlowerWeetjesChip(label: 'Honing', imageAsset: '$_asset/fw_chip_bijenplant.png'),
        FlowerWeetjesChip(label: 'Hout', imageAsset: '$_asset/fw_chip_decoratie.png'),
      ];
  }
}

List<FlowerWeetjesChip> _kleurChips(FlowerGuideProfile p) {
  List<FlowerWeetjesChip> kc(List<String> kleuren) {
    return [
      for (final k in kleuren)
        FlowerWeetjesChip(
          label: k,
          imageAsset: '$_asset/fw_chip_kleur_${k.toLowerCase()}.png',
        ),
    ];
  }
  switch (p.key) {
    case FlowerProfileKey.annualCut:
      return kc(const ['Geel', 'Oranje', 'Roze', 'Wit', 'Rood']);
    case FlowerProfileKey.companionPest:
      return kc(const ['Oranje', 'Geel', 'Rood']);
    case FlowerProfileKey.pollinator:
      return kc(const ['Blauw', 'Paars', 'Roze', 'Geel', 'Wit']);
    case FlowerProfileKey.greenManure:
      return kc(const ['Paars', 'Geel', 'Wit']);
    case FlowerProfileKey.mediterranean:
      return kc(const ['Paars', 'Blauw', 'Wit', 'Roze']);
    case FlowerProfileKey.herbBloom:
      return kc(const ['Wit', 'Roze', 'Paars', 'Geel']);
    case FlowerProfileKey.treeBloom:
      return kc(const ['Crème', 'Geelwit']);
  }
}

FlowerWeetjesGuideData flowerWeetjesGuideForVegetable(Vegetable v) {
  final p = flowerGuideProfileFor(v.id);
  final name = v.nameNl.split('(').first.trim();
  String sum(String title) => flowerCardSummaryFor(
        tab: 'weetjes',
        title: title,
        vegetable: v,
        profile: p,
      );

  return FlowerWeetjesGuideData(
    intro:
        'Ontdek de oorsprong, geschiedenis en verrassende weetjes van $name.',
    sections: [
      FlowerWeetjesSection(
        title: 'Oorsprong',
        body: sum('Oorsprong'),
        imageAsset: '$_asset/fw_oorsprong.png',
        details: _wd(v, p, 'Oorsprong'),
      ),
      FlowerWeetjesSection(
        title: 'Historie',
        body: sum('Historie'),
        imageAsset: '$_asset/fw_historie.png',
        details: _wd(v, p, 'Historie'),
      ),
      FlowerWeetjesSection(
        title: 'Symboliek',
        body: sum('Symboliek'),
        imageAsset: '$_asset/fw_symboliek.png',
        details: _wd(v, p, 'Symboliek'),
      ),
      FlowerWeetjesSection(
        title: 'Bijzonderheden',
        body: sum('Bijzonderheden'),
        imageAsset: '$_asset/fw_bijzonderheden.png',
        details: _wd(v, p, 'Bijzonderheden'),
      ),
      FlowerWeetjesSection(
        title: 'Gebruik door de eeuwen heen',
        body: sum('Gebruik door de eeuwen heen'),
        imageAsset: '$_asset/fw_eeuwen.png',
        details: _wd(v, p, 'Gebruik door de eeuwen heen'),
      ),
      FlowerWeetjesSection(
        title: 'Gebruik in boeketten',
        body: sum('Gebruik in boeketten'),
        imageAsset: '$_asset/fw_boeketten.png',
        details: _wd(v, p, 'Gebruik in boeketten'),
      ),
      FlowerWeetjesSection(
        title: 'Gebruik in tuinen',
        body: sum('Gebruik in tuinen'),
        imageAsset: '$_asset/fw_tuinen.png',
        details: _wd(v, p, 'Gebruik in tuinen'),
      ),
      FlowerWeetjesSection(
        title: 'Gebruik wereldwijd',
        body: sum('Gebruik wereldwijd'),
        imageAsset: '$_asset/fw_wereldwijd.png',
        details: _wd(v, p, 'Gebruik wereldwijd'),
      ),
      FlowerWeetjesSection(
        title: 'Toepassingen',
        body: sum('Toepassingen'),
        chips: const [
          FlowerWeetjesChip(
            label: 'Bijenplant',
            imageAsset: '$_asset/fw_chip_bijenplant.png',
          ),
          FlowerWeetjesChip(
            label: 'Vlinderplant',
            imageAsset: '$_asset/fw_chip_vlinderplant.png',
          ),
          FlowerWeetjesChip(
            label: 'Snijbloem',
            imageAsset: '$_asset/fw_chip_snijbloem.png',
          ),
          FlowerWeetjesChip(
            label: 'Droogbloem',
            imageAsset: '$_asset/fw_chip_droogbloem.png',
          ),
          FlowerWeetjesChip(
            label: 'Geurplant',
            imageAsset: '$_asset/fw_chip_geurplant.png',
          ),
          FlowerWeetjesChip(
            label: 'Companion plant',
            imageAsset: '$_asset/fw_chip_companion.png',
          ),
        ],
        details: _wd(v, p, 'Toepassingen'),
      ),
      FlowerWeetjesSection(
        title: 'Waarde voor de moestuin',
        body: sum('Waarde voor de moestuin'),
        chips: const [
          FlowerWeetjesChip(
            label: 'Trekt bestuivers aan',
            imageAsset: '$_asset/fw_chip_bestuivers.png',
          ),
          FlowerWeetjesChip(
            label: 'Lokt nuttige insecten',
            imageAsset: '$_asset/fw_chip_nuttige_insecten.png',
          ),
          FlowerWeetjesChip(
            label: 'Helpt tegen plagen',
            imageAsset: '$_asset/fw_chip_plagen.png',
          ),
          FlowerWeetjesChip(
            label: 'Companion plant',
            imageAsset: '$_asset/fw_chip_companion.png',
          ),
          FlowerWeetjesChip(
            label: 'Verbetert biodiversiteit',
            imageAsset: '$_asset/fw_chip_biodiversiteit.png',
          ),
        ],
        details: _wd(v, p, 'Waarde voor de moestuin'),
      ),
      FlowerWeetjesSection(
        title: 'Verrassende toepassingen',
        body: sum('Verrassende toepassingen'),
        chips: _verrassingChips(p),
        details: _wd(v, p, 'Verrassende toepassingen'),
      ),
      FlowerWeetjesSection(
        title: 'Wist je dat?',
        body: sum('Wist je dat?'),
        imageAsset: '$_asset/fw_wist_je_dat.png',
        details: _wd(v, p, 'Wist je dat?'),
      ),
      FlowerWeetjesSection(
        title: 'Betekenis van de naam',
        body: sum('Betekenis van de naam'),
        imageAsset: '$_asset/fw_naam.png',
        details: _wd(v, p, 'Betekenis van de naam'),
      ),
      FlowerWeetjesSection(
        title: 'Familie',
        body: sum('Familie'),
        imageAsset: '$_asset/fw_familie.png',
        details: _wd(v, p, 'Familie'),
      ),
      FlowerWeetjesSection(
        title: 'Populaire rassen',
        body: sum('Populaire rassen'),
        imageAsset: '$_asset/fw_rassen.png',
        details: _wd(v, p, 'Populaire rassen'),
      ),
      FlowerWeetjesSection(
        title: 'Kleurvarianten',
        body: sum('Kleurvarianten'),
        chips: _kleurChips(p),
        details: _wd(v, p, 'Kleurvarianten'),
      ),
    ],
    tip: p.tip.isNotEmpty
        ? p.tip
        : '$name is niet alleen prachtig, maar ook nuttig in de moestuin!',
    tipImage: '$_asset/fw_tip.png',
  );
}
