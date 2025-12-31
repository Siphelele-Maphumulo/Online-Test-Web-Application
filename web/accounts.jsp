<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

// Get current user details FIRST
User currentUser = null;

// Check if user is logged in
if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Get current user details
currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());

if (currentUser == null) {
    // User not found in database
    session.invalidate();
    response.sendRedirect("login.jsp");
    return;
}

// Now get student list
ArrayList<User> studentList = pDAO.getAllStudents();
int totalCount = 0;
int displayCount = 0;

// Count total students (excluding current user)
for (User user : studentList) {
    if (user.getUserId() != Integer.parseInt(session.getAttribute("userId").toString())) {
        if (currentUser.getType().equalsIgnoreCase("lecture") && user.getType().equalsIgnoreCase("student") ||
            currentUser.getType().equalsIgnoreCase("admin")) {
            totalCount++;
        }
    }
}
%>

<!--style-->
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
    
    /* Accounts Cards */
    .accounts-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        margin-bottom: var(--spacing-lg);
        overflow: hidden;
        transition: transform var(--transition-normal), box-shadow var(--transition-normal);
    }
    
    .accounts-card:hover {
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
        border-bottom: 1px solid var(--medium-gray);
        padding: var(--spacing-lg);
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
    
    .filter-control {
        padding: 10px 12px;
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        font-size: 14px;
        transition: all var(--transition-fast);
        background: var(--white);
        color: var(--text-dark);
    }
    
    .filter-control:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
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
    
    .btn-success {
        background: linear-gradient(90deg, var(--success), #10b981);
        color: var(--white);
    }
    
    .btn-success:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(5, 150, 105, 0.2);
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
    
    .btn-error {
        background: linear-gradient(90deg, var(--error), #ef4444);
        color: var(--white);
    }
    
    .btn-error:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
    }
    
    /* Actions Bar */
    .actions-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: var(--spacing-md) var(--spacing-lg);
        background: var(--light-gray);
        border-bottom: 1px solid var(--medium-gray);
    }
    
    .search-container {
        position: relative;
        flex: 1;
        max-width: 300px;
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
    
    /* Quick Filters */
    .quick-filter-row {
        display: flex;
        flex-wrap: wrap;
        gap: var(--spacing-sm);
        margin-top: var(--spacing-md);
        padding-top: var(--spacing-md);
        border-top: 1px solid var(--medium-gray);
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
    
    /* Table Styles */
    .accounts-table {
        width: 100%;
        border-collapse: collapse;
        background: var(--white);
    }
    
    .accounts-table thead th {
        background: var(--light-gray);
        color: var(--text-dark);
        padding: var(--spacing-md);
        font-weight: 600;
        text-align: left;
        border-bottom: 1px solid var(--medium-gray);
        font-size: 13px;
        cursor: pointer;
        transition: background-color var(--transition-fast);
    }
    
    .accounts-table thead th:hover {
        background: var(--medium-gray);
    }
    
    .accounts-table tbody td {
        padding: var(--spacing-md);
        border-bottom: 1px solid var(--light-gray);
        vertical-align: middle;
        color: var(--dark-gray);
        font-size: 13px;
    }
    
    .accounts-table tbody tr {
        transition: background-color var(--transition-fast);
    }
    
    .accounts-table tbody tr:hover {
        background-color: var(--light-gray);
    }
    
    /* Student Info */
    .student-name {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
    }
    
    .student-avatar {
        width: 40px;
        height: 40px;
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--white);
        font-weight: 600;
        font-size: 14px;
        flex-shrink: 0;
        box-shadow: 0 2px 6px rgba(9, 41, 77, 0.1);
    }
    
    /* Badges */
    .badge {
        color: var(--white);
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
    }
    
    .badge-success {
        background: linear-gradient(90deg, var(--success), #10b981);
    }
    
    .badge-neutral {
        background: var(--dark-gray);
    }
    
    /* User Role Badge */
    .user-role {
        display: inline-block;
        background: var(--light-gray);
        color: var(--dark-gray);
        padding: 2px 8px;
        border-radius: 10px;
        font-weight: 500;
        font-size: 11px;
        margin-left: var(--spacing-sm);
        border: 1px solid var(--medium-gray);
    }
    
    /* Action Buttons */
    .action-buttons {
        display: flex;
        gap: var(--spacing-sm);
    }
    
    /* Sort Indicator */
    .sort-indicator {
        margin-left: 4px;
        font-size: 10px;
        color: var(--dark-gray);
    }
    
    /* No Students Message */
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
    
    .students-count {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(255, 255, 255, 0.1);
        padding: 6px 12px;
        border-radius: 16px;
        font-weight: 500;
        color: var(--white);
        font-size: 12px;
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
        
        .actions-bar {
            flex-direction: column;
            gap: var(--spacing-md);
            align-items: stretch;
        }
        
        .search-container {
            max-width: 100%;
        }
        
        .filter-grid {
            grid-template-columns: 1fr;
        }
        
        .accounts-table {
            display: block;
            overflow-x: auto;
            white-space: nowrap;
        }
        
        .card-header {
            flex-direction: column;
            gap: var(--spacing-sm);
            text-align: center;
        }
        
        .action-buttons {
            flex-direction: column;
            gap: var(--spacing-xs);
        }
        
        .btn {
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
        
        .accounts-table thead th,
        .accounts-table tbody td {
            padding: var(--spacing-sm);
        }
        
        .student-name {
            flex-direction: column;
            align-items: flex-start;
            gap: var(--spacing-sm);
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
            <a href="adm-page.jsp?pgprt=5" class="nav-item">
                <i class="fas fa-chart-bar"></i>
                <h2>Results</h2>
            </a>
            <a href="adm-page.jsp?pgprt=1" class="nav-item active">
                <i class="fas fa-user-graduate"></i>
                <h2>Student Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=6" class="nav-item">
                <i class="fas fa-chalkboard-teacher"></i>
                <h2>Lecture Accounts</h2>
            </a>
        </nav>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <!-- Page Header -->
        <header class="page-header">
            <div class="page-title">
                <i class="fas fa-user-graduate"></i>
                Student Accounts Management
            </div>
            <div class="stats-badge" id="totalStudentsBadge">
                <i class="fas fa-users"></i>
                <span id="totalStudentsCount">0</span> Students
            </div>
        </header>
        
        <!-- Student Accounts Card -->
        <div class="accounts-card">
            <div class="card-header">
                <span><i class="fas fa-list"></i> All Registered Students</span>
                <div class="students-count">
                    <i class="fas fa-layer-group"></i>
                    Showing: <span id="visibleStudentsCount">0</span> of <span id="totalCount">0</span>
                </div>
            </div>
            
            <!-- Filter Section -->
            <div class="filter-container">
                <div class="filter-grid">
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-user" style="color: var(--accent-blue);"></i>
                            Student Name
                        </label>
                        <input type="text" id="searchName" class="filter-control" 
                               placeholder="Search by name..." oninput="applyFilters()">
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-id-card" style="color: var(--info);"></i>
                            Student Number
                        </label>
                        <input type="text" id="searchStudentNumber" class="filter-control" 
                               placeholder="Search by student number..." oninput="applyFilters()">
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-envelope" style="color: var(--success);"></i>
                            Email Address
                        </label>
                        <input type="text" id="searchEmail" class="filter-control" 
                               placeholder="Search by email..." oninput="applyFilters()">
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-city" style="color: var(--dark-gray);"></i>
                            City
                        </label>
                        <input type="text" id="searchCity" class="filter-control" 
                               placeholder="Search by city..." oninput="applyFilters()">
                    </div>
                </div>
                
                <!-- Quick Filters -->
                <div class="quick-filter-row">
                    <button class="quick-filter-btn" onclick="setQuickFilter('recent')">
                        <i class="fas fa-clock"></i> Recently Added
                    </button>
                    <button class="quick-filter-btn" onclick="setQuickFilter('missing-contact')">
                        <i class="fas fa-phone-slash"></i> Missing Contact
                    </button>
                    <button class="quick-filter-btn" onclick="setQuickFilter('missing-address')">
                        <i class="fas fa-map-marker-alt"></i> Missing Address
                    </button>
                    <button class="quick-filter-btn" onclick="setQuickFilter('all')">
                        <i class="fas fa-list"></i> Show All
                    </button>
                </div>
            </div>
            
            <!-- Search and Actions Bar -->
            <div class="actions-bar">
                <a href="signup.jsp?from=account&user_type=student" class="btn btn-success">
                    <i class="fas fa-plus-circle"></i>
                    Add New Student
                </a>
                
                <div class="search-container">
                    <input type="text" id="globalSearch" class="search-input" 
                           placeholder="Search across all columns..." oninput="applyFilters()">
                    <i class="fas fa-search search-icon"></i>
                </div>
                
                <div class="action-buttons">
                    <button onclick="applyFilters()" class="btn btn-primary">
                        <i class="fas fa-filter"></i> Apply Filters
                    </button>
                    <button onclick="resetFilters()" class="btn btn-secondary">
                        <i class="fas fa-redo"></i> Reset
                    </button>
                </div>
            </div>
            
            <div style="overflow-x: auto;">
                <table class="accounts-table" id="studentTable">
                    <thead>
                        <tr>
                            <th onclick="sortTable(0)">Student <span class="sort-indicator"></span></th>
                            <th onclick="sortTable(1)">Student Number <span class="sort-indicator"></span></th>
                            <th onclick="sortTable(2)">Email <span class="sort-indicator"></span></th>
                            <th onclick="sortTable(3)">Contact <span class="sort-indicator"></span></th>
                            <th onclick="sortTable(4)">Location <span class="sort-indicator"></span></th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="studentTableBody">
                        <%
                            // Note: currentUser is already defined above, so we don't redeclare it here
                            // Just use the existing currentUser variable
                            
                            boolean hasStudents = false;
                            int visibleCountInTable = 0;
                            
                            for (User user : studentList) {
                                if (user.getUserId() != Integer.parseInt(session.getAttribute("userId").toString())) {
                                    if (currentUser.getType().equalsIgnoreCase("lecture") && user.getType().equalsIgnoreCase("student") ||
                                        currentUser.getType().equalsIgnoreCase("admin")) {
                                        hasStudents = true;
                                        visibleCountInTable++;
                                        String initials = user.getFirstName().substring(0, 1) + user.getLastName().substring(0, 1);
                        %>
                        <tr class="student-row" 
                            data-id="<%= user.getUserId() %>"
                            data-name="<%= (user.getFirstName() + " " + user.getLastName()).toLowerCase() %>"
                            data-student-number="<%= user.getUserName().toLowerCase() %>"
                            data-email="<%= user.getEmail().toLowerCase() %>"
                            data-contact="<%= user.getContact() != null ? user.getContact().toLowerCase() : "" %>"
                            data-city="<%= user.getCity() != null ? user.getCity().toLowerCase() : "" %>"
                            data-address="<%= user.getAddress() != null ? user.getAddress().toLowerCase() : "" %>"
                            data-fullname="<%= (user.getFirstName() + " " + user.getLastName()).toLowerCase() %>">
                            <td>
                                <div class="student-name">
                                    <div class="student-avatar">
                                        <%= initials %>
                                    </div>
                                    <div>
                                        <%= user.getFirstName() + " " + user.getLastName() %>
                                        <span class="user-role">Student</span>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="badge badge-info">
                                    <i class="fas fa-id-card"></i>
                                    <%= user.getUserName() %>
                                </span>
                            </td>
                            <td>
                                <div style="color: var(--dark-gray); font-size: 13px;">
                                    <i class="fas fa-envelope" style="color: var(--accent-blue); margin-right: 8px;"></i>
                                    <%= user.getEmail() %>
                                </div>
                            </td>
                            <td>
                                <div style="color: var(--dark-gray); font-size: 13px;">
                                    <i class="fas fa-phone" style="color: var(--success); margin-right: 8px;"></i>
                                    <%= user.getContact() != null ? user.getContact() : "Not provided" %>
                                </div>
                            </td>
                            <td>
                                <div style="color: var(--dark-gray); font-size: 13px;">
                                    <i class="fas fa-map-marker-alt" style="color: var(--info); margin-right: 8px;"></i>
                                    <%= user.getCity() != null ? user.getCity() : "Unknown" %><%= user.getAddress() != null ? ", " + user.getAddress() : "" %>
                                </div>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="#" class="btn btn-primary" onclick="editStudent(<%= user.getUserId() %>)" style="font-size: 13px; padding: 8px 16px;">
                                        <i class="fas fa-edit"></i>
                                        Edit
                                    </a>
                                    <a href="controller.jsp?page=accounts&operation=del&uid=<%= user.getUserId() %>" 
                                       onclick="return confirm('Are you sure you want to delete student \"<%= user.getFirstName() %> <%= user.getLastName() %>\"? This action cannot be undone.');" 
                                       class="btn btn-error" style="font-size: 13px; padding: 8px 16px;">
                                       <i class="fas fa-trash"></i>
                                       Delete
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <%
                                    }
                                }
                            }
                            
                            if (!hasStudents) {
                        %>
                            <tr>
                                <td colspan="6" class="no-results">
                                    <i class="fas fa-user-graduate" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                                    No students registered yet. Add your first student to get started.
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                
                <div class="results-count">
                    Displaying <span id="visibleCount"><%= visibleCountInTable %></span> of <span id="totalStudents"><%= totalCount %></span> students
                </div>
            </div>
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
        updateStudentsCount();
        setupQuickFilterButtons();
    });
    
    // Update student counts
    function updateStudentsCount() {
        const totalRows = document.querySelectorAll('#studentTableBody tr.student-row').length;
        const visibleRows = document.querySelectorAll('#studentTableBody tr.student-row:not([style*="display: none"])').length;
        
        document.getElementById('totalStudentsCount').textContent = totalRows;
        document.getElementById('visibleStudentsCount').textContent = visibleRows;
        document.getElementById('totalCount').textContent = totalRows;
        document.getElementById('visibleCount').textContent = visibleRows;
        document.getElementById('totalStudents').textContent = totalRows;
    }
    
    // Setup quick filter buttons
    function setupQuickFilterButtons() {
        const quickFilterBtns = document.querySelectorAll('.quick-filter-btn');
        quickFilterBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                quickFilterBtns.forEach(b => b.classList.remove('active'));
                this.classList.add('active');
            });
        });
    }
    
    // Apply all filters
    function applyFilters() {
        const nameFilter = document.getElementById('searchName').value.toLowerCase();
        const studentNumberFilter = document.getElementById('searchStudentNumber').value.toLowerCase();
        const emailFilter = document.getElementById('searchEmail').value.toLowerCase();
        const cityFilter = document.getElementById('searchCity').value.toLowerCase();
        const globalSearch = document.getElementById('globalSearch').value.toLowerCase();
        
        const rows = document.querySelectorAll('#studentTableBody tr.student-row');
        let visibleCount = 0;
        
        rows.forEach(row => {
            let showRow = true;
            
            // Name filter
            if (nameFilter && !row.getAttribute('data-name').includes(nameFilter)) {
                showRow = false;
            }
            
            // Student number filter
            if (studentNumberFilter && !row.getAttribute('data-student-number').includes(studentNumberFilter)) {
                showRow = false;
            }
            
            // Email filter
            if (emailFilter && !row.getAttribute('data-email').includes(emailFilter)) {
                showRow = false;
            }
            
            // City filter
            if (cityFilter && !row.getAttribute('data-city').includes(cityFilter)) {
                showRow = false;
            }
            
            // Global search (search across all data attributes)
            if (globalSearch) {
                const searchableData = [
                    row.getAttribute('data-name'),
                    row.getAttribute('data-student-number'),
                    row.getAttribute('data-email'),
                    row.getAttribute('data-contact'),
                    row.getAttribute('data-city'),
                    row.getAttribute('data-address'),
                    row.getAttribute('data-fullname')
                ].join(' ');
                
                if (!searchableData.includes(globalSearch)) {
                    showRow = false;
                }
            }
            
            // Show/hide row
            row.style.display = showRow ? '' : 'none';
            if (showRow) visibleCount++;
        });
        
        updateStudentsCount();
    }
    
    // Set quick filters
    function setQuickFilter(filterType) {
        resetFilters();
        
        const rows = document.querySelectorAll('#studentTableBody tr.student-row');
        
        switch(filterType) {
            case 'recent':
                // Show only last 10 added students (assuming recent ones have higher IDs)
                const sortedRows = Array.from(rows).sort((a, b) => {
                    return parseInt(b.getAttribute('data-id')) - parseInt(a.getAttribute('data-id'));
                });
                
                rows.forEach(row => row.style.display = 'none');
                sortedRows.slice(0, 10).forEach(row => row.style.display = '');
                break;
                
            case 'missing-contact':
                rows.forEach(row => {
                    const contact = row.getAttribute('data-contact');
                    if (contact && contact.length > 0 && !contact.includes('not provided')) {
                        row.style.display = 'none';
                    }
                });
                break;
                
            case 'missing-address':
                rows.forEach(row => {
                    const city = row.getAttribute('data-city');
                    if (city && city.length > 0 && !city.includes('unknown')) {
                        row.style.display = 'none';
                    }
                });
                break;
                
            case 'all':
                // Already handled by resetFilters()
                break;
        }
        
        updateStudentsCount();
    }
    
    // Reset all filters
    function resetFilters() {
        document.getElementById('searchName').value = '';
        document.getElementById('searchStudentNumber').value = '';
        document.getElementById('searchEmail').value = '';
        document.getElementById('searchCity').value = '';
        document.getElementById('globalSearch').value = '';
        
        // Reset quick filter buttons
        document.querySelectorAll('.quick-filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        // Show all rows
        document.querySelectorAll('#studentTableBody tr.student-row').forEach(row => {
            row.style.display = '';
        });
        
        updateStudentsCount();
    }
    
    // Sort table by column
    function sortTable(columnIndex) {
        const tbody = document.getElementById('studentTableBody');
        const rows = Array.from(tbody.querySelectorAll('tr.student-row:not([style*="display: none"])'));
        
        // Update sort indicators
        const headers = document.querySelectorAll('#studentTable thead th');
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
                case 0: // Student Name
                    aValue = a.getAttribute('data-name');
                    bValue = b.getAttribute('data-name');
                    break;
                case 1: // Student Number
                    aValue = a.getAttribute('data-student-number');
                    bValue = b.getAttribute('data-student-number');
                    break;
                case 2: // Email
                    aValue = a.getAttribute('data-email');
                    bValue = b.getAttribute('data-email');
                    break;
                case 3: // Contact
                    aValue = a.getAttribute('data-contact');
                    bValue = b.getAttribute('data-contact');
                    break;
                case 4: // Location
                    const aLocation = a.getAttribute('data-city') + ' ' + a.getAttribute('data-address');
                    const bLocation = b.getAttribute('data-city') + ' ' + b.getAttribute('data-address');
                    aValue = aLocation.toLowerCase();
                    bValue = bLocation.toLowerCase();
                    break;
                default:
                    aValue = aCell.textContent.toLowerCase();
                    bValue = bCell.textContent.toLowerCase();
            }
            
            // Handle empty values
            if (!aValue) aValue = '';
            if (!bValue) bValue = '';
            
            // Compare values
            if (aValue < bValue) return -1 * sortDirection;
            if (aValue > bValue) return 1 * sortDirection;
            return 0;
        });
        
        // Reorder rows in DOM
        rows.forEach(row => tbody.appendChild(row));
        updateStudentsCount();
    }
    
    // Edit student function
    function editStudent(userId) {
        window.location.href = 'edit-user.jsp?uid=' + userId;
    }
</script>