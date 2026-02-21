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
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import javax.imageio.ImageIO;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

public class OpenRouterClient {
    private static final Logger LOGGER = Logger.getLogger(OpenRouterClient.class.getName());
    private static final String API_URL = "https://openrouter.ai/api/v1/chat/completions";
    
    public static String generateQuestions(String text, String questionType, int numQuestions, boolean isMarkingGuideline) {
        String apiKey = OpenRouterConfig.getApiKey();
        
        if (apiKey == null || apiKey.trim().isEmpty()) {
            LOGGER.severe("OPENROUTER_API_KEY not found in any configuration source.");
            LOGGER.severe("Checked: system property 'openrouter.api.key', environment variable, and openrouter.properties");
            return null;
        }
        
        // Log first few chars of key for debugging (remove or mask in production)
        if (apiKey.length() > 10) {
            LOGGER.info("API Key found: " + apiKey.substring(0, 10) + "...");
        }

        try {
            JSONObject payload = new JSONObject();
            payload.put("model", OpenRouterConfig.getModel());
            payload.put("temperature", 0.3);
            payload.put("max_tokens", 2500);

            JSONArray messages = new JSONArray();

            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content", "You are an expert Accounting examiner. You specialize in generating high-quality exam questions from marking guidelines.");
            messages.put(systemMessage);

            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            userMessage.put("content", isMarkingGuideline ? createMarkingGuidelinePrompt(text, numQuestions) : createStandardPrompt(text, questionType, numQuestions));
            messages.put(userMessage);

            payload.put("messages", messages);

            LOGGER.info("Sending request to OpenRouter API (" + OpenRouterConfig.getModel() + ")...");
            String response = sendRequest(payload.toString(), apiKey);
            
            if (response == null) {
                LOGGER.severe("Received null response from API");
                return null;
            }
            
            LOGGER.info("Received response from API, extracting content...");
            return extractContent(response);
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error calling OpenRouter API", e);
            return null;
        }
    }

    private static String createMarkingGuidelinePrompt(String text, int count) {
        return "You are an expert Accounting examiner.\n\n" +
               "TASK:\n" +
               "1. Analyze the provided Accounting Marking Guideline text.\n" +
               "2. Extract examinable concepts (Calculations, Theory, Financial Indicators).\n" +
               "3. Generate approximately " + count + " multiple-choice questions similar to national exam format.\n" +
               "4. Extract the correct numerical answer from the 'ANSWER' or final results section.\n" +
               "5. Use the 'WORKINGS' section to identify common accounting errors and use those to generate plausible distractors.\n" +
               "6. Create 3 plausible distractors for each question.\n" +
               "7. Maintain exam-level difficulty.\n\n" +
               "FORMAT STRICTLY AS JSON ARRAY:\n" +
               "[\n" +
               "  {\n" +
               "    \"question\": \"The specific calculation or theory question stem\",\n" +
               "    \"options\": [\"Correct Answer\", \"Distractor 1\", \"Distractor 2\", \"Distractor 3\"],\n" +
               "    \"correct\": \"Correct Answer\",\n" +
               "    \"type\": \"MCQ\"\n" +
               "  }\n" +
               "]\n\n" +
               "RULES:\n" +
               "- Exactly 4 options.\n" +
               "- Correct answer must match one option exactly.\n" +
               "- For multiple correct answers (MultipleSelect), separate them with | in the correct field: \"ans1|ans2\".\n" +
               "- Return ONLY the JSON array. No preamble, no explanation, no markdown blocks.\n" +
               "- Numerical values must be precise as per the guidelines.\n\n" +
               "TEXT:\n" + text;
    }

    private static String createStandardPrompt(String text, String type, int count) {
        return "Generate " + count + " " + type + " questions based on the following text.\n\n" +
               "FORMAT STRICTLY AS JSON ARRAY:\n" +
               "[\n" +
               "  {\n" +
               "    \"question\": \"...\",\n" +
               "    \"options\": " + ("TrueFalse".equalsIgnoreCase(type) ? "[\"True\", \"False\"]" : "[\"Option A\", \"Option B\", \"Option C\", \"Option D\"]") + ",\n" +
               "    \"correct\": \"...\",\n" +
               "    \"type\": \"" + type + "\"\n" +
               "  }\n" +
               "]\n\n" +
               "RULES:\n" +
               "- Return ONLY valid JSON array.\n" +
               "- No extra text.\n\n" +
               "TEXT:\n" + text;
    }

