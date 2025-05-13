#!/bin/bash
set -e
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/java/.*|\1|')
module="$(dirname ${script_source#*/java/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

# Create directory for compiled classes
mkdir -p $root/target/$module/classes

CLASSPATH=(
  "$root/target/$module/classes"
)

source $root/shared-build-scripts/compile-java-prod-code-If-needed.sh
