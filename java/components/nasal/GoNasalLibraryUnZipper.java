package components.nasal;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.jar.JarFile;
import java.util.zip.ZipEntry;

public class GoNasalLibraryUnZipper {

    public static void unzip() throws IOException {
        String jarPath = GoNasalLibraryUnZipper.class.getProtectionDomain().getCodeSource().getLocation().getPath();

        String libName = "libgonasal.so";

        JarFile jarFile = new JarFile(jarPath);
        ZipEntry entry = jarFile.getEntry(libName);
        if (entry != null) {
            try (InputStream inputStream = jarFile.getInputStream(entry)) {
                File outputFile = new File(libName);
                try (FileOutputStream outputStream = new FileOutputStream(outputFile)) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }
                    System.out.println(outputFile.getCanonicalPath() + " extracted (tempfile)");
                    outputFile.deleteOnExit();
                }
            }
        } else {
            System.out.println(libName + " not found in the JAR.");
        }
    }
    public static void loadLibrary() {
        System.loadLibrary("gonasal");
    }
}
