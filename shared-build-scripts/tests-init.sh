
# Maybe create a temporary file to track scripts that have been executed already
if [[ -z "$2" ]]; then
  echo "New build:"
  echo "" > "$root/.buildStepsDoneLastExecution"
fi

# Scripts already done (entered into), this invocation, mean they can be skipped without message
if [[ "$REDUNDANTLY_REVISIT_SCRIPTS" == "true" ]]; then
  echo "$relative_script_path: visiting"
else
  if ! grep -q "$relative_script_path" "$root/.buildStepsDoneLastExecution"; then
    #echo "$relative_script_path: visiting"
    if grep -q "$relative_script_path" "$root/.buildStepsDoneLastExecution"; then
      awk -v path="$relative_script_path" 'BEGIN{FS=OFS=":"} $1==path {$2+=1} 1' "$root/.buildStepsDoneLastExecution" > temp && mv temp "$root/.buildStepsDoneLastExecution"
    else
      echo "$relative_script_path:1" >> "$root/.buildStepsDoneLastExecution"
    fi
  else
    #echo "$relative_script_path: visited already in this execution, no need to do so again"
    awk -v path="$relative_script_path" 'BEGIN{FS=OFS=":"} $1==path {$2+=1} 1' "$root/.buildStepsDoneLastExecution" > temp && mv temp "$root/.buildStepsDoneLastExecution"
    exit 0
  fi
fi
