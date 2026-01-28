package myPackage;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.pdfbox.pdfparser.PDFParser;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class AIGenerator {

    public static String extractTextFromPDF(byte[] pdfBytes) throws IOException {
        File tempFile = File.createTempFile("pdf-upload-", ".pdf");
        try (FileOutputStream fos = new FileOutputStream(tempFile)) {
            fos.write(pdfBytes);
        }

        try {
            // Use PDFParser.load which is available in 3.0.6 as a static method
            try (PDDocument document = PDFParser.load(tempFile)) {
                PDFTextStripper stripper = new PDFTextStripper();
                return stripper.getText(document);
            }
        } finally {
            tempFile.delete();
        }
    }

    public static String callOpenAI(String apiKey, String text, String type) throws Exception {
        URL url = new URL("https://api.openai.com/v1/chat/completions");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/json");
        con.setRequestProperty("Authorization", "Bearer " + apiKey);
        con.setDoOutput(true);

        JSONObject json = new JSONObject();
        json.put("model", "gpt-3.5-turbo");

        JSONArray messages = new JSONArray();
        JSONObject systemMessage = new JSONObject();
        systemMessage.put("role", "system");
        systemMessage.put("content", "You are a teacher. Generate one " + type + " question from the provided text in JSON format with fields: question, options (array of 4 for MCQ), correct (the correct option text, or pipe-separated for MultipleSelect). Return ONLY the JSON object.");
        messages.put(systemMessage);

        JSONObject userMessage = new JSONObject();
        userMessage.put("role", "user");
        userMessage.put("content", text.length() > 2000 ? text.substring(0, 2000) : text);
        messages.put(userMessage);

        json.put("messages", messages);
        json.put("temperature", 0.7);

        try (OutputStream os = con.getOutputStream()) {
            byte[] input = json.toString().getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        int status = con.getResponseCode();
        if (status != 200) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getErrorStream() != null ? con.getErrorStream() : con.getInputStream(), "utf-8"))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) response.append(line);
                throw new Exception("OpenAI API Error (Status " + status + "): " + response.toString());
            }
        }

        StringBuilder response = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "utf-8"))) {
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
        }

        JSONObject aiResponse = new JSONObject(response.toString());
        String content = aiResponse.getJSONArray("choices").getJSONObject(0).getJSONObject("message").getString("content");

        // More robust JSON extraction
        String jsonStr = content.trim();
        if (jsonStr.contains("{")) {
            jsonStr = jsonStr.substring(jsonStr.indexOf("{"));
            if (jsonStr.lastIndexOf("}") != -1) {
                jsonStr = jsonStr.substring(0, jsonStr.lastIndexOf("}") + 1);
            }
        }

        JSONObject questionJson = new JSONObject(jsonStr);
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("question", questionJson);
        return result.toString();
    }

    public static JSONObject generateHeuristicQuestion(String text, String type) {
        String[] sentences = text.split("[.!?]+");
        List<String> validSentences = new ArrayList<>();
        for (String s : sentences) {
            if (s.trim().split("\\s+").length >= 10) {
                validSentences.add(s.trim());
            }
        }

        String source = validSentences.isEmpty() ? text.trim() : validSentences.get((int) (Math.random() * validSentences.size()));
        if (source.length() > 500) source = source.substring(0, 500);
        String[] words = source.split("\\s+");

        JSONObject q = new JSONObject();
        if ("FillInTheBlank".equalsIgnoreCase(type)) {
            int blankIdx = words.length / 2;
            String blankWord = words[blankIdx].replaceAll("[^a-zA-Z0-9]", "");
            words[blankIdx] = "_________";
            q.put("question", String.join(" ", words));
            q.put("correct", blankWord);
        } else if ("TrueFalse".equalsIgnoreCase(type)) {
            q.put("question", source);
            q.put("correct", "True");
        } else {
            q.put("question", "According to the text, which is correct?");
            JSONArray options = new JSONArray();
            options.put(source);
            options.put("None of the above");
            options.put("Information not provided");
            options.put("The opposite statement");
            q.put("options", options);
            q.put("correct", source);
        }
        return q;
    }
}
