package components.sibilants;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class SibilantsTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.sibilants", new Q().getClass().getPackageName());
        assertEquals("components.sibilants", new X().getClass().getPackageName());
        assertEquals("components.sibilants", new Z().getClass().getPackageName());
    }
}
