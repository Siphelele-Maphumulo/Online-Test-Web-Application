<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<%@ page isELIgnored="true" %>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>
 
<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
%>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>

         /* CSS Variables for Maintainability - PROFESSIONAL THEME */
        :root {
            /* Primary Colors - Professional Blue Theme */
            --primary-blue: #09294d;
            --secondary-blue: #1a3d6d;
            --accent-blue: #3b82f6;
            --accent-blue-light: #60a5fa;
            
            /* Neutral Colors - Modern Gray Scale */
            --white: #ffffff;
            --light-gray: #f8fafc;
            --medium-gray: #e2e8f0;
            --dark-gray: #64748b;
            --text-dark: #1e293b;
            --border-color: #e5e7eb;
            
            /* Semantic Colors */
            --success: #10b981;
            --success-light: #d1fae5;
            --warning: #f59e0b;
            --warning-light: #fef3c7;
            --error: #ef4444;
            --error-light: #fee2e2;
            --info: #0ea5e9;
            --info-light: #e0f2fe;
            
            /* Spacing - 8px grid */
            --spacing-xs: 4px;
            --spacing-sm: 8px;
            --spacing-md: 16px;
            --spacing-lg: 24px;
            --spacing-xl: 32px;
            --spacing-2xl: 48px;
            
            /* Border Radius - Modern */
            --radius-sm: 6px;
            --radius-md: 10px;
            --radius-lg: 16px;
            --radius-xl: 24px;
            --radius-full: 9999px;
            
            /* Shadows - Material Design inspired */
            --shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            
            /* Transitions */
            --transition-fast: 150ms cubic-bezier(0.4, 0, 0.2, 1);
            --transition-normal: 200ms cubic-bezier(0.4, 0, 0.2, 1);
            --transition-slow: 300ms cubic-bezier(0.4, 0, 0.2, 1);
            
            /* Z-index layers */
            --z-dropdown: 100;
            --z-sticky: 200;
            --z-modal: 300;
            --z-popover: 400;
            --z-tooltip: 500;
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
        
        /* Dashboard Container */
        .dashboard-container {
            display: flex;
            min-height: 100vh;
            background: transparent;
        }
        
    /* Sidebar - Modern Design */
        .sidebar {
            width: 200px;
            background: linear-gradient(180deg, var(--primary-blue) 0%, #0d3060 100%);
            color: var(--white);
            flex-shrink: 0;
            position: fixed; /* Changed from sticky to fixed */
            top: 0;
            left: 0;
            height: 100vh;
            z-index: var(--z-sticky);
            box-shadow: var(--shadow-lg);
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: rgba(255, 255, 255, 0.3) transparent;
        }

        /* Main Content Area - Add margin to account for fixed sidebar */
        .content-area,
        .main-content {
            flex: 1;
            padding: var(--spacing-xl);
            overflow-y: auto;
            background: transparent;
            margin-left: 200px;
            min-height: 100vh;
        }

        /* Responsive Design - Adjust for mobile */
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: static;
            }

            .content-area,
            .main-content {
                margin-left: 0;
                padding: var(--spacing-lg);
            }
        }

        .sidebar::-webkit-scrollbar {
            width: 6px;
        }

        .sidebar::-webkit-scrollbar-track {
            background: transparent;
        }

        .sidebar::-webkit-scrollbar-thumb {
            background-color: rgba(255, 255, 255, 0.3);
            border-radius: var(--radius-full);
        }

        .sidebar-header {
            padding-top: 35%;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
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
            color: rgba(255, 255, 255, 0.85);
            text-decoration: none;
            transition: all var(--transition-normal);
            border-radius: var(--radius-md);
            margin: 0 var(--spacing-sm) var(--spacing-sm);
            font-weight: 500;
            font-size: 14px;
            position: relative;
            overflow: hidden;
        }
        
        .nav-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 4px;
            height: 100%;
            background: var(--accent-blue);
            transform: translateX(-100%);
            transition: transform var(--transition-normal);
        }
        
        .nav-item:hover {
            background: rgba(255, 255, 255, 0.1);
            color: var(--white);
            padding-left: var(--spacing-xl);
        }
        
        .nav-item:hover::before {
            transform: translateX(0);
        }
        
        .nav-item.active {
            background: linear-gradient(90deg, rgba(59, 130, 246, 0.2), rgba(59, 130, 246, 0.1));
            color: var(--white);
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
        }
        
        .nav-item.active::before {
            transform: translateX(0);
        }
        
        .nav-item i {
            width: 20px;
            text-align: center;
            font-size: 16px;
            opacity: 0.9;
        }
        
        .nav-item h2 {
            margin: 0;
            font-size: 14px;
            font-weight: 500;
            letter-spacing: 0.3px;
        }
        
        /* Main Content Area */
        .main-content {
            flex: 1;
            padding: var(--spacing-xl);
            overflow-y: auto;
            background: transparent;
        }
        
        /* Page Header */
        .page-header {
            background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
            border-radius: var(--radius-lg);
            padding: var(--spacing-xl);
            margin-bottom: var(--spacing-xl);
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border-color);
            position: relative;
            overflow: hidden;
        }
        
        .page-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--accent-blue), var(--success));
        }
        
        .page-title {
            display: flex;
            align-items: center;
            gap: var(--spacing-md);
            font-size: 20px;
            font-weight: 600;
            color: var(--text-dark);
        }
        
        .page-title i {
            color: var(--accent-blue);
            background: var(--accent-blue-light);
            padding: var(--spacing-sm);
            border-radius: var(--radius-md);
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
        }
        
        .header-actions {
            display: flex;
            gap: var(--spacing-md);
        }
        
        
        /* Layout Structure */
        .profile-wrapper {
            display: flex;
            min-height: 100vh;
            background: var(--light-gray);
        }
        
        
        .left-menu a {
            display: flex;
            align-items: center;
            gap: var(--spacing-md);
            padding: var(--spacing-md) var(--spacing-lg);
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            transition: all var(--transition-normal);
            border-left: 3px solid transparent;
            font-weight: 500;
            font-size: 14px;
        }
        
        .left-menu a:hover {
            background: rgba(255, 255, 255, 0.1);
            color: var(--white);
            border-left-color: var(--accent-blue);
        }
        
        .left-menu a.active {
            background: rgba(255, 255, 255, 0.15);
            color: var(--white);
            border-left-color: var(--white);
        }
        
        .left-menu a i {
            width: 20px;
            text-align: center;
        }
        
        /* Main Content Area */
        .content-area {
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
        
        /* Profile Card */
        .profile-card {
            background: var(--white);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--medium-gray);
            max-width: 700px;
            margin: 0 auto;
            overflow: hidden;
            transition: transform var(--transition-normal), box-shadow var(--transition-normal);
        }
        
        .profile-card:hover {
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
            font-size: 14px;
            font-weight: 500;
        }
        
        /* Profile Content */
        .profile-content {
            padding: var(--spacing-lg);
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
            color: var(--text-dark);
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
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .info-item:hover {
            background-color: var(--light-gray);
        }
        
        .info-item:last-child {
            border-bottom: none;
        }
        
        .info-tag {
            min-width: 140px;
            padding: var(--spacing-sm) var(--spacing-md);
            background: var(--light-gray);
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 13px;
            color: var(--text-dark);
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
        .form-button {
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
        
        .form-button {
            background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
            color: var(--white);
        }
        
        .form-button:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(9, 41, 77, 0.2);
        }
        
        .button-container {
            display: flex;
            gap: var(--spacing-md);
            justify-content: center;
            margin-top: var(--spacing-lg);
            padding-top: var(--spacing-lg);
            border-top: 1px solid var(--medium-gray);
        }
        
        /* Edit Form */
        .edit-form {
            padding: var(--spacing-lg);
        }
        
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
        
        .form-input {
            padding: 10px 12px;
            border: 1px solid var(--medium-gray);
            border-radius: var(--radius-sm);
            font-size: 14px;
            transition: all var(--transition-fast);
        }
        
        .form-input:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
        }
        
        /* Form Actions */
        .form-actions {
            display: flex;
            justify-content: center;
            gap: var(--spacing-md);
            padding-top: var(--spacing-lg);
            border-top: 1px solid var(--medium-gray);
        }
        
        .cancel-btn {
            background: var(--dark-gray);
            color: var(--white);
            border: none;
            border-radius: var(--radius-sm);
            padding: 10px 20px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all var(--transition-normal);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: var(--spacing-sm);
        }
        
        .cancel-btn:hover {
            background: #475569;
        }
        
        /* Role-specific Badge Colors */
        .admin-badge { background: linear-gradient(135deg, #059669, #10b981) !important; }
        .lecturer-badge { background: linear-gradient(135deg, #0891b2, #0ea5e9) !important; }
        .student-badge { background: linear-gradient(135deg, #475569, #64748b) !important; }
        
        /* User Role Badges */
        .user-role {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
            color: var(--white);
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .profile-wrapper {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                height: auto;
                position: static;
            }
            
            .sidebar-background {
                padding: var(--spacing-md);
            }
            
            .sidebar-header {
                padding: var(--spacing-lg) var(--spacing-md);
            }
            
            .left-menu {
                display: flex;
                overflow-x: auto;
                padding: var(--spacing-sm) 0;
                gap: var(--spacing-sm);
            }
            
            .left-menu a {
                flex-direction: column;
                padding: var(--spacing-sm);
                min-width: 80px;
                text-align: center;
                border-left: none;
                border-bottom: 3px solid transparent;
                font-size: 12px;
            }
            
            .left-menu a.active {
                border-left: none;
                border-bottom-color: var(--white);
            }
            
            .left-menu a:hover {
                border-left: none;
                border-bottom-color: var(--accent-blue);
            }
            
            .content-area {
                margin-left: 0;
                padding: var(--spacing-md);
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
            
            .info-tag {
                width: 100%;
                margin-right: 0;
                min-width: auto;
            }
            
            .form-actions,
            .button-container {
                flex-direction: column;
            }
            
            .form-button,
            .cancel-btn {
                width: 100%;
            }
        }
        
        @media (max-width: 480px) {
            .content-area {
                padding: var(--spacing-sm);
            }
            
            .page-header {
                flex-direction: column;
                gap: var(--spacing-md);
                text-align: center;
                padding: var(--spacing-md);
            }
            
            .profile-content,
            .edit-form {
                padding: var(--spacing-md);
            }
            
            .avatar {
                width: 64px;
                height: 64px;
                font-size: 20px;
            }
            
            .user-info h2 {
                font-size: 18px;
            }
            
            .info-tag,
            .info-value {
                font-size: 13px;
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
</style>

<div class="profile-wrapper">
<%
    User user = pDAO.getUserDetails(session.getAttribute("userId").toString());
    String userInitials = user.getFirstName().substring(0, 1) + user.getLastName().substring(0, 1);
    String userRoleClass = "";
    String userRoleDisplay = "";
    String userIcon = "";
    
    if (user.getType().equalsIgnoreCase("admin")) {
        userRoleClass = "admin-badge";
        userRoleDisplay = "Administrator";
        userIcon = "fa-user-shield";
    } else if (user.getType().equalsIgnoreCase("lecture")) {
        userRoleClass = "lecturer-badge";
        userRoleDisplay = "Lecturer";
        userIcon = "fa-chalkboard-teacher";
    } else {
        userRoleClass = "student-badge";
        userRoleDisplay = "Student";
        userIcon = "fa-user-graduate";
    }

    if (user.getType().equalsIgnoreCase("admin") || user.getType().equalsIgnoreCase("lecture")) {
%>
  <!-- SIDEBAR -->
  <aside class="sidebar">
    <div class="sidebar-header">
        <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
    </div>
    <nav class="sidebar-nav">
      <div class="left-menu">
        <a class="nav-item active" href="adm-page.jsp?pgprt=0">
          <i class="fas fa-user"></i>
          <span>Profile</span>
        </a>
        <a class="nav-item" href="adm-page.jsp?pgprt=2">
          <i class="fas fa-book"></i>
          <span>Courses</span>
        </a>
        <a class="nav-item" href="adm-page.jsp?pgprt=3">
          <i class="fas fa-question-circle"></i>
          <span>Questions</span>
        </a>
        <a class="nav-item" href="adm-page.jsp?pgprt=5">
          <i class="fas fa-chart-bar"></i>
          <span>Students Results</span>
        </a>
        <a class="nav-item" href="adm-page.jsp?pgprt=1">
          <i class="fas fa-users"></i>
          <span>Accounts</span>
        </a>
 
        
      </div>
    </nav>
  </aside>

  <!-- CONTENT AREA -->
  <main class="content-area">
    <!-- Page Header -->
    <header class="page-header">
      <div class="page-title">
        <i class="fas fa-user-circle"></i>
        <%= userRoleDisplay %> Profile
      </div>
      <div class="stats-badge <%= userRoleClass %>">
        <i class="fas <%= userIcon %>"></i>
        <%= userRoleDisplay %>
      </div>
    </header>

<%
    } else {
%>
  <!-- SIDEBAR -->
  <aside class="sidebar">
    <div class="sidebar-header">
        <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
    </div>
    <nav class="sidebar-nav">
      <div class="left-menu">
        <a class="nav-item active" href="std-page.jsp?pgprt=0">
          <i class="fas fa-user"></i>
          <span>Profile</span>
        </a>
        <a class="nav-item" href="std-page.jsp?pgprt=1">
          <i class="fas fa-file-alt"></i>
          <span>Lunch Exam</span>
        </a>
        <a class="nav-item" href="std-page.jsp?pgprt=2">
          <i class="fas fa-chart-line"></i>
          <span>Results</span>
        </a>
        <a class="nav-item" href="std-page.jsp?pgprt=3">
          <i class="fas fa-calendar-check"></i>
          <span>Register</span>
        </a>
        <a class="nav-item" href="std-page.jsp?pgprt=4">
            <i class="fas fa-eye"></i>
            <span>Attendance</span>
        </a>
      </div>
    </nav>
  </aside>

  <!-- CONTENT AREA -->
  <main class="content-area">
    <!-- Page Header -->
    <header class="page-header">
      <div class="page-title">
        <i class="fas fa-user-circle"></i>
        Student Profile
      </div>
      <div class="stats-badge <%= userRoleClass %>">
        <i class="fas <%= userIcon %>"></i>
        <%= userRoleDisplay %>
      </div>
    </header>
<%
    }

    if (request.getParameter("pedt") == null) {
%>
      <!-- Profile Information Card -->
      <div class="profile-card">
        <div class="card-header">
          <span><i class="fas fa-id-card"></i> Profile Information</span>
          <i class="fas fa-user-edit"></i>
        </div>
        <div class="profile-content">
          <!-- Profile Header with Avatar -->
          <div class="profile-header">
            <div class="avatar">
              <%= userInitials %>
            </div>
            <div class="user-info">
              <h2><%= user.getFirstName() + " " + user.getLastName() %></h2>
              <p class="user-email"><%= user.getEmail() %></p>
              <span class="user-role <%= userRoleClass %>">
                <i class="fas <%= userIcon %>"></i>
                <%= userRoleDisplay %>
              </span>
            </div>
          </div>

          <!-- Profile Details -->
          <div class="profile-info">
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-user"></i>
                Full Name
              </div>
              <div class="info-value"><%= user.getFirstName() + " " + user.getLastName() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-envelope"></i>
                Email Address
              </div>
              <div class="info-value"><%= user.getEmail() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-phone"></i>
                Contact Number
              </div>
              <div class="info-value"><%= user.getContact() != null ? user.getContact() : "Not provided" %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-city"></i>
                City
              </div>
              <div class="info-value"><%= user.getCity() != null ? user.getCity() : "Not provided" %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-map-marker-alt"></i>
                Address
              </div>
              <div class="info-value"><%= user.getAddress() != null ? user.getAddress() : "Not provided" %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-user-tag"></i>
                User Type
              </div>
              <div class="info-value">
                <%= userRoleDisplay %>
                <span class="user-role <%= userRoleClass %>" style="margin-left: 12px;">
                  <i class="fas <%= userIcon %>"></i>
                  <%= user.getType().toUpperCase() %>
                </span>
              </div>
            </div>
            
            <% if(user.getType().equalsIgnoreCase("lecture")) { 
                String courseName = user.getCourseName();
            %>
            <div class="info-item">
                <div class="info-tag">
                    <i class="fas fa-book"></i>
                    Assigned Course
                </div>
                <div class="info-value">
                    <% if (courseName != null && !courseName.isEmpty() && !courseName.equals("null")) { %>
                        <%= courseName %>
                    <% } else { %>
                        <span style="color: var(--dark-gray);">No course assigned</span>
                    <% } %>
                </div>
            </div>
            <% } %>
          </div>

          <!-- Edit Button -->
          <div class="button-container">
            <% if (user.getType().equals("admin") || user.getType().equals("lecture")) { %>
              <a href="adm-page.jsp?pgprt=0&pedt=1" class="form-button">
                <i class="fas fa-edit"></i>
                Edit Profile Information
              </a>
            <% } else { %>
              <a href="std-page.jsp?pgprt=0&pedt=1" class="form-button">
                <i class="fas fa-edit"></i>
                Edit Profile Information
              </a>
            <% } %>
          </div>
        </div>
      </div>
<%
    } else {
%>
      <!-- Edit Profile Card -->
      <div class="profile-card">
        <div class="card-header">
          <span><i class="fas fa-edit"></i> Edit Profile Information</span>
          <i class="fas fa-user-cog"></i>
        </div>
        <div class="edit-form">
          <form action="controller.jsp" method="post">
            <input type="hidden" name="page" value="profile">
            <input type="hidden" name="utype" value="<%= user.getType() %>">
            
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-phone"></i>
                  Contact Number
                </label>
                <input type="tel" name="contactno" 
                       value="<%= user.getContact() != null ? user.getContact() : "" %>" 
                       class="form-input" 
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
                       class="form-input" 
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
                       class="form-input" 
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
                <select name="course_name" class="form-input">
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
            
            <div class="form-actions">
              <% if (user.getType().equals("admin") || user.getType().equals("lecture")) { %>
                <a href="adm-page.jsp?pgprt=0" class="cancel-btn">
                  <i class="fas fa-times"></i>
                  Cancel
                </a>
              <% } else { %>
                <a href="std-page.jsp?pgprt=0" class="cancel-btn">
                  <i class="fas fa-times"></i>
                  Cancel
                </a>
              <% } %>
              
              <button type="reset" class="cancel-btn" style="background: var(--medium-gray); color: var(--text-dark);">
                <i class="fas fa-redo"></i>
                Reset
              </button>
              
              <button type="submit" class="form-button loading-btn">
                <i class="fas fa-save"></i>
                Save Changes
              </button>
            </div>
          </form>
        </div>
      </div>
<%
    }
%>
  </main>
</div>

<!-- JavaScript for enhanced functionality -->
<script>
    // Form validation and loading state
    document.addEventListener('DOMContentLoaded', function() {
        const forms = document.querySelectorAll('form');
        
        forms.forEach(form => {
            form.addEventListener('submit', function(e) {
                const submitBtn = this.querySelector('button[type="submit"]');
                if (submitBtn) {
                    submitBtn.classList.add('loading');
                    submitBtn.disabled = true;
                }
            });
        });
        
        // Reset button handler
        const resetButtons = document.querySelectorAll('button[type="reset"]');
        resetButtons.forEach(btn => {
            btn.addEventListener('click', function() {
                const form = this.closest('form');
                form.reset();
            });
        });
    });
    

document.addEventListener('DOMContentLoaded', function() {
    const logoutBtn = document.getElementById('logoutBtn');
    const logoutLoader = document.getElementById('logoutLoader');
    const MIN_DISPLAY_TIME = 3000; // 3 seconds minimum

    if (logoutBtn && logoutLoader) {
        logoutBtn.addEventListener('click', function(e) {
            e.preventDefault();

            const startTime = Date.now();

            // Show loader immediately
            logoutLoader.classList.add('show');
            document.body.style.pointerEvents = 'none';

            // Ensure minimum display time
            setTimeout(function() {
                const elapsed = Date.now() - startTime;
                const remaining = Math.max(0, MIN_DISPLAY_TIME - elapsed);

                setTimeout(function() {
                    window.location.href = 'controller.jsp?page=logout';
                }, remaining);

            }, 100);
        });
    }
});
</script>