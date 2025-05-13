#!/bin/bash
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/java/.*|\1|')
echo "New build:"
echo "" > "$root/.buildStepsDoneLastExecution"
echo "Running all .compile.sh in $(pwd) subdirs"
find . -mindepth 2 -name ".compile.sh" -exec bash -c 'bash "$0" "$1"' {} "$root/.buildStepsDoneLastExecution" \;
