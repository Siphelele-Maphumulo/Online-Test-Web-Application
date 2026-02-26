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
            String rawContent = extractContent(response);
            if (rawContent == null) return null;
            // For question generation, we expect a JSON array; ensure array extraction
            return extractJsonContent(rawContent);
            
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
               "3. Generate exactly " + count + " multiple-choice questions similar to national exam format.\n" +
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
               "- The JSON array MUST contain exactly " + count + " objects.\n" +
               "- Exactly 4 options.\n" +
               "- Correct answer must match one option exactly.\n" +
               "- For multiple correct answers (MultipleSelect), separate them with | in the correct field: \"ans1|ans2\".\n" +
               "- Return ONLY the JSON array. No preamble, no explanation, no markdown blocks.\n" +
               "- Numerical values must be precise as per the guidelines.\n\n" +
               "TEXT:\n" + text;
    }

    private static String createStandardPrompt(String text, String type, int count) {
        return "Generate exactly " + count + " " + type + " questions based on the following text.\n\n" +
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
               "- The JSON array MUST contain exactly " + count + " objects.\n" +
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
                            
                            // For face analysis, expect an object; for question generation, expect an array.
                            // Pass through as-is since face analysis will handle object/array detection.
                            return content;
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

    private static String extractJsonContent(String text) {
        if (text == null) return null;

        // Prefer extracting JSON array first (question generation returns an array)
        int arrayStart = text.indexOf('[');
        int arrayEnd = text.lastIndexOf(']');
        if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
            String json = text.substring(arrayStart, arrayEnd + 1);
            LOGGER.info("Extracted JSON array: " + json.substring(0, Math.min(100, json.length())) + "...");
            return json;
        }

        // Fall back to object extraction
        int objectStart = text.indexOf('{');
        int objectEnd = text.lastIndexOf('}');
        if (objectStart != -1 && objectEnd != -1 && objectEnd > objectStart) {
            String json = text.substring(objectStart, objectEnd + 1);
            LOGGER.info("Extracted JSON object: " + json.substring(0, Math.min(100, json.length())) + "...");
            return json;
        }

        LOGGER.warning("No JSON object or array found in content");
        return text;
    }

