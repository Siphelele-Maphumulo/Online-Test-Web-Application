package myPackage;

<<<<<<< HEAD
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Client for OpenRouter API to generate educational questions using AI.
 */
public class OpenRouterClient {
    private static String API_KEY = "";
    private static final String API_URL = "https://openrouter.ai/api/v1/chat/completions";
    private static String MODEL = "meta-llama/llama-3-8b-instruct";
    private static final Logger LOGGER = Logger.getLogger(OpenRouterClient.class.getName());

    static {
        loadConfig();
    }

    private static void loadConfig() {
        try (java.io.InputStream input = OpenRouterClient.class.getClassLoader().getResourceAsStream("openrouter.properties")) {
            java.util.Properties prop = new java.util.Properties();
            if (input == null) {
                LOGGER.warning("openrouter.properties not found in classpath. API Key will be empty.");
                return;
            }
            prop.load(input);
            API_KEY = prop.getProperty("openrouter.api.key", "");
            MODEL = prop.getProperty("openrouter.model", "meta-llama/llama-3-8b-instruct");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error loading openrouter.properties", ex);
        }
    }

    /**
     * Generates questions from text using OpenRouter API.
     * @param text The source text to generate questions from.
     * @param questionType The type of questions (MCQ, MultipleSelect, FillInTheBlank, etc.).
     * @param numQuestions The number of questions to generate.
     * @return JSON string containing the generated questions.
     */
    public static String generateQuestions(String text, String questionType, int numQuestions) {
        if (API_KEY == null || API_KEY.trim().isEmpty()) {
            LOGGER.severe("OpenRouter API Key is missing. AI generation will fail.");
            return null;
        }

        // Prevent token overflow by truncating source text
        if (text != null && text.length() > 12000) {
            text = text.substring(0, 12000);
        }

        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(30))
                    .build();
            
            String prompt = "Act as an elite educational content engineer. Your task is to " +
                            "accurately extract or generate exactly " + numQuestions + " high-quality " + questionType + " questions " +
                            "from the provided content.\n\n" +
                            "STRICT FORMATTING RULES:\n" +
                            "- Return STRICT JSON ONLY. No markdown, no prose, no explanations.\n" +
                            "- If extraction: Identify and isolate individual questions. Ignore website artifacts like 'View Answer', 'Report', pagination, or headers.\n" +
                            "- If generation: Use the provided text as context to create high-quality, relevant questions.\n" +
                            "- Question Text: Clean and professional. Remove prefixes like 'Q1:', 'Question 1:'.\n" +
                            "- Options: Exactly 4 distinct options (except for FillInTheBlank which should have an empty array []).\n" +
                            "- Correct Answer:\n" +
                            "  - For MCQ: Must EXACTLY match one of the 4 options.\n" +
                            "  - For MultipleSelect: Combine all correct options using the pipe '|' separator (e.g., 'OptionA|OptionB'). Must match options exactly.\n" +
                            "  - For FillInTheBlank: Provide the precise missing word or phrase.\n" +
                            "  - For True/False: Options must be ['True', 'False'] and correct must be one of them.\n\n" +
                            "Output JSON format:\n" +
                            "{\n" +
                            "  \"questions\": [\n" +
                            "    {\n" +
                            "      \"question\": \"Question text here?\",\n" +
                            "      \"options\": [\"Option 1\", \"Option 2\", \"Option 3\", \"Option 4\"],\n" +
                            "      \"correct\": \"Correct Option Text\"\n" +
                            "    }\n" +
                            "  ]\n" +
                            "}\n\n" +
                            "SOURCE CONTENT:\n" + text;

            JSONObject body = new JSONObject();
            body.put("model", MODEL);
            body.put("max_tokens", 1200);
            body.put("temperature", 0.3);
            
            JSONArray messages = new JSONArray();
            
            // Add system prompt for extra reliability (LLaMA-optimized)
            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content", "You are an exam question generator. Return ONLY valid JSON. No explanations. No markdown. No extra text.");
            messages.put(systemMessage);
            
            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            userMessage.put("content", prompt);
            messages.put(userMessage);
            
            body.put("messages", messages);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL))
                    .header("Authorization", "Bearer " + API_KEY)
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .header("HTTP-Referer", "https://yourdomain.com")
                    .header("X-Title", "Educational Exam System")
                    .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                    .timeout(Duration.ofSeconds(60))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            
            if (response.statusCode() == 200) {
                JSONObject jsonResponse = new JSONObject(response.body());
                String content = jsonResponse.getJSONArray("choices")
                        .getJSONObject(0)
                        .getJSONObject("message")
                        .getString("content");
                
                // Validate JSON strictly
                new JSONObject(content);
                return content;
            } else {
                LOGGER.severe(response.body());
                return null;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error calling OpenRouter API", e);
            return null;
        }
=======
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;


public class OpenRouterClient {
    
    private static final String OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions";
    private static final String API_KEY = System.getenv("OPENROUTER_API_KEY"); // Get API key from environment variable
    
