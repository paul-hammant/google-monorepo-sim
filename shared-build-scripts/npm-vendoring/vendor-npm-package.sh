#!/bin/bash
set -eo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <root_dir> <package_name> <package_version>"
    exit 1
fi

root_dir="$1"
package_name="$2"
package_version="$3"

vendor_dir_base="$root_dir/libs/javascript/npm_vendored"
package_vendor_dir="$vendor_dir_base/$package_name/$package_version"
# REMOVED: old extracted_package_path="$package_vendor_dir/package"

# Idempotency check refined:
determined_idempotent_path=""
if [ -d "$package_vendor_dir" ]; then # Check if the versioned directory itself exists first
    if [ -f "$package_vendor_dir/package/package.json" ]; then
        determined_idempotent_path="$package_vendor_dir/package"
    elif [ -f "$package_vendor_dir/package.json" ]; then
        determined_idempotent_path="$package_vendor_dir"
    else
        # Fallback for already extracted single-folder structures
        item_count_idem=$(ls -A "$package_vendor_dir" 2>/dev/null | wc -l)
        if [ "$item_count_idem" -eq 1 ]; then
            single_item_name_idem=$(ls -A "$package_vendor_dir")
            potential_path_idem="$package_vendor_dir/$single_item_name_idem"
            if [ -d "$potential_path_idem" ] && [ -f "$potential_path_idem/package.json" ]; then
                 determined_idempotent_path="$potential_path_idem"
            elif [ -d "$potential_path_idem" ]; then # Check for @types structure
                 is_likely_types_package_idem=0
                 if echo "$package_name" | grep -q '^@types/'; then is_likely_types_package_idem=1; fi
                 if [ "$is_likely_types_package_idem" -eq 1 ] && ([ -f "$potential_path_idem/index.d.ts" ] || [ $(find "$potential_path_idem" -name '*.d.ts' -print -quit 2>/dev/null) ]); then
                     determined_idempotent_path="$potential_path_idem"
                 fi
            fi
        fi
    fi
fi

if [ -n "$determined_idempotent_path" ]; then
    echo "Package $package_name@$package_version already vendored. Content found at $determined_idempotent_path. Skipping download."
    echo "$determined_idempotent_path"
    exit 0
else
    if [ -d "$package_vendor_dir" ]; then
      echo "Package directory $package_vendor_dir exists but content root is unclear or incomplete. Proceeding with fetch."
      # It might be a failed previous attempt, so clean it up.
      rm -rf "$package_vendor_dir"
    fi
fi

echo "Vendoring $package_name@$package_version..."
mkdir -p "$package_vendor_dir"
temp_pack_dir=$(mktemp -d)
echo "Temporary pack directory: $temp_pack_dir"
current_dir=$(pwd)
cd "$temp_pack_dir"

echo "Fetching package $package_name@$package_version using npm pack..."
npm_pack_output=$(npm pack "$package_name@$package_version" 2>&1)
if [ $? -ne 0 ]; then
    echo "Error: npm pack failed for $package_name@$package_version"
    echo "Output: $npm_pack_output"
    cd "$current_dir"; rm -rf "$temp_pack_dir"; exit 1
fi

# Try to determine tarball name (npm pack output is not reliable for scripting)
# For @foo/bar, npm pack creates foo-bar.tgz or @foo-bar.tgz depending on version/npm internal choices
# For non-scoped, it's usually name-version.tgz
# Example: @types/node -> types-node-20.12.7.tgz
# Example: assert -> assert-1.5.1.tgz
constructed_tarball_name_simple="${package_name}-${package_version}.tgz" # Works for non-scoped like assert
safe_package_name_for_tarball=$(echo "$package_name" | sed 's|^@||' | sed 's|/|-|g')
constructed_tarball_name_scoped="${safe_package_name_for_tarball}-${package_version}.tgz" # Works for @types/node

tarball_name=""
if [ -f "$constructed_tarball_name_simple" ]; then
    tarball_name="$constructed_tarball_name_simple"
elif [ -f "$constructed_tarball_name_scoped" ]; then
    tarball_name="$constructed_tarball_name_scoped"
