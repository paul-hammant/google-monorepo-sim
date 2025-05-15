package components.voiceless;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class VoicelessTests {

    @Test
    public void testPlaceholder() {
        assertEquals("components.voiceless", new P().getClass().getPackageName());
        assertEquals("components.voiceless", new T().getClass().getPackageName());
    }
}
