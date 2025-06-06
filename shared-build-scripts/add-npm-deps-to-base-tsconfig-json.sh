#!/bin/bash
set -eo pipefail

root="$1"
# module="$2" # Not strictly needed for this version of the script if destination is absolute
# destination="$3" # This is relative to target, e.g. "tests/components/explanation"
target_dir_suffix="$3" # e.g. tests/components/explanation or components/explanation
shift 3
npm_deps=("$@") # e.g. "libs:javascript/assert"

base_tsconfig_path="$root/target/$target_dir_suffix/base-tsconfig.json"

if [ ! -f "$base_tsconfig_path" ]; then
  echo "Error: base-tsconfig.json not found at $base_tsconfig_path" >&2
  exit 1
fi

# Load existing paths, or initialize as empty object if null
paths_json=$(jq -r '.compilerOptions.paths // {}' "$base_tsconfig_path")

for npm_dep_full_name in "${npm_deps[@]}"; do
  dep_short_name="${npm_dep_full_name#libs:javascript/}" # "assert"

  new_path_entry_json_array="" # Store the JSON array string e.g. "["path"]"
  if [ "$dep_short_name" == "assert" ]; then
    # Path to the directory containing @types/node, letting TSC resolve specific .d.ts
    # The path value itself must be a string within the JSON array.
    type_path="$root/libs/javascript/npm_vendored/node_modules/@types/node"
    new_path_entry_json_array="[\"$type_path\"]" # Corrected: Ensure $type_path is quoted in the JSON string
  else
    # For non-'assert' dependencies, we will currently not add them to paths,
    # as the original logic pointed to JS files, which is incorrect for type resolution.
    # This part can be expanded if other npm deps need specific type path mappings.
    echo "Info: Skipping path generation for non-assert dependency '$dep_short_name'. Current logic focuses on 'assert' type resolution." >&2
    continue # Move to the next dependency
  fi

  if [ -n "$new_path_entry_json_array" ]; then
    paths_json=$(echo "$paths_json" | jq --arg key "$dep_short_name" --argjson value "$new_path_entry_json_array" '. + {($key): $value}')
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

echo "Updated $base_tsconfig_path with new paths configuration."
