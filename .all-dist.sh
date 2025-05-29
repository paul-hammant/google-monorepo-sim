#!/bin/bash
set -eo pipefail
root=$(pwd)
echo "New build:"
echo "" > "$root/.buildStepsDoneLastExecution"
echo "Running all .dist.sh in $(pwd) subdirs"
find . -mindepth 2 -name ".dist.sh" -exec bash -c 'bash "$0" "$1"' {} "$root/.buildStepsDoneLastExecution" \;
