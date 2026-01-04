<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.List" %>
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

    PrintWriter outWriter = response.getWriter();
    
    // Write CSV headers
    outWriter.println("Student Name,Student ID,Email,Course,Exam ID,Exam Date,Start Time,End Time,Duration,Status");
    
    try {
        ResultSet rs = pDAO.getFilteredExamRegister(examId, studentId, firstNameFilter, 
                                                   lastNameFilter, courseNameFilter, dateFilter);
        
        if (rs != null) {
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
                
                // Escape quotes in CSV
                String studentName = "\"" + rs.getString("first_name") + " " + rs.getString("last_name") + "\"";
                String email = "\"" + rs.getString("email") + "\"";
                String course = "\"" + rs.getString("course_name") + "\"";
                
                // Write CSV row
                outWriter.print(studentName + ",");
                outWriter.print(rs.getInt("student_id") + ",");
                outWriter.print(email + ",");
                outWriter.print(course + ",");
                outWriter.print(rs.getInt("exam_id") + ",");
                outWriter.print(rs.getDate("exam_date") + ",");
                outWriter.print(rs.getTime("start_time") + ",");
                outWriter.print((endTime != null ? endTime : "?") + ",");
                outWriter.print(duration + ",");
                outWriter.println(status);
            }
        }
        
        outWriter.flush();
        outWriter.close();
        
    } catch (Exception e) {
        // If there's an error, redirect back with error message
        session.setAttribute("errorMessage", "Error exporting data: " + e.getMessage());
        response.sendRedirect("adm-page.jsp?pgprt=7");
    }
%>