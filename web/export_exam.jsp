<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.User" %>
<%
    // Authentication check
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");
    if (userType == null) {
        int userId = Integer.parseInt(session.getAttribute("userId").toString());
        User user = DatabaseClass.getInstance().getUserDetails(String.valueOf(userId));
        if (user != null) {
            userType = user.getType();
            session.setAttribute("userType", userType);
        }
    }

    if (!("admin".equals(userType) || "lecture".equals(userType))) {
        response.sendRedirect("std-page.jsp");
        return;
    }

    DatabaseClass pDAO = DatabaseClass.getInstance();

    // Get filter parameters
    int examId = 0;
    try {
        examId = Integer.parseInt(request.getParameter("exam_id"));
    } catch (Exception ignored) {}

    int studentId = 0;
    try {
        studentId = Integer.parseInt(request.getParameter("student_id"));
    } catch (Exception ignored) {}

    String firstNameFilter = request.getParameter("first_name");
    if (firstNameFilter == null) firstNameFilter = "";

    String lastNameFilter = request.getParameter("last_name");
    if (lastNameFilter == null) lastNameFilter = "";

    String courseNameFilter = request.getParameter("course_name");
    if (courseNameFilter == null) courseNameFilter = "";

    String dateFilter = request.getParameter("exam_date");
    if (dateFilter == null) dateFilter = "";

    // Set response headers for Excel download
    response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-Disposition", "attachment; filename=\"exam_register_export.xls\"");
    response.setCharacterEncoding("UTF-8");

    PrintWriter outWriter = response.getWriter();
    
    // Write HTML table for Excel
    outWriter.println("<html>");
    outWriter.println("<head>");
    outWriter.println("<style>");
    outWriter.println("table { border-collapse: collapse; width: 100%; }");
    outWriter.println("th { background-color: #f2f2f2; border: 1px solid #ddd; padding: 8px; text-align: left; font-weight: bold; }");
    outWriter.println("td { border: 1px solid #ddd; padding: 8px; }");
    outWriter.println("</style>");
    outWriter.println("</head>");
    outWriter.println("<body>");
    outWriter.println("<h3>Exam Register Export</h3>");
    outWriter.println("<p>Generated on: " + new java.util.Date() + "</p>");
    outWriter.println("<table>");
    
    // Write table headers
    outWriter.println("<tr>");
    outWriter.println("<th>#</th>");
    outWriter.println("<th>Student Name</th>");
    outWriter.println("<th>Student ID</th>");
    outWriter.println("<th>Email</th>");
    outWriter.println("<th>Course</th>");
    outWriter.println("<th>Exam ID</th>");
    outWriter.println("<th>Exam Date</th>");
    outWriter.println("<th>Start Time</th>");
    outWriter.println("<th>End Time</th>");
    outWriter.println("<th>Duration</th>");
    outWriter.println("<th>Status</th>");
    outWriter.println("</tr>");
    
    try {
        ResultSet rs = pDAO.getFilteredExamRegister(examId, studentId, firstNameFilter, 
                                                   lastNameFilter, courseNameFilter, dateFilter);
        
        if (rs != null) {
            int counter = 1;
            while (rs.next()) {
                boolean completed = rs.getTime("end_time") != null;
                String status = completed ? "Completed" : "In Progress";
                
                // Calculate duration
                String duration = "?";
                java.sql.Time endTime = rs.getTime("end_time");
                java.sql.Time startTime = rs.getTime("start_time");
                
                if (endTime != null && startTime != null) {
                    long startMillis = startTime.getTime();
                    long endMillis = endTime.getTime();
                    long durationMillis = endMillis - startMillis;
                    
                    long seconds = durationMillis / 1000;
                    long hours = seconds / 3600;
                    long minutes = (seconds % 3600) / 60;
                    long secs = seconds % 60;
                    
                    duration = String.format("%02d:%02d:%02d", hours, minutes, secs);
                }
                
                // Write table row
                outWriter.println("<tr>");
                outWriter.println("<td>" + counter + "</td>");
                outWriter.println("<td>" + rs.getString("first_name") + " " + rs.getString("last_name") + "</td>");
                outWriter.println("<td>" + rs.getInt("student_id") + "</td>");
                outWriter.println("<td>" + (rs.getString("email") != null ? rs.getString("email") : "") + "</td>");
                outWriter.println("<td>" + rs.getString("course_name") + "</td>");
                outWriter.println("<td>" + rs.getInt("exam_id") + "</td>");
                outWriter.println("<td>" + rs.getDate("exam_date") + "</td>");
                outWriter.println("<td>" + (rs.getTime("start_time") != null ? rs.getTime("start_time") : "") + "</td>");
                outWriter.println("<td>" + (endTime != null ? endTime : "?") + "</td>");
                outWriter.println("<td>" + duration + "</td>");
                outWriter.println("<td>" + status + "</td>");
                outWriter.println("</tr>");
                counter++;
            }
            
            // Add summary row
            outWriter.println("<tr style='background-color: #f9f9f9; font-weight: bold;'>");
            outWriter.println("<td colspan='10' style='text-align: right;'>Total Records:</td>");
            outWriter.println("<td>" + (counter - 1) + "</td>");
            outWriter.println("</tr>");
        } else {
            outWriter.println("<tr><td colspan='11' style='text-align: center;'>No records found</td></tr>");
        }
        
        outWriter.println("</table>");
        
        // Add filter information
        outWriter.println("<br><br>");
        outWriter.println("<div style='font-size: 12px; color: #666;'>");
        outWriter.println("<strong>Export Filters:</strong><br>");
        outWriter.println("First Name: " + (firstNameFilter.isEmpty() ? "All" : firstNameFilter) + "<br>");
        outWriter.println("Last Name: " + (lastNameFilter.isEmpty() ? "All" : lastNameFilter) + "<br>");
        outWriter.println("Course: " + (courseNameFilter.isEmpty() ? "All" : courseNameFilter) + "<br>");
        outWriter.println("Exam Date: " + (dateFilter.isEmpty() ? "All" : dateFilter) + "<br>");
        outWriter.println("</div>");
        
        outWriter.println("</body>");
        outWriter.println("</html>");
        
        outWriter.flush();
        outWriter.close();
        
    } catch (Exception e) {
        // If there's an error, write error message
        outWriter.println("<html><body>");
        outWriter.println("<h3>Error Exporting Data</h3>");
        outWriter.println("<p>" + e.getMessage() + "</p>");
        outWriter.println("</body></html>");
        outWriter.flush();
        outWriter.close();
        e.printStackTrace();
    }
%>