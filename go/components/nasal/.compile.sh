#!/bin/bash
set -eo pipefail

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/go/.*|\1|')
module="$(dirname ${script_source#*/go/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

# --- Go Compilation Section ---
echo "$relative_script_path: Compiling Go prod and test code"
# GO_OUTPUT_LIB_DIR is where the .so file will be placed
GO_OUTPUT_LIB_DIR="$root/target/$module/lib"
mkdir -p "$GO_OUTPUT_LIB_DIR"
SHARED_LIB_FILENAME="libgonasal.so"
GO_OUTPUT_PATH="$GO_OUTPUT_LIB_DIR/$SHARED_LIB_FILENAME"

# Ensure module is tidy
go mod tidy

go build -buildmode=c-shared -o "$GO_OUTPUT_PATH" $(find . -maxdepth 1 -name "*.go" -not -name "*_test.go")
