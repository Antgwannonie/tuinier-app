# Atlas-iconen (optioneel)

Standaard gebruikt de app **emoji-iconen** (`kAtlasIconsForAllPlants = false`).

## Opnieuw genereren (schone start)

1. Reset (verwijder oude PNG's):
   ```powershell
   .\RESET_ICONEN.cmd
   ```

2. Genereer via Gemini:
   ```powershell
   dart pub get
   dart run tool/generate_atlas_plant_icons.dart --missing --delay-ms 2800
   ```

3. Importeer + verwerk:
   ```powershell
   .\LAAD_ICONEN.cmd
   ```

4. Zet in `lib/data/vegetable_image_info.dart`:
   ```dart
   const bool kAtlasIconsForAllPlants = true;
   ```

5. Hot restart / `flutter run`

## Losse tools

- `dart run tool/batch_import_atlas_icons.dart` — import uit incoming/
- `dart run tool/reprocess_atlas_icons.dart` — PNG's opnieuw verwerken
- `dart run tool/export_plant_catalog.dart` — catalogus + ontbrekende ids
