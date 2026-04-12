"""Diphthongs — vowel combinations that glide from one sound to another."""

DIPHTHONGS = {
    "ai": ("a", "i"),
    "au": ("a", "u"),
    "ei": ("e", "i"),
    "oi": ("o", "i"),
    "ou": ("o", "u"),
}


def classify(sound: str) -> str:
    """Classify a diphthong by its component vowels."""
    if sound in DIPHTHONGS:
        start, end = DIPHTHONGS[sound]
        return f"{sound}: {start} → {end}"
    return f"{sound}: not a diphthong"


def list_all() -> list[str]:
    """Return all known diphthongs."""
    return sorted(DIPHTHONGS.keys())
