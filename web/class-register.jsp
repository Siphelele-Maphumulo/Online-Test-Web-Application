<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
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
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // Filter parameters for class register
    String classNameFilter = request.getParameter("class_name");
    if (classNameFilter == null) classNameFilter = "";

    String courseFilter = request.getParameter("course_name");
    if (courseFilter == null) courseFilter = "";

    String dateFilter = request.getParameter("attendance_date");
    if (dateFilter == null || dateFilter.trim().isEmpty()) {
        // Set today's date as default
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
        dateFilter = sdf.format(new java.util.Date());
    }

    String firstNameFilter = request.getParameter("first_name");
    if (firstNameFilter == null) firstNameFilter = "";

    String lastNameFilter = request.getParameter("last_name");
    if (lastNameFilter == null) lastNameFilter = "";

    // Get all students (for dropdown or reference)
    List<String> allClasses = new ArrayList<>();
    List<String> allCourses = new ArrayList<>();
    
    try {
        // Get distinct classes from users table (students)
        String classesQuery = "SELECT DISTINCT class_name FROM users WHERE user_type = 'student' AND class_name IS NOT NULL AND class_name != '' ORDER BY class_name";
        pstmt = pDAO.getPreparedStatement(classesQuery);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            String className = rs.getString("class_name");
            allClasses.add(className);
        }
        rs.close();
        pstmt.close();
        
        // Get distinct courses from questions table
        String coursesQuery = "SELECT DISTINCT course_name FROM questions WHERE course_name IS NOT NULL AND course_name != '' ORDER BY course_name";
        pstmt = pDAO.getPreparedStatement(coursesQuery);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            String courseName = rs.getString("course_name");
            allCourses.add(courseName);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        // Add default values if query fails
        allClasses.add("Computer Science");
        allClasses.add("Mathematics");
        allClasses.add("Physics");
        allClasses.add("Engineering");
        
        allCourses.add("Computer Science 101");
        allCourses.add("Mathematics 201");
        allCourses.add("Physics 301");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Register</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
    /* Use the same CSS Variables as the profile page */
    :root {
        /* Primary Colors */
        --primary-blue: #09294d;
        --secondary-blue: #1a3d6d;
        --accent-blue: #4a90e2;
        
        /* Neutral Colors */
        --white: #ffffff;
        --light-gray: #f8fafc;
        --medium-gray: #e2e8f0;
        --dark-gray: #64748b;
        --text-dark: #1e293b;
        
        /* Semantic Colors */
        --success: #059669;
        --warning: #d97706;
        --error: #dc2626;
        --info: #0891b2;
        
        /* Spacing */
        --spacing-xs: 4px;
        --spacing-sm: 8px;
        --spacing-md: 16px;
        --spacing-lg: 24px;
        --spacing-xl: 32px;
        
        /* Border Radius */
        --radius-sm: 4px;
        --radius-md: 8px;
        --radius-lg: 16px;
        
        /* Shadows */
        --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);
        --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
        --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
        
        /* Transitions */
        --transition-fast: 0.15s ease;
        --transition-normal: 0.2s ease;
        --transition-slow: 0.3s ease;
    }
    
    /* Reset and Base Styles - Same as profile page */
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
    }
    
    /* Layout Structure */
    .dashboard-container {
        display: flex;
        min-height: 100vh;
    }
    
    /* Sidebar Styles - Same as profile page */
    .sidebar {
        width: 200px;
        background: linear-gradient(180deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        flex-shrink: 0;
        position: sticky;
        top: 0;
        height: 100vh;
    }
    
    .sidebar-header {
        padding: var(--spacing-xl) var(--spacing-lg);
        text-align: center;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .mut-logo {
        max-height: 150px;
        width: auto;
        filter: brightness(0) invert(1);
    }
    
    .sidebar-nav {
        padding: var(--spacing-lg) 0;
    }
    
    .nav-item {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        padding: var(--spacing-md) var(--spacing-lg);
        color: rgba(255, 255, 255, 0.8);
        text-decoration: none;
        transition: all var(--transition-normal);
        border-left: 3px solid transparent;
    }
    
    .nav-item:hover {
        background: rgba(255, 255, 255, 0.1);
        color: var(--white);
        border-left-color: var(--accent-blue);
    }
    
    .nav-item.active {
        background: rgba(255, 255, 255, 0.15);
        color: var(--white);
        border-left-color: var(--white);
    }
    
    .nav-item i {
        width: 20px;
        text-align: center;
    }
    
    .nav-item h2 {
        font-size: 14px;
        font-weight: 500;
        margin: 0;
    }
    
    /* Main Content Area */
    .main-content {
        flex: 1;
        padding: var(--spacing-lg);
        overflow-y: auto;
    }
    
    /* Page Header */
    .page-header {
        background: var(--white);
        border-radius: var(--radius-md);
        padding: var(--spacing-lg);
        margin-bottom: var(--spacing-lg);
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--medium-gray);
    }
    
    .page-title {
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        font-size: 18px;
        font-weight: 600;
        color: var(--text-dark);
    }
    
    .stats-badge {
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: 6px 16px;
        border-radius: 20px;
        font-size: 13px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    /* Stats Grid */
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: var(--spacing-md);
        padding: var(--spacing-lg);
        background: var(--light-gray);
    }
    
    .stat-card {
        background: var(--white);
        border-radius: var(--radius-md);
        padding: var(--spacing-lg);
        text-align: center;
        border: 1px solid var(--medium-gray);
        box-shadow: var(--shadow-sm);
        transition: transform var(--transition-normal);
    }
    
    .stat-card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-md);
    }
    
    .stat-value {
        font-size: 32px;
        font-weight: 700;
        line-height: 1;
        margin-bottom: var(--spacing-sm);
    }
    
    .stat-label {
        font-size: 13px;
        color: var(--dark-gray);
        display: flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-xs);
    }
    
    /* Results Cards */
    .results-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        margin-bottom: var(--spacing-lg);
        overflow: hidden;
        transition: transform var(--transition-normal), box-shadow var(--transition-normal);
    }
    
    .results-card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-lg);
    }
    
    .card-header {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: var(--spacing-md) var(--spacing-lg);
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .card-header span {
        font-size: 14px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    /* Filter Container */
    .filter-container {
        background: var(--white);
        border-radius: var(--radius-md);
        border: 1px solid var(--medium-gray);
        padding: var(--spacing-lg);
        margin-bottom: var(--spacing-lg);
        box-shadow: var(--shadow-sm);
    }
    
    .filter-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: var(--spacing-lg);
    }
    
    .filter-title {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .filter-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: var(--spacing-md);
        margin-bottom: var(--spacing-md);
    }
    
    .filter-group {
        display: flex;
        flex-direction: column;
    }
    
    .filter-label {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 13px;
        margin-bottom: var(--spacing-xs);
        display: flex;
        align-items: center;
        gap: var(--spacing-xs);
    }
    
    .filter-control,
    .filter-select {
        padding: 10px 12px;
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        font-size: 14px;
        transition: all var(--transition-fast);
        background: var(--white);
        color: var(--text-dark);
    }
    
    .filter-control:focus,
    .filter-select:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }
    
    .filter-select {
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364748b' d='M2 4l4 4 4-4z'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 12px center;
        background-size: 12px;
        padding-right: 32px;
    }
    
    /* Quick Filters */
    .quick-filter-row {
        display: flex;
        flex-wrap: wrap;
        gap: var(--spacing-sm);
        margin-top: var(--spacing-md);
        padding-top: var(--spacing-md);
        border-top: 1px solid var(--medium-gray);
    }
    
    /* Buttons - Consistent with profile page */
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
        padding: 10px 20px;
        border-radius: var(--radius-sm);
        font-size: 14px;
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
    
    .btn-secondary {
        background: var(--dark-gray);
        color: var(--white);
    }
    
    .btn-secondary:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(100, 116, 139, 0.2);
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
    
    .btn-success:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(5, 150, 105, 0.2);
    }
    
    .btn-danger {
        background: linear-gradient(90deg, var(--error), #ef4444);
        color: var(--white);
    }
    
    .btn-danger:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
    }
    
    .btn-sm {
        padding: 6px 12px;
        font-size: 12px;
    }
    
    /* Button Groups */
    .btn-group {
        display: flex;
        gap: 4px;
    }
    
    /* Status Badges */
    .badge {
        padding: 4px 10px;
        border-radius: 12px;
        font-weight: 500;
        font-size: 12px;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        white-space: nowrap;
    }
    
    .badge-info {
        background: linear-gradient(90deg, var(--info), #0ea5e9);
        color: var(--white);
    }
    
    /* Attendance Status */
    .attendance-status {
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }
    
    .status-present {
        background: linear-gradient(90deg, var(--success), #10b981);
        color: var(--white);
    }
    
    .status-absent {
        background: linear-gradient(90deg, var(--error), #ef4444);
        color: var(--white);
    }
    
    .status-not-marked {
        background: var(--medium-gray);
        color: var(--dark-gray);
    }
    
    /* Search Container */
    .search-container {
        position: relative;
        margin-bottom: var(--spacing-lg);
    }
    
    .search-input {
        width: 100%;
        padding: 12px 48px 12px 16px;
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        font-size: 14px;
        transition: all var(--transition-fast);
        background: var(--white);
        color: var(--text-dark);
    }
    
    .search-input:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }
    
    .search-icon {
        position: absolute;
        right: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--dark-gray);
        font-size: 14px;
    }
    
    /* Results Table */
    .results-table {
        width: 100%;
        border-collapse: collapse;
        background: var(--white);
    }
    
    .results-table thead th {
        background: var(--light-gray);
        color: var(--text-dark);
        padding: var(--spacing-md);
        font-weight: 600;
        text-align: left;
        border-bottom: 1px solid var(--medium-gray);
        font-size: 13px;
        cursor: pointer;
        transition: background-color var(--transition-fast);
        position: relative;
    }
    
    .results-table thead th:hover {
        background: var(--medium-gray);
    }
    
    .results-table tbody td {
        padding: var(--spacing-md);
        border-bottom: 1px solid var(--light-gray);
        vertical-align: middle;
        color: var(--dark-gray);
        font-size: 13px;
        text-align: left;
    }
    
    .results-table tbody tr {
        transition: background-color var(--transition-fast);
    }
    
    .results-table tbody tr:hover {
        background-color: var(--light-gray);
    }
    
    /* Sort Indicator */
    .sort-indicator {
        margin-left: 4px;
        font-size: 10px;
        color: var(--dark-gray);
    }
    
    /* No Results Message */
    .no-results {
        text-align: center;
        padding: var(--spacing-xl);
        color: var(--dark-gray);
    }
    
    .no-results i {
        font-size: 48px;
        color: var(--medium-gray);
        margin-bottom: var(--spacing-md);
    }
    
    .no-results h2 {
        font-size: 18px;
        margin-bottom: var(--spacing-sm);
        color: var(--text-dark);
    }
    
    .no-results p {
        font-size: 14px;
        color: var(--dark-gray);
        margin-bottom: var(--spacing-md);
    }
    
    .results-count {
        text-align: center;
        padding: var(--spacing-md);
        color: var(--dark-gray);
        font-size: 13px;
        border-top: 1px solid var(--medium-gray);
        background: var(--light-gray);
    }
    
    /* Checkboxes */
    input[type="checkbox"] {
        width: 16px;
        height: 16px;
        cursor: pointer;
    }
    
    /* Responsive Design - Consistent with profile page */
    @media (max-width: 768px) {
        .dashboard-container {
            flex-direction: column;
        }
        
        .sidebar {
            width: 100%;
            height: auto;
            position: static;
        }
        
        .sidebar-nav {
            display: flex;
            overflow-x: auto;
            padding: var(--spacing-sm);
        }
        
        .nav-item {
            flex-direction: column;
            padding: var(--spacing-sm);
            min-width: 80px;
            text-align: center;
            border-left: none;
            border-bottom: 3px solid transparent;
        }
        
        .nav-item.active {
            border-left: none;
            border-bottom-color: var(--white);
        }
        
        .nav-item:hover {
            border-left: none;
            border-bottom-color: var(--accent-blue);
        }
        
        .page-header {
            flex-direction: column;
            gap: var(--spacing-md);
            text-align: center;
        }
        
        .filter-grid {
            grid-template-columns: 1fr;
        }
        
        .results-table {
            display: block;
            overflow-x: auto;
            white-space: nowrap;
        }
        
        .card-header {
            flex-direction: column;
            gap: var(--spacing-sm);
            text-align: center;
        }
        
        .stats-grid {
            grid-template-columns: repeat(2, 1fr);
        }
        
        .quick-filter-row {
            flex-direction: column;
        }
        
        .quick-filter-row .btn {
            width: 100%;
            justify-content: center;
        }
    }
    
    @media (max-width: 480px) {
        .main-content {
            padding: var(--spacing-md);
        }
        
        .filter-container {
            padding: var(--spacing-md);
        }
        
        .results-table thead th,
        .results-table tbody td {
            padding: var(--spacing-sm);
        }
        
        .stats-grid {
            grid-template-columns: 1fr;
        }
        
        .btn-group {
            flex-direction: column;
        }
    }
    
    /* Loading State */
    .loading {
        opacity: 0.7;
        pointer-events: none;
    }
    
    .loading::after {
        content: '';
        display: inline-block;
        width: 14px;
        height: 14px;
        border: 2px solid var(--light-gray);
        border-top: 2px solid var(--primary-blue);
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-left: var(--spacing-sm);
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    /* For inline forms in quick-filter-row */
    .quick-filter-row form {
        display: inline;
    }
    
    .quick-filter-row .btn {
        margin: 2px;
    }
    
    /* Table Container */
    .results-table-container {
        overflow-x: auto;
    }
    
    /* Results Count Styling */
    .results-count span {
        font-weight: 600;
    }
</style>
    
</head>
<body>
<div class="dashboard-container">
    <!-- Sidebar Navigation -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="CodeSA Institute Pty LTD Logo" class="mut-logo">
        </div>
        <nav class="sidebar-nav">
            <a href="adm-page.jsp?pgprt=0" class="nav-item">
                <i class="fas fa-user"></i>
                <h2>Profile</h2>
            </a>
            <a href="adm-page.jsp?pgprt=2" class="nav-item">
                <i class="fas fa-book"></i>
                <h2>Courses</h2>
            </a>
            <a href="adm-page.jsp?pgprt=3" class="nav-item">
                <i class="fas fa-question-circle"></i>
                <h2>Questions</h2>
            </a>
            <a href="adm-page.jsp?pgprt=5" class="nav-item">
                <i class="fas fa-chart-bar"></i>
                <h2>Results</h2>
            </a>
            <a href="adm-page.jsp?pgprt=1" class="nav-item">
                <i class="fas fa-user-graduate"></i>
                <h2>Student Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=6" class="nav-item">
                <i class="fas fa-chalkboard-teacher"></i>
                <h2>Lecture Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=7" class="nav-item">
               <i class="fas fa-users"></i>
               <h2>Exam Registers</h2>
           </a>
           <a href="adm-page.jsp?pgprt=8" class="nav-item active">
               <i class="fas fa-users"></i>
               <h2>Class Registers</h2>
           </a>
        </nav>
    </aside>

    <div class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <div class="page-title">
                <i class="fas fa-clipboard-list"></i> Class Register - All Students
            </div>
            <div class="stats-badge">
                <i class="fas fa-user-graduate"></i> Student Attendance Register
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-container">
            <form method="get" action="adm-page.jsp">
                <input type="hidden" name="pgprt" value="8">

                <div class="filter-grid">
                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-user"></i> First Name</label>
                        <input type="text" name="first_name" class="filter-control" value="<%= firstNameFilter %>" placeholder="Search by first name">
                    </div>
                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-user"></i> Last Name</label>
                        <input type="text" name="last_name" class="filter-control" value="<%= lastNameFilter %>" placeholder="Search by last name">
                    </div>
                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-school"></i> Class</label>
                        <select name="class_name" class="filter-select">
                            <option value="">All Classes</option>
                            <% for (String className : allClasses) { %>
                                <option value="<%= className %>" <%= className.equals(classNameFilter) ? "selected" : "" %>><%= className %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-book"></i> Course</label>
                        <select name="course_name" class="filter-select">
                            <option value="">All Courses</option>
                            <% for (String course : allCourses) { %>
                                <option value="<%= course %>" <%= course.equals(courseFilter) ? "selected" : "" %>><%= course %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-calendar"></i> Attendance Date</label>
                        <input type="date" name="attendance_date" class="filter-control" value="<%= dateFilter %>">
                    </div>
                </div>

                <div class="quick-filter-row">
                    <button class="btn btn-primary" type="submit">
                        <i class="fas fa-search"></i> Apply Filters
                    </button>
                    <a href="adm-page.jsp?pgprt=8" class="btn btn-outline">
                        <i class="fas fa-times"></i> Clear Filters
                    </a>
                    <button type="button" class="btn btn-success" onclick="markAllAttendance()">
                        <i class="fas fa-check-circle"></i> Mark Selected
                    </button>
                </div>
            </form>
        </div>

        <!-- Class Register Results -->
        <div class="results-card">
            <div class="card-header">
                <span><i class="fas fa-table"></i> Class Attendance Register</span>
                <span class="stats-badge" style="font-size: 12px; padding: 4px 12px;">
                    <i class="fas fa-users"></i> Students Listed
                </span>
            </div>

            <%
                List<Map<String, String>> studentsList = new ArrayList<>();
                int totalStudents = 0;
                int presentCount = 0;
                int absentCount = 0;
                
                try {
                    // Build query to get all students with their attendance for the selected date
                    StringBuilder query = new StringBuilder();
                    query.append("SELECT u.user_id, u.first_name, u.last_name, u.email, u.class_name, ");
                    query.append("dr.registration_date, dr.status ");
                    query.append("FROM users u ");
                    query.append("LEFT JOIN daily_register dr ON u.user_id = dr.student_id ");
                    query.append("AND DATE(dr.registration_date) = ? ");
                    query.append("WHERE u.user_type = 'student' ");
                    
                    List<Object> params = new ArrayList<>();
                    params.add(dateFilter);
                    
                    if (!firstNameFilter.isEmpty()) {
                        query.append("AND u.first_name LIKE ? ");
                        params.add("%" + firstNameFilter + "%");
                    }
                    
                    if (!lastNameFilter.isEmpty()) {
                        query.append("AND u.last_name LIKE ? ");
                        params.add("%" + lastNameFilter + "%");
                    }
                    
                    if (!classNameFilter.isEmpty()) {
                        query.append("AND u.class_name = ? ");
                        params.add(classNameFilter);
                    }
                    
                    query.append("ORDER BY u.class_name, u.last_name, u.first_name");
                    
                    pstmt = pDAO.getPreparedStatement(query.toString());
                    
                    for (int i = 0; i < params.size(); i++) {
                        pstmt.setObject(i + 1, params.get(i));
                    }
                    
                    rs = pstmt.executeQuery();
                    
                    while (rs.next()) {
                        Map<String, String> student = new HashMap<>();
                        student.put("user_id", rs.getString("user_id"));
                        student.put("first_name", rs.getString("first_name"));
                        student.put("last_name", rs.getString("last_name"));
                        student.put("email", rs.getString("email"));
                        student.put("class_name", rs.getString("class_name"));
                        student.put("registration_date", rs.getString("registration_date"));
                        student.put("status", rs.getString("status"));
                        
                        studentsList.add(student);
                        totalStudents++;
                        
                        if ("present".equalsIgnoreCase(rs.getString("status"))) {
                            presentCount++;
                        } else if ("absent".equalsIgnoreCase(rs.getString("status"))) {
                            absentCount++;
                        }
                    }
                    
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                }
            %>

            <!-- Summary Statistics -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value"><%= totalStudents %></div>
                    <div class="stat-label"><i class="fas fa-users"></i> Total Students</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" style="color: var(--success);"><%= presentCount %></div>
                    <div class="stat-label"><i class="fas fa-check-circle"></i> Present</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" style="color: var(--error);"><%= absentCount %></div>
                    <div class="stat-label"><i class="fas fa-times-circle"></i> Absent</div>
                </div>
                <div class="stat-card">
                    <%
                        int notMarked = totalStudents - presentCount - absentCount;
                    %>
                    <div class="stat-value" style="color: var(--warning);"><%= notMarked %></div>
                    <div class="stat-label"><i class="fas fa-clock"></i> Not Marked</div>
                </div>
            </div>

            <% if (!studentsList.isEmpty()) { %>
                <div class="results-table-container">
                    <form id="attendanceForm" method="post" action="updateAttendance.jsp">
                        <input type="hidden" name="attendance_date" value="<%= dateFilter %>">
                        <table class="results-table">
                            <thead>
                                <tr>
                                    <th style="width: 30px;">#</th>
                                    <th style="width: 30px;">
                                        <input type="checkbox" id="selectAll" onchange="toggleSelectAll(this)">
                                    </th>
                                    <th>Student Name</th>
                                    <th>Student ID</th>
                                    <th>Class</th>
                                    <th>Email</th>
                                    <th>Attendance Date</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int i = 0;
                                    for (Map<String, String> student : studentsList) {
                                        i++;
                                        String status = student.get("status");
                                        String registrationDate = student.get("registration_date");
                                %>
                                <tr>
                                    <td><%= i %></td>
                                    <td>
                                        <input type="checkbox" name="selectedStudents" value="<%= student.get("user_id") %>" 
                                               class="student-checkbox">
                                    </td>
                                    <td>
                                        <strong><%= student.get("first_name") %> <%= student.get("last_name") %></strong>
                                    </td>
                                    <td><%= student.get("user_id") %></td>
                                    <td>
                                        <span class="badge badge-info">
                                            <%= student.get("class_name") != null ? student.get("class_name") : "N/A" %>
                                        </span>
                                    </td>
                                    <td><%= student.get("email") %></td>
                                    <td>
                                        <% if (registrationDate != null) { 
                                            try {
                                                java.text.SimpleDateFormat displayFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
                                                java.text.SimpleDateFormat parseFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                                                out.print(displayFormat.format(parseFormat.parse(registrationDate)));
                                            } catch (Exception e) {
                                                out.print(dateFilter);
                                            }
                                        } else {
                                            out.print(dateFilter);
                                        } %>
                                    </td>
                                    <td>
                                        <% if ("present".equalsIgnoreCase(status)) { %>
                                            <span class="attendance-status status-present">
                                                <i class="fas fa-check-circle"></i> Present
                                            </span>
                                        <% } else if ("absent".equalsIgnoreCase(status)) { %>
                                            <span class="attendance-status status-absent">
                                                <i class="fas fa-times-circle"></i> Absent
                                            </span>
                                        <% } else { %>
                                            <span class="attendance-status status-not-marked">
                                                <i class="fas fa-clock"></i> Not Marked
                                            </span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <button type="button" class="btn btn-success btn-sm"
                                                    onclick="markAttendance('<%= student.get("user_id") %>', 'present')">
                                                <i class="fas fa-check"></i> Present
                                            </button>
                                            <button type="button" class="btn btn-danger btn-sm"
                                                    onclick="markAttendance('<%= student.get("user_id") %>', 'absent')">
                                                <i class="fas fa-times"></i> Absent
                                            </button>
                                            <button type="button" class="btn btn-outline btn-sm"
                                                    onclick="markAttendance('<%= student.get("user_id") %>', 'late')">
                                                <i class="fas fa-clock"></i> Late
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </form>
                </div>

                <div class="results-count">
                    Total Students: <strong><%= totalStudents %></strong> | 
                    Present: <strong style="color: var(--success);"><%= presentCount %></strong> | 
                    Absent: <strong style="color: var(--error);"><%= absentCount %></strong> | 
                    Not Marked: <strong style="color: var(--warning);"><%= totalStudents - presentCount - absentCount %></strong>
                </div>

            <% } else { %>
                <div class="no-results">
                    <i class="fas fa-user-graduate"></i>
                    <h2>No Students Found</h2>
                    <p>No student records match your search criteria.</p>
                    <a href="adm-page.jsp?pgprt=8" class="btn btn-primary">
                        <i class="fas fa-refresh"></i> Reset Filters
                    </a>
                </div>
            <% } %>
        </div>
    </div>
</div>

<script>
    function toggleSelectAll(checkbox) {
        const checkboxes = document.querySelectorAll('.student-checkbox');
        checkboxes.forEach(cb => {
            cb.checked = checkbox.checked;
        });
    }
    
    function markAttendance(studentId, status) {
        if (confirm('Mark this student as ' + status + '?')) {
            const form = document.createElement('form');
            form.method = 'post';
            form.action = 'updateAttendance.jsp';
            
            const studentIdInput = document.createElement('input');
            studentIdInput.type = 'hidden';
            studentIdInput.name = 'student_id';
            studentIdInput.value = studentId;
            
            const statusInput = document.createElement('input');
            statusInput.type = 'hidden';
            statusInput.name = 'status';
            statusInput.value = status;
            
            const dateInput = document.createElement('input');
            dateInput.type = 'hidden';
            dateInput.name = 'attendance_date';
            dateInput.value = '<%= dateFilter %>';
            
            form.appendChild(studentIdInput);
            form.appendChild(statusInput);
            form.appendChild(dateInput);
            
            document.body.appendChild(form);
            form.submit();
        }
    }
    
    function markAllAttendance() {
        const selectedCheckboxes = document.querySelectorAll('.student-checkbox:checked');
        if (selectedCheckboxes.length === 0) {
            alert('Please select at least one student.');
            return;
        }
        
        if (confirm('Mark attendance for ' + selectedCheckboxes.length + ' selected students as "Present"?')) {
            // Create status input for bulk marking
            const statusInput = document.createElement('input');
            statusInput.type = 'hidden';
            statusInput.name = 'status';
            statusInput.value = 'present';
            
            const form = document.getElementById('attendanceForm');
            form.appendChild(statusInput);
            form.submit();
        }
    }
    
    // Set today's date as default if empty
    document.addEventListener('DOMContentLoaded', function() {
        const dateInput = document.querySelector('input[name="attendance_date"]');
        if (dateInput && !dateInput.value) {
            const today = new Date().toISOString().split('T')[0];
            dateInput.value = today;
        }
    });
</script>
</body>
</html>