private static String compressImage(String base64Image, int maxWidth, float quality) throws Exception {
    // Clean base64 string
    if (base64Image.contains(",")) {
        base64Image = base64Image.split(",")[1];
    }
    
    // Decode base64 to bytes
    byte[] imageBytes = Base64.getDecoder().decode(base64Image);
    BufferedImage originalImage = ImageIO.read(new ByteArrayInputStream(imageBytes));
    
    if (originalImage == null) {
        LOGGER.warning("Could not decode image, returning original");
        return base64Image;
    }
    
    // Calculate new dimensions maintaining aspect ratio
    int originalWidth = originalImage.getWidth();
    int originalHeight = originalImage.getHeight();
    
    if (originalWidth <= maxWidth) {
        LOGGER.info("Image already small enough (" + originalWidth + "px), returning compressed with quality only");
    }
    
    int newWidth = Math.min(originalWidth, maxWidth);
    int newHeight = (int) ((double) originalHeight * newWidth / originalWidth);
    
    // Resize image
    BufferedImage resizedImage = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_INT_RGB);
    resizedImage.getGraphics().drawImage(originalImage.getScaledInstance(newWidth, newHeight, java.awt.Image.SCALE_SMOOTH), 0, 0, null);
    
    // Compress as JPEG with specified quality
    ByteArrayOutputStream compressed = new ByteArrayOutputStream();
    
    // Get JPEG writer and set compression
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
    
    byte[] compressedBytes = compressed.toByteArray();
    String compressedBase64 = Base64.getEncoder().encodeToString(compressedBytes);
    
    double compressionRatio = (double) compressedBytes.length / imageBytes.length;
    LOGGER.info("Image compressed: " + originalWidth + "x" + originalHeight + " → " + newWidth + "x" + newHeight + 
               ", Size: " + (imageBytes.length / 1024) + "KB → " + (compressedBytes.length / 1024) + "KB " +
               "(" + String.format("%.1f", compressionRatio * 100) + "% of original)");
    
    return compressedBase64;
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
            // Clean up base64 string - remove data:image prefix if present
            if (base64Image.contains(",")) {
                base64Image = base64Image.split(",")[1];
            }
            
            // Compress image to save API credits
            try {
                base64Image = compressImage(base64Image, 600, 0.75f); // Max 600px width, 75% quality
            } catch (Exception compressErr) {
                LOGGER.warning("Image compression failed, using original: " + compressErr.getMessage());
                // Continue with original image
            }

            JSONObject payload = new JSONObject();
            payload.put("model", "anthropic/claude-3.5-sonnet"); // Best for vision tasks
            payload.put("temperature", 0.1); // Low temperature for consistent results
            payload.put("max_tokens", 500);

            JSONArray messages = new JSONArray();

            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            
            JSONArray content = new JSONArray();
            
            // Text prompt - FIXED to request proper JSON object
            JSONObject textPart = new JSONObject();
            textPart.put("type", "text");
            textPart.put("text", 
                "You are an identity verification system. Analyze this face photo and respond with a JSON object only.\n\n" +
                "STRICT ACCEPTANCE RULES (must be enforced in your output):\n" +
                "1. Reject if more than one face is visible (faceCount > 1).\n" +
                "2. Reject if the face is not centered in the frame.\n" +
                "3. Reject if there are any obstructions covering key facial features (eyes/nose/mouth).\n" +
                "4. Reject if the face is unclear due to lighting/blur.\n\n" +
                "Return confidence 0-100 for how well the photo meets the requirements.\n" +
                "IMPORTANT: The output MUST be a single JSON OBJECT (NOT an array).\n" +
                "RESPOND WITH A VALID JSON OBJECT IN THIS EXACT FORMAT (NOT AN ARRAY):\n" +
                "{\n" +
                "  \"passed\": true,\n" +
                "  \"reason\": \"Face verification passed\",\n" +
                "  \"confidence\": 95,\n" +
                "  \"faceCount\": 1,\n" +
                "  \"obstructions\": [],\n" +
                "  \"isCentered\": true\n" +
                "}\n\n" +
                "IMPORTANT: Return ONLY the JSON object, no other text, no arrays, no markdown."
            );
            content.put(textPart);
            
            // Image part
            JSONObject imagePart = new JSONObject();
            imagePart.put("type", "image_url");
            JSONObject imageUrl = new JSONObject();
            imageUrl.put("url", "data:image/jpeg;base64," + base64Image);
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
            
            // Parse JSON response - face analysis should return an object
            try {
                // Clean content
                content_str = content_str.replace("```json", "").replace("```", "").trim();
                
                // Face analysis should be an object; if we get an array, it's an error
                if (content_str.trim().startsWith("[")) {
                    LOGGER.warning("Face analysis returned an array unexpectedly; treating as error");
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
        boolean aiPassed = result.optBoolean("passed", true);

        int confidence = result.optInt("confidence", 0);
        int faceCount = result.optInt("faceCount", 0);
        JSONArray obstructions = result.optJSONArray("obstructions");
        boolean isCentered = result.has("isCentered") ? result.optBoolean("isCentered", false) : false;

        // Strict validation rules (server-side)
        boolean strictPassed = true;
        String strictReason = "Face verification passed";

        if (faceCount != 1) {
            strictPassed = false;
            strictReason = (faceCount > 1) ? "More than one face detected" : "No face detected";
        } else if (confidence < 90) {
            strictPassed = false;
            strictReason = "Low confidence (" + confidence + "%) - please retake the photo";
        } else if (obstructions != null && obstructions.length() > 0) {
            strictPassed = false;
            strictReason = "Face obstructed: " + obstructions.toString();
        } else if (!isCentered) {
            strictPassed = false;
            strictReason = "Face not centered - please align your face in the center of the frame";
        }

        if (reason != null) {
            // Prefer strict reason; if strict passed, keep AI reason for extra context
            reason.append(strictPassed ? result.optString("reason", strictReason) : strictReason);
        }

        LOGGER.info("Face analysis confidence: " + confidence + "%");
        LOGGER.info("Face analysis aiPassed: " + aiPassed + ", strictPassed: " + strictPassed + ", faceCount: " + faceCount + ", isCentered: " + isCentered);

        return strictPassed;
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
            // Clean the base64 string
            if (base64Image.contains(",")) {
                base64Image = base64Image.split(",")[1];
            }
            
            // Compress image to save API credits
            try {
                base64Image = compressImage(base64Image, 800, 0.8f); // Max 800px width, 80% quality for ID docs
            } catch (Exception compressErr) {
                LOGGER.warning("ID image compression failed, using original: " + compressErr.getMessage());
                // Continue with original image
            }

            JSONObject payload = new JSONObject();
            payload.put("model", "anthropic/claude-3.5-sonnet"); // Best for vision tasks
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
                "  \"passed\": false,\n" +
                "  \"reason\": \"Detailed reason if failed, or 'ID verification passed' if successful\",\n" +
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
            imageUrl.put("url", "data:image/jpeg;base64," + base64Image);
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
            // Clean up base64 string
            if (base64Image.contains(",")) {
                base64Image = base64Image.split(",")[1];
            }
            
            // Compress image to save API credits
            try {
                base64Image = compressImage(base64Image, 600, 0.75f); // Max 600px width, 75% quality
            } catch (Exception compressErr) {
                LOGGER.warning("ID verification image compression failed, using original: " + compressErr.getMessage());
                // Continue with original image
            }

            JSONObject payload = new JSONObject();
            payload.put("model", "anthropic/claude-3.5-sonnet");
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
                "  \"holdingId\": true or false,\n" +
                "  \"reason\": \"Brief reason if false, or 'ID detected' if true\"\n" +
                "}\n\n" +
                "Examples:\n" +
                "- If they're holding an ID card: {\"holdingId\": true, \"reason\": \"ID card detected\"}\n" +
                "- If no ID visible: {\"holdingId\": false, \"reason\": \"No ID or document visible in frame\"}\n" +
                "- If holding something else: {\"holdingId\": false, \"reason\": \"Holding object but not an ID\"}"
            );
            content.put(textPart);
            
            // Image part
            JSONObject imagePart = new JSONObject();
            imagePart.put("type", "image_url");
            JSONObject imageUrl = new JSONObject();
            imageUrl.put("url", "data:image/jpeg;base64," + base64Image);
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
}