    public static String generateQuestions(String text, String questionType, int numQuestions) {
        // Check if API key is available
        if (API_KEY == null || API_KEY.trim().isEmpty()) {
            // Return a sample response when API key is not configured
            System.out.println("OpenRouter API key not configured. Returning sample response.");
            return generateSampleResponse(questionType, numQuestions);
        }
        
        try {
            // Create the prompt for generating questions
            String prompt = createPrompt(text, questionType, numQuestions);
            
            // Create the request payload
            Map<String, Object> payload = new HashMap<>();
            payload.put("model", "mistralai/mistral-7b-instruct"); // Using a free model
            
            // Structure the message according to OpenRouter API
            Map<String, Object> message = new HashMap<>();
            message.put("role", "user");
            message.put("content", prompt);
            
            payload.put("messages", new Object[]{message});
            
            // Add headers
            Map<String, String> headers = new HashMap<>();
            headers.put("Authorization", "Bearer " + API_KEY);
            headers.put("Content-Type", "application/json");
            // Add required headers for OpenRouter
            headers.put("HTTP-Referer", "https://yourdomain.com"); // Replace with your domain
            headers.put("X-Title", "Online Test Generator"); // Replace with your app name
            
            // Make the API call
            String response = makeApiCall(payload, headers);
            
            // Extract the response text from the JSON response
            return extractResponseText(response);
            
        } catch (Exception e) {
            System.err.println("Error generating questions with OpenRouter: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    private static String createPrompt(String text, String questionType, int numQuestions) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Generate ").append(numQuestions).append(" ").append(questionType).append(" questions based on the following text:\n\n");
        prompt.append(text).append("\n\n");
        
        if ("MCQ".equalsIgnoreCase(questionType)) {
            prompt.append("Format the response as a JSON array of objects with the following structure:\n");
            prompt.append("[{\n");
            prompt.append("  \"question\": \"The question text\",\n");
            prompt.append("  \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"],\n");
            prompt.append("  \"correct\": \"The correct option\"\n");
            prompt.append("}]\n");
        } else if ("TrueFalse".equalsIgnoreCase(questionType)) {
            prompt.append("Format the response as a JSON array of objects with the following structure:\n");
            prompt.append("[{\n");
            prompt.append("  \"question\": \"The true/false question text\",\n");
            prompt.append("  \"options\": [\"True\", \"False\"],\n");
            prompt.append("  \"correct\": \"True or False\"\n");
            prompt.append("}]\n");
        } else {
            // Default to MCQ format
            prompt.append("Format the response as a JSON array of objects with the following structure:\n");
            prompt.append("[{\n");
            prompt.append("  \"question\": \"The question text\",\n");
            prompt.append("  \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"],\n");
            prompt.append("  \"correct\": \"The correct option\"\n");
            prompt.append("}]\n");
        }
        
        prompt.append("Ensure the response is valid JSON format only, with no additional text or explanations.");
        
        return prompt.toString();
    }
    
    private static String makeApiCall(Map<String, Object> payload, Map<String, String> headers) throws Exception {
        URL url = new URL(OPENROUTER_API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        
        // Set request method
        conn.setRequestMethod("POST");
        
        // Set headers
        for (Map.Entry<String, String> header : headers.entrySet()) {
            conn.setRequestProperty(header.getKey(), header.getValue());
        }
        
        // Enable output and input streams
        conn.setDoOutput(true);
        
        // Write the payload
        String payloadString = mapToJson(payload);
        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = payloadString.getBytes("utf-8");
            os.write(input, 0, input.length);
        }
        
        // Get response
        int responseCode = conn.getResponseCode();
        StringBuilder response = new StringBuilder();
        
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), "utf-8"))) {
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
        }
        
        conn.disconnect();
        
        if (responseCode >= 200 && responseCode < 300) {
            return response.toString();
        } else {
            System.err.println("API call failed with response code: " + responseCode);
            System.err.println("Response: " + response.toString());
            return null;
        }
    }
    
    private static String mapToJson(Map<String, Object> map) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        
        boolean first = true;
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) {
                json.append(",");
            }
            json.append("\"").append(entry.getKey()).append("\":");
            
            if (entry.getValue() instanceof String) {
                json.append("\"").append(escapeJson((String) entry.getValue())).append("\"");
            } else {
                json.append(entry.getValue().toString());
            }
            
            first = false;
        }
        
        json.append("}");
        return json.toString();
    }
    
    private static String escapeJson(String str) {
        if (str == null) {
            return null;
        }
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
    
    private static String extractResponseText(String jsonResponse) {
        // Properly extract the content from the JSON response
        try {
            // Look for the choices array and message -> content 
            int choicesIndex = jsonResponse.indexOf("\"choices\"");
            if (choicesIndex != -1) {
                int contentIndex = jsonResponse.indexOf("\"content\":\"");
                if (contentIndex != -1) {
                    contentIndex += 11; // Length of "\"content\":\""
                    int endIndex = jsonResponse.indexOf("\"", contentIndex);
                    if (endIndex != -1) {
                        return jsonResponse.substring(contentIndex, endIndex);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error extracting response text: " + e.getMessage());
        }
        return jsonResponse;
    }
    
    private static String generateSampleResponse(String questionType, int numQuestions) {
        StringBuilder response = new StringBuilder();
        response.append("[");
        
        for (int i = 0; i < numQuestions; i++) {
            if (i > 0) response.append(",");
            
            response.append("{\n");
            response.append("  \"question\": \"Sample ").append(questionType).append(" question #").append(i + 1).append("\",\n");
            
            if ("TrueFalse".equalsIgnoreCase(questionType)) {
                response.append("  \"options\": [\"True\", \"False\"],\n");
                response.append("  \"correct\": \"").append(Math.random() > 0.5 ? "True" : "False").append("\"\n");
            } else {
                response.append("  \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"],\n");
                response.append("  \"correct\": \"Option ").append((char)('A' + (int)(Math.random() * 4))).append("\"\n");
            }
            
            response.append("}");
        }
        
        response.append("]");
        return response.toString();
>>>>>>> 785ce98247cfd24fe2780613ffa7506689f57ec0
    }
}