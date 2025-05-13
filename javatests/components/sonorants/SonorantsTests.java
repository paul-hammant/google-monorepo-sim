package components.sonorants;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class SonorantsTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.sonorants", new L().getClass().getPackageName());
        assertEquals("components.sonorants", new R().getClass().getPackageName());
    }
}
