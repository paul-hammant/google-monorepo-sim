#!/bin/bash
set -e
root=$(pwd)
rm "$root/.buildStepsDoneLastExecution" || true
echo "Running all .tests.sh in $(pwd) subdirs"
find . -mindepth 2 -name ".tests.sh" | while IFS= read -r script; do
  "$script" - "$root/.buildStepsDoneLastExecution" || exit 1
done

