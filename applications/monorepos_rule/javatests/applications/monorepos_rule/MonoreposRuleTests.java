package applications.monorepos_rule;

import components.vowelbase.VowelBase;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class MonoreposRuleTests {

    @Test
    public void testPlaceholder() {
        VowelBase.loadLibrary();
        assertEquals("MonoreposRule{m=class components.nasal.M, o=class components.vowels.O, n=class components.nasal.N, " +
                "o2=class components.vowels.O, r=class components.sonorants.R, e=class components.vowels.E, " +
                "p=class components.voiceless.P, o3=class components.vowels.O, s=class components.fricatives.S, " +
                "r2=class components.sonorants.R, u=class components.vowels.U, l=class components.sonorants.L, " +
                "e2=class components.vowels.E}", MonoreposRule.makeMonoreposRule().toString());
    }
}
