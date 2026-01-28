<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>
<%@ page isELIgnored="true" %>

<%
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

// Get course names for dropdown
ArrayList<String> courseNames = pDAO.getAllCourseNames();
if (courseNames == null) {
    courseNames = new ArrayList<>();
}

// Get total questions count
int totalQuestions = 0;
try {
    totalQuestions = pDAO.getTotalQuestionsCount();
} catch (Exception e) {
    totalQuestions = 0; // Default to 0 if there's an error
}

// Get the last selected course name and question type from session
String lastCourseName = (String) session.getAttribute("last_course_name");
String lastQuestionType = (String) session.getAttribute("last_question_type");

// If not in session, try to get from request parameter
if (lastCourseName == null || lastCourseName.trim().isEmpty()) {
    lastCourseName = request.getParameter("coursename");
}

// If still not available, use the first course if available
if (lastCourseName == null || lastCourseName.trim().isEmpty()) {
    if (!courseNames.isEmpty()) {
        lastCourseName = courseNames.get(0);
    }
}

// Set default question type if not in session
if (lastQuestionType == null || lastQuestionType.trim().isEmpty()) {
    lastQuestionType = "MCQ"; // Default to Multiple Choice
}
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
        height: 100vh;
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
    
    /* REMOVED sticky-add-form class - All panels will scroll normally */
    .question-card {
        position: static;
        background: var(--white);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-md);
        margin-bottom: var(--spacing-lg);
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
    bottom:30px;  /* Positioned above the scroll to top button */
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

/* Scroll to Top Button */
.scroll-to-top {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 999;
    display: none;
    background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
    color: white;
    border: none;
    border-radius: 50%;
    width: 50px;
    height: 50px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
    cursor: pointer;
    transition: all 0.3s ease;
}

.scroll-to-top:hover {
    transform: scale(1.1);
    box-shadow: 0 6px 15px rgba(0, 0, 0, 0.3);
}

.scroll-to-top.show {
    display: flex;
    align-items: center;
    justify-content: center;
}

.scroll-to-top i {
    font-size: 20px;
}

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

/* Progress Bar Styles */
.progress {
    height: 20px;
    background-color: var(--medium-gray);
    border-radius: var(--radius-sm);
    overflow: hidden;
    margin: 10px 0;
}

.progress-bar {
    height: 100%;
    background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
    transition: width 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--white);
    font-size: 12px;
    font-weight: 500;
}

/* Drag and Drop Styles */
.drop-zone {
    border: 2px dashed var(--medium-gray);
    border-radius: var(--radius-md);
    padding: 30px;
    text-align: center;
    background-color: var(--light-gray);
    transition: all var(--transition-normal);
    cursor: pointer;
    position: relative;
}

.drop-zone:hover {
    border-color: var(--accent-blue);
    background-color: rgba(74, 144, 226, 0.05);
}

.drop-zone.drag-over {
    border-color: var(--accent-blue);
    background-color: rgba(74, 144, 226, 0.1);
    transform: scale(1.02);
}

.drop-zone-content {
    pointer-events: none;
}

.drop-icon {
    font-size: 48px;
    color: var(--dark-gray);
    margin-bottom: 15px;
    display: block;
}

.drop-text {
    font-size: 16px;
    color: var(--text-dark);
    margin: 0 0 5px 0;
    font-weight: 500;
}

.drop-hint {
    font-size: 13px;
    color: var(--dark-gray);
    margin: 0;
}

.file-name-display {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px;
    background-color: #d4edda;
    border: 1px solid #c3e6cb;
    border-radius: var(--radius-sm);
    margin-top: 10px;
}

.file-name-display i {
    color: var(--success);
}

.remove-file-btn {
    background: none;
    border: none;
    color: #dc3545;
    font-size: 20px;
    cursor: pointer;
    padding: 0;
    margin-left: auto;
    line-height: 1;
}

.remove-file-btn:hover {
    color: #a71d2a;
}

</style>

<!-- Dashboard Layout -->
<div class="dashboard-container">
    <!-- Sidebar -->
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
    <div class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <div class="page-title">
                <i class="fas fa-question-circle"></i>
                Questions Management
            </div>
            <div class="stats-badge">
                <i class="fas fa-layer-group"></i>
                <%= totalQuestions %> Total Questions
            </div>
        </div>
        
        <!-- Upload PDF to Generate Questions Panel -->
