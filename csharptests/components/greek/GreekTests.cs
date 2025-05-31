#:library ../../../target/components/greek/bin/components_greek.dll

using Foo.Bar;

namespace Components.Tests
{
    public class GreekTests
    {
        public void TestBetaToString()
        {
            var beta = new Beta();
            beta.ToString().ShouldBe("β");
        }

        public void TestLambdaToString()
        {
            var lambda = new Lambda();
            lambda.ToString().ShouldBe("λ");
        }
        public void TestAlphaToString()
        {
            var alpha = new Alpha();
            alpha.ToString().ShouldBe("α");
        }

        public void TestGammaToString()
        {
            var gamma = new Gamma();
            gamma.ToString().ShouldBe("γ");
        }

        public void TestDeltaToString()
        {
            var delta = new Delta();
            delta.ToString().ShouldBe("δ");
        }

        public void TestMuToString()
        {
            var mu = new Mu();
            mu.ToString().ShouldBe("μ");
        }

        public void TestNuToString()
        {
            var nu = new Nu();
            nu.ToString().ShouldBe("ν");
        }

        public void TestPiToString()
        {
            var pi = new Pi();
            pi.ToString().ShouldBe("π");
        }

        public void TestRhoToString()
        {
            var rho = new Rho();
            rho.ToString().ShouldBe("ρ");
        }

        public void TestSigmaToString()
        {
            var sigma = new Sigma();
            sigma.ToString().ShouldBe("σ");
        }

        public void TestTauToString()
        {
            var tau = new Tau();
            tau.ToString().ShouldBe("τ");
        }

        public void TestThetaToString()
        {
            var theta = new Theta();
            theta.ToString().ShouldBe("θ");
        }
    }
    public static class Runner
    {
        public static void Main()
        {

            // I'm approximating a test runner here because vstest's deps are confusing to me
            // after hours of work.
            // And even if I could get it working, it would detract from the education
            // aspect of this repo.

            // It is possible that Google tooling to ingest binary deps is considerable. When the
            // dependent jars are in the monorepo, and there is no conflict on versions (diamond
            // dependency problem) it all looks very elegant - but the principle of the swan
            // applies: elegant on the surface, flapping like hell under the water.


            var tests = new GreekTests();
            try
            {
                tests.TestBetaToString();
                tests.TestLambdaToString();
                tests.TestAlphaToString();
                tests.TestGammaToString();
                tests.TestDeltaToString();
                tests.TestMuToString();
                tests.TestNuToString();
                tests.TestPiToString();
                tests.TestRhoToString();
                tests.TestSigmaToString();
                tests.TestTauToString();
                tests.TestThetaToString();
                Console.WriteLine("All tests passed.");
            }
            catch (Exception e)
            {
                Console.WriteLine($"Test failed: {e.Message}");
                Environment.Exit(1);
            }
        }
    }
}
