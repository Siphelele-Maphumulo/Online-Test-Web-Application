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
     * @param questionType The type of questions (MCQ, MultipleSelect, FillInTheBlank).
     * @return JSON string containing the generated questions.
     */
    public static String generateQuestions(String text, String questionType) {
        if (API_KEY == null || API_KEY.trim().isEmpty()) {
            LOGGER.severe("OpenRouter API Key is missing. AI generation will fail.");
            return null;
        }

        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(30))
                    .build();

            String prompt = "Act as an educational expert. Generate 3 to 5 high-quality " + questionType + " questions based on the provided text. " +
                            "Output must be a JSON object with a 'questions' key containing an array of objects. " +
                            "Each question object MUST have: " +
                            "1. 'question': the question text. " +
                            "2. 'options': an array of exactly 4 strings (for MCQ and MultipleSelect, empty array for FillInTheBlank). " +
                            "3. 'correct': the correct answer. For MultipleSelect, use 'OptionText1|OptionText2' format. For MCQ, it MUST match one of the options exactly. " +
                            "The response should be strictly JSON, no extra text.\n\n" +
                            "Text: " + text;

            JSONObject body = new JSONObject();
            body.put("model", MODEL);
            body.put("max_tokens", 1500);

            JSONArray messages = new JSONArray();
            JSONObject message = new JSONObject();
            message.put("role", "user");
            message.put("content", prompt);
            messages.put(message);

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
