<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Authentication and authorization checks
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");
    if (!("admin".equals(userType) || "lecture".equals(userType))) {
        response.sendRedirect("std-page.jsp");
        return;
    }

    // Get filter parameters from request
    String studentNameFilter = request.getParameter("student_name");
    if (studentNameFilter == null) studentNameFilter = "";

    String dateFilter = request.getParameter("registration_date");
    if (dateFilter == null) dateFilter = "";

    String sortBy = request.getParameter("sort_by");
    if (sortBy == null) sortBy = "registration_date";

    String sortOrder = request.getParameter("sort_order");
    if (sortOrder == null) sortOrder = "desc";

    // Instantiate DAO and fetch data
    DatabaseClass pDAO = DatabaseClass.getInstance();
    ArrayList<Map<String, String>> registerList = pDAO.getFilteredDailyRegister(studentNameFilter, dateFilter);
    
    // Get today's date for quick filters
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new java.util.Date());
    
    // Get yesterday's date
    java.util.Calendar cal = java.util.Calendar.getInstance();
    cal.add(java.util.Calendar.DATE, -1);
    String yesterday = sdf.format(cal.getTime());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Register Log</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

</head>

<%@ include file="modal_assets.jspf" %>

<!-- CSS Styles remain the same -->
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
    
    /* Sidebar Styles - Scrollable */
    .sidebar {
        width: 200px;
        background: linear-gradient(180deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        flex-shrink: 0;
        position: sticky;
        top: 0;
        height: 100vh;
        overflow-y: auto;        /* enable vertical scrolling */
        overflow-x: hidden;      /* prevent horizontal scroll */
    }

    /* Optional: smoother scrolling */
    .sidebar {
        scroll-behavior: smooth;
    }

    /* Optional: hide scrollbar but keep scroll (Chrome/Edge/Safari) */
    .sidebar::-webkit-scrollbar {
        width: 6px;
    }
    .sidebar::-webkit-scrollbar-thumb {
        background: rgba(255, 255, 255, 0.35);
        border-radius: 4px;
    }
    .sidebar::-webkit-scrollbar-track {
        background: transparent;
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
    
    
    .quick-filter-btn {
        background: var(--light-gray);
        border: 1px solid var(--medium-gray);
        border-radius: 20px;
        padding: 8px 16px;
        font-size: 13px;
        cursor: pointer;
        transition: all var(--transition-fast);
        color: var(--text-dark);
        display: inline-flex;
        align-items: center;
        gap: var(--spacing-xs);
    }
    
    .quick-filter-btn:hover,
    .quick-filter-btn.active {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        border-color: transparent;
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
    
    .badge-success {
        background: linear-gradient(90deg, var(--success), #10b981);
        color: var(--white);
    }
    
    .badge-error {
        background: linear-gradient(90deg, var(--error), #ef4444);
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
        font-style: italic;
        font-size: 14px;
    }
    
    .results-count {
        text-align: center;
        padding: var(--spacing-md);
        color: var(--dark-gray);
        font-size: 13px;
        border-top: 1px solid var(--medium-gray);
        background: var(--light-gray);
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
        
        .quick-filter-btn {
            font-size: 12px;
            padding: 6px 12px;
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
</style>

<body>
<div class="dashboard-container">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="Logo" class="mut-logo">
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
               <i class="fas fa-clipboard-list"></i>
               <h2>Class Registers</h2>
           </a>
        </nav>
    </aside>

    <div class="main-content">
        <!-- Header -->
        <div class="page-header">
            <div class="page-title">
                <i class="fas fa-clipboard-list"></i> Class Register Log
            </div>
            <div class="stats-badge">
                <i class="fas fa-users"></i>
                <span><%= registerList.size() %> Total Records</span>
            </div>
        </div>

        <!-- Search and Quick Actions -->
        <div class="search-container">
            <form method="get" action="adm-page.jsp" id="searchForm">
                <input type="hidden" name="pgprt" value="8">
                <input type="search" 
                       name="student_name" 
                       class="search-input" 
                       placeholder="Search by student name or ID..."
                       value="<%= studentNameFilter %>">
                <i class="fas fa-search search-icon"></i>
            </form>
        </div>

        <!-- Filter Container -->
        <div class="filter-container">
            <form method="get" action="adm-page.jsp" id="filterForm">
                <input type="hidden" name="pgprt" value="8">
                <input type="hidden" name="student_name" value="<%= studentNameFilter %>">
                
                <div class="filter-header">
                    <div class="filter-title">
                        <i class="fas fa-filter"></i> Filter Options
                    </div>
                    <button type="button" class="btn btn-outline" onclick="resetFilters()">
                        <i class="fas fa-redo"></i> Reset All
                    </button>
                </div>

                <div class="filter-grid">
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-calendar-alt"></i> Date Range
                        </label>
                        <input type="date" 
                               name="registration_date" 
                               class="filter-control" 
                               value="<%= dateFilter %>">
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-sort-amount-down"></i> Sort By
                        </label>
                        <select name="sort_by" class="filter-select" onchange="this.form.submit()">
                            <option value="registration_date" <%= "registration_date".equals(sortBy) ? "selected" : "" %>>Date</option>
                            <option value="student_name" <%= "student_name".equals(sortBy) ? "selected" : "" %>>Student Name</option>
                            <option value="student_id" <%= "student_id".equals(sortBy) ? "selected" : "" %>>Student ID</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-sort"></i> Order
                        </label>
                        <select name="sort_order" class="filter-select" onchange="this.form.submit()">
                            <option value="desc" <%= "desc".equals(sortOrder) ? "selected" : "" %>>Newest First</option>
                            <option value="asc" <%= "asc".equals(sortOrder) ? "selected" : "" %>>Oldest First</option>
                        </select>
                    </div>
                </div>

                <!-- Quick Filters -->
                <div class="quick-filter-row">
                    <span class="filter-label" style="margin-right: var(--spacing-sm);">
                        <i class="fas fa-bolt"></i> Quick Filters:
                    </span>
                    <button type="button" 
                            class="quick-filter-btn <%= today.equals(dateFilter) ? "active" : "" %>"
                            onclick="setDateFilter('<%= today %>')">
                        <i class="fas fa-calendar-day"></i> Today
                    </button>
                    <button type="button" 
                            class="quick-filter-btn <%= yesterday.equals(dateFilter) ? "active" : "" %>"
                            onclick="setDateFilter('<%= yesterday %>')">
                        <i class="fas fa-calendar-minus"></i> Yesterday
                    </button>
                    <button type="button" 
                            class="quick-filter-btn <%= "".equals(dateFilter) ? "active" : "" %>"
                            onclick="setDateFilter('')">
                        <i class="fas fa-calendar-week"></i> All Dates
                    </button>
                    
                    <div style="flex-grow: 1;"></div>
                    
                    <button class="btn btn-primary" type="submit">
                        <i class="fas fa-search"></i> Apply Filters
                    </button>
                    
                    <a href="export-class-register.jsp?student_name=<%= URLEncoder.encode(studentNameFilter, "UTF-8") %>&registration_date=<%= URLEncoder.encode(dateFilter, "UTF-8") %>&sort_by=<%= sortBy %>&sort_order=<%= sortOrder %>" 
                       class="btn btn-success">
                        <i class="fas fa-file-csv"></i> Export CSV
                    </a>
                </div>
            </form>
        </div>

        <!-- Results Card -->
        <div class="results-card">
            <div class="card-header">
                <span><i class="fas fa-table"></i> Attendance Records</span>
                <div>
                    <span class="stats-badge">
                        <i class="fas fa-chart-line"></i>
                        <%= registerList.size() %> Records
                    </span>
                    <% if (!dateFilter.isEmpty()) { %>
                    <span class="stats-badge" style="margin-left: var(--spacing-sm); background: linear-gradient(135deg, var(--info), #0ea5e9);">
                        <i class="fas fa-calendar-check"></i>
                        <%= dateFilter %>
                    </span>
                    <% } %>
                </div>
            </div>

            <% if (!registerList.isEmpty()) { %>
            <form id="bulkDeleteForm" action="controller.jsp" method="post">
                <input type="hidden" name="page" value="class-register">
                <input type="hidden" name="operation" value="bulk_delete">
                <input type="hidden" name="csrf_token" value="<%= session.getAttribute("csrf_token") %>">
                <button type="submit" class="btn btn-danger" style="margin-bottom: 20px;">
                    <i class="fas fa-trash"></i> Delete Selected
                </button>
                <div class="results-table-container">
                    <table class="results-table">
                        <thead>
                            <tr>
                                <th><input type="checkbox" id="selectAll"></th>
                                <th onclick="sortTable('index')"># <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('register_id')">Register ID <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('student_id')">Student ID <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('student_name')">Student Name <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('registration_date')">Date <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('registration_time')">Time <i class="fas fa-sort sort-indicator"></i></th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                int i = 0; 
                                for (Map<String, String> record : registerList) { 
                                    i++;
                                    String registerId = record.get("register_id");
                                    String studentId = record.get("student_id");
                                    String studentName = record.get("student_name");
                                    String regDate = record.get("registration_date");
                                    String regTime = record.get("registration_time");
                            %>
                            <tr>
                                <td><input type="checkbox" name="registerIds" value="<%= registerId %>"></td>
                                <td><span class="badge badge-info"><%= i %></span></td>
                                <td><code><%= registerId %></code></td>
                                <td><strong><%= studentId %></strong></td>
                                <td>
                                    <div style="display: flex; align-items: center; gap: var(--spacing-sm);">
                                        <div style="width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, var(--primary-blue), var(--accent-blue)); display: flex; align-items: center; justify-content: center; color: white; font-size: 12px;">
                                            <%= studentName.substring(0, 1).toUpperCase() %>
                                        </div>
                                        <%= studentName %>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge <%= today.equals(regDate) ? "badge-success" : "badge-info" %>">
                                        <i class="fas fa-calendar"></i>
                                        <%= regDate %>
                                    </span>
                                </td>
                                <td>
                                    <span class="badge badge-warning">
                                        <i class="fas fa-clock"></i>
                                        <%= regTime %>
                                    </span>
                                </td>
                                <td>
                                    <button class="btn btn-outline" style="padding: 4px 8px; font-size: 12px;" 
                                            onclick="viewStudentDetails('<%= studentId %>')">
                                        <i class="fas fa-eye"></i> View
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </form>
                
                <div class="results-count">
                    Showing <%= registerList.size() %> record(s)
                    <% if (!studentNameFilter.isEmpty()) { %>
                        for "<%= studentNameFilter %>"
                    <% } %>
                    <% if (!dateFilter.isEmpty()) { %>
                        on <%= dateFilter %>
                    <% } %>
                </div>
                
            <% } else { %>
                <div class="no-results">
                    <i class="fas fa-clipboard-list fa-3x" style="color: var(--medium-gray); margin-bottom: var(--spacing-md);"></i>
                    <h2>No Records Found</h2>
                    <p style="color: var(--dark-gray); margin-bottom: var(--spacing-lg);">
                        No attendance records match your filter criteria.
                        <% if (!studentNameFilter.isEmpty() || !dateFilter.isEmpty()) { %>
                            Try adjusting your filters.
                        <% } %>
                    </p>
                    <% if (!studentNameFilter.isEmpty() || !dateFilter.isEmpty()) { %>
                        <a href="adm-page.jsp?pgprt=8" class="btn btn-primary">
                            <i class="fas fa-times"></i> Clear All Filters
                        </a>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
</div>

<div id="deleteConfirmationModal" class="modal-overlay" style="display: none;">
  <div class="modal-content">
    <div class="modal-header">
      <h2 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Confirm Deletion</h2>
      <button class="close-button" onclick="closeModal()">&times;</button>
    </div>
    <div class="modal-body">
      <p id="deleteModalMessage">Are you sure you want to delete the selected records?</p>
    </div>
    <div class="modal-footer">
      <button onclick="closeModal()" class="btn btn-secondary">Cancel</button>
      <button id="confirmDeleteBtn" class="btn btn-danger">Delete</button>
    </div>
  </div>
</div>

<script>
    // JavaScript for enhanced functionality
    document.addEventListener('DOMContentLoaded', function() {
        // Auto-submit search form on typing
        const searchInput = document.querySelector('.search-input');
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                document.getElementById('searchForm').submit();
            }, 500);
        });
        
        // Highlight active filters
        highlightActiveFilters();
    });

    document.getElementById('selectAll').addEventListener('change', function(e) {
        const checkboxes = document.querySelectorAll('input[name="registerIds"]');
        checkboxes.forEach(checkbox => {
            checkbox.checked = e.target.checked;
        });
    });

    document.getElementById('bulkDeleteForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const selected = document.querySelectorAll('input[name="registerIds"]:checked').length;
        if (selected === 0) {
            showAlert('Please select at least one record to delete.');
            return;
        }

        document.getElementById('deleteModalMessage').innerText = 'Are you sure you want to delete ' + selected + ' record(s)?';
        showModal();

        document.getElementById('confirmDeleteBtn').onclick = function() {
            e.target.submit();
        };
    });
    
    function setDateFilter(date) {
        const form = document.getElementById('filterForm');
        form.elements['registration_date'].value = date;
        form.submit();
    }
    
    function resetFilters() {
        window.location.href = 'adm-page.jsp?pgprt=8';
    }
    
    function sortTable(column) {
        const url = new URL(window.location.href);
        const currentSort = url.searchParams.get('sort_by');
        const currentOrder = url.searchParams.get('sort_order');
        
        let newOrder = 'asc';
        if (currentSort === column) {
            newOrder = currentOrder === 'asc' ? 'desc' : 'asc';
        }
        
        url.searchParams.set('sort_by', column);
        url.searchParams.set('sort_order', newOrder);
        window.location.href = url.toString();
    }
    
    function viewStudentDetails(studentId) {
        // You can implement a modal or redirect to student details page
        alert('View details for student ID: ' + studentId);
        // Example: window.open('student-details.jsp?id=' + studentId, '_blank');
    }
    
    function highlightActiveFilters() {
        const params = new URLSearchParams(window.location.search);
        
        // Highlight date quick filters
        const dateFilter = params.get('registration_date');
        if (dateFilter) {
            document.querySelectorAll('.quick-filter-btn').forEach(btn => {
                if (btn.textContent.includes(dateFilter === '<%= today %>' ? 'Today' : 
                                            dateFilter === '<%= yesterday %>' ? 'Yesterday' : '')) {
                    btn.classList.add('active');
                }
            });
        }
    }
    
    // Add loading state to form submissions
    document.querySelectorAll('form').forEach(form => {
        form.addEventListener('submit', function() {
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.classList.add('loading');
                submitBtn.disabled = true;
            }
        });
    });
</script>

</body>
</html>