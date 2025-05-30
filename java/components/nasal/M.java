package components.nasal;

public class M {
    static {
        System.loadLibrary("gonasal");
    }

    public M() {
        M_Init();
    }

    private native void M_Init();
}
