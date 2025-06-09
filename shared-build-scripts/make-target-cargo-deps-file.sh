#!/bin/bash
set -eo pipefail

root="$1"
module="$2"
destination="$3"
shift 3
cargo_deps=("$@")

# Our in-memory collection
cargo_deps_incl_transitive=()

# Add the current module's cargo dependencies to the list
for cargo_dep in "${cargo_deps[@]}"; do
  cargo_deps_incl_transitive+=("$cargo_dep")
done

# Collect transitive cargo dependencies from other module dependencies
# Check if module has other dependencies that might have cargo deps
deps_patterns=("typescript_module_deps_including_transitive" "jvm_classpath_deps_including_transitive" "shared_library_deps_including_transitive")

for deps_file_pattern in "${deps_patterns[@]}"; do
  deps_file="$root/target/$module/$deps_file_pattern"
  if [[ -f "$deps_file" ]]; then
    while IFS= read -r dep_path; do
      if [[ -n "$dep_path" ]]; then
        # Extract module path from dependency path
        if [[ "$dep_path" =~ $root/target/(.+)/(js|classes|lib) ]]; then
          dep_module_path="${BASH_REMATCH[1]}"
        elif [[ "$dep_path" =~ $root/target/(.+) ]]; then
          dep_module_path="${BASH_REMATCH[1]}"
        else
          continue
        fi
        
        # Check for cargo deps file in the dependency
        dep_cargo_deps_file="$root/target/$dep_module_path/cargo_deps_including_transitive"
        if [[ -f "$dep_cargo_deps_file" ]]; then
          while IFS= read -r transitive_cargo_dep; do
            if [[ -n "$transitive_cargo_dep" ]]; then
              cargo_deps_incl_transitive+=("$transitive_cargo_dep")
            fi
          done < "$dep_cargo_deps_file"
        fi
      fi
    done < "$deps_file"
  fi
done

# Output, deduped and sorted
printf "%s\n" "${cargo_deps_incl_transitive[@]}" | sed '/^$/d' | sort -u > "$destination"