<!--        <div class="question-card" id="uploadPdfPanel">
            <div class="card-header">
                <span><i class="fas fa-file-pdf"></i> Upload Exam Paper (PDF)</span>
                <i class="fas fa-upload" style="opacity: 0.8;"></i>
            </div>
            <div class="question-form">
                <form id="pdfUploadForm" enctype="multipart/form-data">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book" style="color: var(--accent-blue);"></i>
                                Select Course
                            </label>
                            <select name="coursename" class="form-select" id="courseSelectPdf" required>
                                <% 
                                if (courseNames.isEmpty()) {
                                %>
                                    <option value="">No courses available</option>
                                <%
                                } else {
                                %>
                                    <option value="">Select Course</option>
                                <%
                                    for (String course : courseNames) {
                                        boolean isSelected = (lastCourseName != null && lastCourseName.equals(course));
                                %>
                                <option value="<%=course%>" <%=isSelected ? "selected" : ""%>><%=course%></option>
                                <% 
                                    }
                                } 
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-list" style="color: var(--info);"></i>
                                Question Type
                            </label>
                            <select id="questionTypeSelectPdf" class="form-select">
                                <option value="MCQ">Multiple Choice</option>
                                <option value="TrueFalse">True/False</option>
                                <option value="MultipleSelect">Multiple Select (2 correct)</option>
                                <option value="Code">Code Snippet</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-file-upload" style="color: var(--primary-blue);"></i>
                            Upload PDF File
                        </label>
                        <div class="drop-zone" id="dropZone">
                            <div class="drop-zone-content">
                                <i class="fas fa-cloud-upload-alt drop-icon"></i>
                                <p class="drop-text">Drag & drop your PDF here or click to browse</p>
                                <p class="drop-hint">Supports PDF (Max 5MB)</p>
                                <input type="file" name="pdfFile" class="form-control" id="pdfFile" accept=".pdf" style="display: none;">
                            </div>
                        </div>
                        <div id="fileNameDisplay" class="file-name-display" style="display: none; margin-top: 10px;">
                            <i class="fas fa-file-pdf"></i>
                            <span id="fileName"></span>
                            <button type="button" class="remove-file-btn" onclick="removeFile()">×</button>
                        </div>
                        <small class="form-hint">Upload a PDF file to extract questions automatically</small>
                    </div>
                    
                     Progress and Status Elements for PDF Upload 
                    <div id="uploadProgress" class="progress" style="display: none; margin: 15px 0;">
                        <div class="progress-bar" style="width: 0%;">0%</div>
                    </div>
                    <div id="uploadStatus" style="display: none;"></div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn btn-outline" onclick="resetPdfForm()">
                            <i class="fas fa-redo"></i>
                            Reset
                        </button>
                        <button type="button" class="btn btn-primary" id="uploadPdfBtn">
                            <i class="fas fa-bolt"></i>
                            Generate Questions
                        </button>
                    </div>
                </form>
            </div>
        </div>-->
        
        <!-- Add Question Panel -->
        <div class="question-card" id="addQuestionPanel">
            <div class="card-header">
                <span><i class="fas fa-plus-circle"></i> Add New Question</span>
                <i class="fas fa-question" style="opacity: 0.8;"></i>
            </div>
            <div class="question-form">
                <form id="addQuestionForm" method="post" action="controller.jsp?page=questions&operation=addnew" enctype="multipart/form-data">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book" style="color: var(--accent-blue);"></i>
                                Select Course
                            </label>
                            <select name="coursename" class="form-select" id="courseSelectAddNew" required onchange="saveLastSelection()">
                                <% 
                                if (courseNames.isEmpty()) {
                                %>
                                    <option value="">No courses available</option>
                                <%
                                } else {
                                %>
                                    <option value="">Select Course</option>
                                <%
                                    for (String course : courseNames) {
                                        boolean isSelected = (lastCourseName != null && lastCourseName.equals(course));
                                %>
                                <option value="<%=course%>" <%=isSelected ? "selected" : ""%>><%=course%></option>
                                <% 
                                    }
                                } 
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-list" style="color: var(--info);"></i>
                                Question Type
                            </label>
                            <select id="questionTypeSelect" class="form-select" onchange="toggleOptions(); saveLastSelection()">
                                <option value="MCQ" <%="MCQ".equals(lastQuestionType) ? "selected" : ""%>>Multiple Choice</option>
                                <option value="TrueFalse" <%="TrueFalse".equals(lastQuestionType) ? "selected" : ""%>>True/False</option>
                                <option value="MultipleSelect" <%="MultipleSelect".equals(lastQuestionType) ? "selected" : ""%>>Multiple Select (2 correct)</option>
                                <option value="Code" <%="Code".equals(lastQuestionType) ? "selected" : ""%>>Code Snippet</option>
                            </select>
                            <input type="hidden" id="questionTypeHidden" name="questionType" value="<%=lastQuestionType%>">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-question-circle" style="color: var(--primary-blue);"></i> Your Question</label>
                        <textarea name="question" id="questionTextarea" class="question-input" rows="3" oninput="checkForCodeSnippet()"></textarea>
                        <small class="form-hint">Enter your question text (optional if uploading an image)</small>
                    </div>
                    
                    <!-- Image Upload Section -->
                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-image" style="color: var(--info);"></i> Upload Question Image (Optional)</label>
                        <div class="drop-zone" id="imageDropZone">
                            <div class="drop-zone-content">
                                <i class="fas fa-cloud-upload-alt drop-icon"></i>
                                <p class="drop-text">Drag & drop your image here or click to browse</p>
                                <p class="drop-hint">Supports JPG, PNG, GIF, WebP (Max 3MB)</p>
                                <input type="file" name="imageFile" class="form-control" id="imageFile" accept=".jpg,.jpeg,.png,.gif,.webp" style="display: none;">
                            </div>
                        </div>
                        <div id="imageFileNameDisplay" class="file-name-display" style="display: none; margin-top: 10px;">
                            <i class="fas fa-image"></i>
                            <span id="imageFileName"></span>
                            <button type="button" class="remove-file-btn" onclick="removeImageFile()">×</button>
                        </div>
                        <small class="form-hint">Upload an image to accompany your question (optional)</small>
                    </div>
                    
                    <!-- Image Preview Section -->
                    <div id="imagePreviewSection" class="form-group" style="display: none;">
                        <label class="form-label"><i class="fas fa-eye" style="color: var(--success);"></i> Image Preview</label>
                        <div style="text-align: center; padding: 10px; border: 1px solid var(--medium-gray); border-radius: var(--radius-sm);">
                            <img id="imagePreview" src="#" alt="Image Preview" style="max-width: 100%; max-height: 200px; display: none; border-radius: var(--radius-sm);">
                            <p id="previewPlaceholder" style="color: var(--dark-gray); margin: 0;">Uploaded image will appear here</p>
                        </div>
                    </div>
                    
                    <div id="mcqOptions">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-list-ol" style="color: var(--dark-gray);"></i>
                                Options
                            </label>
                            <div class="options-grid">
                                <div class="option-container">
                                    <textarea name="opt1" class="option-input" placeholder="First Option" id="opt1" required rows="2"></textarea>
                                    <div class="error-message" id="opt1Error">First option is required</div>
                                </div>
                                <div class="option-container">
                                    <textarea name="opt2" class="option-input" placeholder="Second Option" id="opt2" required rows="2"></textarea>
                                    <div class="error-message" id="opt2Error">Second option is required</div>
                                </div>
                                <div class="option-container">
                                    <textarea name="opt3" class="option-input" placeholder="Third Option" id="opt3" rows="2"></textarea>
                                    <div class="error-message" id="opt3Error">Third option is required</div>
                                </div>
                                <div class="option-container">
                                    <textarea name="opt4" class="option-input" placeholder="Fourth Option" id="opt4" rows="2"></textarea>
                                    <div class="error-message" id="opt4Error">Fourth option is required</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-check-circle" style="color: var(--success);"></i> Correct Answer</label>
                        
                        <!-- True/False Dropdown -->
                        <div id="trueFalseContainer" style="display:none;">
                            <select id="trueFalseSelect" name="correct" class="form-select" required>
                                <option value="">Select Correct Answer</option>
                                <option value="True">True</option>
                                <option value="False">False</option>
                            </select>
                            <small class="form-hint">Select whether the statement is True or False</small>
                        </div>
                        
                        <!-- Regular Correct Answer Textarea -->
                        <div id="correctAnswerContainer">
                            <textarea id="correctAnswer" name="correct" class="form-control" required rows="2" placeholder="Enter the correct answer"></textarea>
                            <small class="form-hint">Must match one of the options exactly</small>
                        </div>
                        
                        <div id="multipleCorrectContainer" style="display:none;">
                            <div class="options-grid">
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt1" class="form-check-input correct-checkbox">
                                    <label for="correctOpt1" class="form-check-label">Option 1</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt2" class="form-check-input correct-checkbox">
                                    <label for="correctOpt2" class="form-check-label">Option 2</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt3" class="form-check-input correct-checkbox">
                                    <label for="correctOpt3" class="form-check-label">Option 3</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt4" class="form-check-input correct-checkbox">
                                    <label for="correctOpt4" class="form-check-label">Option 4</label>
                                </div>
                            </div>
                            <small class="form-hint">Select exactly 2 correct answers</small>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="reset" class="btn btn-outline" onclick="resetForm()">
                            <i class="fas fa-redo"></i>
                            Reset
                        </button>
                        <button type="submit" class="btn btn-success" id="submitBtn">
                            <i class="fas fa-plus"></i>
                            Add Question
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- View Questions Section - Updated with Show All Questions Button -->
        <div class="question-card" id="viewQuestionsCard">
            <div class="card-header">
                <span><i class="fas fa-eye"></i> View Questions</span>
                <i class="fas fa-search" style="opacity: 0.8;"></i>
            </div>
            <div class="question-form">
                <form action="" method="get" id="viewQuestionsForm">
                    <input type="hidden" name="pgprt" value="4">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-filter" style="color: var(--warning);"></i>
                                Filter by Course
                            </label>
                            <select name="coursename" class="form-select" id="courseSelectView" onchange="updateShowAllButton()">
                                <option value="">All Courses</option>
                                <% 
                                if (courseNames != null) {
                                    for (String course : courseNames) {
                                        boolean isSelected = (lastCourseName != null && lastCourseName.equals(course));
                                %>
                                <option value="<%=course%>" <%=isSelected ? "selected" : ""%>><%=course%></option>
                                <% 
                                    }
                                } 
                                %>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn btn-success" id="showAllQuestionsBtn" onclick="showAllQuestions()" <%=courseNames.isEmpty() ? "disabled" : ""%>>
                            <i class="fas fa-eye"></i>
                            Show All Questions
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Scroll to Top Button -->
<button class="scroll-to-top" id="scrollToTopBtn" title="Scroll to top">
    <i class="fas fa-arrow-up"></i>
