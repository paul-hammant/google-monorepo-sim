#!/bin/bash
# ensure-npm-dependencies.sh
set -eo pipefail # Exit on error, and on pipe failures

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <root_dir> <npm_dep_1> [<npm_dep_2> ...]" >&2
    echo "Example: $0 /path/to/root "assert@1.5.1" "@types/node@20.12.7"" >&2
    exit 1
fi

root_dir="$1"
shift # Remove root_dir from arguments, remaining are dependencies

script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
vendor_script="$script_dir/vendor-npm-package.sh"

if [ ! -x "$vendor_script" ]; then # Ensure core script is executable
    echo "Critical Error: Core vendoring script not found or not executable at $vendor_script" >&2
    exit 1
fi

final_vendored_paths=() # Array to store successfully determined paths

echo "Debug [ensure-npm]: Processing ${#} dependencies..." >&2

for dep_string in "$@"; do
    echo "Debug [ensure-npm]: Parsing dependency string: '$dep_string'" >&2
    # Regex handles optional @scope/ and captures name and version
    if [[ ! "$dep_string" =~ ^((@([^/]+)/)?([^@]+))@([^@]+)$ ]]; then
        echo "Warning [ensure-npm]: Could not parse dependency string '$dep_string'. Expected format: [@scope/]package_name@version. Skipping." >&2
        continue
    fi
    package_name="${BASH_REMATCH[1]}"    # Full name e.g., @types/node or assert
    package_version="${BASH_REMATCH[5]}" # Version part

    echo "Info [ensure-npm]: Processing dependency $package_name@$package_version..." >&2

    temp_stdout=$(mktemp)
    if [ $? -ne 0 ] || [ -z "$temp_stdout" ]; then echo "Critical Error [ensure-npm]: mktemp for stdout failed." >&2; exit 1; fi
    temp_stderr=$(mktemp)
    if [ $? -ne 0 ] || [ -z "$temp_stderr" ]; then echo "Critical Error [ensure-npm]: mktemp for stderr failed." >&2; rm -f "$temp_stdout"; exit 1; fi

    vendor_script_exit_code=0
    # Call vendor_script, redirecting its stdout and stderr to temp files
    if ! "$vendor_script" "$root_dir" "$package_name" "$package_version" > "$temp_stdout" 2> "$temp_stderr"; then
        vendor_script_exit_code=$? # Capture the exit code
        echo "Error [ensure-npm]: Vendoring script FAILED for $package_name@$package_version (Exit Code: $vendor_script_exit_code)." >&2
    fi

    # Always print stderr from vendor_script for debugging visibility
    if [ -s "$temp_stderr" ]; then # Check if stderr temp file is not empty
        echo "--- Vendoring Script STDERR for $package_name@$package_version ---" >&2
        cat "$temp_stderr" >&2
        echo "--- End Vendoring Script STDERR ---" >&2
    else
        echo "Debug [ensure-npm]: Vendoring script for $package_name@$package_version produced no STDERR." >&2
    fi

    if [ $vendor_script_exit_code -ne 0 ]; then
        # If vendor_script exited with an error, ensure-npm-dependencies also exits with error
        rm -f "$temp_stdout" "$temp_stderr"
        exit 1 # Propagate failure
    fi

    # If vendor_script succeeded (exit code 0)
    actual_path=$(cat "$temp_stdout")
    if [ -z "$actual_path" ]; then
        echo "Error [ensure-npm]: Vendoring script for $package_name@$package_version succeeded but produced no path (empty stdout)." >&2
        # This case should ideally be caught by vendor_script itself if it can't determine a path.
        rm -f "$temp_stdout" "$temp_stderr"
        exit 1
    fi

    echo "Info [ensure-npm]: Successfully processed $package_name@$package_version. Content at: $actual_path" >&2
    final_vendored_paths+=("$actual_path")

    rm -f "$temp_stdout" "$temp_stderr"
done

# Output all successfully determined paths, one per line, to STDOUT
# This is captured by the calling .tests.sh script
if [ ${#final_vendored_paths[@]} -gt 0 ]; then
    printf "%s\n" "${final_vendored_paths[@]}"
fi

echo "Info [ensure-npm]: All specified NPM dependencies processed." >&2
