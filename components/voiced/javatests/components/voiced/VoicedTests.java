package components.voiced;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class VoicedTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.voiced", new B().getClass().getPackageName());
        assertEquals("components.voiced", new D().getClass().getPackageName());
    }
}
