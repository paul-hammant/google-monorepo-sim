#!/bin/bash
set -eo pipefail

# Rust-aware wrapper for gcheckout.sh that understands cargo dependencies
# This extends the original gcheckout.sh to handle Rust cargo dependency graphs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

# Source the original gcheckout functions
source "$SCRIPT_DIR/gcheckout.sh"

# Enhanced module processing that understands cargo deps
process_module_with_rust() {
    local module_path="$1"
    local action="$2"
    
    # Call original process_module function
    process_module "$module_path" "$action"
    
    # Additionally handle cargo dependencies if this is a Rust module
    if [[ "$module_path" =~ ^rust/ ]]; then
        echo "Processing Rust module: $module_path"
        
        # Find .compile.sh files in the Rust module
        local sh_files
        sh_files=$(find "$module_path" -name "*.compile.sh" 2>/dev/null || true)
        
        for sh_file in $sh_files; do
            # Look for cargo_deps=("libs:rust/...")
            grep -o 'libs:rust/[^"]*' "$sh_file" 2>/dev/null | while read cargo_dep; do
                crate_name="${cargo_dep#libs:rust/}"
                echo "Found cargo dependency: $crate_name"
                
                # Get all transitive dependencies for this crate
                if [ -f "$ROOT/libs/rust/registry/get-transitive-deps.sh" ]; then
                    "$ROOT/libs/rust/registry/get-transitive-deps.sh" "$crate_name" | while read dep_path; do
                        if [ -n "$dep_path" ] && [[ ! "$dep_path" =~ ^# ]]; then
                            echo "Adding Rust transitive dep: $dep_path"
                            add_to_sparse_checkout "$dep_path" "$action"
                        fi
                    done
                fi
            done
        done
    fi
}

# Main script logic (mirrors original but uses enhanced function)
if [ "$1" == "--reset" ]; then
    reset_sparse_checkout
    exit 0
elif [ "$1" == "add" ] && [ -n "$2" ]; then
    module_path="$2"
    process_module_with_rust "$module_path" "add"
elif [ "$1" == "--init" ]; then
    echo "Initializing sparse checkout with --cone..."
    git sparse-checkout init --cone
    git sparse-checkout add shared-build-scripts
    echo "Sparse checkout initialized and shared-build-scripts added."
    echo "Usage: $0 add <module_path> | --init | --reset"
    exit 1
else
    echo "Rust-aware gcheckout wrapper"
    echo "Usage: $0 add <module_path> | --init | --reset"
    echo
    echo "This extends gcheckout.sh to handle Rust cargo dependencies."
    echo "When adding a Rust module, it will also include all transitive cargo dependencies."
    exit 1
fi