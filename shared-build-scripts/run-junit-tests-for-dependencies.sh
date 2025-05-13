#!/bin/bash

# Visit compile-time deps and invoke their .tests.sh scripts recursively
##  make depsTests from deps
for dep in "${deps[@]}"; do
  compile_script="$root/${dep#module:}/.compile.sh"
  if [[ -f "$compile_script" ]]; then
    while IFS= read -r line; do
      if [[ "$line" =~ module:[a-z] ]]; then
        # Extract the module path after 'module:'
        extracted=$(echo "$line" | sed -n 's/.*module:java\/\([a-zA-Z0-9\/_-]*\).*/\1/p')
        if [[ -n "$extracted" && "$extracted" != "java/" ]]; then
          "$root/javatests/${extracted}/.tests.sh" -tdt "$root/.buildStepsDoneLastExecution"
        fi
      fi
    done < "$compile_script"
  fi
 done