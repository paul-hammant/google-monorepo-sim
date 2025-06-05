#!/bin/bash
set -eo pipefail

root="$1"
module="$2"
destination="$3"
shift 3
deps=("$@")

# Our in-memory collection
deps_incl_transitive=()

# Add the current module itself to the dependencies list
if [[ "$module" == typescript/* ]]; then
  deps_incl_transitive+=("module:$module") # If $module is already 'typescript/foo', use 'module:typescript/foo'
else
  deps_incl_transitive+=("module:typescript/$module") # Otherwise, prepend 'typescript/'
fi

for dep in "${deps[@]}"; do
  if [[ $dep == module:typescript/* ]]; then
    dep_path="${dep#module:typescript/}"
    ##echo "DEBUG: Adding direct dep $dep_path" >&2
    deps_incl_transitive+=("$dep")
    if [[ -f "$root/target/$dep_path/tsdeps" ]]; then
      while IFS= read -r trans_dep; do
        ##echo "DEBUG: Adding transitive dep $trans_dep from $dep_path" >&2
        deps_incl_transitive+=("$trans_dep")
      done < "$root/target/$dep_path/tsdeps"
    fi
  fi
done

# Output, deduped and sorted
#printf "%s\n" "${deps_incl_transitive[@]}" | grep -v '^$' | sort -u > "$destination"
printf "%s\n" "${deps_incl_transitive[@]}" | sed '/^$/d' | sort -u > "$destination"
#echo "DEBUG: $destination: $(cat $destination)"

