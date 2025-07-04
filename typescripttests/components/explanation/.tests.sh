#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/typescripttests/.*|\1|')
module="$(dirname ${script_source#*/typescripttests/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/tests-init.sh
cd $module_source_dir

deps=(
  "module:typescript/components/explanation"
)

npm_deps=(
  "libs:javascript/assert"
  "libs:javascript/mocha"
)

# Visit compile-time deps and invoke their .compile.sh scripts
source $root/shared-build-scripts/invoke-all-compile-scripts-for-dependencies.sh "$root" "${deps[@]}"

# Create directory for compiled test classes (JS output)
mkdir -p $root/target/tests/$module/

timestamp_file="$root/target/tests/$module/.timestamp"
raw_source_timestamp=$(find . -mindepth 1 -name "*" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
source_timestamp=${raw_source_timestamp:-0}
previous_timestamp=$(cat "$timestamp_file" 2>/dev/null || echo 0)

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
  echo "$relative_script_path: compiling test code and executing tests"

  "$root/shared-build-scripts/make-target-tsdeps-file.sh" "$root" "$module" "$root/target/tests/$module/typescript_module_deps_including_transitive" "${deps[@]}"

  "$root/shared-build-scripts/make-target-npmdeps-file.sh" "$root" "$module" "$root/target/tests/$module/npm_deps_including_transitive" "${npm_deps[@]}"

  "$root/shared-build-scripts/make-target-shared-library-deps-file.sh" "$root" "$module" "$root/target/tests/$module/shared_library_deps_including_transitive" "${deps[@]}"

  "$root/shared-build-scripts/generate-typescript-base-tsconfig-json.sh" \
    "$root" "$module_source_dir" "$root/target/tests/$module" "$(cat "$root/target/tests/$module/typescript_module_deps_including_transitive")"

  "$root/shared-build-scripts/add-npm-deps-to-base-tsconfig-json.sh" "$root" "$module" "tests/$module" $(cat "$root/target/tests/$module/npm_deps_including_transitive")

  # Compile TypeScript test files
  tsc

  if [ $? -ne 0 ]; then
    echo "TypeScript test compilation failed for module: $module"
    exit 1
  fi

  NODE_PATH=$(
    {
      echo "$root/target/tests/$module/js" # Output directory for test classes
      echo "$root/target" # Add the base target directory for alias resolution
      # Use the tsdeps paths directly (they're already fully-qualified paths to js directories)
      cat "$root/target/tests/$module/typescript_module_deps_including_transitive" 2>/dev/null
      echo "$root/libs/javascript/npm_vendored/node_modules" # Add path for vendored npm modules
    } | sort -u | paste -sd ":" -
  )

  # Set NODE_PATH for Node.js to find modules
  export NODE_PATH

  # Run tests using Mocha
  node "$root/libs/javascript/npm_vendored/node_modules/mocha/bin/mocha.js" "$root/target/tests/$module/js/typescripttests/$module/ExplanationTests.js"
  echo "$source_timestamp" > "$timestamp_file"

else
  echo "$relative_script_path: skipping compilation of and execution test TypeScript code for $module (not changed)"
fi
