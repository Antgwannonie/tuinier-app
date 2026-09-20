/// Tuinweetje van de dag, roteert op basis van de kalenderdatum.
class GardenDailyTip {
  const GardenDailyTip({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;
}

const List<GardenDailyTip> kGardenDailyTips = [
  GardenDailyTip(
    title: 'Ochtendwater',
    text: 'Geef liever vroeg water dan ’s avonds, dan verdampen minder '
        'nutriënten en drogen bladeren sneller af.',
  ),
  GardenDailyTip(
    title: 'Mulchen',
    text: 'Een laagje mulch houdt vocht vast, dempt onkruid en houdt '
        'de bodemtemperatuur stabieler.',
  ),
  GardenDailyTip(
    title: 'Nuttige insecten',
    text: 'Lieveheersbeestjes eten tot wel 50 bladluizen per dag. '
        'Laat ze gerust zitten in je moestuin.',
  ),
  GardenDailyTip(
    title: 'Wisselteelt',
    text: 'Zet dezelfde groentefamilie niet twee jaar op dezelfde plek, '
        'zo voorkom je ziekte-opbouw in de bodem.',
  ),
  GardenDailyTip(
    title: 'Tomaten zijkiezen',
    text: 'Verwijder bij tomaten regelmatig zijscheuten zodat energie '
        'naar vruchten en luchtcirculatie gaat.',
  ),
  GardenDailyTip(
    title: 'Regenwater',
    text: 'Regenwater is zachter dan kraanwater en vaak beter voor '
        'zuurminnende planten zoals blauwe bessen.',
  ),
  GardenDailyTip(
    title: 'Compost',
    text: 'Goede compost verbetert de bodemstructuur én voedt planten '
        'langzaam, een investering die zichzelf terugbetaalt.',
  ),
  GardenDailyTip(
    title: 'Zaaien in rijen',
    text: 'Zaai in dunne rijen zodat je later makkelijker kunt wieden '
        'en planten genoeg licht krijgen.',
  ),
  GardenDailyTip(
    title: 'Bijen in de tuin',
    text: 'Eén bloeiende kruidplant zoals bonenkruid trekt vaak al '
        'meer bestuivers naar je moestuin.',
  ),
  GardenDailyTip(
    title: 'Oogsten stimuleert',
    text: 'Regelmatig oogsten bij peulen, courgettes en sla houdt '
        'planten langer productief.',
  ),
  GardenDailyTip(
    title: 'Vorstbescherming',
    text: 'Dek jonge planten af met vliesdoek of een omgekeerde pot '
        'bij nachtvorst, verwijder overdag voor licht.',
  ),
  GardenDailyTip(
    title: 'Bodem niet betreden',
    text: 'Loop niet op natte bedden, dan verdicht de bodem en '
        'wortels krijgen minder zuurstof.',
  ),
  GardenDailyTip(
    title: 'Slakken',
    text: 'Slakken zijn actiever bij vochtig weer. Controleer planten '
        '’s ochtends vroeg als het geregend heeft.',
  ),
  GardenDailyTip(
    title: 'Kalkgroenten',
    text: 'Koolsoorten, broccoli en spruitjes zijn zware eters, '
        'bemest ze met compost of organische mest.',
  ),
  GardenDailyTip(
    title: 'Diep wortelen',
    text: 'Wortelgewassen groeien beter in losse, steenarme grond. '
        'Breek harde korst op voordat je zaait.',
  ),
  GardenDailyTip(
    title: 'Schaduw',
    text: 'Salade, spinazie en radijs gedijen vaak beter met wat '
        'middag schaduw in de zomer.',
  ),
  GardenDailyTip(
    title: 'Uitbloeien',
    text: 'Laat een paar planten bewust uitbloeien, dat helpt '
        'bestuivers en nuttige insecten in de tuin.',
  ),
  GardenDailyTip(
    title: 'Gieter bij wortels',
    text: 'Geef water bij de voet van de plant, niet over het blad, '
        'zo voorkom je schimmel en verbranding.',
  ),
  GardenDailyTip(
    title: 'Koude kieming',
    text: 'Sommige zaden kiemen beter na een nacht in de koelkast '
        'of na een koude periode buiten.',
  ),
  GardenDailyTip(
    title: 'Companion planting',
    text: 'Basilicum naast tomaten kan bladluis afschrikken én '
        'smaakt lekker in dezelfde maaltijd.',
  ),
  GardenDailyTip(
    title: 'Herfstcompost',
    text: 'Gooi geen zieke plantenresten op de compost, die kunnen '
        'ziekten overdragen naar volgend jaar.',
  ),
  GardenDailyTip(
    title: 'Groene bemesting',
    text: 'Mosterd of phacelia als groenbemester verbetert de bodem '
        'als je ze omspitten vóór de bloei.',
  ),
  GardenDailyTip(
    title: 'Potten drainen',
    text: 'Zorg dat potten altijd drainagegaten hebben, staand water '
        'is de snelste weg naar wortelrot.',
  ),
  GardenDailyTip(
    title: 'Snoeien in droog weer',
    text: 'Snoei bij droog weer zodat wonden sneller dichtgroeien '
        'en schimmels minder kans krijgen.',
  ),
  GardenDailyTip(
    title: 'Kruiden oogsten',
    text: 'Knip kruiden regelmatig boven een bladpaar, dan worden '
        'ze bossiger in plaats van lang en slap.',
  ),
  GardenDailyTip(
    title: 'Aardappelen',
    text: 'Aardappelen aanaarden beschermt knollen tegen licht, '
        'licht maakt ze groen en bitter.',
  ),
  GardenDailyTip(
    title: 'Wind',
    text: 'Bind hoge planten vast vóór storm, een stevige paal '
        'voorkomt breuk en wortelschade.',
  ),
  GardenDailyTip(
    title: 'Bodemleven',
    text: 'Een levende bodem met wormen en microben helpt planten '
        'voeding beter opnemen.',
  ),
  GardenDailyTip(
    title: 'Droogte',
    text: 'Liever één keer diep water geven dan vaak een beetje, '
        'zo groeien wortels dieper en sterker.',
  ),
  GardenDailyTip(
    title: 'Zaailingen',
    text: 'Zaailingen hebben veel licht nodig. Te weinig licht maakt '
        'ze lang en kwetsbaar.',
  ),
  GardenDailyTip(
    title: 'Tuinlogboek',
    text: 'Noteer wat je plant en wanneer je oogst, volgend jaar '
        'weet je precies wat werkte.',
  ),
  GardenDailyTip(
    title: 'Insectenhotel',
    text: 'Een insectenhotel of stapel hout trekt overwinterende '
        'nuttige insecten naar je tuin.',
  ),
];

/// Zelfde weetje op dezelfde kalenderdag (stabiel bij herstart).
GardenDailyTip gardenTipOfTheDay([DateTime? on]) {
  final d = on ?? DateTime.now();
  final start = DateTime(d.year, 1, 1);
  final dayIndex = d.difference(start).inDays;
  return kGardenDailyTips[dayIndex % kGardenDailyTips.length];
}

/// Weetje voor onderaan het scanrapport — AI-fact of plant-specifiek roterend tip.
GardenDailyTip scanFactForPlant({
  String? plantNameNl,
  String? plantId,
  required DateTime scannedAt,
  String? aiFact,
  String? harvestTips,
  String? care,
}) {
  if (aiFact != null && aiFact.trim().isNotEmpty) {
    return GardenDailyTip(title: 'Wist je dat?', text: aiFact.trim());
  }

  final plantKey = (plantId ?? plantNameNl ?? '').toLowerCase();
  final matched = <GardenDailyTip>[];
  for (final tip in kGardenDailyTips) {
    final hay = '${tip.title} ${tip.text}'.toLowerCase();
    if (plantKey.isNotEmpty &&
        (hay.contains(plantKey) ||
            (plantNameNl != null &&
                hay.contains(plantNameNl.toLowerCase())))) {
      matched.add(tip);
    }
  }
  if (matched.isNotEmpty) {
    final idx = scannedAt.difference(DateTime(scannedAt.year, 1, 1)).inDays;
    return matched[idx % matched.length];
  }

  if (harvestTips != null && harvestTips.trim().isNotEmpty) {
    return GardenDailyTip(
      title: 'Wist je dat?',
      text: harvestTips.trim(),
    );
  }
  if (care != null && care.trim().isNotEmpty) {
    return GardenDailyTip(
      title: 'Wist je dat?',
      text: care.trim(),
    );
  }

  final base = gardenTipOfTheDay(scannedAt);
  if (plantNameNl != null && plantNameNl.trim().isNotEmpty) {
    return GardenDailyTip(
      title: base.title,
      text: '${base.text}\n\n(Geldt ook voor je $plantNameNl.)',
    );
  }
  return base;
}
