# google-monorepo-sim

This repo goes hand in hand with my book: [Trunk-Based Development And Branch By Abstraction ](https://tbd-book.com/) and a [short video talking about it](https://tbd-book.com/gmr-vid) 

It purports to show a monorepo in the style that Google use internally - with a novel expand/contract feature that maps to Git's sparse-checkout.

Two branches in this repo show simulations of monorepo concepts with some source files in common, but not all.

2. Directed Acyclic Graph Modular Monorepo - [trunk](https://github.com/paul-hammant/google-monorepo-sim/tree/trunk)
1. Depth-First Recursive Modular Monorepo - [depth-first_recursive_modular_monorepo](https://github.com/paul-hammant/google-monorepo-sim/tree/depth-first_recursive_modular_monorepo)

Specifically, the Java, and Rust sources are identical in both, but in different directories. 
The build files are different. There's newer Kotlin modules in trunk, that are not duplicated 
in the depth-first_recursive_modular_monorepo branch 

# Build System

## Aether Build (current)

The monorepo is built using [Aether Build](https://github.com/paul-hammant/aetherBuild),
a polyglot build system written in [Aether](https://github.com/paul-hammant/aether).
Each module has a `.build.ae` file declaring its dependencies and build action.
The entrypoint is `aeb(cap)` — the build receives a capability handle `cap`
from the trusted aeb host (the same handle that backs `--sandbox` runtime
containment); a build file never constructs its own authority, it only
receives it:

```aether
import build

aeb(cap) {
    b = build.start()
    build.dep(b, "rust/components/vowelbase")
    build.javac(b)
}
```

(The legacy `main()` spelling still works — aeb lowers both to the same
context-receiving entrypoint — but `aeb(cap)` is the convention this repo
demonstrates.)

A single `aeb --scan '<glob>'` invocation walks the tree for every `.ae` node whose
basename matches the glob, topologically sorts the dependency graph, generates one linked
native binary, and executes everything in a single process with an in-memory visited-module
map. (Current aeb requires a named target or an explicit `--scan` glob — a bare `aeb` with
no arguments no longer builds the whole tree.)

### Prerequisites

* [Aether](https://github.com/paul-hammant/aether) compiler (`ae`)
* General unix tools: `sudo apt install moreutils jq build-essential`
* JDK 21 or above. [Linux instructions](https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/generic-linux-install.html)
* Rust and Cargo. [Linux/Mac instructions](https://doc.rust-lang.org/cargo/getting-started/installation.html)
* Kotlin: `sudo apt install kotlin`
* Go 1.24+ (see below)
* TypeScript: Node v22+, `sudo npm install -g typescript`

Also, "Go" via this oneliner as sdk-man doesn't have it:

``` 
sudo rm -rf /usr/local/go && \
curl -o go.tar.gz https://dl.google.com/go/go1.24.3.linux-amd64.tar.gz && \
sudo tar -C /usr/local -xzf go.tar.gz && \
rm go.tar.gz && \
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile && \
exec $SHELL -l && \
go version
```

### Building everything

```bash
# compile every module (the .build.ae DAG)
AETHER=/path/to/ae aeb --scan '.build.ae'

# or build/run a single leaf and its deps by naming it
AETHER=/path/to/ae aeb java/applications/monorepos_rule/.dist.ae
AETHER=/path/to/ae aeb typescripttests/components/explanation/.tests.ae
```

Output:
```
aeb: 18 compile + 2 dist + 17 test
go/components/nasal: compiling Go prod & test code
rust/components/vowelbase: compiling prod code
java/components/vowelbase: compiling prod code
...
dist:java/applications/monorepos_rule: packaging monorepos-rule.jar
...
javatests/components/vowelbase: tests PASSED
typescripttests/applications/mmmm: tests PASSED
```

18 compile targets across 5 languages, 2 fat jars, 17 test suites — all from one command.

### Running the apps

```bash
java -Djava.library.path=. -jar ./target/applications/monorepos_rule/bin/monorepos-rule.jar
java -Djava.library.path=. -jar ./target/applications/directed_graph_build_systems_are_cool/bin/directed-graph-build-systems-are-cool.jar
```

### Build files

Each module directory has:

| File | Purpose |
|------|---------|
| `.build.ae` | Compile — declares deps, invokes language compiler |
| `.tests.ae` | Test — declares deps + test libs, compiles and runs tests |
| `.dist.ae` | Package — builds fat jar or other distributable |

Dependencies are one-per-line `build.dep(b, "path")` calls — greppable for DAG extraction without compilation.

### Cross-language dependency chains

- Java → Rust (JNI shared library)
- Java → Kotlin (JVM classpath interop)
- Java → Go (shared library via ldlibdeps)
- TypeScript → Go (FFI via ffi-napi)

## Legacy bash build system

The previous build system used `.compile.sh`, `.tests.sh`, and `.dist.sh` bash scripts
with `shared-build-scripts/` for common logic and `.buildStepsDoneLastExecution` for
visited-module tracking. This has been fully replaced by Aether Build. The
`shared-build-scripts/` directory is retained as some helper scripts (tsconfig generation,
npm path mapping) are still called by the Aether TypeScript SDK.

## Vendoring in Third-Party Dependencies

This sim aims to simulate many aspects of a google-style monorepo, including how third-party dependencies 
might be "vendored in" rather than relying on external package managers during builds.      
Vendoring means copying the dependency's source code or binaries directly into the repository. 
This provides benefits like reproducible builds, faster dependency resolution, and        
immunity to external repository outages, but also adds overhead in managing updates.

Here's the current status of vendoring for different language ecosystems within this repo:

| Language   | Current Status                                                       |
|------------|----------------------------------------------------------------------|
| Java       | complete – see `libs/java/`                                          |
| Rust       | complete – see `libs/rust/registry/`                                 |
| Go         | Not started – `go build` is used and it has its own idioms           |
| TypeScript | complete – see `libs/javascript/npm_vendored/`                       |

# Sparse-checkout feature (that Google do)

There's also a use of Git sparse-checkout, implemented in Aether:

```bash
# Build the tool once
ae build shared-build-scripts/gcheckout.ae -o gcheckout

# Initialize sparse checkout
./gcheckout --init

# Add a module and all its transitive deps
./gcheckout add javatests/applications/monorepos_rule
```

This recursively walks `.build.ae` and `.tests.ae` files, extracting
`dep()`, `lib()`, `npm_dep()`, and `cargo_dep()` declarations, and adds
every transitive dependency to the sparse checkout.
