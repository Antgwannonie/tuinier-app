# -*- coding: utf-8 -*-
"""Export vegetable_overview_all.json from generate_vegetable_overview.py data."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "generate_vegetable_overview.py"
OUT = ROOT / "vegetable_overview_all.json"

REQUIRED_IDS = """
rode_biet rode_biet_cilindrisch gele_biet witte_biet chioggia_biet
sla ijsbergsla lollo_rossa krulsla lambsla eikenbladsla
spinazie baby_spinazie rucola andijvie postelein snijbiet tuinkers witlof veldsla
wortel paarse_wortel gele_wortel witte_wortel radijs pastinaak winterpeen mini_wortel schorseneer rammenas zwarte_radijs peterseliewortel
tomaat snoeptomaat cherrytomaat pruimtomaat vleestomaat trostomaat cocktailtomaat balkontomaat honingtomaat
rode_paprika gele_paprika oranje_paprika puntpaprika snack_paprika peper cayenne_peper chilipeper jalapeno habanero serrano_peper galapeno_peper thaise_peper poblano_peper padron_peper tabasco_peper peperoncini banana_peper
snackkomkommer komkommer cucamelon courgette courgette_geel patisson augurk pompoen reuzen_pompoen pompoen_hokkaido pompoen_butternut okra pepino galia_meloen honingmeloen
bosui ui prei winterprei zomerprei knoflook sjalot rode_ui winterui knoflook_hardnekkig scheve_ui
boerenkool broccoli bimi koolrabi wittekool rodekool bloemkool spruitkool paksoi koolraap savooiekool spitskool palmekool romanesco chinese_kool raapstelen raapkool rode_savooi bloemkool_paars spruitkool_rood paksoi_jong broccoli_rabe
aardappel vroege_aardappel vastkokende_aardappel kruimige_aardappel zoete_aardappel aardpeer
aubergine
mais maiskolf
rabarber asperge groene_asperge witte_asperge zuring
""".split()


def main() -> None:
    src = SRC.read_text(encoding="utf-8")
    start = src.index("# --- Bieten ---")
    end = src.index("# Write dart file")
    code = src[start:end]
    code = re.sub(r"entries\.append\(", "collect(", code)

    plants: dict[str, dict] = {}

    def collect(id_: str, **kwargs: object) -> None:
        plant = kwargs.pop("plant", []) or []
        row = dict(kwargs)
        row["plant"] = plant
        plants[id_] = {
            "sow": row.get("sow", []),
            "plant": row.get("plant", []),
            "harvest": row["harvest"],
            "standplaats": row["standplaats"],
            "water": row["water"],
            "difficulty": row["difficulty"],
            "lifespan": row["lifespan"],
            "outdoor": row["outdoor"],
            "container": row["container"],
            "voeding": row["voeding"],
            "height": row["height"],
            "width": row["width"],
            "habit": row["habit"],
            "spacing": row["spacing"],
            "row": row["row"],
            "first": row["first"],
            "period": row["period"],
            "yield_level": row["yield_level"],
            "yield_detail": row["yield_detail"],
            "points": row["points"],
            "summary": row["summary"],
            "know": row["know"],
        }

    exec(compile(code, str(SRC), "exec"), {"collect": collect, "entry": collect})

    ordered = {pid: plants[pid] for pid in REQUIRED_IDS if pid in plants}
    missing = [pid for pid in REQUIRED_IDS if pid not in plants]
    extra = [pid for pid in plants if pid not in REQUIRED_IDS]

    OUT.write_text(
        json.dumps(ordered, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(ordered)} plants -> {OUT}")
    if missing:
        print("Missing:", ", ".join(missing))
    if extra:
        print("Extra:", ", ".join(extra))


if __name__ == "__main__":
    main()
