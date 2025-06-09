#!/bin/bash
set -eo pipefail

# This script updates the Rust registry after adding/changing dependencies in Cargo.toml
# Usage: ./update-registry.sh [--dry-run]

DRY_RUN=""
if [ "$1" = "--dry-run" ]; then
    DRY_RUN="--dry-run"
    echo "DRY RUN MODE - no changes will be made"
fi

echo "=== Updating Rust Registry ==="
echo "Current directory: $(pwd)"
echo

# Step 1: Vendor dependencies
echo "Step 1: Vendoring dependencies..."
if [ "$DRY_RUN" = "" ]; then
    cargo vendor vendor
else
    echo "  (DRY RUN) Would run: cargo vendor vendor"
fi
echo

# Step 2: Build registry to get compiled artifacts
echo "Step 2: Building registry..."
if [ "$DRY_RUN" = "" ]; then
    cargo build --release
else
    echo "  (DRY RUN) Would run: cargo build --release"
fi
echo

# Step 3: Generate dependency analysis
echo "Step 3: Generating dependency analysis..."
if [ "$DRY_RUN" = "" ]; then
    ./generate-dependency-graph.sh > DEPENDENCY-ANALYSIS.md
    echo "  Updated DEPENDENCY-ANALYSIS.md"
else
    echo "  (DRY RUN) Would run: ./generate-dependency-graph.sh > DEPENDENCY-ANALYSIS.md"
fi
echo

# Step 4: Show what changed
echo "Step 4: Summary of changes..."
if [ "$DRY_RUN" = "" ]; then
    echo "Files to commit:"
    echo "- vendor/ (vendored source code)"
    echo "- target/release/ (pre-compiled artifacts)"
    echo "- DEPENDENCY-ANALYSIS.md (dependency graph)"
    echo
    echo "Git status:"
    git status --porcelain vendor/ target/ DEPENDENCY-ANALYSIS.md 2>/dev/null || echo "  (no git repository or files)"
else
    echo "  (DRY RUN) Would show git status of vendor/, target/, DEPENDENCY-ANALYSIS.md"
fi
echo

# Step 5: Instructions for committing
echo "Step 5: Next steps..."
if [ "$DRY_RUN" = "" ]; then
    echo "To commit the changes:"
    echo "  git add vendor/ target/release/ DEPENDENCY-ANALYSIS.md"
    echo "  git commit -m \"Update Rust registry dependencies\""
    echo
    echo "To see the dependency changes, review DEPENDENCY-ANALYSIS.md"
else
    echo "  (DRY RUN) Would provide git commit instructions"
fi

echo "=== Registry update complete ==="