# Rust Registry

This directory contains all vendored Rust dependencies for the monorepo, providing hermetic builds without external network dependencies.

## Structure

- `Cargo.toml` - Defines direct dependencies and their versions
- `vendor/` - Vendored source code of all dependencies (direct + transitive)
- `target/release/` - Pre-compiled `.rlib` files for fast builds
- `DEPENDENCY-ANALYSIS.md` - Detailed dependency graph and analysis
- `generate-dependency-graph.sh` - Script to analyze dependency tree
- `update-registry.sh` - Script to update registry after Cargo.toml changes

## Adding Dependencies

1. Edit `Cargo.toml` to add new direct dependencies
2. Run `./update-registry.sh` to vendor and build
3. Commit vendor/, target/, and DEPENDENCY-ANALYSIS.md

## Understanding Dependencies

- **Direct dependencies**: Listed in Cargo.toml, required by our modules
- **Transitive dependencies**: Pulled in automatically by direct dependencies
- **Build dependencies**: Only needed during compilation, not at runtime

See `DEPENDENCY-ANALYSIS.md` for the complete dependency graph.

## Current Status

- **1 direct dependency**: jni (for Java interop)
- **22 total dependencies** (including 21 transitive)
- **Key transitive chains**:
  - jni → cesu8, combine, jni-sys, log, thiserror
  - thiserror → thiserror-impl → proc-macro2, quote, syn
  - combine → bytes, memchr

## Module Usage

Individual Rust modules reference dependencies like:

```toml
[dependencies]
jni = { path = "../../../libs/rust/registry/vendor/jni" }
```

The version is controlled entirely by this registry, not by individual modules.