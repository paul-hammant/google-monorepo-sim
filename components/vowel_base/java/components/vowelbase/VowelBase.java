package components.vowelbase;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class VowelBase {

    public static void loadLibrary() {
        System.loadLibrary("vowelbase");
    }

    public VowelBase(String input) {
        printString("(" + input + ")");
    }

    private static native void printString(String input);
}
