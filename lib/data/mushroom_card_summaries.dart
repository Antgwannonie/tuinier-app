import '../models/vegetable.dart';
import 'mushroom_overview_data.dart';

/// Korte, soort-specifieke kaart-samenvatting voor paddenstoel-encyclopedie-tabs.
String mushroomCardSummaryFor({
  required String tab,
  required String title,
  required Vegetable vegetable,
}) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();

  final key = '${tab}::$title';
  return switch (key) {
    // ── Water ──
    'water::Waarom is water belangrijk?' =>
      'Water is essentieel voor gezonde groei van $name bij ${overview.humidity} luchtvochtigheid.',
    'water::De ideale watercondities' =>
      'Houd ${overview.humidity} luchtvochtigheid aan en vernevel regelmatig voor $name.',
    'water::Hoe geef je water?' =>
      'Vernevel fijn en gelijkmatig, meerdere keren per dag.',
    'water::Signalen: te droog of te nat' =>
      'Let op signalen van uitdroging of overmatig vocht bij $name.',
    'water::Te droog' =>
      'Te droog: trage groei, kleine pinheads en droog substraat bij $name.',
    'water::Te nat' =>
      'Te nat: druppels, vlekken en rot-risico bij $name — ventileer meer.',
    'water::Tips voor optimaal waterbeheer' =>
      'Praktische tips om ${overview.humidity} stabiel te houden.',
    'water::Veelgemaakte fouten' =>
      'Vermijd deze veelgemaakte waterfouten bij het kweken van $name.',

    // ── Substrate ──
    'substrate::Wat is substraat?' =>
      'Substraat is het voedingsmedium voor het mycelium van $name.',
    'substrate::Waarvoor gebruik je het?' =>
      'Substraat voedt het mycelium en houdt vocht vast tijdens de kweek van $name.',
    'substrate::Beste substraat' =>
      '$name groeit het beste op ${overview.substrate}.',
    'substrate::Alternatieve substraten' =>
      'Naast het ideale substraat zijn er alternatieven voor $name.',
    'substrate::Geschikte houtsoorten' =>
      'Verschillende houtsoorten beïnvloeden de groei van $name.',
    'substrate::Ideaal vochtgehalte' =>
      'Het substraat moet 60–70 % vochtig zijn — niet te nat, niet te droog.',
    'substrate::Substraat voorbereiden' =>
      'Volg deze stappen voor een schoon, goed voorbereid substraat.',
    'substrate::Pasteuriseren' =>
      'Verhit het substraat om ongewenste organismen te doden.',
    'substrate::Steriliseren' =>
      'Volledige sterilisatie voor maximale zuiverheid van het substraat.',
    'substrate::Temperatuur van het substraat' =>
      'Het substraat moet 20–25 °C zijn voordat je gaat enten.',
    'substrate::Veelgemaakte fouten' =>
      'Vermijd deze veelgemaakte substraatfouten bij $name.',
    'substrate::Besmetting voorkomen' =>
      'Werk hygiënisch om besmetting van het substraat te voorkomen.',

    // ── Inoculation ──
    'inoculation::Wat is enten?' =>
      'Enten is het toevoegen van broed aan je substraat voor $name.',
    'inoculation::Wanneer enten?' =>
      'Het juiste moment om $name te enten hangt af van temperatuur en substraat.',
    'inoculation::Hoeveel broed gebruiken?' =>
      'De juiste verhouding broed/substraat is belangrijk voor $name.',
    'inoculation::Entmethode' =>
      'Stap voor stap het broed toevoegen en afsluiten.',
    'inoculation::Temperatuur tijdens enten' =>
      'Houd 20–25 °C aan tijdens het enten voor optimale start.',
    'inoculation::Hygiëne is cruciaal' =>
      'Schoon werken voorkomt besmetting bij het enten van $name.',
    'inoculation::Benodigdheden' =>
      'Alles wat je nodig hebt om $name te enten.',
    'inoculation::Veelgemaakte fouten' =>
      'Vermijd deze entfouten voor een succesvolle kweek van $name.',
    'inoculation::Besmetting voorkomen' =>
      'Preventieve maatregelen tegen besmetting bij het enten.',

    // ── Colonization ──
    'colonization::Wat is kolonisatie?' =>
      'Kolonisatie is de fase waarin mycelium het substraat van $name overgroeit.',
    'colonization::Ideale omstandigheden' =>
      '${overview.temperature} en ${overview.humidity} zijn ideaal tijdens kolonisatie.',
    'colonization::Kolonisatieduur' =>
      'De kolonisatieduur van $name hangt af van temperatuur en substraat.',
    'colonization::Gezond mycelium herkennen' =>
      'Gezond mycelium is wit, stevig en groeit gelijkmatig.',
    'colonization::Volledige kolonisatie herkennen' =>
      'Herken wanneer het substraat van $name volledig gekoloniseerd is.',
    'colonization::Groei controleren' =>
      'Controleer visueel, voel en ruik om de groei te beoordelen.',
    'colonization::Problemen tijdens kolonisatie' =>
      'Herken en los veelvoorkomende problemen op tijdens kolonisatie.',
    'colonization::Veelgemaakte fouten' =>
      'Vermijd deze fouten voor een vlotte kolonisatie van $name.',

    // ── Fruiting ──
    'fruiting::Wat is vruchtvorming?' =>
      'Vruchtvorming is de fase waarin pinheads van $name uitgroeien tot paddenstoelen.',
    'fruiting::Omstandigheden' =>
      '${overview.temperature}, ${overview.humidity} en frisse lucht zijn cruciaal.',
    'fruiting::Van pinhead tot oogst' =>
      'De groeifasen van pinhead tot oogstbare paddenstoel.',
    'fruiting::Vruchtvorming stimuleren' =>
      'Acties om vruchtzetting van $name te stimuleren.',
    'fruiting::Problemen bij vruchtvorming' =>
      'Herken en voorkom problemen bij de vruchtzetting van $name.',

    // ── Environment ──
    'environment::De ideale omgeving' =>
      'Stabiliteit in temperatuur en luchtvochtigheid is de sleutel voor $name.',
    'environment::Kies je kweekomgeving' =>
      'Kies de beste locatie voor het kweken van $name.',
    'environment::Ideale omgevingsfactoren' =>
      '${overview.temperature}, ${overview.humidity} en ${overview.ventilation} ventilatie.',
    'environment::Omgeving per groeifase' =>
      'Elke groeifase van $name vraagt andere omgevingscondities.',
    'environment::Veelgemaakte fouten' =>
      'Vermijd deze omgevingsfouten bij het kweken van $name.',

    // ── Growth ──
    'growth::Wat gebeurt er tijdens de groei?' =>
      'Van mycelium tot oogstbare paddenstoelen — gemiddeld ${overview.timeToHarvest}.',
    'growth::De groeifase in het kort' =>
      'Overzicht van de groeifasen: kolonisatie, vruchtzetting, groei en oogst.',
    'growth::Ideale omstandigheden tijdens groei' =>
      '${overview.temperature} en ${overview.humidity} voor optimale groei van $name.',
    'growth::Wat kun je verwachten?' =>
      '${overview.yield} per flush, ${overview.flushCount}.',
    'growth::Fasen van de groei' =>
      'Van eerste pinheads tot volgroeide paddenstoelen.',
    'growth::Tips voor een gezonde groei' =>
      'Praktische tips voor een gezonde groeifase van $name.',
    'growth::Veelgemaakte fouten' =>
      'Vermijd deze groeifouten bij het kweken van $name.',

    // ── Harvest ──
    'harvest::Wanneer en hoe oogst je?' =>
      'Oogst $name op het juiste moment voor de beste smaak en textuur.',
    'harvest::Wanneer is het tijd om te oogsten?' =>
      'Herken het ideale oogstmoment aan grootte, stevigheid en hoedvorm.',
    'harvest::Hoe oogst je?' =>
      'Stap voor stap de paddenstoel schoon en correct oogsten.',
    'harvest::Na het oogsten' =>
      'Bevochtig, ventileer en houd condities stabiel na de oogst.',
    'harvest::Tips voor een betere opbrengst' =>
      'Praktische oogsttips voor een betere opbrengst van $name.',
    'harvest::Wat kun je verwachten?' =>
      '${overview.flushCount} met ${overview.yield} per flush.',
    'harvest::Veelgemaakte fouten' =>
      'Vermijd deze oogstfouten bij $name.',

    // ── Flushes ──
    'flushes::Wat zijn flushes?' =>
      'Een flush is een oogstgolf — $name geeft gemiddeld ${overview.flushCount}.',
    'flushes::De flush cyclus' =>
      'Van oogst naar herstel naar nieuwe pinheads — de cyclus herhaalt zich.',
    'flushes::Hoeveel flushes kun je verwachten?' =>
      '${overview.flushCount} met afnemende opbrengst per ronde.',
    'flushes::Zo start je een nieuwe flush' =>
      'Stap voor stap een nieuwe oogstronde opstarten.',
    'flushes::Optimale omstandigheden na het oogsten' =>
      '${overview.temperature} en ${overview.humidity} stabiel houden na oogst.',
    'flushes::Veelvoorkomende problemen tussen flushes' =>
      'Herken en los problemen op tussen oogstrondes van $name.',

    // ── Problems ──
    'problems::Problemen vroeg herkennen' =>
      'Controleer dagelijks op kleur, geur en textuur bij $name.',
    'problems::Veelvoorkomende problemen' =>
      'De vijf meest voorkomende problemen bij het kweken van $name.',
    'problems::Problemen snel herkennen' =>
      'Visuele gids voor het herkennen van veelvoorkomende problemen.',
    'problems::Algemene checklist bij problemen' =>
      'Controleer deze punten bij problemen met $name.',
    'problems::Wanneer een blok weggooien?' =>
      'Herken wanneer je substraat niet meer te redden is.',
    'problems::Extra hulp nodig?' =>
      'Aanvullende tips en hulpmiddelen voor probleemoplossing bij $name.',

    // ── Storage ──
    'storage::Waarom goed bewaren belangrijk is' =>
      'Goed bewaren houdt $name langer vers en behoudt smaak.',
    'storage::Bewaarmethoden' =>
      'Koelkast, drogen, invriezen of inmaken — kies de beste methode.',
    'storage::Stappen voor bewaren in de koelkast' =>
      'Stap voor stap $name vers bewaren in de koelkast.',
    'storage::Houdbaarheid en tips' =>
      'Hoelang blijft $name vers per bewaarmethode, met praktische tips.',
    'storage::Hoe lang kun je ze bewaren?' =>
      'Hoelang blijft $name vers per bewaarmethode.',
    'storage::Tips voor optimaal bewaren' =>
      'Praktische bewaartips om $name langer vers te houden.',
    'storage::Verschillen in kwaliteit' =>
      'Herken of $name nog vers, twijfelachtig of bedorven is.',
    'storage::Veelgemaakte fouten' =>
      'Vermijd deze bewaarfouten om $name langer vers te houden.',

    // ── Facts ──
    'facts::Ontdek paddenstoelen' =>
      'Fascinerende feiten over $name en de wereld van paddenstoelen.',
    'facts::Ontdek de fascinerende wereld van paddenstoelen' =>
      'Fascinerende feiten over $name en de wereld van paddenstoelen.',
    'facts::Top 6 weetjes' =>
      'Zes verrassende weetjes over paddenstoelen.',
    'facts::Wist je dat?' =>
      'Bijzondere feiten over het rijk der schimmels.',
    'facts::Leuke feitjes over kweek' =>
      'Van growkit tot eerste oogst — leuke kweekfeitjes.',
    'facts::Soorten in de spotlight' =>
      'Ontdek populaire paddenstoelsoorten naast $name.',

    _ => '${overview.goodToKnow}',
  };
}
