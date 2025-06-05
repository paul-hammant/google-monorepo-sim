# google-monorepo-sim

This repo goes hand in hand with my book: [Trunk-Based Development And Branch By Abstraction ](https://tbd-book.com/) and a [short video talking about it](https://tbd-book.com/gmr-vid) 

It purports to show a monorepo in the style that Google use internally - with a novel expand/contract feature that maps to Git's sparse-checkout.

Two branches in this repo show simulations of monorepo concepts with some source files in common, but not all.

2. Directed Acyclic Graph Modular Monorepo - [trunk](https://github.com/paul-hammant/google-monorepo-sim/tree/trunk)
1. Depth-First Recursive Modular Monorepo - [depth-first_recursive_modular_monorepo](https://github.com/paul-hammant/google-monorepo-sim/tree/depth-first_recursive_modular_monorepo)

Specifically, the Java, and Rust sources are identical in both, but in different directories. 
The build files are different. There's newer Kotlin modules in trunk, that are not duplicated 
in the depth-first_recursive_modular_monorepo branch 

# Directed Acyclic Graph Modular Monorepo

## Prerequisites

Install these and set paths etc for your OS. Only of you want to build EVERYTHING. Otherwise just pick the pertinent ones:

* General unix tools: `sudo apt install moreutils jq build-essential`
* JDK 21 or above. [Linux instructions](https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/generic-linux-install.html)
* Rust and Cargo. [Linux/Mac instructions](https://doc.rust-lang.org/cargo/getting-started/installation.html)
* Kotlin which if you're on Debian you'll want to install [via SDKMan](https://sdkman.io/sdks/kotlin) as the 'apt' installed one is too old
* Go 1.24.3 (see below)
* Typescript [needs Node v22](https://docs.vultr.com/how-to-install-node-js-and-npm-on-debian-12) or above, and the npm-installed tsc (globally).
* Bash

Also, "Go" via this oneliner as sdk-man doesn't have it:

``` 
# See 1.24.3 below
sudo rm -rf /usr/local/go && \
curl -o go.tar.gz https://dl.google.com/go/go1.24.3.linux-amd64.tar.gz && \
sudo tar -C /usr/local -xzf go.tar.gz && \
rm go.tar.gz && \
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile && \
exec $SHELL -l && \
go version
```

Note: If on Windows, use WSL or Git-Bash to be able to use `Bash`

## Examples of building and running contrived apps

This build technology doesn't have a name - it uses shell scripts and it just for the simulation

All tests for one app and all deps, then make the fat jar, then executing it

```
$ ./javatests/applications/monorepos_rule/.dist.sh
```

Running that app for contrived output to stdout:

```
$ java -Djava.library.path=. -jar ./target/applications/monorepos_rule/bin/monorepos-rule.jar
```

All tests for the other app and all deps, them making the fat jar, then executing it 

```
$ ./javatests/applications/directed_graph_build_systems_are_cool/.dist.sh

java -Djava.library.path=. -jar ./target/applications/directed_graph_build_systems_are_cool/bin/directed-graph-build-systems-are-cool.jar

libvowelbase.so extracted successfully.
DirectedGraphBuildSystemsAreCool instance created:
D(I)R(E)CT(E)DGR(A)PHB(U)(I)LDSYST(E)MS(A)R(E)C(O)(O)L
DirectedGraphBuildSystemsAreCool{d=class components.voiced.D, i=class components.vowels.I, ...
```

**TypeScript App Example:**

All tests for the TypeScript app and all deps, then executing them:

```bash
$ ./typescripttests/applications/mmmm/.tests.sh
```

All tests for the single TypeScript component, then executing them:

```bash
$ ./typescripttests/applications/mmmm/.tests.sh
```


You can target any `.dist.sh` script anywhere, or `.tests.sh` or `.compile.sh` where you see them.

You can do that from the root folder. You can also do it by cd-ing deeper into the dir structure.

Any target can invoke any of its dependencies build files anywhere else in the relative dir structure.

If you run anything a second time, compile and test invocation are skipped, and there will be a note in the build log to that effect.


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
| Rust       | Not started – Cargo build system is used and it has its own idioms   |
| Go         | Not started – `go build` is used and it has its own idioms           |
| TypeScript | No deps presently and no idea how to elegantly do it                 |


# Sparse-checkout feature (that Google do)

There's also a use of Git sparse-checkout

```
.shared-build-scripts/gcheckout.sh --init
.shared-build-scripts/gcheckout.sh add javatests/applications/monorepos_rule
```

You'd do regular source edit and build steps after that.
