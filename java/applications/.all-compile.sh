#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/java/.*|\1|')
echo "New build:"
echo "" > "$root/.buildStepsDoneLastExecution"
echo "Running all .compile.sh in $(pwd) subdirs"
find . -mindepth 2 -name '.compile.sh' -print0 \
  | while IFS= read -r -d '' script; do
      bash "$script" "$root/.buildStepsDoneLastExecution"
    done