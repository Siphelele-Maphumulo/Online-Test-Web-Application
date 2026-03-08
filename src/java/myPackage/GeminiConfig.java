package myPackage;

import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class GeminiConfig {
    private static final Logger LOGGER = Logger.getLogger(GeminiConfig.class.getName());
    private static Properties props = new Properties();
    private static final String DEFAULT_MODEL = "gemini-3-flash-preview";

    static {
        try {
            // Try to load from gemini.properties in classpath
            InputStream input = GeminiConfig.class.getClassLoader().getResourceAsStream("gemini.properties");
            if (input != null) {
                props.load(input);
                LOGGER.info("Loaded gemini.properties from classpath");
            } else {
                // Try to load from root /
                input = GeminiConfig.class.getResourceAsStream("/gemini.properties");
                if (input != null) {
                    props.load(input);
                    LOGGER.info("Loaded gemini.properties from /");
                } else {
                    LOGGER.warning("Could not find gemini.properties in classpath");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading gemini properties", e);
        }
    }

    public static String getApiKey() {
        // Try system property first
        String key = System.getProperty("gemini.api.key");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        // Try environment variable
        key = System.getenv("GEMINI_API_KEY");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        // Try properties file
        key = props.getProperty("gemini.api.key");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        return null;
    }

    public static String getModel() {
        return props.getProperty("gemini.model", DEFAULT_MODEL);
    }
}
