#!/bin/bash
set -eo pipefail
script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/rust/.*|\1|')
module="$(dirname ${script_source#*/rust/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

# Define cargo dependencies using the libs:rust/ format
cargo_deps=(
  "libs:rust/jni"
)

mkdir -p $root/target/components/vowelbase/lib
# Calculate the highest timestamp for source files
source_timestamp=$(find . -name "*" -printf '%T@\n' | sort -n | tail -1 || echo 0)
previous_timestamp=$(cat $root/target/$module/lib/.timestamp 2>/dev/null || echo 0)
# Compare timestamps and compile if necessary
if [[ "$source_timestamp" != "$previous_timestamp" ]]; then
    echo "$relative_script_path: compiling prod code"
    
    # Generate cargo dependencies file
    "$root/shared-build-scripts/make-target-cargo-deps-file.sh" "$root" "$module" "$root/target/$module/cargo_deps_including_transitive" "${cargo_deps[@]}"
    
    # Set up cargo environment for local registry
    "$root/shared-build-scripts/add-cargo-deps-to-build-env.sh" "$root" "$module" "$module" $(cat "$root/target/$module/cargo_deps_including_transitive")
    
    # Use cargo with local registry instead of rustc directly
    cargo build --release --target-dir="$root/target/$module/lib"
    echo $source_timestamp > $root/target/$module/lib/.timestamp
    echo -n "$root/target/$module/lib/release/libvowelbase.so" > $root/target/$module/ldlibdeps
    
    # Generate shared library dependencies file (Rust modules can have dependencies on other native modules)
    deps=()  # This Rust module has no dependencies currently
    "$root/shared-build-scripts/make-target-shared-library-deps-file.sh" "$root" "$module" "$root/target/$module/shared_library_deps_including_transitive" "${deps[@]}"
    # Add our own shared library to the transitive dependencies
    echo "$root/target/$module/lib/release/libvowelbase.so" >> "$root/target/$module/shared_library_deps_including_transitive"
    # Remove duplicates and sort
    sort -u "$root/target/$module/shared_library_deps_including_transitive" -o "$root/target/$module/shared_library_deps_including_transitive"
else
    echo "$relative_script_path: skipping compilation of prod code (not changed)"
fi
