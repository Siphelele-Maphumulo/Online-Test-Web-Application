<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Authentication and authorization checks
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");
    if (!("admin".equals(userType) || "lecture".equals(userType))) {
        response.sendRedirect("std-page.jsp");
        return;
    }

    // Get filter parameters from request
    String studentNameFilter = request.getParameter("student_name");
    if (studentNameFilter == null) studentNameFilter = "";

    String dateFilter = request.getParameter("registration_date");
    if (dateFilter == null) dateFilter = "";

    String sortBy = request.getParameter("sort_by");
    if (sortBy == null) sortBy = "registration_date";

    String sortOrder = request.getParameter("sort_order");
    if (sortOrder == null) sortOrder = "desc";

    // Instantiate DAO and fetch data
    DatabaseClass pDAO = DatabaseClass.getInstance();
    ArrayList<Map<String, String>> registerList = pDAO.getFilteredDailyRegister(studentNameFilter, dateFilter);
    
    // Get today's date for quick filters
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new java.util.Date());
    
    // Get yesterday's date
    java.util.Calendar cal = java.util.Calendar.getInstance();
    cal.add(java.util.Calendar.DATE, -1);
    String yesterday = sdf.format(cal.getTime());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Register Log</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
    /* CSS Variables - Enhanced color palette */
    :root {
        /* Primary Colors */
        --primary-blue: #09294d;
        --secondary-blue: #1a3d6d;
        --accent-blue: #4a90e2;
        --light-blue: #e8f2ff;
        
        /* Neutral Colors */
        --white: #ffffff;
        --light-gray: #f8fafc;
        --medium-gray: #e2e8f0;
        --dark-gray: #64748b;
        --text-dark: #1e293b;
        --border-color: #e5e7eb;
        
        /* Semantic Colors */
        --success: #059669;
        --warning: #d97706;
        --error: #dc2626;
        --info: #0891b2;
        --success-light: #d1fae5;
        --warning-light: #fef3c7;
        --error-light: #fee2e2;
        --info-light: #e0f2fe;
        
        /* Spacing */
        --spacing-xs: 4px;
        --spacing-sm: 8px;
        --spacing-md: 16px;
        --spacing-lg: 24px;
        --spacing-xl: 32px;
        --spacing-2xl: 48px;
        
        /* Border Radius */
        --radius-xs: 2px;
        --radius-sm: 4px;
        --radius-md: 8px;
        --radius-lg: 12px;
        --radius-xl: 16px;
        --radius-full: 9999px;
        
        /* Shadows */
        --shadow-xs: 0 1px 2px rgba(0, 0, 0, 0.05);
        --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);
        --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
        --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
        --shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.15);
        --shadow-inner: inset 0 2px 4px rgba(0, 0, 0, 0.05);
        
        /* Transitions */
        --transition-fast: 0.15s ease;
        --transition-normal: 0.2s ease;
        --transition-slow: 0.3s ease;
        --transition-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
        
        /* Z-index layers */
        --z-sidebar: 100;
        --z-sticky: 200;
        --z-modal: 1000;
        --z-dropdown: 1100;
        --z-toast: 1200;
    }
    
    /* Reset and Base Styles */
    *,
    *::before,
    *::after {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        line-height: 1.6;
        color: var(--text-dark);
        background-color: var(--light-gray);
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
    }
    
    /* Layout Structure */
    .dashboard-container {
        display: flex;
        min-height: 100vh;
        background: var(--light-gray);
    }
    
    /* Sidebar Styles - Enhanced */
    .sidebar {
        width: 220px;
        background: linear-gradient(180deg, var(--primary-blue), #0f3c7a);
        color: var(--white);
        flex-shrink: 0;
        position: sticky;
        top: 0;
        height: 100vh;
        overflow-y: auto;
        overflow-x: hidden;
        z-index: var(--z-sidebar);
        box-shadow: var(--shadow-md);
        border-right: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .sidebar::-webkit-scrollbar {
        width: 8px;
    }
    
    .sidebar::-webkit-scrollbar-thumb {
        background: rgba(255, 255, 255, 0.25);
        border-radius: var(--radius-full);
        transition: background var(--transition-fast);
    }
    
    .sidebar::-webkit-scrollbar-thumb:hover {
        background: rgba(255, 255, 255, 0.4);
    }
    
    .sidebar::-webkit-scrollbar-track {
        background: transparent;
    }
    
    .sidebar-header {
        padding: var(--spacing-xl) var(--spacing-lg);
        text-align: center;
        border-bottom: 1px solid rgba(255, 255, 255, 0.15);
        position: relative;
        overflow: hidden;
    }
    
    .sidebar-header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, var(--accent-blue), #3b82f6);
    }
    
    .mut-logo {
        max-height: 140px;
        width: auto;
        filter: brightness(0) invert(1);
        transition: transform var(--transition-normal);
    }
    
    .mut-logo:hover {
        transform: scale(1.05);
    }
    
    .sidebar-nav {
        padding: var(--spacing-md) 0;
    }
    
    .nav-item {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        padding: var(--spacing-md) var(--spacing-lg);
        color: rgba(255, 255, 255, 0.85);
        text-decoration: none;
        transition: all var(--transition-normal);
        border-left: 3px solid transparent;
        margin: 0 var(--spacing-xs);
        border-radius: var(--radius-sm);
        position: relative;
        overflow: hidden;
    }
    
    .nav-item::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.05));
        opacity: 0;
        transition: opacity var(--transition-normal);
    }
    
    .nav-item:hover {
        background: rgba(255, 255, 255, 0.08);
        color: var(--white);
        border-left-color: var(--accent-blue);
    }
    
    .nav-item:hover::before {
        opacity: 1;
    }
    
    .nav-item.active {
        background: rgba(255, 255, 255, 0.12);
        color: var(--white);
        border-left-color: var(--white);
        font-weight: 500;
    }
    
    .nav-item.active::after {
        content: '';
        position: absolute;
        right: var(--spacing-md);
        width: 8px;
        height: 8px;
        background: var(--accent-blue);
        border-radius: 50%;
        animation: pulse 2s infinite;
    }
    
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }
    
    .nav-item i {
        width: 20px;
        text-align: center;
        font-size: 16px;
        flex-shrink: 0;
    }
    
    .nav-item h2 {
        font-size: 14px;
        font-weight: 500;
        margin: 0;
        white-space: nowrap;
        position: relative;
        z-index: 1;
    }
    
    /* Main Content Area */
    .main-content {
        flex: 1;
        padding: var(--spacing-xl);
        overflow-y: auto;
        background: linear-gradient(135deg, var(--light-gray) 0%, #f1f5f9 100%);
        min-height: 100vh;
    }
    
    /* Page Header - Enhanced */
    .page-header {
        background: var(--white);
        border-radius: var(--radius-lg);
        padding: var(--spacing-xl);
        margin-bottom: var(--spacing-xl);
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: var(--shadow-lg);
        border: 1px solid var(--border-color);
        position: relative;
        overflow: hidden;
    }
    
    .page-header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, var(--primary-blue), var(--accent-blue));
    }
    
    .page-title {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        font-size: 20px;
        font-weight: 700;
        color: var(--text-dark);
        position: relative;
        z-index: 1;
    }
    
    .page-title i {
        font-size: 22px;
        color: var(--primary-blue);
    }
    
    .stats-badge {
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: 10px 20px;
        border-radius: var(--radius-full);
        font-size: 14px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        box-shadow: var(--shadow-md);
        transition: all var(--transition-normal);
        position: relative;
        overflow: hidden;
    }
    
    .stats-badge::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.1), transparent);
        transform: translateX(-100%);
        transition: transform 0.6s ease;
    }
    
    .stats-badge:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-lg);
    }
    
    .stats-badge:hover::before {
        transform: translateX(100%);
    }
    
    /* Results Cards - Enhanced */
    .results-card {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-lg);
        border: 1px solid var(--border-color);
        margin-bottom: var(--spacing-xl);
        overflow: hidden;
        transition: all var(--transition-normal);
        position: relative;
    }
    
    .results-card:hover {
        transform: translateY(-4px);
        box-shadow: var(--shadow-xl);
    }
    
    .card-header {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: var(--spacing-lg);
        display: flex;
        justify-content: space-between;
        align-items: center;
        position: relative;
        overflow: hidden;
    }
    
    .card-header::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, var(--accent-blue), #60a5fa);
    }
    
    .card-header span {
        font-size: 15px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    /* Filter Container - Enhanced */
    .filter-container {
        background: var(--white);
        border-radius: var(--radius-lg);
        border: 1px solid var(--border-color);
        padding: var(--spacing-xl);
        margin-bottom: var(--spacing-xl);
        box-shadow: var(--shadow-md);
        position: relative;
    }
    
    .filter-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: var(--spacing-xl);
        padding-bottom: var(--spacing-md);
        border-bottom: 2px solid var(--light-gray);
    }
    
    .filter-title {
        font-weight: 700;
        color: var(--text-dark);
        font-size: 16px;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .filter-title i {
        color: var(--accent-blue);
    }
    
    .filter-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: var(--spacing-lg);
        margin-bottom: var(--spacing-lg);
    }
    
    .filter-group {
        display: flex;
        flex-direction: column;
        gap: var(--spacing-xs);
    }
    
    .filter-label {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: var(--spacing-xs);
    }
    
    .filter-label i {
        color: var(--dark-gray);
        font-size: 12px;
    }
    
    .filter-control,
    .filter-select {
        padding: 12px 16px;
        border: 2px solid var(--medium-gray);
        border-radius: var(--radius-md);
        font-size: 15px;
        transition: all var(--transition-normal);
        background: var(--white);
        color: var(--text-dark);
        width: 100%;
        font-family: inherit;
    }
    
    .filter-control:hover,
    .filter-select:hover {
        border-color: var(--accent-blue);
    }
    
    .filter-control:focus,
    .filter-select:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.15);
        transform: translateY(-1px);
    }
    
    .filter-select {
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3E%3Cpath fill='%2364748b' d='M4 6l4 4 4-4z'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 16px center;
        background-size: 16px;
        padding-right: 48px;
        cursor: pointer;
    }
    
    /* Quick Filters - Enhanced */
    .quick-filter-row {
        display: flex;
        flex-wrap: wrap;
        gap: var(--spacing-sm);
        margin-top: var(--spacing-xl);
        padding-top: var(--spacing-xl);
        border-top: 2px solid var(--light-gray);
        align-items: center;
    }
    
    .quick-filter-btn {
        background: var(--light-gray);
        border: 2px solid var(--medium-gray);
        border-radius: var(--radius-full);
        padding: 10px 20px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all var(--transition-normal);
        color: var(--text-dark);
        display: inline-flex;
        align-items: center;
        gap: var(--spacing-sm);
        text-decoration: none;
    }
    
    .quick-filter-btn:hover {
        background: var(--accent-blue);
        color: var(--white);
        border-color: var(--accent-blue);
        transform: translateY(-2px);
        box-shadow: var(--shadow-md);
    }
    
    .quick-filter-btn.active {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        border-color: transparent;
        box-shadow: var(--shadow-md);
    }
    
    /* Buttons - Enhanced */
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
        padding: 12px 24px;
        border-radius: var(--radius-md);
        font-size: 15px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        border: 2px solid transparent;
        transition: all var(--transition-normal);
        font-family: inherit;
        position: relative;
        overflow: hidden;
        white-space: nowrap;
    }
    
    .btn::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0;
        height: 0;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.2);
        transform: translate(-50%, -50%);
        transition: width 0.6s, height 0.6s;
    }
    
    .btn:hover::before {
        width: 300px;
        height: 300px;
    }
    
    .btn-primary {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
    }
    
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(9, 41, 77, 0.25);
    }
    
    .btn-secondary {
        background: var(--dark-gray);
        color: var(--white);
    }
    
    .btn-secondary:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(100, 116, 139, 0.25);
    }
    
    .btn-outline {
        background: transparent;
        border: 2px solid var(--medium-gray);
        color: var(--dark-gray);
    }
    
    .btn-outline:hover {
        background: var(--light-gray);
        border-color: var(--dark-gray);
        transform: translateY(-2px);
        box-shadow: var(--shadow-md);
    }
    
    .btn-success {
        background: linear-gradient(90deg, var(--success), #10b981);
        color: var(--white);
    }
    
    .btn-success:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(5, 150, 105, 0.25);
    }
    
    .btn-danger {
        background: linear-gradient(90deg, var(--error), #ef4444);
        color: var(--white);
    }
    
    .btn-danger:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(220, 38, 38, 0.25);
    }
    
    /* Search Container - Enhanced */
    .search-container {
        position: relative;
        margin-bottom: var(--spacing-xl);
    }
    
    .search-input {
        width: 100%;
        padding: 14px 52px 14px 20px;
        border: 2px solid var(--medium-gray);
        border-radius: var(--radius-md);
        font-size: 15px;
        transition: all var(--transition-normal);
        background: var(--white);
        color: var(--text-dark);
        box-shadow: var(--shadow-sm);
    }
    
    .search-input:hover {
        border-color: var(--accent-blue);
    }
    
    .search-input:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.15), var(--shadow-md);
        transform: translateY(-1px);
    }
    
    .search-icon {
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--dark-gray);
        font-size: 16px;
        pointer-events: none;
    }
    
    /* Results Table - Enhanced */
    .results-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        background: var(--white);
        border-radius: var(--radius-md);
        overflow: hidden;
        box-shadow: var(--shadow-sm);
    }
    
    .results-table thead {
        position: sticky;
        top: 0;
        z-index: var(--z-sticky);
    }
    
    .results-table thead th {
        background: linear-gradient(to bottom, #f8fafc, #f1f5f9);
        color: var(--text-dark);
        padding: var(--spacing-lg);
        font-weight: 700;
        text-align: left;
        border-bottom: 2px solid var(--border-color);
        font-size: 14px;
        cursor: pointer;
        transition: all var(--transition-fast);
        position: relative;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        white-space: nowrap;
    }
    
    .results-table thead th:hover {
        background: var(--light-blue);
        color: var(--primary-blue);
    }
    
    .results-table thead th::after {
        content: '';
        position: absolute;
        bottom: -2px;
        left: 0;
        right: 0;
        height: 2px;
        background: var(--accent-blue);
        transform: scaleX(0);
        transition: transform var(--transition-normal);
    }
    
    .results-table thead th:hover::after {
        transform: scaleX(1);
    }
    
    .results-table tbody td {
        padding: var(--spacing-md);
        border-bottom: 1px solid var(--light-gray);
        vertical-align: middle;
        color: var(--dark-gray);
        font-size: 14px;
        text-align: left;
        transition: all var(--transition-fast);
    }
    
    .results-table tbody tr {
        transition: all var(--transition-fast);
    }
    
    .results-table tbody tr:hover {
        background-color: var(--light-blue);
    }
    
    .results-table tbody tr:hover td {
        color: var(--text-dark);
    }
    
    /* Status Badges - Enhanced */
    .badge {
        padding: 6px 14px;
        border-radius: var(--radius-full);
        font-weight: 600;
        font-size: 12px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
        transition: all var(--transition-normal);
        box-shadow: var(--shadow-xs);
    }
    
    .badge:hover {
        transform: translateY(-1px);
        box-shadow: var(--shadow-sm);
    }
    
    .badge-success {
        background: linear-gradient(135deg, var(--success), #10b981);
        color: var(--white);
    }
    
    .badge-error {
        background: linear-gradient(135deg, var(--error), #ef4444);
        color: var(--white);
    }
    
    .badge-warning {
        background: linear-gradient(135deg, var(--warning), #f59e0b);
        color: var(--white);
    }
    
    .badge-info {
        background: linear-gradient(135deg, var(--info), #0ea5e9);
        color: var(--white);
    }
    
    /* Sort Indicator */
    .sort-indicator {
        margin-left: var(--spacing-xs);
        font-size: 10px;
        color: var(--dark-gray);
        transition: all var(--transition-fast);
    }
    
    .results-table thead th:hover .sort-indicator {
        color: var(--accent-blue);
    }
    
    /* No Results Message - Enhanced */
    .no-results {
        text-align: center;
        padding: var(--spacing-2xl) var(--spacing-xl);
        color: var(--dark-gray);
        font-size: 15px;
        background: var(--white);
        border-radius: var(--radius-md);
        margin: var(--spacing-xl) 0;
    }
    
    .no-results i {
        font-size: 48px;
        margin-bottom: var(--spacing-lg);
        color: var(--medium-gray);
        opacity: 0.5;
    }
    
    .no-results h2 {
        font-size: 20px;
        font-weight: 600;
        color: var(--text-dark);
        margin-bottom: var(--spacing-sm);
    }
    
    .results-count {
        text-align: center;
        padding: var(--spacing-lg);
        color: var(--dark-gray);
        font-size: 14px;
        font-weight: 500;
        border-top: 1px solid var(--medium-gray);
        background: linear-gradient(to bottom, var(--light-gray), #f1f5f9);
    }
    
    /* Loading State - Enhanced */
    .loading {
        opacity: 0.8;
        pointer-events: none;
        position: relative;
    }
    
    .loading::after {
        content: '';
        display: inline-block;
        width: 16px;
        height: 16px;
        border: 2px solid rgba(255, 255, 255, 0.3);
        border-top: 2px solid var(--white);
        border-radius: 50%;
        animation: spin 0.8s linear infinite;
        margin-left: var(--spacing-sm);
        vertical-align: middle;
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    /* Modal Styles - Enhanced */
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.6);
        display: none; /* CRITICAL FIX: Hide by default */
        align-items: center;
        justify-content: center;
        z-index: var(--z-modal);
        backdrop-filter: blur(4px);
        animation: fadeIn 0.3s ease-out;
    }
    
    .modal-overlay.active {
        display: flex; /* Show when active class is added */
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    
    .modal-content {
        background: var(--white);
        border-radius: var(--radius-xl);
        width: 90%;
        max-width: 500px;
        box-shadow: var(--shadow-xl);
        animation: modalSlideIn 0.4s var(--transition-bounce);
        overflow: hidden;
        transform: translateY(0);
    }
    
    @keyframes modalSlideIn {
        from {
            transform: translateY(-30px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
    
    .modal-header {
        background: linear-gradient(135deg, var(--error), #ef4444);
        color: white;
        padding: var(--spacing-xl);
        display: flex;
        justify-content: space-between;
        align-items: center;
        position: relative;
        overflow: hidden;
    }
    
    .modal-header::before {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #fca5a5, #fecaca);
    }
    
    .modal-title {
        font-size: 18px;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .close-button {
        background: rgba(255, 255, 255, 0.2);
        border: none;
        color: white;
        font-size: 20px;
        cursor: pointer;
        padding: 8px;
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: all var(--transition-normal);
    }
    
    .close-button:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: rotate(90deg);
    }
    
    .modal-body {
        padding: var(--spacing-2xl) var(--spacing-xl);
        border-bottom: 1px solid var(--medium-gray);
        text-align: center;
    }
    
    .modal-body p {
        font-size: 16px;
        line-height: 1.6;
        color: var(--text-dark);
        margin: 0;
    }
    
    .modal-footer {
        padding: var(--spacing-xl);
        display: flex;
        justify-content: flex-end;
        gap: var(--spacing-md);
        background: var(--light-gray);
    }
    
    /* Modal Variations */
    .alert-modal .modal-header {
        background: linear-gradient(135deg, var(--warning), #f59e0b);
    }
    
    .alert-modal .modal-header::before {
        background: linear-gradient(90deg, #fcd34d, #fde68a);
    }
    
    .info-modal .modal-header {
        background: linear-gradient(135deg, var(--info), #0ea5e9);
    }
    
    .info-modal .modal-header::before {
        background: linear-gradient(90deg, #7dd3fc, #bae6fd);
    }
    
    .success-modal .modal-header {
        background: linear-gradient(135deg, var(--success), #10b981);
    }
    
    .success-modal .modal-header::before {
        background: linear-gradient(90deg, #34d399, #a7f3d0);
    }
    
    /* Bulk Controls - Enhanced */
    .bulk-controls {
        display: none; /* Hidden by default */
        align-items: center;
        justify-content: space-between;
        gap: var(--spacing-md);
        padding: var(--spacing-md) var(--spacing-lg);
        background: linear-gradient(to right, var(--light-gray), #f1f5f9);
        border-bottom: 2px solid var(--border-color);
        position: sticky;
        top: 0;
        z-index: var(--z-sticky);
        backdrop-filter: blur(10px);
        border-radius: var(--radius-md) var(--radius-md) 0 0;
    }
    
    .bulk-controls.active {
        display: flex; /* Show when active */
    }
    
    .selected-count {
        font-size: 14px;
        font-weight: 600;
        color: var(--primary-blue);
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        padding: 6px 12px;
        background: var(--white);
        border-radius: var(--radius-full);
        border: 1px solid var(--accent-blue);
    }
    
    /* Checkbox Styling - Enhanced */
    .checkbox-container {
        display: inline-flex;
        align-items: center;
        position: relative;
        cursor: pointer;
        user-select: none;
        gap: var(--spacing-sm);
    }
    
    .checkbox-container input[type="checkbox"] {
        opacity: 0;
        position: absolute;
        width: 20px;
        height: 20px;
        cursor: pointer;
    }
    
    .checkbox-custom {
        width: 20px;
        height: 20px;
        background: var(--white);
        border: 2px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        position: relative;
        transition: all var(--transition-normal);
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .checkbox-container:hover .checkbox-custom {
        border-color: var(--accent-blue);
        background: var(--light-blue);
    }
    
    .checkbox-container input[type="checkbox"]:checked + .checkbox-custom {
        background: var(--accent-blue);
        border-color: var(--accent-blue);
    }
    
    .checkbox-container input[type="checkbox"]:checked + .checkbox-custom::after {
        content: '✓';
        color: white;
        font-size: 12px;
        font-weight: bold;
        animation: checkIn 0.3s var(--transition-bounce);
    }
    
    @keyframes checkIn {
        0% { transform: scale(0); }
        70% { transform: scale(1.2); }
        100% { transform: scale(1); }
    }
    
    /* Responsive Design */
    @media (max-width: 1024px) {
        .sidebar {
            width: 200px;
        }
        
        .filter-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    
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
            max-height: 60vh;
        }
        
        .sidebar-nav {
            display: flex;
            overflow-x: auto;
            padding: var(--spacing-sm);
            gap: var(--spacing-xs);
        }
        
        .nav-item {
            flex-direction: column;
            padding: var(--spacing-sm) var(--spacing-md);
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
        
        .main-content {
            padding: var(--spacing-lg);
        }
        
        .page-header {
            flex-direction: column;
            gap: var(--spacing-lg);
            text-align: center;
            padding: var(--spacing-lg);
        }
        
        .filter-grid {
            grid-template-columns: 1fr;
            gap: var(--spacing-md);
        }
        
        .filter-container {
            padding: var(--spacing-lg);
        }
        
        .results-table {
            display: block;
            overflow-x: auto;
        }
        
        .card-header {
            flex-direction: column;
            gap: var(--spacing-md);
            text-align: center;
            padding: var(--spacing-md);
        }
        
        .quick-filter-row {
            flex-direction: column;
            align-items: stretch;
        }
        
        .quick-filter-row .btn,
        .quick-filter-btn {
            width: 100%;
            justify-content: center;
        }
        
        .modal-content {
            width: 95%;
            margin: 10px;
        }
        
        .modal-footer {
            flex-direction: column;
        }
        
        .modal-footer .btn {
            width: 100%;
        }
        
        .bulk-controls {
            flex-direction: column;
            gap: var(--spacing-sm);
            padding: var(--spacing-md);
        }
    }
    
    @media (max-width: 480px) {
        :root {
            --spacing-xl: 24px;
            --spacing-lg: 20px;
            --spacing-md: 16px;
        }
        
        .main-content {
            padding: var(--spacing-md);
        }
        
        .filter-container {
            padding: var(--spacing-md);
        }
        
        .results-table thead th,
        .results-table tbody td {
            padding: var(--spacing-sm);
            font-size: 13px;
        }
        
        .btn {
            padding: 10px 16px;
            font-size: 14px;
        }
        
        .search-input {
            padding: 12px 44px 12px 16px;
            font-size: 14px;
        }
        
        .quick-filter-btn {
            font-size: 13px;
            padding: 8px 16px;
        }
        
        .badge {
            padding: 4px 10px;
            font-size: 11px;
        }
    }
    
    /* Print Styles */
    @media print {
        .sidebar,
        .bulk-controls,
        .modal-overlay,
        .btn,
        .quick-filter-row,
        .search-container {
            display: none !important;
        }
        
        .dashboard-container {
            flex-direction: column;
        }
        
        .main-content {
            padding: 0;
        }
        
        .results-card {
            box-shadow: none;
            border: 1px solid #000;
        }
        
        .results-table {
            border: 1px solid #000;
        }
        
        .results-table thead th {
            background: #f0f0f0 !important;
            color: #000 !important;
            -webkit-print-color-adjust: exact;
        }
    }
    
    /* Floating Delete Button */
    .floating-delete-btn {
        position: fixed;
        bottom: 30px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 9999;
        display: none; /* Initially hidden */
        opacity: 0;
        transition: opacity 0.3s ease-in-out;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    }
    
    .floating-delete-btn.visible {
        display: block;
        opacity: 1;
    }
    
    /* Loading animation styles */
    .btn-delete-loading {
        position: relative;
        pointer-events: none;
    }
    
    .btn-delete-loading::after {
        content: '';
        position: absolute;
        width: 16px;
        height: 16px;
        top: 50%;
        left: 50%;
        margin: -8px 0 0 -8px;
        border: 2px solid rgba(255, 255, 255, 0.3);
        border-top: 2px solid white;
        border-radius: 50%;
        animation: spin 1s linear infinite;
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

    /* Highlight selected rows for delete */
    .record-row-selected {
        background-color: rgba(250, 150, 150, 0.15);
        position: relative;
    }

    .record-row-selected::before {
        content: '';
        position: absolute;
        inset: 0;
        border: 2px solid rgba(220, 38, 38, 0.5);
        border-radius: var(--radius-sm);
        pointer-events: none;
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
</style>
</head>

<body>
<div class="dashboard-container">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="Logo" class="mut-logo">
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
               <h2>Exam Registers</h2>
           </a>
           <a href="adm-page.jsp?pgprt=8" class="nav-item active">
               <i class="fas fa-clipboard-list"></i>
               <h2>Class Registers</h2>
           </a>
            <a href="adm-page.jsp?pgprt=9" class="nav-item">
                <i class="fas fa-user-shield"></i>
                <h2>Proctoring</h2>
            </a>
        </nav>
    </aside>

    <div class="main-content">
        <!-- Header -->
        <div class="page-header">
            <div class="page-title">
                <i class="fas fa-clipboard-list"></i> Class Register Log
            </div>
            <div class="stats-badge">
                <i class="fas fa-users"></i>
                <span><%= registerList.size() %> Total Records</span>
            </div>
        </div>

        <!-- Search and Quick Actions -->
        <div class="search-container">
            <form method="get" action="adm-page.jsp" id="searchForm">
                <input type="hidden" name="pgprt" value="8">
                <input type="search" 
                       name="student_name" 
                       class="search-input" 
                       placeholder="Search by student name or ID..."
                       value="<%= studentNameFilter %>">
                <i class="fas fa-search search-icon"></i>
            </form>
        </div>

        <!-- Filter Container -->
        <div class="filter-container">
            <form method="get" action="adm-page.jsp" id="filterForm">
                <input type="hidden" name="pgprt" value="8">
                <input type="hidden" name="student_name" value="<%= studentNameFilter %>">
                
                <div class="filter-header">
                    <div class="filter-title">
                        <i class="fas fa-filter"></i> Filter Options
                    </div>
                    <button type="button" class="btn btn-outline" onclick="resetFilters()">
                        <i class="fas fa-redo"></i> Reset All
                    </button>
                </div>

                <div class="filter-grid">
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-calendar-alt"></i> Date Range
                        </label>
                        <input type="date" 
                               name="registration_date" 
                               class="filter-control" 
                               value="<%= dateFilter %>">
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-sort-amount-down"></i> Sort By
                        </label>
                        <select name="sort_by" class="filter-select" onchange="this.form.submit()">
                            <option value="registration_date" <%= "registration_date".equals(sortBy) ? "selected" : "" %>>Date</option>
                            <option value="student_name" <%= "student_name".equals(sortBy) ? "selected" : "" %>>Student Name</option>
                            <option value="student_id" <%= "student_id".equals(sortBy) ? "selected" : "" %>>Student ID</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">
                            <i class="fas fa-sort"></i> Order
                        </label>
                        <select name="sort_order" class="filter-select" onchange="this.form.submit()">
                            <option value="desc" <%= "desc".equals(sortOrder) ? "selected" : "" %>>Newest First</option>
                            <option value="asc" <%= "asc".equals(sortOrder) ? "selected" : "" %>>Oldest First</option>
                        </select>
                    </div>
                </div>

                <!-- Quick Filters -->
                <div class="quick-filter-row">
                    <span class="filter-label" style="margin-right: var(--spacing-sm);">
                        <i class="fas fa-bolt"></i> Quick Filters:
                    </span>
                    <button type="button" 
                            class="quick-filter-btn <%= today.equals(dateFilter) ? "active" : "" %>"
                            onclick="setDateFilter('<%= today %>')">
                        <i class="fas fa-calendar-day"></i> Today
                    </button>
                    <button type="button" 
                            class="quick-filter-btn <%= yesterday.equals(dateFilter) ? "active" : "" %>"
                            onclick="setDateFilter('<%= yesterday %>')">
                        <i class="fas fa-calendar-minus"></i> Yesterday
                    </button>
                    <button type="button" 
                            class="quick-filter-btn <%= "".equals(dateFilter) ? "active" : "" %>"
                            onclick="setDateFilter('')">
                        <i class="fas fa-calendar-week"></i> All Dates
                    </button>
                    
                    <div style="flex-grow: 1;"></div>
                    
                    <button class="btn btn-primary" type="submit">
                        <i class="fas fa-search"></i> Apply Filters
                    </button>
                    
                    <a href="export-class-register.jsp?student_name=<%= URLEncoder.encode(studentNameFilter, "UTF-8") %>&registration_date=<%= URLEncoder.encode(dateFilter, "UTF-8") %>&sort_by=<%= sortBy %>&sort_order=<%= sortOrder %>" 
                       class="btn btn-success">
                        <i class="fas fa-file-csv"></i> Export CSV
                    </a>
                </div>
            </form>
        </div>

        <!-- Results Card -->
        <div class="results-card">
            <div class="card-header">
                <span><i class="fas fa-table"></i> Attendance Records</span>
                <div>
                    <span class="stats-badge">
                        <i class="fas fa-chart-line"></i>
                        <%= registerList.size() %> Records
                    </span>
                    <% if (!dateFilter.isEmpty()) { %>
                    <span class="stats-badge" style="margin-left: var(--spacing-sm); background: linear-gradient(135deg, var(--info), #0ea5e9);">
                        <i class="fas fa-calendar-check"></i>
                        <%= dateFilter %>
                    </span>
                    <% } %>
                </div>
            </div>

            <% if (!registerList.isEmpty()) { %>
            <form id="bulkDeleteForm" action="controller.jsp" method="post" onsubmit="return handleBulkDelete(event)">
                <input type="hidden" name="page" value="class-register">
                <input type="hidden" name="operation" value="bulk_delete">
                <input type="hidden" name="csrf_token" value="<%= session.getAttribute("csrf_token") %>">
                <input type="hidden" name="student_name" value="<%= studentNameFilter %>">
                <input type="hidden" name="registration_date" value="<%= dateFilter %>">
                <input type="hidden" name="sort_by" value="<%= sortBy %>">
                <input type="hidden" name="sort_order" value="<%= sortOrder %>">
                
                <div class="bulk-controls" id="bulkControls">
                    <div class="selected-count" id="selectedCount">0 selected</div>
<!--                    <button type="button" class="btn btn-danger" onclick="showDeleteConfirmation()">
                        <i class="fas fa-trash"></i> Delete Selected
                    </button>-->
                    <button type="button" class="btn btn-outline" onclick="clearSelection()">
                        <i class="fas fa-times"></i> Clear
                    </button>
                </div>
                
                <div class="results-table-container">
                    <table class="results-table">
                        <thead>
                            <tr>
                                <% if ("admin".equals(userType)) { %>
                                <th style="width: 50px;">
                                    <label class="checkbox-container">
                                        <input type="checkbox" id="selectAll" onchange="toggleSelectAll(this)">
                                        <span class="checkbox-custom"></span>
                                    </label>
                                </th>
                                <% } %>
                                <th onclick="sortTable('index')"># <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('register_id')">Register ID <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('student_id')">Student ID <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('student_name')">Student Name <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('registration_date')">Date <i class="fas fa-sort sort-indicator"></i></th>
                                <th onclick="sortTable('registration_time')">Time <i class="fas fa-sort sort-indicator"></i></th>
                                <th style="width: 100px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                int i = 0; 
                                for (Map<String, String> record : registerList) { 
                                    i++;
                                    String registerId = record.get("register_id");
                                    String studentId = record.get("student_id");
                                    String studentName = record.get("student_name");
                                    String regDate = record.get("registration_date");
                                    String regTime = record.get("registration_time");
                            %>
                            <tr>
                                <% if ("admin".equals(userType)) { %>
                                <td>
                                    <label class="checkbox-container">
                                        <input type="checkbox" name="registerIds" value="<%= registerId %>" class="record-checkbox" onchange="updateSelection()">
                                        <span class="checkbox-custom"></span>
                                    </label>
                                </td>
                                <% } %>
                                <td><span class="badge badge-info"><%= i %></span></td>
                                <td><code><%= registerId %></code></td>
                                <td><strong><%= studentId %></strong></td>
                                <td>
                                    <div style="display: flex; align-items: center; gap: var(--spacing-sm);">
                                        <div style="width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, var(--primary-blue), var(--accent-blue)); display: flex; align-items: center; justify-content: center; color: white; font-size: 12px;">
                                            <%= studentName != null && !studentName.isEmpty() ? studentName.substring(0, 1).toUpperCase() : "?" %>
                                        </div>
                                        <%= studentName %>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge <%= today.equals(regDate) ? "badge-success" : "badge-info" %>">
                                        <i class="fas fa-calendar"></i>
                                        <%= regDate %>
                                    </span>
                                </td>
                                <td>
                                    <span class="badge badge-warning">
                                        <i class="fas fa-clock"></i>
                                        <%= regTime %>
                                    </span>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 12px;" 
                                            onclick="viewStudentDetails('<%= studentId %>')">
                                        <i class="fas fa-eye"></i> View
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </form>
                
                <div class="results-count">
                    Showing <%= registerList.size() %> record(s)
                    <% if (!studentNameFilter.isEmpty()) { %>
                        for "<%= studentNameFilter %>"
                    <% } %>
                    <% if (!dateFilter.isEmpty()) { %>
                        on <%= dateFilter %>
                    <% } %>
                </div>
                
            <% } else { %>
                <div class="no-results">
                    <i class="fas fa-clipboard-list fa-3x" style="color: var(--medium-gray); margin-bottom: var(--spacing-md);"></i>
                    <h2>No Records Found</h2>
                    <p style="color: var(--dark-gray); margin-bottom: var(--spacing-lg);">
                        No attendance records match your filter criteria.
                        <% if (!studentNameFilter.isEmpty() || !dateFilter.isEmpty()) { %>
                            Try adjusting your filters.
                        <% } %>
                    </p>
                    <% if (!studentNameFilter.isEmpty() || !dateFilter.isEmpty()) { %>
                        <a href="adm-page.jsp?pgprt=8" class="btn btn-primary">
                            <i class="fas fa-times"></i> Clear All Filters
                        </a>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteConfirmationModal" class="modal-overlay">
  <div class="modal-content">
    <div class="modal-header">
      <h2 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Confirm Deletion</h2>
      <button class="close-button" onclick="closeModal('deleteConfirmationModal')">&times;</button>
    </div>
    <div class="modal-body">
      <p id="deleteModalMessage">Are you sure you want to delete the selected records? This action cannot be undone.</p>
    </div>
    <div class="modal-footer">
      <button type="button" onclick="closeModal('deleteConfirmationModal')" class="btn btn-secondary">Cancel</button>
      <button type="button" id="confirmDeleteBtn" class="btn btn-danger">Delete Selected</button>
    </div>
  </div>
</div>

<!-- Alert Modal -->
<div id="alertModal" class="modal-overlay">
  <div class="modal-content alert-modal">
    <div class="modal-header">
      <h2 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Alert</h2>
      <button class="close-button" onclick="closeModal('alertModal')">&times;</button>
    </div>
    <div class="modal-body">
      <p id="alertModalMessage">Please select at least one record to delete.</p>
    </div>
    <div class="modal-footer">
      <button type="button" onclick="closeModal('alertModal')" class="btn btn-primary">OK</button>
    </div>
  </div>
</div>

<!-- Loading Modal -->
<div id="loadingModal" class="modal-overlay">
  <div class="modal-content" style="background: transparent; box-shadow: none;">
    <div class="modal-body" style="text-align: center; color: white; border: none;">
      <div style="width: 50px; height: 50px; margin: 0 auto 20px; border: 4px solid rgba(255,255,255,0.3); border-top: 4px solid white; border-radius: 50%; animation: spin 1s linear infinite;"></div>
      <p style="font-size: 16px; margin: 0;">Deleting records...</p>
    </div>
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

            
            <!-- Floating Delete Button -->
            <% if ("admin".equals(userType)) { %>
            <div id="floatingDeleteBtn" class="floating-delete-btn">
                <button type="button" id="deleteSelectedBtn" class="btn btn-danger" style="padding: 15px 30px; font-size: 16px;">
                    <i class="fas fa-trash"></i> Delete Selected (<span id="selectedCountBadge">0</span>)
                </button>
            </div>
            <% } %>

<script>
    // Global variables
    let deleteForm = null;
    let deleteButton = null;

    // JavaScript for enhanced functionality
    document.addEventListener('DOMContentLoaded', function() {
        // Auto-submit search form on typing
        const searchInput = document.querySelector('.search-input');
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                document.getElementById('searchForm').submit();
            }, 500);
        });
        
        // Initialize delete form reference
        deleteForm = document.getElementById('bulkDeleteForm');
        if (deleteForm) {
            deleteForm.onsubmit = handleBulkDelete;
        }
        
        // Highlight active filters
        highlightActiveFilters();
        
        // Initialize modals as hidden
        document.querySelectorAll('.modal-overlay').forEach(modal => {
            modal.style.display = 'none';
        });

        // Initialize floating scroll buttons
        initScrollButtons();
    });

    // Selection Management
    function toggleSelectAll(checkbox) {
        const checkboxes = document.querySelectorAll('.record-checkbox');
        checkboxes.forEach(cb => {
            cb.checked = checkbox.checked;
        });
        updateSelection();
    }

    function updateSelection() {
        const checkboxes = document.querySelectorAll('.record-checkbox');
        const selectedCount = document.querySelectorAll('.record-checkbox:checked').length;
        const bulkControls = document.getElementById('bulkControls');
        const selectAllCheckbox = document.getElementById('selectAll');
        const selectedCountElement = document.getElementById('selectedCount');
        const floatingBtn = document.getElementById('floatingDeleteBtn');
        const selectedCountBadge = document.getElementById('selectedCountBadge');
        
        selectedCountElement.textContent = selectedCount + ' selected';
        
        if (selectedCountBadge) {
            selectedCountBadge.textContent = selectedCount;
        }

        // Highlight selected rows
        checkboxes.forEach(cb => {
            const row = cb.closest('tr');
            if (!row) return;
            if (cb.checked) {
                row.classList.add('record-row-selected');
            } else {
                row.classList.remove('record-row-selected');
            }
        });
        
        if (selectedCount > 0) {
            bulkControls.style.display = 'flex';
            if (floatingBtn) {
                floatingBtn.classList.add('visible');
            }
        } else {
            bulkControls.style.display = 'none';
            if (floatingBtn) {
                floatingBtn.classList.remove('visible');
            }
        }
        
        // Update select all checkbox state
        if (selectedCount === 0) {
            selectAllCheckbox.checked = false;
            selectAllCheckbox.indeterminate = false;
        } else if (selectedCount === checkboxes.length) {
            selectAllCheckbox.checked = true;
            selectAllCheckbox.indeterminate = false;
        } else {
            selectAllCheckbox.checked = false;
            selectAllCheckbox.indeterminate = true;
        }
    }

    function clearSelection() {
        const checkboxes = document.querySelectorAll('.record-checkbox');
        checkboxes.forEach(cb => {
            cb.checked = false;
        });
        document.getElementById('selectAll').checked = false;
        document.getElementById('selectAll').indeterminate = false;
        updateSelection();
    }

    // Delete Functionality
    function showDeleteConfirmation() {
        const selectedCount = document.querySelectorAll('.record-checkbox:checked').length;
        
        if (selectedCount === 0) {
            showAlert('Please select at least one record to delete.');
            return;
        }
        
        document.getElementById('deleteModalMessage').textContent = 
            `Are you sure you want to delete ${selectedCount} record(s)? This action cannot be undone.`;
        
        showModal('deleteConfirmationModal');
    }

    function handleBulkDelete(event) {
        if (event) {
            event.preventDefault();
        }
        
        const selectedCount = document.querySelectorAll('.record-checkbox:checked').length;
        
        if (selectedCount === 0) {
            showAlert('Please select at least one record to delete.');
            return false;
        }
        
        showDeleteConfirmation();
        return false;
    }

    // Modal Management
    function showModal(modalId) {
        const modal = document.getElementById(modalId);
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden'; // Prevent background scrolling
        
        // Set up delete confirmation
        if (modalId === 'deleteConfirmationModal') {
            const confirmBtn = document.getElementById('confirmDeleteBtn');
            confirmBtn.onclick = function() {
                closeModal('deleteConfirmationModal');
                performDelete();
            };
            
            // Store reference to delete button
            deleteButton = document.querySelector('#bulkControls .btn-danger');
            if (deleteButton) {
                deleteButton.disabled = true;
                deleteButton.classList.add('btn-delete-loading');
                deleteButton.innerHTML = '<i class="fas fa-spinner"></i> Deleting...';
            }
        }
    }

    function closeModal(modalId) {
        const modal = document.getElementById(modalId);
        modal.style.display = 'none';
        document.body.style.overflow = 'auto'; // Restore scrolling
        
        // Reset delete button if modal was closed
        if (modalId === 'deleteConfirmationModal' && deleteButton) {
            deleteButton.disabled = false;
            deleteButton.classList.remove('btn-delete-loading');
            deleteButton.innerHTML = '<i class="fas fa-trash"></i> Delete Selected';
        }
    }

    function showAlert(message) {
        document.getElementById('alertModalMessage').textContent = message;
        showModal('alertModal');
    }

    // Add event listener for floating delete button
    document.addEventListener('DOMContentLoaded', function() {
        const floatingDeleteBtn = document.getElementById('deleteSelectedBtn');
        if (floatingDeleteBtn) {
            floatingDeleteBtn.addEventListener('click', function(e) {
                e.preventDefault();
                
                const selectedCheckboxes = document.querySelectorAll('.record-checkbox:checked');
                
                if (selectedCheckboxes.length === 0) {
                    showAlert('Please select at least one record to delete.');
                    return;
                }
                
                showDeleteConfirmation();
            });
        }
    });

    function performDelete() {
        // Show loading modal
        showModal('loadingModal');
        
        // Submit the form after a short delay to show loading state
        setTimeout(() => {
            if (deleteForm) {
                // Create a hidden input for selected IDs
                const selectedCheckboxes = document.querySelectorAll('.record-checkbox:checked');
                const ids = Array.from(selectedCheckboxes).map(cb => cb.value).join(',');
                
                // Add hidden field for IDs
                let idsInput = deleteForm.querySelector('input[name="registerIds"]');
                if (!idsInput) {
                    idsInput = document.createElement('input');
                    idsInput.type = 'hidden';
                    idsInput.name = 'registerIds';
                    deleteForm.appendChild(idsInput);
                }
                idsInput.value = ids;
                
                // Submit the form
                deleteForm.submit();
            }
        }, 500);
    }

    // Helper Functions
    function setDateFilter(date) {
        const form = document.getElementById('filterForm');
        form.elements['registration_date'].value = date;
        form.submit();
    }
    
    function resetFilters() {
        window.location.href = 'adm-page.jsp?pgprt=8';
    }
    
    function sortTable(column) {
        const url = new URL(window.location.href);
        const currentSort = url.searchParams.get('sort_by');
        const currentOrder = url.searchParams.get('sort_order');
        
        let newOrder = 'asc';
        if (currentSort === column) {
            newOrder = currentOrder === 'asc' ? 'desc' : 'asc';
        }
        
        url.searchParams.set('sort_by', column);
        url.searchParams.set('sort_order', newOrder);
        window.location.href = url.toString();
    }
    
    function viewStudentDetails(studentId) {
        // Get student details from the table row
        const studentRow = event.target.closest('tr');
        if (!studentRow) return;
        
        const cells = studentRow.getElementsByTagName('td');
        if (cells.length < 3) return;
        
        const studentName = cells[2] ? cells[2].textContent.trim() : 'Unknown';
        const registrationDate = cells[3] ? cells[3].textContent.trim() : 'N/A';
        const registrationTime = cells[4] ? cells[4].textContent.trim() : 'N/A';
        const status = cells[5] ? cells[5].textContent.trim() : 'Unknown';
        
        // Populate alert modal with student details
        const alertModalMessage = document.getElementById('alertModalMessage');
        alertModalMessage.innerHTML = `
            <div style="text-align: left; margin-bottom: 15px;">
                <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                    <div style="font-weight: 600; color: var(--primary-blue);">Student Details:</div>
                    <div style="text-align: right;">
                        <a href="adm-page.jsp?pgprt=8&student_id=${studentId}" 
                           style="color: var(--accent-blue); text-decoration: underline; font-size: 14px;">
                            <i class="fas fa-external-link-alt"></i> View Full Details
                        </a>
                    </div>
                </div>
                <div style="border-top: 1px solid var(--medium-gray); padding-top: 10px;">
                    <div style="margin-bottom: 8px;"><strong>Student ID:</strong> ${studentId}</div>
                    <div style="margin-bottom: 8px;"><strong>Name:</strong> ${studentName}</div>
                    <div style="margin-bottom: 8px;"><strong>Registration Date:</strong> ${registrationDate}</div>
                    <div style="margin-bottom: 8px;"><strong>Registration Time:</strong> ${registrationTime}</div>
                    <div style="margin-bottom: 8px;"><strong>Status:</strong> ${status}</div>
                </div>
                <div style="text-align: center; margin-top: 15px;">
                    <button type="button" onclick="closeModal('alertModal')" 
                            style="background: var(--primary-blue); color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">
                        Close
                    </button>
                </div>
        `;
        
        showAlert('Student Details Retrieved');
    }
    
    function highlightActiveFilters() {
        const params = new URLSearchParams(window.location.search);
        const dateFilter = params.get('registration_date');
        
        if (dateFilter) {
            document.querySelectorAll('.quick-filter-btn').forEach(btn => {
                if (btn.textContent.includes(dateFilter === '<%= today %>' ? 'Today' : 
                                            dateFilter === '<%= yesterday %>' ? 'Yesterday' : '')) {
                    btn.classList.add('active');
                }
            });
        }
    }

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
        
        function scrollToTop() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        }
        
        function scrollToBottom() {
            window.scrollTo({
                top: document.documentElement.scrollHeight,
                behavior: 'smooth'
            });
        }
        
        scrollUpBtn.addEventListener('click', scrollToTop);
        scrollDownBtn.addEventListener('click', scrollToBottom);
        window.addEventListener('scroll', toggleScrollButtons);
        
        toggleScrollButtons();
    }
    
    // Close modal when clicking outside
    document.addEventListener('click', function(event) {
        if (event.target.classList.contains('modal-overlay')) {
            event.target.style.display = 'none';
            document.body.style.overflow = 'auto';
            
            // Reset delete button if delete modal was closed
            if (event.target.id === 'deleteConfirmationModal' && deleteButton) {
                deleteButton.disabled = false;
                deleteButton.classList.remove('btn-delete-loading');
                deleteButton.innerHTML = '<i class="fas fa-trash"></i> Delete Selected';
            }
        }
    });
    
    // Close modal with Escape key
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            document.querySelectorAll('.modal-overlay').forEach(modal => {
                if (modal.style.display === 'flex') {
                    modal.style.display = 'none';
                    document.body.style.overflow = 'auto';
                    
                    // Reset delete button if delete modal was closed
                    if (modal.id === 'deleteConfirmationModal' && deleteButton) {
                        deleteButton.disabled = false;
                        deleteButton.classList.remove('btn-delete-loading');
                        deleteButton.innerHTML = '<i class="fas fa-trash"></i> Delete Selected';
                    }
                }
            });
        }
    });
    
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
</script>

</body>
</html>