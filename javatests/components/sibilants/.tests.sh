#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/javatests/.*|\1|')
module="$(dirname ${script_source#*/javatests/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/tests-init.sh
cd $module_source_dir

deps=(
  "module:java/components/sibilants"
)

# Visit compile-time deps and invoke their .compile.sh scripts
source $root/shared-build-scripts/invoke-all-compile-scripts-for-dependencies.sh "$root" "${deps[@]}"

# Create directory for compiled classes
mkdir -p $root/target/$module/classes

CLASSPATH=$(
  {
    echo "$root/target/$module/classes"
    echo "$root/target/$module/test-classes"
    for dep in "${deps[@]}"; do cat "$root/target/${dep#module:java/}/jvmdeps" 2>/dev/null || true; done
  } | sort -u | paste -sd ":" -
)

# Define additional binary dependencies (external libraries like junit, hamcrest)
bindeps=(
  "lib:java/junit/junit.jar"
  "lib:java/hamcrest/hamcrest.jar"
)

# Build LIBS_CLASSPATH:
# - Add paths to required jars from lib/
LIBS_CLASSPATH=$(
  {
    for bindep in "${bindeps[@]}"; do
      echo "$root/libs/${bindep#lib:}" 2>/dev/null || true
    done
  } | sort -u | paste -sd ":" -
)

source $root/shared-build-scripts/compile-java-test-code-If-needed.sh
