#!/bin/bash
set -e

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/csharp/.*|\1|')
module="$(dirname ${script_source#*/csharp/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

# Compile the application
$root/csharp/$module/.compile.sh "$root/.buildStepsDoneLastExecution"

# Create a distribution package
echo "Creating distribution package for $module"
cp -r $root/target/$module/bin $root/target/$module/dist

# TODO combine DLLS into exe ???