<%@page import="myPackage.DatabaseClass"%>
<%@page import="java.util.*"%>
<%
    // Test the drag and drop edit fix
    DatabaseClass db = DatabaseClass.getInstance();
    
    // Look for a drag and drop question to test with
    try {
        String sql = "SELECT question_id, question_type FROM questions WHERE question_type = 'DRAG_AND_DROP' LIMIT 1";
        Connection conn = db.getConnection();
        PreparedStatement pstm = conn.prepareStatement(sql);
        ResultSet rs = pstm.executeQuery();
        
        if (rs.next()) {
            int questionId = rs.getInt("question_id");
            String questionType = rs.getString("question_type");
            
            out.println("<h2>Found Drag & Drop Question for Testing</h2>");
            out.println("<p><strong>Question ID:</strong> " + questionId + "</p>");
            out.println("<p><strong>Question Type:</strong> " + questionType + "</p>");
            
            // Get the drag drop data
            Map<String, String> dragDropData = db.getDragDropData(questionId);
            
            String dragItemsJson = dragDropData.get("drag_items");
            String dropTargetsJson = dragDropData.get("drop_targets");
            String correctTargetsJson = dragDropData.get("drag_correct_targets");
            
            out.println("<h3>Database Data:</h3>");
            out.println("<p><strong>drag_items:</strong> " + dragItemsJson + "</p>");
            out.println("<p><strong>drop_targets:</strong> " + dropTargetsJson + "</p>");
            out.println("<p><strong>drag_correct_targets:</strong> " + correctTargetsJson + "</p>");
            
            out.println("<h3>Test Links:</h3>");
            out.println("<p><a href='edit_question.jsp?qid=" + questionId + "' target='_blank'>Edit this question (new fix)</a></p>");
            out.println("<p><a href='showall.jsp' target='_blank'>View all questions</a></p>");
            
        } else {
            out.println("<h2>No Drag & Drop Questions Found</h2>");
            out.println("<p>Please create a drag and drop question first, then test the edit functionality.</p>");
            out.println("<p><a href='questions.jsp'>Create a new question</a></p>");
        }
        
        rs.close();
        pstm.close();
        conn.close();
        
    } catch (Exception e) {
        out.println("<h2>Error:</h2>");
        out.println("<p>" + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>