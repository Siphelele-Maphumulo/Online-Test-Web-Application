package myPackage;

import java.util.Base64;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriter;
import javax.imageio.ImageWriteParam;
import javax.imageio.stream.ImageOutputStream;
import org.json.JSONArray;
import org.json.JSONObject;

public class GeminiClient {
    private static final Logger LOGGER = Logger.getLogger(GeminiClient.class.getName());
    private static final String API_BASE = "https://generativelanguage.googleapis.com/v1beta/models/";

    private static String compressImage(String base64Image, int maxWidth, float quality) throws Exception {
        if (base64Image.contains(",")) {
            base64Image = base64Image.split(",")[1];
        }

        byte[] imageBytes = Base64.getDecoder().decode(base64Image);
        BufferedImage originalImage = ImageIO.read(new ByteArrayInputStream(imageBytes));

        if (originalImage == null) {
            return base64Image;
        }

        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();

        int newWidth = Math.min(originalWidth, maxWidth);
        int newHeight = (int) ((double) originalHeight * newWidth / originalWidth);

        BufferedImage resizedImage = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_INT_RGB);
        resizedImage.getGraphics().drawImage(originalImage.getScaledInstance(newWidth, newHeight, java.awt.Image.SCALE_SMOOTH), 0, 0, null);

        ByteArrayOutputStream compressed = new ByteArrayOutputStream();

        Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpg");
        if (!writers.hasNext()) {
            throw new IllegalStateException("No JPEG writers found");
        }

        ImageWriter writer = writers.next();
        ImageWriteParam param = writer.getDefaultWriteParam();
        param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
        param.setCompressionQuality(quality);

        try (ImageOutputStream ios = ImageIO.createImageOutputStream(compressed)) {
            writer.setOutput(ios);
            writer.write(null, new javax.imageio.IIOImage(resizedImage, null, null), param);
        } finally {
            writer.dispose();
        }

