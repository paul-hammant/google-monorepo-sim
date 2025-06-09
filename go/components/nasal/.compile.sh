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
raw_source_timestamp=$(find . -mindepth 1 -name "*" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1 || echo 0)
source_timestamp=${raw_source_timestamp:-0}
previous_timestamp=$(cat "$timestamp_file" 2>/dev/null || echo 0)

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    echo "$relative_script_path: compiling Go prod & test code"
    # Ensure module is tidy
  go mod tidy

  GO_SOURCE_FILES=$(find . -maxdepth 1 -name "*.go" -not -name "*_test.go")
  if [[ -n "$GO_SOURCE_FILES" ]]; then
    go build -buildmode=c-shared -o "$GO_OUTPUT_PATH" $GO_SOURCE_FILES
  else
    echo "$relative_script_path: No Go source files found, skipping go build."
  fi
  echo "$source_timestamp" > "$timestamp_file"
  echo -n "$GO_OUTPUT_PATH" > $root/target/$module/ldlibdeps
  
  # Generate shared library dependencies file (Go modules can have dependencies on other native modules)
  deps=()  # This Go module has no dependencies currently
  "$root/shared-build-scripts/make-target-shared-library-deps-file.sh" "$root" "$module" "$root/target/$module/shared_library_deps_including_transitive" "${deps[@]}"
  # Add our own shared library to the transitive dependencies
  echo "$GO_OUTPUT_PATH" >> "$root/target/$module/shared_library_deps_including_transitive"
  # Remove duplicates and sort
  sort -u "$root/target/$module/shared_library_deps_including_transitive" -o "$root/target/$module/shared_library_deps_including_transitive"
else
    echo "$relative_script_path: skipping compilation of Go prod & test code (not changed)"
fi
