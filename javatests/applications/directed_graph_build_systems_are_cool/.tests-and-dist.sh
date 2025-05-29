#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/javatests/.*|\1|')
module="$(dirname ${script_source#*/javatests/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/tests-init.sh
cd $module_source_dir

targ="$1"
[ -z "$targ" ] && targ="-"

$root/javatests/$module/.tests.sh $targ "$root/.buildStepsDoneLastExecution"
$root/java/$module/.dist.sh "$root/.buildStepsDoneLastExecution"