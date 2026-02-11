<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="java.util.*" %>
<%
    DatabaseClass pDAO = new DatabaseClass();
    int questionId = 238; // Your drag and drop question ID
    
    // Get drag drop data using the same method as edit_question.jsp
    Map<String, String> dragDropData = pDAO.getDragDropData(questionId);
    
    // Parse JSON data manually (same logic as edit_question.jsp)
    String dragItemsJsonStr = dragDropData.get("drag_items");
    String dropTargetsJsonStr = dragDropData.get("drop_targets");
    String dragCorrectTargetsJsonStr = dragDropData.get("drag_correct_targets");
    
    ArrayList<String> dragItems = new ArrayList<>();
    ArrayList<String> dropTargets = new ArrayList<>();
    ArrayList<String> dragCorrectTargets = new ArrayList<>();
    
    // Parse drag items
    if (dragItemsJsonStr != null && dragItemsJsonStr.startsWith("[") && dragItemsJsonStr.endsWith("]")) {
        String content = dragItemsJsonStr.substring(1, dragItemsJsonStr.length() - 1);
        if (!content.trim().isEmpty()) {
            String[] items = content.split(",");
            for (String item : items) {
                String cleaned = item.trim().replaceAll("^\"|\"$", "").replace("\\\"", "\"");
                if (!cleaned.isEmpty()) {
                    dragItems.add(cleaned);
                }
            }
        }
    }
    
    // Parse drop targets
    if (dropTargetsJsonStr != null && dropTargetsJsonStr.startsWith("[") && dropTargetsJsonStr.endsWith("]")) {
        String content = dropTargetsJsonStr.substring(1, dropTargetsJsonStr.length() - 1);
        if (!content.trim().isEmpty()) {
            String[] items = content.split(",");
            for (String item : items) {
                String cleaned = item.trim().replaceAll("^\"|\"$", "").replace("\\\"", "\"");
                if (!cleaned.isEmpty()) {
                    dropTargets.add(cleaned);
                }
            }
        }
    }
    
    // Parse drag correct targets
    if (dragCorrectTargetsJsonStr != null && dragCorrectTargetsJsonStr.startsWith("[") && dragCorrectTargetsJsonStr.endsWith("]")) {
        String content = dragCorrectTargetsJsonStr.substring(1, dragCorrectTargetsJsonStr.length() - 1);
        if (!content.trim().isEmpty()) {
            String[] items = content.split(",");
            for (String item : items) {
                String cleaned = item.trim().replaceAll("^\"|\"$", "").replace("\\\"", "\"");
                if (!cleaned.isEmpty()) {
                    dragCorrectTargets.add(cleaned);
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Debug Drag Drop Data</title>
</head>
<body>
    <h2>Debug Drag Drop Data for Question ID: <%= questionId %></h2>
    
    <h3>Raw Database Data:</h3>
    <p><strong>drag_items:</strong> <%= dragItemsJsonStr %></p>
    <p><strong>drop_targets:</strong> <%= dropTargetsJsonStr %></p>
    <p><strong>drag_correct_targets:</strong> <%= dragCorrectTargetsJsonStr %></p>
    
    <h3>Parsed Data:</h3>
    <p><strong>Drag Items:</strong> <%= dragItems %></p>
    <p><strong>Drop Targets:</strong> <%= dropTargets %></p>
    <p><strong>Correct Targets:</strong> <%= dragCorrectTargets %></p>
    
    <h3>JSON for JavaScript (escaped):</h3>
    <p><strong>dragItemsJsonStr:</strong> <%= dragItemsJsonStr.replace("\"", "&quot;") %></p>
    <p><strong>dropTargetsJsonStr:</strong> <%= dropTargetsJsonStr.replace("\"", "&quot;") %></p>
    <p><strong>dragCorrectTargetsJsonStr:</strong> <%= dragCorrectTargetsJsonStr.replace("\"", "&quot;") %></p>
    
    <hr>
    
    <h3>Test JavaScript Parsing:</h3>
    <input type="hidden" id="testDragItems" value='<%= dragItemsJsonStr.replace("\"", "&quot;") %>'>
    <input type="hidden" id="testDropTargets" value='<%= dropTargetsJsonStr.replace("\"", "&quot;") %>'>
    <input type="hidden" id="testCorrectTargets" value='<%= dragCorrectTargetsJsonStr.replace("\"", "&quot;") %>'>
    
    <button onclick="testParsing()">Test JavaScript Parsing</button>
    <div id="results"></div>
    
    <script>
        function testParsing() {
            try {
                const dragItemsStr = document.getElementById('testDragItems').value.replace(/&quot;/g, '"');
                const dropTargetsStr = document.getElementById('testDropTargets').value.replace(/&quot;/g, '"');
                const correctTargetsStr = document.getElementById('testCorrectTargets').value.replace(/&quot;/g, '"');
                
                console.log('Raw strings:');
                console.log('dragItems:', dragItemsStr);
                console.log('dropTargets:', dropTargetsStr);
                console.log('correctTargets:', correctTargetsStr);
                
                const dragItems = JSON.parse(dragItemsStr);
                const dropTargets = JSON.parse(dropTargetsStr);
                const correctTargets = JSON.parse(correctTargetsStr);
                
                console.log('Parsed arrays:');
                console.log('dragItems:', dragItems);
                console.log('dropTargets:', dropTargets);
                console.log('correctTargets:', correctTargets);
                
                document.getElementById('results').innerHTML = `
                    <h4>JavaScript Parsing Results:</h4>
                    <p><strong>Drag Items:</strong> ${JSON.stringify(dragItems)}</p>
                    <p><strong>Drop Targets:</strong> ${JSON.stringify(dropTargets)}</p>
                    <p><strong>Correct Targets:</strong> ${JSON.stringify(correctTargets)}</p>
                `;
            } catch (e) {
                console.error('Parsing error:', e);
                document.getElementById('results').innerHTML = `<p style="color: red;">Error: ${e.message}</p>`;
            }
        }
    </script>
</body>
</html>