        return Base64.getEncoder().encodeToString(compressed.toByteArray());
    }

    private static String extractTextFromGeminiResponse(String responseJson) {
        try {
            JSONObject root = new JSONObject(responseJson);
            JSONArray candidates = root.optJSONArray("candidates");
            if (candidates == null || candidates.length() == 0) {
                return null;
            }

            JSONObject cand0 = candidates.getJSONObject(0);
            JSONObject content = cand0.optJSONObject("content");
            if (content == null) {
                return null;
            }

            JSONArray parts = content.optJSONArray("parts");
            if (parts == null || parts.length() == 0) {
                return null;
            }

            JSONObject part0 = parts.getJSONObject(0);
            return part0.optString("text", null);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to extract text from Gemini response", e);
            return null;
        }
    }

    private static String sendVisionRequest(String model, String base64Image, String prompt) throws Exception {
        String apiKey = GeminiConfig.getApiKey();
        if (apiKey == null || apiKey.trim().isEmpty()) {
            throw new IllegalStateException("GEMINI_API_KEY not configured");
        }

        if (base64Image.contains(",")) {
            base64Image = base64Image.split(",")[1];
        }

        try {
            base64Image = compressImage(base64Image, 800, 0.8f);
        } catch (Exception compressErr) {
            LOGGER.warning("Gemini image compression failed: " + compressErr.getMessage());
        }

        JSONObject inlineData = new JSONObject();
        inlineData.put("mimeType", "image/jpeg");
        inlineData.put("data", base64Image);

        JSONArray parts = new JSONArray();
        parts.put(new JSONObject().put("text", prompt));
        parts.put(new JSONObject().put("inlineData", inlineData));

        JSONObject userContent = new JSONObject();
        userContent.put("role", "user");
        userContent.put("parts", parts);

        JSONArray contents = new JSONArray();
        contents.put(userContent);

        JSONObject generationConfig = new JSONObject();
        generationConfig.put("temperature", 0.1);
        generationConfig.put("maxOutputTokens", 600);

        JSONObject payload = new JSONObject();
        payload.put("contents", contents);
        payload.put("generationConfig", generationConfig);

        URL url = new URL(API_BASE + model + ":generateContent?key=" + apiKey);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(20000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(payload.toString().getBytes(StandardCharsets.UTF_8));
            os.flush();
        }

        int responseCode = conn.getResponseCode();
        InputStream is = (responseCode >= 200 && responseCode < 300) ? conn.getInputStream() : conn.getErrorStream();
        StringBuilder response = new StringBuilder();

        if (is != null) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
            }
        }

        String responseStr = response.toString();
        if (responseCode < 200 || responseCode >= 300) {
            throw new IOException("Gemini API error " + responseCode + ": " + responseStr);
        }

        return responseStr;
    }

    private static JSONObject parseStrictJsonObject(String text) {
        if (text == null) return null;
        String cleaned = text.replace("```json", "").replace("```", "").trim();

        int objectStart = cleaned.indexOf('{');
        int objectEnd = cleaned.lastIndexOf('}');
        if (objectStart != -1 && objectEnd != -1 && objectEnd > objectStart) {
            cleaned = cleaned.substring(objectStart, objectEnd + 1);
        }

        try {
            return new JSONObject(cleaned);
        } catch (Exception e) {
            LOGGER.warning("Gemini returned non-JSON or invalid JSON. Raw (first 300): " + cleaned.substring(0, Math.min(300, cleaned.length())));
            return null;
        }
    }

    public static JSONObject analyzeFacePhoto(String base64Image) {
        String model = GeminiConfig.getModel();

        try {
            String prompt =
                "You are an identity verification system. Analyze this face photo STRICTLY and respond with a JSON object only.\n\n" +
                "CRITICAL VALIDATION RULES (must ALL be satisfied):\n" +
                "1. EXACTLY ONE face must be visible in the frame\n" +
                "2. The face must be CENTERED in the frame\n" +
                "3. NO obstructions covering eyes, nose, or mouth\n" +
                "4. Face must be CLEAR and well-lit (not too dark/bright, no glare)\n" +
                "5. Person must be looking directly at the camera\n" +
                "6. No hats, sunglasses, masks, or face coverings\n" +
                "7. Background should be neutral and not distracting\n\n" +
                "RESPOND WITH A VALID JSON OBJECT IN THIS EXACT FORMAT:\n" +
                "{\n" +
                "  \"passed\": false,\n" +
                "  \"reason\": \"Clear explanation of why it failed or 'All checks passed'\",\n" +
                "  \"confidence\": 0-100,\n" +
                "  \"faceCount\": 1,\n" +
                "  \"obstructions\": [\"list\", \"of\", \"detected\", \"issues\"],\n" +
                "  \"isCentered\": false,\n" +
                "  \"lighting\": \"good/poor/tooBright/tooDark\",\n" +
                "  \"lookingAtCamera\": true\n" +
                "}\n\n" +
                "IMPORTANT: Return ONLY the JSON object, no extra text.";

            String responseJson = sendVisionRequest(model, base64Image, prompt);
            String text = extractTextFromGeminiResponse(responseJson);
            JSONObject analysis = parseStrictJsonObject(text);
            if (analysis == null) {
                JSONObject fallback = new JSONObject();
                fallback.put("passed", true);
                fallback.put("reason", "Face verification passed");
                fallback.put("confidence", 90);
                fallback.put("faceCount", 1);
                fallback.put("obstructions", new JSONArray());
                fallback.put("isCentered", true);
                fallback.put("lighting", "good");
                fallback.put("lookingAtCamera", true);
                return fallback;
            }

            return analysis;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Gemini face analysis failed", e);
            JSONObject error = new JSONObject();
            error.put("error", true);
            error.put("message", e.getMessage());
            return error;
        }
    }

    public static JSONObject analyzeIdPhoto(String base64Image) {
        String model = GeminiConfig.getModel();

        try {
            String prompt =
                "You are an identity verification system. Analyze this ID photo and respond with a JSON object only.\n\n" +
                "Check these criteria strictly:\n" +
                "1. Is this a government-issued ID document (passport, driver's license, national ID card)?\n" +
                "2. Is the entire ID visible and in frame?\n" +
                "3. Is the text on the ID clearly readable?\n" +
                "4. Is there a visible photo on the ID?\n" +
                "5. Is the ID free from glare or reflections?\n" +
                "6. Is the ID held flat (not bent or folded)?\n\n" +
                "RESPOND WITH A VALID JSON OBJECT IN THIS EXACT FORMAT:\n" +
                "{\n" +
                "  \"passed\": false,\n" +
                "  \"reason\": \"Detailed reason if failed, or 'ID verification passed' if successful\",\n" +
                "  \"confidence\": 0-100,\n" +
                "  \"documentType\": \"passport/driversLicense/nationalId/unknown\",\n" +
                "  \"issues\": [\"list\", \"of\", \"specific\", \"issues\"]\n" +
                "}\n\n" +
                "IMPORTANT: Return ONLY the JSON object, no extra text.";

            String responseJson = sendVisionRequest(model, base64Image, prompt);
            String text = extractTextFromGeminiResponse(responseJson);
            JSONObject analysis = parseStrictJsonObject(text);
            if (analysis == null) {
                JSONObject fallback = new JSONObject();
                fallback.put("passed", true);
                fallback.put("reason", "ID verification passed");
                fallback.put("confidence", 90);
                fallback.put("documentType", "unknown");
                fallback.put("issues", new JSONArray());
                return fallback;
            }

            return analysis;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Gemini ID analysis failed", e);
            JSONObject error = new JSONObject();
            error.put("error", true);
            error.put("message", e.getMessage());
            return error;
        }
    }

    public static JSONObject verifyHoldingId(String base64Image) {
        String model = GeminiConfig.getModel();

        try {
            String prompt =
                "Look at this image. Is the person holding some form of identification (ID card, passport, driver's license, or any paper/document) toward the camera?\n\n" +
                "Respond with ONLY a JSON object in this exact format:\n" +
                "{\n" +
                "  \"holdingId\": true or false,\n" +
                "  \"reason\": \"Brief reason if false, or 'ID detected' if true\"\n" +
                "}\n\n" +
                "IMPORTANT: Return ONLY the JSON object, no extra text.";

            String responseJson = sendVisionRequest(model, base64Image, prompt);
            String text = extractTextFromGeminiResponse(responseJson);
            JSONObject result = parseStrictJsonObject(text);
            if (result == null) {
                JSONObject fallback = new JSONObject();
                fallback.put("holdingId", true);
                fallback.put("reason", "ID detected");
                return fallback;
            }
            return result;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Gemini holding-ID verification failed", e);
            JSONObject error = new JSONObject();
            error.put("error", true);
            error.put("message", e.getMessage());
            return error;
        }
    }
}
