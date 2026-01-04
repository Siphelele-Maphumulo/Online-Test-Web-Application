<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.User" %>
<%@ page contentType="text/html;charset=UTF-8"%>

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

    int examId = 0;
    try {
        examId = Integer.parseInt(request.getParameter("exam_id"));
    } catch (Exception ignored) {}

    int studentId = 0;
    try {
        studentId = Integer.parseInt(request.getParameter("student_id"));
    } catch (Exception ignored) {}

    String firstNameFilter = request.getParameter("first_name");
    if (firstNameFilter == null) firstNameFilter = "";

    String lastNameFilter = request.getParameter("last_name");
    if (lastNameFilter == null) lastNameFilter = "";

    String courseNameFilter = request.getParameter("course_name");
    if (courseNameFilter == null) courseNameFilter = "";

    String dateFilter = request.getParameter("exam_date");
    if (dateFilter == null) dateFilter = "";

    List<String> allCourses = pDAO.getExamRegisterCourses();
%>

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
    
    /* For inline forms in quick-filter-row */
    .quick-filter-row form {
        display: inline;
    }
    
    .quick-filter-row .btn {
        margin: 2px;
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
            <a href="adm-page.jsp?pgprt=7" class="nav-item" active>
               <i class="fas fa-users"></i>
               <h2>Registers</h2>
           </a>
        </nav>
 </aside>

    <div class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <div class="page-title">
                <i class="fas fa-clipboard-list"></i> Exam Register
            </div>
            <div class="stats-badge">
                <i class="fas fa-users"></i> Attendance Register
            </div>
        </div>

        <!-- Filters - UPDATED -->
        <div class="filter-container">
            <form method="get" action="adm-page.jsp">
                <input type="hidden" name="pgprt" value="7">

                <div class="filter-grid">
<!--                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-hashtag"></i> Exam ID</label>
                        <input type="number" name="exam_id" class="filter-control" value="<%= examId > 0 ? examId : "" %>">
                    </div>

                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-id-card"></i> Student ID</label>
                        <input type="number" name="student_id" class="filter-control" value="<%= studentId > 0 ? studentId : "" %>">
                    </div>-->

                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-user"></i> First Name</label>
                        <input type="text" name="first_name" class="filter-control" value="<%= firstNameFilter %>" placeholder="Search by first name">
                    </div>

                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-user"></i> Last Name</label>
                        <input type="text" name="last_name" class="filter-control" value="<%= lastNameFilter %>" placeholder="Search by last name">
                    </div>

                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-book"></i> Course</label>
                        <select name="course_name" class="filter-select">
                            <option value="">All Courses</option>
                            <% for (String c : allCourses) { %>
                                <option value="<%= c %>" <%= c.equals(courseNameFilter) ? "selected" : "" %>><%= c %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-calendar"></i> Exam Date</label>
                        <input type="date" name="exam_date" class="filter-control" value="<%= dateFilter %>">
                    </div>
                </div>

                <div class="quick-filter-row">
                    <button class="btn btn-primary" type="submit">
                        <i class="fas fa-search"></i> Apply Filters
                    </button>
                    <a href="adm-page.jsp?pgprt=7" class="btn btn-outline">
                        <i class="fas fa-times"></i> Clear
                    </a>
                    
                    <!-- Export Form in Filter Section -->
                    <form id="exportRegisterForm" method="get" action="export-register.jsp" target="_blank" style="display: inline;">
                        <!-- Pass all filter parameters -->
                        <input type="hidden" name="exam_id" value="<%= examId %>">
                        <input type="hidden" name="student_id" value="<%= studentId %>">
                        <input type="hidden" name="first_name" value="<%= firstNameFilter %>">
                        <input type="hidden" name="last_name" value="<%= lastNameFilter %>">
                        <input type="hidden" name="course_name" value="<%= courseNameFilter %>">
                        <input type="hidden" name="exam_date" value="<%= dateFilter %>">
                        <button type="button" id="exportButton" class="btn btn-success">
                            <i class="fas fa-file-excel"></i> Export to Excel
                        </button>
                    </form>
                </div>
            </form>
        </div>

        <!-- Results -->
        <div class="results-card">
            <div class="card-header">
                <span><i class="fas fa-table"></i> Exam Register Records</span>
            </div>

            <%
                ResultSet rs = null;
                try {
                    // UPDATED: Call with all filter parameters
                    rs = pDAO.getFilteredExamRegister(examId, studentId, firstNameFilter, 
                                                     lastNameFilter, courseNameFilter, dateFilter);
                    if (rs != null && rs.next()) {
            %>

            <table class="results-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student</th>
                        <th>Student ID</th>
                        <th>Course</th>
                        <th>Exam ID</th>
                        <th>Date</th>
                        <th>Start</th>
                        <th>End</th>
                        <th>Duration</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    int i = 0;
                    rs.beforeFirst();
                    while (rs.next()) {
                        i++;
                        boolean completed = rs.getTime("end_time") != null;
                %>
                    <tr>
                        <td><%= i %></td>
                        <td>
                            <strong><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></strong><br>
                            <small><%= rs.getString("email") %></small>
                        </td>
                        <td><%= rs.getInt("student_id") %></td>
                        <td><%= rs.getString("course_name") %></td>
                        <td><%= rs.getInt("exam_id") %></td>
                        <td><%= rs.getDate("exam_date") %></td>
                        <td><%= rs.getTime("start_time") %></td>
                        <td><%= rs.getTime("end_time") != null ? rs.getTime("end_time") : "—" %></td>
                        <td>
                            <%
                                java.sql.Time endTime = rs.getTime("end_time");
                                java.sql.Time startTime = rs.getTime("start_time");

                                if (endTime != null && startTime != null) {
                                    long startMillis = startTime.getTime();
                                    long endMillis = endTime.getTime();
                                    long durationMillis = endMillis - startMillis;

                                    long seconds = durationMillis / 1000;
                                    long hours = seconds / 3600;
                                    long minutes = (seconds % 3600) / 60;
                                    long secs = seconds % 60;

                                    out.print(String.format("%02d:%02d:%02d", hours, minutes, secs));
                                } else {
                                    out.print("—");
                                }
                            %>
                        </td>
                        <td>
                            <span class="badge <%= completed ? "badge-success" : "badge-warning" %>">
                                <%= completed ? "Completed" : "In Progress" %>
                            </span>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>

            <div class="results-count">
                Total Records: <%= i %>
            </div>

            <% } else { %>
                <div class="no-results">
                    No exam register records found.
                </div>
            <% } } catch (Exception e) { %>
                <div class="no-results">
                    Error loading exam register.
                </div>
            <% } %>

        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var exportButton = document.getElementById('exportButton');
    var exportForm = document.getElementById('exportRegisterForm');

    if (exportButton && exportForm) {
        exportButton.addEventListener('click', function(event) {
            // Stop any other scripts from interfering
            event.preventDefault();
            event.stopPropagation();
            
            // Submit the form directly
            exportForm.submit();
        });
    }
});
</script>