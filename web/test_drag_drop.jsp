<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    DatabaseClass pDAO = new DatabaseClass();
    
    // Test 1: Check if tables exist and have data
    try {
        List<Map<String, Object>> dragItems = pDAO.getDragItemsByQuestionId(1);
        List<Map<String, Object>> dropTargets = pDAO.getDropTargetsByQuestionId(1);
        
        out.println("<h2>Drag-Drop Database Test Results</h2>");
        out.println("<h3>Test 1: Database Tables</h3>");
        out.println("<p>Drag Items for Question ID 1: " + dragItems.size() + " found</p>");
        out.println("<p>Drop Targets for Question ID 1: " + dropTargets.size() + " found</p>");
        
        // Test 2: Get last inserted ID
        int lastId = pDAO.getLastInsertedQuestionId();
        out.println("<h3>Test 2: Last Inserted Question ID</h3>");
        out.println("<p>Last inserted ID: " + lastId + "</p>");
        
        // Test 3: Check if question exists
        boolean exists = pDAO.questionExists(lastId);
        out.println("<h3>Test 3: Question Exists Check</h3>");
        out.println("<p>Question ID " + lastId + " exists: " + (exists ? "YES" : "NO") + "</p>");
        
        out.println("<h3>Next Steps:</h3>");
        out.println("<ol>");
        out.println("<li>Run the SQL script: <code>create_drag_drop_complete.sql</code></li>");
        out.println("<li>Create a drag-drop question in the application</li>");
        out.println("<li>Check the server logs for detailed messages</li>");
        out.println("<li>Verify data appears in drag_items and drop_targets tables</li>");
        out.println("</ol>");
        
    } catch (Exception e) {
        out.println("<h2>Error Testing Drag-Drop</h2>");
        out.println("<p>Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
%>
