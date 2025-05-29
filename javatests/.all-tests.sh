#!/bin/bash
set -e
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/javatests/.*|\1|')
echo "Running all .tests.sh in $(pwd) subdirs"
echo "" > "$root/.buildStepsDoneLastExecution"
find . -mindepth 2 -name ".tests.sh" | while IFS= read -r script; do
  "$script" - "$root/.buildStepsDoneLastExecution" || exit 1
done

