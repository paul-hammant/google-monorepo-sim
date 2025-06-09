#!/bin/bash
set -eo pipefail

root="$1"
module="$2"
destination="$3"
shift 3
npm_deps=("$@")

# Our in-memory collection
npm_deps_incl_transitive=()

# Add the current module's npm dependencies to the list
for npm_dep in "${npm_deps[@]}"; do
  npm_deps_incl_transitive+=("$npm_dep")
done

# Collect transitive npm dependencies from TypeScript module dependencies
typescript_deps_file="$root/target/$module/typescript_module_deps_including_transitive"
if [[ -f "$typescript_deps_file" ]]; then
  while IFS= read -r ts_dep_path; do
    if [[ -n "$ts_dep_path" ]]; then
      # Extract module path from the full js path
      # /path/to/root/target/components/explanation/js -> components/explanation
      ts_module_path="${ts_dep_path#$root/target/}"
      ts_module_path="${ts_module_path%/js}"
      
      # Check for npm deps file in the TypeScript dependency
      ts_npm_deps_file="$root/target/$ts_module_path/npm_deps_including_transitive"
      if [[ -f "$ts_npm_deps_file" ]]; then
        while IFS= read -r transitive_npm_dep; do
          if [[ -n "$transitive_npm_dep" ]]; then
            npm_deps_incl_transitive+=("$transitive_npm_dep")
          fi
        done < "$ts_npm_deps_file"
      fi
    fi
  done < "$typescript_deps_file"
fi

# Output, deduped and sorted
printf "%s\n" "${npm_deps_incl_transitive[@]}" | sed '/^$/d' | sort -u > "$destination"