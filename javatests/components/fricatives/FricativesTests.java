package components.fricatives;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class FricativesTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.fricatives", new F().getClass().getPackageName());
        assertEquals("components.fricatives", new S().getClass().getPackageName());
    }
}
