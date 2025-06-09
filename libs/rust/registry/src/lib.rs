// This is a dummy library for the Rust registry
// The real purpose is to compile and vendor all dependencies in target/release/deps/
// Individual modules will link against the .rlib files in target/release/deps/

pub fn dummy_function() {
    // This function exists just to make cargo happy
    // It re-exports all our vendored dependencies so they get compiled
}