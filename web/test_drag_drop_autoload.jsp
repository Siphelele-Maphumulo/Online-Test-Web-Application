<%@page import="myPackage.DatabaseClass"%>
<%@page import="java.util.*"%>
<%
    // Test the auto-loading functionality
    DatabaseClass db = DatabaseClass.getInstance();
    
    // Test with a known drag and drop question ID (you can change this)
    int testQuestionId = 245; // Change to an actual drag-drop question ID in your database
    
    try {
        // Get the drag drop data
        Map<String, String> dragDropData = db.getDragDropData(testQuestionId);
        
        String dragItemsJson = dragDropData.get("drag_items");
        String dropTargetsJson = dragDropData.get("drop_targets");
        String correctTargetsJson = dragDropData.get("drag_correct_targets");
        
        // Handle null values
        if (dragItemsJson == null) dragItemsJson = "[]";
        if (dropTargetsJson == null) dropTargetsJson = "[]";
        if (correctTargetsJson == null) correctTargetsJson = "[]";
        
        float totalMarks = 1.0f; // Default value
        
        out.println("<h2>Testing Drag & Drop Auto-Load for Question ID: " + testQuestionId + "</h2>");
        out.println("<h3>Database Data:</h3>");
        out.println("<p><strong>drag_items:</strong> " + dragItemsJson + "</p>");
        out.println("<p><strong>drop_targets:</strong> " + dropTargetsJson + "</p>");
        out.println("<p><strong>drag_correct_targets:</strong> " + correctTargetsJson + "</p>");
        out.println("<p><strong>total_marks:</strong> " + totalMarks + "</p>");
        
        // Parse the JSON to show what should appear in the UI
        out.println("<h3>Expected UI Display:</h3>");
        
        // Simple JSON parsing for demonstration
        if (!dragItemsJson.equals("[]")) {
            out.println("<h4>Draggable Items:</h4><ul>");
            // Remove brackets and quotes for simple display
            String cleanItems = dragItemsJson.replaceAll("[\\[\\]\"]", "");
            String[] items = cleanItems.split(",");
            for (String item : items) {
                if (!item.trim().isEmpty()) {
                    out.println("<li>" + item.trim() + "</li>");
                }
            }
            out.println("</ul>");
        }
        
        if (!dropTargetsJson.equals("[]")) {
            out.println("<h4>Drop Targets:</h4><ul>");
            String cleanTargets = dropTargetsJson.replaceAll("[\\[\\]\"]", "");
            String[] targets = cleanTargets.split(",");
            for (String target : targets) {
                if (!target.trim().isEmpty()) {
                    out.println("<li>" + target.trim() + "</li>");
                }
            }
            out.println("</ul>");
        }
        
        out.println("<h4>Correct Pairings:</h4>");
        if (!dragItemsJson.equals("[]") && !dropTargetsJson.equals("[]") && !correctTargetsJson.equals("[]")) {
            out.println("<p>The system will automatically create pairings based on the database values.</p>");
        }
        
        out.println("<p><a href='edit_question.jsp?qid=" + testQuestionId + "'>Click here to test the edit page</a></p>");
        
    } catch (Exception e) {
        out.println("<h2>Error:</h2>");
        out.println("<p>" + e.getMessage() + "</p>");
        out.println("<pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
    }
%>