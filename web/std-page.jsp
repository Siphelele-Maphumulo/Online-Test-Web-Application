<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.classes.User"%>
<%@page import="myPackage.DatabaseClass"%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>
 
<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
//pDAO.autoActivateExams();

// Disable loader for fast-loading pages
String pgprtParam = request.getParameter("pgprt");
if (pgprtParam == null || pgprtParam.equals("0") || pgprtParam.equals("4")) {
    request.setAttribute("disableLoader", "true");
}
%>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
    /* CSS Variables for easy customization */
    :root {
        --primary-blue: #09294d;
        --secondary-blue: #1a3d6d;
        --accent-blue: #4a90e2;
        --text-white: #ffffff;
        --text-light: #e0e9ff;
        --shadow-light: rgba(255, 255, 255, 0.1);
        --shadow-dark: rgba(0, 0, 0, 0.1);
        --transition-speed: 0.2s;
    }

    /* Reset and Base Styles */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
        background-color: #f8fafc;
        color: #334155;
        line-height: 1.5;
        font-size: 14px;
        overflow-x: hidden;
    }

    /* Professional Dashboard Header - Compact Size */
    .dashboard-header {
        background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
        padding: 8px 0; /* Reduced from 12px */
        border-bottom: 2px solid var(--text-white);
        position: sticky;
        top: 0;
        z-index: 1000;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); /* Lighter shadow */
        font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
        width: 100%;
        height: 58px; /* Fixed height for consistency */
    }

    /* Header container - full width */
    .header-container {
        width: 100%;
        padding: 0 12px; /* Reduced from 15px */
        height: 100%;
        display: flex;
        align-items: center;
    }

    /* Header row - 3 column flex layout */
    .header-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
        gap: 10px;
    }

    /* Logo Column - Compact size */
    .logo-col {
        flex: 0 0 auto;
    }

    /* Title Column - More space */
    .title-col {
        flex: 1;
        text-align: center;
    }

    /* User Column - Compact size */
    .user-col {
        flex: 0 0 auto;
    }

    /* Logo Styles - Smaller */
    .logo-link {
        display: inline-block;
    }

    .header-logo {
        max-height: 34px; /* Reduced from 42px */
        width: auto;
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .logo-link:hover .header-logo {
        transform: translateY(-1px);
        opacity: 0.95;
    }

    /* Title Styles - Smaller */
    .header-title {
        color: var(--text-white);
        font-size: 1rem; /* Reduced from 1.125rem */
        font-weight: 600;
        margin: 0;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2); /* Lighter shadow */
        letter-spacing: 0.2px;
        line-height: 1.3;
    }

    .header-subtitle {
        color: var(--text-light);
        font-size: 0.6875rem; /* Reduced from 0.75rem */
        margin: 1px 0 0; /* Reduced margin */
        opacity: 0.9;
        display: block;
    }

    /* User Info Styles - Compact */
    .user-section {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 2px; /* Reduced gap */
        color: var(--text-white);
    }

    .user-info {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        color: var(--text-white);
    }

    .user-name {
        color: var(--text-white);
        font-weight: 500;
        font-size: 0.8125rem; /* Reduced from 0.875rem */
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 100px; /* Limit width */
    }

    .user-role {
        color: var(--text-light);
        font-size: 0.6875rem; /* Reduced from 0.75rem */
        background: rgba(255, 255, 255, 0.08); /* Lighter background */
        padding: 1px 6px; /* Reduced padding */
        border-radius: 10px; /* Smaller radius */
        margin-top: 1px;
    }

    /* Logout Button - Smaller */
    .logout-btn {
        color: var(--text-white);
        text-decoration: none;
        font-weight: 500;
        font-size: 0.75rem; /* Reduced from 0.8125rem */
        padding: 4px 10px; /* Reduced padding */
        border-radius: 3px; /* Smaller radius */
        transition: all var(--transition-speed) ease;
        background: rgba(255, 255, 255, 0.08);
        border: 1px solid rgba(255, 255, 255, 0.15);
        display: flex;
        align-items: center;
        gap: 4px; /* Reduced gap */
        white-space: nowrap;
    }

    .logout-btn:hover {
        background: rgba(255, 255, 255, 0.15); /* Lighter hover */
        transform: translateY(-1px); /* Smaller movement */
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15); /* Lighter shadow */
        border-color: rgba(255, 255, 255, 0.25);
    }

    .logout-btn:active {
        transform: translateY(0);
    }

    .logout-btn i {
        font-size: 0.625rem; /* Reduced from 0.6875rem */
    }

        /* Floating Scroll Button */
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

    /* Responsive Design */
    @media (max-width: 991.98px) {
        .dashboard-header {
            padding: 6px 0; /* Even smaller */
            height: 52px; /* Reduced height */
        }
        
        .header-container {
            padding: 0 10px; /* More compact */
        }
        
        .header-title {
            font-size: 0.9375rem; /* Smaller */
        }
        
        .header-subtitle {
            font-size: 0.625rem; /* Smaller */
            margin-top: 0;
        }
        
        .logo-col {
            flex: 0 0 12%;
            max-width: 12%;
        }
        
        .title-col {
            flex: 0 0 76%;
            max-width: 76%;
        }
        
        .user-col {
            flex: 0 0 12%;
            max-width: 12%;
        }
        
        .dashboard-container {
            padding-top: 52px; /* Match new height */
        }
        
        .dashboard-sidebar {
            top: 52px; /* Match new height */
            width: 200px;
        }
        
        .dashboard-content {
            margin-left: 0;
            min-height: calc(100vh - 52px); /* Match new height */
            padding: 0;
            width: 100%;
        }
        
        .content-wrapper {
            padding: 0;
        }
    }

    @media (max-width: 767.98px) {
        .dashboard-header {
            padding: 4px 0;
            height: 50px;
        }
        
        .header-container {
            padding: 0 10px;
        }
        
        .header-logo {
            max-height: 30px;
        }
        
        .header-title {
            font-size: 0.85rem;
            line-height: 1.2;
        }
        
        .header-subtitle {
            display: none;
        }
        
        .user-name {
            display: none;
        }
        
        .user-role {
            display: none;
        }
        
        .logout-btn {
            padding: 4px 8px;
            font-size: 0.75rem;
        }
        
        .logout-btn span {
            display: none;
        }
        
        .logout-btn i {
            margin-right: 0;
        }
        
        .dashboard-container {
            padding-top: 48px;
        }
        
        /* Mobile sidebar */
        .sidebar-toggle {
            display: flex;
            top: 10px;
            left: 10px;
            width: 28px;
            height: 28px;
        }
        
        .dashboard-sidebar {
            width: 60px;
            transform: translateX(-100%);
            top: 48px;
        }
        
        .dashboard-sidebar.active {
            transform: translateX(0);
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.15);
        }
        
        .dashboard-content {
            margin-left: 0;
            padding: 12px;
            min-height: calc(100vh - 48px);
        }
        
        .sidebar-overlay.active {
            display: block;
        }
        
        .nav-item span {
            display: none;
        }
        
        .nav-item {
            padding: 10px;
            justify-content: center;
        }
    }

    @media (max-width: 575.98px) {
        .dashboard-header {
            height: 44px;
        }
        
        .header-title {
            font-size: 0.75rem;
        }
        
        .header-logo {
            max-height: 24px;
        }
        
        .logo-col,
        .title-col,
        .user-col {
            padding: 0 4px;
        }
        
        .logout-btn {
            padding: 2px 4px;
            font-size: 0.625rem;
        }
        
        .logout-btn i {
            font-size: 0.625rem;
        }
        
        .dashboard-container {
            padding-top: 44px;
        }
        
        .dashboard-sidebar {
            top: 44px;
            width: 50px;
        }
        
        .dashboard-content {
            padding: 8px;
            min-height: calc(100vh - 44px);
        }
        
        .content-wrapper {
            padding: 12px;
        }
        
        .sidebar-toggle {
            top: 8px;
            left: 8px;
            width: 26px;
            height: 26px;
        }
    }

    /* Page Loader Styles */
    .page-loader-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(5px);
        z-index: 99999;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 1;
        visibility: visible;
        transition: opacity 0.3s ease-out, visibility 0.3s ease-out;
    }

    .page-loader-overlay.hidden {
        opacity: 0;
        visibility: hidden;
    }

    .page-loader-content {
        text-align: center;
    }

    .page-loader-spinner {
        width: 60px;
        height: 60px;
        border: 5px solid #f3f3f3;
        border-top: 5px solid #09294d;
        border-radius: 50%;
        animation: pageLoaderSpin 1s linear infinite;
        margin: 0 auto 20px;
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .page-loader-img {
        width: 32px;
        height: 32px;
        position: absolute;
        filter: brightness(0) invert(1); /* Makes image white */
        animation: pageLoaderImgSpin 1s linear infinite;
        object-fit: contain;
    }

    @keyframes pageLoaderSpin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    @keyframes pageLoaderImgSpin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    .page-loader-text {
        font-size: 16px;
        font-weight: 500;
        color: #09294d;
        font-family: 'Segoe UI', 'Roboto', sans-serif;
        animation: pageLoaderPulse 1.5s ease-in-out infinite;
    }

    @keyframes pageLoaderPulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }

    @media (max-width: 399.98px) {
        .dashboard-header {
            height: 40px;
        }
        
        .header-title {
            font-size: 0.6875rem;
        }
        
        .header-subtitle {
            display: none;
        }
        
        .header-logo {
            max-height: 22px;
        }
        
        .title-col {
            display: none;
        }
        
        .logo-col {
            flex: 0 0 50%;
            max-width: 50%;
        }
        
        .user-col {
            flex: 0 0 50%;
            max-width: 50%;
        }
        
        .dashboard-container {
            padding-top: 40px;
        }
        
        .dashboard-sidebar {
            top: 40px;
            width: 48px;
        }
        
        .dashboard-content {
            min-height: calc(100vh - 40px);
        }
    }

    /* Scrollbar Styling */
    .dashboard-sidebar::-webkit-scrollbar {
        width: 4px; /* Thinner */
    }
    
    .dashboard-sidebar::-webkit-scrollbar-track {
        background: #f1f5f9;
    }
    
    .dashboard-sidebar::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 2px; /* Smaller radius */
    }
    
    .dashboard-sidebar::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
    }

    /* Status Modal Styles */
    .status-modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.6);
        display: none;
        justify-content: center;
        align-items: center;
        z-index: 2000;
    }

    .status-modal {
        background-color: #fff;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        text-align: center;
        width: 90%;
        max-width: 400px;
    }

    .status-modal-icon {
        font-size: 50px;
        margin-bottom: 20px;
    }

    .status-modal-icon.deactivated { color: #f87171; }
    .status-modal-icon.passed { color: #fbbf24; }
    .status-modal-icon.future { color: #60a5fa; }

    .status-modal-title {
        font-size: 24px;
        font-weight: 600;
        margin-bottom: 10px;
    }

    .status-modal-message {
        font-size: 16px;
        color: #64748b;
        margin-bottom: 25px;
    }

    .status-modal-close-btn {
        background-color: var(--primary-blue);
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 5px;
        cursor: pointer;
        font-size: 16px;
    }
    
    /* Floating Scroll Buttons */
    .floating-scroll {
        position: fixed;
        bottom: 100px;
        right: 20px;
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
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: var(--primary-blue);
        color: var(--text-white);
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
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
        
        /* Exam Loader Styles */
        .exam-loader-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            transition: opacity 0.3s ease;
        }
        
        .exam-loader-spinner {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            text-align: center;
            min-width: 200px;
        }
        
        .exam-loader-spinner .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid var(--accent-blue);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 16px;
        }
        
        .exam-loader-spinner p {
            margin: 0;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    }
</style>

<%
    // Get userId from session
    Object userIdObj = session.getAttribute("userId");

    if (userIdObj == null) {
        // Redirect if no session or invalid login
        response.sendRedirect("login.jsp");
        return;
    }

    String userIdStr = userIdObj.toString();
    User currentUser = pDAO.getUserDetails(userIdStr);

    if (currentUser == null) {
        // If user details not found, redirect to login
        response.sendRedirect("login.jsp");
        return;
    }
%>

  <!-- Page Loader - Shows for 0.5 seconds -->
  <% if (request.getAttribute("disableLoader") == null && session.getAttribute("disableLoader") == null) { %>
  <div id="pageLoader" class="page-loader-overlay">
    <div class="page-loader-content">
      <div class="page-loader-spinner">
        <img src="./IMG/Design.png" class="page-loader-img" alt="Loading" aria-hidden="true">
      </div>
      <div class="page-loader-text">Loading...</div>
    </div>
  </div>
  <% } %>

<!-- Professional Dashboard Header - 3 Column Layout -->
<header class="dashboard-header">
    <div class="header-container">
        <div class="header-row">
            <!-- Logo Column -->
            <div class="logo-col">
                <a href="index.jsp" class="logo-link">
                    <img src="IMG/mut-45yearslogo-whitetrans1024x362-1-12@2x.png" 
                         alt="MUT Logo" 
                         class="header-logo">
                </a>
            </div>

            <!-- Title Column -->
            <div class="title-col">
                <h1 class="header-title">Student Panel</h1>
                <span class="header-subtitle">CodeSA Institute Pty LTD</span>
            </div>

            <!-- User Info Column -->
            <div class="user-col">
                <div class="user-section">
                    <div class="user-info">
                        <span class="user-name"><%= currentUser.getFirstName() %> <%= currentUser.getLastName() %></span>
                    </div>
                    <a href="controller.jsp?page=logout" class="logout-btn">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</header>
    <!-- Include the header messages -->
    <%@ include file="header-messages.jsp" %>
    
    
<div class="student-panel-container">

  <!-- MAIN CONTENT -->
   <main class="main-content" style="margin-left: 13%; margin-top: -5%;">
    <%
        if(session.getAttribute("userStatus") != null && session.getAttribute("userStatus").equals("1")) {
            String pgprt = request.getParameter("pgprt");
            
            
            // Page title and badge
            String pageTitle = "Student Profile";
            String userRole = "Student";
            
            if ("1".equals(pgprt)) {
                pageTitle = "Student Exams";
            } else if ("2".equals(pgprt)) {
                pageTitle = "Student Results";
            } else if ("3".equals(pgprt)) {
                pageTitle = "Register";
            } else if ("4".equals(pgprt)) {
                pageTitle = "View Attendance";
            }
    %>
    
    <!-- Page Header -->
    <div class="page-header">
      <div class="page-title">
        <i class="fas fa-user-graduate"></i>
        <%= pageTitle %>
      </div>
      <div class="role-badge">
        <i class="fas fa-user"></i>
        <%= currentUser.getFirstName() + " " + currentUser.getLastName() %>
      </div>
    </div>

    <%
        // Include appropriate page based on parameter
        if ("1".equals(pgprt)) {
    %>
        <div id="examLoader" class="exam-loader-overlay">
            <div class="exam-loader-spinner">
                <div class="spinner"></div>
                <p>Loading Exam...</p>
            </div>
        </div>
        <script>
            // Hide loader when exam is fully loaded
            window.addEventListener('load', function() {
                setTimeout(function() {
                    const loader = document.getElementById('examLoader');
                    if (loader) {
                        loader.style.opacity = '0';
                        setTimeout(() => {
                            loader.style.display = 'none';
                        }, 300);
                    }
                }, 500);
            });
        </script>
        <jsp:include page="exam.jsp"/>
    <%
        } else if ("2".equals(pgprt)) {
    %>
        <jsp:include page="results.jsp"/> 
    <%
        } else if ("3".equals(pgprt)) {
    %>
        <jsp:include page="daily_register.jsp"/>
    <%
        } else if ("4".equals(pgprt)) {
    %>
        <jsp:include page="view_attendance.jsp"/>
    <%
        } else {
            // Default to profile
    %>
    
        <jsp:include page="profile.jsp"/>
    <%
        }
    %>
    
    <%
        } else {
            // Redirect if session is invalid
            response.sendRedirect("login.jsp");
        }
    %>
  </main>
</div>

<!-- Status Modals -->
<div id="statusModal" class="status-modal-overlay">
    <div class="status-modal">
        <div id="modalIcon" class="status-modal-icon"></div>
        <h2 id="modalTitle" class="status-modal-title"></h2>
        <p id="modalMessage" class="status-modal-message"></p>
        <button id="modalCloseBtn" class="status-modal-close-btn">Close</button>
    </div>
</div>

<script>
    // Mobile sidebar functionality
    document.addEventListener('DOMContentLoaded', function() {
        const sidebar = document.getElementById('sidebar');
        const currentPath = window.location.pathname + window.location.search;
        const navItems = document.querySelectorAll('.nav-item');
        
        // Add active state based on current page
        if (navItems.length > 0) {
            navItems.forEach(item => {
                if (item.href && currentPath.includes(new URL(item.href).search)) {
                    item.classList.add('active');
                }
            });
        }
        
        // Toggle sidebar on mobile
        if (sidebar) {
            let resizeTimer;
            window.addEventListener('resize', function() {
                clearTimeout(resizeTimer);
                resizeTimer = setTimeout(function() {
                    if (window.innerWidth > 768) {
                        sidebar.classList.remove('active');
                    }
                }, 250);
            });
        }
    });

    // Modal functionality
    const statusModal = document.getElementById('statusModal');
    const modalIcon = document.getElementById('modalIcon');
    const modalTitle = document.getElementById('modalTitle');
    const modalMessage = document.getElementById('modalMessage');
    const modalCloseBtn = document.getElementById('modalCloseBtn');

    function showModal(type, message) {
        let iconClass, title;
        switch (type) {
            case 'deactivated':
                iconClass = 'fas fa-times-circle deactivated';
                title = 'Exam Deactivated';
                break;
            case 'passed':
                iconClass = 'fas fa-exclamation-triangle passed';
                title = 'Exam Date Passed';
                break;
            case 'future':
                iconClass = 'fas fa-calendar-alt future';
                title = 'Exam Not Yet Active';
                break;
        }
        modalIcon.className = 'status-modal-icon ' + iconClass;
        modalTitle.textContent = title;
        modalMessage.textContent = message;
        statusModal.style.display = 'flex';
    }

    modalCloseBtn.onclick = () => {
        statusModal.style.display = 'none';
    };

    window.onclick = (event) => {
        if (event.target == statusModal) {
            statusModal.style.display = 'none';
        }
    };

    // Page Loader - Show for exactly 2 seconds OR until page is fully loaded
    (function() {
        var loader = document.getElementById('pageLoader');
        if (loader) {
            // Ensure loader is visible immediately
            loader.style.display = 'flex';
            
            // Hide loader after 0.5 seconds OR when page is fully loaded
            var hideLoader = function() {
                if (loader && loader.classList) {
                    loader.classList.add('hidden');
                    setTimeout(function() {
                        if (loader) {
                            loader.style.display = 'none';
                        }
                    }, 300); // Wait for fade-out transition
                }
            };
            
            // Set timeout to hide loader after 0.5 seconds
            setTimeout(hideLoader, 500);
            
            // Also hide loader when page is fully loaded
            window.addEventListener('load', hideLoader);
            
            // Fallback: hide loader after 10 seconds maximum (in case of errors)
            setTimeout(hideLoader, 10000);
            
            // Additional safety: hide loader if there are any JavaScript errors
            window.addEventListener('error', hideLoader);
        }
    })();
</script>

<!-- Floating Scroll Buttons -->
<div class="floating-scroll" id="floatingScroll">
    <button class="scroll-btn" id="scrollUpBtn" title="Scroll to Top">
        <i class="fas fa-chevron-up"></i>
    </button>
    <button class="scroll-btn" id="scrollDownBtn" title="Scroll to Bottom">
        <i class="fas fa-chevron-down"></i>
    </button>
</div>

<script>
// Initialize floating scroll buttons
document.addEventListener('DOMContentLoaded', function() {
    initScrollButtons();
});

// Single, consolidated scroll button functionality
function initScrollButtons() {
    const floatingScroll = document.getElementById('floatingScroll');
    const scrollUpBtn = document.getElementById('scrollUpBtn');
    const scrollDownBtn = document.getElementById('scrollDownBtn');
    
    if (!floatingScroll || !scrollUpBtn || !scrollDownBtn) {
        console.log('Scroll buttons not found');
        return;
    }
    
    console.log('Scroll buttons initialized');
    
    function scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }
    
    function scrollToBottom() {
        window.scrollTo({
            top: document.documentElement.scrollHeight - window.innerHeight,
            behavior: 'smooth'
        });
    }
    
    function toggleScrollButtons() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const documentHeight = document.documentElement.scrollHeight;
        const windowHeight = window.innerHeight;
        
        // Always show floating container when page is scrollable
        if (documentHeight > windowHeight) {
            floatingScroll.classList.add('visible');
        } else {
            floatingScroll.classList.remove('visible');
        }
        
        // Hide down button when at bottom
        if (scrollTop + windowHeight >= documentHeight - 100) {
            scrollDownBtn.style.display = 'none';
        } else {
            scrollDownBtn.style.display = 'flex';
        }
        
        // Hide up button when at top
        if (scrollTop < 100) {
            scrollUpBtn.style.display = 'none';
        } else {
            scrollUpBtn.style.display = 'flex';
        }
    }
    
    // Remove any existing event listeners to prevent duplicates
    window.removeEventListener('scroll', toggleScrollButtons);
    window.removeEventListener('resize', toggleScrollButtons);
    
    // Attach fresh event listeners
    document.getElementById('scrollUpBtn').addEventListener('click', scrollToTop);
    document.getElementById('scrollDownBtn').addEventListener('click', scrollToBottom);
    window.addEventListener('scroll', toggleScrollButtons);
    window.addEventListener('resize', toggleScrollButtons);
    
    // Initial check
    toggleScrollButtons();
    
    // Force visible after a short delay to ensure DOM is ready
    setTimeout(() => {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const documentHeight = document.documentElement.scrollHeight;
        const windowHeight = window.innerHeight;
        
        if (documentHeight > windowHeight && scrollTop > 200) {
            floatingScroll.classList.add('visible');
        }
    }, 500);
}

// Initialize when DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initScrollButtons);
} else {
    initScrollButtons();
}
</script>

</body>
</html>