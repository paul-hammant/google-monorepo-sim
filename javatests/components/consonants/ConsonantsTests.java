package components.consonants;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class ConsonantsTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.consonants", new C().getClass().getPackageName());
    }
}
