# Calculate the highest timestamp for source files

set -eo pipefail

if [ "${#deps[@]}" -ne 0 ]; then
  LDLIB_DEPS=$(
    for dep in "${deps[@]}"; do
      depmod="${dep#module:*\/}"
      if [ -f "$root/target/$depmod/ldlibdeps" ]; then
        cat "$root/target/$depmod/ldlibdeps"
        echo    # Always add a newline after each file
      fi
    done | sort -u
  )
fi

# Generate shared library dependencies file using the new transitive system
"$root/shared-build-scripts/make-target-shared-library-deps-file.sh" "$root" "$module" "$root/target/$module/shared_library_deps_including_transitive" "${deps[@]}"

source_timestamp=$(find . -mindepth 1 -name "*" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1 || echo 0)
previous_timestamp=$(cat "$root/target/$module/classes/$module/.timestamp" 2>/dev/null || echo 0)
# Compare timestamps and compile if necessary

if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    echo "$relative_script_path: compiling prod code"
    if ! javac -d "$root/target/$module/classes" $(find . -name "*.java") -cp "$CLASSPATH"; then
        echo "COMPILATION FAILED FOR $relative_script_path"
        exit 1
    fi
    echo "$source_timestamp" > "$root/target/$module/classes/$module/.timestamp"
    echo "$CLASSPATH" | sed 's/:/\n/g' > "$root/target/$module/jvm_classpath_deps_including_transitive"
    echo -n "$LDLIB_DEPS" | sponge "$root/target/$module/ldlibdeps"
    sed -i '/^[[:space:]]*$/d' "$root/target/$module/ldlibdeps"
    echo "" >> "$root/target/$module/ldlibdeps"

else
    echo "$relative_script_path: skipping compilation of prod code (not changed)"
fi
