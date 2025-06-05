#!/bin/bash
set -eo pipefail

root="$1"
module="$2"
destination="$3"
shift 3
npm_deps=("$@")

# Extract actual paths for npm dependencies from package-map
npm_deps_paths=()
while IFS= read -r line; do
  IFS=':' read -r key path <<< "$line"
  for npm_dep in "${npm_deps[@]}"; do
    if [[ "$npm_dep" == "libs:javascript/$key" ]]; then
      npm_deps_paths+=("$key:$root/libs/javascript/npm_vendored/$path")
    fi
  done
done < "$root/libs/javascript/npm_vendored/package-map"

# Couple npm dependencies with their paths
declare -A npm_paths_map
for npm_dep_path in "${npm_deps_paths[@]}"; do
  IFS=':' read -r key value <<< "$npm_dep_path"
  jq --arg key "$key" --arg value "$value" \
    '.compilerOptions.paths[$key] += [$value]' \
    "$root/target/$destination/base-tsconfig.json" | sponge "$root/target/$destination/base-tsconfig.json"
done

