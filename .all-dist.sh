#!/bin/bash
set -eo pipefail
root=$(pwd)
echo "New build:"
echo "" > "$root/.buildStepsDoneLastExecution"
echo "Running all .dist.sh in $(pwd) subdirs"
find . -mindepth 2 -name '.dist.sh' -print0 \
  | while IFS= read -r -d '' script; do
      bash "$script" "$root/.buildStepsDoneLastExecution"
    done