package components.nasal;

public class N {
    static {
        System.loadLibrary("gonasal");
    }

    public N() {
        N_Init();
    }

    private native void N_Init();
}
