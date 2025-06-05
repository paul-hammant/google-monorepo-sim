#!/bin/bash
set -eo pipefail

ROOT_DIR="$1"
MODULE_TARGET_DIR="$2"
BASE_TARGET_DIR="$3"
TS_DEPS_FILE="$4"
# FFI_NAPI_DIR is optional
FFI_NAPI_DIR="${5:-}" # Default to empty if not provided

{
  echo "$MODULE_TARGET_DIR"
  echo "$BASE_TARGET_DIR"
  if [[ -f "$TS_DEPS_FILE" && -s "$TS_DEPS_FILE" ]]; then
    # Prepend base_target_dir to each dependency path from the tsdeps file
    # Note: paths in tsdeps are relative to $ROOT_DIR/target/
    sed "s|^|$BASE_TARGET_DIR/|" "$TS_DEPS_FILE"
  fi
  if [[ -n "$FFI_NAPI_DIR" ]]; then
    echo "$FFI_NAPI_DIR"
  fi
} | sort -u | paste -sd ":" -
