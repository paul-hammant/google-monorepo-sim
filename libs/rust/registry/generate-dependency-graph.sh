#!/bin/bash
set -eo pipefail

# This script generates a dependency graph and analysis for the Rust registry
# Run this after updating dependencies to understand the dependency tree

echo "=== Rust Registry Dependency Analysis ==="
echo "Generated on: $(date)"
echo

# Get the dependency tree
echo "## Full Dependency Tree"
echo '```'
cargo tree
echo '```'
echo

# Analyze direct vs transitive dependencies
echo "## Direct Dependencies (from our Cargo.toml)"
echo "These are the packages we explicitly depend on:"
echo
grep -A 100 "^\[dependencies\]" Cargo.toml | grep -v "^\[" | grep "=" | sed 's/^/- /'
echo

echo "## All Dependencies (including transitive)"
echo "These are all packages that get pulled in:"
echo
cargo metadata --format-version 1 | jq -r '.packages[] | select(.name != "rust_registry") | "- \(.name) v\(.version)"' | sort
echo

# Generate summary by category
echo "## Dependency Categories"
echo

echo "### Direct Dependencies (1 level)"
echo "These are explicitly listed in our Cargo.toml:"
cargo tree --depth 1 | grep "└──\|├──" | sed 's/.*── /- /' | head -20
echo

echo "### Direct Dependencies of jni (2nd level)"
echo "These are immediate dependencies of jni:"
cargo tree | grep "^    ├──\|^    └──" | grep -v "build-dependencies" | sed 's/.*── /- /' | head -20
echo

echo "### Build Dependencies"
echo "These are needed only at build time:"
cargo tree | grep -A 10 "build-dependencies" | grep "└──\|├──" | sed 's/.*── /- /'
echo

# Generate usage statistics
echo "## Statistics"
total_deps=$(cargo tree --format "{p}" | grep -v "rust_registry" | wc -l)
direct_deps_count=$(cargo tree --depth 1 | grep "└──\|├──" | wc -l)
transitive_deps_count=$((total_deps - direct_deps_count))

echo "- Total dependencies: $total_deps"
echo "- Direct dependencies: $direct_deps_count" 
echo "- Transitive dependencies: $transitive_deps_count"
echo

echo "## Recommended Actions"
echo "1. Review direct dependencies to ensure they're all necessary"
echo "2. Consider if any transitive dependencies could be replaced with lighter alternatives"
echo "3. Update this analysis after any Cargo.toml changes by running: ./generate-dependency-graph.sh > DEPENDENCY-ANALYSIS.md"