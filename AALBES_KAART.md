# Aalbes-kaart (Zoeken-tab)

## Formaat (gelijk aan aardappel)

| | Waarde |
|---|--------|
| Fotovlak (Zoeken) | **0,78** (breedte ÷ hoogte) |
| Grid-kaart | **0,62** (hele kaart incl. titel) |
| Export | **512 × 656 px** |
| Bestand in app | `assets/images/vegetables/aalbes.png` |

Een oude export met ratio **0,55** (512×930) past niet op de kaart — zwarte/zijbalken of verkeerde verhouding. Gebruik altijd **0,78**.

## Importeren

Dubbelklik: **`GEN_AALBES.cmd`**

Of:

```powershell
cd C:\Users\frede\tuinier_app
dart run tool/install_plant_card_icon.dart aalbes
```

Bron (één van):

- `C:\Users\frede\.cursor\projects\empty-window\assets\aalbes_kaart_bron.png` (atlas-stijl, veel lucht)
- `assets\images\vegetables\aalbes_kaart_bron.png`

Import schaalt de plant naar **82%** van het kader (zelfde idee als aardappel: hele struik zichtbaar, ruimte voor zoom in de app).

## App herstarten

```powershell
flutter clean
flutter pub get
flutter run
```

## Fijnafstelling in de app

Op de detailpagina: **Foto in kaart aanpassen** (zoom/positie).
