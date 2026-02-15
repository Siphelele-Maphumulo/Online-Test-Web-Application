
package myPackage;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;


public class OpenRouterClient {
    
    private static final Logger LOGGER = Logger.getLogger(OpenRouterClient.class.getName());
    private static final String OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions";
    private static final String API_KEY = System.getenv("OPENROUTER_API_KEY"); // Get API key from environment variable
    
    public static String generateQuestions(String text, String questionType, int numQuestions) {
        return generateQuestions(text, questionType, numQuestions, false);
    }

    public static String generateQuestions(String text, String questionType, int numQuestions, boolean isMarkingGuideline) {
        // Check if API key is available
        if (API_KEY == null || API_KEY.trim().isEmpty()) {
            LOGGER.warning("OpenRouter API key not configured. Returning sample response.");
            return generateSampleResponse(questionType, numQuestions);
        }
        
        try {
            // Create the prompt for generating questions
            String prompt = isMarkingGuideline ? createMarkingGuidelinePrompt(text, numQuestions) : createPrompt(text, questionType, numQuestions);

            // Create the request payload using org.json
            JSONObject payload = new JSONObject();
            payload.put("model", "meta-llama/llama-3-8b-instruct");
            
            JSONArray messages = new JSONArray();
            
            // System message to enforce JSON format
            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content", "You are an expert examiner. Return ONLY valid JSON array. No explanations, no preamble.");
            messages.put(systemMessage);

            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            userMessage.put("content", prompt);
            messages.put(userMessage);

            payload.put("messages", messages);
            payload.put("temperature", 0.3); // Lower temperature for more stable JSON
            payload.put("max_tokens", 1500);
            
            // Add headers
            java.util.Map<String, String> headers = new java.util.HashMap<>();
            headers.put("Authorization", "Bearer " + API_KEY);
            headers.put("Content-Type", "application/json");
            headers.put("HTTP-Referer", "https://codesa-institute.co.za");
            headers.put("X-Title", "Accounting Question Generator");
            
            // Make the API call
            String response = makeApiCall(payload.toString(), headers);

            if (response == null) return null;
            
            // Extract the response text from the JSON response
            return extractResponseText(response);
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error generating questions with OpenRouter", e);
            return null;
        }
    }

    private static String createMarkingGuidelinePrompt(String text, int numQuestions) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("You are an expert Accounting educator and examiner. Parse the following Accounting marking guidelines (which may contain symbols like √, □, ☑ for marks) and generate multiple-choice questions (MCQs) based on the items found within.\n\n");
        prompt.append("MARKING GUIDELINE TEXT:\n");
        prompt.append(text).append("\n\n");
        prompt.append("INSTRUCTIONS:\n");
        prompt.append("1. Identify unique question items from the text. Look for patterns like 'Calculate ...', 'Determine ...' or items in a list followed by workings and an answer.\n");
        prompt.append("2. Extract the correct numerical answer from the 'ANSWER' or final value column/section. Note that marks are often indicated by symbols (√, □, ☑).\n");
        prompt.append("3. Use the 'WORKINGS' section (if available) to understand how the answer was derived.\n");
        prompt.append("4. Create 3 plausible distractors (incorrect options) based on common accounting errors identified in the workings (e.g., using a wrong percentage, forgetting a calculation step, reversing a sign).\n");
        prompt.append("5. Format the result as a JSON array of objects.\n\n");
        prompt.append("JSON STRUCTURE:\n");
        prompt.append("[\n");
        prompt.append("  {\n");
        prompt.append("    \"question\": \"The specific calculation or theory question stem (e.g., 'What is the amount of Taxation paid?')\",\n");
        prompt.append("    \"options\": [\"Correct Answer\", \"Distractor 1\", \"Distractor 2\", \"Distractor 3\"],\n");
        prompt.append("    \"correct\": \"Correct Answer\",\n");
        prompt.append("    \"type\": \"MCQ\"\n");
        prompt.append("  }\n");
        prompt.append("]\n\n");
        prompt.append("RULES:\n");
        prompt.append("- Return ONLY valid JSON array. No text before or after the JSON.\n");
        prompt.append("- Limit to approximately ").append(numQuestions).append(" questions.\n");
        prompt.append("- Numerical values must be exactly as per the guidelines.\n");
        prompt.append("- Ensure distractors look realistic for an accounting student.\n");

