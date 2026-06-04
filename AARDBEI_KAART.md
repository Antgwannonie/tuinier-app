# Aardbei-kaart (Zoeken-tab)

Zelfde atlas-stijl en formaat als aardappel en aalbes.

| | Waarde |
|---|--------|
| PNG | **`aardbei_v2.png`** — 512 × 656 (ratio **0,78**, gelijk aalbes) |
| Hele Zoeken-kaart | **0,62** |
| Plant | **88%**, hoger (`alignY -0.22`) |

Landschap-bron wordt automatisch bijgesneden tot portret.

Na import: op detail **Reset** bij Foto in kaart aanpassen (oude zoom weg).

## Importeren

Dubbelklik **`GEN_AARDBEI.cmd`** of:

```powershell
cd C:\Users\frede\tuinier_app
dart run tool/install_plant_card_icon.dart aardbei
```

Bron: `C:\Users\frede\.cursor\projects\empty-window\assets\aardbei_kaart_bron.png`

## App

```powershell
flutter clean
flutter pub get
flutter run
```

Finetune op detailpagina: **Foto in kaart aanpassen**.
