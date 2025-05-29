#!/bin/bash
root=$(pwd)
echo "New build:"
echo "" > "$root/.buildStepsDoneLastExecution"  || true
echo "Running all .compile.sh in $(pwd) subdirs"
find . -mindepth 2 -name ".compile.sh" -exec bash -c 'bash "$0" "$1"' {} "$root/.buildStepsDoneLastExecution" \;
