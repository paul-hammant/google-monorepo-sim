#!/bin/bash
set -eo pipefail

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/go/.*|\1|')
module="$(dirname ${script_source#*/go/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

GO_OUTPUT_LIB_DIR="$root/target/$module/lib"
mkdir -p "$GO_OUTPUT_LIB_DIR"
SHARED_LIB_FILENAME="libgonasal.so"
GO_OUTPUT_PATH="$GO_OUTPUT_LIB_DIR/$SHARED_LIB_FILENAME"

# Timestamp-based compilation
timestamp_file="$GO_OUTPUT_LIB_DIR/.timestamp"
raw_source_timestamp=$(find . -mindepth 1 -name "*.go" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
source_timestamp=${raw_source_timestamp:-0}
previous_timestamp=$(cat "$timestamp_file" 2>/dev/null || echo 0)

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    echo "$relative_script_path: compiling Go prod & test code"
    # Ensure module is tidy
  go mod tidy

  go build -buildmode=c-shared -o "$GO_OUTPUT_PATH" $(find . -maxdepth 1 -name "*.go" -not -name "*_test.go")
  echo "$source_timestamp" > "$timestamp_file"
else
    echo "$relative_script_path: skipping compilation of Go prod & test code (not changed)"
fi
