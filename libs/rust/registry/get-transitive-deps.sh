#!/bin/bash
set -eo pipefail

# Helper script for gcheckout.sh to get transitive Rust dependencies
# Usage: ./get-transitive-deps.sh <crate_name>
# Returns all vendor paths needed for the given crate

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_FILE="$SCRIPT_DIR/DEPENDENCIES.txt"

if [ ! -f "$DEPS_FILE" ]; then
    echo "Error: $DEPS_FILE not found. Run ./generate-dependency-data.sh first." >&2
    exit 1
fi

crate_name="$1"
if [ -z "$crate_name" ]; then
    echo "Usage: $0 <crate_name>" >&2
    echo "Example: $0 jni" >&2
    exit 1
fi

# Check if this is a direct dependency we manage
if ! grep -q "^direct:$crate_name:" "$DEPS_FILE"; then
    echo "Warning: $crate_name is not a direct dependency in this registry" >&2
    exit 1
fi

echo "# Transitive dependencies for $crate_name"

# Get all vendor paths since cargo resolves the full graph
grep '^vendor:' "$DEPS_FILE" | cut -d: -f3

# Also include the registry structure itself
echo "libs/rust/registry/Cargo.toml"
echo "libs/rust/registry/src/"
echo "libs/rust/registry/.cargo/"