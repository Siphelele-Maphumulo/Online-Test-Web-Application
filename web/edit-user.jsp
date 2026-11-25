<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="app-theme.css">
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

String targetUserIdParam = request.getParameter("uid");
User targetUser = null;
if (targetUserIdParam != null && !targetUserIdParam.trim().isEmpty()) {
    targetUser = pDAO.getUserDetails(targetUserIdParam);
}

ArrayList<String> editPageCourses = pDAO.getAllCourseNames();
String flashMessage = (String) session.getAttribute("message");
String errorMessage = (String) session.getAttribute("error");
if (flashMessage != null) {
    session.removeAttribute("message");
}
if (errorMessage != null) {
    session.removeAttribute("error");
}

String targetInitials = "?";
String backLink = "adm-page.jsp?pgprt=1";
String currentCourseName = null;
if (targetUser != null) {
    String first = targetUser.getFirstName() != null ? targetUser.getFirstName().trim() : "";
    String last = targetUser.getLastName() != null ? targetUser.getLastName().trim() : "";
    if (!first.isEmpty()) {
        targetInitials = first.substring(0, 1).toUpperCase();
    }
    if (!last.isEmpty()) {
        targetInitials = targetInitials.equals("?") ? last.substring(0, 1).toUpperCase() : targetInitials + last.substring(0, 1).toUpperCase();
    }
    if ("?".equals(targetInitials) && targetUser.getUserName() != null && !targetUser.getUserName().trim().isEmpty()) {
        targetInitials = targetUser.getUserName().substring(0, 1).toUpperCase();
    }

    if ("lecture".equalsIgnoreCase(targetUser.getType())) {
        backLink = "adm-page.jsp?pgprt=6";
    }

    currentCourseName = targetUser.getCourseName();
}
%>

