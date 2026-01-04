<%@ page import="java.sql.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="myPackage.classes.User" %>
<%
    // Check if user is admin/lecturer
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check user type
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
    
    // Get all filter parameters
    int examId = 0;
    String examIdParam = request.getParameter("exam_id");
    if (examIdParam != null && !examIdParam.isEmpty()) {
        try {
            examId = Integer.parseInt(examIdParam);
        } catch (NumberFormatException e) {
            examId = 0;
        }
    }
    
    int studentId = 0;
    String studentIdParam = request.getParameter("student_id");
    if (studentIdParam != null && !studentIdParam.isEmpty()) {
        try {
            studentId = Integer.parseInt(studentIdParam);
        } catch (NumberFormatException e) {
            studentId = 0;
        }
    }
    
    String firstName = request.getParameter("first_name");
    if (firstName == null) firstName = "";
    
    String lastName = request.getParameter("last_name");
    if (lastName == null) lastName = "";
    
    String courseName = request.getParameter("course_name");
    if (courseName == null) courseName = "";
    
    String examDate = request.getParameter("exam_date");
    if (examDate == null) examDate = "";
    
    // Generate filename
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
    Date now = new Date();
    String timestamp = sdf.format(now);
    String filename = "Exam_Register_" + timestamp;
    
    if (examId > 0) {
        filename += "_Exam" + examId;
    }
    if (studentId > 0) {
        filename += "_Student" + studentId;
    }
    if (!courseName.isEmpty()) {
        String safeCourseName = courseName.replaceAll("[^a-zA-Z0-9]", "_");
        filename += "_" + safeCourseName;
    }
    if (!examDate.isEmpty()) {
        filename += "_" + examDate.replace("-", "");
    }
    filename += ".csv";  // CSV extension
    
    // Set CSV headers
    response.setContentType("text/csv; charset=UTF-8");
    response.setHeader("Content-Disposition", "attachment;filename=\"" + filename + "\"");
    
    // Create CSV writer
    PrintWriter outWriter = response.getWriter();
    
    // Write BOM for UTF-8 (optional, helps with Excel)
    outWriter.write('\ufeff');
    
    // Write CSV headers
    outWriter.println("#,Student Name,Student ID,Course,Exam ID,Exam Date,Start Time,End Time,Duration,Email,Status");
    
    try {
        ResultSet rs = pDAO.getFilteredExamRegister(examId, studentId, firstName, lastName, courseName, examDate);
        
        int count = 0;
        int completedCount = 0;
        int inProgressCount = 0;
        long totalDuration = 0;
        
        if (rs != null) {
            while (rs.next()) {
                count++;
                String rsFirstName = rs.getString("first_name");
                String rsLastName = rs.getString("last_name");
                int rsStudentId = rs.getInt("student_id");
                String course = rs.getString("course_name");
                int currentExamId = rs.getInt("exam_id");
                Date examDateObj = rs.getDate("exam_date");
                Time examStartTime = rs.getTime("start_time");
                Time examEndTime = rs.getTime("end_time");
                String email = rs.getString("email");
                
                String studentName = (rsFirstName != null ? rsFirstName.trim() : "") + " " + 
                                   (rsLastName != null ? rsLastName.trim() : "");
                
                // Calculate duration
                String duration = "N/A";
                long durationMillis = 0;
                if (examEndTime != null && examStartTime != null) {
                    long startMillis = examStartTime.getTime();
                    long endMillis = examEndTime.getTime();
                    durationMillis = endMillis - startMillis;
                    totalDuration += durationMillis;
                    
                    long seconds = durationMillis / 1000;
                    long hours = seconds / 3600;
                    long minutes = (seconds % 3600) / 60;
                    long secs = seconds % 60;
                    duration = String.format("%02d:%02d:%02d", hours, minutes, secs);
                }
                
                String status = "In Progress";
                if (examEndTime != null) {
                    status = "Completed";
                    completedCount++;
                } else {
                    inProgressCount++;
                }
                
                // Format date
                String formattedDate = "N/A";
                if (examDateObj != null) {
                    formattedDate = new SimpleDateFormat("dd-MMM-yyyy").format(examDateObj);
                }
                
                // Format times
                String formattedStartTime = "N/A";
                if (examStartTime != null) {
                    formattedStartTime = examStartTime.toString().substring(0, 5);
                }
                
                String formattedEndTime = "N/A";
                if (examEndTime != null) {
                    formattedEndTime = examEndTime.toString().substring(0, 5);
                }
                
                // Escape CSV special characters
                studentName = "\"" + studentName.replace("\"", "\"\"") + "\"";
                course = "\"" + course.replace("\"", "\"\"") + "\"";
                email = "\"" + (email != null ? email.replace("\"", "\"\"") : "N/A") + "\"";
                
                // Write CSV row
                outWriter.print(count + ",");
                outWriter.print(studentName + ",");
                outWriter.print(rsStudentId + ",");
                outWriter.print(course + ",");
                outWriter.print(currentExamId + ",");
                outWriter.print(formattedDate + ",");
                outWriter.print(formattedStartTime + ",");
                outWriter.print(formattedEndTime + ",");
                outWriter.print(duration + ",");
                outWriter.print(email + ",");
                outWriter.println(status);
            }
        }
        
        // Add summary
        if (count > 0) {
            double completionRate = (completedCount * 100.0) / count;
            long avgDuration = count > 0 ? totalDuration / count : 0;
            long avgSeconds = avgDuration / 1000;
            long avgHours = avgSeconds / 3600;
            long avgMinutes = (avgSeconds % 3600) / 60;
            long avgSecs = avgSeconds % 60;
            String avgDurationStr = avgDuration > 0 ? String.format("%02d:%02d:%02d", avgHours, avgMinutes, avgSecs) : "N/A";
            
            outWriter.println();
            outWriter.println("SUMMARY STATISTICS");
            outWriter.println("Total Records," + count);
            outWriter.println("Completed," + completedCount);
            outWriter.println("In Progress," + inProgressCount);
            outWriter.println("Average Duration," + avgDurationStr);
            outWriter.println("Completion Rate," + String.format("%.1f%%", completionRate));
            outWriter.println();
            outWriter.println("Report Generated," + new SimpleDateFormat("dd MMMM yyyy 'at' HH:mm:ss").format(now));
            outWriter.println("Generated By User ID," + session.getAttribute("userId"));
        }
        
        outWriter.flush();
        outWriter.close();
        
    } catch (SQLException e) {
        // If error occurs, write error message
        outWriter.println("ERROR GENERATING REPORT");
        outWriter.println("Error Message," + e.getMessage());
        outWriter.flush();
        outWriter.close();
    }
%>