# Monorepo Build System General Guide

This document outlines the structure and functionality of our monorepo's custom build system. While it uses Bash scripts, its design principles are heavily inspired by build systems like Bazel, which uses Starlark. The goal is to provide dependency-aware build process that supports multiple languages within a single repository. Hermetic, parallel and similar are out of scope.

## Core Concepts: A Bazel-like Approach in Bash

Instead of using a dedicated tool like Bazel, this repository employs a series of interconnected Bash scripts to define and manage the build process. Each component or application is treated as a "module" or "target," similar to Bazel's package structure. Indeed, you invoke a bash script (all . prefixed) at leaf locations within the tree.

### Directory Structure

The repository is organized by language and then by component type:

-   `java/`, `go/`, `rust/`, `typescript/`, `kotlin/`: Top-level directories for each language.
-   `components/`, `applications/`: **Subdirectories** for libraries and runnable programs.
-   `javatests/`, `typescripttests/`, etc.: Parallel source trees for tests. Tests for rust are missing presently, and Go tests are in the same go/ dir.
-   `libs/`: Contains third-party or pre-compiled libraries (vendored dependencies).
-   `shared-build-scripts/`: Houses common logic used by the individual build scripts.
-   `target/`: The output directory for all build artifacts, analogous to Bazel's `bazel-out`. This directory is not checked into source control.  If in doubt about clean/dirty or should not use cache, delete target/ ahead of a build script invocation.

### Build Scripts as Targets

Each module defines its build and test actions through specific shell scripts:

-   `.compile.sh`: This script is responsible for compiling the source code of a single module. It's the equivalent of `bazel build //path/to:target`.
-   `.tests.sh`: This script compiles and executes the tests for a module. It's the equivalent of `bazel test //path/to:target`.
-   `.dist.sh`: This script packages a module into a distributable format, such as a JAR file. It's analogous to Bazel's `pkg_` rules.

### Dependency Management

The heart of the Bazel-like behavior lies in how dependencies are managed:

1.  **Declaration**: Dependencies are declared inside each module's `.compile.sh` or `.tests.sh` script, typically in a shell array named `deps`. For example:
    ```bash
    deps=(
      "module:java/components/vowels"
      "module:rust/components/vowelbase"
    )
    ```
    There are other classes of deps too, like npm_deps=(...) for TypeScript modules.

2.  **Graph Traversal**: The `shared-build-scripts/invoke-all-compile-scripts-for-dependencies.sh` script is called by each module. It reads the `deps` array and recursively invokes the `.compile.sh` script for each dependency. This ensures that all dependencies are built before the module that depends on them, effectively traversing the build graph.

3.  **Artifact Passing**: Compiled artifacts and metadata are passed between modules via files in the `target/` directory.
    -   `jvmdeps`: A file containing the classpath needed by a Java/Kotlin module.
    -   `ldlibdeps`: A file containing the path to a native shared library (`.so`, `.dll`, `.dylib`).
    -   `tsdeps`: A file containing a list of TypeScript dependency paths for tsconfig generation.
    -   `npm_deps` as mentioned.

### Caching and Incrementality

To avoid unnecessary work, the build system uses a simple timestamp-based caching mechanism:

-   **Source Timestamps**: Before compiling, a script checks the latest modification timestamp of its source files.
-   **Artifact Timestamps**: This source timestamp is compared against a stored timestamp from the last successful build (e.g., in `target/module/.timestamp`).
-   **Conditional Compilation**: The module is only recompiled if its source files are newer than the last build artifact.

Additionally, the `.buildStepsDoneLastExecution` file at the root tracks which scripts have been executed within a single build invocation, preventing redundant execution if a module is a dependency of multiple other modules in the same build run.

## Comparison with Bazel

| Feature               | This Build System                                     | Bazel                                                 |
| --------------------- | ----------------------------------------------------- | ----------------------------------------------------- |
| **Configuration**     | Bash scripts (`.compile.sh`, etc.)                    | Starlark (`BUILD`, `.bzl` files)                      |
| **Dependency Graph**  | Declared in shell arrays (`deps=()`)                  | Declared in `deps` attributes of build rules          |
| **Caching**           | File timestamp comparison                             | Cryptographic hashing of file contents and build actions |
| **Execution**         | Direct shell execution in the user's environment      | Sandboxed, hermetic execution environment             |
| **Toolchain**         | Relies on tools present on the system path (`javac`, `go`, `tsc`) | Manages its own toolchains for reproducibility        |

## How to Use the Build System

You can build and test individual modules or entire sections of the repository by invoking the appropriate scripts.

-   **Build a single module**:
    ```bash
    ./java/components/vowels/.compile.sh
    ```

-   **Test a single (the same) module**:
    ```bash
    ./javatests/components/vowels/.tests.sh
    ```

-   **Build all Java components - rare use **:
    ```bash
    ./java/components/.all-compile.sh
    ```

-   **Build the entire repository - rate use **:
    ```bash
    ./.all-compile.sh
    ```

-   **Test the entire repository - rare use **:
    ```bash
    ./.all-tests.sh
    ```
# TSCONSRAINTS: Working with TypeScript components specifically.  

There is a packages.json file at `libs/javascript/npm_vendored/package.json` that `npm install` uses to make node_modules at that level. After that though, npm is not used for dependency. Other bash-centric ways of plucking dependencies from there, and making them available to `tsc` invocations via a base-tsconfig.json (generated into target/ by hash and jq) and one that inherits from that that's co-located with the module TS source.  The latter contains no path mappings, and relies on the paths set in the generated one. All deps pertinent to TS imports should be a path mapping in the relevant base-tsconfig.json. Nothing in any tsconfig should attempt to mount a general package root: they're always very specific. 