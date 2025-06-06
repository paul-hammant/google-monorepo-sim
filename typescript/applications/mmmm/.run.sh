#!/bin/bash
set -eo pipefail

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/typescript/.*|\1|')
module="$(dirname ${script_source#*/typescript/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"

JS_DEPS=$(cat "$root/target/$module/tsdeps" 2>/dev/null || true | tr '\n' ':')

cd "$root/target/$module"

# Add the monorepo root's target directory and vendored ffi-napi path to NODE_PATH
NODE_PATH="$root/target:$JS_DEPS:$root/libs/javascript/node_modules/ffi-napi" \
  node MmmmU0021.js
