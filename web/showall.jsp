<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>

<%
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

// Generate new CSRF token for each page load
// This ensures fresh token for each request
String csrfToken = java.util.UUID.randomUUID().toString();
session.setAttribute("csrf_token", csrfToken);
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
    
    /* Questions Container */
    .questions-container {
        max-width: 900px;
        margin: 0 auto;
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
    
    .btn-secondary {
        background: var(--dark-gray);
        color: var(--white);
        margin-bottom: var(--spacing-lg);
    }
    
    .btn-secondary:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(100, 116, 139, 0.2);
    }
    
    .btn-primary {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
    }
    
    .btn-primary:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(9, 41, 77, 0.2);
    }
    
    .btn-error {
        background: linear-gradient(90deg, var(--error), #ef4444);
        color: var(--white);
    }
    
    .btn-error:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
    }
    
    .btn-info {
        background: linear-gradient(90deg, var(--info), #0ea5e9);
        color: var(--white);
    }
    
    .btn-info:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(8, 145, 178, 0.2);
    }
    
    /* Course Header */
    .course-header {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: var(--spacing-md) var(--spacing-lg);
        border-radius: var(--radius-md) var(--radius-md) 0 0;
        margin-bottom: 0;
        font-size: 16px;
        font-weight: 600;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    
    .questions-count {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(255, 255, 255, 0.2);
        padding: 4px 12px;
        border-radius: 12px;
        font-weight: 500;
        font-size: 12px;
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
    
    /* Question Header */
    .question-header {
        background: var(--light-gray);
        padding: var(--spacing-md) var(--spacing-lg);
        border-bottom: 1px solid var(--medium-gray);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    
    .question-number {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
    }
    
    .question-badge {
        width: 36px;
        height: 36px;
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 14px;
        flex-shrink: 0;
        box-shadow: 0 2px 6px rgba(9, 41, 77, 0.1);
    }
    
    .question-text {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 14px;
        margin: 0;
        line-height: 1.5;
    }
    
    /* Question Actions */
    .question-actions {
        display: flex;
        gap: var(--spacing-sm);
    }
    
    /* Question Content */
    .question-content {
        padding: var(--spacing-lg);
    }
    
    /* Options Grid */
    .options-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: var(--spacing-md);
        margin-bottom: var(--spacing-md);
    }
    
    .option-item {
        background: var(--light-gray);
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        padding: var(--spacing-md);
        transition: all var(--transition-fast);
        position: relative;
    }
    
    .option-item:hover {
        background: var(--white);
        border-color: var(--dark-gray);
    }
    
    .option-correct {
        border-color: var(--success);
        background: linear-gradient(135deg, rgba(5, 150, 105, 0.1), rgba(16, 185, 129, 0.1));
    }
    .option-correct-multiple {
        border-color: var(--info);
        background: linear-gradient(135deg, rgba(8, 145, 178, 0.1), rgba(14, 165, 233, 0.1));
    }
    
    .option-correct::after {
        content: "? Correct";
        position: absolute;
        top: -10px;
        right: 8px;
        background: linear-gradient(90deg, var(--success), #10b981);
        color: var(--white);
        padding: 4px 10px;
        border-radius: 10px;
        font-size: 11px;
        font-weight: 500;
        z-index: 1;
    }
    
    .option-label {
        font-weight: 600;
        color: var(--dark-gray);
        margin-bottom: var(--spacing-xs);
        display: block;
        font-size: 13px;
    }
    
    .option-text {
        color: var(--text-dark);
        font-weight: 500;
        line-height: 1.4;
        font-size: 14px;
    }
    
    /* Question Meta Info */
    .question-meta {
        display: flex;
        gap: var(--spacing-lg);
        margin-top: var(--spacing-md);
        font-size: 13px;
        color: var(--dark-gray);
    }
    
    .meta-item {
        display: flex;
        align-items: center;
        gap: var(--spacing-xs);
    }
    
    /* No Questions Message */
    .no-results {
        text-align: center;
        padding: var(--spacing-xl);
        color: var(--dark-gray);
        font-style: italic;
        font-size: 14px;
        background: var(--white);
        border-radius: var(--radius-md);
        border: 1px solid var(--medium-gray);
        box-shadow: var(--shadow-sm);
    }
    
    /* Question Type Badge */
    .question-type-badge {
        display: inline-block;
        background: var(--light-gray);
        color: var(--text-dark);
        padding: 2px 10px;
        border-radius: 10px;
        font-weight: 500;
        font-size: 11px;
        margin-left: var(--spacing-sm);
        border: 1px solid var(--medium-gray);
    }
    
    .question-type-badge.info {
        background: linear-gradient(135deg, rgba(8, 145, 178, 0.1), rgba(14, 165, 233, 0.1));
        color: var(--info);
        border-color: var(--info);
    }
    
    .code-question-indicator {
        background: linear-gradient(135deg, var(--accent-blue), #3b82f6);
        color: var(--white);
        padding: var(--spacing-sm) var(--spacing-md);
        border-radius: var(--radius-sm);
        margin-bottom: var(--spacing-md);
        border-left: 3px solid var(--primary-blue);
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        font-weight: 500;
        font-size: 13px;
    }
    
    .code-snippet {
        background: var(--primary-blue);
        color: var(--light-gray);
        border: 1px solid var(--secondary-blue);
        border-radius: var(--radius-sm);
        padding: var(--spacing-md);
        margin: var(--spacing-md) 0;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 13px;
        line-height: 1.5;
        overflow-x: auto;
        position: relative;
    }
    
    .code-header {
        color: var(--dark-gray);
        font-size: 12px;
        margin-bottom: var(--spacing-sm);
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        border-bottom: 1px solid var(--secondary-blue);
        padding-bottom: var(--spacing-sm);
    }

    .floating-back-btn {
    position: fixed;
    bottom: 20px;
    right: 20px;

    z-index: 10000;

    display: inline-flex;
    align-items: center;
    gap: 8px;

    padding: 10px 16px;
    border-radius: 8px;

    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
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
        
        .question-header {
            flex-direction: column;
            gap: var(--spacing-md);
            align-items: flex-start;
        }
        
        .question-actions {
            width: 100%;
            justify-content: space-between;
        }
        
        .options-grid {
            grid-template-columns: 1fr;
        }
        
        .btn {
            width: 100%;
            justify-content: center;
        }
        
        .course-header {
            flex-direction: column;
            gap: var(--spacing-sm);
            text-align: center;
        }
    }
    
    @media (max-width: 480px) {
        .main-content {
            padding: var(--spacing-md);
        }
        
        .question-content {
            padding: var(--spacing-md);
        }
        
        .question-meta {
            flex-direction: column;
            gap: var(--spacing-sm);
        }
        
        .question-actions {
            flex-direction: column;
            gap: var(--spacing-xs);
        }
    }

    @media (max-width: 576px) {
    .floating-back-btn {
        bottom: 15px;
        right: 15px;
        font-size: 13px;
        padding: 8px 12px;
    }
}

    /* Scroll to Top Button */
    .scroll-to-top {
        position: fixed;
        bottom: 140px;  /* Positioned above the floating back button */
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
    
    /* Alert Messages - Add to your existing CSS */
    .messages-container {
        margin-bottom: var(--spacing-lg);
    }

    .alert {
        padding: var(--spacing-md) var(--spacing-lg);
        border-radius: var(--radius-md);
        margin-bottom: var(--spacing-sm);
        display: flex;
        align-items: center;
        justify-content: space-between;
        animation: slideDown 0.3s ease;
        border-left: 4px solid transparent;
    }

    .alert-success {
        background: linear-gradient(90deg, rgba(5, 150, 105, 0.1), rgba(16, 185, 129, 0.1));
        color: var(--success);
        border-color: var(--success);
    }

    .alert-error {
        background: linear-gradient(90deg, rgba(220, 38, 38, 0.1), rgba(239, 68, 68, 0.1));
        color: var(--error);
        border-color: var(--error);
    }

    .alert i {
        margin-right: var(--spacing-sm);
        font-size: 16px;
    }

    .alert-close {
        background: transparent;
        border: none;
        color: inherit;
        cursor: pointer;
        font-size: 14px;
        opacity: 0.7;
        transition: opacity var(--transition-fast);
    }

    .alert-close:hover {
        opacity: 1;
    }

    @keyframes slideDown {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
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
        <!-- Display session messages -->
        <div class="messages-container">
            <% 
                // Check for success message
                String successMessage = (String) session.getAttribute("message");
                String errorMessage = (String) session.getAttribute("error");
                
                if (successMessage != null && !successMessage.trim().isEmpty()) {
            %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <%= successMessage %>
                    <button type="button" class="alert-close" onclick="this.parentElement.style.display='none'">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            <%
                    // Clear the message from session after displaying
                    session.removeAttribute("message");
                }
                
                if (errorMessage != null && !errorMessage.trim().isEmpty()) {
            %>
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= errorMessage %>
                    <button type="button" class="alert-close" onclick="this.parentElement.style.display='none'">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            <%
                    // Clear the error from session after displaying
                    session.removeAttribute("error");
                }
            %>
        </div>
        
        <div class="questions-container">
            <!-- Page Header -->
            <header class="page-header">
                <div class="page-title">
                    <i class="fas fa-question-circle"></i>
                    Course Questions
                </div>
                <div class="stats-badge">
                    <%
                        if (request.getParameter("coursename") != null) {
                            ArrayList list = pDAO.getAllQuestions(request.getParameter("coursename"));
                    %>
                    <i class="fas fa-list-ol"></i>
                    <%= list.size() %> Questions
                    <%
                        }
                    %>
                </div>
            </header>
            
            <!-- Back Button -->
            <a href="adm-page.jsp?pgprt=3" class="btn btn-secondary floating-back-btn">
                <i class="fas fa-arrow-left"></i>
                Back
            </a>
            
            <!-- Scroll to Top Button -->
            <button class="scroll-to-top" id="scrollToTopBtn" title="Scroll to top">
                <i class="fas fa-arrow-up"></i>
            </button>

            
            <%
                if (request.getParameter("coursename") != null) {
                    ArrayList list = pDAO.getAllQuestions(request.getParameter("coursename"));
                    String courseName = request.getParameter("coursename");
            %>
            
            <form action="controller.jsp" method="post">
                <input type="hidden" name="page" value="questions">
                <input type="hidden" name="operation" value="bulk_delete">
                <input type="hidden" name="coursename" value="<%= courseName %>">
                <input type="hidden" name="csrf_token" value="<%= csrfToken %>">


            <!-- Course Header -->
            <div class="question-card" style="border-radius: var(--radius-md); margin-bottom: var(--spacing-lg);">
                <div class="course-header">
                    <div>
                        <i class="fas fa-book"></i>
                        <%= courseName %> - Questions
                    </div>
                    <div class="questions-count">
                        <i class="fas fa-layer-group"></i>
                        Total: <%= list.size() %> Questions
                    </div>
                </div>
            </div>
            
            <%
                    if (list.isEmpty()) {
            %>
                <div class="no-results">
                    <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                    No questions found for <%= courseName %>.
                    <br>
                    <small>Add questions to this course to see them listed here.</small>
                </div>
            <%
                    } else {
            %>
<!--                <button type="button" id="bulkDeleteBtn" class="btn btn-error">
                    <i class="fas fa-trash"></i> Delete Selected
                </button> -->
                <br><br>
            <%
                        for (int i = 0; i < list.size(); i++) {
                            Questions question = (Questions) list.get(i);
                            String questionId = String.valueOf(question.getQuestionId());
                            String questionNumber = String.valueOf(i + 1);
                            String questionText = question.getQuestion();
                            String opt1 = question.getOpt1();
                            String opt2 = question.getOpt2();
                            String opt3 = question.getOpt3();
                            String opt4 = question.getOpt4();
                            String correct = question.getCorrect();
                            String questionType = question.getQuestionType();
                            String imagePath = question.getImagePath();
                            
                            // Check if this is a multiple select question (contains pipe separator)
                            boolean isMultipleSelect = correct != null && correct.contains("|");
                            String[] correctAnswers = null;
                            if (isMultipleSelect) {
                                correctAnswers = correct.split("\\|");
                            }
                            
                            // Handle code snippet display
                            String fullQuestion = questionText, questionPart = "", codePart = "";
                            boolean isCodeQuestion = false;
                            if(questionType != null && questionType.equals("Code")) {
                                isCodeQuestion = true;
                                if(fullQuestion.contains("```")){
                                    String[] parts = fullQuestion.split("```", 3);
                                    if(parts.length >= 2) {
                                        questionPart = parts[0].trim();
                                        codePart = parts[1].trim();
                                    } else {
                                        questionPart = fullQuestion.replace("```", "").trim();
                                    }
                                } else {
                                    codePart = fullQuestion;
                                    questionPart = "What is the output/result of this code?";
                                }
                            } else {
                                questionPart = fullQuestion;
                            }
            %>
            
            <!-- Question Card -->
            <div class="question-card">
                <div class="question-header">
                    <div class="question-number">
                        <input type="checkbox" name="questionIds" value="<%= questionId %>">
                        <div class="question-badge">
                            <%= questionNumber %>
                        </div>
                        <div class="question-text">
                            <%= questionText %>
                            
                            <!-- Display question image if exists -->
                            <% if (imagePath != null && !imagePath.isEmpty()) { %>
                            <div style="margin-top: 15px; text-align: center;">
                                <div style="display: inline-block; border: 1px solid #ddd; border-radius: 8px; padding: 10px; background: #f9f9f9;">
                                    <img src="<%= imagePath %>" alt="Question Image" 
                                         style="max-width: 100%; max-height: 300px; border-radius: 4px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
                                    <div style="margin-top: 8px; font-size: 12px; color: #666;">
                                        <i class="fas fa-image"></i> Question Image
                                    </div>
                                </div>
                            </div>
                            <% } %>
                            
                            <% if (isMultipleSelect) { %>
                                <div style="margin-top: var(--spacing-xs);">
                                    <span class="question-type-badge info">
                                        <i class="fas fa-check-double"></i> Multiple Select (Choose Two)
                                    </span>
                                </div>
                            <% } %>
                        </div>
                    </div>
                    <div class="question-actions">
                        <a href="edit_question.jsp?qid=<%= question.getQuestionId() %>&coursename=<%= courseName %>"
                           class="btn btn-primary" style="font-size: 13px; padding: 8px 16px;">
                            <i class="fas fa-edit"></i>
                            Edit
                        </a>

                        <button type="button" class="btn btn-error single-delete-btn" style="font-size: 13px; padding: 8px 16px;" data-qid="<%= question.getQuestionId() %>" data-coursename="<%= courseName %>">
                            <i class="fas fa-trash"></i>
                            Delete
                        </button>
                    </div>
                </div>
                
                <div class="question-content">
                    <% if ("FillInTheBlank".equalsIgnoreCase(questionType)) { %>
                        <div class="fib-answer-display" style="background: linear-gradient(135deg, rgba(5, 150, 105, 0.1), rgba(16, 185, 129, 0.1)); border: 1px solid var(--success); border-radius: var(--radius-sm); padding: var(--spacing-md); position: relative; margin-bottom: var(--spacing-md);">
                            <span class="option-label" style="color: var(--success);"><i class="fas fa-check-circle"></i> Correct Answer</span>
                            <div class="option-text" style="font-size: 16px; font-weight: 600;"><%= correct %></div>
                        </div>
                    <% } else { %>
                        <div class="options-grid">
                            <!-- Option A -->
                            <div class="option-item <%= isMultipleSelect ? 
                                  (containsAnswer(correctAnswers, opt1) ? "option-correct-multiple" : "") : 
                                  (correct != null && correct.equals(opt1) ? "option-correct" : "") %>">
                                <span class="option-label">Option A</span>
                                <div class="option-text"><%= opt1 %></div>
                            </div>
                            
                            <!-- Option B -->
                            <div class="option-item <%= isMultipleSelect ? 
                                  (containsAnswer(correctAnswers, opt2) ? "option-correct-multiple" : "") : 
                                  (correct != null && correct.equals(opt2) ? "option-correct" : "") %>">
                                <span class="option-label">Option B</span>
                                <div class="option-text"><%= opt2 %></div>
                            </div>
                            
                            <!-- Option C -->
                            <% if (opt3 != null && !opt3.isEmpty()) { %>
                            <div class="option-item <%= isMultipleSelect ? 
                                  (containsAnswer(correctAnswers, opt3) ? "option-correct-multiple" : "") : 
                                  (correct != null && correct.equals(opt3) ? "option-correct" : "") %>">
                                <span class="option-label">Option C</span>
                                <div class="option-text"><%= opt3 %></div>
                            </div>
                            <% } %>
                            
                            <!-- Option D -->
                            <% if (opt4 != null && !opt4.isEmpty()) { %>
                            <div class="option-item <%= isMultipleSelect ? 
                                  (containsAnswer(correctAnswers, opt4) ? "option-correct-multiple" : "") : 
                                  (correct != null && correct.equals(opt4) ? "option-correct" : "") %>">
                                <span class="option-label">Option D</span>
                                <div class="option-text"><%= opt4 %></div>
                            </div>
                            <% } %>
                        </div>
                    <% } %>
                    
                    <div class="question-meta">
                        <div class="meta-item">
                            <i class="fas fa-hashtag" style="color: var(--accent-blue);"></i>
                            Question ID: <strong><%= questionId %></strong>
                        </div>
                        <% if (isMultipleSelect) { %>
                        <div class="meta-item">
                            <i class="fas fa-info-circle" style="color: var(--info);"></i>
                            <span style="color: var(--info);"><strong>Multiple Correct Answers</strong> - Both highlighted answers must be selected</span>
                        </div>
                        <% } else { %>
                        <div class="meta-item">
                            <i class="fas fa-check-circle" style="color: var(--success);"></i>
                            Correct answer is highlighted in green
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                        }
            %>
            </form>
            <%
                    }
                } else {
            %>
                <div class="no-results">
                    <i class="fas fa-exclamation-circle" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                    Please select a course to view questions.
                    <br>
                    <small>Go back to Questions Management and select a course.</small>
                </div>
            <%
                }
            %>
        </div>
    </main>
</div>

<!-- Professional Modal for Delete Confirmation -->
<div id="confirmationModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle"><i class="fas fa-exclamation-triangle"></i> Confirmation</h3>
            <span class="close-modal" onclick="hideModal()">&times;</span>
        </div>
        <div class="modal-body">
            <p id="modalMessage"></p>
        </div>
        <div class="modal-footer">
            <button id="cancelButton" class="btn btn-outline" onclick="hideModal()">Cancel</button>
            <button id="confirmButton" class="btn btn-error" onclick="confirmAction()">Delete</button>
        </div>
    </div>
</div>

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

/* Floating delete button */
.floating-delete-btn {
    position: fixed;
    bottom: 20px;
    right: 30px;
    z-index: 999;
    display: none;
    animation: fadeIn 0.3s;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}
</style>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- JavaScript for enhanced functionality -->
<script>
    // Add animation to question cards
    let pageInitialized = false;
    function initializePage() {
        // Prevent multiple initializations
        if (pageInitialized) {
            console.log('Page already initialized, skipping...');
            return;
        }
        
        console.log('Starting page initialization...');
        pageInitialized = true;
        
        const questionCards = document.querySelectorAll('.question-card');
        questionCards.forEach((card, index) => {
            card.style.animationDelay = `${index * 0.1}s`;
            card.style.animation = 'fadeInUp 0.3s ease forwards';
            card.style.opacity = '0';
        });
        
        // Add CSS animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
        `;
        document.head.appendChild(style);
        
        // Add floating delete button
        const floatingDeleteBtn = document.createElement('button');
        floatingDeleteBtn.id = 'floatingDeleteBtn';
        floatingDeleteBtn.className = 'btn btn-error floating-delete-btn';
        floatingDeleteBtn.innerHTML = '<i class="fas fa-trash"></i> Delete Selected';
        floatingDeleteBtn.onclick = function() {
            const form = document.querySelector('form');
            if (!form) return;
            
            const selectedQuestions = form.querySelectorAll('input[name="questionIds"]:checked').length;
            
            if (selectedQuestions === 0) {
                alert('Please select at least one question to delete.');
                return;
            }
            
            document.getElementById('modalMessage').textContent = 
                `Are you sure you want to delete the ${selectedQuestions} selected question(s)? This action cannot be undone.`;
            document.getElementById('confirmationModal').style.display = 'block';
            
            // Store reference to form and indicate it's a bulk delete
            window.deleteForm = form;
            window.isBulkDelete = true;
        };
        document.body.appendChild(floatingDeleteBtn);
        
        // Update floating delete button state based on selections
        function updateFloatingDeleteButton() {
            const form = document.querySelector('form');
            if (!form) return;
            
            const selectedQuestions = form.querySelectorAll('input[name="questionIds"]:checked').length;
            const floatingBtn = document.getElementById('floatingDeleteBtn');
            
            if (selectedQuestions > 0) {
                floatingBtn.style.display = 'block';
            } else {
                floatingBtn.style.display = 'none';
            }
        }
        
        // Add event listeners to all checkboxes
        setTimeout(function() {
            document.querySelectorAll('input[name="questionIds"]').forEach(checkbox => {
                checkbox.addEventListener('change', updateFloatingDeleteButton);
            });
            // Initial update
            updateFloatingDeleteButton();
        }, 100);
        
        // Add event listener to bulk delete button
        const bulkDeleteBtn = document.getElementById('bulkDeleteBtn');
        if (bulkDeleteBtn) {
            bulkDeleteBtn.addEventListener('click', function(e) {
                e.preventDefault();
                const form = document.querySelector('form');
                const selectedQuestions = form.querySelectorAll('input[name="questionIds"]:checked').length;
                
                if (selectedQuestions === 0) {
                    alert('Please select at least one question to delete.');
                    return;
                }
                
                document.getElementById('modalMessage').textContent = 
                    `Are you sure you want to delete the ${selectedQuestions} selected question(s)? This action cannot be undone.`;
                document.getElementById('confirmationModal').style.display = 'block';
                
                // Store reference to form and indicate it's a bulk delete
                window.deleteForm = form;
                window.isBulkDelete = true;
            });
        }
        
        // Add event listener to single delete buttons
        setTimeout(function() {
            document.querySelectorAll('.single-delete-btn').forEach(button => {
                button.addEventListener('click', function(e) {
                    e.preventDefault();
                    const qid = this.getAttribute('data-qid');
                    const coursename = this.getAttribute('data-coursename');
                    
                    // Store the parameters for later use in confirmAction
                    window.currentDeleteParams = {
                        qid: qid,
                        coursename: coursename
                    };
                    
                    showModal(`Are you sure you want to delete question ID ${qid}? This action cannot be undone.`);
                });
            });
        }, 100);
    }
    
    // Initialize when DOM is ready
    function initPage() {
        console.log('Initializing page...');
        initializePage();
        console.log('Page initialization complete');
    }
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPage);
    } else {
        initPage();
    }
    
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
    
    let modalTimer;

    function showModal(message) {
        document.getElementById('modalMessage').textContent = message;
        document.getElementById('confirmationModal').style.display = 'block';
        modalTimer = setTimeout(hideModal, 5000);
    }
    
    function hideModal() {
        clearTimeout(modalTimer);
        document.getElementById('confirmationModal').style.display = 'none';
    }
    
    function confirmAction() {
        clearTimeout(modalTimer);
        
        // If we have stored delete parameters (single delete), submit delete request
        if (window.currentDeleteParams && !window.isBulkDelete) {
            console.log('Submitting single delete request for question ID:', window.currentDeleteParams.qid);
            
            // Create a temporary form to submit the delete request
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'controller.jsp';
            form.style.display = 'none';
            
            // Add parameters for single delete
            const pageInput = document.createElement('input');
            pageInput.type = 'hidden';
            pageInput.name = 'page';
            pageInput.value = 'questions';
            form.appendChild(pageInput);
            
            const operationInput = document.createElement('input');
            operationInput.type = 'hidden';
            operationInput.name = 'operation';
            operationInput.value = 'del';
            form.appendChild(operationInput);
            
            const qidInput = document.createElement('input');
            qidInput.type = 'hidden';
            qidInput.name = 'qid';
            qidInput.value = window.currentDeleteParams.qid;
            form.appendChild(qidInput);
            
            const coursenameInput = document.createElement('input');
            coursenameInput.type = 'hidden';
            coursenameInput.name = 'coursename';
            coursenameInput.value = window.currentDeleteParams.coursename;
            form.appendChild(coursenameInput);
            
            // Get fresh CSRF token from the form on the page
            const mainForm = document.querySelector('form[action="controller.jsp"]');
            const csrfToken = mainForm ? mainForm.querySelector('input[name="csrf_token"]').value : '';
            
            const csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = 'csrf_token';
            csrfInput.value = csrfToken;
            form.appendChild(csrfInput);
            
            document.body.appendChild(form);
            form.submit();
        } else {
            // Perform bulk delete
            console.log('Performing bulk delete');
            
            // Create a fresh form for each delete operation to avoid CSRF token issues
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'controller.jsp';
            form.style.display = 'none';
            
            // Get selected question IDs
            const mainForm = document.querySelector('form[action="controller.jsp"]');
            if (!mainForm) {
                console.error('Main form not found');
                alert('Error: Could not find main form');
                hideModal();
                return;
            }
            
            const selectedCheckboxes = mainForm.querySelectorAll('input[name="questionIds"]:checked');
            console.log('Found', selectedCheckboxes.length, 'selected questions');
            
            if (selectedCheckboxes.length === 0) {
                alert('No questions selected to delete.');
                hideModal();
                return;
            }
            
            // Add hidden inputs for the operation
            const pageInput = document.createElement('input');
            pageInput.type = 'hidden';
            pageInput.name = 'page';
            pageInput.value = 'questions';
            form.appendChild(pageInput);
            
            const operationInput = document.createElement('input');
            operationInput.type = 'hidden';
            operationInput.name = 'operation';
            operationInput.value = 'bulk_delete';
            form.appendChild(operationInput);
            
            const coursenameInput = document.createElement('input');
            coursenameInput.type = 'hidden';
            coursenameInput.name = 'coursename';
            coursenameInput.value = '<%= request.getParameter("coursename") %>';
            form.appendChild(coursenameInput);
            
            // Get the CSRF token from the main form
            const csrfTokenInput = mainForm.querySelector('input[name="csrf_token"]');
            const csrfToken = csrfTokenInput ? csrfTokenInput.value : '';
            
            const csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = 'csrf_token';
            csrfInput.value = csrfToken;
            form.appendChild(csrfInput);
            
            // Add selected question IDs
            selectedCheckboxes.forEach(checkbox => {
                const questionIdInput = document.createElement('input');
                questionIdInput.type = 'hidden';
                questionIdInput.name = 'questionIds';
                questionIdInput.value = checkbox.value;
                form.appendChild(questionIdInput);
            });
            
            // Log form data for debugging
            const formData = new FormData(form);
            console.log('Form data:', [...formData.entries()]);
            
            // Append form to body and submit
            document.body.appendChild(form);
            form.submit();
            console.log('Bulk delete form submitted successfully');
        }
        
        // Reset flags and hide modal after action
        window.currentDeleteParams = null;
        window.isBulkDelete = false;
        hideModal();
    }
    
    // Close modal when clicking outside of it
    window.onclick = function(event) {
        const modal = document.getElementById('confirmationModal');
        if (event.target === modal) {
            hideModal();
        }
    }
    
    // Auto-hide alert messages after 5 seconds
    setTimeout(function() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            if (alert.style.display !== 'none') {
                alert.style.opacity = '1';
                let opacity = 1;
                const fadeOut = setInterval(function() {
                    if (opacity <= 0) {
                        clearInterval(fadeOut);
                        alert.style.display = 'none';
                    }
                    alert.style.opacity = opacity;
                    opacity -= 0.05;
                }, 50);
            }
        });
    }, 5000); // Hide after 5 seconds
</script>

<%!
// Helper method to check if an array contains a specific answer
private boolean containsAnswer(String[] correctAnswers, String option) {
    if (correctAnswers == null || option == null) return false;
    for (String correctAnswer : correctAnswers) {
        if (correctAnswer.trim().equals(option.trim())) {
            return true;
        }
    }
    return false;
}
%>