#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/kotlintests/.*|\1|') # Updated for kotlintests
module="$(dirname ${script_source#*/kotlintests/})" # Updated for kotlintests
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/tests-init.sh # This might need updates for Kotlin later
cd $module_source_dir

# Define KOTLIN_HOME if not set, common location for Kotlin compiler
: "${KOTLIN_HOME:=/usr/share/kotlin}"

deps=(
  "module:kotlin/components/sonorants" # Updated for Kotlin module
)

# Visit compile-time deps and invoke their .compile.sh scripts
for dep in "${deps[@]}"; do "$root/${dep#module:}/.compile.sh" "$root/.buildStepsDoneLastExecution"; done

# Create directories for compiled classes
mkdir -p $root/target/$module/classes # For main code if any in this module (unlikely for tests)
mkdir -p $root/target/$module/test-classes # For compiled test classes
mkdir -p $root/target/$module/test-classes/$module # For timestamp file

# Classpath for compiling tests: includes main code, its dependencies, and Kotlin stdlib
CLASSPATH=$(
  {
    echo "$root/target/${deps[0]#module:kotlin/}/classes" # Compiled main Kotlin code
    # Add jvmdeps from the main module (assuming it lists .class files or JARs)
    cat "$root/target/${deps[0]#module:kotlin/}/jvmdeps" 2>/dev/null
    echo "$KOTLIN_HOME/lib/kotlin-stdlib.jar"
  } | sort -u | paste -sd ":" -
)

# Define Kotest binary dependencies
bindeps=(
)

# Build LIBS_CLASSPATH for Kotest and other libraries
LIBS_CLASSPATH=$(
  {
    for bindep in "${bindeps[@]}"; do
      echo "$root/libs/${bindep#lib:}" # Assumes JARs are in $root/libs/kotlin/kotest/
    done
  } | sort -u | paste -sd ":" -
)

# Timestamp-based test compilation
timestamp_file="$root/target/$module/test-classes/$module/.timestamp"
raw_source_timestamp=$(find . -mindepth 1 -name "*" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
source_timestamp=${raw_source_timestamp:-0}
previous_timestamp=$(cat "$timestamp_file" 2>/dev/null || echo 0)

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
  echo "$relative_script_path: compiling test Kotlin code for $module"
  # Compile Kotlin test files
  find . -name "*.kt" -print0 | xargs -0 kotlinc \
    -cp "$CLASSPATH:$LIBS_CLASSPATH" \
    -d "$root/target/$module/test-classes"

  if [ $? -ne 0 ]; then
    echo "Kotlin test compilation failed for module: $module"
    exit 1
  fi
  echo "Kotlin test compilation successful for module: $module"
  echo "$source_timestamp" > "$timestamp_file"

  # Create a jvmdeps file for this test module (if needed by other scripts)
  # For now, it's empty as test modules usually aren't dependencies for compilation.
  touch $root/target/$module/jvmdeps
  echo "Created/updated jvmdeps for test module $module"

  # Runtime Classpath for running tests:
  # - Compiled test classes
  # - Compiled main code classes (and its direct dependencies via jvmdeps)
  # - Kotlin stdlib
  # - Kotest libraries
  RUNTIME_CLASSPATH=$(
    {
      echo "$root/target/$module/test-classes"
      echo "$root/target/${deps[0]#module:kotlin/}/classes"
      cat "$root/target/${deps[0]#module:kotlin/}/jvmdeps" 2>/dev/null
      echo "$KOTLIN_HOME/lib/kotlin-stdlib.jar"  # should be in libs:/ ??
      echo "CLASSPATH"
      echo "$LIBS_CLASSPATH"
    } | sort -u | paste -sd ":" -
  )

  # Run the main method in SonorantsTests.kt using the compiled classes
  echo "Running SonorantsTests..."
  java -ea -cp "$RUNTIME_CLASSPATH" components.sonorants.SonorantsTestsKt

  if [ $? -eq 0 ]; then
    echo "Tests passed for module: $module"
  else
    echo "Tests failed for module: $module"
    exit 1
  fi
else
  echo "$relative_script_path: skipping compilation of and execution test Kotlin code for $module (not changed)"
fi
