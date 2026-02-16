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
<div id="qValidationModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header error-header">
            <h3 id="qModalTitle">
                <i class="fas fa-exclamation-triangle"></i> Validation Error
            </h3>
            <span class="close-modal" onclick="closeModal()">&times;</span>
        </div>

        <div class="modal-body">
            <p class="error-summary">
                The correct answer does not match any of the provided options.
            </p>

            <div class="error-details">
                <p><strong>Entered Correct Answer:</strong></p>
                <div id="qEnteredAnswer" class="highlight-box"></div>

                <p><strong>Available Options:</strong></p>
                <ul id="qOptionsList" class="options-list"></ul>
            </div>

            <div class="error-instruction">
                Please ensure the correct answer matches one of the options exactly 
                (including spelling, spacing, and capitalization).
            </div>
        </div>

        <div class="modal-footer">
            <button onclick="closeModal()" class="btn btn-primary">OK</button>
        </div>
    </div>
</div>

<style>
    .highlight-box {
        background: #fff3cd;
        padding: 8px;
        border-left: 4px solid #ffc107;
        margin-bottom: 10px;
        font-weight: bold;
    }

    .options-list {
        background: #f8f9fa;
        padding: 10px;
        border-radius: 5px;
        list-style-position: inside;
    }

    .error-header {
        background: #dc3545;
        color: white;
    }

    .error-instruction {
        margin-top: 15px;
        padding: 10px;
        background: #e9ecef;
        border-radius: 5px;
        font-size: 14px;
    }

    .error-details {
        margin: 15px 0;
    }

    .error-summary {
        font-size: 16px;
        margin-bottom: 15px;
        color: #666;
    }
</style>

<!-- Modal for batch completion confirmation -->
<div id="batchCompleteModal" class="modal" style="display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4);">
    <div class="modal-content" style="background-color: #fefefe; margin: 15% auto; padding: 20px; border: 1px solid #888; width: 40%; min-width: 300px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
        <div class="modal-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid #eee;">
            <h3 style="margin: 0; color: #333;">
                <i class="fas fa-check-circle" style="color: #28a745;"></i> Batch Complete
            </h3>
            <span class="close-modal" onclick="closeBatchCompleteModal()" style="font-size: 28px; font-weight: bold; cursor: pointer; color: #aaa;">&times;</span>
        </div>
        <div class="modal-body" style="margin-bottom: 20px;">
            <p>All questions in the batch have been added successfully!</p>
            <p>Would you like to view all questions now?</p>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 10px; padding-top: 15px; border-top: 1px solid #eee;">
            <button onclick="closeBatchCompleteModal()" class="btn btn-secondary" style="padding: 8px 16px; background-color: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer;">No, Continue</button>
            <button onclick="viewAllQuestions()" class="btn btn-primary" style="padding: 8px 16px; background-color: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;">Yes, View All</button>
        </div>
    </div>
</div>