<!--style-->
<style>
    /* CSS Variables - Matches accounts.jsp / courses.jsp */
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
        --border-color: #e5e7eb;

        /* Semantic Colors */
        --success: #059669;
        --success-light: #d1fae5;
        --warning: #d97706;
        --warning-light: #fef3c7;
        --error: #dc2626;
        --error-light: #fee2e2;
        --info: #0891b2;
        --info-light: #e0f2fe;

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
        --radius-lg: 16px;
        --radius-xl: 24px;
        --radius-full: 9999px;

        /* Shadows */
        --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);
        --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
        --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);

        /* Transitions */
        --transition-fast: 0.15s ease;
        --transition-normal: 0.2s ease;
        --transition-slow: 0.3s ease;
    }

    /* Reset and Base Styles */
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        line-height: 1.5;
        color: var(--text-dark);
        background-color: var(--light-gray);
    }

    /* Layout */
    .dashboard-container { display: flex; min-height: 100vh; }

    /* Sidebar - Matches accounts.jsp / courses.jsp */
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

    .nav-item i { width: 20px; text-align: center; }

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

    /* Page Header - Matches accounts.jsp */
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

    .header-actions { display: flex; gap: var(--spacing-md); }

    /* Alert Messages */
    .alert {
        background: linear-gradient(90deg, var(--success-light), #ecfdf5);
        border-left: 4px solid var(--success);
        color: var(--text-dark);
        padding: var(--spacing-lg);
        border-radius: var(--radius-md);
        margin-bottom: var(--spacing-xl);
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        font-size: 14px;
        box-shadow: var(--shadow-sm);
    }

    .alert-success {
        background: linear-gradient(90deg, var(--success-light), #ecfdf5);
        border-left-color: var(--success);
    }
    .alert-success i { color: var(--success); }

    .alert-error {
        background: linear-gradient(90deg, var(--error-light), #fef2f2);
        border-left-color: var(--error);
    }
    .alert-error i { color: var(--error); }

    /* Empty State */
    .empty-state {
        text-align: center;
        padding: var(--spacing-2xl) var(--spacing-xl);
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
    }
    .empty-state i {
        font-size: 64px;
        color: var(--dark-gray);
        margin-bottom: var(--spacing-lg);
        opacity: 0.5;
    }
    .empty-state h2 {
        font-size: 24px;
        font-weight: 600;
        margin-bottom: var(--spacing-md);
        color: var(--text-dark);
    }
    .empty-state p {
        color: var(--dark-gray);
        margin-bottom: var(--spacing-xl);
        max-width: 400px;
        margin-left: auto;
        margin-right: auto;
    }

    /* User Edit Grid */
    .user-edit-grid {
        display: grid;
        grid-template-columns: 350px 1fr;
        gap: var(--spacing-lg);
        margin-bottom: var(--spacing-lg);
    }
    @media (max-width: 1024px) { .user-edit-grid { grid-template-columns: 1fr; } }

    /* Summary Card */
        /* Summary Card ? compact */
    .user-summary-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        padding: 16px 18px;
        height: fit-content;
        position: sticky;
        top: var(--spacing-lg);
    }

    .summary-header {
        display: flex;
        align-items: center;
        gap: 10px;
        padding-bottom: 10px;
        margin-bottom: 10px;
        border-bottom: 1px solid var(--medium-gray);
    }

    .summary-avatar {
        width: 52px;
        height: 52px;
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--white);
        font-size: 18px;
        font-weight: 600;
        flex-shrink: 0;
        box-shadow: 0 2px 6px rgba(9, 41, 77, 0.1);
    }

    .summary-header h2 {
        margin: 0 0 2px 0;
        font-size: 16px;
        font-weight: 600;
        color: var(--text-dark);
        line-height: 1.25;
    }

    .summary-header p {
        color: var(--dark-gray);
        font-size: 12px;
        margin-bottom: 3px;
        display: flex;
        align-items: center;
        gap: 3px;
        line-height: 1.3;
        word-break: break-word;
    }
    .summary-header p i { color: var(--dark-gray); font-size: 11px; }

    /* Role Badges */
    .role-badge {
        display: inline-block;
        padding: 2px 7px;
        border-radius: 10px;
        font-size: 10.5px;
        font-weight: 500;
        color: var(--white);
        line-height: 1.3;
    }
    .role-student { background: var(--dark-gray); }
    .role-lecture { background: var(--info); }
    .role-admin   { background: var(--success); }

    /* Summary Details */
    .summary-details { list-style: none; }
    .summary-details li {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 4px 0;
        border-bottom: 1px solid var(--light-gray);
        font-size: 12px;
        gap: 8px;
    }
    .summary-details li:last-child { border-bottom: none; }

    .summary-details .label {
        font-weight: 600;
        color: var(--dark-gray);
        font-size: 11.5px;
        display: flex;
        align-items: center;
        gap: 4px;
        flex-shrink: 0;
        white-space: nowrap;
    }
    .summary-details .label i {
        width: 12px;
        color: var(--dark-gray);
        font-size: 10.5px;
        text-align: center;
        flex-shrink: 0;
    }

    .summary-details span:last-child {
        font-weight: 500;
        color: var(--text-dark);
        font-size: 12px;
        text-align: right;
        max-width: 160px;
        word-break: break-word;
        overflow-wrap: anywhere;
    }

    /* User Form Card */
    /* User Form Card ? compact */
    .user-form-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        padding: 16px 18px;
    }

    .user-form-card h3 {
        font-size: 14px;
        font-weight: 600;
        color: var(--text-dark);
        margin-bottom: 10px;
        padding-bottom: 6px;
        border-bottom: 1px solid var(--medium-gray);
    }

    /* Form Grid */
    .form-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 10px;
        margin-bottom: 14px;
    }
    @media (max-width: 768px) { .form-grid { grid-template-columns: 1fr; } }

    .form-group { display: flex; flex-direction: column; }

    .form-label {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 11.5px;
        margin-bottom: 2px;
        display: flex;
        align-items: center;
        gap: 3px;
        line-height: 1.3;
    }
    .form-label i {
        color: var(--dark-gray);
        width: 12px;
        font-size: 10.5px;
        text-align: center;
        flex-shrink: 0;
    }

    .form-input {
        padding: 7px 10px;
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        font-size: 13px;
        transition: all var(--transition-fast);
        width: 100%;
        background: var(--white);
        font-family: inherit;
        color: var(--text-dark);
        line-height: 1.35;
    }
    .form-input:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }
    .form-input:disabled {
        background: var(--light-gray);
        cursor: not-allowed;
        opacity: 0.7;
    }

    /* Password Field */
    .password-field { position: relative; }
    .password-toggle {
        position: absolute;
        right: 8px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: var(--dark-gray);
        cursor: pointer;
        padding: 3px;
        font-size: 12px;
        transition: color var(--transition-fast);
    }
    .password-toggle:hover { color: var(--text-dark); }

    /* Input Hints */
    .input-hint {
        display: block;
        margin-top: 2px;
        font-size: 11px;
        color: var(--dark-gray);
        line-height: 1.3;
    }
    .input-hint i { color: var(--dark-gray); font-size: 10px; }

    /* Form Actions */
    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 6px;
        padding-top: 10px;
        border-top: 1px solid var(--medium-gray);
        margin-top: 10px;
        flex-wrap: wrap;
    }

    /* Buttons ? compact */
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 5px;
        padding: 7px 14px;
        border-radius: var(--radius-sm);
        font-size: 12.5px;
        font-weight: 500;
        text-decoration: none;
        cursor: pointer;
        border: none;
        transition: all var(--transition-normal);
        line-height: 1.35;
        white-space: nowrap;
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

    .btn-error {
        background: linear-gradient(90deg, var(--error), #ef4444);
        color: var(--white);
    }
    .btn-error:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
    }

    /* Loading State */
    .loading { opacity: 0.7; pointer-events: none; }
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

    /* Form error style */
    .form-input.error {
        border-color: #dc3545 !important;
        box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25) !important;
    }

    /* Alert close button */
    .alert-close-btn:hover {
        opacity: 1 !important;
        color: #dc2626 !important;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .dashboard-container { flex-direction: column; }

        .sidebar { width: 100%; height: auto; position: static; }

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

        .main-content { padding: var(--spacing-md); }

        .page-header {
            flex-direction: column;
            gap: var(--spacing-md);
            text-align: center;
        }

        .header-actions { width: 100%; justify-content: center; }

        .user-summary-card,
        .user-form-card { padding: var(--spacing-md); }

        .summary-header {
            flex-direction: column;
            text-align: center;
            gap: var(--spacing-sm);
        }

        .form-actions { flex-direction: column; }

        .btn { width: 100%; justify-content: center; }
    }
    
        /* Very small phones ? extra compaction */
    @media (max-width: 480px) {
        .user-summary-card,
        .user-form-card { padding: 12px 14px; }

        .summary-avatar {
            width: 42px;
            height: 42px;
            font-size: 15px;
        }

        .summary-header h2 { font-size: 14px; }

        .summary-header p { font-size: 11.5px; }

        .summary-details .label { font-size: 10.5px; }

        .summary-details .label i { font-size: 10px; width: 11px; }

        .summary-details span:last-child { font-size: 11.5px; }

        .form-grid { gap: 7px; }

        .form-label { font-size: 11px; }

        .form-label i { font-size: 10px; width: 11px; }

        .form-input { padding: 6px 9px; font-size: 12px; }

        .form-actions { flex-direction: column; gap: 6px; }

        .form-actions .btn { width: 100%; }

        .password-toggle { right: 6px; font-size: 11px; }
    }

    /* Focus Styles */
    *:focus { outline: 2px solid var(--accent-blue); outline-offset: 2px; }
    *:focus:not(.focus-visible) { outline: none; }
