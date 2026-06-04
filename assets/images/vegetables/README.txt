Plaats hier plant-iconen (PNG) of run vanuit de projectmap:

  dart run tool/import_aardappel_icon.dart
  dart run tool/import_tomaat_icon.dart

Witte achtergrond uit bestaande tomaat.png halen:

  dart pub get
  dart run tool/import_tomaat_icon.dart --reprocess

Met eigen bestand:

  dart run tool/import_tomaat_icon.dart "C:\pad\naar\jouw-tomaat.png"

Iconen: aardappel.png, tomaat.png (transparant, alleen tekening + schaduw in app).
Gebruikt op Zoeken-tab en plant-detailpagina (useAtlasIllustration).

Nieuwe tomaat van AI:
  dart run tool/import_tomaat_icon.dart
