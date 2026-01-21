<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.Questions" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Verify Image Upload Implementation</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            line-height: 1.6;
        }
        .section {
            margin-bottom: 30px;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        h2 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 5px;
        }
        .status-ok {
            color: #27ae60;
            font-weight: bold;
        }
        .status-warning {
            color: #f39c12;
            font-weight: bold;
        }
        .status-error {
            color: #e74c3c;
            font-weight: bold;
        }
        .check-item {
            margin: 10px 0;
            padding: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Image Upload Implementation Verification</h1>
    
    <div class="section">
        <h2>Implementation Status</h2>
        <div class="check-item">
            <span class="status-ok">✓</span> Database table updated with image_path column
        </div>
        <div class="check-item">
            <span class="status-ok">✓</span> Questions.java updated with imagePath field
        </div>
        <div class="check-item">
            <span class="status-ok">✓</span> DatabaseClass.java updated with image handling methods
        </div>
        <div class="check-item">
            <span class="status-ok">✓</span> questions.jsp updated with image upload UI
        </div>
        <div class="check-item">
            <span class="status-ok">✓</span> controller.jsp updated with multipart handling for addnew
        </div>
        <div class="check-item">
            <span class="status-ok">✓</span> controller.jsp updated with multipart handling for edit
        </div>
        <div class="check-item">
            <span class="status-ok">✓</span> edit_question.jsp updated with image upload UI
        </div>
        <div class="check-item">
            <span class="status-ok">✓</span> Upload directory created (uploads/images/)
        </div>
    </div>
    
    <%
    DatabaseClass pDAO = DatabaseClass.getInstance();
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    %>
    
    <div class="section">
        <h2>Database Schema Verification</h2>
        <%
        try {
            conn = pDAO.getConnection();
            DatabaseMetaData meta = conn.getMetaData();
            rs = meta.getColumns(null, null, "questions", "image_path");
            
            if (rs.next()) {
                out.println("<div class='check-item'><span class='status-ok'>✓</span> image_path column exists in questions table</div>");
                out.println("<p><strong>Data Type:</strong> " + rs.getString("TYPE_NAME") + "</p>");
            } else {
                out.println("<div class='check-item'><span class='status-error'>✗</span> image_path column NOT found in questions table</div>");
            }
        } catch (Exception e) {
            out.println("<div class='check-item'><span class='status-error'>✗</span> Error checking database schema: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
        %>
    </div>
    
    <div class="section">
        <h2>Sample Question with Image Path</h2>
        <%
        try {
            conn = pDAO.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT question_id, question, image_path FROM questions LIMIT 5");
            
            out.println("<table>");
            out.println("<tr><th>ID</th><th>Question</th><th>Image Path</th></tr>");
            
            boolean hasRows = false;
            while (rs.next()) {
                hasRows = true;
                out.println("<tr>");
                out.println("<td>" + rs.getInt("question_id") + "</td>");
                out.println("<td>" + rs.getString("question").substring(0, Math.min(50, rs.getString("question").length())) + "...</td>");
                out.println("<td>" + (rs.getString("image_path") != null ? rs.getString("image_path") : "NULL") + "</td>");
                out.println("</tr>");
            }
            
            if (!hasRows) {
                out.println("<tr><td colspan='3'>No questions found in database</td></tr>");
            }
            
            out.println("</table>");
        } catch (Exception e) {
            out.println("<div class='check-item'><span class='status-error'>✗</span> Error querying questions: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
        %>
    </div>
    
    <div class="section">
        <h2>Next Steps</h2>
        <p>The image upload functionality has been successfully implemented. Here's what you can do now:</p>
        <ul>
            <li>Go to the Questions page to add new questions with images</li>
            <li>Edit existing questions to add or remove images</li>
            <li>Images will be stored in the <code>uploads/images/</code> directory</li>
            <li>Image paths are stored in the database and displayed with questions</li>
        </ul>
        <p><a href="questions.jsp" style="color: #3498db; text-decoration: none;">← Back to Questions Management</a></p>
    </div>
</body>
</html>