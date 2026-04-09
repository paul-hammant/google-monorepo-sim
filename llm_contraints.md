# Monorepo Build System General Guide

This document outlines the structure and functionality of our monorepo's custom build system. It uses [Aether Build](https://github.com/paul-hammant/aetherBuild), a polyglot build system written in the [Aether](https://github.com/paul-hammant/aether) language, inspired by Bazel and Gradle. Each module declares its dependencies and build actions in a `.build.ae` file; a runner generates a single linked native binary and executes everything in one process.

## Core Concepts

### Directory Structure

The repository is organized by language and then by component type:

-   `java/`, `go/`, `rust/`, `typescript/`, `kotlin/`: Top-level directories for each language.
-   `components/`, `applications/`: Subdirectories for libraries and runnable programs.
-   `javatests/`, `typescripttests/`, `kotlintests/`: Parallel source trees for tests. Go tests are co-located with source.
-   `libs/`: Contains third-party or pre-compiled libraries (vendored dependencies).
-   `shared-build-scripts/`: TypeScript helper scripts (tsconfig generation, npm path mapping).
-   `target/`: The output directory for all build artifacts. Not checked into source control. Delete to force clean builds.

### Build Files

Each module defines its build and test actions through Aether scripts:

-   `.build.ae`: Compiles the source code of a single module. Equivalent of `bazel build //path/to:target`.
-   `.tests.ae`: Compiles and executes tests for a module. Equivalent of `bazel test //path/to:target`.
-   `.dist.ae`: Packages a module into a distributable format (e.g., fat jar).

### Dependency Management

1.  **Declaration**: Dependencies are declared inside each module's `.build.ae` or `.tests.ae`, one per line:
    ```aether
    build.dep(b, "java/components/vowels")
    build.dep(b, "rust/components/vowelbase")
    ```
    Other dep types: `build.lib(b, ...)` for vendored binaries, `build.npm_dep(b, ...)` for npm packages, `build.cargo_dep(b, ...)` for Cargo crates.

2.  **Graph Extraction**: The runner (`aeb`) greps all `.build.ae` files for `dep(` lines to build the dependency DAG — no compilation needed. Same contract as Bazel's BUILD files.

3.  **Linked Execution**: The runner generates a single `.ae` file with one function per module, compiles it to a native binary, and executes it. Each module function calls its deps directly. An in-memory visited-module map prevents redundant builds.

4.  **Artifact Passing**: Compiled artifacts and metadata are passed between modules via files in `target/`:
    -   `jvm_classpath_deps_including_transitive`: Newline-separated classpath entries for Java/Kotlin.
    -   `ldlibdeps`: Paths to native shared libraries (`.so`).
    -   `shared_library_deps_including_transitive`: Transitive native library deps.
    -   `typescript_module_deps_including_transitive`: Paths to compiled JS directories.
    -   `npm_deps_including_transitive`: Vendored npm package references.

### Caching and Incrementality

-   **Source Timestamps**: Before compiling, the SDK checks the latest modification timestamp of source files.
-   **Artifact Timestamps**: Compared against a stored `.timestamp` from the last successful build.
-   **Conditional Compilation**: The module is only recompiled if source files are newer. Tests always run (only compilation is skipped).

### Comparison with Bazel

| Feature               | Aether Build                                          | Bazel                                                 |
| --------------------- | ----------------------------------------------------- | ----------------------------------------------------- |
| **Configuration**     | Aether (`.build.ae`, `.tests.ae`)                     | Starlark (`BUILD`, `.bzl` files)                      |
| **Dependency Graph**  | `build.dep(b, "path")` — greppable                   | `deps` attributes in build rules                      |
| **Execution**         | Single linked binary, in-process visited map          | Sandboxed, hermetic execution environment             |
| **Caching**           | File timestamp comparison                             | Cryptographic hashing of contents and actions          |
| **Toolchain**         | Relies on tools on system path                        | Manages its own toolchains                            |
| **Polyglot**          | 5 languages: Java, Kotlin, Go, Rust, TypeScript       | Any language via rules                                |

## How to Use the Build System

```bash
# Build and test everything
AETHER=/path/to/ae aeb

# Output: 18 compile + 2 dist + 17 test
```

# Working with TypeScript components specifically

There is a `package.json` file at `libs/javascript/npm_vendored/package.json` that `npm install` uses to make `node_modules` at that level (not root of repo). After that, npm is not used for dependency resolution. Instead, the Aether TypeScript SDK calls bash helper scripts that generate `base-tsconfig.json` files (via `jq`) with explicit path mappings for each dependency. Each module's `tsconfig.json` extends the generated one. All deps pertinent to TS imports should be a path mapping in the relevant `base-tsconfig.json`. Nothing in any tsconfig should attempt to mount a general package root: they're always very specific. Do NOT rely on standard Node module resolution for vendored packages. The test for a dep is whether it is listed in `package-map` or not.

## Rules for future LLM work

1. Do not add `"include": ["*.ts"]` to any tsconfig.json, that is not needed.
2. Do not add `"include": [/any/path/to/global.d.ts"]` to any tsconfig.json — it is the wrong solution for a bazel-style monorepo like this.
3. Do not create a "global.d.ts" anywhere in the source tree.
4. Do not create *.d.ts files in the source tree for things that @types/* from npm-land should define.
5. `npm_deps` in `.build.ae`/`.tests.ae` is the right place to declare npm dependencies.
6. Do not use `module` as a variable name in `.ae` files (Aether codegen issue).
7. Dependencies must be declared in `.build.ae` files with `build.dep(b, "path")` — one per line, string literal, greppable.
