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
  "module:java/components/vowelbase"
)

# Visit compile-time deps and invoke their .compile.sh scripts
source $root/shared-build-scripts/invoke-all-compile-scripts-for-dependencies.sh "$root" "${deps[@]}"

# Create directory for compiled classes
mkdir -p $root/target/$module/classes

CLASSPATH=$(
  {
    echo "$root/target/$module/classes"
    for dep in "${deps[@]}"; do cat "$root/target/${dep#module:java/}/jvm_classpath_deps_including_transitive" 2>/dev/null; done
  } | sort -u | paste -sd ":" -
)

source $root/shared-build-scripts/compile-java-prod-code-If-needed.sh