</style>

<div class="dashboard-container">
    <!-- Sidebar Navigation - Matches accounts.jsp / courses.jsp -->
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
            <a href="adm-page.jsp?pgprt=1" class="nav-item <%= "adm-page.jsp?pgprt=1".equals(backLink) ? "active" : "" %>">
                <i class="fas fa-user-graduate"></i>
                <h2>Student Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=6" class="nav-item <%= "adm-page.jsp?pgprt=6".equals(backLink) ? "active" : "" %>">
                <i class="fas fa-chalkboard-teacher"></i>
                <h2>Lecture Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=7" class="nav-item">
                <i class="fas fa-users"></i>
                <h2>Registers</h2>
            </a>
            <a href="adm-page.jsp?pgprt=9" class="nav-item">
                <i class="fas fa-user-shield"></i>
                <h2>Proctoring</h2>
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <header class="page-header edit-header">
            <div class="page-title">
                <i class="fas fa-user-edit"></i>
                Edit Account
            </div>
            <div class="header-actions">
                <a href="<%= backLink %>" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i>
                    Back to Accounts
                </a>
            </div>
        </header>

        <% if (flashMessage != null && !flashMessage.isEmpty()) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <%= flashMessage %>
        </div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-circle"></i>
            <%= errorMessage %>
        </div>
        <% } %>

        <% if (targetUser == null) { %>
        <div class="empty-state">
            <i class="fas fa-user-slash"></i>
            <h2>User not found</h2>
            <p>The requested account could not be located. Please return to the accounts list.</p>
            <a href="adm-page.jsp?pgprt=1" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i>
                Back to Student Accounts
            </a>
        </div>
        <% } else { %>
        <section class="user-edit-grid">
            <div class="user-summary-card">
                <div class="summary-header">
                    <div class="summary-avatar" id="summaryAvatar"><%= targetInitials %></div>
                    <div>
                        <h2 id="summaryName"><%= (targetUser.getFirstName() != null ? targetUser.getFirstName() : "") %> <%= (targetUser.getLastName() != null ? targetUser.getLastName() : "") %></h2>
                        <p id="summaryEmail"><i class="fas fa-envelope"></i> <%= (targetUser.getEmail() != null ? targetUser.getEmail() : "Not provided") %></p>
                        <span id="summaryType" class="role-badge role-<%= (targetUser.getType() != null ? targetUser.getType().toLowerCase() : "student") %>">
                            <%= (targetUser.getType() != null ? targetUser.getType().substring(0, 1).toUpperCase() + targetUser.getType().substring(1) : "Student") %>
                        </span>
                    </div>
                </div>

            <ul class="summary-details">
                <li>
                    <span class="label"><i class="fas fa-id-card"></i> Username</span>
                    <span id="summaryUsername"><%= (targetUser.getUserName() != null ? targetUser.getUserName() : "") %></span>
                </li>
                <li>
                    <span class="label"><i class="fas fa-phone"></i> Contact</span>
                    <span id="summaryContact"><%= (targetUser.getContact() != null && !targetUser.getContact().isEmpty() ? targetUser.getContact() : "Not provided") %></span>
                </li>
                <li>
                    <span class="label"><i class="fas fa-city"></i> City</span>
                    <span id="summaryCity"><%= (targetUser.getCity() != null && !targetUser.getCity().isEmpty() ? targetUser.getCity() : "Not provided") %></span>
                </li>
                <li>
                    <span class="label"><i class="fas fa-map-marker-alt"></i> Address</span>
                    <span id="summaryAddress"><%= (targetUser.getAddress() != null && !targetUser.getAddress().isEmpty() ? targetUser.getAddress() : "Not provided") %></span>
                </li>
                <li id="summaryCourseRow" style="<%= ("lecture".equalsIgnoreCase(targetUser.getType()) ? "" : "display: none;") %>">
                    <span class="label"><i class="fas fa-book"></i> Course</span>
                    <span id="summaryCourse"><%= (currentCourseName != null && !currentCourseName.isEmpty() ? currentCourseName : "No course assigned") %></span>
                </li>
                <li>
                    <span class="label"><i class="fas fa-clock"></i> Last Updated</span>
                    <span><%= targetUser.getUserId() > 0 ? "Updates take effect immediately" : "" %></span>
                </li>
            </ul>

            </div>

            <div class="user-form-card">
                <h3>Update Account Details</h3>
                <form id="editUserForm" action="controller.jsp" method="post" onsubmit="return validateForm()">
                    <input type="hidden" name="page" value="accounts">
                    <input type="hidden" name="operation" value="edit">
                    <input type="hidden" name="uid" value="<%= targetUser.getUserId() %>">
                    <input type="hidden" name="original_type" value="<%= (targetUser.getType() != null ? targetUser.getType() : "") %>">

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label" for="editFname"><i class="fas fa-user"></i> First Name</label>
                            <input type="text" id="editFname" name="fname" class="form-input" 
                                   value="<%= (targetUser.getFirstName() != null ? targetUser.getFirstName() : "") %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editLname"><i class="fas fa-user"></i> Last Name</label>
                            <input type="text" id="editLname" name="lname" class="form-input" 
                                   value="<%= (targetUser.getLastName() != null ? targetUser.getLastName() : "") %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editUname"><i class="fas fa-at"></i> Username</label>
                            <input type="text" id="editUname" name="uname" class="form-input" 
                                   value="<%= (targetUser.getUserName() != null ? targetUser.getUserName() : "") %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editEmail"><i class="fas fa-envelope"></i> Email</label>
                            <input type="email" id="editEmail" name="email" class="form-input" 
                                   value="<%= (targetUser.getEmail() != null ? targetUser.getEmail() : "") %>" required>
                        </div>

                        <div class="form-group" style="grid-column: span 2;">
                            <label class="form-label" for="editPassword"><i class="fas fa-lock"></i> Password</label>
                            <div class="password-field">
                                <input type="password" id="editPassword" name="pass" class="form-input" 
                                       placeholder="Leave blank to keep current password">
                                <button type="button" class="password-toggle" id="passwordToggle">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                            <small class="input-hint"><i class="fas fa-info-circle"></i> Leave blank if you do not want to change the password.</small>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editType"><i class="fas fa-user-tag"></i> User Type</label>
                            <select id="editType" name="type" class="form-input" required>
                                <option value="student" <%= ("student".equalsIgnoreCase(targetUser.getType()) ? "selected" : "") %>>Student</option>
                                <option value="lecture" <%= ("lecture".equalsIgnoreCase(targetUser.getType()) ? "selected" : "") %>>Lecturer</option>
                                <option value="admin" <%= ("admin".equalsIgnoreCase(targetUser.getType()) ? "selected" : "") %>>Administrator</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editContact"><i class="fas fa-phone"></i> Contact Number</label>
                            <input type="tel" id="editContact" name="contactno" class="form-input" 
                                   value="<%= (targetUser.getContact() != null ? targetUser.getContact() : "") %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editCity"><i class="fas fa-city"></i> City</label>
                            <input type="text" id="editCity" name="city" class="form-input" 
                                   value="<%= (targetUser.getCity() != null ? targetUser.getCity() : "") %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editAddress"><i class="fas fa-map-marker-alt"></i> Address</label>
                            <input type="text" id="editAddress" name="address" class="form-input" 
                                   value="<%= (targetUser.getAddress() != null ? targetUser.getAddress() : "") %>">
                        </div>

                        <div class="form-group" id="courseField" style="grid-column: span 2; <%= ("lecture".equalsIgnoreCase(targetUser.getType()) ? "" : "display: none;") %>">
                            <label class="form-label" for="editCourseName"><i class="fas fa-book"></i> Course Assignment</label>
                            <select id="editCourseName" name="course_name" class="form-input">
                                <option value="">-- No Course Assignment --</option>
                                <% if (editPageCourses != null) {
                                       for (String course : editPageCourses) {
                                           if (course != null && !course.trim().isEmpty()) {
                                %>
                                <option value="<%= course %>" <%= (currentCourseName != null && currentCourseName.equalsIgnoreCase(course)) ? "selected" : "" %>><%= course %></option>
                                <%         }
                                       }
                                   }
                                %>
                            </select>
                            <small class="input-hint"><i class="fas fa-info-circle"></i> Only applicable for lecturers.</small>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="btn btn-outline" id="cancelEditBtn">
                            <i class="fas fa-times"></i>
                            Cancel
                        </button>
                        <button type="button" class="btn btn-secondary" id="resetBtn">
                            <i class="fas fa-redo"></i>
                            Reset
                        </button>
                        <button type="submit" class="btn btn-primary" id="saveBtn">
                            <i class="fas fa-save"></i>
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </section>
        <% } %>
    </main>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- JavaScript for enhanced functionality -->
