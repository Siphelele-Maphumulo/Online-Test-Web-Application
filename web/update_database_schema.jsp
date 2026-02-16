<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Update Database Schema</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; }
        .error { color: red; }
        .info { color: blue; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Database Schema Update</h1>
    
    <%
    Connection conn = null;
    Statement stmt = null;
    try {
        // Database connection - adjust these parameters to match your setup
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam_system", "root", "");
        stmt = conn.createStatement();
        
        out.println("<p class='info'>Connected to database successfully.</p>");
        
        // Read the SQL file
        String filePath = application.getRealPath("/") + "../db script/drag_drop_tables.sql";
        File sqlFile = new File(filePath);
        
        if (!sqlFile.exists()) {
            out.println("<p class='error'>SQL file not found at: " + filePath + "</p>");
            return;
        }
        
        BufferedReader reader = new BufferedReader(new FileReader(sqlFile));
        StringBuilder sqlBuilder = new StringBuilder();
        String line;
        
        while ((line = reader.readLine()) != null) {
            // Skip comments and empty lines
            if (!line.trim().startsWith("--") && !line.trim().isEmpty()) {
                sqlBuilder.append(line).append(" ");
            }
        }
        reader.close();
        
        // Split by semicolon to get individual statements
        String[] statements = sqlBuilder.toString().split(";");
        
        int successCount = 0;
        int errorCount = 0;
        
        for (String sql : statements) {
            String trimmedSql = sql.trim();
            if (!trimmedSql.isEmpty()) {
                try {
                    stmt.execute(trimmedSql);
                    successCount++;
                    out.println("<p class='success'>✓ Executed: " + trimmedSql.substring(0, Math.min(50, trimmedSql.length())) + "...</p>");
                } catch (SQLException e) {
                    // Ignore "table already exists" errors
                    if (e.getMessage().contains("already exists") || e.getMessage().contains("Duplicate column")) {
                        out.println("<p class='info'>○ Skipped (already exists): " + trimmedSql.substring(0, Math.min(50, trimmedSql.length())) + "...</p>");
                        successCount++;
                    } else {
                        out.println("<p class='error'>✗ Error: " + e.getMessage() + "</p>");
                        out.println("<pre>" + trimmedSql + "</pre>");
                        errorCount++;
                    }
                }
            }
        }
        
        out.println("<h2>Update Complete</h2>");
        out.println("<p class='success'>Successfully executed " + successCount + " statements.</p>");
        if (errorCount > 0) {
            out.println("<p class='error'>Encountered " + errorCount + " errors.</p>");
        }
        out.println("<p><a href='adm-page.jsp'>Return to Admin Panel</a></p>");
        
    } catch (Exception e) {
        out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
        e.printStackTrace(new PrintWriter(out));
    } finally {
        try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
    %>
</body>
</html>