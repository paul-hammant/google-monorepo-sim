# Calculate the highest timestamp for source files

set -e
source_timestamp=$(find . -name "*" -printf '%T@\n' | sort -n | tail -1)
previous_timestamp=$(cat $root/target/$module/classes/$module/.timestamp 2>/dev/null || echo 0)
# Compare timestamps and compile if necessary
if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    echo "$relative_script_path: compiling prod code"
    if ! javac -d $root/target/$module/classes $(find . -name "*.java") -cp "$CLASSPATH"; then
        echo "COMPILATION FAILED FOR $relative_script_path"
        exit 1
    fi
    echo $source_timestamp > $root/target/$module/classes/$module/.timestamp
    echo "$CLASSPATH" | sed 's/:/\n/g' > $root/target/$module/javadeps
else
    echo "$relative_script_path: skipping compilation of prod code (not changed)"
fi