</button>

<script>
// Function to update the Show All Questions button state
function updateShowAllButton() {
    const courseSelect = document.getElementById('courseSelectView');
    const showAllBtn = document.getElementById('showAllQuestionsBtn');
    
    if (courseSelect.value) {
        showAllBtn.disabled = false;
        showAllBtn.innerHTML = '<i class="fas fa-eye"></i> Show Questions in ' + courseSelect.value;
    } else {
        showAllBtn.disabled = true;
        showAllBtn.innerHTML = '<i class="fas fa-eye"></i> Select a Course First';
    }
}

// Function to show all questions for selected course
function showAllQuestions() {
    const courseSelect = document.getElementById('courseSelectView');
    const courseName = courseSelect.value;
    
    if (!courseName) {
        showToast('error', 'Validation Error', 'Please select a course first.');
        return;
    }
    
    // Navigate to the showall.jsp page with the selected course
    window.location.href = 'showall.jsp?coursename=' + encodeURIComponent(courseName);
}

// Function to save last selections to session
function saveLastSelection() {
    const courseSelect = document.getElementById('courseSelectAddNew');
    const questionTypeSelect = document.getElementById('questionTypeSelect');
    
    if (courseSelect && courseSelect.value) {
        // Save to session via AJAX
        fetch('controller.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'page=questions&operation=save_selection&last_course_name=' + encodeURIComponent(courseSelect.value) + '&last_question_type=' + encodeURIComponent(questionTypeSelect.value)
        }).catch(error => {
            console.log('Session saved for course:', courseSelect.value, 'and question type:', questionTypeSelect.value);
        });
    }
}

