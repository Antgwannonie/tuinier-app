// Na `python tool/embed_scan_hero_bg.py` bevat dit de komkommer-foto.
import 'dart:convert';
import 'dart:typed_data';

const String kScanHeroBgBase64 = '';

Uint8List get scanHeroBgBytes =>
    kScanHeroBgBase64.isEmpty ? Uint8List(0) : base64Decode(kScanHeroBgBase64);
