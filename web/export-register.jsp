<%@ page import="java.lang.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="application/vnd.ms-excel" %>
<%
    // Set content type for Excel
    response.setContentType("application/vnd.ms-excel");
    
    // Check if user is admin/lecturer
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    
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
    String timestamp = sdf.format(new Date());
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
    filename += ".xls";
    
    response.setHeader("Content-Disposition", "attachment;filename=" + filename);
%>
<html xmlns:o="urn:schemas-microsoft-com:office:office" 
      xmlns:x="urn:schemas-microsoft-com:office:excel" 
      xmlns="http://www.w3.org/TR/REC-html40">
<head>
    <meta charset="UTF-8">
    <!--[if gte mso 9]>
    <xml>
        <x:ExcelWorkbook>
            <x:ExcelWorksheets>
                <x:ExcelWorksheet>
                    <x:Name>Exam Register</x:Name>
                    <x:WorksheetOptions>
                        <x:DisplayGridlines/>
                        <x:Print>
                            <x:ValidPrinterInfo/>
                            <x:PaperSizeIndex>9</x:PaperSizeIndex>
                            <x:HorizontalResolution>600</x:HorizontalResolution>
                            <x:VerticalResolution>600</x:VerticalResolution>
                        </x:Print>
                        <x:Selected/>
                        <x:FreezePanes/>
                        <x:FrozenNoSplit/>
                        <x:SplitHorizontal>2</x:SplitHorizontal>
                        <x:TopRowBottomPane>2</x:TopRowBottomPane>
                        <x:ActivePane>2</x:ActivePane>
                        <x:Panes>
                            <x:Pane>
                                <x:Number>3</x:Number>
                            </x:Pane>
                            <x:Pane>
                                <x:Number>2</x:Number>
                                <x:ActiveRow>0</x:ActiveRow>
                            </x:Pane>
                        </x:Panes>
                    </x:WorksheetOptions>
                </x:ExcelWorksheet>
            </x:ExcelWorksheets>
        </x:ExcelWorkbook>
    </xml>
    <![endif]-->
    <style>
        @page {
            mso-page-orientation: landscape;
            margin: 0.5in 0.25in 0.5in 0.25in;
        }
        
        body {
            font-family: Calibri, Arial, sans-serif;
            font-size: 11pt;
            color: #000000;
        }
        
        .report-header {
            text-align: center;
            margin-bottom: 15px;
        }
        
        .university-title {
            font-size: 16pt;
            font-weight: bold;
            color: #09294d;
            margin-bottom: 5px;
        }
        
        .report-title {
            font-size: 14pt;
            font-weight: bold;
            color: #1a3d6d;
            margin-bottom: 10px;
        }
        
        .report-subtitle {
            font-size: 11pt;
            color: #666666;
            margin-bottom: 15px;
        }
        
        .info-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
            font-size: 10pt;
        }
        
        .info-table td {
            padding: 4px 8px;
            border: none;
        }
        
        .info-label {
            font-weight: bold;
            color: #1a3d6d;
            width: 120px;
        }
        
        .info-value {
            color: #000000;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 10pt;
        }
        
        .data-table th {
            background-color: #09294d;
            color: #ffffff;
            font-weight: bold;
            padding: 8px;
            text-align: left;
            border: 1px solid #cccccc;
            white-space: nowrap;
        }
        
        .data-table td {
            padding: 6px 8px;
            border: 1px solid #cccccc;
            vertical-align: middle;
        }
        
        .data-table tr:nth-child(even) {
            background-color: #f8fafc;
        }
        
        .data-table tr:hover {
            background-color: #ebf5ff;
        }
        
        .status-completed {
            color: #059669;
            font-weight: bold;
        }
        
        .status-inprogress {
            color: #d97706;
            font-weight: bold;
        }
        
        .summary-row {
            background-color: #e2e8f0 !important;
            font-weight: bold;
            border-top: 2px solid #09294d;
        }
        
        .total-cell {
            background-color: #1a3d6d;
            color: white;
            text-align: center;
        }
        
        .footer {
            margin-top: 20px;
            font-size: 9pt;
            color: #666666;
            text-align: center;
        }
        
        .section-divider {
            height: 1px;
            background-color: #cccccc;
            margin: 10px 0;
        }
        
        .text-center {
            text-align: center;
        }
        
        .text-right {
            text-align: right;
        }
        
        .highlight {
            background-color: #fffacd;
        }
        
        .percentage {
            font-weight: bold;
            color: #09294d;
        }
        
        .timestamp {
            font-size: 9pt;
            color: #999999;
            font-style: italic;
        }
    </style>
