package components.velar;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class VelarTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.velar", new G().getClass().getPackageName());
        assertEquals("components.velar", new K().getClass().getPackageName());
    }
}
