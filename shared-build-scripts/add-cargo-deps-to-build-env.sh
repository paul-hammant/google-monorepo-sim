#!/bin/bash
set -eo pipefail

root="$1"
module="$2"
target_dir_suffix="$3" # e.g. components/vowelbase or tests/components/vowelbase
shift 3
cargo_deps=("$@") # e.g. "libs:rust/jni"

package_map_path="$root/libs/rust/package-map"
cargo_config_path="$root/target/$target_dir_suffix/.cargo/config.toml"

if [ ! -f "$package_map_path" ]; then
  echo "Error: package-map not found at $package_map_path" >&2
  exit 1
fi

# Create .cargo directory if it doesn't exist
mkdir -p "$(dirname "$cargo_config_path")"

# Create cargo config that points to our local registry
cat > "$cargo_config_path" << 'EOF'
[source.crates-io]
replace-with = "local-registry"

[source.local-registry]
local-registry = "../../../libs/rust/registry"
EOF

# Create a CARGO_DEPS_PATHS environment variable for rustc if needed
cargo_deps_paths=""
for cargo_dep_full_name in "${cargo_deps[@]}"; do
  dep_short_name="${cargo_dep_full_name#libs:rust/}"
  
  # Find the path from package-map
  line=$(grep "^${dep_short_name}:" "$package_map_path" || true)
  
  if [ -n "$line" ]; then
    dep_path_suffix=$(echo "$line" | cut -d: -f2)
    # Construct the full path to the dependency libraries
    lib_path="$root/libs/rust/$dep_path_suffix"
    if [ -n "$cargo_deps_paths" ]; then
      cargo_deps_paths="$cargo_deps_paths:$lib_path"
    else
      cargo_deps_paths="$lib_path"
    fi
  else
    echo "Info: No mapping found for cargo dependency '$dep_short_name' in $package_map_path. Skipping." >&2
  fi
done

# Write the CARGO_DEPS_PATHS to a file for the build script to source
if [ -n "$cargo_deps_paths" ]; then
  echo "export CARGO_DEPS_PATHS=\"$cargo_deps_paths\"" > "$root/target/$target_dir_suffix/cargo_deps_env.sh"
else
  echo "# No cargo dependencies" > "$root/target/$target_dir_suffix/cargo_deps_env.sh"
fi