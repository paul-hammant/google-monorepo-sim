#!/bin/bash
set -eo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <root_dir> <package_name> <package_version>"
    exit 1
fi

root_dir="$1"
package_name="$2"
package_version="$3"

# Define the target directory for the vendored package
# e.g., $root/libs/javascript/npm_vendored/assert/1.5.1/
vendor_dir_base="$root_dir/libs/javascript/npm_vendored"
package_vendor_dir="$vendor_dir_base/$package_name/$package_version"
extracted_package_path="$package_vendor_dir/package" # npm pack extracts into a 'package' subdirectory

# Idempotency check: if the extracted package path already exists, skip
if [ -d "$extracted_package_path" ]; then
    echo "Package $package_name@$package_version already vendored at $extracted_package_path. Skipping."
    echo "$extracted_package_path" # Output the path for the calling script
    exit 0
fi

echo "Vendoring $package_name@$package_version..."

# Ensure the base vendor directory and specific package version directory exist
mkdir -p "$package_vendor_dir"

# Create a temporary directory for npm pack
temp_pack_dir=$(mktemp -d)
echo "Temporary pack directory: $temp_pack_dir"

# Navigate to temp dir to run npm pack (keeps current dir clean)
current_dir=$(pwd)
cd "$temp_pack_dir"

echo "Fetching package $package_name@$package_version using npm pack..."
# Specify a registry to ensure consistent results if needed, otherwise defaults to public npm
npm_pack_output=$(npm pack "$package_name@$package_version" 2>&1)
if [ $? -ne 0 ]; then
    echo "Error: npm pack failed for $package_name@$package_version"
    echo "Output: $npm_pack_output"
    # Cleanup temp dir before exiting
    cd "$current_dir"
    rm -rf "$temp_pack_dir"
    exit 1
fi

# npm pack creates a tarball, e.g., assert-1.5.1.tgz (or scoped like @types-assert-1.5.1.tgz)
# We need to find the tarball name. It should be the only .tgz file.
# Handle potential scoped package names in tarball (e.g. @foo-bar-1.0.0.tgz -> foo-bar-1.0.0.tgz)
# For simplicity, assuming non-scoped names first, like `assert-1.5.1.tgz`
# A more robust way would be to parse npm pack output or handle various naming conventions.
# For `assert`, the tarball is `assert-1.5.1.tgz`.
# If package_name is "assert" and version is "1.5.1", tarball_name is "assert-1.5.1.tgz"
# Let's try to construct it. This might need adjustment for scoped packages.
tarball_name="${package_name}-${package_version}.tgz"
if [ ! -f "$tarball_name" ]; then
    # Attempt to find it if the simple construction failed (e.g. due to @scope/pkgname)
    # This will pick the first tgz file. If npm pack produces multiple, this is not robust.
    discovered_tarball_name=$(ls *.tgz | head -n 1)
    if [ -f "$discovered_tarball_name" ]; then
        tarball_name="$discovered_tarball_name"
        echo "Discovered tarball name: $tarball_name"
    else
        echo "Error: Could not find .tgz file for $package_name@$package_version in $temp_pack_dir"
        echo "npm pack output: $npm_pack_output"
        ls -la "$temp_pack_dir"
        cd "$current_dir"
        rm -rf "$temp_pack_dir"
        exit 1
    fi
fi

echo "Extracting $tarball_name into $package_vendor_dir ..."
# tar extracts into a subdirectory named 'package' by default.
# We want to extract into our specific versioned directory, maintaining the 'package' subfolder.
tar -xzf "$tarball_name" -C "$package_vendor_dir"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract $tarball_name to $package_vendor_dir"
    # Cleanup temp dir and potentially the partially extracted dir
    cd "$current_dir"
    rm -rf "$temp_pack_dir"
    rm -rf "$package_vendor_dir/package" # remove potentially corrupted extraction
    exit 1
fi

# Verify extraction
if [ ! -d "$extracted_package_path" ]; then
    echo "Error: Expected directory $extracted_package_path not found after extraction."
    ls -la "$package_vendor_dir"
    cd "$current_dir"
    rm -rf "$temp_pack_dir"
    exit 1
fi

echo "Successfully vendored $package_name@$package_version into $extracted_package_path"

# Go back to original directory and clean up temp dir
cd "$current_dir"
rm -rf "$temp_pack_dir"

# Output the path to the extracted package root
echo "$extracted_package_path"
