<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>

<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
%>

<!-- Modal for validation messages -->
<div id="validationModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle"><i class="fas fa-exclamation-triangle"></i> Validation Error</h3>
            <span class="close-modal" onclick="closeModal()">&times;</span>
        </div>
        <div class="modal-body">
            <p id="modalMessage"></p>
        </div>
        <div class="modal-footer">
            <button onclick="closeModal()" class="btn btn-primary">OK</button>
        </div>
    </div>
</div>

<!-- Success/Error Toast -->
<div id="toast" class="toast" style="display: none;">
    <div class="toast-content">
        <i id="toastIcon" class="fas"></i>
        <div class="toast-message">
            <strong id="toastTitle"></strong>
            <span id="toastText"></span>
        </div>
        <button class="toast-close" onclick="hideToast()">&times;</button>
    </div>
</div>

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
    
    /* Question Cards */
    .question-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        margin-bottom: var(--spacing-lg);
        overflow: hidden;
        transition: transform var(--transition-normal), box-shadow var(--transition-normal);
    }
    
    .question-card:hover {
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
    
    /* Question Form */
    .question-form {
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
    
    .form-control,
    .form-select,
    .question-input,
    .option-input {
        padding: 10px 12px;
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        font-size: 14px;
        transition: all var(--transition-fast);
        background: var(--white);
        color: var(--text-dark);
    }
    
    .form-control:focus,
    .form-select:focus,
    .question-input:focus,
    .option-input:focus {
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
    
    /* Options Grid */
    .options-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: var(--spacing-sm);
        margin: var(--spacing-md) 0;
    }
    
    .question-input {
        width: 100%;
        min-height: 100px;
        resize: vertical;
    }
    
    /* Form Actions - Consistent with profile page */
    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: var(--spacing-md);
        padding-top: var(--spacing-lg);
        border-top: 1px solid var(--medium-gray);
        margin-top: var(--spacing-lg);
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
    
    .btn-outline {
        background: transparent;
        border: 1px solid var(--medium-gray);
        color: var(--dark-gray);
    }
    
    .btn-outline:hover {
        background: var(--light-gray);
        border-color: var(--dark-gray);
    }
    
    /* Alert Messages */
    .alert {
        background: #d4edda;
        color: #155724;
        padding: var(--spacing-md);
        border-radius: var(--radius-sm);
        margin-bottom: var(--spacing-lg);
        border: 1px solid #c3e6cb;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .alert i {
        color: var(--success);
    }
    
    /* Checkbox Styling */
    .form-check {
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        padding: var(--spacing-sm);
        background: var(--light-gray);
        border-radius: var(--radius-sm);
        border: 1px solid var(--medium-gray);
        transition: all var(--transition-fast);
    }
    
    .form-check:hover {
        background: var(--white);
        border-color: var(--accent-blue);
    }
    
    .form-check-label {
        font-size: 13px;
        color: var(--text-dark);
        cursor: pointer;
    }
    
    .form-check-input {
        accent-color: var(--primary-blue);
    }
    
    .form-hint {
        font-size: 12px;
        color: var(--dark-gray);
        margin-top: var(--spacing-xs);
    }
    
    /* Utility Classes */
    .hidden {
        display: none;
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
        
        .options-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    
    @media (max-width: 480px) {
        .main-content {
            padding: var(--spacing-md);
        }
        
        .question-form {
            padding: var(--spacing-md);
        }
        
        .options-grid {
            grid-template-columns: 1fr;
        }
        
        .card-header {
            flex-direction: column;
            gap: var(--spacing-sm);
            text-align: center;
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
    /* Add these styles to eliminate scrolling */
    .main-content {
        position: relative;
        max-height: calc(100vh - 100px);
        overflow-y: auto;
        padding-right: 10px;
    }
    
    .main-content::-webkit-scrollbar {
        width: 8px;
    }
    
    .main-content::-webkit-scrollbar-track {
        background: var(--light-gray);
        border-radius: 4px;
    }
    
    .main-content::-webkit-scrollbar-thumb {
        background: var(--dark-gray);
        border-radius: 4px;
    }
    
    .question-card:first-of-type {
        margin-bottom: 30px;
    }
    
    .sticky-add-form {
        position: sticky;
        top: 20px;
        background: var(--white);
        box-shadow: var(--shadow-lg);
        border: 2px solid var(--primary-blue);
        border-radius: var(--radius-md);
        z-index: 100;
        margin-top: 20px;
    }
    
    .quick-add-indicator {
        background: linear-gradient(90deg, var(--success-light), #d4edda);
        color: var(--success);
        padding: 8px 12px;
        border-radius: var(--radius-sm);
        margin-bottom: 15px;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 8px;
        border-left: 3px solid var(--success);
        animation: fadeIn 0.5s ease;
    }
    
    .quick-add-indicator i {
        font-size: 14px;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .form-highlight {
        animation: pulseHighlight 2s ease-in-out;
    }
    
    @keyframes pulseHighlight {
        0% { box-shadow: 0 0 0 0 rgba(9, 41, 77, 0.7); }
        70% { box-shadow: 0 0 0 10px rgba(9, 41, 77, 0); }
        100% { box-shadow: 0 0 0 0 rgba(9, 41, 77, 0); }
    }
    
    
.scroll-indicator{
    position:fixed;
    right:20px;
    bottom:20px;
    width:48px;
    height:48px;
    background:#2563eb;
    color:#fff;
    border-radius:50%;
    display:flex;
    align-items:center;
    justify-content:center;
    cursor:pointer;
    z-index:1000;
    box-shadow:0 6px 20px rgba(0,0,0,.3);
}
</style>

<style>
/* Modal Styles */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
    animation: fadeIn 0.3s;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-content {
    background-color: #fff;
    margin: 10% auto;
    padding: 0;
    border-radius: 8px;
    width: 90%;
    max-width: 500px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    animation: slideDown 0.3s;
}

@keyframes slideDown {
    from { transform: translateY(-50px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

.modal-header {
    padding: 16px 20px;
    background-color: #f8f9fa;
    border-bottom: 1px solid #dee2e6;
    border-radius: 8px 8px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-header h3 {
    margin: 0;
    color: #333;
    font-size: 18px;
}

.close-modal {
    color: #aaa;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
    line-height: 20px;
}

.close-modal:hover {
    color: #000;
}

.modal-body {
    padding: 20px;
    color: #333;
    font-size: 16px;
    line-height: 1.5;
}

.modal-footer {
    padding: 16px 20px;
    background-color: #f8f9fa;
    border-top: 1px solid #dee2e6;
    border-radius: 0 0 8px 8px;
    text-align: right;
}

/* Toast Styles */
.toast {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 1001;
    min-width: 300px;
    max-width: 400px;
    animation: slideInRight 0.3s;
}

@keyframes slideInRight {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}

.toast-content {
    background: white;
    border-radius: 8px;
    padding: 16px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    display: flex;
    align-items: flex-start;
    border-left: 4px solid;
}

.toast.success {
    border-left-color: #28a745;
}

.toast.error {
    border-left-color: #dc3545;
}

.toast.warning {
    border-left-color: #ffc107;
}

.toast.info {
    border-left-color: #17a2b8;
}

.toast-message {
    flex: 1;
    margin-left: 12px;
}

.toast-message strong {
    display: block;
    margin-bottom: 4px;
    color: #333;
}

.toast-message span {
    color: #666;
    font-size: 14px;
}

.toast-close {
    background: none;
    border: none;
    color: #999;
    font-size: 20px;
    cursor: pointer;
    padding: 0;
    margin-left: 12px;
    line-height: 1;
}

.toast-close:hover {
    color: #666;
}

/* Form Validation Styles */
.input-error {
    border-color: #dc3545 !important;
    background-color: #fff5f5 !important;
}

.error-message {
    color: #dc3545;
    font-size: 12px;
    margin-top: 4px;
    display: none;
}

.form-group.has-error .error-message {
    display: block;
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
            <a href="adm-page.jsp?pgprt=3" class="nav-item active">
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
                <i class="fas fa-question-circle"></i>
                Question Management
            </div>
            <div class="stats-badge">
                <i class="fas fa-database"></i>
                Manage Questions
            </div>
        </header>
        
        <!-- Show Questions Panel -->
        <div class="question-card" id="showQuestionsPanel">
            <div class="card-header">
                <span><i class="fas fa-list"></i> Show All Questions</span>
                <i class="fas fa-search" style="opacity: 0.8;"></i>
            </div>
            <div class="question-form">
                <form action="adm-page.jsp">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book" style="color: var(--accent-blue);"></i>
                                Select Course
                            </label>
                            <select name="coursename" class="form-select" id="courseSelectShowAll" required>
                                <% 
                                ArrayList<String> courseNames = pDAO.getAllCourseNames(); 
                                String lastCourseName = pDAO.getLastCourseName();
                                
                                if (courseNames.isEmpty()) {
                                %>
                                    <option value="">No courses available</option>
                                <%
                                } else {
                                    for (String course : courseNames) {
                                        boolean isSelected = (lastCourseName != null && lastCourseName.equals(course)) || 
                                                           (lastCourseName == null && course.equals(courseNames.get(0)));
                                %>
                                <option value="<%=course%>" <%=isSelected ? "selected" : ""%>><%=course%></option>
                                <% 
                                    }
                                } 
                                %>
                            </select>
                        </div>
                    </div>
                    
                    <input type="hidden" name="pgprt" value="4">
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-success" <%=courseNames.isEmpty() ? "disabled" : ""%>>
                            <i class="fas fa-eye"></i>
                            Show Questions
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Add New Question Panel -->
        <div class="question-card" id="addQuestionPanel">
            <div class="card-header">
                <span><i class="fas fa-plus-circle"></i> Add New Question</span>
                <i class="fas fa-edit" style="opacity: 0.8;"></i>
            </div>
            <div class="question-form">
                <form action="controller.jsp" method="POST" id="questionForm">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book" style="color: var(--accent-blue);"></i>
                                Select Course
                            </label>
                            <select name="coursename" class="form-select" id="courseSelectAddNew" required>
                                <% 
                                ArrayList<String> allCourseNames = pDAO.getAllCourseNames();
                                if (allCourseNames.isEmpty()) {
                                %>
                                    <option value="">No courses available. Please add courses first.</option>
                                <%
                                } else {
                                %>
                                    <option value="">Select Course</option>
                                <%
                                    for (String course : allCourseNames) {
                                        boolean isSelected = (lastCourseName != null && lastCourseName.equals(course)) || 
                                                           (lastCourseName == null && course.equals(allCourseNames.get(0)));
                                %>
                                <option value="<%=course%>" <%=isSelected ? "selected" : ""%>><%=course%></option>
                                <% 
                                    }
                                } 
                                %>
                            </select>
                            <% if (allCourseNames.isEmpty()) { %>
                            <small style="color: var(--error); font-size: 12px;">
                                <i class="fas fa-exclamation-triangle"></i> 
                                You need to add courses first before adding questions.
                            </small>
                            <% } %>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-question" style="color: var(--info);"></i>
                                Question Type
                            </label>
                            <select name="questionType" id="questionType" class="form-select" onchange="toggleOptions()">
                                <option value="MCQ">Multiple Choice (Single Answer)</option>
                                <option value="MultipleSelect">Multiple Select (Choose Two)</option>
                                <option value="TrueFalse">True/False</option>
                                <option value="Code">Code Snippet</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-pencil-alt" style="color: var(--success);"></i>
                            Your Question
                        </label>
                        <textarea name="question" id="questionText" class="question-input" placeholder="Type your question here" required rows="3"></textarea>
                        <div class="error-message" id="questionError">Question is required</div>
                    </div>
                    
                    <div id="mcqOptions">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-list-ol" style="color: var(--dark-gray);"></i>
                                Options
                            </label>
                            <div class="options-grid">
                                <div class="option-container">
                                    <input type="text" name="opt1" class="option-input" placeholder="First Option" id="opt1" required>
                                    <div class="error-message" id="opt1Error">First option is required</div>
                                </div>
                                <div class="option-container">
                                    <input type="text" name="opt2" class="option-input" placeholder="Second Option" id="opt2" required>
                                    <div class="error-message" id="opt2Error">Second option is required</div>
                                </div>
                                <div class="option-container">
                                    <input type="text" name="opt3" class="option-input" placeholder="Third Option" id="opt3">
                                    <div class="error-message" id="opt3Error"></div>
                                </div>
                                <div class="option-container">
                                    <input type="text" name="opt4" class="option-input" placeholder="Fourth Option" id="opt4">
                                    <div class="error-message" id="opt4Error"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-check-circle" style="color: var(--success);"></i>
                            Correct Answer
                        </label>
                        
                        <!-- Single Answer Input (for MCQ and True/False) -->
                        <div id="correctAnswerContainer">
                            <input type="text" id="correctAnswer" name="correct" class="form-control" placeholder="Enter correct answer" required>
                            <div class="error-message" id="correctAnswerError">Correct answer is required</div>
                            <small id="correctAnswerHint" class="form-hint">Enter the correct answer (must match one of the options exactly)</small>
                        </div>
                        
                        <!-- Multiple Answer Selection (for MultipleSelect) -->
                        <div id="multipleCorrectContainer" style="display: none;">
                            <div class="options-grid">
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt1" name="correctOpt1" value="" class="form-check-input correct-checkbox">
                                    <label for="correctOpt1" class="form-check-label">Option 1</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt2" name="correctOpt2" value="" class="form-check-input correct-checkbox">
                                    <label for="correctOpt2" class="form-check-label">Option 2</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt3" name="correctOpt3" value="" class="form-check-input correct-checkbox">
                                    <label for="correctOpt3" class="form-check-label">Option 3</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt4" name="correctOpt4" value="" class="form-check-input correct-checkbox">
                                    <label for="correctOpt4" class="form-check-label">Option 4</label>
                                </div>
                            </div>
                            <!-- Hidden field that will store the combined correct answers -->
                            <input type="hidden" id="multipleCorrectAnswer" name="correctMultiple">
                            <div class="error-message" id="multipleCorrectError">Select exactly 2 correct answers</div>
                            <small id="multipleCorrectHint" class="form-hint">Select exactly 2 correct answers</small>
                        </div>
                    </div>
                    
                    <input type="hidden" name="page" value="questions">
                    <input type="hidden" name="operation" value="addnew">
                    
                    <div class="form-actions">
                        <button type="reset" class="btn btn-outline" onclick="resetQuestionForm()">
                            <i class="fas fa-redo"></i>
                            Reset Form
                        </button>
                        <button type="button" class="btn btn-primary" id="submitBtn" onclick="validateAndSubmit()">
                            <i class="fas fa-plus"></i>
                            Add Question
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<!-- Scroll Indicator Button -->
<div class="scroll-indicator" id="scrollIndicator">
    <i class="fas fa-arrow-down"></i>
</div>

<!-- Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- JavaScript for enhanced functionality -->
<script>
// Modal functions
function showModal(title, message) {
    document.getElementById('modalTitle').innerHTML = '<i class="fas fa-exclamation-triangle"></i> ' + title;
    document.getElementById('modalMessage').textContent = message;
    document.getElementById('validationModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('validationModal').style.display = 'none';
}

// Toast functions
function showToast(type, title, message) {
    const toast = document.getElementById('toast');
    const toastIcon = document.getElementById('toastIcon');
    const toastTitle = document.getElementById('toastTitle');
    const toastText = document.getElementById('toastText');
    
    toast.className = 'toast ' + type;
    toastTitle.textContent = title;
    toastText.textContent = message;
    
    switch(type) {
        case 'success':
            toastIcon.className = 'fas fa-check-circle';
            toastIcon.style.color = '#28a745';
            break;
        case 'error':
            toastIcon.className = 'fas fa-times-circle';
            toastIcon.style.color = '#dc3545';
            break;
        case 'warning':
            toastIcon.className = 'fas fa-exclamation-triangle';
            toastIcon.style.color = '#ffc107';
            break;
        case 'info':
            toastIcon.className = 'fas fa-info-circle';
            toastIcon.style.color = '#17a2b8';
            break;
    }
    
    toast.style.display = 'block';
    setTimeout(hideToast, 5000);
}

function hideToast() {
    document.getElementById('toast').style.display = 'none';
}

// Form validation functions
function validateQuestionForm() {
    let isValid = true;
    const type = document.getElementById("questionType").value;
    const question = document.getElementById("questionText").value.trim();
    const course = document.getElementById("courseSelectAddNew").value;
    
    // Clear previous errors
    clearErrors();
    
    // Basic validations
    if (!question) {
        showError('questionText', 'questionError', 'Question is required');
        isValid = false;
    }
    
    if (!course) {
        showError('courseSelectAddNew', null, 'Please select a course');
        isValid = false;
    }
    
    // Type-specific validations
    if (type === "TrueFalse") {
        const correctAnswer = document.getElementById("correctAnswer").value.trim();
        if (!correctAnswer) {
            showError('correctAnswer', 'correctAnswerError', 'Correct answer is required');
            isValid = false;
        } else if (correctAnswer !== "True" && correctAnswer !== "False") {
            showError('correctAnswer', 'correctAnswerError', 'Correct answer must be "True" or "False"');
            isValid = false;
        }
        
    } else if (type === "MultipleSelect") {
        // Check options
        const opt1 = document.getElementById("opt1").value.trim();
        const opt2 = document.getElementById("opt2").value.trim();
        
        if (!opt1) {
            showError('opt1', 'opt1Error', 'First option is required');
            isValid = false;
        }
        if (!opt2) {
            showError('opt2', 'opt2Error', 'Second option is required');
            isValid = false;
        }
        
        // Check for duplicate options
        const options = [opt1, opt2];
        if (document.getElementById("opt3").value.trim()) options.push(document.getElementById("opt3").value.trim());
        if (document.getElementById("opt4").value.trim()) options.push(document.getElementById("opt4").value.trim());
        
        const uniqueOptions = [...new Set(options)];
        if (uniqueOptions.length !== options.length) {
            showModal('Duplicate Options', 'Options must be unique. Please provide different values for each option.');
            isValid = false;
        }
        
        // Check correct answers
        const selectedCheckboxes = document.querySelectorAll('.correct-checkbox:checked');
        const selectedCount = selectedCheckboxes.length;
        
        if (selectedCount !== 2) {
            showError('multipleCorrectContainer', 'multipleCorrectError', 'Select exactly 2 correct answers');
            isValid = false;
        } else {
            // Validate that selected answers match actual options
            const selectedValues = Array.from(selectedCheckboxes).map(cb => cb.value.trim());
            const allOptions = [opt1, opt2, 
                               document.getElementById("opt3").value.trim(),
                               document.getElementById("opt4").value.trim()].filter(opt => opt !== "");
            
            for (const selectedValue of selectedValues) {
                if (!allOptions.includes(selectedValue)) {
                    showModal('Invalid Selection', 'Selected correct answer does not match any of the provided options.');
                    isValid = false;
                    break;
                }
            }
            
            updateMultipleCorrectAnswer();
        }
        
    } else { // MCQ or Code
        // Check required options
        const opt1 = document.getElementById("opt1").value.trim();
        const opt2 = document.getElementById("opt2").value.trim();
        
        if (!opt1) {
            showError('opt1', 'opt1Error', 'First option is required');
            isValid = false;
        }
        if (!opt2) {
            showError('opt2', 'opt2Error', 'Second option is required');
            isValid = false;
        }
        
        // Check for duplicate options
        const options = [opt1, opt2];
        if (document.getElementById("opt3").value.trim()) options.push(document.getElementById("opt3").value.trim());
        if (document.getElementById("opt4").value.trim()) options.push(document.getElementById("opt4").value.trim());
        
        const uniqueOptions = [...new Set(options)];
        if (uniqueOptions.length !== options.length) {
            showModal('Duplicate Options', 'Options must be unique. Please provide different values for each option.');
            isValid = false;
        }
        
        // Check correct answer
        const correctAnswer = document.getElementById("correctAnswer").value.trim();
        if (!correctAnswer) {
            showError('correctAnswer', 'correctAnswerError', 'Correct answer is required');
            isValid = false;
        } else {
            // Check if correct answer matches one of the options
            const allOptions = [opt1, opt2, 
                               document.getElementById("opt3").value.trim(),
                               document.getElementById("opt4").value.trim()].filter(opt => opt !== "");
            
            if (!allOptions.includes(correctAnswer)) {
                showModal('Invalid Correct Answer', 'Correct answer must match one of the provided options.');
                isValid = false;
            }
        }
    }
    
    return isValid;
}

function showError(elementId, errorId, message) {
    const element = document.getElementById(elementId);
    if (element) {
        element.classList.add('input-error');
        element.parentElement.classList.add('has-error');
    }
    
    if (errorId) {
        const errorElement = document.getElementById(errorId);
        if (errorElement) {
            errorElement.textContent = message;
            errorElement.style.display = 'block';
        }
    }
}

function clearErrors() {
    // Remove error classes
    document.querySelectorAll('.input-error').forEach(el => {
        el.classList.remove('input-error');
        el.parentElement.classList.remove('has-error');
    });
    
    // Hide error messages
    document.querySelectorAll('.error-message').forEach(el => {
        el.style.display = 'none';
    });
}

function validateAndSubmit() {
    if (validateQuestionForm()) {
        // Show loading state
        const submitBtn = document.getElementById('submitBtn');
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding Question...';
        submitBtn.disabled = true;
        
        // Submit the form
        document.getElementById('questionForm').submit();
    } else {
        // Focus on first error
        const firstError = document.querySelector('.input-error');
        if (firstError) firstError.focus();
    }
}

function toggleOptions() {
    const questionType = document.getElementById("questionType").value;
    const mcqOptions = document.getElementById("mcqOptions");
    const correctAnswerContainer = document.getElementById("correctAnswerContainer");
    const multipleCorrectContainer = document.getElementById("multipleCorrectContainer");
    const correctAnswer = document.getElementById("correctAnswer");
    const correctAnswerHint = document.getElementById("correctAnswerHint");
    const multipleCorrectHint = document.getElementById("multipleCorrectHint");

    // Clear errors when changing type
    clearErrors();

    if (questionType === "TrueFalse") {
        mcqOptions.style.display = "none";
        correctAnswerContainer.style.display = "block";
        multipleCorrectContainer.style.display = "none";
        correctAnswer.value = "";
        correctAnswer.placeholder = "Enter 'True' or 'False'";
        correctAnswerHint.textContent = "Enter 'True' or 'False'";
        correctAnswer.required = true;

        ['opt1','opt2','opt3','opt4'].forEach(id => {
            const opt = document.getElementById(id);
            opt.value = '';
            opt.required = false;
        });

    } else if (questionType === "MultipleSelect") {
        mcqOptions.style.display = "block";
        correctAnswerContainer.style.display = "none";
        multipleCorrectContainer.style.display = "block";
        multipleCorrectHint.textContent = "Select exactly 2 correct answers";
        correctAnswer.required = false;

        ['opt1','opt2'].forEach(id => document.getElementById(id).required = true);
        ['opt3','opt4'].forEach(id => document.getElementById(id).required = false);

        updateCorrectOptionLabels();

    } else if (questionType === "Code") {
        mcqOptions.style.display = "block";
        correctAnswerContainer.style.display = "block";
        multipleCorrectContainer.style.display = "none";
        correctAnswer.placeholder = "Expected output or answer";
        correctAnswerHint.textContent = "Enter the expected output or correct answer for the code snippet";
        correctAnswer.required = true;

        ['opt1','opt2'].forEach(id => document.getElementById(id).required = true);
        ['opt3','opt4'].forEach(id => document.getElementById(id).required = false);

        document.getElementById('opt1').placeholder = "Option 1 (output interpretation)";
        document.getElementById('opt2').placeholder = "Option 2 (output interpretation)";
        document.getElementById('opt3').placeholder = "Option 3 (output interpretation)";
        document.getElementById('opt4').placeholder = "Option 4 (output interpretation)";

    } else {
        // Default Multiple Choice
        mcqOptions.style.display = "block";
        correctAnswerContainer.style.display = "block";
        multipleCorrectContainer.style.display = "none";
        correctAnswer.placeholder = "Correct Answer";
        correctAnswerHint.textContent = "Enter the correct answer (must match one of the options exactly)";
        correctAnswer.required = true;

        ['opt1','opt2'].forEach(id => document.getElementById(id).required = true);
        ['opt3','opt4'].forEach(id => document.getElementById(id).required = false);

        document.getElementById('opt1').placeholder = "First Option";
        document.getElementById('opt2').placeholder = "Second Option";
        document.getElementById('opt3').placeholder = "Third Option";
        document.getElementById('opt4').placeholder = "Fourth Option";
    }

    updateSubmitButton();
}

function updateCorrectOptionLabels() {
    ['opt1','opt2','opt3','opt4'].forEach((id,i)=>{
        const val = document.getElementById(id).value || `Option ${i+1}`;
        const label = document.querySelector(`label[for="correctOpt${i+1}"]`);
        const checkbox = document.getElementById(`correctOpt${i+1}`);
        if (label) label.textContent = val;
        if (checkbox) checkbox.value = val;
    });
}

function updateMultipleCorrectAnswer() {
    const selectedOptions = Array.from(document.querySelectorAll('.correct-checkbox:checked'))
        .map(cb => cb.value.trim())
        .filter(v => v !== '');
    document.getElementById('multipleCorrectAnswer').value = selectedOptions.join('|');
}

function updateSubmitButton() {
    const form = document.getElementById('questionForm');
    const submitBtn = document.getElementById('submitBtn');
    let isValid = form.checkValidity();

    if (document.getElementById("questionType").value === "MultipleSelect") {
        const selectedCount = document.querySelectorAll('.correct-checkbox:checked').length;
        if (selectedCount !== 2) isValid = false;
    }

    submitBtn.disabled = !isValid;
}

function resetQuestionForm() {
    document.getElementById('questionForm').reset();
    ['opt1','opt2','opt3','opt4'].forEach((id,i)=>{
        document.getElementById(id).placeholder = ["First Option","Second Option","Third Option","Fourth Option"][i];
    });
    clearErrors();
    toggleOptions();
}

function syncCourseDropdowns() {
    const addNew = document.getElementById('courseSelectAddNew');
    const showAll = document.getElementById('courseSelectShowAll');
    addNew.addEventListener('change', ()=> showAll.value = addNew.value);
    showAll.addEventListener('change', ()=> addNew.value = showAll.value);
}

// Scroll Indicator
function scrollToShowQuestions(){document.getElementById("showQuestionsPanel").scrollIntoView({behavior:"smooth"});}
function scrollToAddQuestion(){document.getElementById("addQuestionPanel").scrollIntoView({behavior:"smooth"});}
function updateScrollIndicator(){
    const indicator = document.getElementById("scrollIndicator");
    const add = document.getElementById("addQuestionPanel");
    const show = document.getElementById("showQuestionsPanel");
    if(!indicator || !add || !show) return;
    const addTop = Math.abs(add.getBoundingClientRect().top);
    const showTop = Math.abs(show.getBoundingClientRect().top);
    if(addTop < showTop){indicator.innerHTML='<i class="fas fa-arrow-down"></i>'; indicator.onclick = scrollToShowQuestions;}
    else{indicator.innerHTML='<i class="fas fa-arrow-up"></i>'; indicator.onclick = scrollToAddQuestion;}
}

// Initialize on page load
document.addEventListener("DOMContentLoaded",()=>{
    toggleOptions();
    
    // Add input listeners for real-time validation
    ['opt1','opt2','opt3','opt4'].forEach(id=>{
        const el=document.getElementById(id);
        el?.addEventListener('input',()=>{
            updateCorrectOptionLabels();
            updateSubmitButton();
            clearErrors();
        });
    });
    
    document.querySelectorAll('.correct-checkbox').forEach(cb=>{
        cb.addEventListener('change', function(){
            const selectedCount = document.querySelectorAll('.correct-checkbox:checked').length;
            if(selectedCount > 2){
                this.checked=false;
                showModal('Too Many Selections', 'Select only 2 correct answers.');
            }
            updateMultipleCorrectAnswer();
            updateSubmitButton();
            clearErrors();
        });
    });
    
    document.getElementById('correctAnswer')?.addEventListener('input', () => {
        updateSubmitButton();
        clearErrors();
    });
    
    document.getElementById('courseSelectAddNew')?.addEventListener('change', updateSubmitButton);
    document.getElementById('questionText')?.addEventListener('input', updateSubmitButton);
    
    // Close modal when clicking outside
    window.onclick = function(event) {
        const modal = document.getElementById('validationModal');
        if (event.target == modal) {
            closeModal();
        }
    };
    
    // Initialize other functions
    syncCourseDropdowns();
    updateSubmitButton();
    updateScrollIndicator();
    window.addEventListener("scroll", updateScrollIndicator);
    window.addEventListener("resize", updateScrollIndicator);
    
    // Check for session messages
    if(sessionStorage.getItem('justAddedQuestion')==='true'){
        window.scrollTo({top:0,behavior:'smooth'});
        sessionStorage.removeItem('justAddedQuestion');
    }
});
</script>