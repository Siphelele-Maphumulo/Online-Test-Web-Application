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
    private static String MODEL = "openai/gpt-4o-mini";
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
            MODEL = prop.getProperty("openrouter.model", "openai/gpt-4o-mini");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error loading openrouter.properties", ex);
        }
    }

    /**
     * Generates questions from text using OpenRouter API.
     * @param text The source text to generate questions from.
     * @param questionType The type of questions (Forced to MCQ by this method).
     * @param numQuestions The number of questions to generate.
     * @return JSON string containing the generated questions.
     */
    public static String generateQuestions(String text, String questionType, int numQuestions) {
        if (API_KEY == null || API_KEY.trim().isEmpty()) {
            LOGGER.severe("OpenRouter API Key is missing. AI generation will fail.");
            return null;
        }

        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(30))
                    .build();
            
            String prompt = "You are an exam question generator.\n\n" +
                            "Rules:\n" +
                            "- Generate ONLY multiple-choice questions.\n" +
                            "- Each question MUST have exactly 4 options.\n" +
                            "- EXACTLY ONE option must be correct.\n" +
                            "- Return STRICT JSON ONLY.\n" +
                            "- No markdown.\n" +
                            "- No explanations.\n" +
                            "- No prose.\n" +
                            "- No extra text.\n" +
                            "- No numbering outside JSON.\n\n" +
                            "From the content below:\n" +
                            "1. If existing questions are found (e.g. \"Q1\", \"Question 1\"), extract and normalize them.\n" +
                            "2. Otherwise, generate new questions.\n\n" +
                            "Generate " + numQuestions + " UNIQUE multiple-choice questions.\n\n" +
                            "Output JSON format:\n" +
                            "{\n" +
                            "  \"questions\": [\n" +
                            "    {\n" +
                            "      \"question\": \"...\",\n" +
                            "      \"options\": [\"A\", \"B\", \"C\", \"D\"],\n" +
                            "      \"correct\": \"EXACT_OPTION_TEXT\"\n" +
                            "    }\n" +
                            "  ]\n" +
                            "}\n\n" +
                            "Content:\n" + text;

            JSONObject body = new JSONObject();
            body.put("model", MODEL);
            body.put("max_tokens", 2500);
            body.put("temperature", 0.4);
            
            JSONArray messages = new JSONArray();

            // Add system prompt for extra reliability
            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content", "You are an exam question generator. Return STRICT JSON ONLY. No markdown. No prose.");
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
                    .header("HTTP-Referer", "https://github.com/OpenRouterTeam/openrouter-runner")
                    .header("X-Title", "Educational Exam System")
                    .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                    .timeout(Duration.ofSeconds(60))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            
            if (response.statusCode() == 200) {
                JSONObject jsonResponse = new JSONObject(response.body());
                return jsonResponse.getJSONArray("choices")
                        .getJSONObject(0)
                        .getJSONObject("message")
                        .getString("content");
            } else {
                LOGGER.log(Level.SEVERE, "OpenRouter API error: {0} - {1}", new Object[]{response.statusCode(), response.body()});
                
                // Fallback attempt with gpt-3.5-turbo if the primary model fails
                if (!"openai/gpt-3.5-turbo".equals(MODEL) && (response.statusCode() == 404 || response.statusCode() == 400)) {
                    LOGGER.info("Attempting fallback to gpt-3.5-turbo...");
                    body.put("model", "openai/gpt-3.5-turbo");
                    request = HttpRequest.newBuilder()
                            .uri(URI.create(API_URL))
                            .header("Authorization", "Bearer " + API_KEY)
                            .header("Content-Type", "application/json")
                            .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                            .build();
                    response = client.send(request, HttpResponse.BodyHandlers.ofString());
                    if (response.statusCode() == 200) {
                        JSONObject jsonResponse = new JSONObject(response.body());
                        return jsonResponse.getJSONArray("choices")
                                .getJSONObject(0)
                                .getJSONObject("message")
                                .getString("content");
                    }
                }
                return null;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error calling OpenRouter API", e);
            return null;
        }
    }
}
