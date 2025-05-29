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

# Function to process a module path
process_module() {
    local module_path="$1"
    local action="$2"
    add_to_sparse_checkout "$module_path" "$action"

    # Find all .sh files in the module path
    local sh_files
    sh_files=$(find "$module_path" -name "*.sh")

    # Process each .sh file to find module dependencies
    for sh_file in $sh_files; do
        grep -Eo '\"module:[^"]+' "$sh_file" \
          | sed -E 's/^\"module://' \
          | while read -r dep; do
               if [[ -z "${processed_modules[$dep]}" ]]; then
                   processed_modules["$dep"]=1
                   process_module "$dep"
               fi
          done
          grep -Eo '\"lib:[^"]+' "$sh_file" \
            | sed -E 's/^\"lib://' \
            | while read -r bindep; do
                 bindep=$(dirname "libs/$bindep")
                 if [[ -z "${processed_modules[$bindep]}" ]]; then
                     processed_modules["$bindep"]=1
                     process_module "$bindep"
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
