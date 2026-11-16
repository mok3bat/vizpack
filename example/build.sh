#!/usr/bin/env bash
# Vizpack build:  data/sample.csv -> app/src/snapshot-data.js  +  Desktop .twbx
set -euo pipefail
cd "$(dirname "$0")"; HERE="$(pwd)"
CSV="data/sample.csv"
SNAP="app/src/snapshot-data.js"

[ -f "$CSV" ] || python3 data/gen_sample.py      # bootstrap the sample if missing

echo "== 1/2  $CSV -> $SNAP =="
python3 - "$CSV" "$SNAP" <<'PY'
import csv, sys, json
csv_path, out = sys.argv[1], sys.argv[2]
regions, categories, ri, ki = [], [], {}, {}
def idx(lst, d, v):
    if v not in d: d[v] = len(lst); lst.append(v)
    return d[v]
reg=[]; cat=[]; units=[]; rev=[]
with open(csv_path, newline="") as f:
    for r in csv.DictReader(f):
        reg.append(idx(regions, ri, r["region"]))
        cat.append(idx(categories, ki, r["category"]))
        units.append(int(float(r["units"])))
        rev.append(round(float(r["revenue"]), 2))
arr = lambda a: "[" + ",".join(repr(x) for x in a) + "]"
with open(out, "w") as f:
    f.write("window.VP_DATA={\n")
    f.write("regions:" + json.dumps(regions) + ",\n")
    f.write("categories:" + json.dumps(categories) + ",\n")
    for n, a in [("region", reg), ("cat", cat), ("units", units), ("revenue", rev)]:
        f.write(n + ":" + arr(a) + ",\n")
    f.write("};\n")
print(f"   {len(rev)} rows · revenue ${sum(rev):,.0f} -> {out}")
PY

echo "== 2/2  Desktop .twbx =="
# The host workbook ships pre-built in host/ (XSD-valid), so the kit needs NO external tooling.
# It's plain XML — edit host/*.twb directly, or regenerate from vizpack-example.twb.yml if you
# happen to use the twb-as-code compiler, then refresh host/.
mkdir -p build "build/Data"; cp "$CSV" "build/Data/sample.csv"
cp "host/Vizpack Example.twb" "build/Vizpack Example.twb"
# verify the host workbook against the bundled Tableau XSD before packaging
if command -v xmllint >/dev/null 2>&1; then
  ./schema/validate.sh "build/Vizpack Example.twb" >/dev/null \
    && echo "   host workbook: XSD-valid ✓" \
    || { echo "   !! host workbook FAILED XSD validation — fix host/*.twb (run ./schema/validate.sh for details)"; exit 1; }
else
  echo "   (xmllint not found — skipped XSD validation; install libxml2 to enable)"
fi
( cd build && rm -f "Vizpack Example.twbx" && zip -q -r "Vizpack Example.twbx" "Vizpack Example.twb" Data ) \
  && echo "   wrote: build/Vizpack Example.twbx"
echo "done."
