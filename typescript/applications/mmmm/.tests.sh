#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
module_source_dir="$(dirname "$script_source")" # e.g., /app/typescript/applications/mmmm
# Determine root by navigating up from module_source_dir
# typescript/applications/mmmm -> typescript/applications -> typescript -> /app (root)
root=$(realpath "$module_source_dir/../../..")
# Module path relative to root, e.g., typescript/applications/mmmm
module="${module_source_dir#$root/}"
relative_script_path="${script_source#$root/}" # Path to this script, relative to root
source "$root/shared-build-scripts/tests-init.sh" # Ensure $root is correctly prepended
cd "$module_source_dir"

deps=(
  "module:typescript/applications/mmmm"
)
npmdeps=( "assert@1.5.1" "@types/node@20.12.7" "ffi-napi@^4.0.3" "@types/ffi-napi@^3.0.0" ) # Added @types/node

# --- BEGIN NPM VENDORING ---
echo "Ensuring NPM dependencies..."
if [ ${#npmdeps[@]} -gt 0 ]; then
  ensure_npm_script_path="$root/shared-build-scripts/npm-vendoring/ensure-npm-dependencies.sh"
  # Ensure the script is executable (it should be, but defensive check)
  if [ ! -x "$ensure_npm_script_path" ]; then
    echo "Error: NPM vendoring script $ensure_npm_script_path is not executable."
    exit 1
  fi
  vendored_npm_paths_string=$("$ensure_npm_script_path" "$root" "${npmdeps[@]}")
  if [ $? -ne 0 ]; then
    echo "Error: Failed to vendor NPM dependencies."
    exit 1
  fi
  readarray -t vendored_npm_paths <<< "$vendored_npm_paths_string"
else
  vendored_npm_paths=() # Ensure array is empty if no npmdeps
fi
echo "NPM vendoring complete."
# --- END NPM VENDORING ---

# Visit compile-time deps and invoke their .compile.sh scripts
for dep in "${deps[@]}"; do "$root/${dep#module:}/.compile.sh" "$root/.buildStepsDoneLastExecution"; done

# Create directory for compiled test classes (JS output)
mkdir -p $root/target/tests/$module/

# Timestamp-based test compilation and execution
timestamp_file="$root/target/tests/$module/.timestamp"
raw_source_timestamp=$(find . -mindepth 1 -name "*.ts" -type f -printf '%T@
' 2>/dev/null | sort -n | tail -1)
source_timestamp=${raw_source_timestamp:-0}
previous_timestamp=$(cat "$timestamp_file" 2>/dev/null || echo 0)

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
  echo "$relative_script_path: compiling test code and executing tests"

  # Ensure the target directory for logs exists
  mkdir -p "$root/target/"

  "$root/shared-build-scripts/make-target-tsdeps-file.sh" "$root" "$module" "$root/target/tests/$module/tsdeps" "${deps[@]}"
  echo "DEBUG: After make-target-tsdeps-file.sh. Checking if tsdeps file exists:"
  ls -l "$root/target/tests/$module/tsdeps" || echo "DEBUG: tsdeps file not found."

  # Pass npmdeps to generate-typescript-base-tsconfig-json.sh (as a string)

echo "--- [DEBUG] [.tests.sh] Content of generated base-tsconfig.json (to stderr) --- " >&2
cat "\$root/target/tests/\$module/base-tsconfig.json" >&2 || echo "[DEBUG] [.tests.sh] cat base-tsconfig.json failed" >&2
echo "" >&2
echo "--- [DEBUG] [.tests.sh] Validating base-tsconfig.json with jq (to stderr) --- " >&2
if command -v jq > /dev/null; then
  jq . "\$root/target/tests/\$module/base-tsconfig.json" >&2 || echo "[DEBUG] [.tests.sh] jq validation failed (or file not found by jq)" >&2;
else
  echo "[DEBUG] [.tests.sh] jq command not found, skipping JSON validation." >&2;
fi
echo "" >&2


echo "--- [DEBUG] [.tests.sh] Content of generated base-tsconfig.json --- " >> \$root/target/test_error.log
cat "\$root/target/tests/\$module/base-tsconfig.json" >> \$root/target/test_error.log || echo "[DEBUG] [.tests.sh] cat base-tsconfig.json failed" >> \$root/target/test_error.log
echo "" >> \$root/target/test_error.log
echo "--- [DEBUG] [.tests.sh] Validating base-tsconfig.json with jq --- " >> \$root/target/test_error.log
if command -v jq > /dev/null; then
  jq . "\$root/target/tests/\$module/base-tsconfig.json" >> \$root/target/test_error.log 2>> \$root/target/test_error.log || echo "[DEBUG] [.tests.sh] jq validation failed." >> \$root/target/test_error.log
else
  echo "[DEBUG] [.tests.sh] jq command not found, skipping JSON validation." >> \$root/target/test_error.log
fi
echo "" >> \$root/target/test_error.log

  # This script will be modified in the next plan step to accept and use this.
  # Construct the npm_dep_mappings_string (e.g., "assert:/path/to/assert @types/node:/path/to/types/node")
  npm_dep_mappings_string=""
  if [ ${#npmdeps[@]} -gt 0 ]; then
    for i in "${!npmdeps[@]}"; do
      name_at_version="${npmdeps[$i]}"
      # Regex to extract package_name (handles scope)
      [[ "$name_at_version" =~ ^((@([^/]+)/)?([^@]+))@([^@]+)$ ]]
      pkg_name_for_mapping="${BASH_REMATCH[1]}" # Full name e.g. @types/node or assert

      actual_path_for_mapping="${vendored_npm_paths[$i]}"
      npm_dep_mappings_string+="$pkg_name_for_mapping:$actual_path_for_mapping "
    done
    npm_dep_mappings_string=$(echo "$npm_dep_mappings_string" | sed 's/ $//') # Remove trailing space
  fi

  echo "DEBUG: Calling generate-typescript-base-tsconfig-json.sh with args:"

echo "--- [DEBUG] [.tests.sh] Content of generated base-tsconfig.json (to stderr) --- " >&2
cat "\$root/target/tests/\$module/base-tsconfig.json" >&2 || echo "[DEBUG] [.tests.sh] cat base-tsconfig.json failed" >&2
echo "" >&2
echo "--- [DEBUG] [.tests.sh] Validating base-tsconfig.json with jq (to stderr) --- " >&2
if command -v jq > /dev/null; then
  jq . "\$root/target/tests/\$module/base-tsconfig.json" >&2 || echo "[DEBUG] [.tests.sh] jq validation failed (or file not found by jq)" >&2;
else
  echo "[DEBUG] [.tests.sh] jq command not found, skipping JSON validation." >&2;
fi
echo "" >&2


echo "--- [DEBUG] [.tests.sh] Content of generated base-tsconfig.json --- " >> \$root/target/test_error.log
cat "\$root/target/tests/\$module/base-tsconfig.json" >> \$root/target/test_error.log || echo "[DEBUG] [.tests.sh] cat base-tsconfig.json failed" >> \$root/target/test_error.log
echo "" >> \$root/target/test_error.log
echo "--- [DEBUG] [.tests.sh] Validating base-tsconfig.json with jq --- " >> \$root/target/test_error.log
if command -v jq > /dev/null; then
  jq . "\$root/target/tests/\$module/base-tsconfig.json" >> \$root/target/test_error.log 2>> \$root/target/test_error.log || echo "[DEBUG] [.tests.sh] jq validation failed." >> \$root/target/test_error.log
else
  echo "[DEBUG] [.tests.sh] jq command not found, skipping JSON validation." >> \$root/target/test_error.log
fi
echo "" >> \$root/target/test_error.log

  echo "DEBUG: Arg1 (root): $root"
  echo "DEBUG: Arg2 (consumer_module_source_dir): $module_source_dir"
  echo "DEBUG: Arg3 (consumer_target_dir): $root/target/tests/$module"
  echo "DEBUG: Arg4 (deps_source_paths_string): $(cat "$root/target/tests/$module/tsdeps" 2>/dev/null || echo "tsdeps is empty or not found")"
  echo "DEBUG: Arg5 (npm_dep_mappings_string): $npm_dep_mappings_string"

  "$root/shared-build-scripts/generate-typescript-base-tsconfig-json.sh"     "$root" "$module_source_dir" "$root/target/tests/$module"     "$(cat "$root/target/tests/$module/tsdeps" 2>/dev/null)"     "$npm_dep_mappings_string"

echo "--- [DEBUG] [.tests.sh] Content of generated base-tsconfig.json (to stderr) --- " >&2
cat "\$root/target/tests/\$module/base-tsconfig.json" >&2 || echo "[DEBUG] [.tests.sh] cat base-tsconfig.json failed" >&2
echo "" >&2
echo "--- [DEBUG] [.tests.sh] Validating base-tsconfig.json with jq (to stderr) --- " >&2
if command -v jq > /dev/null; then
  jq . "\$root/target/tests/\$module/base-tsconfig.json" >&2 || echo "[DEBUG] [.tests.sh] jq validation failed (or file not found by jq)" >&2;
else
  echo "[DEBUG] [.tests.sh] jq command not found, skipping JSON validation." >&2;
fi
echo "" >&2


echo "--- [DEBUG] [.tests.sh] Content of generated base-tsconfig.json --- " >> \$root/target/test_error.log
cat "\$root/target/tests/\$module/base-tsconfig.json" >> \$root/target/test_error.log || echo "[DEBUG] [.tests.sh] cat base-tsconfig.json failed" >> \$root/target/test_error.log
echo "" >> \$root/target/test_error.log
echo "--- [DEBUG] [.tests.sh] Validating base-tsconfig.json with jq --- " >> \$root/target/test_error.log
if command -v jq > /dev/null; then
  jq . "\$root/target/tests/\$module/base-tsconfig.json" >> \$root/target/test_error.log 2>> \$root/target/test_error.log || echo "[DEBUG] [.tests.sh] jq validation failed." >> \$root/target/test_error.log
else
  echo "[DEBUG] [.tests.sh] jq command not found, skipping JSON validation." >> \$root/target/test_error.log
fi
echo "" >> \$root/target/test_error.log


  echo "DEBUG: After generate-typescript-base-tsconfig-json.sh. Checking if base-tsconfig.json exists:"

echo "--- [DEBUG] [.tests.sh] Content of generated base-tsconfig.json (to stderr) --- " >&2
cat "\$root/target/tests/\$module/base-tsconfig.json" >&2 || echo "[DEBUG] [.tests.sh] cat base-tsconfig.json failed" >&2
echo "" >&2
echo "--- [DEBUG] [.tests.sh] Validating base-tsconfig.json with jq (to stderr) --- " >&2
if command -v jq > /dev/null; then
  jq . "\$root/target/tests/\$module/base-tsconfig.json" >&2 || echo "[DEBUG] [.tests.sh] jq validation failed (or file not found by jq)" >&2;
else
  echo "[DEBUG] [.tests.sh] jq command not found, skipping JSON validation." >&2;
fi
echo "" >&2


echo "--- [DEBUG] [.tests.sh] Content of generated base-tsconfig.json --- " >> \$root/target/test_error.log
cat "\$root/target/tests/\$module/base-tsconfig.json" >> \$root/target/test_error.log || echo "[DEBUG] [.tests.sh] cat base-tsconfig.json failed" >> \$root/target/test_error.log
echo "" >> \$root/target/test_error.log
echo "--- [DEBUG] [.tests.sh] Validating base-tsconfig.json with jq --- " >> \$root/target/test_error.log
if command -v jq > /dev/null; then
  jq . "\$root/target/tests/\$module/base-tsconfig.json" >> \$root/target/test_error.log 2>> \$root/target/test_error.log || echo "[DEBUG] [.tests.sh] jq validation failed." >> \$root/target/test_error.log
else
  echo "[DEBUG] [.tests.sh] jq command not found, skipping JSON validation." >> \$root/target/test_error.log
fi
echo "" >> \$root/target/test_error.log

  ls -l "$root/target/tests/$module/base-tsconfig.json" || echo "DEBUG: base-tsconfig.json not found."

  # Compile TypeScript test files using the test-specific tsconfig
  # Compile TypeScript test files with trace resolution
  echo "[DEBUG] [.tests.sh] About to run: tsc -p tsconfig.tests.json --traceResolution" >&2
  tsc -p tsconfig.tests.json --traceResolution

  if [ $? -ne 0 ]; then
    echo "TypeScript test compilation failed for module: $module"
    exit 1
  fi

  NODE_PATH=$(
    {
      echo "$root/target/tests/$module" # Output directory for test classes
      echo "$root/target" # Ensure base target is included for alias resolution
      # Prepend $root/target/ to each path from tsdeps
      if [ -f "$root/target/tests/$module/tsdeps" ]; then # Check if tsdeps file exists
          sed "s|^|$root/target/|" "$root/target/tests/$module/tsdeps" 2>/dev/null
      fi
      # Add paths to vendored NPM packages
      if [ ${#vendored_npm_paths[@]} -gt 0 ]; then
        printf "%s\n" "${vendored_npm_paths[@]}"
      fi
    } | sort -u | paste -sd ":" -
  )

  # Set NODE_PATH for Node.js to find modules
  export NODE_PATH
  echo "Updated NODE_PATH: $NODE_PATH"

  # Run tests using Node.js
  # Assuming the test file is MmmmU0021Tests.js in the compiled test-classes directory
  node "$root/target/tests/$module/MmmmU0021Tests.js"
  echo "$source_timestamp" > "$timestamp_file"

else
  echo "$relative_script_path: skipping compilation of and execution test TypeScript code for $module (not changed)"
fi
