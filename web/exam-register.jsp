<%@ page import="java.lang.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.User" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Check if user is admin/lecturer
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get user type
    String userType = (String) session.getAttribute("userType");
    if (userType == null) {
        // Try to get user details
        int userId = Integer.parseInt(session.getAttribute("userId").toString());
        User user = myPackage.DatabaseClass.getInstance().getUserDetails(String.valueOf(userId));
        if (user != null) {
            userType = user.getType();
            session.setAttribute("userType", userType);
        }
    }
    
    // Only allow admin and lecturers
    if (!("admin".equals(userType) || "lecture".equals(userType))) {
        response.sendRedirect("std-page.jsp");
        return;
    }
    
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    
    // Get exam ID parameter
    String examIdParam = request.getParameter("exam_id");
    int examId = 0;
    if (examIdParam != null && !examIdParam.isEmpty()) {
        try {
            examId = Integer.parseInt(examIdParam);
        } catch (NumberFormatException e) {
            examId = 0;
        }
    }
    
    // Get course name parameter for filtering
    String courseNameFilter = request.getParameter("course_name");
    if (courseNameFilter == null) courseNameFilter = "";
    
    // Get date filter
    String dateFilter = request.getParameter("exam_date");
    if (dateFilter == null) dateFilter = "";
    
    // Get all courses for filter dropdown
    ArrayList<String> allCourses = pDAO.getCourseList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Register</title>
    <link rel="stylesheet" href="CSS/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Additional styles for exam register */
        .filter-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .filter-form .form-row {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: flex-end;
        }
        
        .filter-form .form-group {
            flex: 1;
            min-width: 200px;
        }
        
        .filter-form .form-group:last-child {
            flex: 0 0 auto;
        }
        
        .data-table-container {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .table-header {
            padding: 20px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .table-info {
            display: flex;
            gap: 10px;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .data-table th {
            background: #f8fafc;
            padding: 12px 15px;
            text-align: left;
            font-weight: 600;
            color: #475569;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .data-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #e2e8f0;
        }
        
        .data-table tr:hover {
            background: #f1f5f9;
        }
        
        .device-info {
            font-family: monospace;
            background: #f1f5f9;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.85em;
            max-width: 150px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            display: inline-block;
        }
        
        .badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: 500;
        }
        
        .badge-success {
            background: #d1fae5;
            color: #065f46;
        }
        
        .badge-warning {
            background: #fef3c7;
            color: #92400e;
        }
        
        .badge-danger {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #64748b;
        }
        
        .empty-state i {
            margin-bottom: 20px;
            color: #cbd5e1;
            font-size: 48px;
        }
        
        .empty-state h3 {
            margin-bottom: 10px;
            color: #475569;
        }
        
        .export-buttons {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        
        .summary-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: white;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .stat-card i {
            font-size: 24px;
            margin-bottom: 10px;
            color: #3b82f6;
        }
        
        .stat-number {
            font-size: 24px;
            font-weight: bold;
            color: #1e293b;
            display: block;
        }
        
        .stat-label {
            color: #64748b;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Include your header/sidebar -->
        <jsp:include page="adm-header.jsp" />
        
        <div class="main-content">
            <div class="page-header">
                <div class="page-title">
                    <i class="fas fa-clipboard-list"></i> Exam Register
                </div>
                <div class="stats-badge">
                    <i class="fas fa-users"></i> Attendance Register
                </div>
            </div>
            
            <!-- Filter Form -->
            <div class="filter-card">
                <form method="GET" action="exam-register.jsp" class="filter-form">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="exam_id"><i class="fas fa-file-alt"></i> Exam ID</label>
                            <input type="number" id="exam_id" name="exam_id" 
                                   value="<%= examId %>" placeholder="Enter Exam ID" 
                                   class="form-control" min="1">
                        </div>
                        
                        <div class="form-group">
                            <label for="course_name"><i class="fas fa-book"></i> Course</label>
                            <select id="course_name" name="course_name" class="form-control">
                                <option value="">All Courses</option>
                                <% if (allCourses != null) {
                                    for (String course : allCourses) {
                                        if (course != null && !course.trim().isEmpty()) {
                                            String selected = course.equals(courseNameFilter) ? "selected" : "";
                                %>
                                <option value="<%= course %>" <%= selected %>><%= course %></option>
                                <%      }
                                    }
                                } %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="exam_date"><i class="fas fa-calendar"></i> Exam Date</label>
                            <input type="date" id="exam_date" name="exam_date" 
                                   value="<%= dateFilter %>" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <button type="submit" class="btn-primary">
                                <i class="fas fa-search"></i> Filter
                            </button>
                            <button type="button" onclick="clearFilters()" class="btn-outline">
                                <i class="fas fa-times"></i> Clear
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            
            <!-- Summary Statistics -->
            <% 
                if (examId > 0 || !courseNameFilter.isEmpty() || !dateFilter.isEmpty()) {
                    try {
                        ResultSet statsRs = pDAO.getExamRegisterStatistics(examId, courseNameFilter, dateFilter);
                        if (statsRs != null && statsRs.next()) {
                            int totalStudents = statsRs.getInt("total_students");
                            int completed = statsRs.getInt("completed");
                            int inProgress = statsRs.getInt("in_progress");
                            int avgDuration = statsRs.getInt("avg_duration");
            %>
            <div class="summary-stats">
                <div class="stat-card">
                    <i class="fas fa-users"></i>
                    <span class="stat-number"><%= totalStudents %></span>
                    <span class="stat-label">Total Students</span>
                </div>
                <div class="stat-card">
                    <i class="fas fa-check-circle"></i>
                    <span class="stat-number"><%= completed %></span>
                    <span class="stat-label">Completed Exams</span>
                </div>
                <div class="stat-card">
                    <i class="fas fa-clock"></i>
                    <span class="stat-number"><%= inProgress %></span>
                    <span class="stat-label">In Progress</span>
                </div>
                <div class="stat-card">
                    <i class="fas fa-hourglass-half"></i>
                    <span class="stat-number">
                        <% 
                            if (avgDuration > 0) {
                                int hours = avgDuration / 3600;
                                int minutes = (avgDuration % 3600) / 60;
                                out.print(String.format("%02d:%02d", hours, minutes));
                            } else {
                                out.print("N/A");
                            }
                        %>
                    </span>
                    <span class="stat-label">Avg Duration</span>
                </div>
            </div>
            <%      }
                } catch (Exception e) {
                    // Ignore stats error
                }
            } %>
            
            <!-- Register Table -->
            <div class="data-table-container">
                <% 
                    try {
                        ResultSet rs = null;
                        int totalCount = 0;
                        
                        if (examId > 0 || !courseNameFilter.isEmpty() || !dateFilter.isEmpty()) {
                            rs = pDAO.getFilteredExamRegister(examId, courseNameFilter, dateFilter);
                            
                            if (rs != null) {
                                // Get count
                                rs.last();
                                totalCount = rs.getRow();
                                rs.beforeFirst();
                            }
                        }
                        
                        if (rs != null && rs.next()) {
                %>
                <div class="table-header">
                    <h3><i class="fas fa-list-alt"></i> Exam Register</h3>
                    <div class="table-info">
                        <span class="badge-success">Total Records: <%= totalCount %></span>
                        <span class="badge" id="completedCount">Completed: 0</span>
                        <span class="badge" id="inProgressCount">In Progress: 0</span>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th><i class="fas fa-user"></i> Student</th>
                                <th><i class="fas fa-id-card"></i> Student ID</th>
                                <th><i class="fas fa-book"></i> Course</th>
                                <th><i class="fas fa-hashtag"></i> Exam ID</th>
                                <th><i class="fas fa-calendar"></i> Exam Date</th>
                                <th><i class="fas fa-clock"></i> Start Time</th>
                                <th><i class="fas fa-clock"></i> End Time</th>
                                <th><i class="fas fa-hourglass"></i> Duration</th>
                                <th><i class="fas fa-desktop"></i> Device</th>
                                <th><i class="fas fa-info-circle"></i> Status</th>
                            </tr>
                        </thead>
                        <tbody id="registerTableBody">
                        <% 
                            int count = 0;
                            int completedCount = 0;
                            int inProgressCount = 0;
                            
                            rs.beforeFirst();
                            while (rs.next()) {
                                count++;
                                String firstName = rs.getString("first_name");
                                String lastName = rs.getString("last_name");
                                int studentId = rs.getInt("student_id");
                                String courseName = rs.getString("course_name");
                                int currentExamId = rs.getInt("exam_id");
                                Date examDate = rs.getDate("exam_date");
                                Time startTime = rs.getTime("start_time");
                                Time endTime = rs.getTime("end_time");
                                String deviceIdentifier = rs.getString("device_identifier");
                                int durationSeconds = rs.getInt("duration_seconds");
                                
                                String studentName = (firstName != null ? firstName : "") + " " + 
                                                   (lastName != null ? lastName : "");
                                String duration = "";
                                if (durationSeconds > 0) {
                                    int hours = durationSeconds / 3600;
                                    int minutes = (durationSeconds % 3600) / 60;
                                    int seconds = durationSeconds % 60;
                                    duration = String.format("%02d:%02d:%02d", hours, minutes, seconds);
                                }
                                
                                String status = "In Progress";
                                String statusClass = "badge-warning";
                                if (endTime != null) {
                                    status = "Completed";
                                    statusClass = "badge-success";
                                    completedCount++;
                                } else {
                                    inProgressCount++;
                                }
                        %>
                            <tr>
                                <td><%= count %></td>
                                <td>
                                    <strong><%= studentName %></strong><br>
                                    <small class="text-muted"><%= rs.getString("email") %></small>
                                </td>
                                <td><%= studentId %></td>
                                <td><%= courseName %></td>
                                <td><%= currentExamId %></td>
                                <td><%= examDate != null ? examDate.toString() : "N/A" %></td>
                                <td><%= startTime != null ? startTime.toString() : "N/A" %></td>
                                <td><%= endTime != null ? endTime.toString() : "N/A" %></td>
                                <td><%= duration.isEmpty() ? "N/A" : duration %></td>
                                <td>
                                    <span class="device-info" title="<%= deviceIdentifier != null ? deviceIdentifier : "Unknown" %>">
                                        <%= deviceIdentifier != null ? 
                                            deviceIdentifier.substring(0, Math.min(20, deviceIdentifier.length())) : 
                                            "Unknown" %>
                                    </span>
                                </td>
                                <td><span class="badge <%= statusClass %>"><%= status %></span></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div class="export-buttons" style="padding: 20px; text-align: center;">
                    <% if (examId > 0) { %>
                    <a href="export-register.jsp?exam_id=<%= examId %>" class="btn-outline">
                        <i class="fas fa-file-excel"></i> Export to Excel
                    </a>
                    <% } %>
                    <a href="export-register.jsp?course_name=<%= java.net.URLEncoder.encode(courseNameFilter, "UTF-8") %>&exam_date=<%= dateFilter %>" 
                       class="btn-outline">
                        <i class="fas fa-download"></i> Export All Filtered
                    </a>
                </div>
                
                <script>
                    // Update counters
                    document.getElementById('completedCount').textContent = 'Completed: <%= completedCount %>';
                    document.getElementById('inProgressCount').textContent = 'In Progress: <%= inProgressCount %>';
                    
                    // Function to clear filters
                    function clearFilters() {
                        window.location.href = 'exam-register.jsp';
                    }
                </script>
                
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-clipboard-question"></i>
                        <h3>No Exam Register Found</h3>
                        <p>
                            <% if (examId > 0) { %>
                                No exam register entries found for Exam ID: <%= examId %>
                            <% } else if (!courseNameFilter.isEmpty()) { %>
                                No exam register entries found for Course: <%= courseNameFilter %>
                            <% } else if (!dateFilter.isEmpty()) { %>
                                No exam register entries found for Date: <%= dateFilter %>
                            <% } else { %>
                                Use the filters above to view exam register entries
                            <% } %>
                        </p>
                    </div>
                <% }
                    
                    } catch (SQLException e) {
                        e.printStackTrace();
                %>
                    <div class="empty-state">
                        <i class="fas fa-exclamation-triangle"></i>
                        <h3>Error Loading Exam Register</h3>
                        <p>An error occurred while loading the exam register. Please try again.</p>
                        <p class="text-muted"><%= e.getMessage() %></p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <script>
        // Function to clear filters
        function clearFilters() {
            window.location.href = 'exam-register.jsp';
        }
        
        // Auto-submit form when exam ID changes (for better UX)
        document.getElementById('exam_id')?.addEventListener('change', function() {
            if (this.value.trim() !== '') {
                this.form.submit();
            }
        });
        
        // Format dates in local timezone
        document.addEventListener('DOMContentLoaded', function() {
            // Format date cells
            const dateCells = document.querySelectorAll('td:nth-child(6)');
            dateCells.forEach(cell => {
                if (cell.textContent !== 'N/A') {
                    try {
                        const date = new Date(cell.textContent + 'T00:00:00');
                        cell.textContent = date.toLocaleDateString();
                    } catch (e) {
                        // Keep original format if parsing fails
                    }
                }
            });
            
            // Format time cells
            const timeCells = document.querySelectorAll('td:nth-child(7), td:nth-child(8)');
            timeCells.forEach(cell => {
                if (cell.textContent !== 'N/A') {
                    try {
                        const timeParts = cell.textContent.split(':');
                        if (timeParts.length >= 2) {
                            const date = new Date();
                            date.setHours(timeParts[0]);
                            date.setMinutes(timeParts[1]);
                            date.setSeconds(timeParts[2] || 0);
                            cell.textContent = date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                        }
                    } catch (e) {
                        // Keep original format if parsing fails
                    }
                }
            });
        });
    </script>
</body>
</html>