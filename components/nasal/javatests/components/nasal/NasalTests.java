package components.nasal;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class NasalTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.nasal", new M().getClass().getPackageName());
        assertEquals("components.nasal", new N().getClass().getPackageName());
    }
}
