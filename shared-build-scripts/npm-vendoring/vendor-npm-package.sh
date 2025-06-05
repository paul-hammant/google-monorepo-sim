#!/bin/bash
# vendor-npm-package.sh
set -eo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <root_dir> <package_name> <package_version_requested>" >&2
    exit 1
fi

root_dir="$1"
package_name="$2"
package_version_requested="$3" # The specific version we want to ensure is vendored

echo "Debug: Processing $package_name@$package_version_requested" >&2

vendor_dir_base="$root_dir/libs/javascript/npm_vendored"
# Package directory is now UNVERSIONED in the path
package_target_dir="$vendor_dir_base/$package_name"
metadata_file_name=".vendored_version"

# Idempotency and Version Check
if [ -d "$package_target_dir" ]; then
    echo "Debug: Package directory $package_target_dir already exists. Checking version..." >&2

    # First, determine where the metadata file *should* be by finding the content root.
    # This reuses the path determination logic but on an existing directory.
    current_content_root=""
    if [ -f "$package_target_dir/package/package.json" ]; then # Common case: package/package.json
        current_content_root="$package_target_dir/package"
    elif [ -f "$package_target_dir/package.json" ]; then # @types case: package.json at root of version dir
        current_content_root="$package_target_dir"
    else
        # Fallback: single subdirectory that might contain package.json or be an @types structure
        item_count_idem=$(ls -A "$package_target_dir" 2>/dev/null | wc -l)
        if [ "$item_count_idem" -eq 1 ]; then
            single_item_name_idem=$(ls -A "$package_target_dir")
            potential_path_idem="$package_target_dir/$single_item_name_idem"
            if [ -d "$potential_path_idem" ]; then
                 # If package.json or @types structure is confirmed, this is the root
                if [ -f "$potential_path_idem/package.json" ] || \
                   ( echo "$package_name" | grep -q '^@types/' && [ $(find "$potential_path_idem" -name '*.d.ts' -print -quit 2>/dev/null) ] ); then
                    current_content_root="$potential_path_idem"
                fi
            fi
        fi
    fi

    if [ -n "$current_content_root" ] && [ -f "$current_content_root/$metadata_file_name" ]; then
        vendored_version_found=$(cat "$current_content_root/$metadata_file_name")
        echo "Debug: Found vendored version $vendored_version_found, requested $package_version_requested." >&2
        if [ "$vendored_version_found" == "$package_version_requested" ]; then
            echo "Info: Correct version ($package_version_requested) of $package_name already vendored at $current_content_root." >&2
            echo "$current_content_root" # Output determined path
            exit 0
        else
            echo "Info: Different version ($vendored_version_found) of $package_name found. Requested $package_version_requested. Re-vendoring." >&2
            rm -rf "$package_target_dir" # Remove old version's directory
        fi
    else
        echo "Warning: Package directory $package_target_dir exists but version metadata missing or content root unclear. Cleaning up and re-fetching." >&2
        rm -rf "$package_target_dir"
    fi
fi

echo "Info: Vendoring $package_name@$package_version_requested into $package_target_dir" >&2
mkdir -p "$package_target_dir"
if [ $? -ne 0 ]; then
    echo "Critical Error: Failed to create package directory $package_target_dir" >&2
    exit 1
fi

temp_pack_dir=$(mktemp -d)
if [ $? -ne 0 ] || [ -z "$temp_pack_dir" ]; then
    echo "Critical Error: Failed to create temporary directory with mktemp." >&2
    exit 1
fi
echo "Debug: Temp pack dir: $temp_pack_dir" >&2
current_dir=$(pwd)
cd "$temp_pack_dir"

echo "Debug: Fetching package $package_name@$package_version_requested using npm pack..." >&2
npm_pack_full_output=$(npm pack "$package_name@$package_version_requested" 2>&1)
if [ $? -ne 0 ]; then
    echo "Critical Error: 'npm pack' failed for $package_name@$package_version_requested." >&2
    echo "npm pack output: $npm_pack_full_output" >&2
    cd "$current_dir"; rm -rf "$temp_pack_dir"; exit 1
fi
echo "Debug: npm pack successful." >&2
echo "npm pack output was: $npm_pack_full_output" >&2


# Determine tarball name
constructed_tarball_name_simple="${package_name}-${package_version_requested}.tgz"
safe_package_name_for_tarball=$(echo "$package_name" | sed 's|^@||' | sed 's|/|-|g')
constructed_tarball_name_scoped="${safe_package_name_for_tarball}-${package_version_requested}.tgz"
tarball_name=""

# Try npm pack output first, as it's most reliable if present
discovered_tarball_name_from_npm_output=$(echo "$npm_pack_full_output" | tail -n 1)
if [ -f "$discovered_tarball_name_from_npm_output" ]; then
    tarball_name="$discovered_tarball_name_from_npm_output"
    echo "Debug: Tarball name from npm pack output: $tarball_name" >&2
elif [ -f "$constructed_tarball_name_simple" ]; then # Non-scoped direct construction
    tarball_name="$constructed_tarball_name_simple"
    echo "Debug: Tarball name from simple construction: $tarball_name" >&2
