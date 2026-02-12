<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.UUID"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>

<%! 
// Function to escape HTML characters for safe display
public String escapeHtml(String input) {
    if (input == null) return "";
    return input.replace("&", "&amp;")
               .replace("<", "&lt;")
               .replace(">", "&gt;")
               .replace("\"", "&quot;")
               .replace("'", "&#x27;");
}
%>

<%
    String csrf_token = UUID.randomUUID().toString();
    session.setAttribute("csrf_token", csrf_token);
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

    // Get ALL exam results (for admin view)
    ArrayList<Exams> allExamResults = pDAO.getAllExamResults();
%>

<!-- Add CSS Styles -->

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
        gap: 2px;
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

    .action-buttons {
    display: flex;
    align-items: center;
    gap: 2px;
    flex-wrap: nowrap;
}

.action-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 3px;

    font-size: 9px;
    height: 24px;
    min-width: 50px;

    padding: 0 9px;
    border-radius: 6px;

    white-space: nowrap;
}

.action-btn i {
    font-size: 9px;
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
         
            <!-- Hidden Form for Bulk Delete -->
        <form id="bulkDeleteForm" action="controller.jsp" method="post" style="display: none;">
            <input type="hidden" name="page" value="admin-results">
            <input type="hidden" name="operation" value="bulk_delete">
            <input type="hidden" name="csrf_token" value="<%= csrf_token %>">
        </form>

        <!-- Scroll to Top Button -->
        <button class="scroll-to-top" id="scrollToTopBtn" title="Scroll to top">
            <i class="fas fa-arrow-up"></i>
        </button>
                        
            <% if (request.getParameter("eid") == null) { %>
                <div style="overflow-x:auto;">
                    <table class="results-table" id="resultsTable">
                        <thead>
                            <tr>
                                <th><input type="checkbox" id="selectAll" class="select-all-checkbox"></th>
                                <th onclick="sortTable(1)">Name <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(2)">Student ID <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(3)">Email <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(4)">Date <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(5)">Course <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(6)">Time <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(7)">Marks <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(8)">Status <span class="sort-indicator"></span></th>
                                <th onclick="sortTable(9)">% <span class="sort-indicator"></span></th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        
                        <tbody id="resultsTableBody">
                            <% 
                                if (allExamResults.isEmpty()) { 
                            %>
                            <tr>
                                <td colspan="11" class="no-results">
                                    <i class="fas fa-info-circle"></i> No results found
                                </td>
                            </tr>
                            <% 
                                } else { 
                                    for (Exams e : allExamResults) {
                                        double percentage = (e.gettMarks() > 0) ? (double)e.getObtMarks() / e.gettMarks() * 100 : 0;
                                        String status = (e.getStatus() != null) ? e.getStatus() : "Terminated";
                                        String fullName = (e.getFullName() != null && !e.getFullName().trim().isEmpty()) ? e.getFullName() : "N/A";
                                        int examId = e.getExamId();
                                        String studentId = e.getUserName() != null ? e.getUserName() : "N/A";
                                        String studentEmail = e.getEmail() != null ? e.getEmail() : "N/A";
                                        String courseName = e.getcName() != null ? e.getcName() : "N/A";
                                        String examDate = e.getDate() != null ? e.getDate() : "N/A";
                            %>
                            <tr class="result-row" 
                                data-exam-id="<%= examId %>"
                                data-index="<%= examId %>"
                                data-name="<%= fullName.toLowerCase() %>"
                                data-id="<%= studentId.toLowerCase() %>"
                                data-email="<%= studentEmail.toLowerCase() %>"
                                data-date="<%= examDate %>"
                                data-course="<%= courseName.toLowerCase() %>"
                                data-time="<%= e.getStartTime() + " - " + e.getEndTime() %>"
                                data-obt-marks="<%= e.getObtMarks() %>"
                                data-total-marks="<%= e.gettMarks() %>"
                                data-marks="<%= e.getObtMarks() + "/" + e.gettMarks() %>"
                                data-percentage="<%= percentage %>"
                                data-status="<%= status.toLowerCase() %>">
                                <td>
                                    <input type="checkbox" name="examIds" value="<%= examId %>" 
                                           class="record-checkbox" onchange="updateBulkDeleteButton()">
                                </td>
                                <td><%= fullName %></td>
                                <td><%= studentId %></td>
                                <td><%= studentEmail %></td>
                                <td><%= examDate %></td>
                                <td><%= courseName %></td>
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
                                    <% if ("Pass".equals(status)) { %>
                                        <span class="badge badge-success status-display">
                                            <i class="fas fa-check-circle"></i> <%= status %>
                                        </span>
                                    <% } else if ("Fail".equals(status)) { %>
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
                                            <option value="Pass" <%= "Pass".equals(status) ? "selected" : "" %>>Pass</option>
                                            <option value="Fail" <%= "Fail".equals(status) ? "selected" : "" %>>Fail</option>
                                            <option value="Terminated" <%= "Terminated".equals(status) ? "selected" : "" %>>Terminated</option>
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge badge-info"><%= String.format("%.0f", percentage) %>%</span>
                                </td>
                                <td>
                                <div class="action-buttons">
                                    <button class="btn btn-secondary action-btn edit-btn" data-exam-id="<%= examId %>">
                                        <i class="fas fa-edit"></i><span>Edit</span>
                                    </button>


                                    <button class="btn btn-success action-btn save-btn" data-exam-id="<%= examId %>" style="display:none;">
                                        <i class="fas fa-save"></i><span>Save</span>
                                    </button>

                                    <button class="btn btn-warning action-btn cancel-btn" style="display:none;">
                                        <i class="fas fa-times"></i><span>Cancel</span>
                                    </button>

                                    <a class="btn btn-primary action-btn" href="adm-page.jsp?pgprt=5&eid=<%= examId %>">
                                        <i class="fas fa-eye"></i><span>Details</span>
                                    </a>

                                     <button class="btn btn-danger action-btn delete-btn single-delete-btn"
                                            type="button"
                                            data-exam-id="<%= examId %>"
                                            data-student-name="<%= fullName %>"
                                            data-course-name="<%= courseName %>"
                                            data-student-email="<%= studentEmail %>"
                                            data-student-id="<%= studentId %>"
                                            data-marks="<%= e.getObtMarks() %>/<%= e.gettMarks() %>"
                                            data-percentage="<%= String.format("%.2f", percentage) %>%"
                                            data-status="<%= status %>"
                                            data-date="<%= examDate %>">
                                        <i class="fas fa-trash"></i>
                                    </button>
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
                                        <td><%= escapeHtml(a.getAnswer() != null ? a.getAnswer() : "No Answer") %></td>
                                        <td><%= escapeHtml(a.getCorrectAnswer() != null ? a.getCorrectAnswer() : "N/A") %></td>
                                        <td>
                                            <% if ("correct".equals(a.getStatus())) { %>
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

<!-- FLOATING DELETE BUTTON - MOVED OUTSIDE SCROLLING CONTAINER -->
<div id="floatingDeleteBtn" class="floating-delete-btn inactive">
    <button type="button" class="btn btn-danger" onclick="handleBulkDelete()">
        <i class="fas fa-trash"></i> Delete Selected (<span id="selectedCountBadge">0</span>)
    </button>
</div>

<!-- Scroll to Top Button -->
<button class="scroll-to-top" id="scrollToTopBtn" title="Scroll to top">
    <i class="fas fa-arrow-up"></i>
</button>
<div id="confirmationModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle"><i class="fas fa-exclamation-triangle"></i> Confirmation</h3>
            <span class="close-modal" onclick="hideModal()">&times;</span>
        </div>
        <div class="modal-body">
            <p id="modalMessage"></p>
        </div>
        <div class="modal-footer">
            <button id="cancelButton" class="btn btn-outline" onclick="hideModal()">Cancel</button>
            <button id="confirmButton" class="btn btn-danger" onclick="confirmAction()">Delete</button>
        </div>
    </div>
</div>

<style>
/* Modal Styles */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
    animation: fadeIn 0.3s;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-content {
    background-color: #fff;
    margin: 10% auto;
    padding: 0;
    border-radius: 8px;
    width: 90%;
    max-width: 500px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    animation: slideDown 0.3s;
}

@keyframes slideDown {
    from { transform: translateY(-50px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
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

/* Floating delete button - PROFESSIONAL VERSION */
.floating-delete-btn {
    position: fixed;
    bottom: 80px;
    right: 30px;
    z-index: 9999;
    display: flex;
    animation: floatIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    box-shadow: 0 8px 20px rgba(220, 38, 38, 0.35);
    border: none;
    border-radius: 50px;
    background: linear-gradient(145deg, #dc2626, #b91c1c);
    padding: 0;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    transform-origin: center;
    will-change: transform, opacity, box-shadow;
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.floating-delete-btn button {
    border: none;
    border-radius: 50px;
    background: transparent;
    color: white;
    transition: all 0.2s ease;
    cursor: pointer;
    font-weight: 600;
    white-space: nowrap;
    padding: 14px 28px;
    font-size: 15px;
    letter-spacing: 0.5px;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: inset 0 1px 2px rgba(255, 255, 255, 0.3);
}

.floating-delete-btn button i {
    font-size: 16px;
    filter: drop-shadow(0 2px 2px rgba(0, 0, 0, 0.2));
}

.floating-delete-btn:hover {
    transform: translateY(-4px) scale(1.02);
    box-shadow: 0 12px 28px rgba(220, 38, 38, 0.45);
    background: linear-gradient(145deg, #ef4444, #dc2626);
}

.floating-delete-btn:active {
    transform: translateY(-2px) scale(0.98);
    box-shadow: 0 6px 16px rgba(220, 38, 38, 0.4);
}

.floating-delete-btn.inactive {
    opacity: 0;
    transform: translateY(20px) scale(0.9);
    pointer-events: none;
    visibility: hidden;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.floating-delete-btn.active {
    opacity: 1;
    transform: translateY(0) scale(1);
    pointer-events: auto;
    visibility: visible;
}

/* Scroll to Top Button - Professional Version */
.scroll-to-top {
    position: fixed;
    bottom: 30px;
    right: 30px;
    z-index: 9998;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(145deg, var(--primary-blue), var(--secondary-blue));
    color: white;
    border: none;
    border-radius: 50px;
    width: 50px;
    height: 50px;
    box-shadow: 0 4px 15px rgba(9, 41, 77, 0.25);
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    opacity: 0;
    transform: translateY(20px) scale(0.9);
    visibility: hidden;
    border: 1px solid rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
}

.scroll-to-top.show {
    opacity: 1;
    transform: translateY(0) scale(1);
    visibility: visible;
}

.scroll-to-top:hover {
    transform: translateY(-4px) scale(1.05);
    box-shadow: 0 8px 25px rgba(9, 41, 77, 0.35);
    background: linear-gradient(145deg, var(--secondary-blue), var(--primary-blue));
}

.scroll-to-top:active {
    transform: translateY(-2px) scale(0.98);
}

.scroll-to-top i {
    font-size: 22px;
    filter: drop-shadow(0 2px 2px rgba(0, 0, 0, 0.2));
}
    @keyframes floatIn {
    0% {
        opacity: 0;
        transform: translateY(40px) scale(0.8);
    }
    100% {
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

/* Responsive adjustments for floating buttons */
@media (max-width: 768px) {
    .floating-delete-btn {
        bottom: 70px;
        right: 20px;
    }
    
    .floating-delete-btn button {
        padding: 12px 24px;
        font-size: 14px;
    }
    
    .scroll-to-top {
        bottom: 20px;
        right: 20px;
        width: 45px;
        height: 45px;
    }
    
    .scroll-to-top i {
        font-size: 20px;
    }
}

@media (max-width: 480px) {
    .floating-delete-btn {
        bottom: 60px;
        right: 15px;
        left: 15px;
        width: auto;
    }
    
    .floating-delete-btn button {
        width: 100%;
        justify-content: center;
        padding: 12px 20px;
    }
    
    .scroll-to-top {
        bottom: 15px;
        right: 15px;
        width: 40px;
        height: 40px;
    }
}

/* Remove any old bulkDeleteBtn styles if they exist */
#bulkDeleteBtn {
    display: none !important;
}
</style>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- JavaScript for enhanced functionality -->
<script>
    // Global variables
    let currentSortColumn = -1;
    let sortDirection = 1;
    const csrf_token = '<%= session.getAttribute("csrf_token") %>';

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
        
        // Initialize functionality
        initializeCheckboxHandlers();
        initializeButtonHandlers();
        
        // Apply initial filters
        applyFilters();
    });

    function initializeCheckboxHandlers() {
        // Select All functionality
        const selectAll = document.getElementById('selectAll');
        if (selectAll) {
            selectAll.addEventListener('change', function() {
                const checkboxes = document.querySelectorAll('.record-checkbox');
                const isChecked = this.checked;
                checkboxes.forEach(function(checkbox) {
                    checkbox.checked = isChecked;
                });
                updateBulkDeleteButton();
            });
        }
        
        // Individual checkbox handling
        document.addEventListener('change', function(e) {
            if (e.target.classList.contains('record-checkbox')) {
                updateBulkDeleteButton();
                
                // Update select all state
                const selectAll = document.getElementById('selectAll');
                if (selectAll) {
                    const totalCheckboxes = document.querySelectorAll('.record-checkbox').length;
                    const checkedCheckboxes = document.querySelectorAll('.record-checkbox:checked').length;
                    
                    selectAll.checked = checkedCheckboxes === totalCheckboxes;
                    selectAll.indeterminate = checkedCheckboxes > 0 && checkedCheckboxes < totalCheckboxes;
                }
            }
        });
    }

    function initializeButtonHandlers() {
        // Edit button click handler
        document.querySelectorAll('.edit-btn').forEach(function(button) {
            button.addEventListener('click', function() {
                const examId = this.getAttribute('data-exam-id');
                const row = this.closest('tr');
                enableEditMode(row, examId);
            });
        });
        
        // Save button click handler
        document.querySelectorAll('.save-btn').forEach(function(button) {
            button.addEventListener('click', function() {
                const examId = this.getAttribute('data-exam-id');
                const row = this.closest('tr');
                saveChanges(row, examId);
            });
        });
        
        // Cancel button click handler
        document.querySelectorAll('.cancel-btn').forEach(function(button) {
            button.addEventListener('click', function() {
                const row = this.closest('tr');
                cancelEdit(row);
            });
        });
        
        // Single delete button handler - FIXED
        document.querySelectorAll('.single-delete-btn').forEach(function(button) {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();

                const examId = this.getAttribute('data-exam-id');
                const studentName = this.getAttribute('data-student-name') || 'N/A';
                const courseName = this.getAttribute('data-course-name') || 'N/A';
                const studentEmail = this.getAttribute('data-student-email') || 'N/A';
                const studentId = this.getAttribute('data-student-id') || 'N/A';
                const marks = this.getAttribute('data-marks') || 'N/A';
                const percentage = this.getAttribute('data-percentage') || 'N/A';
                const status = this.getAttribute('data-status') || 'N/A';
                const date = this.getAttribute('data-date') || 'N/A';

                // Validate data
                if (!examId || examId === 'undefined' || examId === 'null') {
                    showAlert('Error: Could not retrieve exam ID. Please try again.', 'error');
                    return;
                }

                // Create message using string concatenation
                const message = '<div style="text-align: center; max-width: 500px;">' +
                               '<h4 style="color: #dc3545; margin-bottom: 15px;">' +
                               '<i class="fas fa-exclamation-triangle"></i> Delete Exam Result' +
                               '</h4>' +
                               '<p style="margin-bottom: 15px; font-weight: 500;">Are you sure you want to delete this exam result?</p>' +
                               '<div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 15px;">' +
                               '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">' +
                               '<div><strong>Student:</strong></div>' +
                               '<div>' + studentName + '</div>' +
                               '<div><strong>Student ID:</strong></div>' +
                               '<div>' + studentId + '</div>' +
                               '<div><strong>Email:</strong></div>' +
                               '<div>' + studentEmail + '</div>' +
                               '<div><strong>Course:</strong></div>' +
                               '<div>' + courseName + '</div>' +
                               '<div><strong>Date:</strong></div>' +
                               '<div>' + date + '</div>' +
                            //    '<div><strong>Marks:</strong></div>' +
                            //    '<div>' + marks + '</div>' +
                            //    '<div><strong>Percentage:</strong></div>' +
                            //    '<div>' + percentage + '</div>' +
                            //    '<div><strong>Status:</strong></div>' +
                            //    '<div>' + status + '</div>' +
                            //    '<div><strong>Exam ID:</strong></div>' +
                            //    '<div>' + examId + '</div>' +
                               '</div>' +
                               '</div>' +
                               '<p style="color: #dc3545; font-weight: bold;">' +
                               '<i class="fas fa-exclamation-circle"></i> This action cannot be undone!' +
                               '</p>' +
                               '</div>';

                showConfirmModal(message, '', function() {
                    // Callback function when confirmed
                    performSingleDelete(examId);
                });
            });
        });
    }

    // Bulk delete handling
    function handleBulkDelete() {
        const selectedCheckboxes = document.querySelectorAll('.record-checkbox:checked');
        const selectedCount = selectedCheckboxes.length;
        
        if (selectedCount === 0) {
            showAlert('Please select at least one exam result to delete.', 'warning');
            return;
        }
        
        // Get selected records details
        const selectedDetails = [];
        selectedCheckboxes.forEach(function(checkbox) {
            const row = checkbox.closest('tr');
            const studentName = row.cells[1].textContent;
            const courseName = row.cells[5].textContent;
            const examId = checkbox.value;
            selectedDetails.push(studentName + ' - ' + courseName + ' (ID: ' + examId + ')');
        });
        
        // Build list items manually
        let detailsList = '';
        for (let i = 0; i < selectedDetails.length; i++) {
            detailsList += '<li>' + selectedDetails[i] + '</li>';
        }
        
        // Create message using string concatenation
        const message = '<div style="text-align: left; max-width: 500px;">' +
                       '<h4 style="color: #dc3545; margin-bottom: 15px;">' +
                       '<i class="fas fa-exclamation-triangle"></i> Delete Multiple Exam Results' +
                       '</h4>' +
                       '<p style="margin-bottom: 15px; font-weight: 500;">' +
                       'Are you sure you want to delete <strong>' + selectedCount + '</strong> selected exam result(s)?' +
                       '</p>' +
                       '<div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 15px; max-height: 200px; overflow-y: auto;">' +
                       '<strong>Selected Records:</strong>' +
                       '<ul style="margin-top: 10px; padding-left: 20px;">' +
                       detailsList +
                       '</ul>' +
                       '</div>' +
                       '<p style="color: #dc3545; font-weight: bold;">' +
                       '<i class="fas fa-exclamation-circle"></i> This action cannot be undone!' +
                       '</p>' +
                       '</div>';
        
        showConfirmModal(message, 'Delete Multiple Records', function() {
            // Callback function when confirmed
            performBulkDelete();
        });
    }

    // Single delete function
    function performSingleDelete(examId) {
        // Show loading indicator
        showAlert('Deleting exam result...', 'info');
        
        // Create hidden form and submit it
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'controller.jsp';
        form.style.display = 'none';
        
        // Add page parameter
        const pageInput = document.createElement('input');
        pageInput.type = 'hidden';
        pageInput.name = 'page';
        pageInput.value = 'admin-results';
        form.appendChild(pageInput);
        
        // Add CSRF token
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'csrf_token';
        csrfInput.value = csrf_token;
        form.appendChild(csrfInput);
        
        // Add operation
        const operationInput = document.createElement('input');
        operationInput.type = 'hidden';
        operationInput.name = 'operation';
        operationInput.value = 'delete_result';
        form.appendChild(operationInput);
        
        // Add exam ID
        const examIdInput = document.createElement('input');
        examIdInput.type = 'hidden';
        examIdInput.name = 'eid';
        examIdInput.value = examId;
        form.appendChild(examIdInput);
        
        // Add to document and submit
        document.body.appendChild(form);
        form.submit();
    }

    // Bulk delete function
    function performBulkDelete() {
        const selectedCheckboxes = document.querySelectorAll('.record-checkbox:checked');
        
        if (selectedCheckboxes.length === 0) {
            showAlert('No records selected for deletion.', 'warning');
            return;
        }
        
        // Show loading indicator
        showAlert('Deleting ' + selectedCheckboxes.length + ' exam result(s)...', 'info');
        
        // Use the existing hidden form
        const form = document.getElementById('bulkDeleteForm');
        
        // Add page parameter if not already present
        const existingPageInput = form.querySelector('input[name="page"]');
        if (!existingPageInput) {
            const pageInput = document.createElement('input');
            pageInput.type = 'hidden';
            pageInput.name = 'page';
            pageInput.value = 'admin-results';
            form.appendChild(pageInput);
        }
        
        // Clear existing examIds inputs (keep CSRF token and page parameter)
        const existingInputs = form.querySelectorAll('input[name="examIds"]');
        existingInputs.forEach(function(input) {
            form.removeChild(input);
        });
        
        // Add selected exam IDs
        selectedCheckboxes.forEach(function(checkbox) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'examIds';
            input.value = checkbox.value;
            form.appendChild(input);
        });
        
        // Submit form
        form.submit();
    }

    function updateBulkDeleteButton() {
        const selectedCheckboxes = document.querySelectorAll('.record-checkbox:checked');
        const bulkDeleteBtn = document.getElementById('bulkDeleteBtn');
        const selectedCount = document.getElementById('selectedCount');
        
        const selectedCountNum = selectedCheckboxes.length;
        selectedCount.textContent = selectedCountNum;
        
        // Show/hide bulk delete button based on selection
        if (selectedCountNum > 0) {
            bulkDeleteBtn.style.display = 'inline-block';
            bulkDeleteBtn.disabled = false;
        } else {
            bulkDeleteBtn.style.display = 'none';
            bulkDeleteBtn.disabled = true;
        }
        
        // Update select all checkbox state
        const selectAll = document.getElementById('selectAll');
        if (selectAll) {
            const totalCheckboxes = document.querySelectorAll('.record-checkbox').length;
            selectAll.checked = selectedCountNum === totalCheckboxes && totalCheckboxes > 0;
            selectAll.indeterminate = selectedCountNum > 0 && selectedCountNum < totalCheckboxes;
        }
    }

    // Helper functions
    function showAlert(message, type) {
        if (!type) type = 'error';
        
        // Create alert element
        const alertDiv = document.createElement('div');
        alertDiv.className = 'custom-alert ' + type;
        
        // Build icon HTML based on type
        let iconClass = 'fa-exclamation-triangle';
        if (type === 'error') {
            iconClass = 'fa-exclamation-circle';
        } else if (type === 'info') {
            iconClass = 'fa-info-circle';
        } else if (type === 'success') {
            iconClass = 'fa-check-circle';
        } else if (type === 'warning') {
            iconClass = 'fa-exclamation-triangle';
        }
        
        // Create alert content
        const iconHtml = '<i class="fas ' + iconClass + '"></i>';
        const contentHtml = '<div style="display: flex; align-items: center; gap: 10px;">' + 
                           iconHtml + 
                           '<span>' + message + '</span>' +
                           '</div>' +
                           '<button onclick="this.parentElement.remove()" style="background: none; border: none; color: inherit; cursor: pointer;">' +
                           '<i class="fas fa-times"></i>' +
                           '</button>';
        
        alertDiv.innerHTML = contentHtml;
        
        // Style the alert
        let bgColor = '#fff3cd';
        let textColor = '#856404';
        let borderColor = '#ffeaa7';
        
        if (type === 'error') {
            bgColor = '#f8d7da';
            textColor = '#721c24';
            borderColor = '#f5c6cb';
        } else if (type === 'info') {
            bgColor = '#d1ecf1';
            textColor = '#0c5460';
            borderColor = '#bee5eb';
        } else if (type === 'success') {
            bgColor = '#d4edda';
            textColor = '#155724';
            borderColor = '#c3e6cb';
        }
        
        alertDiv.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; ' +
                               'background: ' + bgColor + '; color: ' + textColor + '; ' +
                               'border: 1px solid ' + borderColor + '; border-radius: 5px; ' +
                               'display: flex; align-items: center; justify-content: space-between; ' +
                               'min-width: 300px; max-width: 400px; z-index: 9999; ' +
                               'animation: slideInRight 0.3s ease-out;';
        
        document.body.appendChild(alertDiv);
        
        // Auto-remove after 5 seconds
        setTimeout(function() {
            if (alertDiv.parentNode) {
                alertDiv.style.animation = 'slideOutRight 0.3s ease-out';
                setTimeout(function() {
                    if (alertDiv.parentNode) {
                        alertDiv.parentNode.removeChild(alertDiv);
                    }
                }, 300);
            }
        }, 5000);
    }

    // Confirmation modal function
    function showConfirmModal(message, title, onConfirm) {
        const modalId = 'confirmModal_' + Date.now();
        
        // Create modal HTML using string concatenation
        const modalDiv = document.createElement('div');
        modalDiv.id = modalId;
        modalDiv.className = 'modal-overlay';
        modalDiv.style.cssText = 'position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 9998; display: flex; align-items: center; justify-content: center;';
        
        modalDiv.innerHTML = '<div class="modal-content" style="background: white; border-radius: 8px; max-width: 550px; width: 90%; max-height: 90vh; overflow-y: auto; box-shadow: 0 5px 15px rgba(0,0,0,0.3); animation: modalFadeIn 0.3s ease-out;">' +
                            '<div class="modal-header" style="padding: 20px 20px 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center;">' +
                            '<h3 class="modal-title" style="margin: 0; color: #333; font-size: 1.3rem;">' + title + '</h3>' +
                            '<button class="close-button" style="background: none; border: none; font-size: 24px; cursor: pointer; color: #666; line-height: 1;">&times;</button>' +
                            '</div>' +
                            '<div class="modal-body" style="padding: 20px;">' +
                            message +
                            '</div>' +
                            '<div class="modal-footer" style="padding: 15px 20px; border-top: 1px solid #eee; display: flex; justify-content: flex-end; gap: 10px;">' +
                            '<button class="btn btn-secondary cancel-btn" style="padding: 10px 20px; background: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 14px;">Cancel</button>' +
                            '<button class="btn btn-danger confirm-btn" style="padding: 10px 20px; background: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 14px;">' +
                            '<i class="fas fa-check"></i> Confirm Delete' +
                            '</button>' +
                            '</div>' +
                            '</div>';
        
        document.body.appendChild(modalDiv);
        
        // Setup event handlers
        const modalElement = document.getElementById(modalId);
        
        // Close button handler
        modalElement.querySelector('.close-button').addEventListener('click', function() {
            modalElement.remove();
        });
        
        // Cancel button handler
        modalElement.querySelector('.cancel-btn').addEventListener('click', function() {
            modalElement.remove();
        });
        
        // Confirm button handler
        modalElement.querySelector('.confirm-btn').addEventListener('click', function() {
            modalElement.remove();
            if (onConfirm && typeof onConfirm === 'function') {
                onConfirm();
            }
        });
        
        // Close on outside click
        modalElement.addEventListener('click', function(e) {
            if (e.target === modalElement) {
                modalElement.remove();
            }
        });
        
        // Close on escape key
        const escHandler = function(e) {
            if (e.key === 'Escape') {
                modalElement.remove();
                document.removeEventListener('keydown', escHandler);
            }
        };
        document.addEventListener('keydown', escHandler);
    }

    // Edit mode functions
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
            showAlert('Please enter valid marks between 0 and ' + totalMarks, 'warning');
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
        
        // Create hidden inputs
        const fields = [
            {name: 'page', value: 'results'},
            {name: 'operation', value: 'edit'},
            {name: 'eid', value: examId},
            {name: 'obtMarks', value: obtMarks},
            {name: 'totalMarks', value: totalMarks},
            {name: 'status', value: status}
        ];
        
        fields.forEach(function(field) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = field.name;
            input.value = field.value;
            form.appendChild(input);
        });
        
        document.body.appendChild(form);
        form.submit();
    }

    // Filter functions
    function applyFilters() {
        const nameFilter = document.getElementById('filterName').value.toLowerCase();
        const courseFilter = document.getElementById('filterCourse').value.toLowerCase();
        const statusFilter = document.getElementById('filterStatus').value.toLowerCase();
        const dateFrom = document.getElementById('filterDateFrom').value;
        const dateTo = document.getElementById('filterDateTo').value;
        const globalSearch = document.getElementById('searchBox').value.toLowerCase();
        
        const rows = document.querySelectorAll('#resultsTableBody tr.result-row');
        let visibleCount = 0;
        
        rows.forEach(function(row) {
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
            
            // Global search
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
        updateBulkDeleteButton();
    }
    
    function setQuickFilter(filterType) {
        resetAllFilters();
        
        switch(filterType) {
            case 'pass':
                document.getElementById('filterStatus').value = 'Pass';
                break;
            case 'fail':
                document.getElementById('filterStatus').value = 'Fail';
                break;
            case 'high':
                // Filter rows with percentage > 80
                const rowsHigh = document.querySelectorAll('#resultsTableBody tr.result-row');
                rowsHigh.forEach(function(row) {
                    const percentage = parseFloat(row.getAttribute('data-percentage'));
                    row.style.display = percentage >= 80 ? '' : 'none';
                });
                break;
            case 'low':
                // Filter rows with percentage < 50
                const rowsLow = document.querySelectorAll('#resultsTableBody tr.result-row');
                rowsLow.forEach(function(row) {
                    const percentage = parseFloat(row.getAttribute('data-percentage'));
                    row.style.display = percentage < 50 ? '' : 'none';
                });
                break;
        }
        
        if (filterType === 'pass' || filterType === 'fail') {
            applyFilters();
        } else {
            updateResultsCount();
        }
        
        // Add active class to the clicked button
        const buttons = document.querySelectorAll('.quick-filter-btn');
        buttons.forEach(function(btn) {
            var btnText = btn.textContent || btn.innerText;
            if (filterType === 'pass' && btnText.includes('Pass Only')) {
                btn.classList.add('active');
            } else if (filterType === 'fail' && btnText.includes('Fail Only')) {
                btn.classList.add('active');
            } else if (filterType === 'high' && btnText.includes('High Scores')) {
                btn.classList.add('active');
            } else if (filterType === 'low' && btnText.includes('Low Scores')) {
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
        
        // Reset date filters to default
        const today = new Date().toISOString().split('T')[0];
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        
        document.getElementById('filterDateTo').value = today;
        document.getElementById('filterDateFrom').value = thirtyDaysAgo.toISOString().split('T')[0];
        
        // Show all rows
        document.querySelectorAll('#resultsTableBody tr.result-row').forEach(function(row) {
            row.style.display = '';
        });
        
        updateResultsCount();
        
        // Remove active class from quick filter buttons
        document.querySelectorAll('.quick-filter-btn').forEach(function(btn) {
            btn.classList.remove('active');
        });
    }
    
    function updateResultsCount(visibleCount) {
        const totalRows = document.querySelectorAll('#resultsTableBody tr.result-row').length;
        if (visibleCount === undefined || visibleCount === null) {
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
        headers.forEach(function(header, index) {
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
        rows.sort(function(a, b) {
            let aValue, bValue;
            
            switch(columnIndex) {
                case 1: // Name
                    aValue = a.cells[1].textContent.toLowerCase();
                    bValue = b.cells[1].textContent.toLowerCase();
                    break;
                case 2: // Student ID
                    aValue = a.cells[2].textContent.toLowerCase();
                    bValue = b.cells[2].textContent.toLowerCase();
                    break;
                case 3: // Email
                    aValue = a.cells[3].textContent.toLowerCase();
                    bValue = b.cells[3].textContent.toLowerCase();
                    break;
                case 4: // Date
                    aValue = new Date(a.getAttribute('data-date'));
                    bValue = new Date(b.getAttribute('data-date'));
                    break;
                case 5: // Course
                    aValue = a.cells[5].textContent.toLowerCase();
                    bValue = b.cells[5].textContent.toLowerCase();
                    break;
                case 6: // Time
                    return 0;
                case 7: // Marks
                    const aMarks = a.getAttribute('data-obt-marks');
                    const bMarks = b.getAttribute('data-obt-marks');
                    aValue = parseInt(aMarks);
                    bValue = parseInt(bMarks);
                    break;
                case 8: // Status
                    const statusOrder = { 'pass': 1, 'fail': 2, 'terminated': 3 };
                    aValue = statusOrder[a.getAttribute('data-status')] || 4;
                    bValue = statusOrder[b.getAttribute('data-status')] || 4;
                    break;
                case 9: // Percentage
                    aValue = parseFloat(a.getAttribute('data-percentage'));
                    bValue = parseFloat(b.getAttribute('data-percentage'));
                    break;
                default:
                    return 0;
            }
            
            // Compare values
            if (aValue < bValue) return -1 * sortDirection;
            if (aValue > bValue) return 1 * sortDirection;
            return 0;
        });
        
        // Reorder rows in DOM
        rows.forEach(function(row) {
            tbody.appendChild(row);
        });
    }
    
    // Floating delete button functionality - FIXED VERSION
    function updateFloatingDeleteButton() {
        const selectedCheckboxes = document.querySelectorAll('.record-checkbox:checked');
        const floatingDeleteBtn = document.getElementById('floatingDeleteBtn');
        const selectedCountBadge = document.getElementById('selectedCountBadge');
        
        const selectedCountNum = selectedCheckboxes.length;
        
        if (selectedCountBadge) {
            selectedCountBadge.textContent = selectedCountNum;
        }
        
        // Update floating delete button state based on selection
        if (floatingDeleteBtn) {
            if (selectedCountNum > 0) {
                floatingDeleteBtn.classList.add('active');
                floatingDeleteBtn.classList.remove('inactive');
                floatingDeleteBtn.style.visibility = 'visible';
                floatingDeleteBtn.style.opacity = '1';
                floatingDeleteBtn.style.pointerEvents = 'auto';
            } else {
                floatingDeleteBtn.classList.add('inactive');
                floatingDeleteBtn.classList.remove('active');
                floatingDeleteBtn.style.visibility = 'hidden';
                floatingDeleteBtn.style.opacity = '0';
                floatingDeleteBtn.style.pointerEvents = 'none';
            }
        }
    }
    
    function handleFloatingBulkDelete() {
        handleBulkDelete();
    }
    
    // Update the updateBulkDeleteButton function to also update floating button
    function updateBulkDeleteButton() {
        const selectedCheckboxes = document.querySelectorAll('.record-checkbox:checked');
        const selectedCountBadge = document.getElementById('selectedCountBadge');
        
        const selectedCountNum = selectedCheckboxes.length;
        
        if (selectedCountBadge) {
            selectedCountBadge.textContent = selectedCountNum;
        }
        
        // Update select all checkbox state
        const selectAll = document.getElementById('selectAll');
        if (selectAll) {
            const totalCheckboxes = document.querySelectorAll('.record-checkbox').length;
            selectAll.checked = selectedCountNum === totalCheckboxes && totalCheckboxes > 0;
            selectAll.indeterminate = selectedCountNum > 0 && selectedCountNum < totalCheckboxes;
        }
        
        // Also update floating delete button
        updateFloatingDeleteButton();
    }
    
    // Add scroll to top functionality
    const scrollToTopBtn = document.getElementById('scrollToTopBtn');
    
    if (scrollToTopBtn) {
        // Show/hide scroll to top button based on scroll position
        window.addEventListener('scroll', function() {
            if (window.pageYOffset > 300) {  // Show after scrolling down 300px
                scrollToTopBtn.classList.add('show');
            } else {
                scrollToTopBtn.classList.remove('show');
            }
        });
        
        // Scroll to top when button is clicked
        scrollToTopBtn.addEventListener('click', function() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
    

    
    // Initialize floating delete button
    document.addEventListener('DOMContentLoaded', function() {
        // Initialize floating delete button state
        updateFloatingDeleteButton();
        
        // Wire up floating delete button
        const floatingDeleteBtn = document.getElementById('floatingDeleteBtn');
        if (floatingDeleteBtn) {
            const btn = floatingDeleteBtn.querySelector('button');
            if (btn) {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    handleBulkDelete();
                });
            }
        }
    });
    
    
    // Modal functions
    function hideModal() {
        document.getElementById('confirmationModal').style.display = 'none';
    }
    
    function confirmAction() {
        // If we have a stored delete URL (single delete), redirect to it
        if (window.currentDeleteUrl) {
            window.location.href = window.currentDeleteUrl;
        } else {
            // Otherwise, submit the form for bulk delete
            document.getElementById('bulkDeleteForm').submit();
        }
    }
</script>