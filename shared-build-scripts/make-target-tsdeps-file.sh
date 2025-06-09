#!/bin/bash
set -eo pipefail

root="$1"
module="$2"
destination="$3"
shift 3
deps=("$@")

# Our in-memory collection
deps_incl_transitive=()

# Add the current module itself to the dependencies list (as fully-qualified path to transpiled .js)
deps_incl_transitive+=("$root/target/$module/js")

for dep in "${deps[@]}"; do
  if [[ $dep == module:typescript/* ]]; then
    dep_path="${dep#module:typescript/}"
    ##echo "DEBUG: Adding direct dep $dep_path" >&2
    # Convert to fully-qualified path to transpiled .js directory
    deps_incl_transitive+=("$root/target/$dep_path/js")
    if [[ -f "$root/target/$dep_path/typescript_module_deps_including_transitive" ]]; then
      while IFS= read -r trans_dep; do
        ##echo "DEBUG: Adding transitive dep $trans_dep from $dep_path" >&2
        deps_incl_transitive+=("$trans_dep")
      done < "$root/target/$dep_path/typescript_module_deps_including_transitive"
    fi
  fi
done

# Output, deduped and sorted
#printf "%s\n" "${deps_incl_transitive[@]}" | grep -v '^$' | sort -u > "$destination"
printf "%s\n" "${deps_incl_transitive[@]}" | sed '/^$/d' | sort -u > "$destination"
#echo "DEBUG: $destination: $(cat $destination)"

