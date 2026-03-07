package myPackage;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AI Agent for analyzing PDF content and generating context-aware exam questions.
 * Uses OpenRouter API to determine document subject/domain and generate questions based only on PDF content.
 */
public class PdfAiAgent {
    private static final Logger LOGGER = Logger.getLogger(PdfAiAgent.class.getName());

    /**
     * Analyzes PDF content to determine subject domain, topics, and complexity
     * @param pdfText Extracted text from PDF
     * @return JSONObject with domain, topics, complexity, exam_format
     */
    public static JSONObject analyzePdfContent(String pdfText) {
        if (pdfText == null || pdfText.trim().isEmpty()) {
            LOGGER.warning("PDF text is empty for analysis");
            return createDefaultAnalysis();
        }

        String apiKey = OpenRouterConfig.getApiKey();
        if (apiKey == null || apiKey.trim().isEmpty()) {
            LOGGER.severe("API key not found for PDF analysis");
            return createDefaultAnalysis();
        }

        try {
            // Limit text to ~4000 characters for analysis to save tokens
            String analysisText = pdfText.length() > 4000 ?
                pdfText.substring(0, 4000) : pdfText;

            JSONObject payload = new JSONObject();
            payload.put("model", OpenRouterConfig.getModel());
            payload.put("temperature", 0.2); // Deterministic analysis
            payload.put("max_tokens", 400);  // Lightweight analysis

            JSONArray messages = new JSONArray();

            // System prompt for analysis
            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content",
                "You are an expert document analyzer. Analyze documents and identify their domain, key topics, complexity level, and exam format. " +
                "Respond with ONLY a JSON object, no other text."
            );
            messages.put(systemMessage);

            // User prompt for analysis
            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            userMessage.put("content",
                "Analyze this document and identify its characteristics:\n\n" +
                analysisText + "\n\n" +
                "Respond with ONLY this JSON object (no markdown, no explanation):\n" +
                "{\n" +
                "  \"domain\": \"Python/Java/Mathematics/Accounting/Science/History/Literature/Other\",\n" +
                "  \"primary_topics\": [\"topic1\", \"topic2\", \"topic3\"],\n" +
                "  \"complexity\": \"beginner/intermediate/advanced\",\n" +
                "  \"exam_format\": \"conceptual/calculation/mixed\",\n" +
                "  \"estimated_questions\": 5\n" +
                "}"
            );
            messages.put(userMessage);

            payload.put("messages", messages);

            LOGGER.info("Sending PDF analysis request to OpenRouter API...");
            String response = OpenRouterClient.sendRequestInternal(payload.toString(), apiKey);

            if (response == null) {
                LOGGER.severe("Null response from API for PDF analysis");
                return createDefaultAnalysis();
            }

            // Extract content from API response
            String content = OpenRouterClient.extractContentInternal(response);
            if (content == null) {
                LOGGER.severe("Could not extract content from API response");
                return createDefaultAnalysis();
            }

            // Clean and parse JSON
            content = content.replace("```json", "").replace("```", "").trim();

            try {
                JSONObject analysis = new JSONObject(content);
                LOGGER.info("PDF Analysis complete: " + analysis.toString());
                return analysis;
            } catch (JSONException e) {
                LOGGER.log(Level.SEVERE, "Failed to parse PDF analysis JSON: " + content, e);
                return createDefaultAnalysis();
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error analyzing PDF content", e);
            return createDefaultAnalysis();
        }
    }

    /**
     * Generates context-aware exam questions based on PDF content and analysis
     * @param pdfText Extracted text from PDF
     * @param numQuestions Number of questions to generate
     * @return JSONArray of generated questions
     */
    public static JSONArray generateContextAwareQuestions(String pdfText, int numQuestions) {
        if (pdfText == null || pdfText.trim().isEmpty()) {
            LOGGER.warning("PDF text is empty for question generation");
            return new JSONArray();
        }

        if (numQuestions < 1 || numQuestions > 20) {
            LOGGER.warning("Invalid number of questions: " + numQuestions);
            numQuestions = Math.max(1, Math.min(numQuestions, 20));
        }

        String apiKey = OpenRouterConfig.getApiKey();
        if (apiKey == null || apiKey.trim().isEmpty()) {
            LOGGER.severe("API key not found for question generation");
            return new JSONArray();
        }

        try {
            // First, analyze the PDF to get domain and topics
            JSONObject analysis = analyzePdfContent(pdfText);
            String domain = analysis.optString("domain", "General");
            JSONArray topics = analysis.optJSONArray("primary_topics");
            if (topics == null || topics.length() == 0) {
                topics = new JSONArray();
                topics.put("general knowledge");
            }

            // Limit text to ~6000 characters for question generation
            String generationText = pdfText.length() > 6000 ?
                pdfText.substring(0, 6000) : pdfText;

            JSONObject payload = new JSONObject();
            payload.put("model", OpenRouterConfig.getModel());
            payload.put("temperature", 0.3); // Slightly creative but mostly deterministic
            payload.put("max_tokens", 1500); // Sufficient for multiple questions

            JSONArray messages = new JSONArray();

            // System prompt for question generation
            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content",
                "You are an expert exam question generator. Create high-quality, clear, and accurate multiple-choice questions. " +
                "CRITICAL: Every question must be based ONLY on the document content provided. " +
                "Respond with ONLY a JSON array, no other text."
            );
            messages.put(systemMessage);

            // User prompt for question generation
            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");

            // Build topics string
            String topicsStr = buildTopicsString(topics);

            userMessage.put("content",
                "Generate exactly " + numQuestions + " multiple-choice exam questions from this " + domain + " document.\n\n" +
                "KEY REQUIREMENTS:\n" +
                "- EVERY question must use ONLY content from this document\n" +
                "- Focus on these topics: " + topicsStr + "\n" +
                "- Include 4 distinct options per question\n" +
                "- Only 1 correct answer per question\n" +
                "- Make questions clear and unambiguous\n\n" +
                "DOCUMENT:\n" + generationText + "\n\n" +
                "Return ONLY this JSON array (no markdown, no explanation, exactly " + numQuestions + " questions):\n" +
                "[\n" +
                "  {\n" +
                "    \"question\": \"Clear exam question based on document\",\n" +
                "    \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"],\n" +
                "    \"correct\": \"Option A\",\n" +
                "    \"type\": \"MCQ\",\n" +
                "    \"topic\": \"related_topic\"\n" +
                "  }\n" +
                "]\n"
            );
            messages.put(userMessage);

