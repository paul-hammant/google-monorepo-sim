#!/bin/bash
set -eo pipefail

root="$1"
module="$2"
destination="$3"
shift 3
deps=("$@")

# Our in-memory collection
shared_lib_deps_incl_transitive=()

# Collect shared library dependencies from dependencies
for dep in "${deps[@]}"; do
  if [[ $dep == module:rust/* || $dep == module:go/* ]]; then
    dep_path="${dep#module:*/}"
    # Check for shared library deps from Rust/Go modules
    dep_ldlibdeps_file="$root/target/$dep_path/ldlibdeps"
    if [[ -f "$dep_ldlibdeps_file" ]]; then
      while IFS= read -r lib_path; do
        if [[ -n "$lib_path" ]]; then
          shared_lib_deps_incl_transitive+=("$lib_path")
        fi
      done < "$dep_ldlibdeps_file"
    fi
    
    # Also check for transitive shared library deps
    dep_shared_lib_deps_file="$root/target/$dep_path/shared_library_deps_including_transitive"
    if [[ -f "$dep_shared_lib_deps_file" ]]; then
      while IFS= read -r transitive_lib_path; do
        if [[ -n "$transitive_lib_path" ]]; then
          shared_lib_deps_incl_transitive+=("$transitive_lib_path")
        fi
      done < "$dep_shared_lib_deps_file"
    fi
  elif [[ $dep == module:java/* || $dep == module:kotlin/* || $dep == module:typescript/* ]]; then
    dep_path="${dep#module:*/}"
    # Check for transitive shared library deps from Java/Kotlin/TypeScript modules
    dep_shared_lib_deps_file="$root/target/$dep_path/shared_library_deps_including_transitive"
    if [[ -f "$dep_shared_lib_deps_file" ]]; then
      while IFS= read -r transitive_lib_path; do
        if [[ -n "$transitive_lib_path" ]]; then
          shared_lib_deps_incl_transitive+=("$transitive_lib_path")
        fi
      done < "$dep_shared_lib_deps_file"
    fi
  fi
done

# Output, deduped and sorted
printf "%s\n" "${shared_lib_deps_incl_transitive[@]}" | sed '/^$/d' | sort -u > "$destination"