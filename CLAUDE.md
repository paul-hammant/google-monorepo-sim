# Google Monorepo Simulation - Claude Context

## Project Overview
This is a simulated Google-style monorepo with a custom Bazel-inspired build system implemented in Bash. It supports multiple languages (TypeScript, Go, Rust, Java) with dependency-aware compilation and testing.

## Key Architecture Principles
- **Bazel-like dependency management**: Each module declares dependencies in `.compile.sh` and `.tests.sh` scripts
- **Hermetic builds**: All artifacts go to `target/` directory (never checked in)
- **Language-specific structures**: `{language}/components/` for libraries, `{language}/applications/` for executables
- **Test parallelism**: `{language}tests/` mirrors source structure

## Critical Build Files
- `.compile.sh`: Compiles a single module and its dependencies
- `.tests.sh`: Compiles and runs tests for a module
- `shared-build-scripts/`: Common build logic shared across all modules
- `libs/javascript/npm_vendored/`: Contains npm dependencies (use `package-map` for TypeScript imports)

## TypeScript Specifics
- **NO global.d.ts files**: Use targeted type declarations or npm_deps
- **NO generic include patterns**: Avoid `"include": ["*.ts"]` in tsconfig.json
- **Path mappings**: All dependencies must be explicitly mapped in generated base-tsconfig.json
- **npm_deps**: Use format `"libs:javascript/{package-name}"` in build scripts

## FFI Integration Patterns
- **ffi-napi-v22**: Available in npm_vendored, access via `require('/absolute/path/to/ffi.js')`
- **Go shared libraries**: Build to `target/components/{name}/lib/lib{name}.so`
- **Absolute paths**: Use full paths for FFI library loading to avoid module resolution issues
- **Type declarations**: Create minimal `.d.ts` files for require() and FFI modules when needed

## Common Gotchas
1. **Module resolution**: TypeScript in this monorepo doesn't use standard Node module resolution
2. **Dependency declaration**: Always declare deps in BOTH .compile.sh AND .tests.sh if tests need them
3. **npm packages**: Must be added to `libs/javascript/npm_vendored/package-map` to be usable
4. **Timestamps**: Build system uses timestamp-based caching - delete `target/` to force clean builds

## Workflow Tips
- Run individual tests: `./typescripttests/path/to/module/.tests.sh`
- Clean builds: Remove `target/` directory
- Add npm deps: Update `package.json` in `libs/javascript/npm_vendored/` then run `npm install`
- Check dependencies: Look at existing modules for patterns before creating new ones

## Recent Successful Patterns
- FFI integration: `typescript/applications/mmmm/MmmmU0021.ts` successfully uses ffi-napi-v22 to call Go functions
- npm dependency setup: Both compile and test scripts need npm_deps arrays for proper path mapping
- Mixed output: Can combine Go stdout (from FFI calls) with JavaScript console.log for tests