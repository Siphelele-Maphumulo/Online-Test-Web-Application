<%@ page import="java.util.ArrayList" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="java.util.UUID" %>

<%
    String csrfToken = UUID.randomUUID().toString();
    session.setAttribute("csrf_token", csrfToken);
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

    User currentUser = null;
    if (session.getAttribute("userId") != null) {
        currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());
    }

    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    ArrayList list = pDAO.getAllCourses();
    int courseCount = list.size() / 5;
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

    /* Modal Styles */
    .modal {
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: rgba(0,0,0,0.5);
    }
    .modal-content {
        background-color: #fefefe;
        margin: 15% auto;
        padding: 20px;
        border: 1px solid #888;
        width: 80%;
        max-width: 500px;
        border-radius: var(--radius-md);
    }
    .close-btn {
        color: #aaa;
        float: right;
        font-size: 28px;
        font-weight: bold;
    }
    .close-btn:hover,
    .close-btn:focus {
        color: black;
        text-decoration: none;
        cursor: pointer;
    }
</style>

<script>
    const csrfToken = '<%= session.getAttribute("csrf_token") %>';
</script>

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
            
            <a href="adm-page.jsp?pgprt=7" class="nav-item">
               <i class="fas fa-users"></i>
               <h2>Registers</h2>
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
                                String courseName = (String) list.get(i);
                                boolean isActive = (Boolean) list.get(i + 4);
                                
                                // Format date for display and data attribute
                                java.sql.Date sqlDate = (java.sql.Date) list.get(i + 3);
                                String displayDate = "";
                                String dataDate = "";
                                if (sqlDate != null) {
                                    displayDate = sqlDate.toString();
                                    // Convert to YYYY-MM-DD format for input[type=date]
                                    dataDate = sqlDate.toLocalDate().toString();
                                }
                        %>
                        <tr id="course-row-<%= i %>">
                            <td>
                                <div class="course-name">
                                    <i class="fas fa-book" style="color: var(--accent-blue); margin-right: 8px;"></i>
                                    <span id="course-name-<%= i %>"><%= courseName %></span>
                                </div>
                            </td>
                            <td><span class="badge badge-success" id="total-marks-<%= i %>"><%= list.get(i + 1) %> Marks</span></td>
                            <td><span class="badge badge-info" id="time-<%= i %>"><%= list.get(i + 2) %> mins</span></td>
                            <td><span class="badge badge-neutral" id="exam-date-<%= i %>"><%= displayDate %></span></td>
                            <td>
                                <form action="controller.jsp" method="post" class="toggle-form" style="display: inline;">
                                    <input type="hidden" name="page" value="courses">
                                    <input type="hidden" name="operation" value="toggle_status">
                                    <input type="hidden" name="cname" value="<%= courseName %>">
                                    <label class="switch">
                                        <input type="checkbox" name="is_active" 
                                               <%= isActive ? "checked" : "" %> 
                                               onchange="this.form.submit()">
                                        <span class="slider round"></span>
                                    </label>
                                </form>
                                <span class="badge <%= isActive ? "badge-success" : "badge-neutral" %>" style="margin-left: 8px;">
                                    <%= isActive ? "Active" : "Inactive" %>
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn btn-primary edit-btn" 
                                            data-index="<%= i %>"
                                            data-course-name="<%= courseName %>"
                                            data-total-marks="<%= list.get(i + 1) %>" 
                                            data-time="<%= list.get(i + 2) %>"
                                            data-exam-date="<%= dataDate %>">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    <button onclick="confirmDelete('<%= courseName %>');" class="btn btn-danger">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
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

        <!-- Add/Edit Course Panel -->
        <div class="courses-card">
            <div class="card-header">
                <span id="form-title"><i class="fas fa-plus-circle"></i> Add New Course</span>
                <i class="fas fa-graduation-cap" style="opacity: 0.8;"></i>
            </div>
            <div class="add-course-form">
                <form action="controller.jsp" method="post" id="course-form">
                    <input type="hidden" id="original-course-name" name="original_course_name">
                    <input type="hidden" name="page" value="courses">
                    <input type="hidden" id="operation" name="operation" value="addnew">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book" style="color: var(--accent-blue);"></i>
                                Course Name
                            </label>
                            <input type="text" id="courseName" name="coursename" class="form-control" 
                                   placeholder="Enter course name (e.g., Mathematics 101)" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-chart-line" style="color: var(--success);"></i>
                                Total Marks
                            </label>
                            <input type="number" id="totalMarks" name="totalmarks" class="form-control" 
                                   placeholder="Enter total marks" required min="1" max="1000">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-clock" style="color: var(--info);"></i>
                                Exam Duration (minutes)
                            </label>
                            <input type="number" id="time" name="time" class="form-control" 
                                   placeholder="Duration in minutes" required min="1" max="480">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-calendar-alt" style="color: var(--dark-gray);"></i>
                                Exam Date
                            </label>
                            <input type="date" id="examDate" name="examdate" class="form-control" required>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" id="cancel-edit" class="btn btn-outline" style="display: none;">
                            <i class="fas fa-times"></i>
                            Cancel Edit
                        </button>
                        <button type="reset" class="btn btn-outline" onclick="resetForm()">
                            <i class="fas fa-redo"></i>
                            Reset Form
                        </button>
                        <button type="submit" id="submit-btn" class="btn btn-primary">
                            <i class="fas fa-plus"></i>
                            Add Course
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<!-- Update Confirmation Modal -->
<div id="updateConfirmationModal" class="modal" style="display:none;">
    <div class="modal-content">
        <div class="modal-header" style="background-color: var(--primary-blue); color: var(--white);">
            <h3 id="updateModalTitle"><i class="fas fa-question-circle"></i> Confirm Update</h3>
            <span class="close-btn" onclick="closeUpdateModal()">&times;</span>
        </div>
        <div class="modal-body" id="updateModalBody">
            <p>Please review the changes before confirming.</p>
        </div>
        <div class="modal-footer" style="border-top: 1px solid var(--medium-gray);">
            <button type="button" class="btn btn-outline" onclick="closeUpdateModal()">
                <i class="fas fa-times"></i> Cancel
            </button>
            <button type="button" id="confirm-update-btn" class="btn btn-primary">
                <i class="fas fa-check"></i> Confirm Update
            </button>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteConfirmationModal" class="modal" style="display:none;">
    <div class="modal-content">
        <div class="modal-header" style="background-color: var(--error); color: var(--white);">
            <h3 id="deleteModalTitle"><i class="fas fa-exclamation-triangle"></i> Confirm Deletion</h3>
            <span class="close-btn" onclick="closeDeleteModal()">&times;</span>
        </div>
        <div class="modal-body" id="deleteModalBody">
            <!-- Content will be set by JavaScript -->
        </div>
        <div class="modal-footer" style="border-top: 1px solid var(--medium-gray);">
            <button type="button" class="btn btn-outline" onclick="closeDeleteModal()">
                <i class="fas fa-times"></i> Cancel
            </button>
            <button type="button" id="confirm-delete-btn" class="btn btn-danger">
                <i class="fas fa-trash"></i> Confirm Delete
            </button>
        </div>
    </div>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- JavaScript for enhanced functionality -->