elif [ -f "$constructed_tarball_name_scoped" ]; then # Scoped direct construction
    tarball_name="$constructed_tarball_name_scoped"
    echo "Debug: Tarball name from scoped construction: $tarball_name" >&2
else # Last resort: ls (less reliable)
    discovered_tarball_name_ls=$(ls *.tgz 2>/dev/null | head -n 1)
    if [ -f "$discovered_tarball_name_ls" ]; then
        tarball_name="$discovered_tarball_name_ls"
        echo "Debug: Discovered tarball name via ls: $tarball_name" >&2
    else
        echo "Critical Error: Could not find .tgz file for $package_name@$package_version_requested in $temp_pack_dir." >&2
        echo "Tried names based on npm output ('$discovered_tarball_name_from_npm_output'), simple construction ('$constructed_tarball_name_simple'), scoped construction ('$constructed_tarball_name_scoped'). ls found nothing." >&2
        echo "Directory listing of $temp_pack_dir:" >&2; ls -la; cd "$current_dir"; rm -rf "$temp_pack_dir"; exit 1
    fi
fi
echo "Debug: Using tarball: $tarball_name" >&2

echo "Debug: Extracting $tarball_name into $package_target_dir ..." >&2
# Ensure the target directory is empty before extraction (in case of prior partial extraction)
# This was handled by rm -rf above if versions didn't match or metadata was missing.
# If it's a first-time creation, mkdir -p already made it.
tar -xzf "$tarball_name" -C "$package_target_dir"
if [ $? -ne 0 ]; then
    echo "Critical Error: Failed to extract $tarball_name to $package_target_dir." >&2
    cd "$current_dir"; rm -rf "$temp_pack_dir"; rm -rf "$package_target_dir"; exit 1
fi
echo "Debug: Extraction successful." >&2

# Determine actual package content root within $package_target_dir
echo "Debug: Verifying actual package content root in $package_target_dir..." >&2
determined_content_root=""
if [ -f "$package_target_dir/package/package.json" ]; then # Common case: package/
    determined_content_root="$package_target_dir/package"
    echo "Debug: Found package.json in standard 'package/' subdirectory." >&2
elif [ -f "$package_target_dir/package.json" ]; then # @types case or flat packages
    determined_content_root="$package_target_dir"
    echo "Debug: Found package.json directly in target directory." >&2
else # Fallback: single subdirectory (e.g. tarball had <pkg-name>-<version>/... structure)
    item_count=$(ls -A "$package_target_dir" | wc -l)
    if [ "$item_count" -eq 1 ]; then
        single_item_name=$(ls -A "$package_target_dir")
        potential_path="$package_target_dir/$single_item_name"
        echo "Debug: Single item in target dir: $single_item_name. Potential path: $potential_path" >&2
        if [ -d "$potential_path" ]; then
            if [ -f "$potential_path/package.json" ]; then
                determined_content_root="$potential_path"
                echo "Debug: Found package.json in single subdirectory: $single_item_name" >&2
            elif echo "$package_name" | grep -q '^@types/' && [ $(find "$potential_path" -name '*.d.ts' -print -quit 2>/dev/null) ]; then
                determined_content_root="$potential_path"
                echo "Debug: Assuming single subdirectory '$single_item_name' is root for @types package (found .d.ts files)." >&2
            else
                echo "Error: Single item '$single_item_name' in $package_target_dir lacks package.json and isn't a clear @types structure." >&2
                # No exit here yet, will be caught by the final -z check
            fi
        else
             echo "Debug: Single item $single_item_name is not a directory." >&2
        fi
    else
        echo "Debug: Not a 'package/' structure, not a root package.json, and not a single item directory. Item count: $item_count" >&2
    fi
fi

if [ -z "$determined_content_root" ]; then
    echo "Critical Error: Could not determine package content root in $package_target_dir for $package_name@$package_version_requested." >&2
    echo "Listing contents of $package_target_dir:" >&2; ls -A "$package_target_dir" >&2
    find "$package_target_dir" -maxdepth 1 -type d -exec echo "Subdir:" {} \; -exec ls -A {} \; 2>/dev/null || true
    cd "$current_dir"; rm -rf "$temp_pack_dir"; rm -rf "$package_target_dir"; exit 1
fi

# Write metadata file
echo "$package_version_requested" > "$determined_content_root/$metadata_file_name"
if [ $? -ne 0 ]; then
    echo "Critical Error: Failed to write .vendored_version file to $determined_content_root." >&2
    cd "$current_dir"; rm -rf "$temp_pack_dir"; rm -rf "$package_target_dir"; exit 1
fi
echo "Debug: Wrote version $package_version_requested to $determined_content_root/$metadata_file_name" >&2


echo "Info: Actual vendored package path for $package_name@$package_version_requested determined to be: $determined_content_root" >&2
cd "$current_dir"
rm -rf "$temp_pack_dir"

echo "Info: Successfully vendored $package_name@$package_version_requested." >&2
echo "$determined_content_root" # IMPORTANT: This is the actual path output for the calling script
