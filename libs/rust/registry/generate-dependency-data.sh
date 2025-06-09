#!/bin/bash
set -eo pipefail

# Generate machine-parsable dependency data for the Rust registry
# Output format is designed for easy bash parsing and sparse checkout use

echo "=== Generating Rust dependency data ==="

# Generate direct dependencies list
echo "# Direct dependencies (explicitly in Cargo.toml)" > DEPENDENCIES.txt
echo "# Format: direct:<crate_name>:<version>" >> DEPENDENCIES.txt
cargo metadata --format-version 1 | jq -r '
  .packages[] | 
  select(.name == "rust_registry") | 
  .dependencies[] | 
  select(.kind == null or .kind == "normal") |
  "direct:\(.name):\(.req)"
' >> DEPENDENCIES.txt

echo "" >> DEPENDENCIES.txt

# Generate all dependencies list  
echo "# All dependencies (direct + transitive)" >> DEPENDENCIES.txt
echo "# Format: all:<crate_name>:<version>" >> DEPENDENCIES.txt
cargo metadata --format-version 1 | jq -r '
  .packages[] | 
  select(.name != "rust_registry") | 
  "all:\(.name):\(.version)"
' | sort >> DEPENDENCIES.txt

echo "" >> DEPENDENCIES.txt

# Generate dependency relationships
echo "# Dependency relationships" >> DEPENDENCIES.txt  
echo "# Format: depends:<crate_name>:<dependency_name>:<version>" >> DEPENDENCIES.txt
cargo metadata --format-version 1 | jq -r '
  .packages[] | 
  select(.name != "rust_registry") |
  . as $pkg |
  .dependencies[] |
  select(.kind == "normal") |
  "depends:\($pkg.name):\(.name):\(.req)"
' | sort >> DEPENDENCIES.txt

echo "" >> DEPENDENCIES.txt

# Generate build dependencies
echo "# Build-only dependencies" >> DEPENDENCIES.txt
echo "# Format: build:<crate_name>:<version>" >> DEPENDENCIES.txt  
cargo metadata --format-version 1 | jq -r '
  .packages[] |
  select(.name != "rust_registry") |
  . as $pkg |
  .dependencies[] |
  select(.kind == "build") |
  "build:\($pkg.name):\(.version)"
' | sort >> DEPENDENCIES.txt

echo "" >> DEPENDENCIES.txt

# Generate transitive depth information
echo "# Dependency depth from direct dependencies" >> DEPENDENCIES.txt
echo "# Format: depth:<crate_name>:<depth_level>" >> DEPENDENCIES.txt

# Get direct deps
direct_deps=$(cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "rust_registry") | .dependencies[] | select(.kind == "normal") | .name')

# Mark direct deps as depth 1
for dep in $direct_deps; do
    echo "depth:$dep:1" >> DEPENDENCIES.txt
done

# Use cargo tree to calculate depths (this is approximate)
cargo tree --format "{p}" | grep -v "rust_registry" | while read line; do
    if [[ $line =~ ^[[:space:]]*(.+)$ ]]; then
        spaces="${line%%[^[:space:]]*}"
        crate_info="${line#"${spaces}"}"
        crate_name=$(echo "$crate_info" | cut -d' ' -f1)
        depth=$((${#spaces} / 4 + 1))  # Approximate depth based on indentation
        if [ $depth -gt 1 ]; then
            echo "depth:$crate_name:$depth" >> DEPENDENCIES.txt
        fi
    fi
done

echo "" >> DEPENDENCIES.txt

# Generate vendor paths for sparse checkout
echo "# Vendor paths for sparse checkout" >> DEPENDENCIES.txt
echo "# Format: vendor:<crate_name>:<relative_path>" >> DEPENDENCIES.txt
if [ -d vendor ]; then
    find vendor -maxdepth 1 -type d | grep -v "^vendor$" | while read dir; do
        crate_name=$(basename "$dir")
        echo "vendor:$crate_name:libs/rust/registry/$dir" >> DEPENDENCIES.txt
    done
fi

echo "Generated DEPENDENCIES.txt with machine-parsable format"
echo "Usage examples:"
echo "  # Get all direct dependencies:"
echo "  grep '^direct:' DEPENDENCIES.txt"
echo "  # Get vendor paths for sparse checkout:"
echo "  grep '^vendor:' DEPENDENCIES.txt | cut -d: -f3"
echo "  # Get crates at depth 2:"
echo "  grep '^depth:.*:2$' DEPENDENCIES.txt"