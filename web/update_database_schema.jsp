<%@page import="java.sql.*"%>
<%@page import="myPackage.DatabaseClass"%>
<html>
<head>
    <title>Update Database Schema</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; }
        .error { color: red; }
        .info { color: blue; }
    </style>
</head>
<body>
    <h2>Updating Questions Table Schema</h2>
    <%
        Connection conn = null;
        Statement stmt = null;
        try {
            DatabaseClass db = DatabaseClass.getInstance();
            conn = db.getConnection();
            
            out.println("<p class='info'>Connected to database successfully</p>");
            
            // Check if columns already exist
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet rs = meta.getColumns(null, null, "questions", "question_type");
            
            if (rs.next()) {
                out.println("<p class='info'>Column 'question_type' already exists</p>");
            } else {
                // Add the missing columns
                stmt = conn.createStatement();
                stmt.executeUpdate("ALTER TABLE questions ADD COLUMN question_type VARCHAR(45) DEFAULT NULL AFTER correct");
                out.println("<p class='success'>Added column 'question_type' successfully</p>");
            }
            rs.close();
            
            rs = meta.getColumns(null, null, "questions", "image_path");
            if (rs.next()) {
                out.println("<p class='info'>Column 'image_path' already exists</p>");
            } else {
                stmt.executeUpdate("ALTER TABLE questions ADD COLUMN image_path VARCHAR(255) DEFAULT NULL AFTER question_type");
                out.println("<p class='success'>Added column 'image_path' successfully</p>");
            }
            rs.close();
            
            rs = meta.getColumns(null, null, "questions", "extra_data");
            if (rs.next()) {
                out.println("<p class='info'>Column 'extra_data' already exists</p>");
            } else {
                stmt.executeUpdate("ALTER TABLE questions ADD COLUMN extra_data TEXT DEFAULT NULL AFTER image_path");
                out.println("<p class='success'>Added column 'extra_data' successfully</p>");
            }
            rs.close();
            
            if (stmt != null) stmt.close();
            
            // Verify the structure
            stmt = conn.createStatement();
            rs = stmt.executeQuery("DESCRIBE questions");
            out.println("<h3>Current Table Structure:</h3>");
            out.println("<table border='1' cellpadding='5'>");
            out.println("<tr><th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th><th>Extra</th></tr>");
            
            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getString("Field") + "</td>");
                out.println("<td>" + rs.getString("Type") + "</td>");
                out.println("<td>" + rs.getString("Null") + "</td>");
                out.println("<td>" + rs.getString("Key") + "</td>");
                out.println("<td>" + rs.getString("Default") + "</td>");
                out.println("<td>" + rs.getString("Extra") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            rs.close();
            
            // Test insert
            out.println("<h3>Testing Insert Operation:</h3>");
            PreparedStatement pstm = conn.prepareStatement(
                "INSERT INTO questions (course_name, question, opt1, opt2, opt3, opt4, correct, question_type, image_path, extra_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            );
            pstm.setString(1, "Test Course");
            pstm.setString(2, "What is 2+2?");
            pstm.setString(3, "3");
            pstm.setString(4, "4");
            pstm.setString(5, "5");
            pstm.setString(6, "6");
            pstm.setString(7, "4");
            pstm.setString(8, "MultipleChoice");
            pstm.setString(9, null);
            pstm.setString(10, "Test data");
            
            int rows = pstm.executeUpdate();
            pstm.close();
            
            if (rows > 0) {
                out.println("<p class='success'>Test insert successful! Rows affected: " + rows + "</p>");
                
                // Verify the insert
                stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT * FROM questions WHERE course_name = 'Test Course'");
                if (rs.next()) {
                    out.println("<p class='success'>Verification successful - data found in table:</p>");
                    out.println("<p><strong>Question:</strong> " + rs.getString("question") + "</p>");
                    out.println("<p><strong>Question Type:</strong> " + rs.getString("question_type") + "</p>");
                    out.println("<p><strong>Extra Data:</strong> " + rs.getString("extra_data") + "</p>");
                }
                rs.close();
                
                // Clean up test data
                stmt.executeUpdate("DELETE FROM questions WHERE course_name = 'Test Course'");
                out.println("<p class='info'>Test data cleaned up</p>");
            } else {
                out.println("<p class='error'>Test insert failed - no rows affected</p>");
            }
            
            out.println("<p class='success'><strong>Database schema update completed successfully!</strong></p>");
            out.println("<p>You can now add questions with all features including question types, images, and extra data.</p>");
            
        } catch (Exception e) {
            out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                // Ignore cleanup errors
            }
        }
    %>
    
    <br><br>
    <a href="questions.jsp">Go to Questions Page</a> | 
    <a href="showall.jsp">View All Questions</a>
</body>
</html>