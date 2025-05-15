package components.labiodental;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class LabiodentalTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.labiodental", new V().getClass().getPackageName());
        assertEquals("components.labiodental", new W().getClass().getPackageName());

    }
}