// Function to sync all course dropdowns
function syncCourseDropdowns() {
    const pdfCourseSelect = document.getElementById('courseSelectPdf');
    const addQuestionCourseSelect = document.getElementById('courseSelectAddNew');
    const viewCourseSelect = document.getElementById('courseSelectView');
    
    // Function to sync all dropdowns
    function syncAllDropdowns(changedSelect) {
        const value = changedSelect.value;
        
        if (pdfCourseSelect && pdfCourseSelect !== changedSelect) {
            pdfCourseSelect.value = value;
        }
        if (addQuestionCourseSelect && addQuestionCourseSelect !== changedSelect) {
            addQuestionCourseSelect.value = value;
            saveLastSelection(); // Save when course changes
        }
        if (viewCourseSelect && viewCourseSelect !== changedSelect) {
            viewCourseSelect.value = value;
            updateShowAllButton();
        }
    }
    
    // Add event listeners to all dropdowns
    if (pdfCourseSelect) {
        pdfCourseSelect.addEventListener('change', function() {
            syncAllDropdowns(this);
        });
    }
    
    if (addQuestionCourseSelect) {
        addQuestionCourseSelect.addEventListener('change', function() {
            syncAllDropdowns(this);
        });
    }
    
    if (viewCourseSelect) {
        viewCourseSelect.addEventListener('change', function() {
            syncAllDropdowns(this);
            updateShowAllButton();
        });
    }
    
    // Initialize button state
    updateShowAllButton();
}

// PDF Upload Functions
function uploadAndGenerateQuestions() {
    const form = document.getElementById('pdfUploadForm');
    const fileInput = document.getElementById('pdfFile');
    const courseSelect = document.getElementById('courseSelectPdf');
    const uploadBtn = document.getElementById('uploadPdfBtn');
    const progressDiv = document.getElementById('uploadProgress');
    const progressBar = progressDiv.querySelector('.progress-bar');
    const statusDiv = document.getElementById('uploadStatus');
    
    // Validate inputs
    if (!fileInput.files[0]) {
        showToast('error', 'Validation Error', 'Please select a PDF file to upload.');
        return;
    }
    
    if (!courseSelect.value) {
        showToast('error', 'Validation Error', 'Please select a course.');
        return;
    }
    
    // Check file size (5MB = 5242880 bytes)
    if (fileInput.files[0].size > 5242880) {
        showToast('error', 'File Too Large', 'File size exceeds 5MB limit. Please select a smaller file.');
        return;
    }
    
    // Check file type
    if (fileInput.files[0].type !== 'application/pdf' && !fileInput.files[0].name.toLowerCase().endsWith('.pdf')) {
        showToast('error', 'Invalid File Type', 'Only PDF files are allowed.');
        return;
    }
    
    // Prepare form data
    const formData = new FormData(form);
    
    // Show progress bar
    progressDiv.style.display = 'block';
    statusDiv.style.display = 'block';
    statusDiv.innerHTML = '<div class="alert"><i class="fas fa-spinner fa-spin"></i> Processing PDF and extracting questions...</div>';
    
    // Disable button during upload
    uploadBtn.disabled = true;
    uploadBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
    
    // Send request
    fetch('controller.jsp?action=pdf_upload&page=questions', {
        method: 'POST',
        body: formData
    })
    .then(async response => {
        // Check if response is OK before parsing JSON
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        // Try to parse JSON response
        let data;
        try {
            data = await response.json();
        } catch (parseError) {
            console.error('JSON Parse Error:', parseError);
            console.error('Response text:', await response.text());
            throw new Error('Invalid JSON response from server');
        }
        
        if (data.success) {
            // Update progress to 100%
            progressBar.style.width = '100%';
            progressBar.textContent = '100%';
            
            statusDiv.innerHTML = `<div class="alert" style="background: #d4edda; color: #155724;"><i class="fas fa-check-circle"></i> Successfully extracted ${data.count} questions. Adding to database...</div>`;
            
            // Add questions to database
            addExtractedQuestionsToDB(data.questions, courseSelect.value);
        } else {
            // Check if this is the library not installed message
            if (data.message && data.message.includes('libraries not installed')) {
                statusDiv.innerHTML = `<div class="alert" style="background: #fff3cd; color: #856404;"><i class="fas fa-exclamation-triangle"></i> PDF processing is not available. Required libraries need to be installed on the server.</div>`;
                progressBar.style.backgroundColor = '#ffc107';
                showToast('warning', 'Libraries Required', 'PDF processing requires additional libraries to be installed on the server.');
            } else {
                throw new Error(data.message || 'Unknown error occurred');
            }
        }
    })
    .catch(error => {
        console.error('Error:', error);
        statusDiv.innerHTML = `<div class="alert" style="background: #f8d7da; color: #721c24;"><i class="fas fa-exclamation-triangle"></i> Error: ${error.message || error}</div>`;
        progressBar.style.backgroundColor = '#dc3545';
    })
    .finally(() => {
        // Re-enable button
        uploadBtn.disabled = false;
        uploadBtn.innerHTML = '<i class="fas fa-bolt"></i> Generate Questions';
    });
}

