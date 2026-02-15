
package myPackage;

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
        return generateQuestions(text, questionType, numQuestions, false);
    }

    public static String generateQuestions(String text, String questionType, int numQuestions, boolean isMarkingGuideline) {
        // Check if API key is available
        if (API_KEY == null || API_KEY.trim().isEmpty()) {
            // Return a sample response when API key is not configured
            System.out.println("OpenRouter API key not configured. Returning sample response.");
            return generateSampleResponse(questionType, numQuestions);
        }
        
        try {
            // Create the prompt for generating questions
            String prompt = isMarkingGuideline ? createMarkingGuidelinePrompt(text, numQuestions) : createPrompt(text, questionType, numQuestions);
            
            // Create the request payload
            Map<String, Object> payload = new HashMap<>();
            // Use a more capable model for structured extraction
            payload.put("model", "meta-llama/llama-3-8b-instruct");
            
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
            headers.put("HTTP-Referer", "https://codesa-institute.co.za");
            headers.put("X-Title", "Accounting Question Generator");
            
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

    private static String createMarkingGuidelinePrompt(String text, int numQuestions) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("You are an expert Accounting educator. Parse the following Accounting marking guidelines and generate multiple-choice questions (MCQs) based on the items found within.\n\n");
        prompt.append("MARKING GUIDELINE TEXT:\n");
        prompt.append(text).append("\n\n");
        prompt.append("INSTRUCTIONS:\n");
        prompt.append("1. Identify each unique question item (e.g., 'Calculate Taxation paid', 'Carrying value of buildings', etc.).\n");
        prompt.append("2. Extract the correct numerical answer from the 'ANSWER' section.\n");
        prompt.append("3. Use the 'WORKINGS' section to understand how the answer was derived.\n");
        prompt.append("4. Create 3 plausible distractors (incorrect options) based on common accounting errors (e.g., ignoring a specific adjustment, reversing a sign, using a wrong percentage from the workings).\n");
        prompt.append("5. Format the result as a JSON array of objects.\n\n");
        prompt.append("JSON STRUCTURE:\n");
        prompt.append("[{\n");
        prompt.append("  \"question\": \"The specific calculation or theory question stem\",\n");
        prompt.append("  \"options\": [\"Correct Answer\", \"Distractor 1\", \"Distractor 2\", \"Distractor 3\"],\n");
        prompt.append("  \"correct\": \"Correct Answer\",\n");
        prompt.append("  \"type\": \"MCQ\"\n");
        prompt.append("}]\n\n");
        prompt.append("RULES:\n");
        prompt.append("- Return ONLY valid JSON. No preamble or explanation.\n");
        prompt.append("- Focus on accuracy. Numerical values must be precise as per the guidelines.\n");
        prompt.append("- Ensure distractors look realistic for an accounting student.\n");

        return prompt.toString();
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
    }
}