package myPackage;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONObject;

public class IdentityVerificationProvider {
    private static final Logger LOGGER = Logger.getLogger(IdentityVerificationProvider.class.getName());

    private static boolean isGeminiError(JSONObject obj) {
        return obj == null || obj.optBoolean("error", false);
    }

    public static boolean isFacePhotoValid(String base64Image, StringBuilder reason) {
        try {
            JSONObject analysis = GeminiClient.analyzeFacePhoto(base64Image);
            if (!isGeminiError(analysis)) {
                boolean passed = analysis.optBoolean("passed", true);
                if (reason != null) reason.append(analysis.optString("reason", passed ? "Face verification passed" : "Face verification failed"));
                return passed;
            }

            LOGGER.warning("Gemini face analysis unavailable, falling back to OpenRouter. Gemini message: " + analysis.optString("message"));
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Gemini face analysis threw exception, falling back to OpenRouter", e);
        }

        return OpenRouterClient.isFacePhotoValid(base64Image, reason);
    }

    public static boolean isIdPhotoValid(String base64Image, StringBuilder reason) {
        try {
            JSONObject analysis = GeminiClient.analyzeIdPhoto(base64Image);
            if (!isGeminiError(analysis)) {
                boolean passed = analysis.optBoolean("passed", true);
                if (reason != null) reason.append(analysis.optString("reason", passed ? "ID verification passed" : "ID verification failed"));
                return passed;
            }

            LOGGER.warning("Gemini ID analysis unavailable, falling back to OpenRouter. Gemini message: " + analysis.optString("message"));
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Gemini ID analysis threw exception, falling back to OpenRouter", e);
        }

        return OpenRouterClient.isIdPhotoValid(base64Image, reason);
    }

    public static boolean isHoldingId(String base64Image, StringBuilder reason) {
        try {
            JSONObject result = GeminiClient.verifyHoldingId(base64Image);
            if (!isGeminiError(result)) {
                boolean holdingId = result.optBoolean("holdingId", true);
                if (reason != null) reason.append(result.optString("reason", holdingId ? "ID detected" : "ID not detected"));
                return holdingId;
            }

            LOGGER.warning("Gemini holding-ID verification unavailable, falling back to OpenRouter. Gemini message: " + result.optString("message"));
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Gemini holding-ID verification threw exception, falling back to OpenRouter", e);
        }

        return OpenRouterClient.isHoldingId(base64Image, reason);
    }
}