    private static String sendRequest(String jsonPayload, String apiKey) throws Exception {
        URL url = new URL(API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization", "Bearer " + apiKey);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("HTTP-Referer", "https://codesa-institute.co.za");
        conn.setRequestProperty("X-Title", "Accounting Question Generator");

        conn.setDoOutput(true);
        conn.setConnectTimeout(30000); // 30 seconds timeout
        conn.setReadTimeout(60000); // 60 seconds timeout

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
            os.flush();
        }

        int responseCode = conn.getResponseCode();
        LOGGER.info("API Response Code: " + responseCode);
        
        InputStream is;
        if (responseCode >= 200 && responseCode < 300) {
            is = conn.getInputStream();
        } else {
            is = conn.getErrorStream();
            if (is == null) {
                LOGGER.severe("API Error (" + responseCode + ") and error stream is null");
                return null;
            }
            // Read error stream for debugging
            StringBuilder errorResponse = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    errorResponse.append(line);
                }
            }
            LOGGER.severe("API Error Response (" + responseCode + "): " + errorResponse.toString());
            throw new IOException("API returned error code " + responseCode + ": " + errorResponse.toString());
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
            LOGGER.info("Attempting to parse response: " + response.substring(0, Math.min(response.length(), 500)) + "...");

            JSONObject root = new JSONObject(response);
            if (root.has("choices")) {
                JSONArray choices = root.getJSONArray("choices");
                if (choices.length() > 0) {
                    JSONObject choice = choices.getJSONObject(0);
                    if (choice.has("message")) {
                        JSONObject message = choice.getJSONObject("message");
                        if (message.has("content")) {
                            String content = message.getString("content");
                            LOGGER.info("Extracted content length: " + content.length());
                            
                            // Use new extractJsonContent method
                            return extractJsonContent(content);
                        } else {
                            LOGGER.severe("Response JSON missing 'content' field in 'message'.");
                            LOGGER.severe("Parsed JSON structure (partial): " + root.toString(2));
                            return null;
                        }
                    } else {
                        LOGGER.severe("Response JSON missing 'message' field in 'choices[0]'.");
                        LOGGER.severe("Parsed JSON structure (partial): " + root.toString(2));
                        return null;
                    }
                } else {
                    LOGGER.severe("Response JSON 'choices' array is empty.");
                    LOGGER.severe("Parsed JSON structure (partial): " + root.toString(2));
                    return null;
                }
            } else {
                LOGGER.severe("Response JSON missing 'choices' array.");
                LOGGER.severe("Parsed JSON structure (partial): " + root.toString(2));
                return null;
            }
        } catch (JSONException e) {
            LOGGER.log(Level.SEVERE, "Failed to parse API response JSON", e);
            LOGGER.severe("Response string was: " + response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error during content extraction", e);
            LOGGER.severe("Response string was: " + response);
        }
        return null;
    }
    
    private static String extractJsonArray(String text) {
        // Find the first [ and last ]
        int start = text.indexOf('[');
        int end = text.lastIndexOf(']');
        if (start != -1 && end != -1 && end > start) {
            String json = text.substring(start, end + 1);
            LOGGER.info("Extracted JSON array: " + json.substring(0, Math.min(100, json.length())) + "...");
            return json;
        }
        LOGGER.warning("No JSON array found in content");
        return text;
    }
    
    /**
     * Extracts JSON content from text, handling both objects and arrays
     */
    private static String extractJsonContent(String text) {
        // First try to find JSON object { ... }
        int objectStart = text.indexOf('{');
        int objectEnd = text.lastIndexOf('}');
        
        if (objectStart != -1 && objectEnd != -1 && objectEnd > objectStart) {
            String json = text.substring(objectStart, objectEnd + 1);
            LOGGER.info("Extracted JSON object: " + json.substring(0, Math.min(100, json.length())) + "...");
            return json;
        }
        
        // Fall back to array detection
        int arrayStart = text.indexOf('[');
        int arrayEnd = text.lastIndexOf(']');
        if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
            String json = text.substring(arrayStart, arrayEnd + 1);
            LOGGER.info("Extracted JSON array: " + json.substring(0, Math.min(100, json.length())) + "...");
            return json;
        }
        
        LOGGER.warning("No JSON object or array found in content");
        return text;
    }

    /**
     * Analyzes a face photo for identity verification quality
     * @param base64Image The captured face photo as base64 string (with or without data:image prefix)
     * @return JSONObject with analysis results: {"passed": boolean, "reason": string, "confidence": number}
     */
    public static JSONObject analyzeFacePhoto(String base64Image) {
        String apiKey = OpenRouterConfig.getApiKey();
        
        if (apiKey == null || apiKey.trim().isEmpty()) {
            LOGGER.severe("OPENROUTER_API_KEY not found for face analysis");
            return createFallbackResult(true, "API key not configured");
        }

        try {
            // Pre-process image: Resize and compress reasonably
            LOGGER.info("Sending face photo for analysis...");
            base64Image = resizeImage(base64Image);

            // Clean up base64 string - remove data:image prefix if present for the API payload
            String apiBase64 = base64Image;
            if (apiBase64.contains(",")) {
                apiBase64 = apiBase64.split(",")[1];
            }

            JSONObject payload = new JSONObject();
            payload.put("model", OpenRouterConfig.getVisionModel());
            payload.put("temperature", 0.1); // Low temperature for consistent results
            payload.put("max_tokens", 500);

            JSONArray messages = new JSONArray();

            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            
            JSONArray content = new JSONArray();
            
            // Text prompt
            JSONObject textPart = new JSONObject();
            textPart.put("type", "text");
            textPart.put("text", 
                "You are an identity verification system. Analyze this face photo and respond with a JSON object only.\n\n" +
                "Check these criteria strictly:\n" +
                "1. Is there exactly ONE clearly visible face?\n" +
                "2. Is face properly positioned (centered, not too close/far)?\n" +
                "3. Is face free from obstructions (no masks, sunglasses, hats covering eyes)?\n" +
                "4. Is lighting adequate (face clearly visible, not too dark or overexposed)?\n" +
                "5. Is person looking directly at the camera?\n\n" +
                "RESPOND WITH A VALID JSON OBJECT IN THIS EXACT FORMAT:\n" +
                "{\n" +
                "  \"passed\": boolean,\n" +
                "  \"reason\": \"Detailed reason if failed, or 'Face verification passed'\",\n" +
                "  \"confidence\": 0-100,\n" +
                "  \"faceCount\": number,\n" +
                "  \"obstructions\": []\n" +
                "}\n\n" +
                "IMPORTANT: Return ONLY the JSON object, no other text."
            );
            content.put(textPart);
            
            // Image part
            JSONObject imagePart = new JSONObject();
            imagePart.put("type", "image_url");
            JSONObject imageUrl = new JSONObject();
            imageUrl.put("url", "data:image/jpeg;base64," + apiBase64);
            imagePart.put("image_url", imageUrl);
            content.put(imagePart);
            
            userMessage.put("content", content);
            messages.put(userMessage);

            payload.put("messages", messages);

            LOGGER.info("Sending face photo to OpenRouter for analysis...");
            String response = sendRequest(payload.toString(), apiKey);
            
            if (response == null) {
                LOGGER.severe("Received null response from face analysis API");
                return createFallbackResult(true, "API returned null");
            }
            
            LOGGER.info("Received face analysis response, extracting content...");
            String content_str = extractContent(response);
            
            if (content_str == null) {
                return createFallbackResult(true, "Could not extract content");
            }
            
            // Parse JSON response - handle both object and array
            try {
                // Clean content
                content_str = content_str.replace("```json", "").replace("```", "").trim();
                
                // Check if it's an array
                if (content_str.trim().startsWith("[")) {
                    JSONArray errorArray = new JSONArray(content_str);
                    // Convert array to proper object format
                    JSONObject result = new JSONObject();
                    result.put("passed", false);
                    result.put("reason", errorArray.length() > 0 ? errorArray.getString(0) : "Verification failed");
                    result.put("confidence", 50);
                    result.put("faceCount", 1);
                    result.put("obstructions", errorArray);
                    LOGGER.info("Converted array response to object: " + result.toString());
                    return result;
                }
                
                // Normal object parsing
                JSONObject result = new JSONObject(content_str);
                LOGGER.info("Face analysis result: " + result.toString());
                return result;
                
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed to parse face analysis JSON: " + content_str, e);
                
                // Try to extract any useful message from response
                if (content_str.contains("gaze") || content_str.contains("looking")) {
                    JSONObject fallback = new JSONObject();
                    fallback.put("passed", false);
                    fallback.put("reason", "Please look directly at the camera");
                    fallback.put("confidence", 50);
                    fallback.put("faceCount", 1);
                    fallback.put("obstructions", new JSONArray());
                    return fallback;
                }
                
                return createFallbackResult(true, "Failed to parse AI response");
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error calling OpenRouter for face analysis", e);
            return createFallbackResult(true, "Error: " + e.getMessage());
        }
    }
    
    /**
     * Simplified version that just returns pass/fail with reason
     */
    public static boolean isFacePhotoValid(String base64Image, StringBuilder reason) {
        JSONObject result = analyzeFacePhoto(base64Image);
        boolean passed = result.optBoolean("passed", true);
        
        if (reason != null) {
            reason.append(result.optString("reason", "Unknown"));
        }
        
        // Log confidence for debugging
        LOGGER.info("Face analysis confidence: " + result.optInt("confidence", 0) + "%");
        
        return passed;
    }
    
    /**
     * Creates a fallback result when API is unavailable
     */
    private static JSONObject createFallbackResult(boolean passed, String reason) {
        JSONObject fallback = new JSONObject();
        fallback.put("passed", passed);
        fallback.put("reason", reason + " - using fallback approval");
        fallback.put("confidence", 50);
        fallback.put("faceCount", 1);
        fallback.put("obstructions", new JSONArray());
        return fallback;
    }
    
    /**
     * Analyzes an ID photo to verify it's a valid government ID
     * @param base64Image The captured ID photo as base64 string
     * @return JSONObject with analysis results
     */
    public static JSONObject analyzeIdPhoto(String base64Image) {
        String apiKey = OpenRouterConfig.getApiKey();
        
        if (apiKey == null || apiKey.trim().isEmpty()) {
            LOGGER.severe("OPENROUTER_API_KEY not found for ID analysis");
            return createFallbackIdResult(true, "API key not configured");
        }

        try {
            // Pre-process image
            LOGGER.info("Sending ID photo for analysis...");
            base64Image = resizeImage(base64Image);

            // Clean the base64 string
            String apiBase64 = base64Image;
            if (apiBase64.contains(",")) {
                apiBase64 = apiBase64.split(",")[1];
            }

            JSONObject payload = new JSONObject();
            payload.put("model", OpenRouterConfig.getVisionModel());
            payload.put("temperature", 0.1);
            payload.put("max_tokens", 800);

            JSONArray messages = new JSONArray();
            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            
            JSONArray content = new JSONArray();
            
            // Text prompt for ID verification
            JSONObject textPart = new JSONObject();
            textPart.put("type", "text");
            textPart.put("text", 
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
                "  \"passed\": boolean,\n" +
                "  \"reason\": \"Detailed reason if failed, or 'ID verification passed'\",\n" +
                "  \"confidence\": 0-100,\n" +
                "  \"documentType\": \"passport/driversLicense/nationalId/unknown\",\n" +
                "  \"issues\": [\"list\", \"of\", \"specific\", \"issues\"]\n" +
                "}\n\n" +
                "IMPORTANT: Return ONLY the JSON object, no other text."
            );
            content.put(textPart);
            
            // Image part
            JSONObject imagePart = new JSONObject();
            imagePart.put("type", "image_url");
            JSONObject imageUrl = new JSONObject();
            imageUrl.put("url", "data:image/jpeg;base64," + apiBase64);
            imagePart.put("image_url", imageUrl);
            content.put(imagePart);
            
            userMessage.put("content", content);
            messages.put(userMessage);
            payload.put("messages", messages);

            LOGGER.info("Sending ID photo to OpenRouter for analysis...");
            String response = sendRequest(payload.toString(), apiKey);
            
            if (response == null) {
                LOGGER.severe("Received null response from ID analysis API");
                return createFallbackIdResult(true, "API returned null");
            }
            
            LOGGER.info("Received ID analysis response, extracting content...");
            String content_str = extractContent(response);
            
            if (content_str == null) {
                return createFallbackIdResult(true, "Could not extract content");
            }
            
            // Parse the JSON response
            try {
                content_str = content_str.replace("```json", "").replace("```", "").trim();
                
                // Handle array responses if they occur
                if (content_str.trim().startsWith("[")) {
                    JSONArray errorArray = new JSONArray(content_str);
                    JSONObject result = new JSONObject();
                    result.put("passed", false);
                    result.put("reason", errorArray.length() > 0 ? errorArray.getString(0) : "ID verification failed");
                    result.put("confidence", 50);
                    result.put("documentType", "unknown");
                    result.put("issues", errorArray);
                    LOGGER.info("Converted array response to object: " + result.toString());
                    return result;
                }
                
                JSONObject result = new JSONObject(content_str);
                LOGGER.info("ID analysis result: " + result.toString());
                return result;
                
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed to parse ID analysis JSON: " + content_str, e);
                return createFallbackIdResult(true, "Failed to parse AI response");
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error calling OpenRouter for ID analysis", e);
            return createFallbackIdResult(true, "Error: " + e.getMessage());
        }
    }
    
    /**
     * Simplified version for ID verification
     */
    public static boolean isIdPhotoValid(String base64Image, StringBuilder reason) {
        JSONObject result = analyzeIdPhoto(base64Image);
        boolean passed = result.optBoolean("passed", true);
        
        if (reason != null) {
            reason.append(result.optString("reason", "Unknown"));
        }
        
        LOGGER.info("ID analysis confidence: " + result.optInt("confidence", 0) + "%");
        if (!passed) {
            JSONArray issues = result.optJSONArray("issues");
            if (issues != null && issues.length() > 0) {
                LOGGER.info("ID issues: " + issues.toString());
            }
        }
        
        return passed;
    }
    
    /**
     * Creates a fallback result for ID verification
     */
    private static JSONObject createFallbackIdResult(boolean passed, String reason) {
        JSONObject fallback = new JSONObject();
        fallback.put("passed", passed);
        fallback.put("reason", reason + " - using fallback approval");
        fallback.put("confidence", 50);
        fallback.put("documentType", "unknown");
        fallback.put("issues", new JSONArray());
        return fallback;
    }
    
    /**
     * Simplified ID verification - checks if user is holding an ID/card/paper toward camera
     * @param base64Image The captured ID photo as base64 string
     * @return JSONObject with simple pass/fail result
     */
    public static JSONObject verifyHoldingId(String base64Image) {
        String apiKey = OpenRouterConfig.getApiKey();
        
        if (apiKey == null || apiKey.trim().isEmpty()) {
            LOGGER.severe("OPENROUTER_API_KEY not found for ID verification");
            return createSimpleIdResult(true, "API key not configured");
        }

        try {
            // Pre-process image
            base64Image = resizeImage(base64Image);

            // Clean up base64 string
            String apiBase64 = base64Image;
            if (apiBase64.contains(",")) {
                apiBase64 = apiBase64.split(",")[1];
            }

            JSONObject payload = new JSONObject();
            payload.put("model", OpenRouterConfig.getVisionModel());
            payload.put("temperature", 0.1);
            payload.put("max_tokens", 300);

            JSONArray messages = new JSONArray();
            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            
            JSONArray content = new JSONArray();
            
            // Simple prompt - just check if holding ID/card/paper
            JSONObject textPart = new JSONObject();
            textPart.put("type", "text");
            textPart.put("text", 
                "Look at this image. Is the person holding some form of identification (ID card, passport, driver's license, or any paper/document) toward the camera?\n\n" +
                "Respond with ONLY a JSON object in this exact format:\n" +
                "{\n" +
                "  \"holdingId\": boolean,\n" +
                "  \"reason\": \"Brief reason if false, or 'ID detected' if true\"\n" +
                "}\n\n" +
                "IMPORTANT: Return ONLY the JSON object."
            );
            content.put(textPart);
            
            // Image part
            JSONObject imagePart = new JSONObject();
            imagePart.put("type", "image_url");
            JSONObject imageUrl = new JSONObject();
            imageUrl.put("url", "data:image/jpeg;base64," + apiBase64);
            imagePart.put("image_url", imageUrl);
            content.put(imagePart);
            
            userMessage.put("content", content);
            messages.put(userMessage);
            payload.put("messages", messages);

            LOGGER.info("Sending ID photo to OpenRouter for simple verification...");
            String response = sendRequest(payload.toString(), apiKey);
            
            if (response == null) {
                return createSimpleIdResult(true, "API unavailable");
            }
            
            String content_str = extractContent(response);
            if (content_str == null) {
                return createSimpleIdResult(true, "Could not extract content");
            }
            
            // Clean and parse response
            content_str = content_str.replace("```json", "").replace("```", "").trim();
            
            // Handle array responses
            if (content_str.trim().startsWith("[")) {
                JSONArray arr = new JSONArray(content_str);
                JSONObject result = new JSONObject();
                result.put("holdingId", false);
                result.put("reason", arr.length() > 0 ? arr.getString(0) : "ID not detected");
                return result;
            }
            
            // Parse as JSON object
            JSONObject result = new JSONObject(content_str);
            LOGGER.info("ID verification result: " + result.toString());
            return result;
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in ID verification", e);
            return createSimpleIdResult(true, "Error: " + e.getMessage());
        }
    }
    
    /**
     * Simple check - returns true if holding ID
     */
    public static boolean isHoldingId(String base64Image, StringBuilder reason) {
        JSONObject result = verifyHoldingId(base64Image);
        boolean holdingId = result.optBoolean("holdingId", true);
        
        if (reason != null) {
            reason.append(result.optString("reason", "Unknown"));
        }
        
        return holdingId;
    }
    
    /**
     * Creates a simple fallback result
     */
    private static JSONObject createSimpleIdResult(boolean holdingId, String reason) {
        JSONObject fallback = new JSONObject();
        fallback.put("holdingId", holdingId);
        fallback.put("reason", reason);
        return fallback;
    }

    /**
     * Resizes and compresses a base64 image to ensure it's suitable for AI analysis
     * without losing too much detail.
     */
    public static String resizeImage(String base64Image) {
        if (base64Image == null || base64Image.isEmpty()) return base64Image;

        try {
            // Clean base64 string
            String pureBase64 = base64Image;
            if (base64Image.contains(",")) {
                pureBase64 = base64Image.split(",")[1];
            }

            byte[] imageBytes = Base64.getDecoder().decode(pureBase64);
            int originalSize = imageBytes.length;

            BufferedImage originalImage = ImageIO.read(new ByteArrayInputStream(imageBytes));
            if (originalImage == null) return base64Image;

            int width = originalImage.getWidth();
            int height = originalImage.getHeight();

            // Target dimensions (max 1024px while maintaining aspect ratio)
            int targetWidth = width;
            int targetHeight = height;
            int maxSize = 1024;

            if (width > maxSize || height > maxSize) {
                if (width > height) {
                    targetWidth = maxSize;
                    targetHeight = (height * maxSize) / width;
                } else {
                    targetHeight = maxSize;
                    targetWidth = (width * maxSize) / height;
                }
            } else if (originalSize < 150 * 1024) {
                // If already small enough (under 150KB) and not too big dimensions, return original
                return base64Image;
            }

            BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
            Graphics2D g2d = resizedImage.createGraphics();

            // Set rendering hints for better quality scaling
            g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g2d.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

            // Draw original image onto the resized canvas (synchronously)
            g2d.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
            g2d.dispose();

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            // Write as JPG
            ImageIO.write(resizedImage, "jpg", baos);
            byte[] resizedBytes = baos.toByteArray();

            double reduction = 100.0 * (1.0 - (double)resizedBytes.length / originalSize);
            LOGGER.info("Image compression: " + originalSize + " -> " + resizedBytes.length + " bytes (" + String.format("%.0f", reduction) + "% reduction)");

            // Return with original prefix if it had one
            String prefix = "";
            if (base64Image.contains(",")) {
                prefix = base64Image.split(",")[0] + ",";
            }

            return prefix + Base64.getEncoder().encodeToString(resizedBytes);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Image resize failed, using original", e);
            return base64Image;
        }
    }
}
