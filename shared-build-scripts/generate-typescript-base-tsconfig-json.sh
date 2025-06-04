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
# $5: Optional: space-separated list of NPM dependencies (e.g., "assert@1.5.1 otherpkg@1.0.0")

root="$1"
consumer_module_source_dir="$2"
consumer_target_dir="$3"
deps_source_paths_string="$4" # These are paths like "module:typescript/components/explanation"
# Arg5 is now expected to be a space-separated string of "packageName:actualResolvedPath"
# e.g., "assert:/app/libs/js/npm_vendored/assert/package @types/node:/app/libs/js/npm_vendored/@types/node/node"
npm_dep_mappings_string="$5"

#echo "DEBUG: root: $root"
#echo "DEBUG: consumer_module_source_dir: $consumer_module_source_dir"
#echo "DEBUG: consumer_target_dir: $consumer_target_dir"
#echo "DEBUG: deps_source_paths_string: $deps_source_paths_string"
#echo "DEBUG: npm_deps_string: $npm_deps_string"

# Start with the base tsconfig structure for the generated base-tsconfig.json.
# This file will be extended by the consumer's actual tsconfig.json.
# It only needs compilerOptions.paths.
TSCONFIG_CONTENT='{
  "compilerOptions": {
    "paths": {}
  }
}'

# Process NPM dependencies and add them to paths
echo "Debug [generate-tsconfig]: Processing NPM dep mappings: $npm_dep_mappings_string" >&2
for mapping in $npm_dep_mappings_string; do
  echo "Debug [generate-tsconfig]: LOOP START. Current mapping raw: '"$mapping"'" >&2
  # Safely parse "package_name:actual_path"
  # Handle potential colons in paths by splitting only on the first colon
  package_name="${mapping%%:*}"
  actual_vendored_content_path="${mapping#*:}"

  if [ -z "$package_name" ] || [ -z "$actual_vendored_content_path" ] || [ "$package_name" == "$actual_vendored_content_path" ]; then
    echo "Warning [generate-tsconfig]: Could not parse npm dependency mapping '$mapping'. Expected format: package_name:actual_path. Skipping." >&2
    continue
  fi

  echo "Debug [generate-tsconfig]: Parsed mapping. Package Name: '$package_name', Actual Path: '$actual_vendored_content_path'" >&2

  if [ ! -e "$actual_vendored_content_path" ]; then # Use -e to check if path exists (file or directory)
    echo "Error [generate-tsconfig]: Vendored path '$actual_vendored_content_path' for package '$package_name' does not exist. Skipping." >&2
    continue
  fi

  # Calculate the relative path from the consumer's source directory to the actual vendored content path
  echo "Debug [generate-tsconfig]: About to call realpath. consumer_module_source_dir='$consumer_module_source_dir', actual_vendored_content_path='$actual_vendored_content_path'" >&2
  echo "Debug [generate-tsconfig]: Attempting realpath --relative-to='$consumer_module_source_dir' '$actual_vendored_content_path'" >&2
  temp_realpath_out=$(realpath --relative-to="$consumer_module_source_dir" "$actual_vendored_content_path" 2>&1)
  rp_exit_code=$?
  if [ $rp_exit_code -ne 0 ]; then
    echo "Critical Error [generate-tsconfig]: realpath FAILED for path '$actual_vendored_content_path' (relative to '$consumer_module_source_dir'). Exit Code: $rp_exit_code." >&2
    echo "realpath output: $temp_realpath_out" >&2
    exit 1 # Explicit exit after logging
  fi
  relative_npm_pkg_path="$temp_realpath_out"
  echo "Debug [generate-tsconfig]: realpath successful: '$relative_npm_pkg_path'" >&2

  # Add path mapping for the package name (e.g., "assert" or "@types/node")
  key_exact="$package_name" # This is the import path used in TypeScript
  value_exact="[\"$relative_npm_pkg_path\"]" # Path to the root of the package
  TSCONFIG_CONTENT=$(echo "$TSCONFIG_CONTENT" | jq --arg key "$key_exact" --argjson value "$value_exact" '.compilerOptions.paths[$key] = $value')

  # Add path mapping for subpaths (e.g., "assert/*" or "@types/node/*")
  key_wildcard="$package_name/*"
  value_wildcard="[\"$relative_npm_pkg_path/*\"]" # Path to submodules/subfiles
  TSCONFIG_CONTENT=$(echo "$TSCONFIG_CONTENT" | jq --arg key "$key_wildcard" --argjson value "$value_wildcard" '.compilerOptions.paths[$key] = $value')
  echo "Debug [generate-tsconfig]: Added path mappings for '$package_name' and '$package_name/*' to tsconfig." >&2
done

# Iterate over TypeScript dependency *source-relative paths* to collect their path mappings
for dep_source_path_full in $deps_source_paths_string; do
  # Extract the actual module path from the "module:typescript/..." format
  if [[ "$dep_source_path_full" == module:typescript/* ]]; then
    module_path_only="${dep_source_path_full#module:typescript/}"

    # Calculate the relative path from the consumer's source directory to the dependency's target directory
    # Example: from typescript/applications/mmmm to target/components/explanation
    # Adding detailed realpath debugging for module dependencies as well
    echo "Debug [generate-tsconfig]: About to call realpath for module dep. consumer_module_source_dir='$consumer_module_source_dir', target_dep_path='$root/target/$module_path_only'" >&2
    temp_module_realpath_out=$(realpath --relative-to="$consumer_module_source_dir" "$root/target/$module_path_only" 2>&1)
    mrp_exit_code=$?
    if [ $mrp_exit_code -ne 0 ]; then
        echo "Critical Error [generate-tsconfig]: realpath FAILED for module path '$root/target/$module_path_only' (relative to '$consumer_module_source_dir'). Exit Code: $mrp_exit_code." >&2
        echo "realpath output: $temp_module_realpath_out" >&2
        exit 1 # Explicit exit after logging
    fi
    relative_target_path="$temp_module_realpath_out"
    echo "Debug [generate-tsconfig]: realpath for module dep successful: '$relative_target_path'" >&2

    key="$module_path_only/*"
    value="$relative_target_path/*"
    json_value="[\"$value\"]"

    TSCONFIG_CONTENT=$(echo "$TSCONFIG_CONTENT" | jq --arg key "$key" --argjson value "$json_value" '.compilerOptions.paths[$key] = $value')
  else
    # This block handles cases where the tsdeps file might contain non-module:typescript paths
    # For now, we'll just warn and skip, as the request is focused on module paths.
    echo "Warning: Unexpected dependency format in tsdeps: $dep_source_path_full. Skipping path inclusion." >&2
  fi
done

# Write the generated tsconfig.json to the consumer's target directory
GENERATED_TSCONFIG_PATH="$consumer_target_dir/base-tsconfig.json"
echo "$TSCONFIG_CONTENT" > "$GENERATED_TSCONFIG_PATH"
