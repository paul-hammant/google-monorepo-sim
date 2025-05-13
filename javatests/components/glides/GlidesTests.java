package components.glides;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class GlidesTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.glides", new H().getClass().getPackageName());
        assertEquals("components.glides", new J().getClass().getPackageName());
        assertEquals("components.glides", new Y().getClass().getPackageName());
    }
}
