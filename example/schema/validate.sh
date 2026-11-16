#!/usr/bin/env bash
# validate.sh — validate a Tableau workbook (.twb) against the bundled TWB XSD.
#
# Self-contained: uses twb_*.xsd + user.xsd + xml.xsd shipped in this folder. The official
# XSD imports the "user" and "xml" namespaces without a schemaLocation, so we patch a temp
# copy to point them at the local stubs, then run xmllint (libxml2).
#
# Usage:  schema/validate.sh <workbook.twb>        (exit 0 = valid)
set -euo pipefail
TWB="${1:?usage: validate.sh <workbook.twb>}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v xmllint >/dev/null || { echo "ERROR: xmllint not found — install libxml2 (brew install libxml2 / apt install libxml2-utils)"; exit 2; }
XSD="$(ls "$DIR"/twb_*.xsd 2>/dev/null | sort | tail -1)"
[ -n "$XSD" ] || { echo "ERROR: no twb_*.xsd in $DIR"; exit 2; }

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
cp "$DIR/user.xsd" "$DIR/xml.xsd" "$WORK/"
sed -e 's|<xs:import namespace="http://www.tableausoftware.com/xml/user"/>|<xs:import namespace="http://www.tableausoftware.com/xml/user" schemaLocation="user.xsd"/>|' \
    -e 's|<xs:import namespace="http://www.w3.org/XML/1998/namespace"/>|<xs:import namespace="http://www.w3.org/XML/1998/namespace" schemaLocation="xml.xsd"/>|' \
    "$XSD" > "$WORK/twb_resolved.xsd"

echo "Validating $(basename "$TWB") against $(basename "$XSD") ..."
xmllint --noout --schema "$WORK/twb_resolved.xsd" "$TWB" && echo "✓ $(basename "$TWB") is valid"
