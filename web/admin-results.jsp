<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>

<% 
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
        width: 250px;
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
                    <span id="resultsCount">0</span> Results
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
                                        // Use getFullName() method as per Exams class
                                        String fullName = e.getFullName();
                            %>
                            <tr class="result-row" 
                                data-name="<%= fullName.toLowerCase() %>"
                                data-id="<%= e.getUserName().toLowerCase() %>"
                                data-email="<%= e.getEmail().toLowerCase() %>"
                                data-date="<%= e.getDate() %>"
                                data-course="<%= e.getcName().toLowerCase() %>"
                                data-time="<%= e.getStartTime() + " - " + e.getEndTime() %>"
                                data-marks="<%= e.getObtMarks() + "/" + e.gettMarks() %>"
                                data-percentage="<%= percentage %>"
                                data-status="<%= status.toLowerCase() %>">
                                <td><%= fullName %></td>
                                <td><%= e.getUserName() %></td>
                                <td><%= e.getEmail() %></td>
                                <td><%= e.getDate() %></td>
                                <td><%= e.getcName() %></td>
                                <td><%= e.getStartTime() %> - <%= e.getEndTime() %></td>
                                <td><%= e.getObtMarks() %> / <%= e.gettMarks() %></td>
                                <td>
                                    <% if (status.equals("Pass")) { %>
                                        <span class="badge badge-success">
                                            <i class="fas fa-check-circle"></i> <%= status %>
                                        </span>
                                    <% } else if (status.equals("Fail")) { %>
                                        <span class="badge badge-error">
                                            <i class="fas fa-times-circle"></i> <%= status %>
                                        </span>
                                    <% } else { %>
                                        <span class="badge badge-warning">
                                            <i class="fas fa-exclamation-triangle"></i> Terminated
                                        </span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge badge-info"><%= String.format("%.0f", percentage) %>%</span>
                                </td>
                                <td>
                                    <a class="btn btn-primary" href="adm-page.jsp?pgprt=5&eid=<%= e.getExamId() %>" style="font-size: 13px; padding: 8px 16px;">
                                        <i class="fas fa-eye"></i> Details
                                    </a>
                                    <button class="btn btn-danger" onclick="confirmDelete(<%= e.getExamId() %>, '<%= fullName %>', '<%= e.getcName() %>')" style="font-size: 13px; padding: 8px 16px;">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </td>
                            </tr>
                            <% 
                                    }
                                } 
                            %>
                        </tbody>
                    </table>
                    <div class="results-count">
                        Showing <span id="visibleCount">0</span> of <span id="totalCount">0</span> results
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

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- JavaScript for enhanced functionality -->
<script>
    // Global variables for sorting
    let currentSortColumn = -1;
    let sortDirection = 1; // 1 = ascending, -1 = descending
    
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
    });
    
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
    
        // Set quick filters
        function setQuickFilter(filterType) {
            resetAllFilters();

            switch(filterType) {
                case 'pass':
                    // Set status filter to "Pass" and apply
                    document.getElementById('filterStatus').value = 'Pass';
                    applyFilters();
                    break;

                case 'fail':
                    // Set status filter to "Fail" and apply
                    document.getElementById('filterStatus').value = 'Fail';
                    applyFilters();
                    break;

                case 'high':
                    // Filter for high scores (>80%)
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
                    // Filter for low scores (<50%)
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
                    const aMarks = aCell.textContent.split('/').map(Number);
                    const bMarks = bCell.textContent.split('/').map(Number);
                    aValue = aMarks[0] / aMarks[1];
                    bValue = bMarks[0] / bMarks[1];
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

    function confirmDelete(examId, studentName, courseName) {
        const modal = document.getElementById('deleteConfirmationModal');
        document.getElementById('modalStudentName').textContent = studentName;
        document.getElementById('modalCourseName').textContent = courseName;
        document.getElementById('modalExamId').textContent = examId;
        modal.style.display = 'block';

        document.getElementById('confirmDeleteBtn').onclick = function() {
            const deleteBtn = this;
            deleteBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
            deleteBtn.disabled = true;

            const form = document.createElement('form');
            form.method = 'post';
            form.action = 'controller.jsp';

            const pageInput = document.createElement('input');
            pageInput.type = 'hidden';
            pageInput.name = 'page';
            pageInput.value = 'delete_exam_result';
            form.appendChild(pageInput);

            const examIdInput = document.createElement('input');
            examIdInput.type = 'hidden';
            examIdInput.name = 'exam_id';
            examIdInput.value = examId;
            form.appendChild(examIdInput);

            const csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = 'csrfToken';
            csrfInput.value = '<%= session.getAttribute("csrfToken") %>';
            form.appendChild(csrfInput);

            document.body.appendChild(form);
            form.submit();
        };
    }

    function closeModal() {
        document.getElementById('deleteConfirmationModal').style.display = 'none';
    }
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