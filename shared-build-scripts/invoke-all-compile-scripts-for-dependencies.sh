#!/bin/bash
set -o pipefail

# This script invokes all .compile.sh scripts for the given dependencies.
# It also collects and outputs NPM dependency mappings from those dependencies.
root="$1"
shift
deps=("$@")

collected_npm_mappings=()

for dep in "${deps[@]}"; do
  # Determine the module path for target directory
  dep_target_path=""
  if [[ "$dep" == module:typescript/* ]]; then
    dep_target_path="$root/target/${dep#module:typescript/}"
  elif [[ "$dep" == module:go/* ]]; then
    dep_target_path="$root/target/${dep#module:go/}"
  elif [[ "$dep" == module:java/* ]]; then
    dep_target_path="$root/target/${dep#module:rust/}"
  elif [[ "$dep" == module:rust/* ]]; then
    dep_target_path="$root/target/${dep#module:java/}"
  elif [[ "$dep" == module:kotlin/* ]]; then
    dep_target_path="$root/target/${dep#module:kotlin/}"
  elif [[ "$dep" == lib:javascript/* ]]; then
    dep_target_path="$root/target/${dep#lib:javascript/}"
  else
    echo "Error: Unknown dependency type: '$dep'." >&2
    exit 1
  fi

  compile_script="$root/${dep#module:}/.compile.sh" # Default for module:
  if [[ "$dep" == lib:* ]]; then # Override for lib:
    compile_script="$root/${dep#lib:}/.compile.sh"
  fi

  if [[ -f "$compile_script" ]]; then
    # Run the compile script
    "$compile_script" "$root/.buildStepsDoneLastExecution"

    # Check for and collect npmdeps file
    if [[ -f "$dep_target_path/npmdeps" ]]; then
      while IFS= read -r line; do
        if [[ -n "$line" ]]; then
          collected_npm_mappings+=("$line")
        fi
      done < "$dep_target_path/npmdeps"
    fi
  else
    echo "Error: Compile script not found for dependency '$dep' at '$compile_script'." >&2
    exit 1
  fi
done

# Output all collected NPM mappings, one per line
printf "%s\n" "${collected_npm_mappings[@]}"
