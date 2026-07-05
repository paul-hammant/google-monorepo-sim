#!/usr/bin/env bash
# One-command toolchain bootstrap for the google-monorepo-sim monorepo.
#
# Ensures the Aether toolchain (`ae`) and the build runner (`aeb`) are present
# and recent enough. It does NOT build the repo — this monorepo has no single
# per-language leaf to sniff (modules are scattered across
# {lang}/components/** and {lang}/applications/**). Once the toolchain is
# ready, build everything the way the README documents:
#
#     AETHER="$(command -v ae)" aeb --scan '.build.ae'
#
# The toolchains are installed via their canonical remote installers — they
# work from a bare clone (no sibling checkouts), install released builds to a
# user prefix, run no tests, build no contrib:
#     aether: https://raw.githubusercontent.com/aether-lang-org/aether/main/get.sh
#     aeb:    https://raw.githubusercontent.com/aether-lang-org/aeb/main/install.sh
#
# Idempotent: a no-op when `ae`/`aeb` are already good.
# Requires `curl` to install them; no build-from-source fallback.
#
# Env overrides:
#   PREFIX        install prefix                 (default: $HOME/.local; no sudo)
#   AETHER_REF    ae tag/branch/SHA to install   (default: latest tag) — pin in CI
#   AEB_REF       aeb tag/branch/SHA to install  (default: latest tag) — pin in CI
#   MIN_AE        minimum acceptable ae version  (default: 0.183.0)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"; export PREFIX
MIN_AE="${MIN_AE:-0.183.0}"
AETHER_GET_URL="https://raw.githubusercontent.com/aether-lang-org/aether/main/get.sh"
AEB_INSTALL_URL="https://raw.githubusercontent.com/aether-lang-org/aeb/main/install.sh"

say() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }
ae_version() { ae --version 2>/dev/null | head -n1 | sed -E 's/^ae ([0-9]+\.[0-9]+\.[0-9]+).*/\1/'; }

# fetch_run URL : download an installer to a temp file and run it under sh,
# inheriting the (exported) env the caller set. Avoids `curl | sh` masking a
# fetch failure.
fetch_run() {
    command -v curl >/dev/null 2>&1 || die "curl is required to install the Aether toolchain (or install ae/aeb yourself and re-run)."
    local tmp rc; tmp="$(mktemp)"
    if curl -fsSL "$1" -o "$tmp"; then sh "$tmp"; rc=$?; else rc=$?; fi
    rm -f "$tmp"; return $rc
}

export PATH="$PREFIX/bin:$PATH"   # so freshly-installed ae/aeb are found below

# ---- 0. Preflight: a C compiler + make ----
# Aether compiles to C and hands off to a C compiler; the source-tarball
# installers for ae/aeb (get.sh / install.sh) also need make + cc. Check up
# front so a missing compiler fails clearly HERE, not cryptically later inside
# `ae build` (a --emit=lib link error) or the toolchain installer.
command -v cc >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1 \
    || die "a C compiler (cc/gcc/clang) is required — Aether compiles to C. Install e.g. build-essential (Debian/Ubuntu) or the Xcode Command Line Tools (macOS)."
command -v make >/dev/null 2>&1 \
    || die "GNU make is required to build the Aether toolchain from source. Install e.g. build-essential / make."

# ---- 1. Aether toolchain (ae) ----
if command -v ae >/dev/null 2>&1 && have="$(ae_version || true)" && [ -n "$have" ] && version_ge "$have" "$MIN_AE"; then
    say "ae $have already on PATH (>= $MIN_AE) — skipping"
else
    say "installing ae via get.sh (AETHER_REF=${AETHER_REF:-latest}, PREFIX=$PREFIX)"
    AETHER_REF="${AETHER_REF:-}" fetch_run "$AETHER_GET_URL" || die "ae install failed (get.sh)."
    command -v ae >/dev/null 2>&1 || die "ae installed but not on PATH — ensure $PREFIX/bin is on PATH."
    say "ae $(ae_version) ready"
fi

# ---- 2. Build runner (aeb) ----
if command -v aeb >/dev/null 2>&1; then
    say "aeb already on PATH — skipping"
else
    say "installing aeb via install.sh (AEB_REF=${AEB_REF:-latest}, PREFIX=$PREFIX)"
    AEB_REF="${AEB_REF:-}" AETHER="$(command -v ae)" fetch_run "$AEB_INSTALL_URL" || die "aeb install failed (install.sh)."
    command -v aeb >/dev/null 2>&1 || die "aeb installed but not on PATH — ensure $PREFIX/bin is on PATH."
fi
say "using aeb: $(command -v aeb)"

# ---- 3. Done — the toolchain is ready. This bootstrap deliberately does NOT
# build the repo (see header). Point the user at the README's build command.
case ":$PATH:" in *":$PREFIX/bin:"*) : ;; *) say "tip: add '$PREFIX/bin' to your shell PATH permanently";; esac
cat <<EOF

Toolchain ready. To compile the whole monorepo:

    cd "$HERE"
    AETHER="\$(command -v ae)" aeb --scan '.build.ae'

(Name a specific .tests.ae / .dist.ae leaf to run its tests or package it —
current aeb needs a named target or a --scan glob; bare 'aeb' builds nothing.)

Language toolchains (JDK 21+, Rust/Cargo, Kotlin, Go 1.24+, Node 22+ & tsc,
dotnet) must be installed separately — see the README "Prerequisites" section.
EOF
