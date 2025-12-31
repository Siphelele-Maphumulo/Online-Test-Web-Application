<%@ page import="java.util.ArrayList" %>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>
 
<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
%>

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
    
    /* Courses Management Cards */
    .courses-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        margin-bottom: var(--spacing-lg);
        overflow: hidden;
        transition: transform var(--transition-normal), box-shadow var(--transition-normal);
    }
    
    .courses-card:hover {
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
    
    /* Courses Table */
    .courses-table {
        width: 100%;
        border-collapse: collapse;
        background: var(--white);
    }
    
    .courses-table thead th {
        background: var(--light-gray);
        color: var(--text-dark);
        padding: var(--spacing-md);
        font-weight: 600;
        text-align: left;
        border-bottom: 1px solid var(--medium-gray);
        font-size: 13px;
        white-space: nowrap;
    }
    
    .courses-table tbody td {
        padding: var(--spacing-md);
        border-bottom: 1px solid var(--light-gray);
        vertical-align: middle;
        color: var(--dark-gray);
        font-size: 13px;
    }
    
    .courses-table tbody tr {
        transition: background-color var(--transition-fast);
    }
    
    .courses-table tbody tr:hover {
        background-color: var(--light-gray);
    }
    
    .course-name {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    /* Badge Styles */
    .badge {
        color: var(--white);
        padding: 4px 10px;
        border-radius: 12px;
        font-weight: 500;
        font-size: 12px;
        display: inline-block;
        white-space: nowrap;
    }
    
    .badge-success {
        background: var(--success);
    }
    
    .badge-info {
        background: var(--info);
    }
    
    .badge-neutral {
        background: var(--dark-gray);
    }
    
    /* Buttons - Consistent with profile page */
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
        padding: 8px 16px;
        border-radius: var(--radius-sm);
        font-size: 13px;
        font-weight: 500;
        text-decoration: none;
        cursor: pointer;
        border: none;
        transition: all var(--transition-normal);
    }
    
    .btn-danger {
        background: linear-gradient(90deg, var(--error), #ef4444);
        color: var(--white);
    }
    
    .btn-danger:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
    }
    
    .btn-primary {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
    }
    
    .btn-primary:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(9, 41, 77, 0.2);
    }
    
    .btn-outline {
        background: transparent;
        border: 1px solid var(--medium-gray);
        color: var(--dark-gray);
    }
    
    /* Form Styles - Consistent with profile page */
    .add-course-form {
        padding: var(--spacing-lg);
    }
    
    .form-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
        background: var(--white);
        color: var(--text-dark);
    }
    
    .form-control:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }
    
    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: var(--spacing-md);
        padding-top: var(--spacing-lg);
        border-top: 1px solid var(--medium-gray);
        margin-top: var(--spacing-lg);
    }
    
    /* No Courses Message */
    .no-courses {
        text-align: center;
        padding: var(--spacing-xl) var(--spacing-xl);
        color: var(--dark-gray);
        font-style: italic;
        font-size: 14px;
    }
    
    .courses-count {
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
        
        .form-actions {
            flex-direction: column;
        }
        
        .btn {
            width: 100%;
        }
        
        .courses-table {
            display: block;
            overflow-x: auto;
            white-space: nowrap;
        }
    }
    
    @media (max-width: 480px) {
        .main-content {
            padding: var(--spacing-md);
        }
        
        .add-course-form {
            padding: var(--spacing-md);
        }
        
        .courses-table thead th,
        .courses-table tbody td {
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
            <a href="adm-page.jsp?pgprt=2" class="nav-item active">
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
        </nav>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <!-- Page Header -->
        <header class="page-header">
            <div class="page-title">
                <i class="fas fa-book-open"></i>
                Course Management
            </div>
            <div class="stats-badge">
                <i class="fas fa-graduation-cap"></i>
                <%
                    ArrayList list = pDAO.getAllCourses();
                    int courseCount = list.size() / 5;
                %>
                <%= courseCount %> Courses
            </div>
        </header>
        
        <!-- All Courses Panel -->
        <div class="courses-card">
            <div class="card-header">
                <span><i class="fas fa-list"></i> All Courses</span>
                <div class="courses-count">
                    <i class="fas fa-layer-group"></i>
                    Total: <%= courseCount %>
                </div>
            </div>
            <div style="overflow-x: auto;">
                <table class="courses-table">
                    <thead>
                        <tr>
                            <th>Course Name</th>
                            <th>Total Marks</th>
                            <th>Duration</th>
                            <th>Exam Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (list.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="6" class="no-courses">
                                    <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                                    No courses available. Add your first course to get started.
                                </td>
                            </tr>
                        <%
                        } else {
                            for (int i = 0; i < list.size(); i += 5) {
                                if (i + 4 < list.size()) {
                                    boolean isActive = (Boolean) list.get(i + 4);
                        %>
                        <tr>
                            <td>
                                <div class="course-name">
                                    <i class="fas fa-book" style="color: var(--accent-blue); margin-right: 8px;"></i>
                                    <%= list.get(i) %>
                                </div>
                            </td>
                            <td><span class="badge badge-success"><%= list.get(i + 1) %> Marks</span></td>
                            <td><span class="badge badge-info"><%= list.get(i + 2) %> mins</span></td>
                            <td><span class="badge badge-neutral"><%= list.get(i + 3) %></span></td>
                            <td><span class="badge <%= isActive ? "badge-success" : "badge-danger" %>"><%= isActive ? "Active" : "Inactive" %></span></td>
                            <td>
                                <a href="controller.jsp?page=courses&operation=toggle_status&cname=<%= list.get(i) %>" class="btn btn-<%= isActive ? "danger" : "success" %>">
                                    <i class="fas fa-power-off"></i>
                                    <%= isActive ? "Deactivate" : "Activate" %>
                                </a>
                                <a href="controller.jsp?page=courses&operation=del&cname=<%= list.get(i) %>"
                                   onclick="return confirm('Are you sure you want to delete \"<%= list.get(i) %>\"? This action cannot be undone.');" 
                                   class="btn btn-danger">
                                   <i class="fas fa-trash"></i>
                                   Delete
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Add New Course Panel -->
        <div class="courses-card">
            <div class="card-header">
                <span><i class="fas fa-plus-circle"></i> Add New Course</span>
                <i class="fas fa-graduation-cap" style="opacity: 0.8;"></i>
            </div>
            <div class="add-course-form">
                <form action="controller.jsp" method="post">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book" style="color: var(--accent-blue);"></i>
                                Course Name
                            </label>
                            <input type="text" name="coursename" class="form-control" 
                                   placeholder="Enter course name (e.g., Mathematics 101)" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-chart-line" style="color: var(--success);"></i>
                                Total Marks
                            </label>
                            <input type="number" name="totalmarks" class="form-control" 
                                   placeholder="Enter total marks" required min="1" max="1000">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-clock" style="color: var(--info);"></i>
                                Exam Duration
                            </label>
                            <input type="number" name="time" class="form-control" 
                                   placeholder="Duration in minutes" required min="1" max="480">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-calendar-alt" style="color: var(--dark-gray);"></i>
                                Exam Date
                            </label>
                            <input type="date" name="examdate" class="form-control" required>
                        </div>
                    </div>
                    
                    <input type="hidden" name="page" value="courses">
                    <input type="hidden" name="operation" value="addnew">
                    
                    <div class="form-actions">
                        <button type="reset" class="btn btn-outline">
                            <i class="fas fa-redo"></i>
                            Reset Form
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-plus"></i>
                            Add Course
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

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
        
        // Handle delete confirmation
        const deleteButtons = document.querySelectorAll('.btn-danger');
        deleteButtons.forEach(btn => {
            btn.addEventListener('click', function(e) {
                const courseName = this.closest('tr').querySelector('.course-name').textContent.trim();
                const confirmation = confirm(`Are you sure you want to delete "${courseName}"? This action cannot be undone.`);
                if (!confirmation) {
                    e.preventDefault();
                }
            });
        });
    });
    
    // Handle window resize for responsive adjustments
    window.addEventListener('resize', function() {
        // Add any responsive adjustments here
    });
</script>