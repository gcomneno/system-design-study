#!/usr/bin/env bash
set -euo pipefail

found="$(
  find . -path './.git' -prune -o -type f \( \
    -iname '*.mp4' -o \
    -iname '*.mkv' -o \
    -iname '*.webm' -o \
    -iname '*.mov' -o \
    -iname '*.avi' -o \
    -iname '*.flv' -o \
    -iname '*.wmv' -o \
    -iname '*.m4v' -o \
    -iname '*.ts' \
  \) -print
)"

if [ -n "$found" ]; then
  echo "ERRORE: trovati file video nel repository:"
  echo "$found"
  exit 1
fi

echo "OK: nessun file video trovato."
