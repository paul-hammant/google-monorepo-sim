#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/go/.*|\1|')
module="$(dirname ${script_source#*/go/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/tests-init.sh
cd $module_source_dir


# Timestamp-based test execution
timestamp_file="$root/target/$module/.test-timestamp"
raw_source_timestamp=$(find . -mindepth 1 -name "*" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
source_timestamp=${raw_source_timestamp:-0}
previous_timestamp=$(cat "$timestamp_file" 2>/dev/null || echo 0)

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    "$root/go/$module/.compile.sh" $root/.buildStepsDoneLastExecution

    # Run Go tests
    echo "$relative_script_path: running Go tests..."

    LD_LIBRARY_PATH="$root/target/components/nasal/lib:$LD_LIBRARY_PATH" go test -v .

    echo "$relative_script_path: Go tests completed successfully."
    echo "$source_timestamp" > "$timestamp_file"
else
    echo "$relative_script_path: skipping execution of Go tests (not changed)"
fi
