<%@ page import="java.lang.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Authentication and authorization check
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String userType = (String) session.getAttribute("userType");
    if (userType == null) {
        int userId = Integer.parseInt(session.getAttribute("userId").toString());
        User user = myPackage.DatabaseClass.getInstance().getUserDetails(String.valueOf(userId));
        if (user != null) {
            userType = user.getType();
            session.setAttribute("userType", userType);
        }
    }
    
    if (!("admin".equals(userType) || "lecture".equals(userType))) {
        response.sendRedirect("std-page.jsp");
        return;
    }
    
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    
    // Get filter parameters
    String examIdParam = request.getParameter("exam_id");
    int examId = 0;
    if (examIdParam != null && !examIdParam.isEmpty()) {
        try {
            examId = Integer.parseInt(examIdParam);
        } catch (NumberFormatException e) {
            examId = 0;
        }
    }
    
    String courseNameFilter = request.getParameter("course_name");
    if (courseNameFilter == null) courseNameFilter = "";
    
    String dateFilter = request.getParameter("exam_date");
    if (dateFilter == null) dateFilter = "";
    
    List<String> allCourses = pDAO.getCourseList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Attendance Register | MUT</title>
    <link rel="stylesheet" href="CSS/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            /* Primary Colors */
            --primary-blue: #09294d;
            --secondary-blue: #1a3d6d;
            --accent-blue: #4a90e2;
            --light-blue: #ebf5ff;
            
            /* Neutral Colors */
            --white: #ffffff;
            --light-gray: #f8fafc;
            --medium-gray: #e2e8f0;
            --dark-gray: #64748b;
            --text-dark: #1e293b;
            
            /* Semantic Colors */
            --success: #059669;
            --success-light: #d1fae5;
            --warning: #d97706;
            --warning-light: #fef3c7;
            --error: #dc2626;
            --info: #0891b2;
            
            /* Spacing */
            --spacing-xs: 4px;
            --spacing-sm: 8px;
            --spacing-md: 16px;
            --spacing-lg: 24px;
            --spacing-xl: 32px;
            --spacing-2xl: 48px;
            
            /* Border Radius */
            --radius-sm: 4px;
            --radius-md: 8px;
            --radius-lg: 12px;
            --radius-xl: 16px;
            
            /* Shadows */
            --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
            --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
            
            /* Transitions */
            --transition-fast: 0.15s ease;
            --transition-normal: 0.2s ease;
            --transition-slow: 0.3s ease;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.5;
            color: var(--text-dark);
            background-color: var(--light-gray);
            font-size: 14px;
        }
        
        /* Main Layout */
        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }
        
        /* Main Content */
        .main-content {
            flex: 1;
            padding: var(--spacing-lg);
            overflow-y: auto;
        }
        
        /* Page Header */
        .page-header {
            margin-bottom: var(--spacing-xl);
        }
        
        .page-title-section {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: var(--spacing-md);
        }
        
        .page-title {
            font-size: 24px;
            font-weight: 600;
            color: var(--primary-blue);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        
        .page-title i {
            color: var(--accent-blue);
        }
        
        .page-subtitle {
            color: var(--dark-gray);
            font-size: 14px;
            margin-top: var(--spacing-xs);
        }
        
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--spacing-md);
            margin-bottom: var(--spacing-xl);
        }
        
        .stat-card {
            background: var(--white);
            border-radius: var(--radius-md);
            padding: var(--spacing-lg);
            display: flex;
            align-items: center;
            gap: var(--spacing-md);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--medium-gray);
            transition: transform var(--transition-normal), box-shadow var(--transition-normal);
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        
        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }
        
        .stat-icon.total {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .stat-icon.completed {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
        }
        
        .stat-icon.progress {
            background: linear-gradient(135deg, #ff9a9e 0%, #fad0c4 100%);
            color: white;
        }
        
        .stat-icon.duration {
            background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
            color: var(--text-dark);
        }
        
        .stat-content {
            flex: 1;
        }
        
        .stat-number {
            font-size: 24px;
            font-weight: 600;
            color: var(--text-dark);
            display: block;
            line-height: 1.2;
        }
        
        .stat-label {
            font-size: 12px;
            color: var(--dark-gray);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 500;
        }
        
        /* Filter Card */
        .filter-card {
            background: var(--white);
            border-radius: var(--radius-md);
            padding: var(--spacing-lg);
            margin-bottom: var(--spacing-xl);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--medium-gray);
        }
        
        .filter-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: var(--spacing-lg);
            padding-bottom: var(--spacing-md);
            border-bottom: 1px solid var(--light-gray);
        }
        
        .filter-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        
        .filter-title i {
            color: var(--accent-blue);
        }
        
        .filter-form {
            margin-top: var(--spacing-lg);
        }
        
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: var(--spacing-md);
            margin-bottom: var(--spacing-md);
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
            gap: var(--spacing-xs);
        }
        
        .form-group label {
            font-size: 13px;
            font-weight: 500;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: var(--spacing-xs);
        }
        
        .form-group label i {
            color: var(--dark-gray);
            font-size: 12px;
        }
        
        .form-control {
            padding: 10px 12px;
            border: 1px solid var(--medium-gray);
            border-radius: var(--radius-sm);
            font-size: 14px;
            transition: all var(--transition-fast);
            background: var(--white);
            color: var(--text-dark);
            width: 100%;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
        }
        
        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364748b' d='M2 4l4 4 4-4z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
            background-size: 12px;
            padding-right: 32px;
        }
        
        .filter-actions {
            display: flex;
            gap: var(--spacing-sm);
            margin-top: var(--spacing-lg);
            padding-top: var(--spacing-md);
            border-top: 1px solid var(--light-gray);
        }
        
        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: var(--spacing-sm);
            padding: 10px 20px;
            border-radius: var(--radius-sm);
            font-size: 13px;
            font-weight: 500;
            text-decoration: none;
            cursor: pointer;
            border: none;
            transition: all var(--transition-normal);
        }
        
        .btn-primary {
            background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
            color: var(--white);
        }
        
        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(9, 41, 77, 0.2);
        }
        
        .btn-outline {
            background: transparent;
            border: 1px solid var(--medium-gray);
            color: var(--dark-gray);
        }
        
        .btn-outline:hover {
            background: var(--light-gray);
            border-color: var(--dark-gray);
        }
        
        .btn-success {
            background: linear-gradient(90deg, var(--success), #10b981);
            color: var(--white);
        }
        
        /* Table Container */
        .table-container {
            background: var(--white);
            border-radius: var(--radius-md);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--medium-gray);
        }
        
        .table-header {
            padding: var(--spacing-lg);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--light-gray);
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .table-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        
        .table-title i {
            color: var(--accent-blue);
        }
        
        .table-stats {
            display: flex;
            gap: var(--spacing-sm);
        }
        
        /* Badges */
        .badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-weight: 500;
            font-size: 11px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            white-space: nowrap;
        }
        
        .badge-success {
            background: linear-gradient(90deg, var(--success), #10b981);
            color: var(--white);
        }
        
        .badge-warning {
            background: linear-gradient(90deg, var(--warning), #f59e0b);
            color: var(--white);
        }
        
        .badge-info {
            background: linear-gradient(90deg, var(--info), #0ea5e9);
            color: var(--white);
        }
        
        .badge-light {
            background: var(--light-gray);
            color: var(--text-dark);
            border: 1px solid var(--medium-gray);
        }
        
        /* Data Table */
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .data-table thead {
            background: var(--light-gray);
        }
        
        .data-table th {
            padding: 14px 16px;
            text-align: left;
            font-weight: 600;
            font-size: 12px;
            color: var(--text-dark);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid var(--medium-gray);
            white-space: nowrap;
        }
        
        .data-table th i {
            color: var(--dark-gray);
            margin-right: var(--spacing-xs);
            font-size: 11px;
        }
        
        .data-table td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--light-gray);
            vertical-align: middle;
            color: var(--text-dark);
            font-size: 13px;
        }
        
        .data-table tbody tr {
            transition: background-color var(--transition-fast);
        }
        
        .data-table tbody tr:hover {
            background-color: var(--light-gray);
        }
        
        .data-table tbody tr:last-child td {
            border-bottom: none;
        }
        
        .student-info {
            display: flex;
            flex-direction: column;
        }
        
        .student-name {
            font-weight: 500;
            color: var(--text-dark);
        }
        
        .student-email {
            font-size: 11px;
            color: var(--dark-gray);
            margin-top: 2px;
        }
        
        /* Status Indicators */
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        
        .status-completed {
            background: var(--success-light);
            color: var(--success);
        }
        
        .status-in-progress {
            background: var(--warning-light);
            color: var(--warning);
        }
        
        /* Device Info */
        .device-info {
            max-width: 150px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            color: var(--dark-gray);
        }
        
        /* Export Section */
        .export-section {
            padding: var(--spacing-lg);
            border-top: 1px solid var(--light-gray);
            background: var(--light-gray);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .export-buttons {
            display: flex;
            gap: var(--spacing-sm);
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: var(--spacing-2xl) var(--spacing-lg);
            color: var(--dark-gray);
        }
        
        .empty-state i {
            font-size: 48px;
            color: var(--medium-gray);
            margin-bottom: var(--spacing-md);
        }
        
        .empty-state h3 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: var(--spacing-sm);
            color: var(--text-dark);
        }
        
        .empty-state p {
            font-size: 14px;
            max-width: 400px;
            margin: 0 auto;
            line-height: 1.6;
        }
        
        /* Loading State */
        .loading {
            opacity: 0.7;
            pointer-events: none;
            position: relative;
        }
        
        .loading::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 20px;
            height: 20px;
            margin: -10px 0 0 -10px;
            border: 2px solid var(--light-gray);
            border-top: 2px solid var(--primary-blue);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* Responsive Design */
        @media (max-width: 1024px) {
            .main-content {
                padding: var(--spacing-md);
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-header {
                flex-direction: column;
                align-items: flex-start;
                gap: var(--spacing-sm);
            }
            
            .table-header {
                flex-direction: column;
                align-items: flex-start;
                gap: var(--spacing-md);
            }
            
            .table-stats {
                flex-wrap: wrap;
            }
            
            .export-section {
                flex-direction: column;
                gap: var(--spacing-md);
                align-items: stretch;
            }
            
            .export-buttons {
                flex-direction: column;
            }
            
            .data-table {
                display: block;
                overflow-x: auto;
            }
        }
        
        @media (max-width: 480px) {
            .main-content {
                padding: var(--spacing-sm);
            }
            
            .page-title {
                font-size: 20px;
            }
            
            .stat-card {
                padding: var(--spacing-md);
            }
            
            .stat-number {
                font-size: 20px;
            }
            
            .data-table th,
            .data-table td {
                padding: 10px 12px;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Include Sidebar -->
        <jsp:include page="adm-page.jsp?pgprt=7" />
        
        <div class="main-content">
            <!-- Page Header -->
            <div class="page-header">
                <div class="page-title-section">
                    <div>
                        <h1 class="page-title">
                            <i class="fas fa-clipboard-list"></i> Exam Attendance Register
                        </h1>
                        <p class="page-subtitle">
                            Monitor and track student exam attendance and progress
                        </p>
                    </div>
                </div>
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
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon total">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-content">
                        <span class="stat-number"><%= totalStudents %></span>
                        <span class="stat-label">Total Students</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon completed">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-content">
                        <span class="stat-number"><%= completed %></span>
                        <span class="stat-label">Completed Exams</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon progress">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-content">
                        <span class="stat-number"><%= inProgress %></span>
                        <span class="stat-label">In Progress</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon duration">
                        <i class="fas fa-hourglass-half"></i>
                    </div>
                    <div class="stat-content">
                        <span class="stat-number">
                            <% 
                                if (avgDuration > 0) {
                                    int hours = avgDuration / 3600;
                                    int minutes = (avgDuration % 3600) / 60;
                                    out.print(String.format("%d:%02d", hours, minutes));
                                } else {
                                    out.print("0:00");
                                }
                            %>
                        </span>
                        <span class="stat-label">Avg Duration (H:MM)</span>
                    </div>
                </div>
            </div>
            <%      }
                } catch (Exception e) {
                    // Ignore stats error
                }
            } %>
            
            <!-- Filter Card -->
            <div class="filter-card">
                <div class="filter-header">
                    <h3 class="filter-title">
                        <i class="fas fa-filter"></i> Filter Results
                    </h3>
                </div>
                
                <form method="GET" action="exam-register.jsp" class="filter-form">
                    <div class="filter-grid">
                        <div class="form-group">
                            <label for="exam_id">
                                <i class="fas fa-file-alt"></i> Exam ID
                            </label>
                            <input type="number" id="exam_id" name="exam_id" 
                                   value="<%= examId %>" placeholder="Enter Exam ID" 
                                   class="form-control" min="1">
                        </div>
                        
                        <div class="form-group">
                            <label for="course_name">
                                <i class="fas fa-book"></i> Course
                            </label>
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
                            <label for="exam_date">
                                <i class="fas fa-calendar"></i> Exam Date
                            </label>
                            <input type="date" id="exam_date" name="exam_date" 
                                   value="<%= dateFilter %>" class="form-control">
                        </div>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-search"></i> Apply Filters
                        </button>
                        <button type="button" onclick="clearFilters()" class="btn btn-outline">
                            <i class="fas fa-times"></i> Clear Filters
                        </button>
                        <% if (examId > 0 || !courseNameFilter.isEmpty() || !dateFilter.isEmpty()) { %>
                        <a href="export-register.jsp?course_name=<%= java.net.URLEncoder.encode(courseNameFilter, "UTF-8") %>&exam_date=<%= dateFilter %>&exam_id=<%= examId %>" 
                           class="btn btn-success">
                            <i class="fas fa-file-export"></i> Export Results
                        </a>
                        <% } %>
                    </div>
                </form>
            </div>
            
            <!-- Register Table -->
            <div class="table-container">
                <% 
                    try {
                        ResultSet rs = null;
                        int totalCount = 0;
                        int completedCount = 0;
                        int inProgressCount = 0;
                        
                        if (examId > 0 || !courseNameFilter.isEmpty() || !dateFilter.isEmpty()) {
                            rs = pDAO.getFilteredExamRegister(examId, courseNameFilter, dateFilter);
                            
                            if (rs != null) {
                                rs.last();
                                totalCount = rs.getRow();
                                rs.beforeFirst();
                                
                                // Count statuses
                                while (rs.next()) {
                                    Time endTime = rs.getTime("end_time");
                                    if (endTime != null) {
                                        completedCount++;
                                    } else {
                                        inProgressCount++;
                                    }
                                }
                                rs.beforeFirst();
                            }
                        }
                        
                        if (rs != null && rs.next()) {
                %>
                <div class="table-header">
                    <h3 class="table-title">
                        <i class="fas fa-list-alt"></i> Exam Register Details
                    </h3>
                    <div class="table-stats">
                        <span class="badge badge-light">Total: <%= totalCount %></span>
                        <span class="badge badge-success">Completed: <%= completedCount %></span>
                        <span class="badge badge-warning">In Progress: <%= inProgressCount %></span>
                    </div>
                </div>
                
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th><i class="fas fa-hashtag"></i> #</th>
                                <th><i class="fas fa-user"></i> Student</th>
                                <th><i class="fas fa-id-card"></i> Student ID</th>
                                <th><i class="fas fa-book"></i> Course</th>
                                <th><i class="fas fa-hashtag"></i> Exam ID</th>
                                <th><i class="fas fa-calendar"></i> Date</th>
                                <th><i class="fas fa-clock"></i> Start Time</th>
                                <th><i class="fas fa-clock"></i> End Time</th>
                                <th><i class="fas fa-hourglass"></i> Duration</th>
                                <th><i class="fas fa-desktop"></i> Device</th>
                                <th><i class="fas fa-info-circle"></i> Status</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% 
                            int count = 0;
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
                                String email = rs.getString("email");
                                
                                String studentName = (firstName != null ? firstName : "") + " " + 
                                                   (lastName != null ? lastName : "");
                                String duration = "";
                                if (durationSeconds > 0) {
                                    int hours = durationSeconds / 3600;
                                    int minutes = (durationSeconds % 3600) / 60;
                                    duration = String.format("%d:%02d", hours, minutes);
                                }
                                
                                String status = "In Progress";
                                String statusClass = "status-in-progress";
                                if (endTime != null) {
                                    status = "Completed";
                                    statusClass = "status-completed";
                                }
                        %>
                            <tr>
                                <td><%= count %></td>
                                <td>
                                    <div class="student-info">
                                        <span class="student-name"><%= studentName %></span>
                                        <span class="student-email"><%= email %></span>
                                    </div>
                                </td>
                                <td><strong><%= studentId %></strong></td>
                                <td><%= courseName %></td>
                                <td><span class="badge badge-info"><%= currentExamId %></span></td>
                                <td><%= examDate != null ? examDate.toString() : "N/A" %></td>
                                <td><%= startTime != null ? startTime.toString().substring(0, 5) : "N/A" %></td>
                                <td><%= endTime != null ? endTime.toString().substring(0, 5) : "N/A" %></td>
                                <td><%= duration.isEmpty() ? "N/A" : duration %></td>
                                <td>
                                    <span class="device-info" title="<%= deviceIdentifier != null ? deviceIdentifier : "Unknown" %>">
                                        <%= deviceIdentifier != null && deviceIdentifier.length() > 20 ? 
                                            deviceIdentifier.substring(0, 20) + "..." : 
                                            (deviceIdentifier != null ? deviceIdentifier : "Unknown") %>
                                    </span>
                                </td>
                                <td>
                                    <span class="status-badge <%= statusClass %>">
                                        <i class="fas <%= endTime != null ? "fa-check-circle" : "fa-clock" %>"></i>
                                        <%= status %>
                                    </span>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div class="export-section">
                    <div class="export-info">
                        <small class="text-muted">
                            Showing <%= totalCount %> record(s) 
                            <% if (examId > 0) { %>for Exam ID: <%= examId %><% } %>
                            <% if (!courseNameFilter.isEmpty()) { %>in <%= courseNameFilter %><% } %>
                        </small>
                    </div>
                    <div class="export-buttons">
                        <% if (examId > 0) { %>
                        <a href="export-register.jsp?exam_id=<%= examId %>" class="btn btn-outline">
                            <i class="fas fa-file-excel"></i> Export This Exam
                        </a>
                        <% } %>
                        <a href="export-register.jsp?course_name=<%= java.net.URLEncoder.encode(courseNameFilter, "UTF-8") %>&exam_date=<%= dateFilter %>&exam_id=<%= examId %>" 
                           class="btn btn-outline">
                            <i class="fas fa-download"></i> Export All Results
                        </a>
                    </div>
                </div>
                
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-clipboard-question"></i>
                        <h3>No Exam Register Found</h3>
                        <p>
                            <% if (examId > 0) { %>
                                No exam register entries found for Exam ID: <strong><%= examId %></strong>
                            <% } else if (!courseNameFilter.isEmpty()) { %>
                                No exam register entries found for Course: <strong><%= courseNameFilter %></strong>
                            <% } else if (!dateFilter.isEmpty()) { %>
                                No exam register entries found for Date: <strong><%= dateFilter %></strong>
                            <% } else { %>
                                Use the filters above to view exam register entries. Enter an Exam ID, select a course, or choose a date.
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
                        <p class="text-muted"><small>Technical details: <%= e.getMessage() %></small></p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <script>
        // Clear filters function
        function clearFilters() {
            window.location.href = 'exam-register.jsp';
        }
        
        // Auto-submit when exam ID changes
        document.getElementById('exam_id')?.addEventListener('change', function() {
            if (this.value.trim() !== '') {
                this.form.submit();
            }
        });
        
        // Format dates and times on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Format dates
            const dateCells = document.querySelectorAll('.data-table td:nth-child(6)');
            dateCells.forEach(cell => {
                if (cell.textContent !== 'N/A') {
                    try {
                        const [year, month, day] = cell.textContent.split('-');
                        cell.textContent = `${day}/${month}/${year}`;
                    } catch (e) {
                        // Keep original format
                    }
                }
            });
            
            // Format times
            const timeCells = document.querySelectorAll('.data-table td:nth-child(7), .data-table td:nth-child(8)');
            timeCells.forEach(cell => {
                if (cell.textContent !== 'N/A') {
                    try {
                        const time = cell.textContent;
                        if (time.includes(':')) {
                            const [hours, minutes] = time.split(':');
                            const ampm = hours >= 12 ? 'PM' : 'AM';
                            const hour12 = hours % 12 || 12;
                            cell.textContent = `${hour12}:${minutes} ${ampm}`;
                        }
                    } catch (e) {
                        // Keep original format
                    }
                }
            });
        });
        
        // Add row highlighting on hover
        document.querySelectorAll('.data-table tbody tr').forEach(row => {
            row.addEventListener('mouseenter', function() {
                this.style.backgroundColor = '#f8fafc';
            });
            row.addEventListener('mouseleave', function() {
                this.style.backgroundColor = '';
            });
        });
    </script>
</body>
</html>