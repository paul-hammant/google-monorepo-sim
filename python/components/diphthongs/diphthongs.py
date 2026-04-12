"""Diphthongs — vowel combinations that glide from one sound to another.

Uses the Rust vowelbase FFI library to print individual vowel sounds."""

import ctypes
import os

DIPHTHONGS = {
    "ai": ("a", "i"),
    "au": ("a", "u"),
    "ei": ("e", "i"),
    "oi": ("o", "i"),
    "ou": ("o", "u"),
}

_lib = None


def _load_vowelbase():
    global _lib
    if _lib is not None:
        return _lib
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        so = os.path.join(d, "target", "rust", "components", "vowelbase", "lib", "release", "libvowelbase.so")
        if os.path.exists(so):
            _lib = ctypes.CDLL(so)
            _lib.Python_components_vowelbase_printString.argtypes = [ctypes.c_char_p]
            _lib.Python_components_vowelbase_printString.restype = None
            return _lib
        d = os.path.dirname(d)
    raise RuntimeError("libvowelbase.so not found — build rust/components/vowelbase first")


def print_vowel(sound: str):
    """Print a vowel sound via the Rust vowelbase FFI."""
    lib = _load_vowelbase()
    lib.Python_components_vowelbase_printString(sound.encode("utf-8"))


def classify(sound: str) -> str:
    """Classify a diphthong by its component vowels."""
    if sound in DIPHTHONGS:
        start, end = DIPHTHONGS[sound]
        return f"{sound}: {start} → {end}"
    return f"{sound}: not a diphthong"


def list_all() -> list[str]:
    """Return all known diphthongs."""
    return sorted(DIPHTHONGS.keys())


def speak_all():
    """Print all diphthongs via Rust FFI."""
    for name in sorted(DIPHTHONGS.keys()):
        start, end = DIPHTHONGS[name]
        print_vowel(start)
        print_vowel(end)
        print(f" = {name}")
