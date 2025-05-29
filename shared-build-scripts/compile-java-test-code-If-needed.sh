set -eo pipefail

# Calculate the highest timestamp for source files
source_timestamp=$(find . -mindepth 1 -name "*" -printf '%T@\n' | sort -n | tail -1)-
previous_timestamp=$(cat $root/target/$module/test-classes/$module/.timestamp 2>/dev/null || echo 0)
# Compare timestamps and compile if necessary
if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    echo "$relative_script_path: compiling test code and executing tests"
    if ! javac -cp "$CLASSPATH:$LIBS_CLASSPATH" -d $root/target/$module/test-classes $(find . -name "*.java"); then
        echo "COMPILATION FAILED FOR $relative_script_path"
        exit 1
    fi

    testClasses=$(find $root/target/$module/test-classes -name "*Tests.class" | sed "s#$root/target/$module/test-classes/##g" | sed 's|/|.|g' | sed 's|.class$||' | sed "s|^target.test-classes\.||")
    echo "$CLASSPATH:$LIBS_CLASSPATH" | sed 's/:/\n/g' > $root/target/$module/javatestdeps
    java -Djava.library.path="$LD_LIB_PATH" -cp "$CLASSPATH:$LIBS_CLASSPATH" org.junit.runner.JUnitCore $testClasses
    echo $source_timestamp > $root/target/$module/test-classes/$module/.timestamp
else
    echo "$relative_script_path: skipping compilation of test code (not changed)"
fi
