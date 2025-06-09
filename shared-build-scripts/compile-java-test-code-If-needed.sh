set -eo pipefail

# Calculate the highest timestamp for source files
source_timestamp=$(find . -mindepth 1 -name "*" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1 || echo 0)
previous_timestamp=$(cat "$root/target/$module/test-classes/$module/.timestamp" 2>/dev/null || echo 0)
# Compare timestamps and compile if necessary
if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    echo "$relative_script_path: compiling test code and executing tests"

    JAVA_TEST_SOURCE_FILES=$(find . -name "*.java")
    if [[ -n "$JAVA_TEST_SOURCE_FILES" ]]; then
      if ! javac -cp "$CLASSPATH:$LIBS_CLASSPATH" -d "$root/target/$module/test-classes" $JAVA_TEST_SOURCE_FILES; then
          echo "COMPILATION FAILED FOR $relative_script_path"
          exit 1
      fi
    else
      echo "$relative_script_path: No Java test source files found, skipping javac."
    fi

    JAVA_TEST_CLASSES=$(find "$root/target/$module/test-classes" -name "*Tests.class")
    if [[ -n "$JAVA_TEST_CLASSES" ]]; then
      testClasses=$(echo "$JAVA_TEST_CLASSES" | sed "s#$root/target/$module/test-classes/##g" | sed 's|/|.|g' | sed 's|.class$||' | sed "s|^target.test-classes\.||")
      echo "$CLASSPATH:$LIBS_CLASSPATH" | sed 's/:/\n/g' > "$root/target/$module/javatestdeps"

      IFS=':'
      LD_LIB_PATH_STRING="${LD_LIB_PATH[*]}"
      unset IFS    # restore default

      java -Djava.library.path="$LD_LIB_PATH_STRING" -cp "$CLASSPATH:$LIBS_CLASSPATH" org.junit.runner.JUnitCore $testClasses
    else
      echo "$relative_script_path: No compiled Java test classes found, skipping JUnitCore execution."
    fi

    echo "$source_timestamp" > "$root/target/$module/test-classes/$module/.timestamp"
else
    echo "$relative_script_path: skipping compilation of test code (not changed)"
fi