            payload.put("messages", messages);

            LOGGER.info("Generating " + numQuestions + " questions for " + domain + " domain...");
            String response = OpenRouterClient.sendRequestInternal(payload.toString(), apiKey);

            if (response == null) {
                LOGGER.severe("Null response from API for question generation");
                return new JSONArray();
            }

            // Extract content from API response
            String content = OpenRouterClient.extractContentInternal(response);
            if (content == null) {
                LOGGER.severe("Could not extract content from API response for questions");
                return new JSONArray();
            }

            // Clean and parse JSON array
            content = content.replace("```json", "").replace("```", "").trim();

            try {
                // Extract JSON array
                int arrayStart = content.indexOf('[');
                int arrayEnd = content.lastIndexOf(']');
                if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
                    String jsonArray = content.substring(arrayStart, arrayEnd + 1);
                    JSONArray questions = new JSONArray(jsonArray);

                    LOGGER.info("Generated " + questions.length() + " questions: " +
                        (questions.length() > 0 ? questions.getString(0).substring(0, Math.min(100, questions.getString(0).length())) : "empty"));

                    return validateAndCleanQuestions(questions, numQuestions);
                }
            } catch (JSONException e) {
                LOGGER.log(Level.SEVERE, "Failed to parse questions JSON: " + content, e);
            }

            return new JSONArray();

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error generating context-aware questions", e);
            return new JSONArray();
        }
    }

    /**
     * Validates and cleans generated questions
     */
    private static JSONArray validateAndCleanQuestions(JSONArray questions, int expectedCount) {
        JSONArray validated = new JSONArray();

        for (int i = 0; i < questions.length() && validated.length() < expectedCount; i++) {
            try {
                JSONObject q = questions.getJSONObject(i);

                // Validate required fields
                if (!q.has("question") || !q.has("options") || !q.has("correct")) {
                    LOGGER.warning("Question " + i + " missing required fields");
                    continue;
                }

                String question = q.getString("question");
                JSONArray options = q.getJSONArray("options");
                String correct = q.getString("correct");

                // Validate options
                if (options.length() < 2) {
                    LOGGER.warning("Question " + i + " has fewer than 2 options");
                    continue;
                }

                // Ensure correct answer is in options
                boolean correctFound = false;
                for (int j = 0; j < options.length(); j++) {
                    if (options.getString(j).equals(correct)) {
                        correctFound = true;
                        break;
                    }
                }

                if (!correctFound) {
                    LOGGER.warning("Question " + i + " correct answer not in options");
                    continue;
                }

                validated.put(q);

            } catch (JSONException e) {
                LOGGER.log(Level.WARNING, "Error validating question " + i, e);
            }
        }

        LOGGER.info("Validated " + validated.length() + " out of " + questions.length() + " questions");
        return validated;
    }

    /**
     * Converts topics array to string
     */
    private static String buildTopicsString(JSONArray topics) {
        if (topics == null || topics.length() == 0) {
            return "general content";
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < topics.length() && i < 5; i++) {
            if (i > 0) sb.append(", ");
            try {
                sb.append(topics.getString(i));
            } catch (JSONException e) {
                // Skip
            }
        }
        return sb.toString();
    }

    /**
     * Creates a default analysis object when API fails
     */
    private static JSONObject createDefaultAnalysis() {
        JSONObject result = new JSONObject();
        try {
            result.put("domain", "General");
            result.put("primary_topics", new JSONArray().put("general knowledge"));
            result.put("complexity", "intermediate");
            result.put("exam_format", "mixed");
            result.put("estimated_questions", 5);
        } catch (JSONException e) {
            // Ignore
        }
        return result;
    }
}
