package myPackage;

import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OpenRouterConfig {
    private static final Logger LOGGER = Logger.getLogger(OpenRouterConfig.class.getName());
    private static Properties props = new Properties();

    static {
        try {
            // Try to load from openrouter.properties in classpath
            InputStream input = OpenRouterConfig.class.getClassLoader().getResourceAsStream("openrouter.properties");
            if (input != null) {
                props.load(input);
                LOGGER.info("Loaded openrouter.properties from classpath");
            } else {
                // Try to load from root /
                input = OpenRouterConfig.class.getResourceAsStream("/openrouter.properties");
                if (input != null) {
                    props.load(input);
                    LOGGER.info("Loaded openrouter.properties from /");
                } else {
                    LOGGER.warning("Could not find openrouter.properties in classpath");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading openrouter properties", e);
        }
    }

    public static String getApiKey() {
        // Try system property first (set in server startup)
        String key = System.getProperty("openrouter.api.key");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        // Try environment variable
        key = System.getenv("OPENROUTER_API_KEY");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        // Try properties file
        key = props.getProperty("openrouter.api.key");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        return null;
    }

    public static String getModel() {
        return props.getProperty("openrouter.model", "openai/gpt-4o-mini");
    }
}
