<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.UUID"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>

<% 
    String csrfToken = UUID.randomUUID().toString();
    session.setAttribute("csrf_token", csrfToken);
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

// Get ALL exam results (for admin view)
ArrayList<Exams> allExamResults = pDAO.getAllExamResults();
%>


<!--Style-->
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
</style>

<%@ include file="header-messages.jsp" %>

<div class="dashboard-container">
    <!-- Sidebar Navigation - Same as profile page -->
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
            <a href="adm-page.jsp?pgprt=5" class="nav-item active">
                <i class="fas fa-chart-bar"></i>
                <h2>Students Results</h2>
            </a>
            <a href="adm-page.jsp?pgprt=1" class="nav-item">
                <i class="fas fa-users"></i>
                <h2>Accounts</h2>
            </a>
            
            <a href="adm-page.jsp?pgprt=7" class="nav-item">
               <i class="fas fa-users"></i>
               <h2>Registers</h2>
           </a>
        </nav>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <!-- Page Header -->
        <header class="page-header">
            <div class="page-title">
                <i class="fas fa-chart-bar"></i>
                Student Results
            </div>
            <div class="stats-badge">
                <i class="fas fa-graduation-cap"></i>
                Performance Analytics
            </div>
        </header>
        
        <!-- Filter Container -->
        <div class="filter-container">
            <div class="filter-header">
                <div class="filter-title">
                    <i class="fas fa-filter"></i> Filter Results
                </div>
                <button class="btn btn-secondary" onclick="resetAllFilters()">
                    <i class="fas fa-redo"></i> Reset All
                </button>
            </div>
            
            <div class="filter-grid">
                <div class="filter-group">
                    <label class="filter-label">Student Name</label>
                    <input type="text" id="filterName" class="filter-control" 
                           placeholder="Search by name..." oninput="applyFilters()">
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">Course</label>
                    <select id="filterCourse" class="filter-select" onchange="applyFilters()">
                        <option value="">All Courses</option>
                        <%
                            ArrayList<String> allCourses = pDAO.getAllCourseNames();
                            if (allCourses != null) {
                                for (String course : allCourses) {
                        %>
                        <option value="<%= course %>"><%= course %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">Status</label>
                    <select id="filterStatus" class="filter-select" onchange="applyFilters()">
                        <option value="">All Status</option>
                        <option value="Pass">Pass</option>
                        <option value="Fail">Fail</option>
                        <option value="Terminated">Terminated</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">Date Range</label>
                    <input type="date" id="filterDateFrom" class="filter-control" 
                           onchange="applyFilters()">
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">To Date</label>
                    <input type="date" id="filterDateTo" class="filter-control" 
                           onchange="applyFilters()">
                </div>
            </div>
            
            <!-- Quick Filters -->
            <div class="quick-filter-row">
                <button class="quick-filter-btn" onclick="setQuickFilter('pass')">
                    <i class="fas fa-check-circle"></i> Pass Only
                </button>
                <button class="quick-filter-btn" onclick="setQuickFilter('fail')">
                    <i class="fas fa-times-circle"></i> Fail Only
                </button>
                <button class="quick-filter-btn" onclick="setQuickFilter('high')">
                    <i class="fas fa-star"></i> High Scores (&gt;80%)
                </button>
                <button class="quick-filter-btn" onclick="setQuickFilter('low')">
                    <i class="fas fa-exclamation-triangle"></i> Low Scores (&lt;50%)
                </button>
            </div>
        </div>
        
        <!-- Search Box -->
        <div class="search-container">
            <input
                type="text"
                id="searchBox"
                class="search-input"
                placeholder="Search across all columns..."
                oninput="applyFilters()">
            <i class="fas fa-search search-icon"></i>
        </div>
        
        <!-- Results Card -->
        <div class="results-card">
            <div class="card-header">
                <span><i class="fas fa-list"></i> All Student Results</span>
                <div class="stats-badge">
                    <span id="resultsCount"><%= allExamResults.size() %></span> Results
                </div>
            </div>
            
            <% if (request.getParameter("eid") == null) { %>
                <div style="overflow-x:auto;">
                    <table class="results-table" id="resultsTable">
                        <thead>
                            <tr>
                                <th onclick="sortTable(0)">Name <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(1)">Student ID <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(2)">Email <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(3)">Date <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(4)">Course <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(5)">Time <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(6)">Marks <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(7)">Status <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(8)">% <span class="sort-indicator"></span></th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        
                        <tbody id="resultsTableBody">
                            <% 
                                if (allExamResults.isEmpty()) { 
                            %>
                            <tr>
                                <td colspan="10" class="no-results">
                                    <i class="fas fa-info-circle"></i> No results found
                                </td>
                            </tr>
                            <% 
                                } else { 
                                    for (Exams e : allExamResults) {
                                        double percentage = (e.gettMarks() > 0) ? (double)e.getObtMarks() / e.gettMarks() * 100 : 0;
                                        String status = (e.getStatus() != null) ? e.getStatus() : "Terminated";
                                        // Use getFullName() method as per Exams class, with a fallback for safety
                                        String fullName = (e.getFullName() != null && !e.getFullName().trim().isEmpty()) ? e.getFullName() : "N/A";
                                        int examId = e.getExamId();
                            %>
                            <tr class="result-row" 
                                data-index="<%= examId %>"
                                data-name="<%= fullName.toLowerCase() %>"
                                data-id="<%= e.getUserName().toLowerCase() %>"
                                data-email="<%= e.getEmail().toLowerCase() %>"
                                data-date="<%= e.getDate() %>"
                                data-course="<%= e.getcName().toLowerCase() %>"
                                data-time="<%= e.getStartTime() + " - " + e.getEndTime() %>"
                                data-obt-marks="<%= e.getObtMarks() %>"
                                data-total-marks="<%= e.gettMarks() %>"
                                data-marks="<%= e.getObtMarks() + "/" + e.gettMarks() %>"
                                data-percentage="<%= percentage %>"
                                data-status="<%= status.toLowerCase() %>">
                                <td><%= fullName %></td>
                                <td><%= e.getUserName() %></td>
                                <td><%= e.getEmail() %></td>
                                <td><%= e.getDate() %></td>
                                <td><%= e.getcName() %></td>
                                <td><%= e.getStartTime() %> - <%= e.getEndTime() %></td>
                                <td>
                                    <span class="marks-display">
                                        <%= e.getObtMarks() %> / <%= e.gettMarks() %>
                                    </span>
                                    <div class="marks-edit" style="display: none;">
                                        <input type="number" class="form-control" 
                                               value="<%= e.getObtMarks() %>" 
                                               min="0" max="<%= e.gettMarks() %>"
                                               style="width: 80px; display: inline-block;">
                                        <span> / <%= e.gettMarks() %></span>
                                    </div>
                                </td>
                                <td>
                                    <% if (status.equals("Pass")) { %>
                                        <span class="badge badge-success status-display">
                                            <i class="fas fa-check-circle"></i> <%= status %>
                                        </span>
                                    <% } else if (status.equals("Fail")) { %>
                                        <span class="badge badge-error status-display">
                                            <i class="fas fa-times-circle"></i> <%= status %>
                                        </span>
                                    <% } else { %>
                                        <span class="badge badge-warning status-display">
                                            <i class="fas fa-exclamation-triangle"></i> Terminated
                                        </span>
                                    <% } %>
                                    <div class="status-edit" style="display: none;">
                                        <select class="form-control" style="width: 120px; display: inline-block;">
                                            <option value="Pass" <%= status.equals("Pass") ? "selected" : "" %>>Pass</option>
                                            <option value="Fail" <%= status.equals("Fail") ? "selected" : "" %>>Fail</option>
                                            <option value="Terminated" <%= status.equals("Terminated") ? "selected" : "" %>>Terminated</option>
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge badge-info"><%= String.format("%.0f", percentage) %>%</span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn btn-secondary edit-btn" 
                                                data-exam-id="<%= examId %>"
                                                style="font-size: 13px; padding: 8px 16px; margin: 2px;">
                                            <i class="fas fa-edit"></i> Edit
                                        </button>
                                        <button class="btn btn-danger delete-btn" 
                                                data-exam-id="<%= examId %>"
                                                data-student-name="<%= fullName %>"
                                                data-course-name="<%= e.getcName() %>"
                                                style="font-size: 13px; padding: 8px 16px; margin: 2px;">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                        <button class="btn btn-success save-btn" 
                                                data-exam-id="<%= examId %>"
                                                style="display:none; font-size: 13px; padding: 8px 16px; margin: 2px;">
                                            <i class="fas fa-save"></i> Save
                                        </button>
                                        <button class="btn btn-warning cancel-btn" 
                                                style="display:none; font-size: 13px; padding: 8px 16px; margin: 2px;">
                                            <i class="fas fa-times"></i> Cancel
                                        </button>
                                        <a class="btn btn-primary" href="adm-page.jsp?pgprt=5&eid=<%= examId %>" 
                                           style="font-size: 13px; padding: 8px 16px; margin: 2px;">
                                            <i class="fas fa-eye"></i> Details
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <% 
                                    }
                                } 
                            %>
                        </tbody>
                    </table>
                    <div class="results-count">
                        Showing <span id="visibleCount"><%= allExamResults.size() %></span> of 
                        <span id="totalCount"><%= allExamResults.size() %></span> results
                    </div>
                </div>
            <% } else { %>
                <!-- Details View -->
                <div style="padding: var(--spacing-lg);">
                    <button class="btn btn-outline" onclick="window.history.back()" style="margin-bottom: var(--spacing-lg);">
                        <i class="fas fa-arrow-left"></i> Back to Results
                    </button>
                    <div style="margin-top: var(--spacing-md);">
                        <% 
                            int examId = Integer.parseInt(request.getParameter("eid"));
                            ArrayList<Answers> answers = pDAO.getAllAnswersByExamId(examId);
                        %>
                        <h3 style="color: var(--primary-blue); margin-bottom: var(--spacing-md); display: flex; align-items: center; gap: var(--spacing-sm);">
                            <i class="fas fa-file-alt"></i> Exam Details
                        </h3>
                        <% if (answers.isEmpty()) { %>
                            <p class="no-results">No answer details available for this exam.</p>
                        <% } else { %>
                            <table class="results-table" style="margin-top: var(--spacing-md);">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Question</th>
                                        <th>Your Answer</th>
                                        <th>Correct Answer</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (int i = 0; i < answers.size(); i++) { 
                                        Answers a = answers.get(i);
                                    %>
                                    <tr>
                                        <td><strong><%= i + 1 %></strong></td>
                                        <td><%= a.getQuestion() %></td>
                                        <td><%= a.getAnswer() != null ? a.getAnswer() : "No Answer" %></td>
                                        <td><%= a.getCorrectAnswer() != null ? a.getCorrectAnswer() : "N/A" %></td>
                                        <td>
                                            <% if (a.getStatus().equals("correct")) { %>
                                                <span class="badge badge-success">
                                                    <i class="fas fa-check"></i> Correct
                                                </span>
                                            <% } else { %>
                                                <span class="badge badge-error">
                                                    <i class="fas fa-times"></i> Incorrect
                                                </span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
    </main>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="modal" style="display: none;">
    <div class="modal-content" style="max-width: 500px;">
        <div class="modal-header">
            <h3><i class="fas fa-exclamation-triangle" style="color: #dc3545;"></i> Delete Exam Result</h3>
            <span class="close-modal" onclick="closeDeleteModal()">&times;</span>
        </div>
        <div class="modal-body">
            <p id="deleteModalMessage">Are you sure you want to delete this exam result?</p>
        </div>
        <div class="modal-footer">
            <button onclick="closeDeleteModal()" class="btn btn-outline">Cancel</button>
            <button onclick="confirmDelete()" class="btn btn-danger">
                <i class="fas fa-trash"></i> Delete
            </button>
        </div>
    </div>
</div>

<style>
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
}

.modal-content {
    background-color: #fff;
    margin: 10% auto;
    padding: 0;
    border-radius: 8px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.3);
}

.modal-header {
    padding: 16px 20px;
    background-color: #f8f9fa;
    border-bottom: 1px solid #dee2e6;
    border-radius: 8px 8px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-header h3 {
    margin: 0;
    color: #333;
    font-size: 18px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.close-modal {
    color: #aaa;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
    line-height: 20px;
}

.close-modal:hover {
    color: #000;
}

.modal-body {
    padding: 20px;
    color: #333;
    font-size: 16px;
    line-height: 1.5;
}

.modal-footer {
    padding: 16px 20px;
    background-color: #f8f9fa;
    border-top: 1px solid #dee2e6;
    border-radius: 0 0 8px 8px;
    text-align: right;
}

/* Update button styles to match your theme */
.btn {
    padding: 8px 16px;
    border-radius: 6px;
    border: none;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
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

.btn-danger {
    background: linear-gradient(135deg, #dc2626, #b91c1c);
    color: white;
    border: none;
}

.btn-danger:hover {
    background: linear-gradient(135deg, #b91c1c, #991b1b);
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(220, 38, 38, 0.3);
}

.btn-danger:disabled {
    background: #9ca3af;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
}
</style>

<style>
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
}

.modal-content {
    background-color: #fff;
    margin: 10% auto;
    padding: 0;
    border-radius: 8px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.3);
}

.modal-header {
    padding: 16px 20px;
    background-color: #f8f9fa;
    border-bottom: 1px solid #dee2e6;
    border-radius: 8px 8px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-header h3 {
    margin: 0;
    color: #333;
    font-size: 18px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.close-modal {
    color: #aaa;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
    line-height: 20px;
}

.close-modal:hover {
    color: #000;
}

.modal-body {
    padding: 20px;
    color: #333;
    font-size: 16px;
    line-height: 1.5;
}

.modal-footer {
    padding: 16px 20px;
    background-color: #f8f9fa;
    border-top: 1px solid #dee2e6;
    border-radius: 0 0 8px 8px;
    text-align: right;
}

.action-buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    align-items: center;
}

.action-buttons .btn {
    margin: 2px !important;
}
</style>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- JavaScript for enhanced functionality -->
<script>
    // Global variables
    let currentSortColumn = -1;
    let sortDirection = 1;
    let deleteExamId = null;
    let deleteStudentName = null;
    let deleteCourseName = null;
    const csrfToken = '<%= session.getAttribute("csrf_token") %>';

    // Initialize when page loads
    document.addEventListener('DOMContentLoaded', function() {
        updateResultsCount();
        
        // Set today's date as default for date filters
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('filterDateTo').value = today;
        
        // Set date from 30 days ago
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        document.getElementById('filterDateFrom').value = thirtyDaysAgo.toISOString().split('T')[0];
        
        // Initialize edit/delete functionality
        initializeEditDeleteHandlers();
        
        // Debug: Log to check if modal exists
        console.log('Modal element exists:', document.getElementById('deleteModal') !== null);
    });
    
    function initializeEditDeleteHandlers() {
        // Edit button click handler
        document.querySelectorAll('.edit-btn').forEach(button => {
            button.addEventListener('click', function() {
                const examId = this.getAttribute('data-exam-id');
                const row = this.closest('tr');
                enableEditMode(row, examId);
            });
        });
        
        // Save button click handler
        document.querySelectorAll('.save-btn').forEach(button => {
            button.addEventListener('click', function() {
                const examId = this.getAttribute('data-exam-id');
                const row = this.closest('tr');
                saveChanges(row, examId);
            });
        });
        
        // Cancel button click handler
        document.querySelectorAll('.cancel-btn').forEach(button => {
            button.addEventListener('click', function() {
                const row = this.closest('tr');
                cancelEdit(row);
            });
        });
        
        // Delete button click handler
        document.querySelectorAll('.delete-btn').forEach(button => {
            button.addEventListener('click', function(e) {
                e.stopPropagation(); // Prevent event bubbling
                
                const examId = this.getAttribute('data-exam-id');
                const studentName = this.getAttribute('data-student-name');
                const courseName = this.getAttribute('data-course-name');
                
                showDeleteModal(examId, studentName, courseName);
            });
        });
    }
    
    function enableEditMode(row, examId) {
        // Show edit fields
        row.querySelector('.marks-display').style.display = 'none';
        row.querySelector('.marks-edit').style.display = 'block';
        row.querySelector('.status-display').style.display = 'none';
        row.querySelector('.status-edit').style.display = 'block';
        
        // Show/hide buttons
        row.querySelector('.edit-btn').style.display = 'none';
        row.querySelector('.delete-btn').style.display = 'none';
        row.querySelector('.save-btn').style.display = 'inline-flex';
        row.querySelector('.cancel-btn').style.display = 'inline-flex';
        row.querySelector('.btn-primary').style.display = 'none';
    }
    
    function cancelEdit(row) {
        // Hide edit fields
        row.querySelector('.marks-display').style.display = '';
        row.querySelector('.marks-edit').style.display = 'none';
        row.querySelector('.status-display').style.display = '';
        row.querySelector('.status-edit').style.display = 'none';
        
        // Show/hide buttons
        row.querySelector('.edit-btn').style.display = 'inline-flex';
        row.querySelector('.delete-btn').style.display = 'inline-flex';
        row.querySelector('.save-btn').style.display = 'none';
        row.querySelector('.cancel-btn').style.display = 'none';
        row.querySelector('.btn-primary').style.display = 'inline-flex';
    }
    
    function saveChanges(row, examId) {
        const obtMarksInput = row.querySelector('.marks-edit input');
        const statusSelect = row.querySelector('.status-edit select');
        
        const obtMarks = parseInt(obtMarksInput.value);
        const totalMarks = parseInt(row.getAttribute('data-total-marks'));
        const status = statusSelect.value;
        
        // Validate marks
        if (isNaN(obtMarks) || obtMarks < 0 || obtMarks > totalMarks) {
            alert('Please enter valid marks between 0 and ' + totalMarks);
            obtMarksInput.focus();
            return;
        }
        
        // Show loading state
        const saveBtn = row.querySelector('.save-btn');
        const originalText = saveBtn.innerHTML;
        saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
        saveBtn.disabled = true;
        
        // Create and submit form
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'controller.jsp';
        
        const fields = {
            'page': 'results',
            'operation': 'edit',
            'eid': examId,
            'obtMarks': obtMarks,
            'totalMarks': totalMarks,
            'status': status
        };
        
        for (const [name, value] of Object.entries(fields)) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = name;
            input.value = value;
            form.appendChild(input);
        }
        
        document.body.appendChild(form);
        form.submit();
    }
    
    function showDeleteModal(examId, studentName, courseName) {
        console.log('showDeleteModal called with:', {
            examId: examId,
            studentName: studentName,
            courseName: courseName
        });
        
        deleteExamId = examId;
        
        const modal = document.getElementById('deleteModal');
        if (!modal) {
            console.error('Modal element not found!');
            alert('Error: Modal not found. Please refresh the page.');
            return;
        }

        const modalMessage = document.getElementById('deleteModalMessage');
        if (!modalMessage) {
            console.error('Modal message element not found!');
            alert('Error: Modal message element not found.');
            return;
        }

        // Clean up text for display - handle empty/null values
        const cleanStudentName = studentName && studentName !== 'null' ? 
            escapeHtml(studentName.trim()) : 'Unknown Student';
        const cleanCourseName = courseName && courseName !== 'null' ? 
            escapeHtml(courseName.trim()) : 'Unknown Course';
        
        console.log('Cleaned values:', {cleanStudentName, cleanCourseName});

        modalMessage.innerHTML =
            '<div style="text-align: left;">' +
                '<p>Are you sure you want to delete the following exam result?</p>' +
                '<div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 15px 0;">' +
                    '<p><strong>Student:</strong> ' + cleanStudentName + '</p>' +
                    '<p><strong>Course:</strong> ' + cleanCourseName + '</p>' +
                    '<p><strong>Exam ID:</strong> ' + examId + '</p>' +
                '</div>' +
                '<p style="color: #dc3545; font-weight: bold;">' +
                    '<i class="fas fa-exclamation-triangle"></i> ' +
                    'This action will permanently delete:<br>' +
                    '? The exam record<br>' +
                    '? All related answers<br>' +
                    '? This cannot be undone!' +
                '</p>' +
            '</div>';

        modal.style.display = 'block';
        
        // Add fade-in animation
        modal.style.opacity = 0;
        modal.style.transition = 'opacity 0.3s';
        setTimeout(() => {
            modal.style.opacity = 1;
        }, 10);
    }

    // Helper function to escape HTML special characters
    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Optional: AJAX function to fetch exam details
    function fetchExamDetails(examId) {
        fetch(`controller.jsp?page=results&operation=getDetails&eid=${examId}`)
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update modal with additional details
                    updateModalWithDetails(data.details);
                }
            })
            .catch(error => {
                console.error('Error fetching exam details:', error);
            });
    }
    
    function closeDeleteModal() {
        const modal = document.getElementById('deleteModal');
        if (modal) {
            modal.style.display = 'none';
            modal.style.opacity = 0;
        }
        deleteExamId = null;
        deleteStudentName = null;
        deleteCourseName = null;
    }
    
    function confirmDelete() {
        if (!deleteExamId) {
            alert('No exam selected for deletion.');
            return;
        }
        
        console.log('Confirming delete for exam ID:', deleteExamId);
        
        // Show loading state
        const deleteBtn = document.querySelector('#deleteModal .modal-footer .btn-danger');
        if (deleteBtn) {
            const originalText = deleteBtn.innerHTML;
            deleteBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
            deleteBtn.disabled = true;
            
            // Revert button after 5 seconds if something goes wrong
            setTimeout(() => {
                deleteBtn.innerHTML = originalText;
                deleteBtn.disabled = false;
            }, 5000);
        }

        // Submit delete request
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'controller.jsp';

        // Add CSRF token
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'csrf_token';
        csrfInput.value = csrfToken;
        form.appendChild(csrfInput);

        const pageInput = document.createElement('input');
        pageInput.type = 'hidden';
        pageInput.name = 'page';
        pageInput.value = 'results';
        form.appendChild(pageInput);

        const operationInput = document.createElement('input');
        operationInput.type = 'hidden';
        operationInput.name = 'operation';
        operationInput.value = 'delete';
        form.appendChild(operationInput);

        const examIdInput = document.createElement('input');
        examIdInput.type = 'hidden';
        examIdInput.name = 'eid';
        examIdInput.value = deleteExamId;
        form.appendChild(examIdInput);

        console.log('Submitting delete form for exam ID:', deleteExamId);
        document.body.appendChild(form);
        form.submit();
    }

    // Apply all filters
    function applyFilters() {
        const nameFilter = document.getElementById('filterName').value.toLowerCase();
        const courseFilter = document.getElementById('filterCourse').value.toLowerCase();
        const statusFilter = document.getElementById('filterStatus').value.toLowerCase();
        const dateFrom = document.getElementById('filterDateFrom').value;
        const dateTo = document.getElementById('filterDateTo').value;
        const globalSearch = document.getElementById('searchBox').value.toLowerCase();
        
        const rows = document.querySelectorAll('#resultsTableBody tr.result-row');
        let visibleCount = 0;
        
        rows.forEach(row => {
            let showRow = true;
            
            // Name filter
            if (nameFilter && !row.getAttribute('data-name').includes(nameFilter)) {
                showRow = false;
            }
            
            // Course filter
            if (courseFilter && !row.getAttribute('data-course').includes(courseFilter)) {
                showRow = false;
            }
            
            // Status filter
            if (statusFilter) {
                const rowStatus = row.getAttribute('data-status');
                if (statusFilter === 'terminated') {
                    if (rowStatus !== 'terminated') showRow = false;
                } else if (rowStatus !== statusFilter) {
                    showRow = false;
                }
            }
            
            // Date range filter
            if (dateFrom || dateTo) {
                const rowDate = new Date(row.getAttribute('data-date'));
                if (dateFrom) {
                    const fromDate = new Date(dateFrom);
                    if (rowDate < fromDate) showRow = false;
                }
                if (dateTo) {
                    const toDate = new Date(dateTo);
                    toDate.setHours(23, 59, 59, 999);
                    if (rowDate > toDate) showRow = false;
                }
            }
            
            // Global search (search across all visible text)
            if (globalSearch) {
                const rowText = row.textContent.toLowerCase();
                if (!rowText.includes(globalSearch)) {
                    showRow = false;
                }
            }
            
            // Show/hide row
            row.style.display = showRow ? '' : 'none';
            if (showRow) visibleCount++;
        });
        
        updateResultsCount(visibleCount);
    }
    
    function setQuickFilter(filterType) {
        resetAllFilters();
        
        switch(filterType) {
            case 'pass':
                document.getElementById('filterStatus').value = 'Pass';
                applyFilters();
                break;
            case 'fail':
                document.getElementById('filterStatus').value = 'Fail';
                applyFilters();
                break;
            case 'high':
                const rowsHigh = document.querySelectorAll('#resultsTableBody tr.result-row');
                rowsHigh.forEach(row => {
                    const percentage = parseFloat(row.getAttribute('data-percentage'));
                    if (percentage < 80) {
                        row.style.display = 'none';
                    }
                });
                updateResultsCount();
                break;
            case 'low':
                const rowsLow = document.querySelectorAll('#resultsTableBody tr.result-row');
                rowsLow.forEach(row => {
                    const percentage = parseFloat(row.getAttribute('data-percentage'));
                    if (percentage > 50) {
                        row.style.display = 'none';
                    }
                });
                updateResultsCount();
                break;
        }
        
        // Add active class to the clicked button
        const buttons = document.querySelectorAll('.quick-filter-btn');
        buttons.forEach(btn => {
            if (btn.textContent.includes(filterType === 'pass' ? 'Pass Only' : 
                                        filterType === 'fail' ? 'Fail Only' :
                                        filterType === 'high' ? 'High Scores' : 'Low Scores')) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
    }
    
    // Reset all filters
    function resetAllFilters() {
        document.getElementById('filterName').value = '';
        document.getElementById('filterCourse').value = '';
        document.getElementById('filterStatus').value = '';
        document.getElementById('searchBox').value = '';
        
        // Reset date filters to default (last 30 days to today)
        const today = new Date().toISOString().split('T')[0];
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        
        document.getElementById('filterDateTo').value = today;
        document.getElementById('filterDateFrom').value = thirtyDaysAgo.toISOString().split('T')[0];
        
        // Show all rows
        document.querySelectorAll('#resultsTableBody tr.result-row').forEach(row => {
            row.style.display = '';
        });
        
        updateResultsCount();
    }
    
    // Update results count
    function updateResultsCount(visibleCount = null) {
        const totalRows = document.querySelectorAll('#resultsTableBody tr.result-row').length;
        if (visibleCount === null) {
            visibleCount = document.querySelectorAll('#resultsTableBody tr.result-row:not([style*="display: none"])').length;
        }
        
        document.getElementById('resultsCount').textContent = visibleCount;
        document.getElementById('visibleCount').textContent = visibleCount;
        document.getElementById('totalCount').textContent = totalRows;
    }
    
    // Sort table by column
    function sortTable(columnIndex) {
        const tbody = document.getElementById('resultsTableBody');
        const rows = Array.from(tbody.querySelectorAll('tr.result-row:not([style*="display: none"])'));
        
        // Update sort indicators
        const headers = document.querySelectorAll('#resultsTable thead th');
        headers.forEach((header, index) => {
            const indicator = header.querySelector('.sort-indicator');
            indicator.innerHTML = '';
            if (index === columnIndex) {
                if (currentSortColumn === columnIndex) {
                    sortDirection *= -1;
                } else {
                    sortDirection = 1;
                    currentSortColumn = columnIndex;
                }
                indicator.innerHTML = sortDirection === 1 ? '?' : '?';
            }
        });
        
        // Sort rows
        rows.sort((a, b) => {
            let aValue, bValue;
            const aCell = a.cells[columnIndex];
            const bCell = b.cells[columnIndex];
            
            switch(columnIndex) {
                case 0: // Name
                case 1: // Student ID
                case 2: // Email
                case 4: // Course
                    aValue = aCell.textContent.toLowerCase();
                    bValue = bCell.textContent.toLowerCase();
                    break;
                case 3: // Date
                    aValue = new Date(a.getAttribute('data-date'));
                    bValue = new Date(b.getAttribute('data-date'));
                    break;
                case 6: // Marks
                    const aMarks = a.getAttribute('data-obt-marks');
                    const bMarks = b.getAttribute('data-obt-marks');
                    aValue = parseInt(aMarks);
                    bValue = parseInt(bMarks);
                    break;
                case 7: // Status
                    const statusOrder = { 'pass': 1, 'fail': 2, 'terminated': 3 };
                    aValue = statusOrder[a.getAttribute('data-status')] || 4;
                    bValue = statusOrder[b.getAttribute('data-status')] || 4;
                    break;
                case 8: // Percentage
                    aValue = parseFloat(a.getAttribute('data-percentage'));
                    bValue = parseFloat(b.getAttribute('data-percentage'));
                    break;
                default:
                    aValue = aCell.textContent;
                    bValue = bCell.textContent;
            }
            
            // Compare values
            if (aValue < bValue) return -1 * sortDirection;
            if (aValue > bValue) return 1 * sortDirection;
            return 0;
        });
        
        // Reorder rows in DOM
        rows.forEach(row => tbody.appendChild(row));
    }
    
    // Close modal when clicking outside
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('deleteModal');
        if (event.target === modal) {
            closeDeleteModal();
        }
    });
    
    // Add keyboard support for modal
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeDeleteModal();
        }
    });
    
    // Debug function to check button data attributes
    function debugButtonData() {
        document.querySelectorAll('.delete-btn').forEach((button, index) => {
            console.log(`Button ${index}:`, {
                examId: button.getAttribute('data-exam-id'),
                studentName: button.getAttribute('data-student-name'),
                courseName: button.getAttribute('data-course-name'),
                innerHTML: button.innerHTML
            });
        });
    }
    
    // Call debug function on load
    setTimeout(debugButtonData, 1000);
</script>

<div id="deleteConfirmationModal" style="display:none; position:fixed; z-index:1001; left:0; top:0; width:100%; height:100%; overflow:auto; background-color:rgba(0,0,0,0.4);">
  <div style="background-color:#fefefe; margin:15% auto; padding:20px; border:1px solid #888; width:80%; max-width:500px; border-radius:8px; box-shadow:0 4px 8px 0 rgba(0,0,0,0.2),0 6px 20px 0 rgba(0,0,0,0.19);">
    <span onclick="closeModal()" style="color:#aaa; float:right; font-size:28px; font-weight:bold; cursor:pointer;">&times;</span>
    <h2>Confirm Deletion</h2>
    <p>Are you sure you want to delete the exam result for <strong id="modalStudentName"></strong> in the course <strong id="modalCourseName"></strong> (Exam ID: <strong id="modalExamId"></strong>)?</p>
    <p>This action cannot be undone.</p>
    <div style="text-align:right;">
      <button onclick="closeModal()" class="btn btn-secondary">Cancel</button>
      <button id="confirmDeleteBtn" class="btn btn-danger">Delete</button>
    </div>
  </div>
</div>