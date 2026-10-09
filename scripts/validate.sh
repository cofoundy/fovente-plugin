#!/usr/bin/env bash
# Every SKILL.md / agent has `name` + `description`, and a skill's name matches its directory.
set -euo pipefail
fail=0
for f in plugins/*/skills/*/SKILL.md plugins/*/agents/*.md; do
  head -20 "$f" | grep -q '^name: ' || { echo "missing name: $f"; fail=1; }
  head -20 "$f" | grep -q '^description: ' || { echo "missing description: $f"; fail=1; }
done
for f in plugins/*/skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")"); name=$(sed -n 's/^name: //p' "$f" | head -1)
  [ "$dir" = "$name" ] || { echo "name '$name' != dir '$dir': $f"; fail=1; }
done
exit $fail