function addExtractedQuestionsToDB(questions, courseName) {
    let addedCount = 0;
    let errorCount = 0;
    
    const statusDiv = document.getElementById('uploadStatus');
    
    // Process each question
    questions.forEach((question, index) => {
        // Prepare form data for adding question
        const formData = new FormData();
        formData.append('page', 'questions');
        formData.append('operation', 'addnew');
        formData.append('coursename', courseName);
        formData.append('questionType', question.type);
        formData.append('question', question.question);
        
        // Add options
        for (let i = 0; i < question.options.length && i < 4; i++) {
            formData.append(`opt${i+1}`, question.options[i]);
        }
        
        // Add correct answer
        formData.append('correct', question.correct);
        
        // Send request to add question
        fetch('controller.jsp', {
            method: 'POST',
            body: formData
        })
        .then(response => response.text())
        .then(result => {
            addedCount++;
            
            // Update status
            statusDiv.innerHTML = `<div class="alert" style="background: #d4edda; color: #155724;"><i class="fas fa-check-circle"></i> Added ${addedCount} of ${questions.length} questions to ${courseName}</div>`;
            
            // When all questions are added
            if (addedCount + errorCount === questions.length) {
                finishPDFUploadProcess(addedCount, errorCount, courseName);
            }
        })
        .catch(error => {
            console.error('Error adding question:', error);
            errorCount++;
            
            // Continue processing other questions
            if (addedCount + errorCount === questions.length) {
                finishPDFUploadProcess(addedCount, errorCount, courseName);
            }
        });
    });
    
    // Handle case where no questions were processed
    if (questions.length === 0) {
        finishPDFUploadProcess(0, 0, courseName);
    }
}

function finishPDFUploadProcess(successCount, errorCount, courseName) {
    const statusDiv = document.getElementById('uploadStatus');
    const progressDiv = document.getElementById('uploadProgress');
    
    if (successCount > 0) {
        statusDiv.innerHTML = `<div class="alert" style="background: #d4edda; color: #155724;"><i class="fas fa-check-circle"></i> Successfully added ${successCount} questions to ${courseName}. ${errorCount > 0 ? errorCount + ' failed.' : ''}</div>`;
        
        // Show success toast
        showToast('success', 'Success', `Added ${successCount} questions to ${courseName}`);
    } else {
        statusDiv.innerHTML = `<div class="alert" style="background: #f8d7da; color: #721c24;"><i class="fas fa-exclamation-triangle"></i> No questions were added. ${errorCount > 0 ? errorCount + ' errors occurred.' : ''}</div>`;
        
        // Show error toast
        showToast('error', 'Processing Error', 'No questions were added to the database');
    }
    
    // Hide progress bar after delay
    setTimeout(() => {
        progressDiv.style.display = 'none';
    }, 3000);
}

function resetPdfForm() {
    document.getElementById('pdfUploadForm').reset();
    document.getElementById('uploadProgress').style.display = 'none';
    document.getElementById('uploadStatus').style.display = 'none';
    
    // Reset drag and drop UI
    const pdfFileInput = document.getElementById('pdfFile');
    const fileNameDisplay = document.getElementById('fileNameDisplay');
    const dropZone = document.getElementById('dropZone');
    
    if (pdfFileInput) pdfFileInput.value = '';
    if (fileNameDisplay) fileNameDisplay.style.display = 'none';
    if (dropZone) dropZone.style.display = 'block';
}

// Toast notification function
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
            break;
        case 'error':
            toastIcon.className = 'fas fa-times-circle';
            break;
        case 'warning':
            toastIcon.className = 'fas fa-exclamation-triangle';
            break;
        case 'info':
            toastIcon.className = 'fas fa-info-circle';
            break;
    }
    
    toast.style.display = 'block';
    setTimeout(hideToast, 5000);
}

function hideToast() {
    document.getElementById('toast').style.display = 'none';
}

