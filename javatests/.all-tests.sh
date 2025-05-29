#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/javatests/.*|\1|')
echo "Running all .tests.sh in $(pwd) subdirs"
echo "" > "$root/.buildStepsDoneLastExecution"
find . -mindepth 2 -name '.tests.sh' -print0 \
  | while IFS= read -r -d '' script; do
      bash "$script" "$root/.buildStepsDoneLastExecution"
    done
