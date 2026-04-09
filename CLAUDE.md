# Google Monorepo Simulation - Claude Context

## Project Overview
This is a simulated Google-style monorepo with a custom Bazel-inspired build system implemented in [Aether Build](https://github.com/paul-hammant/aetherBuild). It supports multiple languages (Java, Kotlin, Go, Rust, TypeScript) with dependency-aware compilation and testing.

## Build System
- **Aether Build**: Each module has a `.build.ae` file declaring deps and build actions
- **Runner**: `aeb` scans all `.build.ae`/`.tests.ae`/`.dist.ae`, topo-sorts, generates a single linked binary, runs it
- **One process**: In-memory visited-module map prevents redundant builds — no `.buildStepsDoneLastExecution` file
- **SDK**: `lib/build/module.ae` (symlinked from aetherBuild) provides `javac()`, `kotlinc()`, `go_build()`, `cargo_build()`, `tsc()`, `junit()`, `mocha()`, `shade()`, etc.

## Key Architecture Principles
- **Bazel-like dependency management**: Each module declares dependencies via `build.dep(b, "path")` in `.build.ae`
- **Hermetic builds**: All artifacts go to `target/` directory (never checked in)
- **Language-specific structures**: `{language}/components/` for libraries, `{language}/applications/` for executables
- **Test parallelism**: `{language}tests/` mirrors source structure

## Critical Build Files
- `.build.ae`: Compiles a single module and its dependencies
- `.tests.ae`: Compiles and runs tests for a module
- `.dist.ae`: Packages a module (e.g., fat jar)
- `shared-build-scripts/`: TypeScript helpers (tsconfig generation, npm path mapping) still used by the Aether TS SDK
- `libs/javascript/npm_vendored/`: Contains npm dependencies (use `package-map` for TypeScript imports)

## TypeScript Specifics
- **NO global.d.ts files**: Use targeted type declarations or npm_deps
- **NO generic include patterns**: Avoid `"include": ["*.ts"]` in tsconfig.json
- **Path mappings**: All dependencies must be explicitly mapped in generated base-tsconfig.json
- **npm_deps**: Use `build.npm_dep(b, "libs:javascript/{package-name}")` in `.build.ae`/`.tests.ae`

## FFI Integration Patterns
- **ffi-napi-v22**: Available in npm_vendored, access via `require('/absolute/path/to/ffi.js')`
- **Go shared libraries**: Build to `target/components/{name}/lib/lib{name}.so`
- **Absolute paths**: Use full paths for FFI library loading to avoid module resolution issues

## Common Gotchas
1. **Module resolution**: TypeScript in this monorepo doesn't use standard Node module resolution
2. **Dependency declaration**: Declare deps in `.build.ae` for compile-time, and again in `.tests.ae` if tests need them
3. **npm packages**: Must be added to `libs/javascript/npm_vendored/package-map` to be usable
4. **Timestamps**: Build system uses timestamp-based caching — delete `target/` to force clean builds
5. **Variable naming**: Don't use `module` as a variable name in `.ae` files (Aether codegen issue)

## Workflow Tips
- Build everything: `AETHER=/path/to/ae aeb`
- Clean builds: Remove `target/` directory
- Add npm deps: Update `package.json` in `libs/javascript/npm_vendored/` then run `npm install`
- Check dependencies: Look at existing `.build.ae` files for patterns