// Modal functions
function showModal(title, message) {
    document.getElementById('modalTitle').innerHTML = '<i class="fas fa-exclamation-triangle"></i> ' + title;
    document.getElementById('modalMessage').textContent = message;
    document.getElementById('validationModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('validationModal').style.display = 'none';
}

// Drag and drop functionality for PDF upload
const pdfFileInput = document.getElementById('pdfFile');
const dropZone = document.getElementById('dropZone');

if (pdfFileInput && dropZone) {
    // Click to browse
    dropZone.addEventListener('click', () => {
        pdfFileInput.click();
    });
    
    // File input change
    pdfFileInput.addEventListener('change', function() {
        if (this.files && this.files[0]) {
            displayFileName(this.files[0]);
        }
    });
    
    // Drag and drop events
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
    });
    
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, unhighlight, false);
    });
    
    function highlight() {
        dropZone.classList.add('drag-over');
    }
    
    function unhighlight() {
        dropZone.classList.remove('drag-over');
    }
    
    dropZone.addEventListener('drop', handleDrop, false);
    
    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        
        if (files.length > 0) {
            const file = files[0];
            // Check if it's a PDF file
            if (file.type === 'application/pdf' || file.name.toLowerCase().endsWith('.pdf')) {
                // Set the file to the hidden input
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(file);
                pdfFileInput.files = dataTransfer.files;
                displayFileName(file);
            } else {
                showToast('error', 'Invalid File Type', 'Only PDF files are allowed.');
            }
        }
    }
    
    function displayFileName(file) {
        const fileNameDisplay = document.getElementById('fileNameDisplay');
        const fileNameSpan = document.getElementById('fileName');
        
        fileNameSpan.textContent = file.name;
        fileNameDisplay.style.display = 'flex';
        dropZone.style.display = 'none';
    }
}

function removeFile() {
    const pdfFileInput = document.getElementById('pdfFile');
    const fileNameDisplay = document.getElementById('fileNameDisplay');
    const dropZone = document.getElementById('dropZone');
    
    // Reset file input
    pdfFileInput.value = '';
    
    // Hide file name display and show drop zone
    fileNameDisplay.style.display = 'none';
    dropZone.style.display = 'block';
}

function removeImageFile() {
    const imageFileInput = document.getElementById('imageFile');
    const imageFileNameDisplay = document.getElementById('imageFileNameDisplay');
    const imageDropZone = document.getElementById('imageDropZone');
    const imagePreviewSection = document.getElementById('imagePreviewSection');
    const imagePreview = document.getElementById('imagePreview');
    const previewPlaceholder = document.getElementById('previewPlaceholder');
    
    // Reset file input
    imageFileInput.value = '';
    
    // Hide file name display and show drop zone
    imageFileNameDisplay.style.display = 'none';
    imageDropZone.style.display = 'block';
    
    // Hide preview section
    imagePreviewSection.style.display = 'none';
    imagePreview.style.display = 'none';
    previewPlaceholder.style.display = 'block';
}

// Drag and drop functionality for image upload
const imageFileInput = document.getElementById('imageFile');
const imageDropZone = document.getElementById('imageDropZone');
const imagePreview = document.getElementById('imagePreview');
const imagePreviewSection = document.getElementById('imagePreviewSection');
const previewPlaceholder = document.getElementById('previewPlaceholder');

if (imageFileInput && imageDropZone) {
    // Click to browse
    imageDropZone.addEventListener('click', () => {
        imageFileInput.click();
    });
    
    // File input change
    imageFileInput.addEventListener('change', function() {
        if (this.files && this.files[0]) {
            displayImageFileName(this.files[0]);
            previewImage(this.files[0]);
        }
    });
    
    // Drag and drop events
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        imageDropZone.addEventListener(eventName, preventDefaults, false);
    });
    
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    ['dragenter', 'dragover'].forEach(eventName => {
        imageDropZone.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        imageDropZone.addEventListener(eventName, unhighlight, false);
    });
    
    function highlight() {
        imageDropZone.classList.add('drag-over');
    }
    
    function unhighlight() {
        imageDropZone.classList.remove('drag-over');
    }
    
    imageDropZone.addEventListener('drop', handleImageDrop, false);
    
    function handleImageDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        
        if (files.length > 0) {
            const file = files[0];
            // Check if it's an image file
            if (file.type.startsWith('image/') || ['.jpg', '.jpeg', '.png', '.gif', '.webp'].some(ext => file.name.toLowerCase().endsWith(ext))) {
                // Set the file to the hidden input
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(file);
                imageFileInput.files = dataTransfer.files;
                displayImageFileName(file);
                previewImage(file);
            } else {
                showToast('error', 'Invalid File Type', 'Only image files (JPG, PNG, GIF, WebP) are allowed.');
            }
        }
    }
    
    function displayImageFileName(file) {
        const imageFileNameDisplay = document.getElementById('imageFileNameDisplay');
        const imageFileNameSpan = document.getElementById('imageFileName');
        
        imageFileNameSpan.textContent = file.name;
        imageFileNameDisplay.style.display = 'flex';
        imageDropZone.style.display = 'none';
    }
    
    function previewImage(file) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            imagePreview.src = e.target.result;
            imagePreview.style.display = 'block';
            previewPlaceholder.style.display = 'none';
            imagePreviewSection.style.display = 'block';
        };
        
        reader.readAsDataURL(file);
    }
}

// Add event listener to the PDF upload button
const uploadPdfBtn = document.getElementById('uploadPdfBtn');
if (uploadPdfBtn) {
    uploadPdfBtn.addEventListener('click', uploadAndGenerateQuestions);
}

