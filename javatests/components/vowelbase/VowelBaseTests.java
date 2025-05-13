package components.vowelbase;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class VowelBaseTests {

    @Test
    public void testPlaceholder() {
        VowelBase.loadLibrary();
        VowelBase vb = new VowelBase("?");
    }
}
