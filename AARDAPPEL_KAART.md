# Aardappel-kaart (Zoeken-tab)

## Formaat

| | Waarde |
|---|--------|
| Fotovlak (Zoeken) | **0,78** (breedte ÷ hoogte) |
| Grid-kaart | **0,62** (hele kaart incl. "Nu planten") |
| Export | **512 × 656 px** |
| Bestandsnaam in app | `assets/images/vegetables/aardappel.png` |

## Bronfoto (nieuw gegenereerd)

`C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_kaart_bron.png`

## Naar 512×826 maken

Dubbelklik: **`GEN_AARDAPPEL.cmd`**

Of PowerShell:

```powershell
cd C:\Users\frede\tuinier_app
powershell -File tool\install_aardappel.ps1
```

Resultaat:

`C:\Users\frede\tuinier_app\assets\images\vegetables\aardappel.png`

Kopie voor archief (optioneel): `aardappel_kaart_512x826.png` in dezelfde map.

## In de app gebruiken

1. Zet `aardappel.png` in `assets/images/vegetables/`
2. In `lib/data/vegetable_image_info.dart` bij `aardappel`:

```dart
'aardappel': VegetableImageInfo(
  emoji: '🥔',
  greenBackground: false,
  assetPath: 'assets/images/vegetables/aardappel.png',
  atlasCardCover: true,
  atlasCardPrecropped: true,
),
```

3. `flutter clean` → `flutter pub get` → `flutter run`
