#!/bin/bash
set -eo pipefail

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/typescript/.*|\1|')
module="$(dirname ${script_source#*/typescript/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

# Create directory for compiled classes (JS output)
mkdir -p "$root/target/$module"

# Timestamp-based compilation
timestamp_file="$root/target/$module/.timestamp"
raw_source_timestamp=$(find . -mindepth 1 -name "*.ts" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
source_timestamp=${raw_source_timestamp:-0}
previous_timestamp=$(cat "$timestamp_file" 2>/dev/null || echo 0)

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
  echo "$relative_script_path: compiling prod code"

  # Define TypeScript dependencies (empty for this component as it has no TS deps)
  deps=()
  "$root/shared-build-scripts/make-target-tsdeps-file.sh" "$root" "$module" "$root/target/$module/tsdeps" "${deps[@]}"

  # Generate base-tsconfig.json for the production module.
  # The self-path mapping is now handled by make-target-tsdeps-file.sh and generate-typescript-base-tsconfig-json.sh
  "$root/shared-build-scripts/generate-typescript-base-tsconfig-json.sh" \
    "$root" "$module_source_dir" "$root/target/$module" "$(cat "$root/target/$module/tsdeps")"

  tsc

  if [ $? -ne 0 ]; then
    echo "TypeScript compilation failed for module: $module"
    exit 1
  fi
  echo "$source_timestamp" > "$timestamp_file"

else
  echo "$relative_script_path: skipping compilation of prod code (not changed)"
fi
