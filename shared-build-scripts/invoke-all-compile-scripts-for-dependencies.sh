#!/bin/bash
set -o pipefail

# This script invokes all .compile.sh scripts for the given dependencies.
root="$1"
shift
deps=("$@")

for dep in "${deps[@]}"; do
  compile_script="$root/${dep#module:}/.compile.sh"
  if [[ -f "$compile_script" ]]; then
    "$compile_script" "$root/.buildStepsDoneLastExecution"
  else
    echo "Error: Compile script not found for dependency '$dep' at '$compile_script'."
    exit 1
  fi
done