<!-- Modal for batch cancellation confirmation -->
<div id="batchCancelModal" class="modal" style="display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4);">
    <div class="modal-content" style="background-color: #fefefe; margin: 15% auto; padding: 20px; border: 1px solid #888; width: 40%; min-width: 300px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
        <div class="modal-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid #eee;">
            <h3 style="margin: 0; color: #333;">
                <i class="fas fa-exclamation-triangle" style="color: #ffc107;"></i> Cancel Batch Process
            </h3>
            <span class="close-modal" onclick="closeBatchCancelModal()" style="font-size: 28px; font-weight: bold; cursor: pointer; color: #aaa;">&times;</span>
        </div>
        <div class="modal-body" style="margin-bottom: 20px;">
            <p>Are you sure you want to cancel the current batch process?</p>
            <p style="color: #dc3545; font-weight: 500;">Any unsubmitted questions will be lost.</p>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 10px; padding-top: 15px; border-top: 1px solid #eee;">
            <button onclick="closeBatchCancelModal()" class="btn btn-secondary" style="padding: 8px 16px; background-color: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer;">No, Continue Batch</button>
            <button onclick="confirmBatchCancel()" class="btn btn-danger" style="padding: 8px 16px; background-color: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer;">Yes, Cancel Batch</button>
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
    
    /* Smart parsing button styles */
    .btn-sm {
        padding: 6px 12px;
        font-size: 12px;
        line-height: 1.4;
        border-radius: 4px;
    }
    
    .btn-info {
        background: linear-gradient(135deg, #17a2b8, #138496);
        color: white;
        border: none;
        transition: all 0.2s ease;
    }
    
    .btn-info:hover {
        background: linear-gradient(135deg, #138496, #117a8b);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(23, 162, 184, 0.3);
    }
    
    .btn-info:active {
        transform: translateY(0);
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

/* Drag and Drop Interface Styles */
.drag-item-row, .drop-target-row {
    display: flex;
    gap: var(--spacing-sm);
    align-items: center;
    margin-bottom: var(--spacing-sm);
    padding: var(--spacing-sm);
    background: var(--light-gray);
    border-radius: var(--radius-sm);
    border: 1px solid var(--medium-gray);
}

.drag-item-row:hover, .drop-target-row:hover {
    background: var(--white);
    border-color: var(--accent-blue);
}

.drag-item-row textarea, .drop-target-row textarea {
    flex: 1;
    resize: none;
    overflow: hidden;
    min-height: 38px;
}

.drag-handle {
    cursor: move;
}

.drag-item-row.row-dragging, .drop-target-row.row-dragging {
    opacity: 0.4;
    border: 2px dashed var(--accent-blue);
}

.drag-item-row select {
    flex: 1;
    min-width: 200px;
}

.btn-sm {
    padding: 6px 12px;
    font-size: 12px;
    border-radius: var(--radius-sm);
}

.drag-drop-container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: var(--spacing-lg);
    margin-top: var(--spacing-md);
}

.drag-items-section, .drop-targets-section {
    background: var(--light-gray);
    padding: var(--spacing-md);
    border-radius: var(--radius-md);
    border: 1px solid var(--medium-gray);
}

.drag-items-section h4, .drop-targets-section h4 {
    margin-bottom: var(--spacing-md);
    color: var(--text-dark);
    font-size: 14px;
    font-weight: 600;
}

.drag-item-example, .drop-target-example {
    background: var(--white);
    border: 2px dashed var(--accent-blue);
    border-radius: var(--radius-sm);
    padding: var(--spacing-md);
    margin-bottom: var(--spacing-sm);
    text-align: center;
    color: var(--dark-gray);
    font-size: 13px;
}

.drag-item-example {
    cursor: move;
    transition: all var(--transition-normal);
}

.drag-item-example:hover {
    background: rgba(74, 144, 226, 0.05);
    border-color: var(--primary-blue);
}

.drop-target-example {
    min-height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.drop-target-example.drag-over {
    background: rgba(74, 144, 226, 0.1);
    border-color: var(--primary-blue);
    transform: scale(1.02);
}

.drag-drop-preview {
    background: var(--white);
    border: 1px solid var(--medium-gray);
    border-radius: var(--radius-md);
    padding: var(--spacing-lg);
    margin-top: var(--spacing-md);
}

.drag-drop-preview h5 {
    margin-bottom: var(--spacing-md);
    color: var(--text-dark);
    font-size: 14px;
    font-weight: 600;
}

.preview-items, .preview-targets {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-sm);
    margin-bottom: var(--spacing-md);
}

.preview-item {
    background: var(--accent-blue);
    color: var(--white);
    padding: 6px 12px;
    border-radius: var(--radius-sm);
    font-size: 12px;
    cursor: move;
}

.preview-target {
    background: var(--success);
    color: var(--white);
    padding: 8px 16px;
    border-radius: var(--radius-sm);
    font-size: 12px;
    min-width: 100px;
    text-align: center;
}

.preview-target.drag-over {
    background: var(--primary-blue);
    transform: scale(1.05);
}

    /* Enhanced Multi-Question Modal Styles */
    .batch-review-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
    }
    .batch-review-table th {
        background: var(--light-gray);
        padding: 10px;
        text-align: left;
        font-size: 12px;
        text-transform: uppercase;
        color: var(--dark-gray);
        border-bottom: 2px solid var(--medium-gray);
    }
    .batch-review-table td {
        padding: 10px;
        border-bottom: 1px solid var(--medium-gray);
        vertical-align: top;
    }
    .batch-row-edit {
        background: #fff;
        border: 1px solid var(--medium-gray);
        border-radius: 4px;
        padding: 5px;
        width: 100%;
        font-size: 13px;
    }
    .batch-row-edit:focus {
        border-color: var(--accent-blue);
        outline: none;
    }
    .match-indicator {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        font-size: 12px;
        font-weight: 600;
        padding: 2px 8px;
        border-radius: 10px;
    }
    .match-success {
        background: #d1fae5;
        color: #065f46;
    }
    .match-error {
        background: #fee2e2;
        color: #991b1b;
    }
    .batch-modal-content {
        max-width: 1200px !important;
        width: 95% !important;
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
        
        <!-- Upload Question File Panel -->
        <div class="question-card" id="uploadQuestionFilePanel">
            <div class="card-header" style="background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));">
                <span><i class="fas fa-file-upload"></i> Upload Question File (TXT/PDF)</span>
                <i class="fas fa-upload" style="opacity: 0.8;"></i>
            </div>
            <div class="question-form">
                <form id="questionFileUploadForm" enctype="multipart/form-data">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book" style="color: var(--accent-blue);"></i>
                                Target Course
                            </label>
                            <select name="coursename" class="form-select" id="courseSelectFile" required onchange="syncCourseDropdowns()">
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
                            <small class="form-hint">Course where questions will be added</small>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-file-import" style="color: var(--primary-blue);"></i>
                            Select Question File
                        </label>
                        <div class="drop-zone" id="fileDropZone">
                            <div class="drop-zone-content">
                                <i class="fas fa-cloud-upload-alt drop-icon"></i>
                                <p class="drop-text">Drag & drop your file here or click to browse</p>
                                <p class="drop-hint">Supports Text (.txt) and PDF (.pdf) (Max 5MB)</p>
                                <input type="file" name="questionFile" class="form-control" id="questionFile" accept=".txt,.pdf" style="display: none;">
                            </div>
                        </div>
                        <div id="fileUploadNameDisplay" class="file-name-display" style="display: none; margin-top: 10px;">
                            <i id="fileTypeIcon" class="fas fa-file-alt"></i>
                            <span id="uploadFileName"></span>
                            <button type="button" class="remove-file-btn" onclick="removeUploadFile()">?</button>
                        </div>
                        <div class="quick-add-indicator mt-2" style="background: #e9ecef; color: #495057; border-left-color: #6c757d;">
                            <i class="fas fa-info-circle"></i>
                            <span>The file should contain questions in the format: <strong>"Your Question: ... Option 1: ... Option 2: ... Correct Answer: ..."</strong></span>
                        </div>
                    </div>
                    
                    <!-- AI Generation Toggle -->
                    <div class="form-group" style="margin-top: 15px; padding: 15px; background: #f0f7ff; border-radius: 8px; border-left: 4px solid var(--accent-blue);">
                        <div class="form-check" style="border: none; background: transparent; padding: 0;">
                            <input type="checkbox" id="aiGenerationToggle" class="form-check-input" style="width: 20px; height: 20px;">
                            <label for="aiGenerationToggle" class="form-check-label" style="font-weight: 600; color: var(--primary-blue); font-size: 15px; margin-left: 10px;">
                                <i class="fas fa-robot"></i> Use Code SA AI-Bot to extract questions from uploaded file
                            </label>
                        </div>
                        <p class="form-hint" style="margin-top: 8px; margin-left: 30px;">
                            Code SA AI-Bot will intelligently analyze your uploaded file (PDF, Word, Docx), identify questions and answers, and automatically generate high-quality MCQ options for you.
                        </p>
                    </div>

                    
                    <!-- Progress and Status Elements -->
                    <div id="fileUploadProgress" class="progress" style="display: none; margin: 15px 0;">
                        <div class="progress-bar" style="width: 0%;">0%</div>
                    </div>
                    <div id="fileUploadStatus" style="display: none;"></div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn btn-outline" onclick="resetFileUploadForm()">
                            <i class="fas fa-redo"></i>
                            Reset
                        </button>
                        <button type="button" class="btn btn-primary" id="processFileBtn">
                            <i class="fas fa-magic"></i>
                            Extract & Parse Questions
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Batch Progress Card -->
        <div class="question-card" id="batchProgressCard" style="display: none; border-left: 5px solid var(--accent-blue);">
            <div class="card-header" style="background: linear-gradient(90deg, var(--accent-blue), var(--secondary-blue));">
                <span><i class="fas fa-layer-group"></i> Batch Processing Active</span>
                <button type="button" class="btn btn-sm btn-outline" style="color: white; border-color: white; padding: 2px 8px;" onclick="cancelBatch()">Cancel Batch</button>
            </div>
            <div class="question-form" style="padding: 15px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                    <span id="batchProgressText" style="font-weight: 600; color: var(--primary-blue);">Question 1 of 5</span>
                    <span id="batchPercentageText" style="font-weight: 600; color: var(--success);">20%</span>
                </div>
                <div class="progress" style="height: 10px; margin-bottom: 5px;">
                    <div id="batchProgressBar" class="progress-bar" style="width: 20%;"></div>
                </div>
                <small class="form-hint" id="batchStatusHint">Loading next question into form automatically after each submission...</small>
            </div>
        </div>

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
                            <select name="coursename" class="form-select" id="courseSelectAddNew" required onchange="syncCourseDropdowns(); saveLastSelection()">
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
                                <option value="DRAG_AND_DROP" <%="DRAG_AND_DROP".equals(lastQuestionType) ? "selected" : ""%>>Drag and Drop</option>
                            </select>
                            <input type="hidden" id="questionTypeHidden" name="questionType" value="<%=lastQuestionType%>">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-question-circle" style="color: var(--primary-blue);"></i> Your Question</label>
                        <textarea name="question" id="questionTextarea" class="question-input" rows="3" placeholder="Enter your question here...&#10;&#10;Tip: Paste structured questions in this format:&#10;Your Question: What is the correct way to get values in Python?&#10;Option 1: Gets value after input()&#10;Option 2: Gets value after read()&#10;Option 3: Gets value after get()&#10;Option 4: Gets value after scan()&#10;Correct Answer: Gets value after input()"></textarea>
                        <button type="button" class="btn btn-sm btn-secondary mt-2" id="parseQuestionBtn" style="display: none;">
                            <i class="fas fa-magic"></i> Parse Question
                        </button>
                        <small class="form-hint">Type or paste your question. Auto-parsing triggers after 1 second of inactivity.</small>
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
                            <button type="button" class="remove-file-btn" onclick="removeImageFile()">?</button>
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
                    
                    <!-- Drag and Drop Options -->
                    <div id="dragDropOptions" style="display:none;">
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-arrows-alt" style="color: var(--accent-blue);"></i>
                                    Total Marks
                                </label>
                                <input type="number" name="totalMarks" class="form-control" value="1" min="1" max="100" required>
                                <small class="form-hint">Total marks for this question</small>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-columns" style="color: var(--info);"></i>
                                    Orientation
                                </label>
                                <select name="orientation" class="form-select" id="orientationSelect">
                                    <option value="horizontal">Horizontal (Side by Side)</option>
                                    <option value="vertical">Vertical (Stacked)</option>
                                    <option value="landscape">Landscape (Code Style)</option>
                                </select>
                                <small class="form-hint">How items and targets are laid out</small>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-hand-rock" style="color: var(--info);"></i>
                                Draggable Items
                            </label>
                            <div id="dragItemsContainer">
                                <div class="drag-item-row" data-item-index="0" draggable="true" ondragstart="handleQuestionRowDragStart(event)" ondragover="handleQuestionRowDragOver(event)" ondrop="handleQuestionRowDrop(event)" ondragend="handleQuestionRowDragEnd(event)">
                                    <i class="fas fa-grip-vertical mr-2 text-muted drag-handle"></i>
                                    <textarea name="dragItem_text_0" class="form-control" rows="1" placeholder="Enter draggable item text" oninput="autoResize(this)"></textarea>
                                    <select name="dragItem_target_0" class="form-select">
                                        <option value="">Select correct target</option>
                                    </select>
                                    <button type="button" class="btn btn-outline btn-sm" onclick="removeDragItem(this)">Remove</button>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline btn-sm" onclick="addDragItem()">
                                <i class="fas fa-plus"></i> Add Item
                            </button>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-bullseye" style="color: var(--success);"></i>
                                Drop Targets
                            </label>
                            <div id="dropTargetsContainer">
                                <div class="drop-target-row" data-target-index="0" draggable="true" ondragstart="handleQuestionRowDragStart(event)" ondragover="handleQuestionRowDragOver(event)" ondrop="handleQuestionRowDrop(event)" ondragend="handleQuestionRowDragEnd(event)">
                                    <i class="fas fa-bullseye mr-2 text-muted drag-handle"></i>
                                    <textarea name="dropTarget_0" class="form-control" rows="1" placeholder="Enter drop target label (use [[target]] for box position)" oninput="autoResize(this); updateDragDropTargetOptions()"></textarea>
                                    <button type="button" class="btn btn-outline btn-sm" onclick="removeDropTarget(this)">Remove</button>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline btn-sm" onclick="addDropTarget()">
                                <i class="fas fa-plus"></i> Add Target
                            </button>
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
                                    <input type="checkbox" id="correctOpt1" class="form-check-input correct-checkbox" value="">
                                    <label for="correctOpt1" class="form-check-label">Option 1</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt2" class="form-check-input correct-checkbox" value="">
                                    <label for="correctOpt2" class="form-check-label">Option 2</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt3" class="form-check-input correct-checkbox" value="">
                                    <label for="correctOpt3" class="form-check-label">Option 3</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="correctOpt4" class="form-check-input correct-checkbox" value="">
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
                            <select name="coursename" class="form-select" id="courseSelectView" onchange="syncCourseDropdowns(); updateShowAllButton()">
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
    const fileCourseSelect = document.getElementById('courseSelectFile');
    const addQuestionCourseSelect = document.getElementById('courseSelectAddNew');
    const viewCourseSelect = document.getElementById('courseSelectView');
    
    // Function to sync all dropdowns
    function syncAllDropdowns(changedSelect) {
        const value = changedSelect.value;
        
        if (fileCourseSelect && fileCourseSelect !== changedSelect) {
            fileCourseSelect.value = value;
        }
        if (addQuestionCourseSelect && addQuestionCourseSelect !== changedSelect) {
            addQuestionCourseSelect.value = value;
        }
        if (viewCourseSelect && viewCourseSelect !== changedSelect) {
            viewCourseSelect.value = value;
        }
        
        // Save selection and update UI after syncing
        saveLastSelection();
        updateShowAllButton();
    }
    
    // Add event listeners to all dropdowns
    if (fileCourseSelect) {
        fileCourseSelect.addEventListener('change', function() {
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

// File Upload and Processing Functions
function handleFileUploadAndParsing() {
    const form = document.getElementById('questionFileUploadForm');
    const fileInput = document.getElementById('questionFile');
    const courseSelect = document.getElementById('courseSelectFile');
    const processBtn = document.getElementById('processFileBtn');
    const progressDiv = document.getElementById('fileUploadProgress');
    const progressBar = progressDiv.querySelector('.progress-bar');
    const statusDiv = document.getElementById('fileUploadStatus');
    
    if (!fileInput.files[0]) {
        showToast('error', 'Validation Error', 'Please select a file to upload.');
        return;
    }
    
    if (!courseSelect.value) {
        showToast('error', 'Validation Error', 'Please select a target course.');
        return;
    }
    
    const file = fileInput.files[0];
    const fileName = file.name.toLowerCase();
    
    // Show progress bar
    progressDiv.style.display = 'block';
    statusDiv.style.display = 'block';
    statusDiv.innerHTML = '<div class="alert"><i class="fas fa-spinner fa-spin"></i> Reading and processing file...</div>';
    progressBar.style.width = '20%';
    progressBar.textContent = '20%';
    
    // Disable button
    processBtn.disabled = true;
    processBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
    
    const useAI = document.getElementById('aiGenerationToggle').checked;

    if (fileName.endsWith('.txt')) {
        // Process text file client-side
        const reader = new FileReader();
        reader.onload = function(e) {
            progressBar.style.width = '40%';
            progressBar.textContent = '40%';
            const text = e.target.result;
            if (useAI) {
                generateQuestionsWithAI(text, courseSelect.value);
            } else {
                progressBar.style.width = '100%';
                progressBar.textContent = '100%';
                processExtractedText(text, courseSelect.value);
            }
        };
        reader.onerror = function() {
            showToast('error', 'File Error', 'Failed to read the text file.');
            resetFileUploadProgress();
        };
        reader.readAsText(file);
    } else if (fileName.endsWith('.pdf')) {
        // Process PDF server-side
        const formData = new FormData();
        formData.append('questionFile', file);
        formData.append('page', 'questions');
        formData.append('operation', 'extract_text');
        
        fetch('controller.jsp', {
            method: 'POST',
            body: formData
        })
        .then(async response => {
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            const data = await response.json();
            if (data.success) {
                progressBar.style.width = '40%';
                progressBar.textContent = '40%';
                if (useAI) {
                    generateQuestionsWithAI(data.extractedText, courseSelect.value);
                } else {
                    progressBar.style.width = '100%';
                    progressBar.textContent = '100%';
                    processExtractedText(data.extractedText, courseSelect.value);
                }
            } else {
                throw new Error(data.message || 'Failed to extract text from PDF');
            }
        })
        .catch(error => {
            console.error('PDF Processing Error:', error);
            statusDiv.innerHTML = `<div class="alert" style="background: #f8d7da; color: #721c24;"><i class="fas fa-exclamation-triangle"></i> Error: ${error.message}</div>`;
            progressBar.style.backgroundColor = '#dc3545';
            processBtn.disabled = false;
            processBtn.innerHTML = '<i class="fas fa-magic"></i> Extract & Parse Questions';
        });
    } else {
        showToast('error', 'Invalid File', 'Only .txt and .pdf files are supported.');
        resetFileUploadProgress();
    }
}

function generateQuestionsWithAI(text, courseName) {
    const statusDiv = document.getElementById('fileUploadStatus');
    const progressBar = document.querySelector('#fileUploadProgress .progress-bar');
    const processBtn = document.getElementById('processFileBtn');
    
    statusDiv.innerHTML = '<div class="alert"><i class="fas fa-robot fa-spin"></i> AI is intelligently parsing marking guidelines and generating options...</div>';
    progressBar.style.width = '70%';
    progressBar.textContent = '70%';

    const formData = new URLSearchParams();
    formData.append('page', 'questions');
    formData.append('operation', 'ai_generate');
    formData.append('text', text);
    formData.append('questionType', 'MCQ');
    formData.append('isMarkingGuideline', 'true');
    formData.append('numQuestions', '30');

    fetch('controller.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString()
    })
    .then(async response => {
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Server Error (${response.status}): ${errorText.substring(0, 100)}`);
        }
        const data = await response.json();
        if (data.success && data.questions) {
            progressBar.style.width = '100%';
            progressBar.textContent = '100%';
            statusDiv.innerHTML = `<div class="alert" style="background: #d4edda; color: #155724;"><i class="fas fa-check-circle"></i> AI successfully generated ${data.questions.length} questions.</div>`;
            
            // Map AI format to our internal format if needed
            const formattedQuestions = data.questions.map(q => ({
                question: q.question,
                options: q.options || ['', '', '', ''],
                correct: q.correct,
                type: q.type || (q.options && q.options.length === 2 ? 'TrueFalse' : 'MCQ')
            }));

            setTimeout(() => {
                showMultipleQuestionsModal(formattedQuestions);
                resetFileUploadProgress();
            }, 1000);
        } else {
            throw new Error(data.message || 'AI failed to generate questions. The response was not in the expected format.');
        }
    })
    .catch(error => {
        console.error('AI Generation Error:', error);
        statusDiv.innerHTML = `<div class="alert" style="background: #f8d7da; color: #721c24;"><i class="fas fa-exclamation-triangle"></i> AI Error: ${error.message}</div>`;
        progressBar.style.backgroundColor = '#dc3545';
        processBtn.disabled = false;
        processBtn.innerHTML = '<i class="fas fa-magic"></i> Extract & Parse Questions';
    });
}

function processExtractedText(text, courseName) {
    const statusDiv = document.getElementById('fileUploadStatus');
    const progressBar = document.querySelector('#fileUploadProgress .progress-bar');
    const processBtn = document.getElementById('processFileBtn');
    
    try {
        // Update course selection in main form to match the file upload target
        const mainCourseSelect = document.getElementById('courseSelectAddNew');
        if (mainCourseSelect) {
            mainCourseSelect.value = courseName;
            saveLastSelection();
        }
        
        // Parse questions from text
        const questions = parseMultipleQuestions(text);
        
        if (questions.length > 0) {
            progressBar.style.width = '100%';
            progressBar.textContent = '100%';
            statusDiv.innerHTML = `<div class="alert" style="background: #d4edda; color: #155724;"><i class="fas fa-check-circle"></i> Successfully parsed ${questions.length} questions.</div>`;
            
            showToast('success', 'Success', `Parsed ${questions.length} questions from file.`);
            
            // Show review modal
            setTimeout(() => {
                showMultipleQuestionsModal(questions);
                resetFileUploadProgress();
            }, 1000);
        } else {
            throw new Error('No valid questions found in the file. Please check the format.');
        }
    } catch (error) {
        statusDiv.innerHTML = `<div class="alert" style="background: #f8d7da; color: #721c24;"><i class="fas fa-exclamation-triangle"></i> Error: ${error.message}</div>`;
        progressBar.style.backgroundColor = '#dc3545';
        processBtn.disabled = false;
        processBtn.innerHTML = '<i class="fas fa-magic"></i> Extract & Parse Questions';
    }
}

function resetFileUploadProgress() {
    const processBtn = document.getElementById('processFileBtn');
    const progressDiv = document.getElementById('fileUploadProgress');
    const progressBar = progressDiv.querySelector('.progress-bar');
    
    processBtn.disabled = false;
    processBtn.innerHTML = '<i class="fas fa-magic"></i> Extract & Parse Questions';
    
    setTimeout(() => {
        progressDiv.style.display = 'none';
        progressBar.style.width = '0%';
        progressBar.style.backgroundColor = '';
    }, 3000);
}

function resetFileUploadForm() {
    document.getElementById('questionFileUploadForm').reset();
    document.getElementById('fileUploadProgress').style.display = 'none';
    document.getElementById('fileUploadStatus').style.display = 'none';
    
    const fileInput = document.getElementById('questionFile');
    const nameDisplay = document.getElementById('fileUploadNameDisplay');
    const dropZone = document.getElementById('fileDropZone');
    
    if (fileInput) fileInput.value = '';
    if (nameDisplay) nameDisplay.style.display = 'none';
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
    let icon = 'fa-exclamation-triangle';
    if (title === 'Success') icon = 'fa-check-circle';
    document.getElementById('modalTitle').innerHTML = '<i class="fas ' + icon + '"></i> ' + title;
    document.getElementById('modalMessage').textContent = message;
    document.getElementById('validationModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('qValidationModal').style.display = 'none';
}

// Function to populate and show the enhanced validation modal
function showValidationModal(correctValue, opts, questionType = "MCQ") {
    // Set modal title based on question type
    const titleIcon = '<i class="fas fa-exclamation-triangle"></i>';
    const titleText = questionType === "Code" ? "Expected Output Mismatch" : "Correct Answer Mismatch";
    document.getElementById("qModalTitle").innerHTML = titleIcon + " " + titleText;

    // Show entered answer
    document.getElementById("qEnteredAnswer").textContent = `"${correctValue}"`;

    // Populate options list
    const optionsList = document.getElementById("qOptionsList");
    optionsList.innerHTML = "";

    opts.forEach((opt, index) => {
        const li = document.createElement("li");
        li.textContent = (index + 1) + ". " + opt;
        optionsList.appendChild(li);
    });

    // Update error summary based on question type
    const summary = document.querySelector("#qValidationModal .error-summary");
    if (questionType === "Code") {
        summary.textContent = "The expected output does not match any of the provided options.";
    } else {
        summary.textContent = "The correct answer does not match any of the provided options.";
    }

    // Show the modal
    document.getElementById("qValidationModal").style.display = "block";
}

// Drag and drop functionality for generic file upload
const questionFileInput = document.getElementById('questionFile');
const fileDropZone = document.getElementById('fileDropZone');

if (questionFileInput && fileDropZone) {
    // Click to browse
    fileDropZone.addEventListener('click', () => {
        questionFileInput.click();
    });
    
    // File input change
    questionFileInput.addEventListener('change', function() {
        if (this.files && this.files[0]) {
            displayFileUploadName(this.files[0]);
        }
    });
    
    // Drag and drop events
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        fileDropZone.addEventListener(eventName, preventFileUploadDefaults, false);
    });
    
    function preventFileUploadDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    ['dragenter', 'dragover'].forEach(eventName => {
        fileDropZone.addEventListener(eventName, highlightFileDrop, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        fileDropZone.addEventListener(eventName, unhighlightFileDrop, false);
    });
    
    function highlightFileDrop() {
        fileDropZone.classList.add('drag-over');
    }
    
    function unhighlightFileDrop() {
        fileDropZone.classList.remove('drag-over');
    }
    
    fileDropZone.addEventListener('drop', handleFileDrop, false);
    
    function handleFileDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        
        if (files.length > 0) {
            const file = files[0];
            const name = file.name.toLowerCase();
            // Check if it's a TXT or PDF file
            if (name.endsWith('.txt') || name.endsWith('.pdf')) {
                // Set the file to the input
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(file);
                questionFileInput.files = dataTransfer.files;
                displayFileUploadName(file);
            } else {
                showToast('error', 'Invalid File Type', 'Only .txt and .pdf files are allowed.');
            }
        }
    }
    
    function displayFileUploadName(file) {
        const nameDisplay = document.getElementById('fileUploadNameDisplay');
        const nameSpan = document.getElementById('uploadFileName');
        const icon = document.getElementById('fileTypeIcon');
        
        nameSpan.textContent = file.name;
        if (file.name.toLowerCase().endsWith('.pdf')) {
            icon.className = 'fas fa-file-pdf';
            icon.style.color = '#dc3545';
        } else {
            icon.className = 'fas fa-file-alt';
            icon.style.color = '#6c757d';
        }
        
        nameDisplay.style.display = 'flex';
        fileDropZone.style.display = 'none';
    }
}

function removeUploadFile() {
    const fileInput = document.getElementById('questionFile');
    const nameDisplay = document.getElementById('fileUploadNameDisplay');
    const dropZone = document.getElementById('fileDropZone');
    
    // Reset file input
    fileInput.value = '';
    
    // Hide file name display and show drop zone
    nameDisplay.style.display = 'none';
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

// Add event listener to the file processing button
const processFileBtn = document.getElementById('processFileBtn');
if (processFileBtn) {
    processFileBtn.addEventListener('click', handleFileUploadAndParsing);
}

// Question form functions
function toggleOptions() {
    const qType = document.getElementById("questionTypeSelect").value;
    const mcq = document.getElementById("mcqOptions");
    const single = document.getElementById("correctAnswerContainer");
    const trueFalse = document.getElementById("trueFalseContainer");
    const multiple = document.getElementById("multipleCorrectContainer");
    const dragDrop = document.getElementById("dragDropOptions");
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
    dragDrop.style.display = "none";
    
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
        
        // Store current option values before disabling
        if (opt1) {
            sessionStorage.setItem('stored_opt1', opt1.value);
            opt1.disabled = true;
        }
        if (opt2) {
            sessionStorage.setItem('stored_opt2', opt2.value);
            opt2.disabled = true;
        }
        if (opt3) {
            sessionStorage.setItem('stored_opt3', opt3.value);
            opt3.disabled = true;
        }
        if (opt4) {
            sessionStorage.setItem('stored_opt4', opt4.value);
            opt4.disabled = true;
        }
        
        // Update correct answer field with selected value if available
        if (trueFalseSelect && trueFalseSelect.value) {
            const correctAnswerField = document.getElementById('correctAnswer');
            if (correctAnswerField) {
                correctAnswerField.value = trueFalseSelect.value;
            }
        }
    } else if (qType === "DRAG_AND_DROP") {
        dragDrop.style.display = "block";
        // Don't require options for drag-drop questions
        if (opt1) opt1.required = false;
        if (opt2) opt2.required = false;
        if (opt3) opt3.required = false;
        if (opt4) opt4.required = false;
        
        // Store current option values before disabling
        if (opt1) {
            sessionStorage.setItem('stored_opt1', opt1.value);
            opt1.disabled = true;
        }
        if (opt2) {
            sessionStorage.setItem('stored_opt2', opt2.value);
            opt2.disabled = true;
        }
        if (opt3) {
            sessionStorage.setItem('stored_opt3', opt3.value);
            opt3.disabled = true;
        }
        if (opt4) {
            sessionStorage.setItem('stored_opt4', opt4.value);
            opt4.disabled = true;
        }
        
        // Initialize drag-drop interface
        updateDragDropTargetOptions();
    } else {
        mcq.style.display = "block";
        if (opt1) opt1.required = true;
        if (opt2) opt2.required = true;
        
        // Enable option fields for non-True/False questions and restore values
        if (opt1) {
            opt1.disabled = false;
            // Restore stored value if it exists
            const storedValue1 = sessionStorage.getItem('stored_opt1');
            if (storedValue1 && opt1.value === '') {
                opt1.value = storedValue1;
            }
        }
        if (opt2) {
            opt2.disabled = false;
            // Restore stored value if it exists
            const storedValue2 = sessionStorage.getItem('stored_opt2');
            if (storedValue2 && opt2.value === '') {
                opt2.value = storedValue2;
            }
        }
        if (opt3) {
            opt3.disabled = false;
            // Restore stored value if it exists
            const storedValue3 = sessionStorage.getItem('stored_opt3');
            if (storedValue3 && opt3.value === '') {
                opt3.value = storedValue3;
            }
        }
        if (opt4) {
            opt4.disabled = false;
            // Restore stored value if it exists
            const storedValue4 = sessionStorage.getItem('stored_opt4');
            if (storedValue4 && opt4.value === '') {
                opt4.value = storedValue4;
            }
        }
        
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
    // Skip this check if questions are being processed from batch session
    const batchQuestions = sessionStorage.getItem('batchQuestions');
    if (batchQuestions) {
        return; // Don't show the prompt during batch processing
    }
    
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

// Smart parsing functions for multi-line input
function parseMultiLineInput(text, sourceField, silent = false) {
    if (!text || !text.trim()) return;
    
    // First, check if the text contains multiple questions
    const multipleQuestions = parseMultipleQuestions(text);
    
    if (multipleQuestions.length > 1) {
        // Handle multiple questions
        addMultipleQuestions(multipleQuestions);
        return;
    }
    
    const lines = text.split('\n').map(line => line.trim()).filter(line => line !== '');
    
    if (sourceField === 'question') {
        // Parse from question textarea using keyword detection
        parseFromQuestionTextarea(lines, silent);
    } else if (sourceField.startsWith('opt')) {
        // Parse from option textarea using keyword detection
        parseFromOptionTextarea(lines, sourceField, silent);
    }
}

function parseFromQuestionTextarea(lines, silent = false) {
    const questionTextarea = document.getElementById('questionTextarea');
    const opt1 = document.getElementById('opt1');
    const opt2 = document.getElementById('opt2');
    const opt3 = document.getElementById('opt3');
    const opt4 = document.getElementById('opt4');
    const correct = document.getElementById('correctAnswer');
    
    // Try simple line-by-line parsing first
    const result = parseSimpleFormat(lines);
    
    if (result.success) {
        // Populate form fields - FIXED MAPPING
        if (result.question) {
            questionTextarea.value = result.question;
        }
        opt1.value = result.options[0] || '';
        opt2.value = result.options[1] || '';
        opt3.value = result.options[2] || '';
        opt4.value = result.options[3] || '';
        correct.value = result.correct || result.options[0] || '';

        // Auto-update question type
        if (result.type) {
            const typeSelect = document.getElementById('questionTypeSelect');
            if (typeSelect) {
                typeSelect.value = result.type;
                if (typeof toggleOptions === 'function') toggleOptions();
            }
        }
        
        // Debug the field values
        console.log('Setting field values:');
        console.log('Question textarea:', questionTextarea.value);
        console.log('Option 1:', opt1.value);
        console.log('Option 2:', opt2.value);
        console.log('Option 3:', opt3.value);
        console.log('Option 4:', opt4.value);
        console.log('Correct Answer:', correct.value);

        // Validate correct answer against options
        const options = result.options.map(opt => opt.trim()).filter(opt => opt !== '');
        const correctVal = result.correct ? result.correct.trim() : '';

        if (correctVal && options.length > 0 && !options.includes(correctVal)) {
            showModal('Correct Answer Mismatch',
                'The parsed correct answer ("' + correctVal + '") does not match any of the provided options.\n\n' +
                'Available options:\n' + options.map((o, i) => (i + 1) + '. ' + o).join('\n') + '\n\n' +
                'Please manually select or correct the correct answer.');
            return;
        }
        
        if (!silent) {
            showModal('Success', 'Question parsed successfully!\n\n' +
                (result.question ? 'Question: ' + result.question + '\n' : '') +
                'Option 1: ' + (result.options[0] || '') + '\n' +
                'Option 2: ' + (result.options[1] || '') + '\n' +
                'Option 3: ' + (result.options[2] || '') + '\n' +
                'Option 4: ' + (result.options[3] || '') + '\n' +
                'Correct: ' + (result.correct || result.options[0] || ''));
        }
        return;
    }
    
    // Fallback to the original complex parsing
    parseComplexFormat(lines, 'question', silent);
}

function parseFromOptionTextarea(lines, sourceOption, silent = false) {
    const opt1 = document.getElementById('opt1');
    const opt2 = document.getElementById('opt2');
    const opt3 = document.getElementById('opt3');
    const opt4 = document.getElementById('opt4');
    const correct = document.getElementById('correctAnswer');
    
    // Try simple line-by-line parsing first
    const result = parseSimpleFormat(lines);
    
    if (result.success) {
        // Populate form fields based on source option
        if (sourceOption === 'opt1') {
            opt1.value = result.options[0] || '';
            opt2.value = result.options[1] || '';
            opt3.value = result.options[2] || '';
            opt4.value = result.options[3] || '';
            correct.value = result.correct || result.options[0] || '';
        } else if (sourceOption === 'opt2') {
            opt2.value = result.options[0] || '';
            opt3.value = result.options[1] || '';
            opt4.value = result.options[2] || '';
            opt1.value = result.options[3] || '';
            correct.value = result.correct || result.options[0] || '';
        }
        
        // Validate correct answer against options
        const options = result.options.map(opt => opt.trim()).filter(opt => opt !== '');
        const correctVal = result.correct ? result.correct.trim() : '';

        if (correctVal && options.length > 0 && !options.includes(correctVal)) {
            showModal('Correct Answer Mismatch',
                'The parsed correct answer ("' + correctVal + '") does not match any of the provided options.\n\n' +
                'Available options:\n' + options.map((o, i) => (i + 1) + '. ' + o).join('\n') + '\n\n' +
                'Please manually select or correct the correct answer.');
            return;
        }

        if (!silent) {
            showModal('Success', 'Options parsed successfully!\n\n' +
                'First Option: ' + (result.options[0] || '') + '\n' +
                'Second Option: ' + (result.options[1] || '') + '\n' +
                'Third Option: ' + (result.options[2] || '') + '\n' +
                'Fourth Option: ' + (result.options[3] || '') + '\n' +
                'Correct Answer: ' + (result.correct || result.options[0] || ''));
        }
        return;
    }
    
    // Fallback to the original complex parsing
    parseComplexFormat(lines, sourceOption, silent);
}

// Simple format parser for common layouts
function parseSimpleFormat(lines) {
    const result = {
        success: false,
        question: '',
        options: ['', '', '', ''],
        correct: '',
        type: 'MCQ'
    };
    
    console.log('=== PARSING START ==='); // Debug log
    console.log('Parsing lines:', lines); // Debug log
    
    // Check for the exact format you mentioned
    if (lines.length >= 5) {
        // Process each line to find options and correct answer
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const lowerLine = line.toLowerCase().trim();
            
            if (lowerLine.startsWith('your question:')) {
                // Extract everything after "Your Question:"
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    result.question = line.substring(colonIndex + 1).trim();
                    console.log('Extracted question:', result.question); // Debug log
                }
            } else if (lowerLine.startsWith('option 1:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    result.options[0] = line.substring(colonIndex + 1).trim();
                    console.log('Option 1:', result.options[0]); // Debug log
                }
            } else if (lowerLine.startsWith('option 2:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    result.options[1] = line.substring(colonIndex + 1).trim();
                    console.log('Option 2:', result.options[1]); // Debug log
                }
            } else if (lowerLine.startsWith('option 3:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    result.options[2] = line.substring(colonIndex + 1).trim();
                    console.log('Option 3:', result.options[2]); // Debug log
                }
            } else if (lowerLine.startsWith('option 4:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    result.options[3] = line.substring(colonIndex + 1).trim();
                    console.log('Option 4:', result.options[3]); // Debug log
                }
            } else if (lowerLine.startsWith('correct answer:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    result.correct = line.substring(colonIndex + 1).trim();
                    console.log('Correct answer:', result.correct); // Debug log
                }
            }
        }
        
        // If we have at least a question or any options, consider it successful
        if (result.question || result.options.some(opt => opt !== '') || result.correct) {
            result.success = true;
            console.log('Parsing successful with question or options'); // Debug log

            // Auto-detect type
            result.type = detectQuestionType(result.question, result.options, result.correct);
            
            // Sanitize correct answer
            if (result.correct) {
                result.correct = sanitizeCorrectAnswer(result);
            }
        }
    }
    
    console.log('Final parsing result:', result); // Debug log
    console.log('=== PARSING END ==='); // Debug log
    return result;
}

// Advanced multi-question parser that can handle multiple structured questions
function parseMultipleQuestions(text) {
    const questions = [];
    const lines = text.split('\n').map(line => line.trim());
    
    let currentQuestion = null;
    let currentSection = '';
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const lowerLine = line.toLowerCase().trim();
        
        // Check if this is the start of a new question
        if (lowerLine.startsWith('your question:')) {
            // Save the previous question if it exists
            if (currentQuestion && (currentQuestion.question || currentQuestion.options.some(opt => opt))) {
                questions.push({...currentQuestion});
            }
            
            // Start a new question
            currentQuestion = {
                question: line.substring(line.indexOf(':') + 1).trim(),
                options: ['', '', '', ''],
                correct: '',
                type: 'MCQ'
            };
            currentSection = 'question';
        } else if (currentQuestion && lowerLine.startsWith('option 1:')) {
            currentQuestion.options[0] = line.substring(line.indexOf(':') + 1).trim();
            currentSection = 'option1';
        } else if (currentQuestion && lowerLine.startsWith('option 2:')) {
            currentQuestion.options[1] = line.substring(line.indexOf(':') + 1).trim();
            currentSection = 'option2';
        } else if (currentQuestion && lowerLine.startsWith('option 3:')) {
            currentQuestion.options[2] = line.substring(line.indexOf(':') + 1).trim();
            currentSection = 'option3';
        } else if (currentQuestion && lowerLine.startsWith('option 4:')) {
            currentQuestion.options[3] = line.substring(line.indexOf(':') + 1).trim();
            currentSection = 'option4';
        } else if (currentQuestion && lowerLine.startsWith('correct answer:')) {
            currentQuestion.correct = line.substring(line.indexOf(':') + 1).trim();
            currentSection = 'correct';
        } else if (line && currentQuestion && !lowerLine.startsWith('your question:') && 
                 !lowerLine.startsWith('option 1:') && !lowerLine.startsWith('option 2:') && 
                 !lowerLine.startsWith('option 3:') && !lowerLine.startsWith('option 4:') && 
                 !lowerLine.startsWith('correct answer:')) {
            
            // Handle multi-line content for current section
            if (currentSection === 'question') {
                currentQuestion.question += ' ' + line;
            } else if (currentSection === 'option1') {
                currentQuestion.options[0] += ' ' + line;
            } else if (currentSection === 'option2') {
                currentQuestion.options[1] += ' ' + line;
            } else if (currentSection === 'option3') {
                currentQuestion.options[2] += ' ' + line;
            } else if (currentSection === 'option4') {
                currentQuestion.options[3] += ' ' + line;
            } else if (currentSection === 'correct') {
                currentQuestion.correct += ' ' + line;
            }
        }
    }
    
    // Add the last question if it exists
    if (currentQuestion && (currentQuestion.question || currentQuestion.options.some(opt => opt))) {
        questions.push({...currentQuestion});
    }
    
    // Auto-detect question types and sanitize correct answers
    questions.forEach(q => {
        // Sanitize options (remove empty strings)
        q.options = q.options.map(opt => opt ? opt.trim() : '');
        
        // Auto-detect type
        q.type = detectQuestionType(q.question, q.options, q.correct);
        
        // Sanitize correct answer
        if (q.correct) {
            q.correct = sanitizeCorrectAnswer(q);
        }
    });

    console.log('Parsed multiple questions:', questions);
    return questions;
}

// Helper to sanitize correct answer during parsing
function sanitizeCorrectAnswer(q) {
    if (!q || !q.correct) return "";
    const correctText = q.correct.trim();
    const options = (q.options || []).map(opt => opt ? opt.trim() : "");
    
    // If it's a MultipleSelect question or contains pipes, process parts separately
    if (correctText.includes('|')) {
        const parts = correctText.split('|').map(p => p.trim()).filter(p => p !== "");
        const sanitizedParts = parts.map(part => {
            return sanitizeSingleAnswer(part, options);
        });
        return [...new Set(sanitizedParts)].join('|');
    }
    
    return sanitizeSingleAnswer(correctText, options);
}

/**
 * Internal helper to sanitize a single answer string against options
 */
function sanitizeSingleAnswer(answerText, options) {
    if (!answerText) return "";
    const text = answerText.trim();
    
    // 1. Check for exact match
    if (options.includes(text)) return text;
    
    // 2. Check for "Option X: text" format
    const optionMatch = text.match(/Option\s+(\d+)[:\s]*(.*)/i);
    if (optionMatch) {
        const index = parseInt(optionMatch[1]) - 1;
        const textAfterPrefix = optionMatch[2].trim();
        
        if (index >= 0 && index < options.length && options[index]) {
            if (!textAfterPrefix || options[index].includes(textAfterPrefix) || textAfterPrefix.includes(options[index])) {
                return options[index];
            }
        }
    }
    
    // 3. Check for single number (1-4)
    if (text.length === 1 && !isNaN(text)) {
        const num = parseInt(text);
        if (num >= 1 && num <= 4 && options[num-1]) return options[num-1];
    }
    
    // 4. Fuzzy match
    for (let opt of options) {
        const trimmedOpt = opt ? opt.trim() : "";
        if (trimmedOpt && trimmedOpt.length > 2) {
            if (text.toLowerCase() === trimmedOpt.toLowerCase()) return trimmedOpt;
            if (text.toLowerCase().includes(trimmedOpt.toLowerCase()) || trimmedOpt.toLowerCase().includes(text.toLowerCase())) {
                return trimmedOpt;
            }
        }
    }
    
    return text;
}

// Modal for displaying and editing multiple questions
function showMultipleQuestionsModal(questions) {
    // Create modal HTML dynamically
    let modalHtml = `
        <div id="multipleQuestionsModal" class="modal" style="display: block; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4);">
            <div class="modal-content batch-modal-content" style="background-color: #fefefe; margin: 2% auto; padding: 20px; border: 1px solid #888; border-radius: 8px;">
                <div class="modal-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid #eee;">
                    <h3 style="margin: 0; color: #333;">
                        <i class="fas fa-list"></i> Review Parsed Questions (${questions.length})
                    </h3>
                    <span class="close-modal" onclick="closeMultipleQuestionsModal()" style="font-size: 28px; font-weight: bold; cursor: pointer; color: #aaa;">&times;</span>
                </div>
                <div class="modal-body" style="padding: 0;">
                    <p style="padding: 10px 0;">Please review and edit the parsed questions below. Click "Add All Questions" to start batch processing.</p>
                    <div style="max-height: 60vh; overflow-y: auto; border: 1px solid var(--medium-gray); border-radius: 4px;">
                        <table class="batch-review-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th style="width: 30%;">Question Text</th>
                                    <th style="width: 35%;">Options</th>
                                    <th style="width: 20%;">Correct Answer</th>
                                    <th style="width: 10%;">Type</th>
                                </tr>
                            </thead>
                            <tbody id="batchQuestionsTableBody">
    `;
    
    // Add each question to the table
    questions.forEach((q, index) => {
        const matchStatus = getMatchStatus(q);
        modalHtml += `
            <tr data-index="${index}">
                <td>${index + 1}</td>
                <td>
                    <textarea class="batch-row-edit" oninput="updateBatchQuestion(${index}, 'question', this.value)" rows="3">${q.question}</textarea>
                </td>
                <td>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 5px;">
                        <input type="text" class="batch-row-edit" value="${q.options[0] || ''}" placeholder="Opt 1" oninput="updateBatchQuestion(${index}, 'opt0', this.value)">
                        <input type="text" class="batch-row-edit" value="${q.options[1] || ''}" placeholder="Opt 2" oninput="updateBatchQuestion(${index}, 'opt1', this.value)">
                        <input type="text" class="batch-row-edit" value="${q.options[2] || ''}" placeholder="Opt 3" oninput="updateBatchQuestion(${index}, 'opt2', this.value)">
                        <input type="text" class="batch-row-edit" value="${q.options[3] || ''}" placeholder="Opt 4" oninput="updateBatchQuestion(${index}, 'opt3', this.value)">
                    </div>
                </td>
                <td>
                    <input type="text" class="batch-row-edit" value="${q.correct}" oninput="updateBatchQuestion(${index}, 'correct', this.value)">
                    <div id="match-indicator-${index}" class="match-indicator ${matchStatus.isValid ? 'match-success' : 'match-error'}" style="margin-top: 5px;">
                        <i class="fas ${matchStatus.isValid ? 'fa-check-circle' : 'fa-exclamation-triangle'}"></i>
                        <span>${matchStatus.message}</span>
                    </div>
                </td>
                <td>
                    <select class="batch-row-edit" onchange="updateBatchQuestion(${index}, 'type', this.value)">
                        <option value="MCQ" ${q.type === 'MCQ' ? 'selected' : ''}>MCQ</option>
                        <option value="TrueFalse" ${q.type === 'TrueFalse' ? 'selected' : ''}>T/F</option>
                        <option value="MultipleSelect" ${q.type === 'MultipleSelect' ? 'selected' : ''}>Multi</option>
                        <option value="Code" ${q.type === 'Code' ? 'selected' : ''}>Code</option>
                    </select>
                </td>
            </tr>
        `;
    });
    
    modalHtml += `
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 10px; padding-top: 15px; border-top: 1px solid #eee;">
                    <button type="button" onclick="closeMultipleQuestionsModal()" class="btn btn-outline">Cancel</button>
                    <button type="button" onclick="processAllQuestions()" class="btn btn-primary">
                        <i class="fas fa-plus-circle"></i> Add All Questions
                    </button>
                </div>
            </div>
        </div>
    `;
    
    // Store current working questions globally for the modal
    window.currentBatchQuestions = JSON.parse(JSON.stringify(questions));
    
    // Insert modal into body
    document.body.insertAdjacentHTML('beforeend', modalHtml);
}

function getMatchStatus(q) {
    if (!q.correct) return { isValid: false, message: 'Missing answer' };
    
    const options = q.options.filter(opt => opt && opt.trim() !== '').map(opt => opt.trim());
    if (q.type === 'MCQ' || q.type === 'Code') {
        const match = options.some(opt => opt === q.correct.trim());
        return match ? { isValid: true, message: 'Matches option' } : { isValid: false, message: 'No match' };
    } else if (q.type === 'MultipleSelect') {
        const correctParts = q.correct.split('|').map(p => p.trim());
        const matchCount = correctParts.filter(p => options.includes(p)).length;
        return matchCount === 2 ? { isValid: true, message: 'Matches 2 options' } : { isValid: false, message: `Matches ${matchCount}/2` };
    } else if (q.type === 'TrueFalse') {
        const isValid = ['true', 'false'].includes(q.correct.toLowerCase());
        return isValid ? { isValid: true, message: 'Valid T/F' } : { isValid: false, message: 'Invalid T/F' };
    }
    return { isValid: true, message: 'Ready' };
}

function updateBatchQuestion(index, field, value) {
    const q = window.currentBatchQuestions[index];
    if (field === 'question') q.question = value;
    else if (field === 'correct') q.correct = value;
    else if (field === 'type') q.type = value;
    else if (field.startsWith('opt')) {
        const optIndex = parseInt(field.substring(3));
        q.options[optIndex] = value;
    }
    
    // Update match indicator
    const matchStatus = getMatchStatus(q);
    const indicator = document.getElementById(`match-indicator-${index}`);
    if (indicator) {
        indicator.className = `match-indicator ${matchStatus.isValid ? 'match-success' : 'match-error'}`;
        indicator.innerHTML = `<i class="fas ${matchStatus.isValid ? 'fa-check-circle' : 'fa-exclamation-triangle'}"></i> <span>${matchStatus.message}</span>`;
    }
}

// Function to close the multiple questions modal
function closeMultipleQuestionsModal() {
    const modal = document.getElementById('multipleQuestionsModal');
    if (modal) {
        modal.remove();
    }
    window.currentBatchQuestions = null;
}

// Function to process all questions
function processAllQuestions() {
    const questions = window.currentBatchQuestions;
    if (!questions || questions.length === 0) return;

    // Close the modal
    closeMultipleQuestionsModal();
    
    // Store all questions for batch processing
    sessionStorage.setItem('batchQuestions', JSON.stringify(questions));
    sessionStorage.setItem('batchTotal', questions.length.toString());
    sessionStorage.setItem('batchCurrentIndex', '0');
    
    startBatchProcessing();
}

function startBatchProcessing() {
    const questions = JSON.parse(sessionStorage.getItem('batchQuestions') || '[]');
    const index = parseInt(sessionStorage.getItem('batchCurrentIndex') || '0');
    
    if (index < questions.length) {
        // Show progress card
        updateBatchProgressUI(index, questions.length);
        
        // Load the question into the form
        loadQuestionIntoForm(questions[index]);
        
        showToast('info', 'Batch Processing Started', `Loaded first question. ${questions.length} total questions queued.`);
        
        // Scroll to the add question panel
        document.getElementById('addQuestionPanel').scrollIntoView({ behavior: 'smooth' });
        document.getElementById('addQuestionPanel').classList.add('form-highlight');
        setTimeout(() => document.getElementById('addQuestionPanel').classList.remove('form-highlight'), 2000);
    }
}

function updateBatchProgressUI(index, total) {
    const card = document.getElementById('batchProgressCard');
    const text = document.getElementById('batchProgressText');
    const percentText = document.getElementById('batchPercentageText');
    const bar = document.getElementById('batchProgressBar');
    
    if (card) {
        card.style.display = 'block';
        const current = index + 1;
        const percent = Math.round((index / total) * 100);
        
        text.textContent = `Question ${current} of ${total}`;
        percentText.textContent = `${percent}%`;
        bar.style.width = `${percent}%`;
        
        if (index === 0) {
            document.getElementById('batchStatusHint').textContent = "Submit this question to automatically load the next one.";
        } else {
            document.getElementById('batchStatusHint').textContent = `Successfully added ${index} questions. Processing remaining...`;
        }
    }
}

function loadQuestionIntoForm(q) {
    const questionTextarea = document.getElementById('questionTextarea');
    const typeSelect = document.getElementById('questionTypeSelect');
    
    // Clear existing image if any
    if (typeof removeImageFile === 'function') removeImageFile();
    
    const opt1 = document.getElementById('opt1');
    const opt2 = document.getElementById('opt2');
    const opt3 = document.getElementById('opt3');
    const opt4 = document.getElementById('opt4');
    const correct = document.getElementById('correctAnswer');
    const tfSelect = document.getElementById('trueFalseSelect');
    
    if (questionTextarea) questionTextarea.value = q.question;
    if (typeSelect) {
        typeSelect.value = q.type;
        toggleOptions(); // Update UI for the type
    }
    
    if (q.type === 'TrueFalse') {
        if (tfSelect) tfSelect.value = (q.correct.toLowerCase() === 'true' ? 'True' : (q.correct.toLowerCase() === 'false' ? 'False' : ''));
        if (correct) correct.value = tfSelect.value;
    } else if (q.type === 'MultipleSelect') {
        const correctParts = q.correct.split('|').map(p => p.trim());
        if (opt1) opt1.value = q.options[0] || '';
        if (opt2) opt2.value = q.options[1] || '';
        if (opt3) opt3.value = q.options[2] || '';
        if (opt4) opt4.value = q.options[3] || '';
        
        // Update checkbox values and labels immediately
        updateCorrectOptionLabels();
        
        // Delay a bit to let the DOM update
        setTimeout(() => {
            document.querySelectorAll('.correct-checkbox').forEach((cb, idx) => {
                const optVal = q.options[idx] || '';
                // Set the checkbox value to the actual option text
                cb.value = optVal;
                cb.checked = optVal && correctParts.includes(optVal);
            });
            updateCorrectAnswerField();
        }, 50);
    } else {
        if (opt1) opt1.value = q.options[0] || '';
        if (opt2) opt2.value = q.options[1] || '';
        if (opt3) opt3.value = q.options[2] || '';
        if (opt4) opt4.value = q.options[3] || '';
        if (correct) correct.value = q.correct || '';
    }
    
    // Trigger any other UI updates
    updateCorrectOptionLabels();
}

function cancelBatch() {
    showBatchCancelModal();
}

// Enhanced submit handler to support batch processing
function initBatchSubmitHandling() {
    // Check if we should resume a batch on page load
    const batchQuestions = JSON.parse(sessionStorage.getItem('batchQuestions') || '[]');
    const index = parseInt(sessionStorage.getItem('batchCurrentIndex') || '-1');
    if (index !== -1 && index < batchQuestions.length) {
        updateBatchProgressUI(index, batchQuestions.length);
        loadQuestionIntoForm(batchQuestions[index]);
    }
}

async function submitCurrentBatchQuestion() {
    const form = document.getElementById('addQuestionForm');
    const submitBtn = document.getElementById('submitBtn');
    const originalBtnHtml = submitBtn.innerHTML;
    
    // Visual feedback
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding Question...';
    
    try {
        const formData = new FormData(form);
        formData.append('ajax', 'true'); // Tell controller we want JSON
        
        const response = await fetch(form.action, {
            method: 'POST',
            body: formData
        });
        
        let result;
        const contentType = response.headers.get("content-type");
        if (contentType && contentType.indexOf("application/json") !== -1) {
            result = await response.json();
        } else {
            // Fallback for non-JSON response (redirects, etc.)
            const text = await response.text();
            if (text.includes("Success") || response.redirected || response.url.includes("success")) {
                result = { success: true, message: "Question added successfully" };
            } else {
                result = { success: false, message: "Error adding question" };
            }
        }
        
        if (result.success) {
            const questions = JSON.parse(sessionStorage.getItem('batchQuestions') || '[]');
            let nextIndex = parseInt(sessionStorage.getItem('batchCurrentIndex') || '0') + 1;
            
            if (nextIndex < questions.length) {
                // More questions to process
                sessionStorage.setItem('batchCurrentIndex', nextIndex.toString());
                updateBatchProgressUI(nextIndex, questions.length);
                loadQuestionIntoForm(questions[nextIndex]);
                showToast('success', 'Question Added', `Question ${nextIndex} added. Loaded next one.`);
                
                // Clear question fields but keep course/type if needed
                // (loadQuestionIntoForm already handles population)
            } else {
                // Batch complete
                const total = sessionStorage.getItem('batchTotal');
                sessionStorage.removeItem('batchQuestions');
                sessionStorage.removeItem('batchTotal');
                sessionStorage.removeItem('batchCurrentIndex');
                
                document.getElementById('batchProgressCard').style.display = 'none';
                showToast('success', 'Batch Complete', `All ${total} questions added successfully!`);
                resetForm();
                
                // Show a final success modal or redirect to showall
                showBatchCompleteModal();
            }
        } else {
            showToast('error', 'Error', result.message || "Failed to add question. Please check the form and try again.");
        }
    } catch (error) {
        console.error('Batch Submission Error:', error);
        showToast('error', 'Connection Error', 'Failed to communicate with the server.');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalBtnHtml;
    }
}

// Function to add multiple questions to the form
function addMultipleQuestions(questions) {
    if (questions.length === 0) return;
    
    if (questions.length > 1) {
        // Show modal with all questions if there are multiple
        showMultipleQuestionsModal(questions);
    } else {
        // Process single question directly
        const firstQuestion = questions[0];
        
        // Populate the current form
        const questionTextarea = document.getElementById('questionTextarea');
        const opt1 = document.getElementById('opt1');
        const opt2 = document.getElementById('opt2');
        const opt3 = document.getElementById('opt3');
        const opt4 = document.getElementById('opt4');
        const correct = document.getElementById('correctAnswer');
        
        if (questionTextarea) questionTextarea.value = firstQuestion.question;
        if (opt1) opt1.value = firstQuestion.options[0];
        if (opt2) opt2.value = firstQuestion.options[1];
        if (opt3) opt3.value = firstQuestion.options[2];
        if (opt4) opt4.value = firstQuestion.options[3];
        if (correct) correct.value = firstCorrectAnswer(firstQuestion);
        
        showToast('success', 'Success', `Processed 1 question successfully.`);
    }
}

/**
 * Auto-detects the question type based on content, options, and correct answer.
 */
function detectQuestionType(question, options, correct) {
    const qText = (question || "").toLowerCase();
    const cVal = (correct || "").trim().toLowerCase();
    const opts = (options || []).filter(o => o && o.trim() !== '');
    
    // 1. Detect Code Snippet
    const codeKeywords = /(?:def |function |public |class |print\(|console\.|<[^>]*>|\{|\}|import |int |String |printf\(|cout |output of the code|following code|code snippet)/i;
    if (codeKeywords.test(question) || (question && question.includes('\n') && question.split('\n').filter(l => l.trim()).length > 3)) {
        return 'Code';
    } 
    // 2. Detect True/False
    if (cVal === 'true' || cVal === 'false' || (opts.length === 2 && (opts.some(o => o.toLowerCase() === 'true') || opts.some(o => o.toLowerCase() === 'false')))) {
        return 'TrueFalse';
    } 
    // 3. Detect Multiple Select
    if ((correct && correct.includes('|')) || qText.includes('(select two)') || qText.includes('(select 2)') || qText.includes('(select all)') || qText.includes('(select all that apply)')) {
        return 'MultipleSelect';
    } 
    // 4. Default to MCQ
    return 'MCQ';
}

// Re-using sanitizeCorrectAnswer as the primary sanitization logic
function firstCorrectAnswer(question) {
    return sanitizeCorrectAnswer(question);
}

// Complex format parser (fallback) - Improved version
function parseComplexFormat(lines, sourceField, silent = false) {
    const questionTextarea = document.getElementById('questionTextarea');
    const opt1 = document.getElementById('opt1');
    const opt2 = document.getElementById('opt2');
    const opt3 = document.getElementById('opt3');
    const opt4 = document.getElementById('opt4');
    const correct = document.getElementById('correctAnswer');
    
    // Process each line to find options and correct answer
    let questionText = '';
    let option1 = '';
    let option2 = '';
    let option3 = '';
    let option4 = '';
    let correctAnswer = '';

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const lowerLine = line.toLowerCase().trim();
        
        if (lowerLine.startsWith('your question:')) {
            const colonIndex = line.indexOf(':');
            if (colonIndex > -1) {
                questionText = line.substring(colonIndex + 1).trim();
            }
        } else if (lowerLine.startsWith('option 1:')) {
            const colonIndex = line.indexOf(':');
            if (colonIndex > -1) {
                option1 = line.substring(colonIndex + 1).trim();
            }
        } else if (lowerLine.startsWith('option 2:')) {
            const colonIndex = line.indexOf(':');
            if (colonIndex > -1) {
                option2 = line.substring(colonIndex + 1).trim();
            }
        } else if (lowerLine.startsWith('option 3:')) {
            const colonIndex = line.indexOf(':');
            if (colonIndex > -1) {
                option3 = line.substring(colonIndex + 1).trim();
            }
        } else if (lowerLine.startsWith('option 4:')) {
            const colonIndex = line.indexOf(':');
            if (colonIndex > -1) {
                option4 = line.substring(colonIndex + 1).trim();
            }
        } else if (lowerLine.startsWith('correct answer:')) {
            const colonIndex = line.indexOf(':');
            if (colonIndex > -1) {
                correctAnswer = line.substring(colonIndex + 1).trim();
            }
        }
    }
    
    // Populate form fields
    if (questionText || option1 || option2 || option3 || option4) {
        if (questionText && sourceField === 'question') {
            questionTextarea.value = questionText;
        }
        if (option1) opt1.value = option1;
        if (option2) opt2.value = option2;
        if (option3) opt3.value = option3;
        if (option4) opt4.value = option4;
        if (correctAnswer) correct.value = correctAnswer;

        // Auto-detect and sanitize
        const optionsArray = [option1, option2, option3, option4];
        const detectedType = detectQuestionType(questionText, optionsArray, correctAnswer);
        const sanitizedCorrect = sanitizeCorrectAnswer({ correct: correctAnswer, options: optionsArray });
        
        if (sanitizedCorrect) {
            correct.value = sanitizedCorrect;
        }

        const typeSelect = document.getElementById('questionTypeSelect');
        if (typeSelect) {
            typeSelect.value = detectedType;
            if (typeof toggleOptions === 'function') toggleOptions();
        }
        
        // Validate correct answer against options
        const opts = [option1, option2, option3, option4].map(opt => opt.trim()).filter(opt => opt !== '');
        const correctVal = correctAnswer ? correctAnswer.trim() : '';

        if (correctVal && opts.length > 0 && !opts.includes(correctVal)) {
            showModal('Correct Answer Mismatch',
                'The parsed correct answer ("' + correctVal + '") does not match any of the provided options.\n\n' +
                'Available options:\n' + opts.map((o, i) => (i + 1) + '. ' + o).join('\n') + '\n\n' +
                'Please manually select or correct the correct answer.');
            return;
        }

        if (!silent) {
            showModal('Success', 'Question parsed successfully!\n\n' +
                (questionText ? 'Question: ' + questionText + '\n' : '') +
                'Option 1: ' + option1 + '\n' +
                'Option 2: ' + option2 + '\n' +
                'Option 3: ' + option3 + '\n' +
                'Option 4: ' + option4 + '\n' +
                'Correct: ' + correctAnswer);
        }
    }
}



// Function to check if text contains parsing patterns
function containsParsingPatterns(text) {
    const lines = text.split('\n').map(line => line.trim()).filter(line => line !== '');

    // Check for function name patterns
    const functionPatterns = ['input()', 'read()', 'get()', 'scan()'];
    let hasFunctionPatterns = false;

    lines.forEach(line => {
        functionPatterns.forEach(pattern => {
            if (line.toLowerCase().includes(pattern.toLowerCase())) {
                hasFunctionPatterns = true;
            }
        });
    });

    // Check for question patterns - more flexible
    const questionPatterns = [
        /what.*question/i,
        /what.*function/i,
        /what.*correct/i,
        /what.*way/i,
        /your.*question/i,
        /question:/i,
        /q:/i,
        /option\s*[:\-]?\s*?/i,
        /correct\s*[:\-]?\s*answer/i
    ];

    const hasQuestionPattern = lines.some(line =>
        questionPatterns.some(pattern => pattern.test(line))
    );

    // Check for arrow patterns (?)
    const hasArrowPattern = lines.some(line => line.includes('?'));

    // Check for colon patterns with option keywords
    const optionKeywords = ['first option', 'second option', 'third option', 'fourth option', 'option 1', 'option 2', 'option 3', 'option 4'];
    const hasOptionPattern = lines.some(line =>
        optionKeywords.some(keyword => line.toLowerCase().includes(keyword.toLowerCase()))
    );
    
    // NEW: Check for structured question format with "Your Question:", "Option X:", "Correct Answer:" pattern
    const hasStructuredFormat = lines.some(line => 
        line.match(/^(Your Question|Option \d+|Correct Answer):/i)
    );
    
    // NEW: Check if there are at least 3 lines with colon-separated values (likely question/options format)
    const colonSeparatedLines = lines.filter(line => line.includes(':')).length;
    const hasColonFormat = colonSeparatedLines >= 3;
    
    // NEW: Check for multiple questions pattern
    const questionCount = lines.filter(line => line.toLowerCase().startsWith('your question:')).length;
    const hasMultipleQuestions = questionCount > 1;
    
    console.log('Parsing pattern detection:', {
        hasFunctionPatterns,
        hasQuestionPattern,
        hasArrowPattern,
        hasOptionPattern,
        hasStructuredFormat,
        hasColonFormat,
        hasMultipleQuestions,
        questionCount,
        lines
    });
    
    return hasFunctionPatterns || hasQuestionPattern || hasArrowPattern || hasOptionPattern || hasStructuredFormat || hasColonFormat || hasMultipleQuestions;
}

function initializeSmartParsing() {
    const questionTextarea = document.getElementById('questionTextarea');
    const opt1 = document.getElementById('opt1');
    const opt2 = document.getElementById('opt2');
    const opt3 = document.getElementById('opt3');
    const opt4 = document.getElementById('opt4');
    
    // Store timeout references
    let questionTimeout = null;
    let optTimeouts = [null, null, null, null];
    
    // Function to clear and set timeout
    function setParseTimeout(textarea, sourceField, timeoutRef) {
        // Clear existing timeout
        if (timeoutRef) {
            clearTimeout(timeoutRef);
        }
        
        // Set new timeout for 1 second for better responsiveness
        timeoutRef = setTimeout(() => {
            const text = textarea.value.trim();
            if (text) {
                // Check if text contains parsing patterns
                if (containsParsingPatterns(text)) {
                    parseMultiLineInput(text, sourceField, true); // Silent parsing
                }
            }
        }, 1000); // 1 second
        
        return timeoutRef;
    }
    
    // Add event listeners for automatic parsing
    if (questionTextarea) {
        questionTextarea.addEventListener('input', function() {
            // Show parse button when there's content
            const parseBtn = document.getElementById('parseQuestionBtn');
            if (parseBtn) {
                parseBtn.style.display = this.value.trim() ? 'inline-block' : 'none';
            }
            questionTimeout = setParseTimeout(this, 'question', questionTimeout);
        });

        questionTextarea.addEventListener('paste', function() {
            // Show parse button when there's content
            const parseBtn = document.getElementById('parseQuestionBtn');
            if (parseBtn) {
                parseBtn.style.display = this.value.trim() ? 'inline-block' : 'none';
            }
            // Give a moment for paste to complete
            setTimeout(() => {
                questionTimeout = setParseTimeout(this, 'question', questionTimeout);
            }, 100);
        });
        
        // Add manual parse button event listener
        const parseBtn = document.getElementById('parseQuestionBtn');
        if (parseBtn) {
            parseBtn.addEventListener('click', function() {
                const text = questionTextarea.value.trim();
                if (text && containsParsingPatterns(text)) {
                    parseMultiLineInput(text, 'question', false); // Non-silent parsing with success message
                    showToast('success', 'Parsing Complete', 'Question parsed successfully!');
                } else {
                    showToast('warning', 'No Parseable Content', 'No structured question format detected. Please use the format shown in the placeholder.');
                }
            });
        }
    }

    // Add event listeners for option textareas
    [opt1, opt2, opt3, opt4].forEach((opt, index) => {
        if (opt) {
            opt.addEventListener('input', function() {
                optTimeouts[index] = setParseTimeout(this, 'opt' + (index + 1), optTimeouts[index]);
            });

            opt.addEventListener('paste', function() {
                // Give a moment for paste to complete
                setTimeout(() => {
                    optTimeouts[index] = setParseTimeout(this, 'opt' + (index + 1), optTimeouts[index]);
                }, 100);
            });
        }
    });
}

function updateCorrectOptionLabels() {
    for (let i = 1; i <= 4; i++) {
        const optInput = document.getElementById(`opt${i}`);
        const checkbox = document.getElementById(`correctOpt${i}`);
        const label = document.querySelector(`label[for="correctOpt${i}"]`);

        if (optInput && checkbox && label) {
            // Initialize checkbox value and label
            const value = optInput.value.trim();
            label.textContent = value || `Option ${i}`;
            checkbox.value = value;
            checkbox.disabled = !value;
            
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
    const selectedAnswers = [];
    document.querySelectorAll('.correct-checkbox:checked').forEach(cb => {
        // Get the associated option input to get the actual text
        const checkboxId = cb.id;
        const optionNum = checkboxId.replace('correctOpt', '');
        const optionInput = document.getElementById(`opt${optionNum}`);
        if (optionInput && optionInput.value.trim()) {
            selectedAnswers.push(optionInput.value.trim());
        } else if (cb.value && cb.value !== 'on') {
            selectedAnswers.push(cb.value.trim());
        }
    });
    // Filter out any "on" values that might have slipped in and join
    const filteredAnswers = selectedAnswers.filter(ans => ans && ans.toLowerCase() !== 'on');
    document.getElementById('correctAnswer').value = filteredAnswers.join('|');
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
    initializeSmartParsing(); // Initialize smart parsing functionality
    initializeMultipleSelectCheckboxes();
    initializeTrueFalseSelection(); // Initialize True/False dropdown event handler
    
    // Initialize batch processing functionality
    initBatchSubmitHandling();
    
    // Initialize orientation preview
    initOrientationPreview();
    
    // Initialize drop target input event listeners for immediate updates
    const existingDropTargetInputs = document.querySelectorAll('#dropTargetsContainer input[type="text"]');
    existingDropTargetInputs.forEach(input => {
        input.addEventListener('input', updateDragDropTargetOptions);
        input.addEventListener('change', updateDragDropTargetOptions);
    });
    
    // Add form submission handler
    const addQuestionForm = document.getElementById('addQuestionForm');
    if (addQuestionForm) {
        addQuestionForm.addEventListener('submit', function(e) {
            // Trigger immediate parsing if there's content in the question textarea
            const questionTextarea = document.getElementById('questionTextarea');
            if (questionTextarea && questionTextarea.value.trim()) {
                const text = questionTextarea.value.trim();
                // Check if text contains parsing patterns
                if (containsParsingPatterns(text)) {
                    // Parse immediately to ensure content is processed before validation
                    const lines = text.split('\n').map(line => line.trim()).filter(line => line !== '');
                    parseFromQuestionTextarea(lines, true); // Silent parsing
                }
            }
            
            // Check if question suggests code snippet type immediately after parsing
            checkForCodeSnippet();

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
                } else {
                    // Ensure the correct answer field is updated before submission
                    updateCorrectAnswerField();
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
                                // Use the enhanced modal instead of error message
                                showValidationModal(correctValue, opts, qType);
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
                    } else {
                        // Also validate that the expected output matches one of the options
                        const opt1 = document.getElementById('opt1').value.trim();
                        const opt2 = document.getElementById('opt2').value.trim();
                        const opt3 = document.getElementById('opt3').value.trim();
                        const opt4 = document.getElementById('opt4').value.trim();
                        const opts = [opt1, opt2, opt3, opt4].filter(Boolean);
                        
                        if (opts.length >= 2 && !opts.includes(correctValue)) {
                            // Use the enhanced modal for Code question validation
                            showValidationModal(correctValue, opts, qType);
                            isValid = false;
                        }
                    }
                } else if (qType === "DRAG_AND_DROP") {
                    // For Drag and Drop questions, validate that drag items and drop targets are provided
                    const dragItems = document.querySelectorAll('#dragItemsContainer textarea');
                    const dropTargets = document.querySelectorAll('#dropTargetsContainer textarea');
                    
                    let hasValidDragItem = false;
                    let hasValidDropTarget = false;
                    
                    dragItems.forEach(input => {
                        if (input.value.trim()) hasValidDragItem = true;
                    });
                    
                    dropTargets.forEach(input => {
                        if (input.value.trim()) hasValidDropTarget = true;
                    });
                    
                    if (!hasValidDragItem || !hasValidDropTarget) {
                        errorMsg = "Please add at least one draggable item and one drop target.";
                        isValid = false;
                    }
                }
                // True/False validation is handled separately above
            }
            
            if (!isValid) {
                e.preventDefault();
                // For validation errors that show modal, don't show toast
                if (errorMsg) {
                    showToast('error', 'Validation Error', errorMsg);
                }
                // Modal is handled separately in the validation logic
            } else {
                // If form is valid, check if there is an active batch
                const batchQuestions = JSON.parse(sessionStorage.getItem('batchQuestions') || '[]');
                const index = parseInt(sessionStorage.getItem('batchCurrentIndex') || '-1');
                
                if (index !== -1 && index < batchQuestions.length) {
                    e.preventDefault();
                    submitCurrentBatchQuestion();
                }
            }
        });
    }
    
    // Close modal when clicking outside
    window.onclick = (event) => {
        const modal = document.getElementById('qValidationModal');
        if (event.target == modal) closeModal();
        
        // Also close multiple questions modal if clicked outside
        const multiModal = document.getElementById('multipleQuestionsModal');
        if (multiModal && event.target == multiModal) closeMultipleQuestionsModal();
        
        // Also close batch complete modal if clicked outside
        const batchModal = document.getElementById('batchCompleteModal');
        if (batchModal && event.target == batchModal) closeBatchCompleteModal();
        
        // Also close batch cancel modal if clicked outside
        const batchCancelModal = document.getElementById('batchCancelModal');
        if (batchCancelModal && event.target == batchCancelModal) closeBatchCancelModal();
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

// Drag and Drop Interface Functions
let dragItemIndex = 0;
let dropTargetIndex = 0;

function autoResize(textarea) {
    textarea.style.height = 'auto';
    textarea.style.height = textarea.scrollHeight + 'px';
}

function addDragItem() {
    const container = document.getElementById('dragItemsContainer');
    const newIndex = ++dragItemIndex;
    
    const itemRow = document.createElement('div');
    itemRow.className = 'drag-item-row';
    itemRow.setAttribute('data-item-index', newIndex);
    itemRow.draggable = true;
    
    itemRow.addEventListener('dragstart', handleQuestionRowDragStart);
    itemRow.addEventListener('dragover', handleQuestionRowDragOver);
    itemRow.addEventListener('drop', handleQuestionRowDrop);
    itemRow.addEventListener('dragend', handleQuestionRowDragEnd);
    
    itemRow.innerHTML = `
        <i class="fas fa-grip-vertical mr-2 text-muted drag-handle"></i>
        <textarea name="dragItem_text_${newIndex}" class="form-control" rows="1" placeholder="Enter draggable item text" oninput="autoResize(this)"></textarea>
        <select name="dragItem_target_${newIndex}" class="form-select">
            <option value="">Select correct target</option>
        </select>
        <button type="button" class="btn btn-outline btn-sm" onclick="removeDragItem(this)">Remove</button>
    `;
    
    container.appendChild(itemRow);
    updateDragDropTargetOptions();
}

function removeDragItem(button) {
    const itemRow = button.closest('.drag-item-row');
    itemRow.remove();
    updateDragDropTargetOptions();
}

function addDropTarget() {
    const container = document.getElementById('dropTargetsContainer');
    const newIndex = ++dropTargetIndex;
    
    const targetRow = document.createElement('div');
    targetRow.className = 'drop-target-row';
    targetRow.setAttribute('data-target-index', newIndex);
    targetRow.draggable = true;
    
    targetRow.addEventListener('dragstart', handleQuestionRowDragStart);
    targetRow.addEventListener('dragover', handleQuestionRowDragOver);
    targetRow.addEventListener('drop', handleQuestionRowDrop);
    targetRow.addEventListener('dragend', handleQuestionRowDragEnd);
    
    targetRow.innerHTML = `
        <i class="fas fa-bullseye mr-2 text-muted drag-handle"></i>
        <textarea name="dropTarget_${newIndex}" class="form-control" rows="1" placeholder="Enter drop target label (use [[target]] for box position)" oninput="autoResize(this); updateDragDropTargetOptions()"></textarea>
        <button type="button" class="btn btn-outline btn-sm" onclick="removeDropTarget(this)">Remove</button>
    `;
    
    container.appendChild(targetRow);
    
    updateDragDropTargetOptions();
    
    // Auto-update marks (1 per target)
    updateDragDropMarks();
}

// Reordering logic for Add Question form
let draggedQRow = null;

function handleQuestionRowDragStart(e) {
    draggedQRow = this;
    this.style.opacity = '0.4';
    e.dataTransfer.effectAllowed = 'move';
}

function handleQuestionRowDragOver(e) {
    if (e.preventDefault) {
        e.preventDefault();
    }
    e.dataTransfer.dropEffect = 'move';
    
    if (this !== draggedQRow && this.parentNode === draggedQRow.parentNode) {
        const container = this.parentNode;
        const children = Array.from(container.children);
        const draggedIndex = children.indexOf(draggedQRow);
        const targetIndex = children.indexOf(this);
        
        if (draggedIndex < targetIndex) {
            container.insertBefore(draggedQRow, this.nextSibling);
        } else {
            container.insertBefore(draggedQRow, this);
        }
    }
    
    return false;
}

function handleQuestionRowDrop(e) {
    if (e.stopPropagation) {
        e.stopPropagation();
    }
    updateDragDropTargetOptions();
    return false;
}

function handleQuestionRowDragEnd(e) {
    this.style.opacity = '1';
    draggedQRow = null;
}

function removeDropTarget(button) {
    const targetRow = button.closest('.drop-target-row');
    targetRow.remove();
    updateDragDropTargetOptions();
    
    // Auto-update marks
    updateDragDropMarks();
}

function updateDragDropMarks() {
    const targetCount = document.querySelectorAll('#dropTargetsContainer .drop-target-row').length;
    const totalMarksInput = document.querySelector('input[name="totalMarks"]');
    if (totalMarksInput) {
        totalMarksInput.value = Math.max(1, targetCount);
    }
}

function updateDragDropTargetOptions() {
    const targetInputs = document.querySelectorAll('#dropTargetsContainer textarea');
    const targetOptions = [];
    
    targetInputs.forEach(input => {
        const value = input.value.trim();
        if (value) {
            targetOptions.push({ value: value, text: value });
        }
    });
    
    const dragSelects = document.querySelectorAll('#dragItemsContainer select');
    dragSelects.forEach(select => {
        const currentValue = select.value;
        select.innerHTML = '<option value="">Select correct target</option>';
        
        targetOptions.forEach(option => {
            const optionElement = document.createElement('option');
            optionElement.value = option.value;
            optionElement.textContent = option.text;
            if (option.value === currentValue) {
                optionElement.selected = true;
            }
            select.appendChild(optionElement);
        });
    });
}

// Functions for batch completion modal
function showBatchCompleteModal() {
    document.getElementById('batchCompleteModal').style.display = 'block';
}

function closeBatchCompleteModal() {
    document.getElementById('batchCompleteModal').style.display = 'none';
}

function viewAllQuestions() {
    closeBatchCompleteModal();
    const courseSelect = document.getElementById('courseSelectAddNew');
    if (courseSelect && courseSelect.value) {
        window.location.href = 'showall.jsp?coursename=' + encodeURIComponent(courseSelect.value);
    } else {
        window.location.href = 'showall.jsp';
    }
}

// Functions for batch cancellation modal
function showBatchCancelModal() {
    document.getElementById('batchCancelModal').style.display = 'block';
}

function closeBatchCancelModal() {
    document.getElementById('batchCancelModal').style.display = 'none';
}

function confirmBatchCancel() {
    closeBatchCancelModal();
    sessionStorage.removeItem('batchQuestions');
    sessionStorage.removeItem('batchTotal');
    sessionStorage.removeItem('batchCurrentIndex');
    document.getElementById('batchProgressCard').style.display = 'none';
    showToast('info', 'Batch Cancelled', 'The batch process has been stopped.');
    resetForm();
}

// Test function to verify course dropdown synchronization
function testCourseSync() {
    console.log('Testing course dropdown synchronization:');
    const fileSelect = document.getElementById('courseSelectFile');
    const addSelect = document.getElementById('courseSelectAddNew');
    const viewSelect = document.getElementById('courseSelectView');
    
    console.log('File course:', fileSelect ? fileSelect.value : 'Not found');
    console.log('Add course:', addSelect ? addSelect.value : 'Not found');
    console.log('View course:', viewSelect ? viewSelect.value : 'Not found');
}

// Test function to verify orientation functionality
function testOrientation() {
    console.log('Testing orientation functionality:');
    const orientationSelect = document.getElementById('orientationSelect');
    const dragDropEditor = document.getElementById('dragDropEditor');
    
    if (orientationSelect && dragDropEditor) {
        console.log('Current orientation:', orientationSelect.value);
        console.log('Editor classes:', dragDropEditor.className);
        
        // Test all orientations
        ['horizontal', 'vertical', 'landscape'].forEach(orientation => {
            orientationSelect.value = orientation;
            orientationSelect.dispatchEvent(new Event('change'));
            console.log(`${orientation} layout applied:`, dragDropEditor.classList.contains(`${orientation}-layout`));
            
            // Check if drop targets are laid out horizontally for horizontal orientation
            if (orientation === 'horizontal') {
                const dropTargetsList = dragDropEditor.querySelector('.drop-targets-list');
                const isHorizontal = dropTargetsList && getComputedStyle(dropTargetsList).flexDirection === 'row';
                console.log('Drop targets horizontal layout:', isHorizontal);
            }
        });
        
        // Reset to original value
        orientationSelect.value = 'horizontal';
        orientationSelect.dispatchEvent(new Event('change'));
    } else {
        console.log('Orientation elements not found');
    }
}

// Initialize orientation preview for drag-drop questions
function initOrientationPreview() {
    const orientationSelect = document.getElementById('orientationSelect');
    const dragDropEditor = document.getElementById('dragDropEditor');
    
    if (orientationSelect && dragDropEditor) {
        // Function to update preview
        function updateOrientationPreview() {
            const selectedOrientation = orientationSelect.value;
            
            // Remove all orientation classes
            dragDropEditor.classList.remove('horizontal-layout', 'vertical-layout', 'landscape-layout');
            
            // Add selected orientation class
            if (selectedOrientation === 'vertical') {
                dragDropEditor.classList.add('vertical-layout');
            } else if (selectedOrientation === 'landscape') {
                dragDropEditor.classList.add('landscape-layout');
            } else {
                // Default to horizontal
                dragDropEditor.classList.add('horizontal-layout');
            }
            
            console.log('Orientation changed to:', selectedOrientation);
        }
        
        // Add event listener
        orientationSelect.addEventListener('change', updateOrientationPreview);
        
        // Initialize with current selection
        updateOrientationPreview();
    }
}

// Initialize when DOM is loaded (this will be called after the above DOMContentLoaded event)
</script>

<style>
/* Orientation preview styles for drag-drop editor */
#dragDropEditor {
    transition: all 0.3s ease;
}

#dragDropEditor.horizontal-layout {
    /* Default horizontal layout - no special styling needed */
}

#dragDropEditor.horizontal-layout .drop-targets-list {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 15px;
    align-items: center;
}

#dragDropEditor.horizontal-layout .drop-target {
    min-width: 120px;
    flex: 1 1 auto;
}

#dragDropEditor.vertical-layout {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

#dragDropEditor.vertical-layout > div {
    width: 100%;
}

#dragDropEditor.landscape-layout {
    display: grid;
    grid-template-columns: 200px 1fr;
    gap: 20px;
    align-items: start;
}

#dragDropEditor.landscape-layout .draggable-items-panel {
    padding: 15px;
    background: #f1f5f9;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
}

#dragDropEditor.landscape-layout .drop-targets-panel {
    padding: 15px;
    background: #ffffff;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
}
</style>