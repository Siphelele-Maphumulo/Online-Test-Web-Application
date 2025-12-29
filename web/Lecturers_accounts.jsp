<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>

<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

// Get current user for user_type
User currentUser = null;
String currentUserType = "";

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

currentUserType = currentUser.getType();

// Get all lecturers
ArrayList<User> lecturerList = pDAO.getAllLecturers();
int lecturerCount = lecturerList.size();
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
            <a href="adm-page.jsp?pgprt=5" class="nav-item">
                <i class="fas fa-chart-bar"></i>
                <h2>Results</h2>
            </a>
            <a href="adm-page.jsp?pgprt=1" class="nav-item">
                <i class="fas fa-user-graduate"></i>
                <h2>Student Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=6" class="nav-item active">
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
                <i class="fas fa-chalkboard-teacher"></i>
                Lecture Accounts Management
            </div>
            <div class="stats-badge">
                <i class="fas fa-users"></i>
                <%= lecturerCount %> Lecturers
            </div>
        </header>
        
        <!-- Lecturers Accounts Card -->
        <div class="accounts-card">
            <div class="card-header">
                <span><i class="fas fa-list"></i> All Registered Lecturers</span>
                <div class="lecturers-count">
                    <i class="fas fa-layer-group"></i>
                    Total: <%= lecturerCount %>
                </div>
            </div>
            
            <!-- Search and Actions Bar -->
            <div class="actions-bar">
                <a href="staff_Numbers.jsp?from=account&user_type=<%= currentUserType %>" class="btn btn-success">
                    <i class="fas fa-plus-circle"></i>
                    Add New Lecturer
                </a>
                
                <div class="search-container">
                    <input type="text" id="lecturerSearch" class="search-input" 
                           placeholder="Search by Staff No, Name, Email, or Course..."
                           oninput="filterLecturers()">
                    <i class="fas fa-search search-icon"></i>
                </div>
            </div>
            
            <div style="overflow-x: auto;">
                <table class="accounts-table" id="lecturerTable">
                    <thead>
                        <tr>
                            <th onclick="sortTable(0)">Lecturer</th>
                            <th onclick="sortTable(1)">Staff Number</th>
                            <th onclick="sortTable(2)">Email</th>
                            <th onclick="sortTable(3)">Course</th>
                            <th onclick="sortTable(4)">Contact</th>
                            <th onclick="sortTable(5)">Location</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="lecturerTableBody">
                        <%
                            if (lecturerList.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="7" class="no-results">
                                    <i class="fas fa-users-slash" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                                    No lecturers registered yet. Add your first lecturer to get started.
                                </td>
                            </tr>
                        <%
                            } else {
                                for (User lecturer : lecturerList) {
                                    String initials = "";
                                    if (lecturer.getFirstName() != null && lecturer.getFirstName().length() > 0 && 
                                        lecturer.getLastName() != null && lecturer.getLastName().length() > 0) {
                                        initials = lecturer.getFirstName().substring(0, 1) + lecturer.getLastName().substring(0, 1);
                                    } else if (lecturer.getFirstName() != null && lecturer.getFirstName().length() > 0) {
                                        initials = lecturer.getFirstName().substring(0, 1);
                                    } else {
                                        initials = "L";
                                    }
                        %>
                        <tr class="lecturer-row" 
                            data-name="<%= (lecturer.getFirstName() + " " + lecturer.getLastName()).toLowerCase() %>"
                            data-staff-number="<%= lecturer.getUserName() != null ? lecturer.getUserName().toLowerCase() : "" %>"
                            data-email="<%= lecturer.getEmail() != null ? lecturer.getEmail().toLowerCase() : "" %>"
                            data-course="<%= lecturer.getCourseName() != null ? lecturer.getCourseName().toLowerCase() : "" %>"
                            data-contact="<%= lecturer.getContact() != null ? lecturer.getContact().toLowerCase() : "" %>"
                            data-city="<%= lecturer.getCity() != null ? lecturer.getCity().toLowerCase() : "" %>"
                            data-address="<%= lecturer.getAddress() != null ? lecturer.getAddress().toLowerCase() : "" %>">
                            <td>
                                <div class="lecturer-name">
                                    <div class="lecturer-avatar">
                                        <%= initials %>
                                    </div>
                                    <div>
                                        <%= lecturer.getFirstName() + " " + lecturer.getLastName() %>
                                        <span class="user-role">Lecturer</span>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="badge badge-info">
                                    <i class="fas fa-id-card"></i>
                                    <%= lecturer.getUserName() != null ? lecturer.getUserName() : "N/A" %>
                                </span>
                            </td>
                            <td>
                                <div style="color: var(--dark-gray); font-size: 13px;">
                                    <i class="fas fa-envelope" style="color: var(--accent-blue); margin-right: 8px;"></i>
                                    <%= lecturer.getEmail() != null ? lecturer.getEmail() : "N/A" %>
                                </div>
                            </td>
                            <td>
                                <div style="color: var(--dark-gray); font-size: 13px;">
                                    <i class="fas fa-book" style="color: var(--warning); margin-right: 8px;"></i>
                                    <%= lecturer.getCourseName() != null ? lecturer.getCourseName() : "Not assigned" %>
                                </div>
                            </td>
                            <td>
                                <div style="color: var(--dark-gray); font-size: 13px;">
                                    <i class="fas fa-phone" style="color: var(--success); margin-right: 8px;"></i>
                                    <%= lecturer.getContact() != null ? lecturer.getContact() : "Not provided" %>
                                </div>
                            </td>
                            <td>
                                <div style="color: var(--dark-gray); font-size: 13px;">
                                    <i class="fas fa-map-marker-alt" style="color: var(--info); margin-right: 8px;"></i>
                                    <%= lecturer.getCity() != null ? lecturer.getCity() : "Unknown" %><%= lecturer.getAddress() != null ? ", " + lecturer.getAddress() : "" %>
                                </div>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="controller.jsp?page=Lecturers_accounts&operation=del&uid=<%= lecturer.getUserId() %>" 
                                       onclick="return confirm('Are you sure you want to delete lecturer \"<%= lecturer.getFirstName() %> <%= lecturer.getLastName() %>\"? This action cannot be undone.');" 
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
                        %>
                    </tbody>
                </table>
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
    
    // Filter lecturers function
    function filterLecturers() {
        const searchInput = document.getElementById('lecturerSearch').value.toLowerCase();
        const rows = document.querySelectorAll('#lecturerTableBody tr.lecturer-row');
        
        rows.forEach(row => {
            const searchableData = [
                row.getAttribute('data-name') || '',
                row.getAttribute('data-staff-number') || '',
                row.getAttribute('data-email') || '',
                row.getAttribute('data-course') || '',
                row.getAttribute('data-contact') || '',
                row.getAttribute('data-city') || '',
                row.getAttribute('data-address') || ''
            ].join(' ');
            
            if (searchInput === '' || searchableData.includes(searchInput)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }
    
    // Sort table by column
    function sortTable(columnIndex) {
        const tbody = document.getElementById('lecturerTableBody');
        const rows = Array.from(tbody.querySelectorAll('tr.lecturer-row:not([style*="display: none"])'));
        
        // Update sort indicators
        const headers = document.querySelectorAll('#lecturerTable thead th');
        headers.forEach((header, index) => {
            const indicator = header.querySelector('.sort-indicator');
            if (!indicator) {
                const newIndicator = document.createElement('span');
                newIndicator.className = 'sort-indicator';
                header.appendChild(newIndicator);
            }
        });
        
        // Update current header indicators
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
                case 0: // Lecturer Name
                    aValue = a.getAttribute('data-name');
                    bValue = b.getAttribute('data-name');
                    break;
                case 1: // Staff Number
                    aValue = a.getAttribute('data-staff-number');
                    bValue = b.getAttribute('data-staff-number');
                    break;
                case 2: // Email
                    aValue = a.getAttribute('data-email');
                    bValue = b.getAttribute('data-email');
                    break;
                case 3: // Course
                    aValue = a.getAttribute('data-course');
                    bValue = b.getAttribute('data-course');
                    break;
                case 4: // Contact
                    aValue = a.getAttribute('data-contact');
                    bValue = b.getAttribute('data-contact');
                    break;
                case 5: // Location
                    const aLocation = (a.getAttribute('data-city') || '') + ' ' + (a.getAttribute('data-address') || '');
                    const bLocation = (b.getAttribute('data-city') || '') + ' ' + (b.getAttribute('data-address') || '');
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
    }
    
    // Initialize search functionality
    document.addEventListener('DOMContentLoaded', function() {
        // Add sort indicators to headers
        const headers = document.querySelectorAll('#lecturerTable thead th');
        headers.forEach((header, index) => {
            if (index < 6) { // Add to all except Actions column
                const indicator = document.createElement('span');
                indicator.className = 'sort-indicator';
                header.appendChild(indicator);
                
                // Add hover effect
                header.style.cursor = 'pointer';
                header.addEventListener('mouseenter', () => {
                    header.style.backgroundColor = 'var(--medium-gray)';
                });
                header.addEventListener('mouseleave', () => {
                    header.style.backgroundColor = '';
                });
            }
        });
        
        // Add animation for rows
        const rows = document.querySelectorAll('#lecturerTableBody tr.lecturer-row');
        rows.forEach((row, index) => {
            row.style.animationDelay = `${index * 0.1}s`;
            row.style.animation = 'fadeIn 0.3s ease forwards';
        });
        
        // Add CSS animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(10px); }
                to { opacity: 1; transform: translateY(0); }
            }
        `;
        document.head.appendChild(style);
    });
</script>