<script>
    // Store original form values
    let originalFormValues = {};
    
    // Initialize when page loads
    document.addEventListener('DOMContentLoaded', function() {
        setupFormFunctionality();
        setupUserTypeChangeListener();
        setupPasswordToggle();
        storeOriginalValues();
    });
    
    // Store original form values
    function storeOriginalValues() {
        const form = document.getElementById('editUserForm');
        if (form) {
            const inputs = form.querySelectorAll('input, select');
            inputs.forEach(input => {
                if (input.type !== 'submit' && input.type !== 'button') {
                    originalFormValues[input.name || input.id] = input.value;
                }
            });
        }
    }
    
    // Setup form functionality
    function setupFormFunctionality() {
        // Cancel button
        const cancelBtn = document.getElementById('cancelEditBtn');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', function(e) {
                e.preventDefault();
                if (confirm('Are you sure you want to cancel? Any unsaved changes will be lost.')) {
                    window.location.href = '<%= backLink %>';
                }
            });
        }
        
        // Reset button
        const resetBtn = document.getElementById('resetBtn');
        if (resetBtn) {
            resetBtn.addEventListener('click', function(e) {
                e.preventDefault();
                resetForm();
            });
        }
        
        // Save button - form validation before submission
        const saveBtn = document.getElementById('saveBtn');
        if (saveBtn) {
            saveBtn.addEventListener('click', function(e) {
                if (!validateForm()) {
                    e.preventDefault();
                    alert('Please fill in all required fields correctly.');
                    return false;
                }
                return true;
            });
        }
    }
    
    // Setup user type change listener to show/hide course field
    function setupUserTypeChangeListener() {
        const userTypeSelect = document.getElementById('editType');
        const courseField = document.getElementById('courseField');
        
        if (userTypeSelect && courseField) {
            userTypeSelect.addEventListener('change', function() {
                if (this.value === 'lecture') {
                    courseField.style.display = 'block';
                } else {
                    courseField.style.display = 'none';
                    // Clear course selection when not a lecturer
                    const courseSelect = document.getElementById('editCourseName');
                    if (courseSelect) {
                        courseSelect.value = '';
                    }
                }
            });
        }
    }
    
    // Setup password toggle visibility
    function setupPasswordToggle() {
        const passwordToggle = document.getElementById('passwordToggle');
        const passwordField = document.getElementById('editPassword');
        
        if (passwordToggle && passwordField) {
            passwordToggle.addEventListener('click', function() {
                if (passwordField.type === 'password') {
                    passwordField.type = 'text';
                    this.innerHTML = '<i class="fas fa-eye-slash"></i>';
                } else {
                    passwordField.type = 'password';
                    this.innerHTML = '<i class="fas fa-eye"></i>';
                }
            });
        }
    }
    
    // Reset form to original values
    function resetForm() {
        if (confirm('Are you sure you want to reset the form? All changes will be lost.')) {
            const form = document.getElementById('editUserForm');
            if (form) {
                // Restore original values
                for (const [name, value] of Object.entries(originalFormValues)) {
                    const input = form.querySelector(`[name="${name}"]`) || document.getElementById(name);
                    if (input) {
                        input.value = value;
                        
                        // Trigger change event for select elements
                        if (input.tagName === 'SELECT') {
                            input.dispatchEvent(new Event('change'));
                        }
                    }
                }
                
                // Clear password field
                const passwordField = document.getElementById('editPassword');
                if (passwordField) {
                    passwordField.value = '';
                }
                
                alert('Form has been reset to original values.');
            }
        }
    }
    
    // Validate entire form
    function validateForm() {
        const form = document.getElementById('editUserForm');
        const requiredFields = form.querySelectorAll('[required]');
        let isValid = true;

        requiredFields.forEach(field => {
            if (!field.value.trim()) {
                field.classList.add('error');
                isValid = false;
            } else {
                field.classList.remove('error');
            }
        });

        // Email regex
        const emailField = form.querySelector('[name="email"]');
        if (emailField && emailField.value) {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!re.test(emailField.value)) isValid = false;
        }

        // Password length check if provided
        const passField = form.querySelector('[name="pass"]');
        if (passField && passField.value && passField.value.length < 6) isValid = false;

        return isValid;
    }
