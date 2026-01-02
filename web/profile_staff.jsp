<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- 
    Professional Profile Page
    Author: [Your Name/Team Name]
    Version: 1.0
    Last Modified: <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>
--%>

<%-- Database Access --%>
<%
    // Use Singleton pattern for database access
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    
    // Validate session
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?error=session_expired");
        return;
    }
    
    String userId = session.getAttribute("userId").toString();
    User user = null;
    String userInitials = "";
    String userRoleClass = "";
    String userRoleDisplay = "";
    String userIcon = "";
    
    try {
        user = pDAO.getUserDetails(userId);
        
        if (user == null) {
            response.sendRedirect("login.jsp?error=user_not_found");
            return;
        }
        
        // Generate user initials safely
        if (user.getFirstName() != null && !user.getFirstName().isEmpty() && 
            user.getLastName() != null && !user.getLastName().isEmpty()) {
            userInitials = user.getFirstName().substring(0, 1) + user.getLastName().substring(0, 1);
        } else {
            userInitials = "U";
        }
        
        // Set user role and icons
        String userType = user.getType();
        if (userType != null) {
            switch(userType.toLowerCase()) {
                case "admin":
                    userRoleClass = "admin-badge";
                    userRoleDisplay = "Administrator";
                    userIcon = "fa-user-shield";
                    break;
                case "lecture":
                    userRoleClass = "lecturer-badge";
                    userRoleDisplay = "Lecturer";
                    userIcon = "fa-chalkboard-teacher";
                    break;
                default:
                    userRoleClass = "student-badge";
                    userRoleDisplay = "Student";
                    userIcon = "fa-user-graduate";
                    break;
            }
        }
        
    } catch (Exception e) {
        // Log error and redirect
        // Consider using a logging framework like Log4j
        response.sendRedirect("error.jsp?code=500");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="User Profile Management">
    <title><%= userRoleDisplay %> Profile | MUT System</title>
    
    <!-- Font Awesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" 
          integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" 
          crossorigin="anonymous" referrerpolicy="no-referrer" />
    
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MUT Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* CSS Variables for Maintainability */
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
        
        /* Reset and Base Styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.5;
            background-color: var(--light-gray);
        }
        
        /* Layout Structure */
        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }
        
        /* Sidebar Styles */
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
        
        .mut-logo:hover {
            transform: scale(1.05);
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
        
        .role-badge {
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
        
        /* Cards */
        .card {
            background: var(--white);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--medium-gray);
            overflow: hidden;
            transition: transform var(--transition-normal), box-shadow var(--transition-normal);
        }
        
        .card:hover {
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
        
        .card-content {
            padding: var(--spacing-lg);
        }
        
        /* Profile Card */
        .profile-card {
            max-width: 700px;
            margin: 0 auto;
        }
        
        .profile-header {
            display: flex;
            align-items: center;
            gap: var(--spacing-lg);
            padding-bottom: var(--spacing-lg);
            margin-bottom: var(--spacing-lg);
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .avatar {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 24px;
            font-weight: 600;
            flex-shrink: 0;
            box-shadow: 0 4px 12px rgba(9, 41, 77, 0.15);
        }
        
        .user-info h2 {
            margin: 0 0 var(--spacing-xs) 0;
            font-size: 20px;
            font-weight: 600;
        }
        
        .user-email {
            color: var(--dark-gray);
            font-size: 14px;
            margin-bottom: var(--spacing-md);
        }
        
        /* Profile Info Grid */
        .profile-info {
            display: grid;
            gap: 0;
        }
        
        .info-item {
            display: flex;
            align-items: center;
            padding: var(--spacing-md) 0;
            border-bottom: 1px solid var(--light-gray);
            transition: background-color var(--transition-fast);
        }
        
        .info-item:hover {
            background-color: var(--light-gray);
        }
        
        .info-item:last-child {
            border-bottom: none;
        }
        
        .info-label {
            min-width: 140px;
            padding: var(--spacing-sm) var(--spacing-md);
            background: var(--light-gray);
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 13px;
            color: var(--dark-gray);
            margin-right: var(--spacing-lg);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
            border: 1px solid var(--medium-gray);
        }
        
        .info-value {
            flex: 1;
            font-weight: 500;
            color: var(--text-dark);
            font-size: 14px;
        }
        
        /* Buttons */
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
        
        .btn-error {
            background: linear-gradient(90deg, var(--error), #ef4444);
            color: var(--white);
        }
        
        .btn-error:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
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
        
        .button-group {
            display: flex;
            gap: var(--spacing-md);
            justify-content: center;
            margin-top: var(--spacing-lg);
            padding-top: var(--spacing-lg);
            border-top: 1px solid var(--medium-gray);
        }
        
        /* Form Styles */
        .form-grid {
            display: grid;
            gap: var(--spacing-md);
            margin-bottom: var(--spacing-lg);
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-label {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 13px;
            margin-bottom: var(--spacing-xs);
            display: flex;
            align-items: center;
            gap: var(--spacing-xs);
        }
        
        .form-control {
            padding: 10px 12px;
            border: 1px solid var(--medium-gray);
            border-radius: var(--radius-sm);
            font-size: 14px;
            transition: all var(--transition-fast);
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
        }
        
        .form-select {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364748b' d='M2 4l4 4 4-4z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
            background-size: 12px;
            padding-right: 32px;
        }
        
        /* Table Styles */
        .data-table {
            width: 100%;
            border-collapse: collapse;
            background: var(--white);
        }
        
        .data-table thead th {
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
        
        .data-table thead th:hover {
            background: var(--medium-gray);
        }
        
        .data-table tbody td {
            padding: var(--spacing-md);
            border-bottom: 1px solid var(--light-gray);
            vertical-align: middle;
            color: var(--dark-gray);
            font-size: 13px;
        }
        
        .data-table tbody tr {
            transition: background-color var(--transition-fast);
        }
        
        .data-table tbody tr:hover {
            background-color: var(--light-gray);
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
        
        .badge-success {
            background: linear-gradient(90deg, var(--success), #10b981);
        }
        
        .badge-error {
            background: linear-gradient(90deg, var(--error), #ef4444);
        }
        
        .badge-warning {
            background: linear-gradient(90deg, var(--warning), #f59e0b);
        }
        
        .badge-info {
            background: linear-gradient(90deg, var(--info), #0ea5e9);
        }
        
        .badge-neutral {
            background: var(--dark-gray);
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
        
        /* Filter Container */
        .filter-container {
            background: var(--white);
            border-radius: var(--radius-md);
            border: 1px solid var(--medium-gray);
            padding: var(--spacing-lg);
            margin-bottom: var(--spacing-lg);
            box-shadow: var(--shadow-sm);
        }
        
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--spacing-md);
            margin-bottom: var(--spacing-md);
        }
        
        /* Options Grid */
        .options-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: var(--spacing-md);
            margin: var(--spacing-md) 0;
        }
        
        .option-item {
            background: var(--light-gray);
            border: 1px solid var(--medium-gray);
            border-radius: var(--radius-sm);
            padding: var(--spacing-md);
            transition: all var(--transition-fast);
            position: relative;
        }
        
        .option-item:hover {
            background: var(--white);
            border-color: var(--dark-gray);
        }
        
        .option-correct {
            border-color: var(--success);
            background: linear-gradient(135deg, rgba(5, 150, 105, 0.1), rgba(16, 185, 129, 0.1));
        }
        
        .option-correct::after {
            content: "✓ Correct";
            position: absolute;
            top: -10px;
            right: 8px;
            background: linear-gradient(90deg, var(--success), #10b981);
            color: var(--white);
            padding: 4px 10px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 500;
            z-index: 1;
        }
        
        /* Student/Lecturer Info */
        .user-name {
            font-weight: 600;
            color: var(--white);
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: var(--spacing-md);
        }
        
        .user-avatar {
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
        
        /* No Results Message */
        .no-results {
            text-align: center;
            padding: var(--spacing-xl);
            color: var(--dark-gray);
            font-style: italic;
            font-size: 14px;
            background: var(--white);
            border-radius: var(--radius-md);
            border: 1px solid var(--medium-gray);
            box-shadow: var(--shadow-sm);
        }
        
        /* Results Count */
        .results-count {
            text-align: center;
            padding: var(--spacing-md);
            color: var(--dark-gray);
            font-size: 13px;
            border-top: 1px solid var(--medium-gray);
            background: var(--light-gray);
        }
        
        /* User Role Badge */
        .user-role {
            display: inline-block;
            background: var(--light-gray);
            color: var(--text-dark);
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
        
        /* Responsive Design */
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
            
            .profile-header {
                flex-direction: column;
                text-align: center;
            }
            
            .info-item {
                flex-direction: column;
                align-items: flex-start;
                gap: var(--spacing-sm);
            }
            
            .info-label {
                width: 100%;
                margin-right: 0;
            }
            
            .button-group {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
            
            .filter-grid {
                grid-template-columns: 1fr;
            }
            
            .options-grid {
                grid-template-columns: 1fr;
            }
            
            .data-table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
            }
            
            .action-buttons {
                flex-direction: column;
                gap: var(--spacing-xs);
            }
            
            .user-name {
                flex-direction: column;
                align-items: flex-start;
                gap: var(--spacing-sm);
                color: var(--text-white);
            }
        }
        
        @media (max-width: 480px) {
            .main-content {
                padding: var(--spacing-md);
            }
            
            .page-header {
                flex-direction: column;
                gap: var(--spacing-md);
                text-align: center;
            }
            
            .card-content {
                padding: var(--spacing-md);
            }
            
            .data-table thead th,
            .data-table tbody td {
                padding: var(--spacing-sm);
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
        
        /* Utility Classes */
        .text-center { text-align: center; }
        .mt-1 { margin-top: var(--spacing-sm); }
        .mt-2 { margin-top: var(--spacing-md); }
        .mt-3 { margin-top: var(--spacing-lg); }
        .mb-1 { margin-bottom: var(--spacing-sm); }
        .mb-2 { margin-bottom: var(--spacing-md); }
        .mb-3 { margin-bottom: var(--spacing-lg); }
        
        /* Role-specific Badge Colors */
        .admin-badge { background: linear-gradient(135deg, var(--success), #10b981); }
        .lecturer-badge { background: linear-gradient(135deg, var(--info), #0ea5e9); }
        .student-badge { background: linear-gradient(135deg, var(--dark-gray), #94a3b8); }
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
                <% if(user.getType().equalsIgnoreCase("admin") || user.getType().equalsIgnoreCase("lecture")) { %>
                    <a href="adm-page.jsp?pgprt=0" class="nav-item active">
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
                        <i class="fas fa-users"></i>
                        <h2>Accounts</h2>
                    </a>
                     <a href="adm-page.jsp?pgprt=7" class="nav-item">
                        <i class="fas fa-users"></i>
                        <h2>Registers</h2>
                    </a>
                <% } else { %>
                    <a href="std-page.jsp?pgprt=0" class="nav-item active">
                        <i class="fas fa-user"></i>
                        <h2>Profile</h2>
                    </a>
                    <a href="std-page.jsp?pgprt=1" class="nav-item">
                        <i class="fas fa-file-alt"></i>
                        <h2>Exams</h2>
                    </a>
                    <a href="std-page.jsp?pgprt=2" class="nav-item">
                        <i class="fas fa-chart-line"></i>
                        <h2>Results</h2>
                    </a>
                   
                <% } %>
            </nav>
        </aside>
        
        <!-- Main Content -->
        <main class="main-content">
            <!-- Page Header -->
            <header class="page-header">
                <div class="page-title">
                    <i class="fas fa-user-circle"></i>
                    <%= userRoleDisplay %> Profile
                </div>
                <div class="role-badge <%= userRoleClass %>">
                    <i class="fas <%= userIcon %>"></i>
                    <%= userRoleDisplay %>
                </div>
            </header>
            
            <!-- Profile Card -->
            <div class="card profile-card">
                <div class="card-header">
                    <span><i class="fas fa-id-card"></i> Profile Information</span>
                    <i class="fas fa-user-edit"></i>
                </div>
                
                <% if (request.getParameter("pedt") == null) { %>
                    <!-- View Mode -->
                    <div class="card-content">
                        <div class="profile-header">
                            <div class="avatar">
                                <%= userInitials %>
                            </div>
                            <div class="user-info">
                                <h2><%= user.getFirstName() + " " + user.getLastName() %></h2>
                                <p class="user-email"><%= user.getEmail() %></p>
                                <span class="role-badge <%= userRoleClass %>">
                                    <i class="fas <%= userIcon %>"></i>
                                    <%= userRoleDisplay %>
                                </span>
                            </div>
                        </div>
                        
                        <div class="profile-info">
                            <div class="info-item">
                                <div class="info-label">
                                    <i class="fas fa-user"></i>
                                    Full Name
                                </div>
                                <div class="info-value"><%= user.getFirstName() + " " + user.getLastName() %></div>
                            </div>
                            
                            <div class="info-item">
                                <div class="info-label">
                                    <i class="fas fa-envelope"></i>
                                    Email Address
                                </div>
                                <div class="info-value"><%= user.getEmail() %></div>
                            </div>
                            
                            <div class="info-item">
                                <div class="info-label">
                                    <i class="fas fa-phone"></i>
                                    Contact Number
                                </div>
                                <div class="info-value"><%= user.getContact() != null ? user.getContact() : "Not provided" %></div>
                            </div>
                            
                            <div class="info-item">
                                <div class="info-label">
                                    <i class="fas fa-city"></i>
                                    City
                                </div>
                                <div class="info-value"><%= user.getCity() != null ? user.getCity() : "Not provided" %></div>
                            </div>
                            
                            <div class="info-item">
                                <div class="info-label">
                                    <i class="fas fa-map-marker-alt"></i>
                                    Address
                                </div>
                                <div class="info-value"><%= user.getAddress() != null ? user.getAddress() : "Not provided" %></div>
                            </div>
                            
                            <% if(user.getType().equalsIgnoreCase("lecture")) { 
                                String courseName = user.getCourseName();
                            %>
                                <div class="info-item">
                                    <div class="info-label">
                                        <i class="fas fa-book"></i>
                                        Assigned Course
                                    </div>
                                    <div class="info-value">
                                        <% if (courseName != null && !courseName.isEmpty() && !courseName.equals("null")) { %>
                                            <%= courseName %>
                                        <% } else { %>
                                            <span class="text-muted">No course assigned</span>
                                        <% } %>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                        
                        <div class="button-group">
                            <% if(user.getType().equalsIgnoreCase("admin") || user.getType().equalsIgnoreCase("lecture")) { %>
                                <a href="adm-page.jsp?pgprt=0&pedt=1" class="btn btn-primary">
                                    <i class="fas fa-edit"></i>
                                    Edit Profile
                                </a>
                            <% } else { %>
                                <a href="std-page.jsp?pgprt=0&pedt=1" class="btn btn-primary">
                                    <i class="fas fa-edit"></i>
                                    Edit Profile
                                </a>
                            <% } %>
                        </div>
                    </div>
                <% } else { %>
                    <!-- Edit Mode -->
                    <div class="card-content">
                        <form action="controller.jsp" method="post" class="edit-form">
                            <input type="hidden" name="page" value="profile">
                            <input type="hidden" name="utype" value="<%= user.getType() %>">
                            <input type="hidden" name="fname" value="<%= user.getFirstName() %>">
                            <input type="hidden" name="lname" value="<%= user.getLastName() %>">
                            <input type="hidden" name="email" value="<%= user.getEmail() %>">
                            <input type="hidden" name="pass" value="<%= user.getPassword() %>">
                            
                            <div class="form-grid">
                                <div class="form-group">
                                    <label class="form-label">
                                        <i class="fas fa-phone"></i>
                                        Contact Number
                                    </label>
                                    <input type="tel" name="contactno" 
                                           value="<%= user.getContact() != null ? user.getContact() : "" %>" 
                                           class="form-control" 
                                           placeholder="Enter contact number"
                                           pattern="[0-9+\-\s()]{10,15}"
                                           title="Enter a valid phone number">
                                </div>
                                
                                <div class="form-group">
                                    <label class="form-label">
                                        <i class="fas fa-city"></i>
                                        City
                                    </label>
                                    <input type="text" name="city" 
                                           value="<%= user.getCity() != null ? user.getCity() : "" %>" 
                                           class="form-control" 
                                           placeholder="Enter city"
                                           required>
                                </div>
                                
                                <div class="form-group">
                                    <label class="form-label">
                                        <i class="fas fa-map-marker-alt"></i>
                                        Address
                                    </label>
                                    <input type="text" name="address" 
                                           value="<%= user.getAddress() != null ? user.getAddress() : "" %>" 
                                           class="form-control" 
                                           placeholder="Enter address"
                                           required>
                                </div>
                                
                                <% if(user.getType().equalsIgnoreCase("lecture")) { 
                                    ArrayList<String> allCourses = pDAO.getAllCourseNames();
                                    String currentCourse = user.getCourseName();
                                %>
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="fas fa-book"></i>
                                            Course Assignment
                                        </label>
                                        <select name="course_name" class="form-control form-select">
                                            <option value="">-- Select Course --</option>
                                            <% if (allCourses != null) {
                                                for (String course : allCourses) {
                                                    boolean isSelected = false;
                                                    if (currentCourse != null && !currentCourse.isEmpty() && !currentCourse.equals("null")) {
                                                        isSelected = course.equals(currentCourse);
                                                    }
                                            %>
                                                <option value="<%= course %>" <%= isSelected ? "selected" : "" %>>
                                                    <%= course %>
                                                </option>
                                            <% } } %>
                                        </select>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="button-group">
                                <% if(user.getType().equalsIgnoreCase("admin") || user.getType().equalsIgnoreCase("lecture")) { %>
                                    <a href="adm-page.jsp?pgprt=0" class="btn btn-secondary">
                                        <i class="fas fa-times"></i>
                                        Cancel
                                    </a>
                                <% } else { %>
                                    <a href="std-page.jsp?pgprt=0" class="btn btn-secondary">
                                        <i class="fas fa-times"></i>
                                        Cancel
                                    </a>
                                <% } %>
                                
                                <button type="reset" class="btn btn-outline">
                                    <i class="fas fa-redo"></i>
                                    Reset
                                </button>
                                
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save"></i>
                                    Save Changes
                                </button>
                            </div>
                        </form>
                    </div>
                <% } %>
            </div>
        </main>
    </div>
    
    <!-- JavaScript for enhanced functionality -->
    <script>
        // Form validation
        document.addEventListener('DOMContentLoaded', function() {
            const forms = document.querySelectorAll('form');
            
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    // Add loading state
                    const submitBtn = this.querySelector('button[type="submit"]');
                    if (submitBtn) {
                        submitBtn.classList.add('loading');
                        submitBtn.disabled = true;
                    }
                    
                    // Additional validation can be added here
                });
            });
            
            // Reset form handler
            const resetButtons = document.querySelectorAll('button[type="reset"]');
            resetButtons.forEach(btn => {
                btn.addEventListener('click', function() {
                    const form = this.closest('form');
                    form.reset();
                });
            });
            
            // Add animation to cards
            const cards = document.querySelectorAll('.card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;
                card.style.animation = 'fadeInUp 0.3s ease forwards';
                card.style.opacity = '0';
            });
            
            // Add CSS animation
            const style = document.createElement('style');
            style.textContent = `
                @keyframes fadeInUp {
                    from {
                        opacity: 0;
                        transform: translateY(20px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
            `;
            document.head.appendChild(style);
        });
        
        // Handle window resize for responsive adjustments
        window.addEventListener('resize', function() {
            // Add any responsive adjustments here
        });
    </script>
</body>
</html>