<%@page import="java.sql.*"%>
<%@page import="myPackage.DatabaseClass"%>
<html>
<head>
    <title>Add Image Path Column</title>
</head>
<body>
    <h2>Adding Image Path Column to Questions Table</h2>
    <%
        try {
            DatabaseClass db = DatabaseClass.getInstance();
            Connection conn = db.getConnection();
            
            // Check if image_path column already exists
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet rs = meta.getColumns(null, null, "questions", "image_path");
            
            if (rs.next()) {
                out.println("<p>Column 'image_path' already exists in the 'questions' table.</p>");
            } else {
                // Add the image_path column
                String sql = "ALTER TABLE questions ADD COLUMN image_path VARCHAR(255) DEFAULT NULL";
                Statement stmt = conn.createStatement();
                stmt.executeUpdate(sql);
                stmt.close();
                
                out.println("<p>Successfully added 'image_path' column to the 'questions' table!</p>");
            }
            
            conn.close();
            out.println("<p>Operation completed successfully.</p>");
            
        } catch (Exception e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    %>
    
    <br><br>
    <a href="questions.jsp">Go back to Questions</a>
</body>
</html>