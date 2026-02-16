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
    @media (max-width: 992px) {
        .sidebar {
            display: none;
        }

        .main-content {
            margin-left: 0;
            padding: 15px;
            width: 100%;
            box-sizing: border-box;
        }
    }

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
    
    /* Scroll-to-top button */
    .scroll-to-top {
        position: fixed;
        bottom: 30px;
        right: 20px;
        z-index: 999;
        display: none;
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: white;
        border: none;
        border-radius: 40%;
        width: 40px;
        height: 40px;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        cursor: pointer;
        transition: all 0.3s ease;
    }
    
    .scroll-to-top:hover {
        transform: translateY(-3px);
        box-shadow: 0 6px 15px rgba(0, 0, 0, 0.3);
        background: linear-gradient(135deg, var(--secondary-blue), var(--primary-blue));
    }
    
    .scroll-to-top:active {
        transform: translateY(1px);
    }

    /* Floating Scroll Buttons (same style as showall.jsp) */
    .floating-scroll {
        position: fixed;
        bottom: 300px;
        right: 5px;
        z-index: 1000;
        display: flex;
        flex-direction: column;
        gap: 8px;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
    }

    .floating-scroll.visible {
        opacity: 1;
        visibility: visible;
    }

    .scroll-btn {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        background-color: #476287;
        color: var(--white);
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 8px;
        box-shadow: var(--shadow-lg);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }

    .scroll-btn:hover {
        transform: scale(1.1);
        box-shadow: 0 8px 25px rgba(9, 41, 77, 0.3);
    }

    .scroll-btn:active {
        transform: scale(0.95);
    }

    .scroll-btn::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0;
        height: 0;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: translate(-50%, -50%);
        transition: width 0.4s ease, height 0.4s ease;
    }

    .scroll-btn:active::before {
        width: 100%;
        height: 100%;
    }

    @media (max-width: 768px) {
        .floating-scroll {
            bottom: 20px;
            right: 20px;
        }

        .scroll-btn {
            width: 45px;
            height: 45px;
            font-size: 16px;
        }
    }
    
    /* For inline forms in quick-filter-row */
    .quick-filter-row form {
        display: inline;
    }
    
    .quick-filter-row .btn {
        margin: 2px;
    }
    
    /* Floating Delete Button - PROFESSIONAL VERSION */
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
        transform: translateX(-50%);
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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
        transform: translateX(-50%) translateY(-4px) scale(1.02);
        box-shadow: 0 12px 28px rgba(220, 38, 38, 0.45);
        background: linear-gradient(145deg, #ef4444, #dc2626);
    }

    .floating-delete-btn:active {
        transform: translateX(-50%) translateY(-2px) scale(0.98);
        box-shadow: 0 6px 16px rgba(220, 38, 38, 0.4);
    }

    .floating-delete-btn.visible {
        opacity: 1;
        transform: translateX(-50%) translateY(0) scale(1);
        visibility: visible;
    }

    .floating-delete-btn.inactive {
        opacity: 0;
        transform: translateX(-50%) translateY(20px) scale(0.9);
        pointer-events: none;
        visibility: hidden;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
        /* Add to your existing CSS */
    .register-checkbox {
        cursor: pointer;
        transform: scale(1.1);
    }
    
    .register-checkbox:checked {
        accent-color: #dc3545;
    }
    
    .btn-danger:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
    
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.5);
        display: none;
        justify-content: center;
        align-items: center;
        z-index: 1000;
    }
    
    .modal-content {
        background: white;
        border-radius: 8px;
        max-width: 500px;
        width: 90%;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
    }
    
    .modal-header {
        padding: 20px;
        border-bottom: 1px solid #eee;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .modal-body {
        padding: 20px;
    }
    
    .modal-footer {
        padding: 20px;
        border-top: 1px solid #eee;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }
</style>

<%@ include file="header-messages.jsp" %>
<%@ include file="modal_assets.jspf" %>

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
            <a href="adm-page.jsp?pgprt=7" class="nav-item">
               <i class="fas fa-users"></i>
               <h2>Registers</h2>
           </a>
           <a href="adm-page.jsp?pgprt=8" class="nav-item" active>
               <i class="fas fa-users"></i>
               <h2>Class Registers</h2>
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

        <!-- Filters & Export -->
        <div class="filter-container">
            <!-- Filter Form -->
            <form method="get" action="adm-page.jsp">
                <input type="hidden" name="pgprt" value="7">

                <div class="filter-grid">
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
                    rs = pDAO.getFilteredExamRegister(examId, studentId, firstNameFilter, 
                                                     lastNameFilter, courseNameFilter, dateFilter);
                    if (rs != null && rs.next()) {
            %>
            <!-- Move the form START here -->
            <form id="bulkDeleteForm" action="controller.jsp" method="post">
                <input type="hidden" name="page" value="exam-register">
                <input type="hidden" name="operation" value="bulk_delete">
                <input type="hidden" name="csrf_token" value="<%= session.getAttribute("csrf_token") %>">



                <table class="results-table">
                    <thead>
                        <tr>
                            <th><input type="checkbox" id="selectAll"></th>
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
                            <td><input type="checkbox" name="registerIds" value="<%= rs.getInt("register_id") %>"></td>
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
                                    <%= completed ? "Completed" : "incomplete" %>
                                </span>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </form>
            <!-- Form END here -->
            <div class="results-count">
                Total Records: <%= i %>
                            <!-- Standalone Export Form -->
            <div class="quick-filter-row" style="
    padding-top: var(--spacing-sm);
    margin-top: var(--spacing-sm);
    display: flex;
    justify-content: center;
    align-items: center;
    text-align: center;
">  
                <form method="get" action="export-register.jsp" target="_blank" style="display: inline;">
                    <!-- Hidden inputs with current filter values are crucial -->
                    <input type="hidden" name="exam_id" value="<%= examId %>">
                    <input type="hidden" name="student_id" value="<%= studentId %>">
                    <input type="hidden" name="first_name" value="<%= firstNameFilter %>">
                    <input type="hidden" name="last_name" value="<%= lastNameFilter %>">
                    <input type="hidden" name="course_name" value="<%= courseNameFilter %>">
                    <input type="hidden" name="exam_date" value="<%= dateFilter %>">
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-file-excel"></i> Export to Excel
                    </button>
                </form>
            </div>
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
            <!-- Floating Scroll Buttons (same as showall.jsp) -->
            <div class="floating-scroll" id="floatingScroll">
                <button class="scroll-btn" id="scrollUpBtn" title="Scroll to Top">
                    <i class="fas fa-chevron-up"></i>
                </button>
                <button class="scroll-btn" id="scrollDownBtn" title="Scroll to Bottom">
                    <i class="fas fa-chevron-down"></i>
                </button>
            </div>

            <!-- Scroll-to-top button -->
            <button class="scroll-to-top" id="scrollToTopBtn" title="Go to top">
                <i class="fas fa-arrow-up"></i>
            </button>
            
            <!-- Floating Delete Button -->
            <div id="floatingDeleteBtn" class="floating-delete-btn">
                <button type="button" id="deleteSelectedBtn" class="btn btn-danger" style="padding: 15px 30px; font-size: 16px;">
                    <i class="fas fa-trash"></i> Delete Selected (<span id="selectedCountBadge">0</span>)
                </button>
            </div>

<script>
    // Wait for DOM to be fully loaded
    document.addEventListener('DOMContentLoaded', function() {
        // Select All functionality
        const selectAllCheckbox = document.getElementById('selectAll');
        if (selectAllCheckbox) {
            selectAllCheckbox.addEventListener('change', function(e) {
                const checkboxes = document.querySelectorAll('input[name="registerIds"]');
                checkboxes.forEach(checkbox => {
                    checkbox.checked = e.target.checked;
                });
                updateDeleteButtonState();
            });
        }

        // Update delete button state when checkboxes change
        const checkboxes = document.querySelectorAll('input[name="registerIds"]');
        checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', updateDeleteButtonState);
        });

        function updateDeleteButtonState() {
            const selectedCount = document.querySelectorAll('input[name="registerIds"]:checked').length;
            const floatingBtn = document.getElementById('floatingDeleteBtn');
            const deleteBtn = document.getElementById('deleteSelectedBtn');
            const selectedCountBadge = document.getElementById('selectedCountBadge');
            
            if (selectedCountBadge) {
                selectedCountBadge.textContent = selectedCount;
            }
            
            if (floatingBtn) {
                if (selectedCount > 0) {
                    floatingBtn.classList.add('visible');
                } else {
                    floatingBtn.classList.remove('visible');
                }
            }
            
            if (deleteBtn) {
                deleteBtn.disabled = selectedCount === 0;
                deleteBtn.title = selectedCount > 0 ? 
                    `Delete ${selectedCount} selected record(s)` : 
                    'Select records to delete';
            }
        }

        // Initialize button state
        updateDeleteButtonState();

        // Initialize floating scroll buttons
        initScrollButtons();

        // Delete button click handler
        const deleteBtn = document.getElementById('deleteSelectedBtn');
        if (deleteBtn) {
            deleteBtn.addEventListener('click', function(e) {
                e.preventDefault();
                
                const selectedCheckboxes = document.querySelectorAll('input[name="registerIds"]:checked');
                
                if (selectedCheckboxes.length === 0) {
                    showAlert('Please select at least one record to delete.', 'warning');
                    return;
                }
                
                // Show confirmation modal
                document.getElementById('deleteModalMessage').innerHTML = 
                    '<i class="fas fa-exclamation-circle" style="color: #dc3545; margin-right: 10px;"></i>' +
                    'Are you sure you want to delete <strong>' + selectedCheckboxes.length + '</strong> selected record(s)?<br><br>' +
                    '<small style="color: #666;">This action cannot be undone.</small>';
                
                showModal();

                // Set up confirmation handler
                document.getElementById('confirmDeleteBtn').onclick = function() {
                    // Submit the form
                    document.getElementById('bulkDeleteForm').submit();
                };
            });
        }
    });

    // Modal functions
    function showModal() {
        document.getElementById('deleteConfirmationModal').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeModal() {
        document.getElementById('deleteConfirmationModal').style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    // Close modal when clicking outside or pressing ESC
    document.getElementById('deleteConfirmationModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeModal();
        }
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && document.getElementById('deleteConfirmationModal').style.display === 'flex') {
            closeModal();
        }
    });

    // Helper function to show alerts (make sure this exists)
    function showAlert(message, type = 'warning') {
        // If you have a toast/notification system
        if (typeof toastMessage === 'function') {
            toastMessage(message, type);
        } else {
            alert(message);
        }
    }
    
    // Scroll-to-top button functionality
    const scrollToTopBtn = document.getElementById('scrollToTopBtn');
    
    window.addEventListener('scroll', () => {
        if (window.pageYOffset > 300) {
            scrollToTopBtn.style.display = 'block';
        } else {
            scrollToTopBtn.style.display = 'none';
        }
    });
    
    scrollToTopBtn.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });

    // Floating scroll buttons functionality (same as showall.jsp)
    function initScrollButtons() {
        const floatingScroll = document.getElementById('floatingScroll');
        const scrollUpBtn = document.getElementById('scrollUpBtn');
        const scrollDownBtn = document.getElementById('scrollDownBtn');
        
        if (!floatingScroll || !scrollUpBtn || !scrollDownBtn) return;
        
        function toggleScrollButtons() {
            const scrollPosition = window.pageYOffset || document.documentElement.scrollTop;
            const documentHeight = document.documentElement.scrollHeight;
            const windowHeight = window.innerHeight;
            
            if (scrollPosition > 200) {
                floatingScroll.classList.add('visible');
            } else {
                floatingScroll.classList.remove('visible');
            }
            
            if (scrollPosition + windowHeight >= documentHeight - 100) {
                scrollDownBtn.style.display = 'none';
            } else {
                scrollDownBtn.style.display = 'flex';
            }
            
            if (scrollPosition < 100) {
                scrollUpBtn.style.display = 'none';
            } else {
                scrollUpBtn.style.display = 'flex';
            }
        }
        
        function scrollToTopSmooth() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        }
        
        function scrollToBottomSmooth() {
            window.scrollTo({
                top: document.documentElement.scrollHeight,
                behavior: 'smooth'
            });
        }
        
        scrollUpBtn.addEventListener('click', scrollToTopSmooth);
        scrollDownBtn.addEventListener('click', scrollToBottomSmooth);
        window.addEventListener('scroll', toggleScrollButtons);
        
        toggleScrollButtons();
    }
</script>