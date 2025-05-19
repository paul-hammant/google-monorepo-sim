# google-monorepo-sim

This repo goes hand in hand with my book: [Trunk-Based Development And Branch By Abstraction ](https://tbd-book.com/) and a [short video talking about it](https://tbd-book.com/gmr-vid) 

It purports to show a monorepo in the style that Google use internally - with a novel expand/contract feature that maps to Git's sparse-checkout.

Two branches in this repo show simulations of monorepo concepts with some source files in common, but not all.

2. Directed Acyclic Graph Modular Monorepo - [trunk](https://github.com/paul-hammant/google-monorepo-sim/tree/trunk)
1. Depth-First Recursive Modular Monorepo - [depth-first_recursive_modular_monorepo](https://github.com/paul-hammant/google-monorepo-sim/tree/depth-first_recursive_modular_monorepo)

Specifically, the Java and Rust sources are identical in both, but in different directories. The build files are different.

## Directed Acyclic Graph Modular Monorepo

## Prerequisites

Install these and set paths etc for your OS.

* JDK 11 or above. [Linux instructions](https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/generic-linux-install.html)
* Rust and Cargo. [Linux/Mac instructions](https://doc.rust-lang.org/cargo/getting-started/installation.html) but also do `sudo apt install build-essential`
* Bash

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

Output looks like

```
libvowelbase.so extracted successfully.
MonoreposRule instance created:
M(O)N(O)R(E)P(O)SR(U)L(E)
MonoreposRule{m=class components.nasal.M, o=class components.vowels.O, n=class components.nasal.N, o2=class components.vowels.O, r=class components.sonorants.R, e=class components.vowels.E, p=class components.voiceless.P, o3=class components.vowels.O, s=class components.fricatives.S, r2=class components.sonorants.R, u=class components.vowels.U, l=class components.sonorants.L, e2=class components.vowels.E}
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

You can target any `.dist.sh` script anywhere, or `.tests.sh` or `.compile.sh` where you see them.

You can do that from the root folder. You can also do it by cd-ing deeper into the dir structure.

Any target can invoke any of its dependencies build files anywhere else in the relative dir structure.

If you run anything a second time, compile and test invocation are skipped, and there will be a note in the build log to that effect.

# Sparse-checkout feature (that Google do)

There's also a use of Git sparse-checkout

```
.shared-build-scripts/gcheckout.sh --init
.shared-build-scripts/gcheckout.sh add javatests/applications/monorepos_rule
```

You'd do regular source edit and build steps after that.