else
    discovered_tarball_name=$(ls *.tgz 2>/dev/null | head -n 1)
    if [ -f "$discovered_tarball_name" ]; then
        tarball_name="$discovered_tarball_name"
        echo "Discovered tarball name via ls: $tarball_name"
    else
        echo "Error: Could not find .tgz file for $package_name@$package_version in $temp_pack_dir (tried $constructed_tarball_name_simple, $constructed_tarball_name_scoped, and ls)"
        echo "npm pack output: $npm_pack_output"; ls -la "$temp_pack_dir"; cd "$current_dir"; rm -rf "$temp_pack_dir"; exit 1
    fi
fi

echo "Extracting $tarball_name into $package_vendor_dir ..."
tar -xzf "$tarball_name" -C "$package_vendor_dir"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract $tarball_name to $package_vendor_dir"
    cd "$current_dir"; rm -rf "$temp_pack_dir"; rm -rf "$package_vendor_dir"; exit 1
fi

# --- NEW LOGIC TO DETERMINE EXTRACTED PATH ---
echo "Verifying actual package content root..."
determined_extracted_path=""

# Case 1: Check for <package_vendor_dir>/package/package.json (common structure from `npm pack` then `tar xzf`)
# Tarballs from `npm pack` typically create a `package/` directory when extracted.
if [ -f "$package_vendor_dir/package/package.json" ]; then
  determined_extracted_path="$package_vendor_dir/package"
  echo "Found package.json in standard 'package/' subdirectory."
# Case 2: Check for <package_vendor_dir>/package.json (e.g. if tarball root is the package root, like @types)
elif [ -f "$package_vendor_dir/package.json" ]; then
  determined_extracted_path="$package_vendor_dir"
  echo "Found package.json directly in versioned directory (e.g., common for @types packages)."
else
  # Fallback: if no package.json, but there's only one directory in package_vendor_dir, assume that's the root.
  # This handles cases where tarball extracts to e.g. <pkgname>-<version>/
  # Count items in package_vendor_dir (excluding dotfiles like . or .. if any appear)
  item_count=$(ls -A "$package_vendor_dir" | wc -l)
  if [ "$item_count" -eq 1 ]; then
    single_item_name=$(ls -A "$package_vendor_dir")
    potential_path="$package_vendor_dir/$single_item_name"
    if [ -d "$potential_path" ] && [ -f "$potential_path/package.json" ]; then
        determined_extracted_path="$potential_path"
        echo "Found package.json in single subdirectory: $single_item_name"
    elif [ -d "$potential_path" ]; then
        is_likely_types_package=0
        if echo "$package_name" | grep -q '^@types/'; then is_likely_types_package=1; fi

        # Check for any .d.ts file, not just index.d.ts, using find -quit for efficiency
        has_d_ts_files=0
        if [ $(find "$potential_path" -name '*.d.ts' -print -quit 2>/dev/null) ]; then has_d_ts_files=1; fi

        if [ "$is_likely_types_package" -eq 1 ] && [ "$has_d_ts_files" -eq 1 ]; then
            determined_extracted_path="$potential_path"
            echo "Assuming single subdirectory '$single_item_name' is the root for @types package (found .d.ts files)."
        else
             echo "Warning: Single item '$single_item_name' in version_dir does not contain package.json and is not a clear @types structure." >&2
             # Even if not ideal, if it's the only thing, it's our best guess.
             determined_extracted_path="$potential_path"
             echo "Proceeding with single subdirectory '$single_item_name' as package root despite unclear structure."
        fi
    fi
  fi

  if [ -z "$determined_extracted_path" ]; then
    echo "Error: Could not determine package root. No known structure found after extraction." >&2
    echo "Listing contents of $package_vendor_dir:" >&2
    ls -A "$package_vendor_dir" >&2
    # List subdirectories if any, one level deep
    find "$package_vendor_dir" -maxdepth 1 -type d -exec echo "Subdir:" {} \; -exec ls -A {} \; 2>/dev/null || true
    cd "$current_dir"; rm -rf "$temp_pack_dir"; rm -rf "$package_vendor_dir"; exit 1
  fi
fi
echo "Actual vendored package path determined to be: $determined_extracted_path"
# --- END OF NEW LOGIC ---

echo "Successfully vendored $package_name@$package_version."

cd "$current_dir"
rm -rf "$temp_pack_dir"

echo "$determined_extracted_path" # Output the determined path
