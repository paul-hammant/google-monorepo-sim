#!/bin/bash
set -e
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/javatests/.*|\1|')
module="$(dirname ${script_source#*/javatests/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/tests-init.sh
cd $module_source_dir

echo "Running all .tests.sh in $(pwd) subdirs"

find . -mindepth 2 -name ".tests.sh" | while IFS= read -r script; do
  "$script" - "$root/.buildStepsDoneLastExecution" || exit 1
done

