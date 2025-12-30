<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.classes.User"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.Result"%>
<%@page import="java.util.ArrayList"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>
 
<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Add Font Awesome for icons -->
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
        flex-wrap: wrap;
        align-items: center;
        width: 100%;
        margin: 0 -10px; /* Reduced gap */
    }

    /* Logo Column - Compact size */
    .logo-col {
        flex: 0 0 15%;
        max-width: 15%;
        padding: 0 10px;
    }

    /* Title Column - More space */
    .title-col {
        flex: 0 0 70%;
        max-width: 70%;
        padding: 0 10px;
        text-align: center;
    }

    /* User Column - Compact size */
    .user-col {
        flex: 0 0 15%;
        max-width: 15%;
        padding: 0 10px;
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
            margin-left: 200px;
            min-height: calc(100vh - 52px); /* Match new height */
            padding: 16px;
        }
        
        .content-wrapper {
            padding: 16px;
        }
    }

    @media (max-width: 767.98px) {
        .dashboard-header {
            padding: 4px 0; /* Very compact */
            height: 48px;
        }
        
        .header-container {
            padding: 0 8px;
        }
        
        .header-logo {
            max-height: 28px; /* Much smaller */
        }
        
        .header-title {
            font-size: 0.8125rem; /* Smaller */
            line-height: 1.2;
        }
        
        .header-subtitle {
            font-size: 0.5625rem; /* Smaller */
            margin-top: 0;
        }
        
        .user-name {
            display: none;
        }
        
        .user-role {
            display: none;
        }
        
        .logout-btn {
            padding: 3px 6px; /* Very compact */
            font-size: 0.6875rem;
        }
        
        .logout-btn span {
            display: none;
        }
        
        .logout-btn i {
            margin-right: 0;
            font-size: 0.6875rem;
        }
        
        .logo-col {
            flex: 0 0 20%;
            max-width: 20%;
        }
        
        .title-col {
            flex: 0 0 60%;
            max-width: 60%;
        }
        
        .user-col {
            flex: 0 0 20%;
            max-width: 20%;
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
</style>
</head>
<body>

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

    String panelTitle;

    if (currentUser.getType().equalsIgnoreCase("admin")) {
        panelTitle = "Administrator";
    } else if (currentUser.getType().equalsIgnoreCase("lecture")) {
        panelTitle = "Lecturer";
    } else {
        // For students or unhandled types
        panelTitle = "Student";
    }
%>

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
                <h1 class="header-title">Web-Based Online Assessment System</h1>
                <span class="header-subtitle">CodeSA Institute | Professional Testing Platform</span>
            </div>

            <!-- User Info Column -->
            <div class="user-col">
                <div class="user-section">
                    <div class="user-info" style="color: var(--text-white);">
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

<!-- Mobile Sidebar Toggle Button -->




    <!-- Main Content Area -->
    <main class="dashboard-content">
        <div class="content-wrapper">
             <!-- Delete Confirmation Modal -->
            <div id="deleteConfirmationModal" class="modal" style="display:none; position: fixed; z-index: 1001; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4);">
                <div class="modal-content" style="background-color: #fefefe; margin: 15% auto; padding: 20px; border: 1px solid #888; width: 80%; max-width: 400px; text-align: center; border-radius: 8px;">
                    <h2 style="margin-bottom: 20px;">Confirm Deletion</h2>
                    <p style="margin-bottom: 20px;" id="deleteModalText">Are you sure you want to delete this item? This action cannot be undone.</p>
                    <div style="display: flex; justify-content: center; gap: 10px;">
                        <button id="confirmDeleteBtn" class="btn btn-error">Delete</button>
                        <button id="cancelDeleteBtn" class="btn btn-secondary">Cancel</button>
                    </div>
                </div>
            </div>

            <!-- Permission Denied Modal -->
            <div id="permissionDeniedModal" class="modal" style="display:none; position: fixed; z-index: 1002; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4);">
                <div class="modal-content" style="background-color: #fefefe; margin: 15% auto; padding: 20px; border: 1px solid #888; width: 80%; max-width: 400px; text-align: center; border-radius: 8px;">
                    <h2 style="margin-bottom: 20px; color: var(--error);">Permission Denied</h2>
                    <p style="margin-bottom: 20px;">You do not have the required permissions to perform this action. Please contact an administrator.</p>
                    <div style="display: flex; justify-content: center;">
                        <button id="closePermissionModalBtn" class="btn btn-primary">OK</button>
                    </div>
                </div>
            </div>
            <%
                // Check if user is logged in
                if (session.getAttribute("userStatus") != null && session.getAttribute("userStatus").equals("1")) {
                    String pgprt = request.getParameter("pgprt");
                    
                    if (pgprt != null) {
                        if ("1".equals(pgprt)) {
            %>
                            <jsp:include page="accounts.jsp" />
            <%
                        } else if ("2".equals(pgprt)) {
            %>
                            <jsp:include page="courses.jsp" />
            <%
                        } else if ("3".equals(pgprt)) {
            %>
                            <jsp:include page="questions.jsp" />
            <%
                        } else if ("4".equals(pgprt)) {
            %>
                            <jsp:include page="showall.jsp" />
            <%
                        } else if ("5".equals(pgprt)) {
            %>
                            <jsp:include page="admin-results.jsp" />
            <%
                        } else if ("6".equals(pgprt)) {
            %>
                            <jsp:include page="Lecturers_accounts.jsp" />
            <%
                        } else {
                            // Default page: Profile
                            if (currentUser.getType().equalsIgnoreCase("admin")
                                || currentUser.getType().equalsIgnoreCase("lecture")) {
            %>
                                <jsp:include page="profile_staff.jsp" />
            <%
                            } else {
            %>
                                <jsp:include page="profile.jsp" />
            <%
                            }
                        }
                    } else {
                        // Default page when no pgprt parameter
                        if (currentUser.getType().equalsIgnoreCase("admin")
                            || currentUser.getType().equalsIgnoreCase("lecture")) {
            %>
                            <jsp:include page="profile_staff.jsp" />
            <%
                        } else {
            %>
                            <jsp:include page="profile.jsp" />
            <%
                        }
                    }
                } else {
                    // Redirect if session is invalid
                    response.sendRedirect("login.jsp");
                }
            %>
        </div>
    </main>
</div>

<script>
    // Mobile sidebar functionality
    document.addEventListener('DOMContentLoaded', function() {
        const sidebar = document.getElementById('dashboardSidebar');
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebarOverlay = document.getElementById('sidebarOverlay');
        
        // Toggle sidebar on button click
        if (sidebarToggle && sidebar) {
            sidebarToggle.addEventListener('click', function(e) {
                e.stopPropagation();
                sidebar.classList.toggle('active');
                sidebarOverlay.classList.toggle('active');
                document.body.style.overflow = sidebar.classList.contains('active') ? 'hidden' : '';
            });
        }
        
        // Close sidebar when clicking overlay
        if (sidebarOverlay) {
            sidebarOverlay.addEventListener('click', function() {
                sidebar.classList.remove('active');
                this.classList.remove('active');
                document.body.style.overflow = '';
            });
        }
        
        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function(e) {
            if (window.innerWidth <= 768 && sidebar.classList.contains('active')) {
                if (!sidebar.contains(e.target) && e.target !== sidebarToggle) {
                    sidebar.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                    document.body.style.overflow = '';
                }
            }
        });
        
        // Close sidebar when clicking nav items on mobile
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach(item => {
            item.addEventListener('click', function() {
                if (window.innerWidth <= 768) {
                    sidebar.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                    document.body.style.overflow = '';
                }
            });
        });
        
        // Add active state based on current page
        const currentPath = window.location.pathname + window.location.search;
        navItems.forEach(item => {
            if (item.href && currentPath.includes(new URL(item.href).search)) {
                item.classList.add('active');
            }
        });
        
        // Handle window resize
        let resizeTimer;
        window.addEventListener('resize', function() {
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(function() {
                if (window.innerWidth > 768) {
                    sidebar.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                    document.body.style.overflow = '';
                }
            }, 250);
        });
        
        // Header scroll effect
        let lastScroll = 0;
        const header = document.querySelector('.dashboard-header');
        
        if (header) {
            window.addEventListener('scroll', function() {
                const currentScroll = window.pageYOffset;
                
                if (currentScroll <= 0) {
                    header.style.boxShadow = '0 2px 12px rgba(0, 0, 0, 0.15)';
                    return;
                }
                
                if (currentScroll > lastScroll && currentScroll > 50) {
                    // Scrolling down
                    header.style.transform = 'translateY(-100%)';
                } else {
                    // Scrolling up
                    header.style.transform = 'translateY(0)';
                    header.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.2)';
                }
                
                lastScroll = currentScroll;
            });
        }
    });

    // Modal Logic
    document.addEventListener('DOMContentLoaded', function() {
        // Delete Confirmation Modal
        const deleteModal = document.getElementById('deleteConfirmationModal');
        const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
        const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
        const deleteModalText = document.getElementById('deleteModalText');
        let deleteUrl = '';

        // Permission Denied Modal
        const permissionModal = document.getElementById('permissionDeniedModal');
        const closePermissionBtn = document.getElementById('closePermissionModalBtn');

        document.body.addEventListener('click', function(e) {
            // Handle Delete Button Clicks
            if (e.target.closest('.btn-error')) {
                const deleteLink = e.target.closest('a');
                if (deleteLink && deleteLink.href.includes('operation=del')) {
                    e.preventDefault();
                    deleteUrl = deleteLink.href;
                    const itemName = deleteLink.getAttribute('data-item-name');
                    if (itemName) {
                        deleteModalText.textContent = `Are you sure you want to delete "${itemName}"? This action cannot be undone.`;
                    } else {
                        deleteModalText.textContent = 'Are you sure you want to delete this item? This action cannot be undone.';
                    }
                    deleteModal.style.display = 'block';
                }
            }

            // Handle Permission Check Clicks
            if (e.target.closest('.permission-check')) {
                const link = e.target.closest('a');
                if (link) {
                    e.preventDefault();
                    permissionModal.style.display = 'block';
                }
            }
        });

        // Event Listeners for Buttons
        if (cancelDeleteBtn) {
            cancelDeleteBtn.onclick = function() {
                deleteModal.style.display = 'none';
            }
        }

        if (confirmDeleteBtn) {
            confirmDeleteBtn.onclick = function() {
                window.location.href = deleteUrl;
            }
        }

        if (closePermissionBtn) {
            closePermissionBtn.onclick = function() {
                permissionModal.style.display = 'none';
            }
        }

        // Handle clicks outside of the modals
        window.onclick = function(event) {
            if (event.target == deleteModal) {
                deleteModal.style.display = 'none';
            }
            if (event.target == permissionModal) {
                permissionModal.style.display = 'none';
            }
        }
    });
</script>

</body>
</html>