#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/kotlin/.*|\1|') # Updated for Kotlin
module="$(dirname ${script_source#*/kotlin/})" # Updated for Kotlin
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

# Create directory for compiled classes
mkdir -p $root/target/$module/classes
mkdir -p $root/target/$module/classes/$module # For timestamp file

# Define KOTLIN_HOME if not set, common location for Kotlin compiler
: "${KOTLIN_HOME:=/usr/share/kotlin}"

deps=(
)

# Visit compile-time deps and invoke their .compile.sh scripts
source $root/shared-build-scripts/invoke-all-compile-scripts-for-dependencies.sh "$root" "${deps[@]}"

# Create directory for compiled classes
mkdir -p $root/target/$module/classes

CLASSPATH=(
  "$root/target/$module/classes"
  "$KOTLIN_HOME/lib/kotlin-stdlib.jar" # Added Kotlin stdlib
)
# Convert CLASSPATH array to string for kotlinc
classpath_str=$(IFS=: ; echo "${CLASSPATH[*]}")

# Timestamp-based compilation
timestamp_file="$root/target/$module/classes/$module/.timestamp"
raw_source_timestamp=$(find . -mindepth 1 -name "*" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
source_timestamp=${raw_source_timestamp:-0}
previous_timestamp=$(cat "$timestamp_file" 2>/dev/null || echo 0)

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
  echo "$relative_script_path: compiling prod code"
  find . -name "*.kt" -print0 | xargs -0 kotlinc -d "$root/target/$module/classes" -cp "$classpath_str"
  echo "$CLASSPATH" | sed 's/:/\n/g' > $root/target/$module/jvm_classpath_deps_including_transitive
  echo "$source_timestamp" > "$timestamp_file"
  touch $root/target/$module/ldlibdeps
else
  echo "$relative_script_path: skipping compilation of prod code (not changed)"
fi