// Question form functions
function toggleOptions() {
    const qType = document.getElementById("questionTypeSelect").value;
    const mcq = document.getElementById("mcqOptions");
    const single = document.getElementById("correctAnswerContainer");
    const trueFalse = document.getElementById("trueFalseContainer");
    const multiple = document.getElementById("multipleCorrectContainer");
    const correct = document.getElementById("correctAnswer");
    const trueFalseSelect = document.getElementById("trueFalseSelect");
    
    // Get option inputs
    const opt1 = document.getElementById('opt1');
    const opt2 = document.getElementById('opt2');
    const opt3 = document.getElementById('opt3');
    const opt4 = document.getElementById('opt4');
    
    document.getElementById("questionTypeHidden").value = qType;

    // Hide all containers
    mcq.style.display = "none";
    single.style.display = "none";
    trueFalse.style.display = "none";
    multiple.style.display = "none";
    
    // Remove required attributes from all elements
    correct.required = false;
    if (trueFalseSelect) trueFalseSelect.required = false;
    if (opt1) opt1.required = false;
    if (opt2) opt2.required = false;
    if (opt3) opt3.required = false;
    if (opt4) opt4.required = false;

    if (qType === "TrueFalse") {
        trueFalse.style.display = "block";
        if (trueFalseSelect) trueFalseSelect.required = true;
        // Don't require options for True/False questions
        if (opt1) opt1.required = false;
        if (opt2) opt2.required = false;
        if (opt3) opt3.required = false;
        if (opt4) opt4.required = false;
        
        // Clear and disable option fields for True/False questions
        if (opt1) {
            opt1.value = '';
            opt1.disabled = true;
        }
        if (opt2) {
            opt2.value = '';
            opt2.disabled = true;
        }
        if (opt3) {
            opt3.value = '';
            opt3.disabled = true;
        }
        if (opt4) {
            opt4.value = '';
            opt4.disabled = true;
        }
        
        // Update correct answer field with selected value if available
        if (trueFalseSelect && trueFalseSelect.value) {
            const correctAnswerField = document.getElementById('correctAnswer');
            if (correctAnswerField) {
                correctAnswerField.value = trueFalseSelect.value;
            }
        }
    } else {
        mcq.style.display = "block";
        if (opt1) opt1.required = true;
        if (opt2) opt2.required = true;
        
        // Enable option fields for non-True/False questions
        if (opt1) opt1.disabled = false;
        if (opt2) opt2.disabled = false;
        if (opt3) opt3.disabled = false;
        if (opt4) opt4.disabled = false;
        
        if (qType === "MultipleSelect") {
            multiple.style.display = "block";
            updateCorrectOptionLabels();
            initializeMultipleSelectCheckboxes();
        } else {
            single.style.display = "block";
            correct.placeholder = qType === 'Code' ? "Expected output" : "Correct Answer";
            correct.required = true;
        }
    }
}

