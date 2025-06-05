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
  "module:java/components/fricatives"
  "module:java/components/nasal"
  "module:kotlin/components/sonorants"
  "module:java/components/voiceless"
  "module:java/components/vowels"
)

# Visit compile-time deps and invoke their .compile.sh scripts
source $root/shared-build-scripts/invoke-all-compile-scripts-for-dependencies.sh "$root" "${deps[@]}"

mkdir -p "$root/target/$module/classes/$module"

# Collect and build CLASSPATH incorporating dependencies own compile classpaths which may include transitive
CLASSPATH=$(
  {
    echo "$root/target/$module/classes"
for dep in "${deps[@]}"; do
      if [[ $dep == module:java/* || $dep == module:kotlin/* ]]; then
        cat "$root/target/${dep#module:*/}/jvmdeps" 2>/dev/null
      fi
    done
  } | sort -u | paste -sd ":" -
)

source $root/shared-build-scripts/compile-java-prod-code-If-needed.sh
