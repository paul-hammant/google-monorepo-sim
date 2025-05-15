# google-monorepo-sim

This repo goes hand in hand with my book: [Trunk-Based Development And Branch By Abstraction ](https://tbd-book.com/) and a [short video talking about it](https://tbd-book.com/gmr-vid) 

It purports to show a monorepo in the style that Google use internally - with a novel expand/contract featire that maps to Git's sparse-checkout.

Two branches in this repo show simulations of monorepo concepts with some source files in common, but not all.

2. Directed Acyclic Graph Modular Monorepo - [trunk](https://github.com/paul-hammant/google-monorepo-sim/tree/trunk)
1. Depth-First Recursive Modular Monorepo - [depth-first_recursive_modular_monorepo](https://github.com/paul-hammant/google-monorepo-sim/tree/depth-first_recursive_modular_monorepo)

Specifically, the Java and Rust sources are identical in both, but in different directories. The builld files are different.

## Depth-first recursive Modular Monorepo

## Prerequisites

Install these and set paths etc for your OS.

* JDK 11 or above. [Linux instructions](https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/generic-linux-install.html)
* Maven 3. Do `sudo apt install maven`
* Rust and Cargo. [Linux/Mac instructions](https://doc.rust-lang.org/cargo/getting-started/installation.html) but also do `sudo apt install build-essential`
* Bash

Note: If on Windows, use WSL or Git-Bash to be able to use `Bash`

## Examples of building and running contrived apps

All tests for one app and all deps, them making the fat jar, then executing it

```
$ mvn clean
$ mvn package -pl applications/monorepos_rule -am
```

That is an optimized build that targets one app, whereas the classic `mvn package` from root (no additional args) would compile and test all modules encountered.
It also has a lot of logging.  This one is quieter, just for comparison's sake:

```
$ quieter-mvn package -pl applications/monorepos_rule -am
```


Running that app:

```
$ java -Djava.library.path=. -cp applications/monorepos_rule/target/monorepos-rule-1.0-SNAPSHOT-jar-with-dependencies.jar applications.monorepos_rule.MonoreposRule
```

Output looks like

```
libvowelbase.so extracted successfully.
MonoreposRule instance created:
M(O)N(O)R(E)P(O)SR(U)L(E)
MonoreposRule{m=class components.nasal.M, o=class components.vowels.O, n=class components.nasal.N, o2=class components.vowels.O, r=class components.sonorants.R, e=class components.vowels.E, p=class components.voiceless.P, o3=class components.vowels.O, s=class components.fricatives.S, r2=class components.sonorants.R, u=class components.vowels.U, l=class components.sonorants.L, e2=class components.vowels.E}
```