// Function to check if question suggests code snippet type
function checkForCodeSnippet() {
    const questionText = document.getElementById("questionTextarea").value;
    const questionType = document.getElementById("questionTypeSelect").value;
    
    // Count lines and check for code indicators
    const lines = questionText.split('\n').filter(line => line.trim() !== '');
    const hasCodeIndicators = /(?:def |function |public |class |print\(|console\.|<[^>]*>|\{|\}|import |int |String |printf\(|cout )/.test(questionText);
    
    // If question is longer than 3 lines or contains code indicators and is not already Code type
    if ((lines.length > 3 || hasCodeIndicators) && questionType !== 'Code') {
        if (confirm("This question appears to contain code or multiple lines. Would you like to change the question type to 'Code Snippet'?")) {
            document.getElementById("questionTypeSelect").value = "Code";
            toggleOptions();
        }
    }
}

function initializeMultipleSelectCheckboxes() {
    document.querySelectorAll('.correct-checkbox').forEach(cb => {
        cb.addEventListener('change', function() {
            if (document.querySelectorAll('.correct-checkbox:checked').length > 2) {
                this.checked = false;
                showModal('Too Many Selections', 'You can only select 2 correct answers.');
            } else {
                updateCorrectAnswerField();
            }
        });
    });
}

// Add event listener for True/False dropdown
function initializeTrueFalseSelection() {
    const trueFalseSelect = document.getElementById('trueFalseSelect');
    if (trueFalseSelect) {
        trueFalseSelect.addEventListener('change', function() {
            // Update the hidden correct answer field with the selected value
            const correctAnswerField = document.getElementById('correctAnswer');
            if (correctAnswerField) {
                correctAnswerField.value = this.value;
            }
        });
    }
}

function updateCorrectOptionLabels() {
    for (let i = 1; i <= 4; i++) {
        const optInput = document.getElementById(`opt${i}`);
        const checkbox = document.getElementById(`correctOpt${i}`);
        const label = document.querySelector(`label[for="correctOpt${i}"]`);

        if (optInput && checkbox && label) {
            optInput.addEventListener('input', () => {
                const value = optInput.value.trim();
                label.textContent = value || `Option ${i}`;
                checkbox.value = value;
                checkbox.disabled = !value;
                if (!value) {
                    checkbox.checked = false;
                }
            });
        }
    }
}

function updateCorrectAnswerField() {
    const selectedAnswers = Array.from(document.querySelectorAll('.correct-checkbox:checked'))
        .map(cb => cb.value)
        .join('|');
    document.getElementById('correctAnswer').value = selectedAnswers;
}

function resetForm() {
    // Don't reset the course and question type selections
    // Only reset the question content fields
    
    // Reset question text
    const questionTextarea = document.getElementById('questionTextarea');
    if (questionTextarea) {
        questionTextarea.value = '';
    }
    
    // Reset options
    for (let i = 1; i <= 4; i++) {
        const optInput = document.getElementById(`opt${i}`);
        if (optInput) {
            optInput.value = '';
        }
    }
    
    // Reset correct answer
    const correctAnswer = document.getElementById('correctAnswer');
    if (correctAnswer) {
        correctAnswer.value = '';
    }
    
    // Reset True/False dropdown
    const trueFalseSelect = document.getElementById('trueFalseSelect');
    if (trueFalseSelect) {
        trueFalseSelect.selectedIndex = 0;
    }
    
    // Reset multiple select checkboxes
    document.querySelectorAll('.correct-checkbox').forEach(cb => {
        cb.checked = false;
    });
    
    // Reset image upload section
    removeImageFile();
    
    // Re-initialize options based on current question type
    toggleOptions();
}

// Function to update scroll indicator visibility
function updateScrollIndicator() {
    const scrollIndicator = document.querySelector('.scroll-indicator');
    if (scrollIndicator) {
        // Show scroll indicator when near bottom of page
        const scrollTop = window.pageYOffset;
        const windowHeight = window.innerHeight;
        const documentHeight = document.documentElement.scrollHeight;
        
        // Show indicator when user scrolls within 100px of bottom
        if (documentHeight - scrollTop - windowHeight < 100) {
            scrollIndicator.style.display = 'none';
        } else {
            scrollIndicator.style.display = 'flex';
        }
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    toggleOptions(); // Initialize the correct answer container visibility
    updateCorrectOptionLabels();
    syncCourseDropdowns();
    initializeTrueFalseSelection(); // Initialize True/False dropdown event handler
    
    // Add form submission handler
    const addQuestionForm = document.getElementById('addQuestionForm');
    if (addQuestionForm) {
        addQuestionForm.addEventListener('submit', function(e) {
            const qType = document.getElementById("questionTypeSelect").value;
            const questionText = document.getElementById('questionTextarea').value.trim();
            const imageFile = document.getElementById('imageFile').files[0];
            let isValid = true;
            let errorMsg = '';
            
            // Check if either question text or image is provided
            if (!questionText && !imageFile) {
                errorMsg = "Either question text or an image must be provided.";
                isValid = false;
            }
            
            if (qType === "TrueFalse") {
                const trueFalseValue = document.getElementById('trueFalseSelect').value;
                if (!trueFalseValue) {
                    errorMsg = "Please select True or False for the correct answer.";
                    isValid = false;
                }
                // Set the correct answer field to the selected value from dropdown
                const correctAnswerField = document.getElementById('correctAnswer');
                if (correctAnswerField) {
                    correctAnswerField.value = trueFalseValue;
                }
            } else if (qType === "MultipleSelect") {
                const selectedCount = document.querySelectorAll('.correct-checkbox:checked').length;
                if (selectedCount !== 2) {
                    errorMsg = "Select exactly 2 correct answers.";
                    isValid = false;
                }
            } else {
                // For MCQ questions (but not True/False, MultipleSelect, or Code)
                if (qType === "MCQ") {
                    // Get the options
                    const opt1 = document.getElementById('opt1').value.trim();
                    const opt2 = document.getElementById('opt2').value.trim();
                    const opt3 = document.getElementById('opt3').value.trim();
                    const opt4 = document.getElementById('opt4').value.trim();
                    
                    // Check if required options are filled
                    if (!opt1 || !opt2) {
                        errorMsg = "First and second options are required for this question type.";
                        isValid = false;
                    } else {
                        const opts = [opt1, opt2, opt3, opt4].filter(Boolean);
                        if (new Set(opts).size !== opts.length) {
                            errorMsg = "Options must be unique.";
                            isValid = false;
                        } else {
                            const correctValue = document.getElementById('correctAnswer').value.trim();
                            if (!opts.includes(correctValue)) {
                                errorMsg = "Correct answer must match one of the options.";
                                isValid = false;
                            }
                        }
                    }
                } else if (qType === "Code") {
                    // For Code questions, validate that correct answer is provided
                    const correctValue = document.getElementById('correctAnswer').value.trim();
                    if (!correctValue) {
                        errorMsg = "Expected output is required for Code questions.";
                        isValid = false;
                    }
                }
                // True/False validation is handled separately above
            }
            
            if (!isValid) {
                e.preventDefault();
                showToast('error', 'Validation Error', errorMsg);
            }
        });
    }
    
    // Close modal when clicking outside
    window.onclick = (event) => {
        const modal = document.getElementById('validationModal');
        if (event.target == modal) closeModal();
    };

    // Re-enable scroll indicator with debounce to prevent performance issues
    updateScrollIndicator();
    
    // Debounce function to limit how often the scroll event fires
    let scrollTimeout;
    window.addEventListener("scroll", () => {
        clearTimeout(scrollTimeout);
        scrollTimeout = setTimeout(updateScrollIndicator, 100);
    });
    
    let resizeTimeout;
    window.addEventListener("resize", () => {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(updateScrollIndicator, 100);
    });
    
    // Add scroll to top functionality
    const scrollToTopBtn = document.getElementById('scrollToTopBtn');
    
    if (scrollToTopBtn) {
        // Show/hide scroll to top button based on scroll position
        window.addEventListener('scroll', function() {
            if (window.pageYOffset > 300) {  // Show after scrolling down 300px
                scrollToTopBtn.classList.add('show');
            } else {
                scrollToTopBtn.classList.remove('show');
            }
        });
        
        // Scroll to top when button is clicked
        scrollToTopBtn.addEventListener('click', function() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
});
</script>