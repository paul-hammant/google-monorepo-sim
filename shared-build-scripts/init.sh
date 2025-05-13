
# Maybe create a temporary file to track scripts that have been executed already
if [[ -z "$1" ]]; then
  echo "New build:"
  echo "" > "$root/.buildStepsDoneLastExecution"
fi

# Scripts already done (entered into), this invocation, mean they can be skipped without message
if [[ "$REDUNDANTLY_REVISIT_SCRIPTS" == "true" ]]; then
  echo "$relative_script_path: visiting"
else
  if ! grep -Fxq "$relative_script_path" "$root/.buildStepsDoneLastExecution"; then
    #echo "$relative_script_path: visiting"
    echo "$relative_script_path" >> "$root/.buildStepsDoneLastExecution"
  else
    #echo "$relative_script_path: visited already in this execution, no need to do so again"
    exit 0
  fi
fi
