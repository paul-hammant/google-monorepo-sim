#!/bin/bash
set -eo pipefail

root="$1"
# module="$2" # Not strictly needed for this version of the script if destination is absolute
# destination="$3" # This is relative to target, e.g. "tests/components/explanation"
target_dir_suffix="$3" # e.g. tests/components/explanation or components/explanation
shift 3
npm_deps=("$@") # e.g. "libs:javascript/assert"

base_tsconfig_path="$root/target/$target_dir_suffix/base-tsconfig.json"
package_map_path="$root/libs/javascript/npm_vendored/package-map"

if [ ! -f "$base_tsconfig_path" ]; then
  echo "Error: base-tsconfig.json not found at $base_tsconfig_path" >&2
  exit 1
fi

if [ ! -f "$package_map_path" ]; then
  echo "Error: package-map not found at $package_map_path" >&2
  exit 1
fi

# Load existing paths, or initialize as empty object if null
paths_json=$(jq -r '.compilerOptions.paths // {}' "$base_tsconfig_path")

for npm_dep_full_name in "${npm_deps[@]}"; do
  dep_short_name="${npm_dep_full_name#libs:javascript/}" # "assert"

  # Find the path from package-map
  line=$(grep "^${dep_short_name}:" "$package_map_path" || true)

  if [ -n "$line" ]; then
    dep_path_suffix=$(echo "$line" | cut -d: -f2)
    # Construct the full path to the type definition file
    type_path="$root/libs/javascript/npm_vendored/$dep_path_suffix"
    
    # For tsconfig paths, we usually want to point to the file, not a directory.
    # The key will be the module name, and the value an array with the path to its declaration.
    new_path_entry_json_array="[\"$type_path\"]"

    paths_json=$(echo "$paths_json" | jq --arg key "$dep_short_name" --argjson value "$new_path_entry_json_array" '. + {($key): $value}')
  else
    echo "Info: No mapping found for npm dependency '$dep_short_name' in $package_map_path. Skipping path generation." >&2
    continue
  fi
done

# Update the base-tsconfig.json with the modified paths object
# Ensure sponge is available or use a temporary file
if command -v sponge > /dev/null; then
  jq --argjson new_paths "$paths_json" '.compilerOptions.paths = $new_paths' "$base_tsconfig_path" | sponge "$base_tsconfig_path"
else
  tmp_file=$(mktemp)
  jq --argjson new_paths "$paths_json" '.compilerOptions.paths = $new_paths' "$base_tsconfig_path" > "$tmp_file" && mv "$tmp_file" "$base_tsconfig_path"
fi
