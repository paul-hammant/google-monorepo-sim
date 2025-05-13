#!/bin/bash
set -e
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

# Visit compile-time deps amd invoke heir .compile.sh scripts
for dep in "${deps[@]}"; do "$root/${dep#module:}/.compile.sh" "$root/.buildStepsDoneLastExecution"; done

# Create directory for compiled classes
mkdir -p $root/target/$module/classes

CLASSPATH=$(
  {
    echo "$root/target/$module/classes"
    for dep in "${deps[@]}"; do cat "$root/target/${dep#module:java/}/javadeps" 2>/dev/null; done
  } | sort -u | paste -sd ":" -
)

source $root/shared-build-scripts/compile-java-prod-code-If-needed.sh
