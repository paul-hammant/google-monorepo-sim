=== Rust Registry Dependency Analysis ===
Generated on: Mon Jun  9 11:01:45 AM BST 2025

## Full Dependency Tree
```
rust_registry v1.0.0 (/home/paul/scm/google-monorepo-sim/libs/rust/registry)
└── jni v0.20.0
    ├── cesu8 v1.1.0
    ├── combine v4.6.7
    │   ├── bytes v1.10.1
    │   └── memchr v2.7.4
    ├── jni-sys v0.3.0
    ├── log v0.4.27
    └── thiserror v1.0.69
        └── thiserror-impl v1.0.69 (proc-macro)
            ├── proc-macro2 v1.0.95
            │   └── unicode-ident v1.0.18
            ├── quote v1.0.40
            │   └── proc-macro2 v1.0.95 (*)
            └── syn v2.0.101
                ├── proc-macro2 v1.0.95 (*)
                ├── quote v1.0.40 (*)
                └── unicode-ident v1.0.18
    [build-dependencies]
    └── walkdir v2.5.0
        └── same-file v1.0.6
```

## Direct Dependencies (from our Cargo.toml)
These are the packages we explicitly depend on:

- jni = "0.20.0"

## All Dependencies (including transitive)
These are all packages that get pulled in:

- bytes v1.10.1
- cesu8 v1.1.0
- combine v4.6.7
- jni-sys v0.3.0
- jni v0.20.0
- log v0.4.27
- memchr v2.7.4
- proc-macro2 v1.0.95
- quote v1.0.40
- same-file v1.0.6
- syn v2.0.101
- thiserror-impl v1.0.69
- thiserror v1.0.69
- unicode-ident v1.0.18
- walkdir v2.5.0
- winapi-util v0.1.9
- windows_aarch64_gnullvm v0.52.6
- windows_aarch64_msvc v0.52.6
- windows_i686_gnullvm v0.52.6
- windows_i686_gnu v0.52.6
- windows_i686_msvc v0.52.6
- windows-sys v0.59.0
- windows-targets v0.52.6
- windows_x86_64_gnullvm v0.52.6
- windows_x86_64_gnu v0.52.6
- windows_x86_64_msvc v0.52.6

## Dependency Categories

### Direct Dependencies (1 level)
These are explicitly listed in our Cargo.toml:
- jni v0.20.0

### Direct Dependencies of jni (2nd level)
These are immediate dependencies of jni:
- cesu8 v1.1.0
- combine v4.6.7
- jni-sys v0.3.0
- log v0.4.27
- thiserror v1.0.69
- walkdir v2.5.0

### Build Dependencies
These are needed only at build time:
- walkdir v2.5.0
- same-file v1.0.6

## Statistics
- Total dependencies: 20
- Direct dependencies: 1
- Transitive dependencies: 19

## Recommended Actions
1. Review direct dependencies to ensure they're all necessary
2. Consider if any transitive dependencies could be replaced with lighter alternatives
3. Update this analysis after any Cargo.toml changes by running: ./generate-dependency-graph.sh > DEPENDENCY-ANALYSIS.md
