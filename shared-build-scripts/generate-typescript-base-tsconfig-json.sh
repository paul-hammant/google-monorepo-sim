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
npm_deps_string="$5"         # These are like "assert@1.5.1 anotherpackage@1.2.3"

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
for npm_dep in $npm_deps_string; do
  # Parse package_name@package_version
  if [[ ! "$npm_dep" =~ ^([^@]+)@([^@]+)$ ]]; then
    echo "Warning: Could not parse npm dependency string '$npm_dep' in generate-typescript-base-tsconfig-json.sh. Skipping." >&2
    continue
  fi
  npm_package_name="${BASH_REMATCH[1]}"
  npm_package_version="${BASH_REMATCH[2]}"

  # Construct path to the vendored package
  vendored_npm_pkg_path="$root/libs/javascript/npm_vendored/$npm_package_name/$npm_package_version/package"

  # Calculate the relative path from the consumer's source directory to the vendored package path
  # realpath --relative-to=from_path to_path
  relative_npm_pkg_path=$(realpath --relative-to="$consumer_module_source_dir" "$vendored_npm_pkg_path")

  # Add path mapping for the package name (e.g., "assert")
  key_exact="$npm_package_name"
  value_exact="[\"$relative_npm_pkg_path\"]"
  TSCONFIG_CONTENT=$(echo "$TSCONFIG_CONTENT" | jq --arg key "$key_exact" --argjson value "$value_exact" '.compilerOptions.paths[$key] = $value')

  # Add path mapping for subpaths (e.g., "assert/*")
  key_wildcard="$npm_package_name/*"
  value_wildcard="[\"$relative_npm_pkg_path/*\"]"
  TSCONFIG_CONTENT=$(echo "$TSCONFIG_CONTENT" | jq --arg key "$key_wildcard" --argjson value "$value_wildcard" '.compilerOptions.paths[$key] = $value')
done

# Iterate over TypeScript dependency *source-relative paths* to collect their path mappings
for dep_source_path_full in $deps_source_paths_string; do
  # Extract the actual module path from the "module:typescript/..." format
  if [[ "$dep_source_path_full" == module:typescript/* ]]; then
    module_path_only="${dep_source_path_full#module:typescript/}"

    # Calculate the relative path from the consumer's source directory to the dependency's target directory
    # Example: from typescript/applications/mmmm to target/components/explanation
    relative_target_path=$(realpath --relative-to="$consumer_module_source_dir" "$root/target/$module_path_only")

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
