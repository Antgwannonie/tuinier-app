"""Embed scan_hero_bg.png in app (Dart bytes + assets copy)."""
from __future__ import annotations

import base64
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES = [
    Path(r"C:\Users\frede\.cursor\projects\empty-window\assets\scan_hero_bg.png"),
    ROOT / "assets" / "images" / "scan_hub" / "scan_hero_bg.png",
]
DART_OUT = ROOT / "lib" / "data" / "scan_hero_bg_asset.dart"
PNG_OUT = ROOT / "assets" / "images" / "scan_hub" / "scan_hero_bg.png"


def main() -> int:
    src = next((p for p in SOURCES if p.is_file()), None)
    if src is None:
        print("scan_hero_bg.png niet gevonden.", file=sys.stderr)
        return 1

    raw = src.read_bytes()
    b64 = base64.b64encode(raw).decode("ascii")

    PNG_OUT.parent.mkdir(parents=True, exist_ok=True)
    PNG_OUT.write_bytes(raw)

    DART_OUT.write_text(
        "\n".join(
            [
                "// GENERATED — python tool/embed_scan_hero_bg.py",
                "import 'dart:convert';",
                "import 'dart:typed_data';",
                "",
                "const String kScanHeroBgBase64 =",
                f"'{b64}';",
                "",
                "Uint8List get scanHeroBgBytes =>",
                "    kScanHeroBgBase64.isEmpty ? Uint8List(0) : base64Decode(kScanHeroBgBase64);",
                "",
            ]
        ),
        encoding="utf-8",
    )

    print(f"PNG  -> {PNG_OUT} ({len(raw)} bytes)")
    print(f"Dart -> {DART_OUT} ({DART_OUT.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