</script>

<%-- Add auto-close functionality for alert messages --%>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Auto-close alert messages after 5 seconds
    const alerts = document.querySelectorAll('.alert');
    
    alerts.forEach(alert => {
        // Add close button to alerts
        const closeButton = document.createElement('button');
        closeButton.innerHTML = '&times;';
        closeButton.className = 'alert-close-btn';
        closeButton.style.cssText = `
            background: none;
            border: none;
            font-size: 20px;
            font-weight: bold;
            cursor: pointer;
            color: inherit;
            opacity: 0.7;
            margin-left: auto;
            padding: 0 5px;
        `;
        closeButton.addEventListener('click', function() {
            closeAlert(alert);
        });
        alert.appendChild(closeButton);
        
        // Auto-close after 5 seconds
        setTimeout(() => {
            closeAlert(alert);
        }, 5000);
    });
    
    // Function to close alert with fade-out animation
    function closeAlert(alertElement) {
        if (alertElement && alertElement.parentElement) {
            alertElement.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
            alertElement.style.opacity = '0';
            alertElement.style.transform = 'translateY(-10px)';
            setTimeout(() => {
                if (alertElement.parentElement) {
                    alertElement.remove();
                }
            }, 300);
        }
    }
});

// Also close alerts when clicking anywhere outside
document.addEventListener('click', function(event) {
    if (!event.target.closest('.alert') && !event.target.closest('.alert-close-btn')) {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            closeAlert(alert);
        });
    }
});
</script>

</body>
</html>