        return prompt.toString();
    }
    
    private static String createPrompt(String text, String questionType, int numQuestions) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Generate ").append(numQuestions).append(" ").append(questionType).append(" questions based on the following text:\n\n");
        prompt.append(text).append("\n\n");
        
        prompt.append("Format the response as a JSON array of objects with the following structure:\n");
        prompt.append("[\n");
        prompt.append("  {\n");
        prompt.append("    \"question\": \"The question text\",\n");
        if ("TrueFalse".equalsIgnoreCase(questionType)) {
            prompt.append("    \"options\": [\"True\", \"False\"],\n");
            prompt.append("    \"correct\": \"True or False\",\n");
            prompt.append("    \"type\": \"TrueFalse\"\n");
        } else {
            prompt.append("    \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"],\n");
            prompt.append("    \"correct\": \"The correct option\",\n");
            prompt.append("    \"type\": \"MCQ\"\n");
        }
        prompt.append("  }\n");
        prompt.append("]\n\n");
        
        prompt.append("Return ONLY valid JSON array. No preamble or explanation.");
        
        return prompt.toString();
    }
    
    private static String makeApiCall(String payloadString, java.util.Map<String, String> headers) throws Exception {
        URL url = new URL(OPENROUTER_API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        
        // Set request method
        conn.setRequestMethod("POST");
        
        // Set headers
        for (java.util.Map.Entry<String, String> header : headers.entrySet()) {
            conn.setRequestProperty(header.getKey(), header.getValue());
        }
        
        // Enable output and input streams
        conn.setDoOutput(true);
        
        // Write the payload
        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = payloadString.getBytes("utf-8");
            os.write(input, 0, input.length);
        }
        
        // Get response code
        int responseCode = conn.getResponseCode();
        
        // Read response
        InputStreamReader isr = (responseCode >= 200 && responseCode < 300)
                               ? new InputStreamReader(conn.getInputStream(), "utf-8")
                               : new InputStreamReader(conn.getErrorStream(), "utf-8");

        StringBuilder response = new StringBuilder();
        try (BufferedReader br = new BufferedReader(isr)) {
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
        }
        
        conn.disconnect();
        
        if (responseCode >= 200 && responseCode < 300) {
            return response.toString();
        } else {
            LOGGER.severe("API call failed with response code: " + responseCode);
            LOGGER.severe("Response: " + response.toString());
            return null;
        }
    }
    
    private static String extractResponseText(String jsonResponse) {
        try {
            JSONObject obj = new JSONObject(jsonResponse);
            if (obj.has("choices")) {
                JSONArray choices = obj.getJSONArray("choices");
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
            LOGGER.log(Level.WARNING, "Error extracting response text from JSON", e);
        }
        return jsonResponse;
    }
    
    private static String generateSampleResponse(String questionType, int numQuestions) {
        JSONArray arr = new JSONArray();
        
        for (int i = 0; i < numQuestions; i++) {
            JSONObject q = new JSONObject();
            q.put("question", "Sample " + questionType + " question #" + (i + 1));
            
            JSONArray opts = new JSONArray();
            if ("TrueFalse".equalsIgnoreCase(questionType)) {
                opts.put("True");
                opts.put("False");
                q.put("options", opts);
                q.put("correct", Math.random() > 0.5 ? "True" : "False");
                q.put("type", "TrueFalse");
            } else {
                opts.put("Option A");
                opts.put("Option B");
                opts.put("Option C");
                opts.put("Option D");
                q.put("options", opts);
                q.put("correct", "Option A");
                q.put("type", "MCQ");
            }
            arr.put(q);
        }
        
        return arr.toString();
    }
}
