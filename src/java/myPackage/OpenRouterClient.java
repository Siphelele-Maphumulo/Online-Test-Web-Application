package myPackage;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

public class OpenRouterClient {
    private static final Logger LOGGER = Logger.getLogger(OpenRouterClient.class.getName());
    private static final String API_URL = "https://openrouter.ai/api/v1/chat/completions";
    private static final String API_KEY = System.getenv("OPENROUTER_API_KEY");

    public static String generateQuestions(String text, String questionType, int numQuestions, boolean isMarkingGuideline) {
        if (API_KEY == null || API_KEY.trim().isEmpty()) {
            LOGGER.severe("OPENROUTER_API_KEY not set in environment.");
            return null;
        }

        try {
            JSONObject payload = new JSONObject();
            payload.put("model", "openai/gpt-4o-mini");
            payload.put("temperature", 0.3);
            payload.put("max_tokens", 2500);

            JSONArray messages = new JSONArray();

            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content", "You are an expert Accounting examiner and examiner. You specialize in generating high-quality exam questions from marking guidelines.");
            messages.put(systemMessage);

            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            userMessage.put("content", isMarkingGuideline ? createMarkingGuidelinePrompt(text, numQuestions) : createStandardPrompt(text, questionType, numQuestions));
            messages.put(userMessage);

            payload.put("messages", messages);

            String response = sendRequest(payload.toString());
            if (response == null) return null;

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

    private static String sendRequest(String jsonPayload) throws Exception {
        URL url = new URL(API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization", "Bearer " + API_KEY);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("HTTP-Referer", "https://codesa-institute.co.za");
        conn.setRequestProperty("X-Title", "Accounting Question Generator");

        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
        }

        int responseCode = conn.getResponseCode();
        InputStream is = (responseCode >= 200 && responseCode < 300) ? conn.getInputStream() : conn.getErrorStream();

        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }

            if (responseCode >= 400) {
                LOGGER.severe("API Error (" + responseCode + "): " + response.toString());
                return null;
            }

            return response.toString();
        } finally {
            conn.disconnect();
        }
    }

    private static String extractContent(String response) {
        try {
            JSONObject root = new JSONObject(response);
            if (root.has("choices")) {
                JSONArray choices = root.getJSONArray("choices");
                if (choices.length() > 0) {
                    JSONObject choice = choices.getJSONObject(0);
                    if (choice.has("message")) {
                        JSONObject message = choice.getJSONObject("message");
                        if (message.has("content")) {
                            return message.getString("content");
                        }
                    }
                }
            }
        } catch (JSONException e) {
            LOGGER.log(Level.SEVERE, "Failed to parse API response JSON", e);
        }
        return null;
    }
}
