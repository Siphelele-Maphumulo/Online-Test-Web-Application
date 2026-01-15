<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Email Check Diagnostic</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #09294d; color: white; }
        .test-form { background: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0; }
        input[type="text"] { padding: 8px; width: 300px; }
        button { padding: 10px 20px; background: #09294d; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>
    <h1>🔍 Email Check Diagnostic Tool</h1>
    
    <% 
    DatabaseClass pDAO = DatabaseClass.getInstance();
    
    // Test if we can query the database
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = pDAO.getConnection();
        
        // Display all emails in users table
        out.println("<h2>📧 All Emails in 'users' Table:</h2>");
        out.println("<table>");
        out.println("<tr><th>User ID</th><th>First Name</th><th>Last Name</th><th>Email</th><th>User Type</th></tr>");
        
        String sql = "SELECT user_id, first_name, last_name, email, user_type FROM users";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
        
        int count = 0;
        while(rs.next()) {
            count++;
            out.println("<tr>");
            out.println("<td>" + rs.getInt("user_id") + "</td>");
            out.println("<td>" + rs.getString("first_name") + "</td>");
            out.println("<td>" + rs.getString("last_name") + "</td>");
            out.println("<td><strong>" + rs.getString("email") + "</strong></td>");
            out.println("<td>" + rs.getString("user_type") + "</td>");
            out.println("</tr>");
        }
        
        out.println("</table>");
        out.println("<p class='success'>✓ Total users found: " + count + "</p>");
        
        rs.close();
        ps.close();
        
    } catch(Exception e) {
        out.println("<p class='error'>❌ Database Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch(SQLException e) {
            e.printStackTrace();
        }
    }
    %>
    
    <hr>
    
    <h2>🧪 Test Email Check Function</h2>
    <div class="test-form">
        <form method="POST">
            <label>Enter email to test:</label><br>
            <input type="text" name="testEmail" placeholder="e.g., user@example.com" required>
            <button type="submit">Check Email</button>
        </form>
        
        <% 
        String testEmail = request.getParameter("testEmail");
        if (testEmail != null && !testEmail.isEmpty()) {
            out.println("<h3>Test Results for: <code>" + testEmail + "</code></h3>");
            
            try {
                boolean exists = pDAO.checkEmailExists(testEmail);
                
                if (exists) {
                    out.println("<p class='success'>✓ Email EXISTS in database</p>");
                } else {
                    out.println("<p class='error'>✗ Email NOT FOUND in database</p>");
                }
                
                // Also test with trimmed version
                String trimmed = testEmail.trim();
                if (!trimmed.equals(testEmail)) {
                    out.println("<p><strong>Note:</strong> Testing with trimmed version: '" + trimmed + "'</p>");
                    boolean existsTrimmed = pDAO.checkEmailExists(trimmed);
                    if (existsTrimmed) {
                        out.println("<p class='success'>✓ Trimmed email EXISTS</p>");
                        out.println("<p class='error'>⚠️ Issue: Your email has leading/trailing spaces!</p>");
                    }
                }
                
            } catch(Exception e) {
                out.println("<p class='error'>❌ Error checking email: " + e.getMessage() + "</p>");
            }
        }
        %>
    </div>
    
    <hr>
    
    <h2>📝 Instructions:</h2>
    <ol>
        <li>Check the table above to see all emails in your database</li>
        <li>Copy an email exactly as it appears</li>
        <li>Test it using the form above</li>
        <li>If it shows "Email EXISTS", try it on the Forgot Password page</li>
        <li>Check browser console (F12) for debug messages</li>
        <li>Check server logs for "Checking email:" messages</li>
    </ol>
    
    <p><a href="Forgot_Password.jsp">← Go to Forgot Password Page</a></p>
</body>
</html>
