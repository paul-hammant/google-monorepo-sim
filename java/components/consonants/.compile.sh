#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/java/.*|\1|')
module="$(dirname ${script_source#*/java/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

deps=(
)

# Visit compile-time deps and invoke their .compile.sh scripts
source $root/shared-build-scripts/invoke-all-compile-scripts-for-dependencies.sh "$root" "${deps[@]}"

# Create directory for compiled classes
mkdir -p $root/target/$module/classes
# Calculate the highest timestamp for source files

CLASSPATH=(
  "$root/target/$module/classes"
)

source $root/shared-build-scripts/compile-java-prod-code-If-needed.sh
