#!/bin/bash
set -eo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <root_dir> <npm_dep_1> [<npm_dep_2> ...]"
    echo "Example: $0 /path/to/root "assert@1.5.1" "anotherpackage@1.0.0""
    exit 1
fi

root_dir="$1"
shift # Remove root_dir from arguments, remaining are dependencies

# Get the directory where vendor-npm-package.sh is located
# This makes the script callable from anywhere as long as vendor-npm-package.sh is in the same dir
script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
vendor_script="$script_dir/vendor-npm-package.sh"

if [ ! -f "$vendor_script" ]; then
    echo "Error: Core vendoring script not found at $vendor_script"
    exit 1
fi

vendored_package_paths=()

for dep_string in "$@"; do
    # Parse package_name@package_version
    # This simple parsing works for "name@version".
    # It might need to be more robust for versions with '-', or scoped packages like '@scope/name@version'.
    # For "assert@1.5.1", package_name=assert, package_version=1.5.1
    if [[ ! "$dep_string" =~ ^([^@]+)@([^@]+)$ ]]; then
        echo "Warning: Could not parse dependency string '$dep_string'. Expected format: package_name@version. Skipping."
        continue
    fi
    package_name="${BASH_REMATCH[1]}"
    package_version="${BASH_REMATCH[2]}"

    echo "Processing dependency: $package_name@$package_version"

    # Call the vendor-npm-package.sh script and capture its output (the path)
    # If vendor_script fails, pipefail will ensure this script also fails.
    output_path=$("$vendor_script" "$root_dir" "$package_name" "$package_version")

    if [ -n "$output_path" ]; then
        # The vendor_script outputs multiple lines, the last one is the path.
        # Let's make sure we only take the last line.
        actual_path=$(echo "$output_path" | tail -n 1)
        echo "Successfully processed $package_name@$package_version, vendored at: $actual_path"
        vendored_package_paths+=("$actual_path")
    else
        echo "Warning: No output path received from vendoring $package_name@$package_version. Check logs from vendor-npm-package.sh."
    fi
done

# Print all collected vendored package paths, one per line
# This output will be captured by the calling .tests.sh script
for path in "${vendored_package_paths[@]}"; do
    echo "$path"
done
