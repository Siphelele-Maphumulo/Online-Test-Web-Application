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
    filename += ".html";  // HTML extension for better formatting
    
    // Set headers for HTML download
    response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-Disposition", "attachment;filename=\"" + filename + "\"");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Register Report</title>
    <style>
        /* Professional Exam Register Report Styling */
        :root {
            --primary-blue: #09294d;
            --secondary-blue: #1a3d6d;
            --accent-blue: #4a90e2;
            --success-green: #059669;
            --warning-orange: #d97706;
            --light-gray: #f8fafc;
            --medium-gray: #e2e8f0;
            --dark-gray: #64748b;
            --text-dark: #1e293b;
            --white: #ffffff;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: var(--text-dark);
            background-color: var(--white);
            padding: 20px;
        }
        
        /* Report Container */
        .report-container {
            max-width: 1200px;
            margin: 0 auto;
            border: 1px solid var(--medium-gray);
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }
        
        /* Header Section */
        .report-header {
            background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
            color: var(--white);
            padding: 30px;
            text-align: center;
            border-bottom: 4px solid var(--accent-blue);
        }
        
        .institution-logo {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .logo-symbol {
            width: 60px;
            height: 60px;
            background: var(--white);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-blue);
            font-size: 28px;
            font-weight: bold;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        
        .institution-name {
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        
        .report-title {
            font-size: 32px;
            font-weight: 800;
            margin: 10px 0;
            letter-spacing: 1px;
        }
        
        .report-subtitle {
            font-size: 18px;
            font-weight: 300;
            opacity: 0.9;
            margin-bottom: 15px;
        }
        
        /* Metadata Section */
        .metadata-section {
            background: var(--light-gray);
            padding: 20px;
            border-bottom: 2px solid var(--medium-gray);
        }
        
        .metadata-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 15px;
        }
        
        .metadata-card {
            background: var(--white);
            padding: 15px;
            border-radius: 6px;
            border-left: 4px solid var(--accent-blue);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
        
        .metadata-label {
            font-weight: 600;
            color: var(--primary-blue);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 5px;
        }
        
        .metadata-value {
            font-size: 14px;
            color: var(--text-dark);
            font-weight: 500;
        }
        
        /* Filters Section */
        .filters-section {
            background: var(--white);
            padding: 20px;
            border-bottom: 1px dashed var(--medium-gray);
        }
        
        .filters-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--primary-blue);
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .filters-title:before {
            content: "??";
            font-size: 14px;
        }
        
        .filters-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 10px;
        }
        
        .filter-item {
            padding: 8px 12px;
            background: var(--light-gray);
            border-radius: 4px;
            font-size: 13px;
        }
        
        .filter-label {
            font-weight: 600;
            color: var(--dark-gray);
            margin-right: 5px;
        }
        
        /* Data Table */
        .data-section {
            padding: 0;
        }
        
        .data-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 13px;
        }
        
        .data-table thead th {
            background: linear-gradient(to bottom, var(--primary-blue), var(--secondary-blue));
            color: var(--white);
            padding: 14px 12px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 12px;
            border: none;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        
        .data-table thead th:first-child {
            border-top-left-radius: 0;
        }
        
        .data-table thead th:last-child {
            border-top-right-radius: 0;
        }
        
        .data-table tbody tr {
            transition: background-color 0.2s ease;
        }
        
        .data-table tbody tr:nth-child(even) {
            background-color: var(--light-gray);
        }
        
        .data-table tbody tr:hover {
            background-color: #e8f4ff;
        }
        
        .data-table td {
            padding: 12px;
            border-bottom: 1px solid var(--medium-gray);
            vertical-align: middle;
        }
        
        .data-table td:first-child {
            font-weight: 600;
            color: var(--primary-blue);
        }
        
        /* Status Badges */
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-completed {
            background: linear-gradient(135deg, #10b981, #059669);
            color: var(--white);
        }
        
        .status-inprogress {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: var(--white);
        }
        
        /* Summary Section */
        .summary-section {
            background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
            color: var(--white);
            padding: 25px;
            margin-top: 20px;
            border-radius: 8px;
        }
        
        .summary-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .summary-title:before {
            content: "?";
            font-size: 16px;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .summary-card {
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 6px;
            text-align: center;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .summary-value {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .summary-label {
            font-size: 12px;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .highlight-stat {
            background: rgba(255, 255, 255, 0.2);
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        /* Footer */
        .report-footer {
            background: var(--light-gray);
            padding: 20px;
            text-align: center;
            border-top: 1px solid var(--medium-gray);
            margin-top: 30px;
        }
        
        .footer-text {
            font-size: 12px;
            color: var(--dark-gray);
            margin-bottom: 5px;
        }
        
        .report-id {
            font-family: 'Courier New', monospace;
            font-weight: 600;
            color: var(--primary-blue);
        }
        
        /* Print-specific styles */
        @media print {
            body {
                padding: 0;
            }
            
            .report-container {
                box-shadow: none;
                border: 1px solid #000;
            }
            
            .data-table thead th {
                background: #000 !important;
                color: #fff !important;
                -webkit-print-color-adjust: exact;
            }
        }
        
        /* Column-specific widths */
        .col-serial { width: 50px; }
        .col-name { width: 200px; }
        .col-id { width: 100px; }
        .col-course { width: 150px; }
        .col-exam-id { width: 80px; }
        .col-date { width: 100px; }
        .col-time { width: 80px; }
        .col-duration { width: 90px; }
        .col-email { width: 180px; }
        .col-status { width: 100px; }
    </style>
</head>
<body>
    <div class="report-container">
        <!-- Report Header -->
        <div class="report-header">
            <div class="institution-logo">
            <div class="logo-col">
                <a href="index.jsp" class="logo-link logo-symbol">
                    <img src="https://github.com/Siphelele-Maphumulo/Online-Test-Web-Application/blob/fix/export-button-filtered-data-18053524147114085452/web/IMG/mut.png?raw=true" 
                         alt="MUT Logo" 
                         class="header-logo logo-symbol">
                </a>
            </div>
                <div class="institution-name">CODE SA TESTINGS</div>
            </div>
            <h1 class="report-title">ATTENDANCE REGISTER</h1>
            <div class="report-subtitle">CodeSA Institute Pty Ltd | Official Examination Records</div>
        </div>
        
        <!-- Metadata Section -->
        <div class="metadata-section">
            <div class="metadata-grid">
                <div class="metadata-card">
                    <div class="metadata-label">Report Generated</div>
                    <div class="metadata-value"><%= new SimpleDateFormat("dd MMMM yyyy 'at' HH:mm:ss").format(now) %></div>
                </div>
                <div class="metadata-card">
                    <div class="metadata-label">Generated By</div>
                    <div class="metadata-value">User ID: <%= session.getAttribute("userId") %></div>
                </div>
                <div class="metadata-card">
                    <div class="metadata-label">Report ID</div>
                    <div class="metadata-value">EXR-<%= timestamp %></div>
                </div>
            </div>
        </div>
        
        <!-- Filters Section -->
        <div class="filters-section">
<!--            <div class="filters-title">APPLIED FILTERS</div>-->
            <div class="filters-grid">
                <% 
                    boolean hasFilters = false;
                    String[] filters = new String[6];
                    
                    if (examId > 0) { 
                        filters[0] = "Exam ID: " + examId;
                        hasFilters = true;
                    }
                    if (studentId > 0) { 
                        filters[1] = "Student ID: " + studentId;
                        hasFilters = true;
                    }
                    if (!firstName.isEmpty()) { 
                        filters[2] = "First Name: " + firstName;
                        hasFilters = true;
                    }
                    if (!lastName.isEmpty()) { 
                        filters[3] = "Last Name: " + lastName;
                        hasFilters = true;
                    }
                    if (!courseName.isEmpty()) { 
                        filters[4] = "Course: " + courseName;
                        hasFilters = true;
                    }
                    if (!examDate.isEmpty()) { 
                        filters[5] = "Date: " + examDate;
                        hasFilters = true;
                    }
                    
                    if (hasFilters) {
                        for (String filter : filters) {
                            if (filter != null) {
                %>
                <div class="filter-item">
                    <span class="filter-label">?</span> <%= filter %>
                </div>
                <%
                            }
                        }
                    } else {
                %>
                <div class="filter-item">
                    <span class="filter-label">?</span> All Records (No Filters Applied)
                </div>
                <%
                    }
                %>
            </div>
        </div>
        
        <!-- Data Section -->
        <div class="data-section">
            <table class="data-table">
                <thead>
                    <tr>
                        <th class="col-serial">#</th>
                        <th class="col-name">Student Name</th>
                        <th class="col-id">Student ID</th>
                        <th class="col-course">Course</th>
                        <th class="col-exam-id">Exam ID</th>
                        <th class="col-date">Exam Date</th>
                        <th class="col-time">Start Time</th>
                        <th class="col-time">End Time</th>
                        <th class="col-duration">Duration</th>
                        <th class="col-email">Email</th>
                        <th class="col-status">Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
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
                                String statusClass = "status-inprogress";
                                if (examEndTime != null) {
                                    status = "Completed";
                                    statusClass = "status-completed";
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
                %>
                <tr>
                    <td class="text-center"><%= count %></td>
                    <td><strong><%= studentName %></strong></td>
                    <td class="text-center"><code><%= rsStudentId %></code></td>
                    <td><%= course %></td>
                    <td class="text-center"><%= currentExamId %></td>
                    <td class="text-center"><%= formattedDate %></td>
                    <td class="text-center"><%= formattedStartTime %></td>
                    <td class="text-center"><%= formattedEndTime %></td>
                    <td class="text-center"><%= duration %></td>
                    <td><small><%= email != null ? email : "N/A" %></small></td>
                    <td class="text-center">
                        <span class="status-badge <%= statusClass %>"><%= status %></span>
                    </td>
                </tr>
                <%
                            }
                        }
                        
                        // Calculate statistics
                        double completionRate = count > 0 ? (completedCount * 100.0) / count : 0;
                        long avgDuration = count > 0 ? totalDuration / count : 0;
                        long avgSeconds = avgDuration / 1000;
                        long avgHours = avgSeconds / 3600;
                        long avgMinutes = (avgSeconds % 3600) / 60;
                        long avgSecs = avgSeconds % 60;
                        String avgDurationStr = avgDuration > 0 ? String.format("%02d:%02d:%02d", avgHours, avgMinutes, avgSecs) : "N/A";
                        
                %>
                </tbody>
            </table>
            
            <!-- Summary Section -->
            <% if (count > 0) { %>
            <div class="summary-section">
                <div class="summary-title">PERFORMANCE SUMMARY</div>
                <div class="summary-grid">
                    <div class="summary-card">
                        <div class="summary-value"><%= count %></div>
                        <div class="summary-label">Total Records</div>
                    </div>
                    <div class="summary-card highlight-stat">
                        <div class="summary-value"><%= completedCount %></div>
                        <div class="summary-label">Exams Completed</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-value"><%= inProgressCount %></div>
                        <div class="summary-label">In Progress</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-value"><%= avgDurationStr %></div>
                        <div class="summary-label">Avg Duration</div>
                    </div>
                    <div class="summary-card highlight-stat">
                        <div class="summary-value"><%= String.format("%.1f%%", completionRate) %></div>
                        <div class="summary-label">Completion Rate</div>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div style="text-align: center; padding: 40px; color: var(--dark-gray);">
                <div style="font-size: 24px; margin-bottom: 10px;">?</div>
                <h3 style="color: var(--primary-blue); margin-bottom: 10px;">No Records Found</h3>
                <p>No exam register records match the specified criteria.</p>
            </div>
            <% } %>
            
        </div>
        
        <!-- Report Footer -->
        <div class="report-footer">
            <div class="footer-text">This is an official document generated by the Professional Testing System</div>
            <div class="footer-text">Report ID: <span class="report-id">EXR-<%= timestamp %></span> | System Version: 2.1</div>
            <div class="footer-text">© <%= new SimpleDateFormat("yyyy").format(now) %> CodeSA Institute Pty Ltd. All rights reserved.</div>
            <div class="footer-text" style="margin-top: 10px; font-size: 11px; color: var(--dark-gray);">
                Document Classification: INTERNAL USE | Valid until: <%= new SimpleDateFormat("dd MMM yyyy").format(new Date(now.getTime() + 3L * 30 * 24 * 60 * 60 * 1000)) %>
            </div>
        </div>
    </div>
</body>
</html>
<%
    } catch (SQLException e) {
        // Error handling
        out.println("<div style='padding: 40px; text-align: center; color: #dc2626;'>");
        out.println("<h3>ERROR GENERATING REPORT</h3>");
        out.println("<p>" + e.getMessage() + "</p>");
        out.println("</div>");
    }
%>