package myPackage;

import myPackage.classes.Questions;
import myPackage.classes.DragItem;
import myPackage.classes.DropTarget;
import org.json.JSONObject;
import org.json.JSONArray;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

public class DragDropService {
    private DatabaseClass db;

    public DragDropService() throws Exception {
        this.db = DatabaseClass.getInstance();
    }

    /**
     * Fetch question from database and parse JSON data for draggable items and drop targets.
     * Returns structured JSON object to JSP.
     */
    public JSONObject getDragDropQuestion(int questionId) {
        Questions question = db.getQuestionById(questionId);
        if (question == null || !"DRAG_AND_DROP".equalsIgnoreCase(question.getQuestionType())) {
            return null;
        }

        JSONObject result = new JSONObject();
        JSONArray draggableItems = new JSONArray();
        JSONArray dropTargets = new JSONArray();
        JSONObject correctMappings = new JSONObject();

        // Populate draggable items
        List<DragItem> dragItems = question.getDragItems();
        if (dragItems != null) {
            for (DragItem item : dragItems) {
                JSONObject itemJson = new JSONObject();
                itemJson.put("id", "item_" + item.getId());
                itemJson.put("text", item.getItemText());
                draggableItems.put(itemJson);
                
                // Populate correct mapping if target ID is present
                if (item.getCorrectTargetId() != null && item.getCorrectTargetId() > 0) {
                    correctMappings.put("target_" + item.getCorrectTargetId(), "item_" + item.getId());
                }
            }
        }

        // Populate drop targets
        List<DropTarget> targets = question.getDropTargets();
        if (targets != null) {
            for (DropTarget target : targets) {
                JSONObject targetJson = new JSONObject();
                targetJson.put("id", "target_" + target.getId());
                targetJson.put("label", target.getTargetLabel());
                dropTargets.put(targetJson);
            }
        }

        result.put("questionId", question.getQuestionId());
        result.put("questionText", question.getQuestion());
        result.put("draggableItems", draggableItems);
        result.put("dropTargets", dropTargets);
        result.put("correctMappings", correctMappings);

        return result;
    }

    /**
     * Validates user's dropped item-to-target mappings against correct mappings.
     * Calculates score and returns result with feedback.
     */
    public Map<String, Object> validateDragDropAnswer(int questionId, String userMappingsJson) {
        Map<String, Object> result = new HashMap<>();
        try {
            JSONObject userMappings = new JSONObject(userMappingsJson);
            JSONObject questionData = getDragDropQuestion(questionId);
            if (questionData == null) {
                result.put("error", "Question not found");
                return result;
            }

            JSONObject correctMappings = questionData.getJSONObject("correctMappings");
            int totalItems = correctMappings.length();
            int correctCount = 0;

            for (String targetId : userMappings.keySet()) {
                if (correctMappings.has(targetId)) {
                    Object userVal = userMappings.get(targetId);
                    Object correctVal = correctMappings.get(targetId);
                    if (userVal != null && userVal.toString().equals(correctVal.toString())) {
                        correctCount++;
                    }
                }
            }

            boolean isCorrect = (correctCount == totalItems && userMappings.length() == totalItems);
            
            result.put("correct", isCorrect);
            result.put("score", (float) correctCount);
            result.put("total", (float) totalItems);
            result.put("feedback", correctCount + " out of " + totalItems + " correctly matched.");
            
        } catch (Exception e) {
            result.put("error", "Error validating answer: " + e.getMessage());
        }
        
        return result;
    }

    /**
     * Parses the JSON user mappings into a Map for DAO processing.
     */
    public Map<Integer, Integer> parseUserMappings(String userMappingsJson) {
        Map<Integer, Integer> dragDropMatches = new HashMap<>();
        try {
            JSONObject matchesJson = new JSONObject(userMappingsJson);
            for (String key : matchesJson.keySet()) {
                // key format: target_X, value format: item_Y
                try {
                    int tId = Integer.parseInt(key.replace("target_", ""));
                    int iId = Integer.parseInt(matchesJson.getString(key).replace("item_", ""));
                    dragDropMatches.put(iId, tId);
                } catch (Exception e) {}
            }
        } catch (Exception e) {}
        return dragDropMatches;
    }
}
