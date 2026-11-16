#!/usr/bin/env bash
# Vizpack site build — package the app INSIDE the workbook (Untether method):
# the extension is bundled under Packages/<id>/ and referenced by tableaulocalext:/// —
# a sandboxed packaged extension, so there is no external URL to add to the site safe list.
# Run ./build.sh first.  Rationale is in the README.
set -euo pipefail
cd "$(dirname "$0")"; HERE="$(pwd)"
ID="com.vizpack.example"
TWB="build/Vizpack Example.twb"
CSV="data/sample.csv"
LOCAL_URL="http://localhost:8750/index.html"
PKG_URL="tableaulocalext:///$ID/content/index.html"

[ -f "$TWB" ] || { echo "!! $TWB missing — run ./build.sh first"; exit 1; }
[ -f "app/src/snapshot-data.js" ] || { echo "!! snapshot-data.js missing — run ./build.sh first"; exit 1; }

STAGE="build-site/stage"
rm -rf build-site; mkdir -p "$STAGE/Packages/$ID/content" "$STAGE/Packages/$ID/extensions" "$STAGE/Data"

sed "s#$LOCAL_URL#$PKG_URL#g" "$TWB" > "$STAGE/Vizpack Example.twb"            # 1. rewrite extension URL → in-package
cp -R app/. "$STAGE/Packages/$ID/content/"                                     # 2. bundle the app (assets ship as globals — no runtime fetch)
sed "s#<url>$LOCAL_URL</url>#<url>index.html</url>#" vizpack-example.trex \
  > "$STAGE/Packages/$ID/extensions/data-app.trex"                            # 3. packaged trex (relative url)
cp "$CSV" "$STAGE/Data/sample.csv"                                             # 4. embed data

OUT="build-site/Vizpack Example (Site).twbx"
( cd "$STAGE" && zip -q -r "$HERE/$OUT" "Vizpack Example.twb" Packages Data )  # 5. self-contained .twbx
echo "wrote: $OUT"
echo "  extension url: $(grep -o "$PKG_URL" "$STAGE/Vizpack Example.twb" | sort -u)"
