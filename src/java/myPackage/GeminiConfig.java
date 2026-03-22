package myPackage;

import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class GeminiConfig {
    private static final Logger LOGGER = Logger.getLogger(GeminiConfig.class.getName());
    private static final Properties props = new Properties();
    private static final String DEFAULT_MODEL = "gemini-1.5-flash";

    static {
        try {
            InputStream input = GeminiConfig.class.getClassLoader().getResourceAsStream("gemini.properties");
            if (input != null) {
                props.load(input);
                LOGGER.info("Loaded gemini.properties from classpath");
            } else {
                input = GeminiConfig.class.getResourceAsStream("/gemini.properties");
                if (input != null) {
                    props.load(input);
                    LOGGER.info("Loaded gemini.properties from /");
                } else {
                    LOGGER.info("gemini.properties not found in classpath (this is ok if using env vars)");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading gemini properties", e);
        }
    }

    public static String getApiKey() {
        String key = System.getProperty("gemini.api.key");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        key = System.getenv("GEMINI_API_KEY");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        key = props.getProperty("gemini.api.key");
        if (key != null && !key.trim().isEmpty()) {
            return key;
        }

        return null;
    }

    public static String getModel() {
        String model = props.getProperty("gemini.model", DEFAULT_MODEL);
        if (model == null) {
            return DEFAULT_MODEL;
        }

        model = model.trim();

        // Map human-friendly names to actual API model IDs
        switch (model.toLowerCase()) {
            case "gemini 3 flash preview":
                return "gemini-3-flash-preview";
            case "gemini 3 flash":
                return "gemini-3-flash-preview";
            case "gemini 3 pro preview":
                return "gemini-3-pro-preview";
            case "gemini 3 pro":
                return "gemini-3-pro-preview";
        }

        // Gemini model names are URL path segments. Reject anything with spaces or unusual characters.
        // Valid examples: gemini-1.5-flash, gemini-1.5-pro, gemini-3-flash-preview
        if (model.isEmpty() || model.contains(" ") || !model.matches("[a-zA-Z0-9._-]+")) {
            LOGGER.warning("Invalid gemini.model configured: '" + model + "'. Falling back to " + DEFAULT_MODEL);
            return DEFAULT_MODEL;
        }

        return model;
    }
}