</head>
<body>
    <!-- Report Header -->
    <div class="report-header">
        <div class="university-title">PROFESSIONAL TESTING</div>
        <div class="report-title">EXAM ATTENDANCE REGISTER</div>
        <div class="report-subtitle">CodeSA Institute Pty Ltd</div>
    </div>
    
    <!-- Report Information -->
    <table class="info-table">
        <tr>
            <td class="info-label">Report Generated:</td>
            <td class="info-value">
                <%= new SimpleDateFormat("dd MMMM yyyy 'at' HH:mm:ss").format(new Date()) %>
            </td>
            <td class="info-label">Generated By:</td>
            <td class="info-value">User ID: <%= session.getAttribute("userId") %></td>
        </tr>
        <tr>
            <td class="info-label">Report Type:</td>
            <td class="info-value">
                <% 
                    if (examId > 0) {
                        out.print("Specific Exam Analysis");
                    } else if (studentId > 0) {
                        out.print("Student Analysis");
                    } else if (!courseName.isEmpty()) {
                        out.print("Course Analysis");
                    } else if (!examDate.isEmpty()) {
                        out.print("Date Analysis");
                    } else {
                        out.print("Comprehensive Report");
                    }
                %>
            </td>
            <td class="info-label">Filters Applied:</td>
            <td class="info-value">
                <% 
                    boolean hasFilters = false;
                    if (examId > 0) { 
                        out.print("Exam ID: " + examId + "<br>");
                        hasFilters = true;
                    }
                    if (studentId > 0) { 
                        out.print("Student ID: " + studentId + "<br>");
                        hasFilters = true;
                    }
                    if (!firstName.isEmpty()) { 
                        out.print("First Name: " + firstName + "<br>");
                        hasFilters = true;
                    }
                    if (!lastName.isEmpty()) { 
                        out.print("Last Name: " + lastName + "<br>");
                        hasFilters = true;
                    }
                    if (!courseName.isEmpty()) { 
                        out.print("Course: " + courseName + "<br>");
                        hasFilters = true;
                    }
                    if (!examDate.isEmpty()) { 
                        out.print("Date: " + examDate);
                        hasFilters = true;
                    }
                    if (!hasFilters) {
                        out.print("All Records");
                    }
                %>
            </td>
        </tr>
    </table>
    
    <div class="section-divider"></div>
    
    <!-- Data Table -->
    <table class="data-table">
        <thead>
            <tr>
                <th width="30">#</th>
                <th width="150">Student Name</th>
                <th width="80">Student ID</th>
                <th width="120">Course</th>
                <th width="60">Exam ID</th>
                <th width="80">Exam Date</th>
                <th width="70">Start Time</th>
                <th width="70">End Time</th>
                <th width="80">Duration</th>
                <th width="120">Device Identifier</th>
                <th width="80">Status</th>
                <th width="120">Email</th>
                <th width="100">Department</th>
            </tr>
        </thead>
        <tbody>
        <%
            try {
                ResultSet rs = null;
                
                // Check if any filters are applied
                hasFilters = examId > 0 || studentId > 0 || 
                                   !firstName.isEmpty() || !lastName.isEmpty() || 
                                   !courseName.isEmpty() || !examDate.isEmpty();
                
                if (hasFilters) {
                    // Call the method with all parameters
                    rs = pDAO.getFilteredExamRegister(examId, studentId, firstName, lastName, courseName, examDate);
                } else {
                    rs = pDAO.getAllExamRegister();
                }
                
                int count = 0;
                int completedCount = 0;
                int inProgressCount = 0;
                int totalDuration = 0;
                
                if (rs != null) {
                    while (rs.next()) {
                        count++;
                        String rsFirstName = rs.getString("first_name");
                        String rsLastName = rs.getString("last_name");
                        int rsStudentId = rs.getInt("student_id");
                        String course = rs.getString("course_name");
                        int currentExamId = rs.getInt("exam_id");
                        Date examDateObj = rs.getDate("exam_date");
                        Time startTime = rs.getTime("start_time");
                        Time endTime = rs.getTime("end_time");
                        String deviceIdentifier = rs.getString("device_identifier");
                        int durationSeconds = rs.getInt("duration_seconds");
                        String email = rs.getString("email");
                        String department = rs.getString("department");
                        
                        String studentName = (rsFirstName != null ? rsFirstName.trim() : "") + " " + 
                                           (rsLastName != null ? rsLastName.trim() : "");
                        
                        String duration = "";
                        if (durationSeconds > 0) {
                            totalDuration += durationSeconds;
                            int hours = durationSeconds / 3600;
                            int minutes = (durationSeconds % 3600) / 60;
                            duration = String.format("%d:%02d", hours, minutes);
                        }
                        
                        String status = "In Progress";
                        String statusClass = "status-inprogress";
                        if (endTime != null) {
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
                        if (startTime != null) {
                            formattedStartTime = startTime.toString().substring(0, 5);
                        }
                        
                        String formattedEndTime = "N/A";
                        if (endTime != null) {
                            formattedEndTime = endTime.toString().substring(0, 5);
                        }
        %>
        <tr>
            <td class="text-center"><%= count %></td>
            <td><%= studentName %></td>
            <td class="text-center"><%= rsStudentId %></td>
            <td><%= course %></td>
            <td class="text-center"><%= currentExamId %></td>
            <td class="text-center"><%= formattedDate %></td>
            <td class="text-center"><%= formattedStartTime %></td>
            <td class="text-center"><%= formattedEndTime %></td>
            <td class="text-center"><%= duration.isEmpty() ? "N/A" : duration %></td>
            <td>
                <% 
                    if (deviceIdentifier != null && deviceIdentifier.length() > 20) {
                        out.print(deviceIdentifier.substring(0, 20) + "...");
                    } else {
                        out.print(deviceIdentifier != null ? deviceIdentifier : "Unknown");
                    }
                %>
            </td>
            <td class="text-center <%= statusClass %>"><%= status %></td>
            <td><%= email != null ? email : "N/A" %></td>
            <td><%= department != null ? department : "N/A" %></td>
        </tr>
        <%
                    }
                }
                
                // Add summary statistics
                if (count > 0) {
                    double completionRate = (completedCount * 100.0) / count;
                    int avgDuration = count > 0 ? totalDuration / count : 0;
                    int avgHours = avgDuration / 3600;
                    int avgMinutes = (avgDuration % 3600) / 60;
                    
        %>
        <tr class="summary-row">
            <td colspan="2" class="total-cell">SUMMARY STATISTICS</td>
            <td class="text-center" colspan="2"><strong>Total Records:</strong> <%= count %></td>
            <td class="text-center" colspan="2"><strong>Completed:</strong> <%= completedCount %></td>
            <td class="text-center" colspan="2"><strong>In Progress:</strong> <%= inProgressCount %></td>
            <td class="text-center" colspan="2">
                <strong>Avg Duration:</strong> 
                <%= avgDuration > 0 ? String.format("%d:%02d", avgHours, avgMinutes) : "N/A" %>
            </td>
            <td class="text-center percentage" colspan="3">
                <strong>Completion Rate:</strong> <%= String.format("%.1f%%", completionRate) %>
            </td>
        </tr>
        <%
                }
                
            } catch (SQLException e) {
        %>
        <tr>
            <td colspan="13" style="color: #dc2626; text-align: center; padding: 20px;">
                <strong>ERROR GENERATING REPORT</strong><br>
                <%= e.getMessage() %>
            </td>
        </tr>
        <%
            }
        %>
        </tbody>
    </table>
    
    <div class="section-divider"></div>
    
    <!-- Footer -->
    <div class="footer">
        <div>This report was automatically generated by the Professional Testing System</div>
        <div>CodeSA Institute Pty Ltd | Professional Testing Platform</div>
        <div class="timestamp">
            Report ID: EXR<%= timestamp %> | 
            System Version: 2.1 | 
            Page generated in <%= System.currentTimeMillis() - new Date().getTime() %>ms
        </div>
        <div>© <%= new SimpleDateFormat("yyyy").format(new Date()) %> CodeSA Institute. All rights reserved.</div>
    </div>
</body>
</html>