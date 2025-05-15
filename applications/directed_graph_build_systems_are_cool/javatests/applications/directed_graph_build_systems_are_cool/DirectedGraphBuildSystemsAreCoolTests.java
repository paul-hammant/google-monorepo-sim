package applications.directed_graph_build_systems_are_cool;

import components.vowelbase.VowelBase;
import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class DirectedGraphBuildSystemsAreCoolTests {
    @Test
    public void testPlaceholder() {
        VowelBase.loadLibrary();
        assertEquals("DirectedGraphBuildSystemsAreCool{d=class components.voiced.D, i=class components.vowels.I, " +
                        "r=class components.sonorants.R, e=class components.vowels.E, c=class components.consonants.C, " +
                        "t=class components.voiceless.T, e2=class components.vowels.E, d2=class components.voiced.D, " +
                        "g=class components.velar.G, r2=class components.sonorants.R, a=class components.vowels.A, " +
                        "p=class components.voiceless.P, h=class components.glides.H, b=class components.voiced.B, " +
                        "u=class components.vowels.U, i2=class components.vowels.I, l=class components.sonorants.L, " +
                        "d3=class components.voiced.D, s=class components.fricatives.S, y=class components.glides.Y, " +
                        "s2=class components.fricatives.S, t2=class components.voiceless.T, e3=class components.vowels.E, " +
                        "m=class components.nasal.M, s3=class components.fricatives.S, a2=class components.vowels.A, " +
                        "r3=class components.sonorants.R, e4=class components.vowels.E, c2=class components.consonants.C, " +
                        "o=class components.vowels.O, o2=class components.vowels.O, l2=class components.sonorants.L}",
                DirectedGraphBuildSystemsAreCool.makeDirectedGraphBuildSystemsAreCool().toString());
    }
}
