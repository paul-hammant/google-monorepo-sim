package components.sonorants

class SonorantsTests {

    fun testPlaceholder() {
        assert(L()::class.java.packageName == "components.sonorants") { "L package name is incorrect" }
        assert(R()::class.java.packageName == "components.sonorants") { "R package name is incorrect" }
    }
}

fun main() {

    // I'm approximating a test runner here because Kotest's deps are a long list
    // and would detract from the education aspect of this repo.

    // It is possible that Google tooling to ingest binary deps is considerable. When the
    // dependent jars are in the monorepo, and there is no conflict on versions (diamond
    // dependcy problem) it all looks very elegant - but the principle of the swan
    // applies: elegant on the surface, flapping like hell under the water.

    val tests = SonorantsTests()
    try {
        tests.testPlaceholder()
        println("All tests passed.")
    } catch (e: AssertionError) {
        println("Test failed: ${e.message}")
        System.exit(1)
    }
}