<script>
    // Global variable to track if we're editing
    let isEditing = false;
    let originalCourseName = null;
    let currentIndex = null;

    // Function to handle edit button click
    function handleEditButtonClick() {
        console.log('Edit button clicked:', this.dataset);
        
        isEditing = true;
        currentIndex = this.dataset.index;
        originalCourseName = this.dataset.courseName;
        
        // Populate form fields
        document.getElementById('original-course-name').value = originalCourseName;
        document.getElementById('courseName').value = this.dataset.courseName || '';
        document.getElementById('totalMarks').value = this.dataset.totalMarks || '';
        document.getElementById('time').value = this.dataset.time || '';
        
        // Handle exam date - ensure it's in YYYY-MM-DD format
        let examDateValue = this.dataset.examDate || '';
        console.log('Exam date from data:', examDateValue);
        
        if (examDateValue) {
            // If date is in a different format, convert it
            const date = new Date(examDateValue);
            if (!isNaN(date.getTime())) {
                const year = date.getFullYear();
                const month = String(date.getMonth() + 1).padStart(2, '0');
                const day = String(date.getDate()).padStart(2, '0');
                examDateValue = `${year}-${month}-${day}`;
            }
        }
        
        document.getElementById('examDate').value = examDateValue;
        console.log('Exam date set to:', document.getElementById('examDate').value);
        
        // Change form operation
        document.getElementById('operation').value = 'update_course';
        
        // Update UI
        document.getElementById('form-title').innerHTML = '<i class="fas fa-edit"></i> Edit Course';
        document.getElementById('submit-btn').innerHTML = '<i class="fas fa-save"></i> Update Course';
        document.getElementById('cancel-edit').style.display = 'inline-block';
        
        // Show warning about course name change
        showCourseNameWarning();
        
        // Scroll to form
        document.querySelector('.add-course-form').scrollIntoView({ 
            behavior: 'smooth', 
            block: 'start' 
        });
        
        // Focus on the course name field
        setTimeout(() => {
            document.getElementById('courseName').focus();
        }, 300);
    }

    // Function to reset form
    function resetForm() {
        isEditing = false;
        originalCourseName = null;
        currentIndex = null;
        
        // Reset form fields
        document.getElementById('original-course-name').value = '';
        document.getElementById('courseName').value = '';
        document.getElementById('totalMarks').value = '';
        document.getElementById('time').value = '';
        document.getElementById('examDate').value = '';
        
        // Reset form operation
        document.getElementById('operation').value = 'addnew';
        
        // Reset UI
        document.getElementById('form-title').innerHTML = '<i class="fas fa-plus-circle"></i> Add New Course';
        document.getElementById('submit-btn').innerHTML = '<i class="fas fa-plus"></i> Add Course';
        document.getElementById('cancel-edit').style.display = 'none';
        
        // Hide warning
        hideCourseNameWarning();
        
        // Focus on course name field
        setTimeout(() => {
            document.getElementById('courseName').focus();
        }, 300);
    }

    // Function to show warning about course name change
    function showCourseNameWarning() {
        let warningDiv = document.getElementById('course-name-warning');
        if (!warningDiv) {
            warningDiv = document.createElement('div');
            warningDiv.id = 'course-name-warning';
            warningDiv.className = 'alert alert-warning';
            warningDiv.style.cssText = 'background-color: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 12px; border-radius: 4px; margin-bottom: 16px; font-size: 13px;';
            warningDiv.innerHTML = '<i class="fas fa-exclamation-triangle"></i> <strong>Warning:</strong> Changing the course name will update all related exams and questions.';
            
            const formGrid = document.querySelector('.form-grid');
            formGrid.parentNode.insertBefore(warningDiv, formGrid);
        }
    }

    // Function to hide warning
    function hideCourseNameWarning() {
        const warningDiv = document.getElementById('course-name-warning');
        if (warningDiv) {
            warningDiv.remove();
        }
    }

    function closeUpdateModal() {
        const modal = document.getElementById('updateConfirmationModal');
        if (modal) {
            modal.style.display = 'none';
        }
    }

    function closeDeleteModal() {
        const modal = document.getElementById('deleteConfirmationModal');
        if (modal) {
            modal.style.display = 'none';
        }
    }

    // Function for delete confirmation
    function confirmDelete(courseName) {
        const modal = document.getElementById('deleteConfirmationModal');
        const modalBody = document.getElementById('deleteModalBody');
        const confirmBtn = document.getElementById('confirm-delete-btn');

        const decodedCourseName = decodeURIComponent(courseName);

        modalBody.innerHTML =
            '<p>Are you sure you want to delete the course <strong>"' + decodedCourseName + '"</strong>?</p>' +
            '<p class="alert alert-warning" style="margin-top: 16px;">' +
                '<i class="fas fa-exclamation-triangle"></i>' +
                'This will permanently delete the course, all associated questions, and all exam records. <strong>This action cannot be undone.</strong>' +
            '</p>';

        confirmBtn.onclick = function() {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'controller.jsp';

            const csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = 'csrf_token';
            csrfInput.value = csrfToken;
            form.appendChild(csrfInput);

            const pageInput = document.createElement('input');
            pageInput.type = 'hidden';
            pageInput.name = 'page';
            pageInput.value = 'courses';
            form.appendChild(pageInput);

            const operationInput = document.createElement('input');
            operationInput.type = 'hidden';
            operationInput.name = 'operation';
            operationInput.value = 'del';
            form.appendChild(operationInput);

            const cnameInput = document.createElement('input');
            cnameInput.type = 'hidden';
            cnameInput.name = 'cname';
            cnameInput.value = courseName;
            form.appendChild(cnameInput);

            document.body.appendChild(form);
            form.submit();
        };

        modal.style.display = 'block';
    }

    // Initialize when DOM is loaded
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Course management page loaded');
        
        // Attach event listeners to edit buttons
        const editButtons = document.querySelectorAll('.edit-btn');
        console.log('Found edit buttons:', editButtons.length);
        
        editButtons.forEach(button => {
            button.addEventListener('click', handleEditButtonClick);
        });
        
        // Cancel edit button handler
        const cancelEditBtn = document.getElementById('cancel-edit');
        if (cancelEditBtn) {
            cancelEditBtn.addEventListener('click', function(e) {
                e.preventDefault();
                resetForm();
            });
        }
        
        // Confirm update button handler
        const confirmUpdateBtn = document.getElementById('confirm-update-btn');
        if (confirmUpdateBtn) {
            confirmUpdateBtn.addEventListener('click', function() {
                const courseForm = document.getElementById('course-form');
                const submitBtn = courseForm.querySelector('#submit-btn');

                if (submitBtn) {
                    submitBtn.classList.add('loading');
                    submitBtn.disabled = true;
                    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
                }

                courseForm.submit();
            });
        }

        // Form submission handler
        const courseForm = document.getElementById('course-form');
        if (courseForm) {
            courseForm.addEventListener('submit', function(e) {
                e.preventDefault(); // Always prevent default submission

                const submitBtn = this.querySelector('#submit-btn');
                const newCourseName = document.getElementById('courseName').value.trim();
                const originalCourseNameFromInput = document.getElementById('original-course-name').value;

                if (isEditing && newCourseName !== originalCourseNameFromInput) {
                    // Show confirmation modal
                    const modal = document.getElementById('updateConfirmationModal');
                    const modalBody = document.getElementById('updateModalBody');

                    modalBody.innerHTML =
                        '<p>You are about to rename the course from <strong>"' + originalCourseNameFromInput + '"</strong> to <strong>"' + newCourseName + '"</strong>.</p>' +
                        '<p class="alert alert-warning" style="margin-top: 16px;">' +
                            '<i class="fas fa-exclamation-triangle"></i>' +
                            'This will update all associated questions and exam records. This action cannot be undone.' +
                        '</p>' +
                        '<p>Are you sure you want to proceed?</p>';

                    modal.style.display = 'block';
                } else {
                    // If not editing or name hasn't changed, submit directly
                    submitBtn.classList.add('loading');
                    submitBtn.disabled = true;
                    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
                    this.submit();
                }
            });
        }
        
        // Set min date for exam date to today
        const examDateInput = document.getElementById('examDate');
        if (examDateInput) {
            const today = new Date().toISOString().split('T')[0];
            examDateInput.min = today;
            
            // If not editing, set default to today
            if (!isEditing) {
                examDateInput.value = today;
            }
        }
        
        console.log('Course management initialized successfully');
    });

    // Also initialize if DOM is already loaded
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        setTimeout(() => {
            document.querySelectorAll('.edit-btn').forEach(button => {
                button.addEventListener('click', handleEditButtonClick);
            });
        }, 100);
    }
    
    // Close modal when clicking outside (if you have modals)
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('course-name-warning');
        if (event.target === modal) {
            hideCourseNameWarning();
        }
    });
</script>

<style>
    .action-buttons {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }
    
    .switch {
        position: relative;
        display: inline-block;
        width: 50px;
        height: 24px;
        vertical-align: middle;
    }
    
    .switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }
    
    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc;
        transition: .4s;
    }
    
    .slider:before {
        position: absolute;
        content: "";
        height: 16px;
        width: 16px;
        left: 4px;
        bottom: 4px;
        background-color: white;
        transition: .4s;
    }
    
    input:checked + .slider {
        background-color: var(--success);
    }
    
    input:checked + .slider:before {
        transform: translateX(26px);
    }
    
    .slider.round {
        border-radius: 24px;
    }
    
    .slider.round:before {
        border-radius: 50%;
    }
    
    .btn.loading {
        opacity: 0.7;
        cursor: not-allowed;
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    .fa-spinner {
        animation: spin 1s linear infinite;
    }
    
    /* Alert styling */
    .alert {
        padding: 12px;
        border-radius: 4px;
        margin-bottom: 16px;
        font-size: 13px;
    }
    
    .alert-warning {
        background-color: #fff3cd;
        border: 1px solid #ffeaa7;
        color: #856404;
    }
    
    .alert-warning i {
        color: #856404;
        margin-right: 8px;
    }
</style>