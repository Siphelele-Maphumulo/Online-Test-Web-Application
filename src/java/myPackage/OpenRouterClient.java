package myPackage;

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
    }
}