#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/rust/.*|\1|')
module="$(dirname ${script_source#*/rust/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

mkdir -p $root/target/components/vowelbase/lib
# Calculate the highest timestamp for source files
source_timestamp=$(find . -name "*" -printf '%T@\n' | sort -n | tail -1 || echo 0)
previous_timestamp=$(cat $root/target/$module/lib/.timestamp 2>/dev/null || echo 0)
# Compare timestamps and compile if necessary
if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    echo "$relative_script_path: compiling prod code"
     # todo - should use rustc and also source libs from root/libs/rust (not cargo)
    cargo build --release --target-dir="$root/target/$module/lib"
    echo $source_timestamp > $root/target/$module/lib/.timestamp
    echo -n "$root/target/$module/lib/release/libvowelbase.so" > $root/target/$module/ldlibdeps
else
    echo "$relative_script_path: skipping compilation of prod code (not changed)"
fi
