/// JSON-schema voor uitgebreide plantanalyse (NL).
const String kPlantAiInsightJsonSchema = '''
  "insight": {
    "summary": "1-2 zinnen: korte samenvatting voor de tuinier",
    "healthScore": <int 0-100 algemene gezondheid>,
    "growthScore": <int 0-100 groei/kracht>,
    "riskLevel": "low|medium|high",
    "priority": "low|medium|high|urgent",
    "problems": ["korte NL problemen die je ziet, max 6"],
    "pests": [
      {"id":"bladluis","labelNl":"Bladluis","detected":<bool>,"confidencePercent":<0-100>,"symptoms":<of null>,"action":<of null>},
      {"id":"witte_vlieg","labelNl":"Witte vlieg","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"spint","labelNl":"Spint","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"trips","labelNl":"Trips","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"rups","labelNl":"Rupsen","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"kever","labelNl":"Kevers","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>}
    ],
    "diseases": [
      {"id":"meeldauw","labelNl":"Meeldauw","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"valse_meeldauw","labelNl":"Valse meeldauw","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"roest","labelNl":"Roest","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"bladvlek","labelNl":"Bladvlekkenziekte","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"schimmel","labelNl":"Schimmelinfectie","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>}
    ],
    "waterStatus": "ok|too_dry|too_wet|wilting",
    "waterSymptoms": <NL of null>,
    "waterAdvice": <praktisch NL of null>,
    "nutrients": [
      {"id":"stikstof","labelNl":"Stikstoftekort","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"explanation":<of null>},
      {"id":"magnesium","labelNl":"Magnesiumtekort","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"explanation":<of null>},
      {"id":"kalium","labelNl":"Kaliumtekort","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"explanation":<of null>},
      {"id":"ijzer","labelNl":"IJzertekort","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"explanation":<of null>}
    ],
    "growthPhaseDetail": "zaailing|jonge_plant|vegetatief|bloei|vruchtvorming|oogst",
    "harvestReady": <bool>,
    "ripenessNote": <NL of null>,
    "floweringStatus": "none|buds|blooming|faded",
    "floweringNote": <NL of null>,
    "growthScheduleStatus": "ahead|on_track|behind|unknown",
    "growthScheduleWeeksDelta": <int weken voor/achter; 0 als unknown>,
    "growthScheduleNote": <NL vergelijking met gemiddelde plant van dit gewas, bijv. 2 weken achter door schaduw>,
    "adjustedHarvestLabel": <NL datum/venster na correctie of null>,
    "pruningAdvice": <NL snoei: dode bladeren, uitdunnen, dieven bij tomaat — of null>,
    "weedsDetected": <bool>,
    "weedsNote": <NL of null>,
    "sunlightLevel": "veel|gemiddeld|weinig",
    "sunlightAdvice": <NL standplaats of null>,
    "recommendedActions": [
      {"title":"korte actie","description":"optioneel","priority":"low|medium|high|urgent"}
    ],
    "coachTasks": [
      {"title":"bijv. Water geven","body":"optioneel","dueInDays":<int>,"kind":"water|fertilize|prune|check|harvest"}
    ]
  }
''';

const String kPlantAiInsightInstructions = '''
STAP 3 — alleen bij matchesSelectedCrop = true: vul ook het geneste object "insight" in.
- Wees conservatief: detected=true alleen bij duidelijke visuele signalen; anders false met lage confidence.
- Vergelijk groei met een GEMIDDELDE ${'{gewas}'} van hetzelfde type in NL (teelttijd, fase op foto).
- growthScheduleNote: vermeld voor/achter in weken en mogelijke oorzaak (zon, temperatuur, water).
- Pas adjustedHarvestLabel aan als de plant achterloopt of voorloopt.
- coachTasks: 0-4 concrete taken (water, bemesten, snoeien, controleren, oogsten) met dueInDays.
- problems: alleen echte issues; geen seizoens- of datumteksten (die horen in seasonTimingWarning).
- summary: max 2 zinnen; dit is het eerste wat de tuinier leest.
- Bij wortel-/knol-/uigewassen op een gewone plantfoto: harvestReady = false; ripenessNote wijst op proefoogst.
- Bij sier-moestuinbloemen (cosmos, facelia, …): harvestReady = false; alleen bloei en insecten.
- Bij eetbare moestuinbloemen (goudsbloem, oost-indische kers, kruiden in bloei, …): harvestReady mag true als plukken eetbaar lijkt; vermeld ook «laten uitbloeien» als alternatief.
''';
