#!/bin/bash
set -eo pipefail

# Sparse checkout helper for Rust dependencies
# This script helps create minimal checkouts with only needed Rust dependencies

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_FILE="$SCRIPT_DIR/DEPENDENCIES.txt"

show_usage() {
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  list-direct          List direct dependencies only"
    echo "  list-all             List all dependencies"  
    echo "  list-vendor-paths    List vendor paths for sparse checkout"
    echo "  list-by-depth <N>    List dependencies at depth N"
    echo "  create-sparse-list   Generate paths for minimal Rust sparse checkout"
    echo "  show-stats           Show dependency statistics"
    echo
    echo "Examples:"
    echo "  $0 list-direct"
    echo "  $0 list-by-depth 2"
    echo "  $0 create-sparse-list > rust-sparse-paths.txt"
}

if [ ! -f "$DEPS_FILE" ]; then
    echo "Error: $DEPS_FILE not found. Run ./generate-dependency-data.sh first."
    exit 1
fi

case "$1" in
    "list-direct")
        echo "=== Direct Dependencies ==="
        grep '^direct:' "$DEPS_FILE" | while IFS=: read -r type name version; do
            echo "- $name ($version)"
        done
        ;;
        
    "list-all")
        echo "=== All Dependencies ==="
        grep '^all:' "$DEPS_FILE" | while IFS=: read -r type name version; do
            echo "- $name v$version"
        done
        ;;
        
    "list-vendor-paths")
        echo "=== Vendor Paths ==="
        grep '^vendor:' "$DEPS_FILE" | cut -d: -f3
        ;;
        
    "list-by-depth")
        if [ -z "$2" ]; then
            echo "Error: Please specify depth (e.g., $0 list-by-depth 2)"
            exit 1
        fi
        depth="$2"
        echo "=== Dependencies at Depth $depth ==="
        grep "^depth:.*:$depth\$" "$DEPS_FILE" | while IFS=: read -r type name depth_val; do
            echo "- $name"
        done
        ;;
        
    "create-sparse-list")
        echo "# Minimal Rust sparse checkout paths"
        echo "# Generated on $(date)"
        echo
        echo "# Core registry files"
        echo "libs/rust/registry/Cargo.toml"
        echo "libs/rust/registry/src/"
        echo "libs/rust/registry/.cargo/"
        echo "libs/rust/registry/README.md"
        echo "libs/rust/registry/DEPENDENCIES.txt"
        echo "libs/rust/registry/*.sh"
        echo
        echo "# Vendor directories for all dependencies"
        grep '^vendor:' "$DEPS_FILE" | cut -d: -f3
        echo
        echo "# Pre-compiled artifacts (optional - comment out for source-only checkout)"
        echo "libs/rust/registry/target/release/deps/"
        ;;
        
    "show-stats")
        echo "=== Rust Registry Statistics ==="
        direct_count=$(grep -c '^direct:' "$DEPS_FILE")
        all_count=$(grep -c '^all:' "$DEPS_FILE")
        vendor_count=$(grep -c '^vendor:' "$DEPS_FILE")
        build_count=$(grep -c '^build:' "$DEPS_FILE")
        
        echo "Direct dependencies: $direct_count"
        echo "Total dependencies: $all_count"
        echo "Transitive dependencies: $((all_count - direct_count))"
        echo "Vendor directories: $vendor_count"
        echo "Build-only dependencies: $build_count"
        echo
        echo "Dependency expansion ratio: $((all_count))x (1 direct → $all_count total)"
        
        if [ $vendor_count -gt 0 ]; then
            echo
            echo "Vendor directory sizes:"
            grep '^vendor:' "$DEPS_FILE" | cut -d: -f3 | while read path; do
                if [ -d "$path" ]; then
                    size=$(du -sh "$path" 2>/dev/null | cut -f1)
                    crate_name=$(basename "$path")
                    echo "  $crate_name: $size"
                fi
            done | sort -k2 -hr | head -10
        fi
        ;;
        
    *)
        show_usage
        exit 1
        ;;
esac