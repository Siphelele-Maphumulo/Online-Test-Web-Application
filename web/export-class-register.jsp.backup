<%@ page import="java.sql.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="myPackage.classes.User" %>
<%
    // ============ SECURITY AND ACCESS CONTROL ============
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check user type for authorization
    String userType = (String) session.getAttribute("userType");
    if (userType == null) {
        int userId = Integer.parseInt(session.getAttribute("userId").toString());
        User user = DatabaseClass.getInstance().getUserDetails(String.valueOf(userId));
        if (user != null) {
            userType = user.getType();
            session.setAttribute("userType", userType);
        }
    }

    if (!("admin".equals(userType) || "lecture".equals(userType) || "staff".equals(userType))) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }
    
    // ============ FILTER PARAMETERS ============
    String studentNameFilter = request.getParameter("student_name");
    if (studentNameFilter == null) studentNameFilter = "";
    
    String dateFilter = request.getParameter("registration_date");
    if (dateFilter == null) dateFilter = "";
    
    // Additional filters for enhanced reporting
    String courseFilter = request.getParameter("course");
    if (courseFilter == null) courseFilter = "";
    
    String timeRangeFilter = request.getParameter("time_range");
    if (timeRangeFilter == null) timeRangeFilter = "";
    
    // ============ REPORT GENERATION SETUP ============
    DatabaseClass pDAO = DatabaseClass.getInstance();
    
    // Generate dynamic filename with timestamp
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
    Date now = new Date();
    String timestamp = sdf.format(now);
    String filename = "Class_Register_" + timestamp;
    
    if (!studentNameFilter.isEmpty()) {
        String safeName = studentNameFilter.replaceAll("[^a-zA-Z0-9]", "_");
        filename += "_" + safeName.substring(0, Math.min(safeName.length(), 20));
    }
    if (!dateFilter.isEmpty()) {
        filename += "_" + dateFilter.replace("-", "");
    }
    filename += ".html";
    
    // Set headers for download
    response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-Disposition", "attachment;filename=\"" + filename + "\"");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Attendance Register Report</title>
    <style>
        /* Professional Attendance Register Report Styling */
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
            --present-color: #10b981;
            --absent-color: #ef4444;
            --late-color: #f59e0b;
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
            content: "?";
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
        
        /* Time indicators */
        .time-indicator {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 500;
        }
        
        .morning-time {
            background: linear-gradient(135deg, #4a90e2, #1a3d6d);
            color: var(--white);
        }
        
        .afternoon-time {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: var(--white);
        }
        
        .evening-time {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
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
        
        /* Column-specific widths */
        .col-serial { width: 50px; }
        .col-register-id { width: 80px; }
        .col-student-id { width: 100px; }
        .col-student-name { width: 200px; }
        .col-date { width: 100px; }
        .col-time { width: 80px; }
        .col-status { width: 100px; }
        .col-remarks { width: 150px; }
        
        /* Status indicators */
        .present-indicator {
            color: var(--success-green);
            font-weight: 600;
        }
        
        .absent-indicator {
            color: var(--absent-color);
            font-weight: 600;
        }
        
        .late-indicator {
            color: var(--late-color);
            font-weight: 600;
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
    </style>
</head>
<body>
    <div class="report-container">
        <!-- Report Header -->
        <div class="report-header">
            <div class="institution-logo">
                <div class="logo-col">
                    <div class="logo-symbol">
                        <img src="https://github.com/Siphelele-Maphumulo/Online-Test-Web-Application/blob/fix/export-button-filtered-data-18053524147114085452/web/IMG/mut.png?raw=true" 
                             alt="Institution Logo" 
                             style="width: 50px; height: 50px; border-radius: 50%;">
                    </div>
                </div>
                <div class="institution-name">CODE SA INSTITUTE</div>
            </div>
            <h1 class="report-title">CLASS ATTENDANCE REGISTER</h1>
            <div class="report-subtitle">CodeSA Institute Pty Ltd | Official Class Records</div>
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
                    <div class="metadata-value">ATT-REG-<%= timestamp %></div>
                </div>
            </div>
        </div>
        
        <!-- Filters Section -->
        <div class="filters-section">
<!--            <div class="filters-title">APPLIED FILTERS</div>-->
            <div class="filters-grid">
                <% 
                    boolean hasFilters = false;
                    List<String> activeFilters = new ArrayList<>();
                    
                    if (!studentNameFilter.isEmpty()) { 
                        activeFilters.add("Student Name: " + studentNameFilter);
                        hasFilters = true;
                    }
                    if (!dateFilter.isEmpty()) { 
                        activeFilters.add("Date: " + dateFilter);
                        hasFilters = true;
                    }
                    if (!courseFilter.isEmpty()) { 
                        activeFilters.add("Course: " + courseFilter);
                        hasFilters = true;
                    }
                    if (!timeRangeFilter.isEmpty()) { 
                        activeFilters.add("Time Range: " + timeRangeFilter);
                        hasFilters = true;
                    }
                    
                    if (hasFilters) {
                        for (String filter : activeFilters) {
                %>
                <div class="filter-item">
                    <span class="filter-label">?</span> <%= filter %>
                </div>
                <%
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
                        <th class="col-register-id">Register ID</th>
                        <th class="col-student-id">Student ID</th>
                        <th class="col-student-name">Student Name</th>
                        <th class="col-date">Registration Date</th>
                        <th class="col-time">Registration Time</th>
                        <th class="col-status">Status</th>
                        <th class="col-remarks">Remarks</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        // Get filtered data from database
                        java.util.ArrayList<java.util.Map<String, String>> registerList = 
                            pDAO.getFilteredDailyRegister(studentNameFilter, dateFilter);
                        
                        int totalRecords = 0;
                        int morningCount = 0;
                        int afternoonCount = 0;
                        int eveningCount = 0;
                        
                        if (registerList != null && !registerList.isEmpty()) {
                            for (java.util.Map<String, String> record : registerList) {
                                totalRecords++;
                                String registerId = record.get("register_id");
                                String studentId = record.get("student_id");
                                String studentName = record.get("student_name");
                                String registrationDate = record.get("registration_date");
                                String registrationTime = record.get("registration_time");
                                
                                // Determine time of day for styling
                                String timeClass = "";
                                if (registrationTime != null && !registrationTime.isEmpty()) {
                                    try {
                                        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
                                        java.util.Date time = timeFormat.parse(registrationTime);
                                        int hour = time.getHours();
                                        
                                        if (hour < 12) {
                                            timeClass = "morning-time";
                                            morningCount++;
                                        } else if (hour < 17) {
                                            timeClass = "afternoon-time";
                                            afternoonCount++;
                                        } else {
                                            timeClass = "evening-time";
                                            eveningCount++;
                                        }
                                    } catch (Exception e) {
                                        timeClass = "";
                                    }
                                }
                                
                                // Determine attendance status (you can customize this logic)
                                String status = "Present";
                                String statusClass = "present-indicator";
                                String remarks = "";
                                
                                // You can add logic here to determine if student was late, absent, etc.
                                // For now, we'll mark everyone as present in this example
                %>
                <tr>
                    <td class="text-center"><%= totalRecords %></td>
                    <td class="text-center"><code><%= registerId %></code></td>
                    <td class="text-center"><code><%= studentId %></code></td>
                    <td><strong><%= studentName != null ? studentName : "N/A" %></strong></td>
                    <td class="text-center"><%= registrationDate != null ? registrationDate : "N/A" %></td>
                    <td class="text-center">
                        <% if (registrationTime != null && !registrationTime.isEmpty()) { %>
                            <span class="time-indicator <%= timeClass %>">
                                <%= registrationTime.substring(0, Math.min(registrationTime.length(), 8)) %>
                            </span>
                        <% } else { %>
                            N/A
                        <% } %>
                    </td>
                    <td class="text-center <%= statusClass %>"><%= status %></td>
                    <td class="text-center"><small><%= remarks %></small></td>
                </tr>
                <%
                            }
                        }
                        
                        // Calculate statistics
                        double morningPercentage = totalRecords > 0 ? (morningCount * 100.0) / totalRecords : 0;
                        double afternoonPercentage = totalRecords > 0 ? (afternoonCount * 100.0) / totalRecords : 0;
                        double eveningPercentage = totalRecords > 0 ? (eveningCount * 100.0) / totalRecords : 0;
                        
                %>
                </tbody>
            </table>
            
            <!-- Summary Section -->
            <% if (totalRecords > 0) { %>
            <div class="summary-section">
                <div class="summary-title">ATTENDANCE SUMMARY</div>
                <div class="summary-grid">
                    <div class="summary-card">
                        <div class="summary-value"><%= totalRecords %></div>
                        <div class="summary-label">Total Registrations</div>
                    </div>
                    <div class="summary-card highlight-stat">
                        <div class="summary-value"><%= morningCount %></div>
                        <div class="summary-label">Morning Sessions</div>
                        <small>(<%= String.format("%.1f%%", morningPercentage) %>)</small>
                    </div>
                    <div class="summary-card">
                        <div class="summary-value"><%= afternoonCount %></div>
                        <div class="summary-label">Afternoon Sessions</div>
                        <small>(<%= String.format("%.1f%%", afternoonPercentage) %>)</small>
                    </div>
                    <div class="summary-card">
                        <div class="summary-value"><%= eveningCount %></div>
                        <div class="summary-label">Evening Sessions</div>
                        <small>(<%= String.format("%.1f%%", eveningPercentage) %>)</small>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div style="text-align: center; padding: 40px; color: var(--dark-gray);">
                <div style="font-size: 24px; margin-bottom: 10px;">?</div>
                <h3 style="color: var(--primary-blue); margin-bottom: 10px;">No Attendance Records Found</h3>
                <p>No class attendance records match the specified criteria.</p>
                <p style="font-size: 12px; margin-top: 10px;">Try adjusting your filters or contact the administrator.</p>
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
    } catch (Exception e) {
        // Error handling
        out.println("<div style='padding: 40px; text-align: center; color: #dc2626; border: 1px solid #fecaca; border-radius: 8px; background: #fef2f2;'>");
        out.println("<h3 style='color: #dc2626; margin-bottom: 15px;'>?? ERROR GENERATING ATTENDANCE REPORT</h3>");
        out.println("<p style='font-family: monospace; background: #fee2e2; padding: 10px; border-radius: 4px;'>" + e.getMessage() + "</p>");
        out.println("<p style='margin-top: 15px; font-size: 12px; color: #7f1d1d;'>Please contact system administrator for assistance.</p>");
        out.println("</div>");
    }
%>