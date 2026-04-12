using Shouldly;
using Xunit;
using Components.Greek;

namespace Components.Greek.Tests
{
    public class GreekTests
    {
        [Fact] public void BetaToString() => new Beta().ToString().ShouldBe("β");
        [Fact] public void LambdaToString() => new Lambda().ToString().ShouldBe("λ");
        [Fact] public void AlphaToString() => new Alpha().ToString().ShouldBe("α");
        [Fact] public void GammaToString() => new Gamma().ToString().ShouldBe("γ");
        [Fact] public void DeltaToString() => new Delta().ToString().ShouldBe("δ");
        [Fact] public void MuToString() => new Mu().ToString().ShouldBe("μ");
        [Fact] public void NuToString() => new Nu().ToString().ShouldBe("ν");
        [Fact] public void PiToString() => new Pi().ToString().ShouldBe("π");
        [Fact] public void RhoToString() => new Rho().ToString().ShouldBe("ρ");
        [Fact] public void SigmaToString() => new Sigma().ToString().ShouldBe("σ");
        [Fact] public void TauToString() => new Tau().ToString().ShouldBe("τ");
        [Fact] public void ThetaToString() => new Theta().ToString().ShouldBe("θ");
    }
}
