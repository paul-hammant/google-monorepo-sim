package components.vowels;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import components.vowelbase.VowelBase;

public class VowelsTests {

    @Test
    public void testPlaceholder() {
        VowelBase.loadLibrary();
        assertEquals("components.vowels", new A().getClass().getPackageName());
        assertEquals("components.vowels", new E().getClass().getPackageName());
        assertEquals("components.vowels", new I().getClass().getPackageName());
        assertEquals("components.vowels", new O().getClass().getPackageName());
        assertEquals("components.vowels", new U().getClass().getPackageName());
    }
}
