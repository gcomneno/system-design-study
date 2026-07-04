#!/usr/bin/env bash
set -euo pipefail

echo "Checking potentially risky public-content files..."

found="$(
  find . -path './.git' -prune -o -type f \( \
    -path './archive/*.txt' -o \
    -iname '*transcript*' -o \
    -iname '*corpus*' -o \
    -iname '*what apis are*' -o \
    -iname '*.srt' -o \
    -iname '*.vtt' \
  \) -print

  find ./sessions -type f -path '*/translations/*' \
    ! -name 'README.md' \
    -print 2>/dev/null || true
)"

if [ -n "$found" ]; then
  echo "WARN: found files that may require copyright/publication review:"
  echo "$found"
  echo
  echo "This is not always wrong for private/local study."
  echo "Before publishing publicly, review or remove these files."
  exit 1
else
  echo "OK: no obvious transcript/corpus/translation files found."
fi
