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
import java.util.logging.Level;
import java.util.logging.Logger;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.Iterator;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriter;
import javax.imageio.ImageWriteParam;
import javax.imageio.stream.ImageOutputStream;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

public class GeminiClient {
    private static final Logger LOGGER = Logger.getLogger(GeminiClient.class.getName());
    private static final String API_BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models/";

    private static String sendRequest(String jsonPayload, String apiKey, String model) throws Exception {
        String urlString = API_BASE_URL + model + ":generateContent?key=" + apiKey;
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");

        conn.setDoOutput(true);
        conn.setConnectTimeout(30000);
        conn.setReadTimeout(60000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
            os.flush();
        }

        int responseCode = conn.getResponseCode();
        LOGGER.info("Gemini API Response Code: " + responseCode);

        InputStream is;
        if (responseCode >= 200 && responseCode < 300) {
            is = conn.getInputStream();
        } else {
            is = conn.getErrorStream();
            if (is == null) {
                LOGGER.severe("Gemini API Error (" + responseCode + ") and error stream is null");
                return null;
            }
            StringBuilder errorResponse = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    errorResponse.append(line);
                }
            }
            LOGGER.severe("Gemini API Error Response (" + responseCode + "): " + errorResponse.toString());
            throw new IOException("Gemini API returned error code " + responseCode + ": " + errorResponse.toString());
        }

        StringBuilder response = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
        }

        conn.disconnect();
        return response.toString();
    }

    private static String extractContent(String response) {
        try {
            JSONObject root = new JSONObject(response);
            if (root.has("candidates")) {
                JSONArray candidates = root.getJSONArray("candidates");
                if (candidates.length() > 0) {
                    JSONObject candidate = candidates.getJSONObject(0);
                    if (candidate.has("content")) {
                        JSONObject content = candidate.getJSONObject("content");
                        if (content.has("parts")) {
                            JSONArray parts = content.getJSONArray("parts");
                            if (parts.length() > 0) {
                                return parts.getJSONObject(0).getString("text");
                            }
                        }
                    }
                }
            }
            LOGGER.severe("Could not extract text from Gemini response: " + response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error parsing Gemini response", e);
        }
        return null;
    }

    private static String compressImage(String base64Image, int maxWidth, float quality) throws Exception {
        if (base64Image.contains(",")) {
            base64Image = base64Image.split(",")[1];
        }

        byte[] imageBytes = Base64.getDecoder().decode(base64Image);
        BufferedImage originalImage = ImageIO.read(new ByteArrayInputStream(imageBytes));

        if (originalImage == null) {
            LOGGER.warning("Could not decode image, returning original");
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
        if (!writers.hasNext()) throw new IllegalStateException("No JPEG writers found");

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

    public static JSONObject analyzeFacePhoto(String base64Image) {
        String apiKey = GeminiConfig.getApiKey();
        String model = GeminiConfig.getModel();

        try {
            if (base64Image.contains(",")) base64Image = base64Image.split(",")[1];
            try { base64Image = compressImage(base64Image, 600, 0.75f); } catch (Exception ignore) {}

            JSONObject payload = new JSONObject();
            JSONArray contents = new JSONArray();
            JSONObject content = new JSONObject();
            JSONArray parts = new JSONArray();

            JSONObject textPart = new JSONObject();
            textPart.put("text",
                "You are an identity verification system. Analyze this face photo STRICTLY and respond with a JSON object.\n" +
                "CRITICAL VALIDATION RULES:\n" +
                "1. EXACTLY ONE face must be visible\n" +
                "2. Face must be CENTERED\n" +
                "3. NO obstructions (eyes, nose, mouth)\n" +
                "4. CLEAR and well-lit\n" +
                "5. Looking directly at camera\n" +
                "6. No hats, sunglasses, masks\n" +
                "7. Neutral background\n\n" +
                "Return JSON:\n" +
                "{\n" +
                "  \"passed\": boolean,\n" +
                "  \"reason\": \"explanation\",\n" +
                "  \"confidence\": 0-100,\n" +
                "  \"faceCount\": number,\n" +
                "  \"obstructions\": [],\n" +
                "  \"isCentered\": boolean,\n" +
                "  \"lighting\": \"good/poor\",\n" +
                "  \"lookingAtCamera\": boolean\n" +
                "}"
            );
            parts.put(textPart);

            JSONObject imagePart = new JSONObject();
            JSONObject inlineData = new JSONObject();
            inlineData.put("mime_type", "image/jpeg");
            inlineData.put("data", base64Image);
            imagePart.put("inline_data", inlineData);
            parts.put(imagePart);

            content.put("parts", parts);
            contents.put(content);
            payload.put("contents", contents);

            JSONObject generationConfig = new JSONObject();
            generationConfig.put("response_mime_type", "application/json");
            payload.put("generationConfig", generationConfig);

            String response = sendRequest(payload.toString(), apiKey, model);
            String contentStr = extractContent(response);

            JSONObject analysis = new JSONObject(contentStr);
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("analysis", analysis);
            return result;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in Gemini face analysis", e);
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("reason", e.getMessage());
            return error;
        }
    }

    public static boolean isFacePhotoValid(String base64Image, StringBuilder reason) {
        JSONObject result = analyzeFacePhoto(base64Image);
        if (!result.optBoolean("success")) {
            if (reason != null) reason.append(result.optString("reason", "System error"));
            return false;
        }
        JSONObject analysis = result.getJSONObject("analysis");
        boolean passed = analysis.optBoolean("passed", false);
        if (reason != null) reason.append(analysis.optString("reason", ""));
        return passed;
    }

    public static JSONObject analyzeIdPhoto(String base64Image) {
        String apiKey = GeminiConfig.getApiKey();
        String model = GeminiConfig.getModel();

        try {
            if (base64Image.contains(",")) base64Image = base64Image.split(",")[1];
            try { base64Image = compressImage(base64Image, 800, 0.8f); } catch (Exception ignore) {}

            JSONObject payload = new JSONObject();
            JSONArray contents = new JSONArray();
            JSONObject content = new JSONObject();
            JSONArray parts = new JSONArray();

            JSONObject textPart = new JSONObject();
            textPart.put("text",
                "Analyze this ID photo and respond with JSON:\n" +
                "{\n" +
                "  \"passed\": boolean,\n" +
                "  \"reason\": \"explanation\",\n" +
                "  \"confidence\": 0-100,\n" +
                "  \"documentType\": \"passport/driversLicense/nationalId/unknown\",\n" +
                "  \"issues\": []\n" +
                "}"
            );
            parts.put(textPart);

            JSONObject imagePart = new JSONObject();
            JSONObject inlineData = new JSONObject();
            inlineData.put("mime_type", "image/jpeg");
            inlineData.put("data", base64Image);
            imagePart.put("inline_data", inlineData);
            parts.put(imagePart);

            content.put("parts", parts);
            contents.put(content);
            payload.put("contents", contents);

            JSONObject generationConfig = new JSONObject();
            generationConfig.put("response_mime_type", "application/json");
            payload.put("generationConfig", generationConfig);

            String response = sendRequest(payload.toString(), apiKey, model);
            String contentStr = extractContent(response);

            return new JSONObject(contentStr);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in Gemini ID analysis", e);
            JSONObject error = new JSONObject();
            error.put("passed", false);
            error.put("reason", e.getMessage());
            return error;
        }
    }

    public static boolean isIdPhotoValid(String base64Image, StringBuilder reason) {
        JSONObject result = analyzeIdPhoto(base64Image);
        boolean passed = result.optBoolean("passed", false);
        if (reason != null) reason.append(result.optString("reason", ""));
        return passed;
    }

    public static JSONObject verifyHoldingId(String base64Image) {
        String apiKey = GeminiConfig.getApiKey();
        String model = GeminiConfig.getModel();

        try {
            if (base64Image.contains(",")) base64Image = base64Image.split(",")[1];
            try { base64Image = compressImage(base64Image, 600, 0.75f); } catch (Exception ignore) {}

            JSONObject payload = new JSONObject();
            JSONArray contents = new JSONArray();
            JSONObject content = new JSONObject();
            JSONArray parts = new JSONArray();

            JSONObject textPart = new JSONObject();
            textPart.put("text",
                "Is the person holding identification toward the camera? Respond with JSON:\n" +
                "{\n" +
                "  \"holdingId\": boolean,\n" +
                "  \"reason\": \"explanation\"\n" +
                "}"
            );
            parts.put(textPart);

            JSONObject imagePart = new JSONObject();
            JSONObject inlineData = new JSONObject();
            inlineData.put("mime_type", "image/jpeg");
            inlineData.put("data", base64Image);
            imagePart.put("inline_data", inlineData);
            parts.put(imagePart);

            content.put("parts", parts);
            contents.put(content);
            payload.put("contents", contents);

            JSONObject generationConfig = new JSONObject();
            generationConfig.put("response_mime_type", "application/json");
            payload.put("generationConfig", generationConfig);

            String response = sendRequest(payload.toString(), apiKey, model);
            String contentStr = extractContent(response);

            return new JSONObject(contentStr);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in Gemini holding ID verification", e);
            JSONObject error = new JSONObject();
            error.put("holdingId", false);
            error.put("reason", e.getMessage());
            return error;
        }
    }

    public static boolean isHoldingId(String base64Image, StringBuilder reason) {
        JSONObject result = verifyHoldingId(base64Image);
        boolean holdingId = result.optBoolean("holdingId", false);
        if (reason != null) reason.append(result.optString("reason", ""));
        return holdingId;
    }
}
