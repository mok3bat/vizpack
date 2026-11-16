#!/bin/zsh
# Serve the Vizpack example app on localhost (for a browser preview or Tableau Desktop).
# Keep it running while the Desktop workbook is open.
cd "$(dirname "$0")/app"
PORT=${1:-8750}
echo "Vizpack example at http://localhost:$PORT — Ctrl-C to stop."
exec python3 -m http.server "$PORT" --bind 127.0.0.1
