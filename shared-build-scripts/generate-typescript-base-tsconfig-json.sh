#!/bin/bash
set -eo pipefail

# This script generates a base-tsconfig.json for a TypeScript consumer module
# by aggregating path mappings from its TypeScript dependencies.
#
# Arguments:
# $1: root directory of the monorepo
# $2: consumer_module_source_dir (e.g., /path/to/monorepo/typescript/applications/mmmm)
# $3: consumer_target_dir (e.g., /path/to/monorepo/target/applications/mmmm)
# $4: space-separated list of *source-relative paths* of TypeScript dependencies (e.g., "module:typescript/components/explanation")

root="$1"
consumer_module_source_dir="$2"
consumer_target_dir="$3"
deps_source_paths_string="$4" # These are paths like "module:typescript/components/explanation"

#echo "DEBUG: root: $root"
#echo "DEBUG: consumer_module_source_dir: $consumer_module_source_dir"
#echo "DEBUG: consumer_target_dir: $consumer_target_dir"
#echo "DEBUG: deps_source_paths_string: $deps_source_paths_string"

# Initialize paths with the ffi-napi mapping.
# This path is relative from the consumer's source tsconfig.json's baseUrl (which is '.')
# to the vendored location.
INITIAL_PATHS='{
}'

# Start with the base tsconfig structure for the generated base-tsconfig.json.
# This file will be extended by the consumer's actual tsconfig.json.
# It only needs compilerOptions.paths.
TSCONFIG_CONTENT="{
  \"compilerOptions\": {
    \"paths\": {}
  }
}"

#    \"typeRoots\": [\"typings\", \"$root/libs/javascript/npm_vendored/node_modules/@types\"]
#  \"include\": [\"src/**/*.ts\", \"typings/**/*.d.ts\"]

# Merge initial paths (e.g., ffi-napi)
TSCONFIG_CONTENT=$(echo "$TSCONFIG_CONTENT" | jq --argjson initial_paths "$INITIAL_PATHS" '.compilerOptions.paths += $initial_paths')

# Iterate over TypeScript dependency paths to collect their path mappings
for dep_path_full in $deps_source_paths_string; do
  # Handle both old module:typescript/* format and new fully-qualified paths
  if [[ "$dep_path_full" == module:typescript/* ]]; then
    # Old format - extract the actual module path from the "module:typescript/..." format
    module_path_only="${dep_path_full#module:typescript/}"

    # Calculate the relative path from the consumer's source directory to the dependency's target directory
    # Example: from typescript/applications/mmmm to target/components/explanation
    relative_target_path=$(realpath --relative-to="$consumer_module_source_dir" "$root/target/$module_path_only")

    key="$module_path_only/*"
    value="$relative_target_path/*"
    json_value="[\"$value\"]"

    TSCONFIG_CONTENT=$(echo "$TSCONFIG_CONTENT" | jq --arg key "$key" --argjson value "$json_value" '.compilerOptions.paths[$key] = $value')
  elif [[ "$dep_path_full" == */target/*/js ]]; then
    # New format - fully-qualified path to transpiled .js directory
    # Extract module path from the full path: /path/to/root/target/components/explanation/js -> components/explanation
    module_path_only="${dep_path_full#$root/target/}"
    module_path_only="${module_path_only%/js}"

    # Calculate the relative path from the consumer's source directory to the dependency's js directory
    relative_target_path=$(realpath --relative-to="$consumer_module_source_dir" "$dep_path_full")

    key="$module_path_only/*"
    value="$relative_target_path/$module_path_only/*"
    json_value="[\"$value\"]"

    TSCONFIG_CONTENT=$(echo "$TSCONFIG_CONTENT" | jq --arg key "$key" --argjson value "$json_value" '.compilerOptions.paths[$key] = $value')
  else
    # Skip paths that don't match expected formats
    echo "Warning: Unrecognized dependency path format: $dep_path_full. Skipping path inclusion." >&2
  fi
done

# Write the generated tsconfig.json to the consumer's target directory
GENERATED_TSCONFIG_PATH="$consumer_target_dir/base-tsconfig.json"
echo "$TSCONFIG_CONTENT" > "$GENERATED_TSCONFIG_PATH"
