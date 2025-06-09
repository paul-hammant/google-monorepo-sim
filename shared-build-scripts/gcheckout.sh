#!/bin/bash

set -eo pipefail
# Function to reset the sparse checkout configuration
reset_sparse_checkout() {
    echo "Resetting sparse checkout configuration..."
    git read-tree --reset -u HEAD
    rm .git/info/sparse-checkout
    git sparse-checkout disable
    echo "Sparse checkout configuration has been reset."
}
declare -A processed_modules
add_to_sparse_checkout() {
    local path="$1"
    local action="${2:-add}"
    if ! git sparse-checkout list | grep -q "^$path\$"; then
        echo "${action^}ing $path to sparse checkout"
        git sparse-checkout "$action" "$path"
    fi
}

# Function to process cargo dependencies and their transitive deps
process_cargo_dependencies() {
    local crate_name="$1"
    local action="$2"
    
    # Always add the main Rust registry
    local rust_registry="libs/rust/registry"
    if [[ -z "${processed_modules[$rust_registry]}" ]]; then
        echo "    Adding Rust registry: $rust_registry"
        processed_modules["$rust_registry"]=1
        add_to_sparse_checkout "$rust_registry" "$action"
    fi
    
    # Add all transitive dependencies if we have the helper script
    local deps_script="$root/libs/rust/registry/get-transitive-deps.sh"
    if [ -f "$deps_script" ]; then
        echo "    Getting transitive dependencies for $crate_name..."
        "$deps_script" "$crate_name" 2>/dev/null | while read -r dep_path; do
            if [ -n "$dep_path" ] && [[ ! "$dep_path" =~ ^# ]]; then
                if [[ -z "${processed_modules[$dep_path]}" ]]; then
                    echo "      Adding cargo transitive dep: $dep_path"
                    processed_modules["$dep_path"]=1
                    add_to_sparse_checkout "$dep_path" "$action"
                fi
            fi
        done
    else
        echo "    Warning: Rust dependency helper not found, adding registry only"
    fi
}

# Function to process a module path
process_module() {
    local module_path="$1"
    local action="$2"
    add_to_sparse_checkout "$module_path" "$action"

    # Find all .sh files in the module path
    local sh_files
    sh_files=$(find "$module_path" -name "*.sh")

    # Process each .sh file to find dependencies
    for sh_file in $sh_files; do
        echo "Processing dependencies in $sh_file"
        
        # 1. Handle module dependencies (e.g., "module:java/components/nasal")
        grep -Eo '\"module:[^"]+' "$sh_file" 2>/dev/null \
          | sed -E 's/^\"module://' \
          | while read -r dep; do
               if [[ -z "${processed_modules[$dep]}" ]]; then
                   echo "  Found module dependency: $dep"
                   processed_modules["$dep"]=1
                   process_module "$dep" "$action"
               fi
          done
          
        # 2. Handle npm dependencies (e.g., "libs:javascript/ffi-napi")
        grep -Eo '\"libs:javascript/[^"]+' "$sh_file" 2>/dev/null \
          | sed -E 's/^\"libs:javascript\///' \
          | while read -r npm_dep; do
               npm_path="libs/javascript/npm_vendored"
               if [[ -z "${processed_modules[$npm_path]}" ]]; then
                   echo "  Found npm dependency: $npm_dep (adding $npm_path)"
                   processed_modules["$npm_path"]=1
                   add_to_sparse_checkout "$npm_path" "$action"
               fi
          done
          
        # 3. Handle cargo dependencies (e.g., "libs:rust/jni")
        grep -Eo '\"libs:rust/[^"]+' "$sh_file" 2>/dev/null \
          | sed -E 's/^\"libs:rust\///' \
          | while read -r cargo_dep; do
               echo "  Found cargo dependency: $cargo_dep"
               process_cargo_dependencies "$cargo_dep" "$action"
          done
          
        # 4. Handle other lib dependencies (e.g., "libs:java/junit")  
        grep -Eo '\"libs:[^"]+' "$sh_file" 2>/dev/null \
          | sed -E 's/^\"libs://' \
          | while read -r lib_dep; do
               if [[ ! "$lib_dep" =~ ^(javascript/|rust/) ]]; then
                   lib_path="libs/$lib_dep"
                   lib_dir=$(dirname "$lib_path")
                   if [[ -z "${processed_modules[$lib_dir]}" ]]; then
                       echo "  Found lib dependency: $lib_dep (adding $lib_dir)"
                       processed_modules["$lib_dir"]=1
                       add_to_sparse_checkout "$lib_dir" "$action"
                   fi
               fi
          done
    done
}

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/shared-build-scripts/.*|\1|')

# Main script logic
if [ "$1" == "--reset" ]; then
    reset_sparse_checkout
    exit 0
elif [ "$1" == "add" ] && [ -n "$2" ]; then
    module_path="$2"
    process_module "$module_path" "add"
elif [ "$1" == "--init" ]; then
    echo "Initializing sparse checkout with --cone..."
    git sparse-checkout init --cone
    git sparse-checkout add shared-build-scripts
    echo "Sparse checkout initialized and shared-build-scripts added."
    echo "Usage: $0 add <module_path> | --init | --reset"
    exit 1
else
    echo "Usage: $0 add <module_path> | --init | --reset"
    exit 1
fi
