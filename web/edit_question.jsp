<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.User"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Add session validation at the VERY TOP of the page
    Object userIdObj = session.getAttribute("userId");
    String userStatus = (String) session.getAttribute("userStatus");
    
    if (userIdObj == null || userStatus == null || !"1".equals(userStatus)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    DatabaseClass pDAO = DatabaseClass.getInstance();
    String qidParam = request.getParameter("qid");
    
    if (qidParam == null || qidParam.trim().isEmpty()) {
        session.setAttribute("error", "Missing question ID parameter");
        response.sendRedirect("adm-page.jsp?pgprt=3");
        return;
    }
    
    int questionId = Integer.parseInt(qidParam);
    Questions questionToEdit = null;
    String questionType = "MCQ";

    try {
        String sql = "SELECT * FROM questions WHERE question_id=?";
        Connection conn = pDAO.getConnection();
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, questionId);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
        questionToEdit = new Questions(
            rs.getInt("question_id"),
            rs.getString("question"),
            rs.getString("opt1"),
            rs.getString("opt2"),
            rs.getString("opt3"),
            rs.getString("opt4"),
            rs.getString("correct"),
            rs.getString("course_name"),
            rs.getString("question_type"),  // 9th parameter
            rs.getString("image_path")      // 10th parameter
        );
            questionType = rs.getString("question_type") != null ? rs.getString("question_type") : "MCQ";
        }
        rs.close();
        pstm.close();
        conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    String[] correctAnswers = null;
    if ("MultipleSelect".equals(questionType) && questionToEdit != null) {
        correctAnswers = questionToEdit.getCorrect().split("\\|");
    }
    
    // Get the current course name from the question being edited
    String currentCourseName = "";
    if (questionToEdit != null && questionToEdit.getCourseName() != null) {
        currentCourseName = questionToEdit.getCourseName();
    }

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
        min-height: 150px;
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

<div class="dashboard-container">
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
    
    <main class="main-content">
        <header class="page-header">
            <div class="page-title">
                <i class="fas fa-edit"></i>Edit Question
                <span class="question-type-badge"><i class="fas fa-tag"></i><%= questionType %></span>
            </div>
            <div class="stats-badge">
                <i class="fas fa-hashtag"></i>Question ID: <%= questionToEdit.getQuestionId() %>
                &nbsp;&nbsp;
                <i class="fas fa-book"></i>Course: <%= currentCourseName %>
            </div>
        </header>
        
        <% String message = (String) session.getAttribute("message");
           if (message != null) { %>
            <div class="alert"><i class="fas fa-check-circle"></i> <%= message %></div>
        <% session.removeAttribute("message"); } %>

        <div class="question-card" id="editQuestionPanel">
            <div class="card-header"><span><i class="fas fa-edit"></i> Edit Question</span><i class="fas fa-question-circle" style="opacity: 0.8;"></i></div>
            <div class="question-form">
                <form action="controller.jsp" method="POST" id="editQuestionForm" enctype="multipart/form-data">
                    <input type="hidden" name="page" value="questions">
                    <input type="hidden" name="operation" value="edit">
                    <input type="hidden" name="qid" value="<%= questionToEdit.getQuestionId() %>">
                    <input type="hidden" name="coursename" value="<%= currentCourseName %>">
                    <input type="hidden" id="currentImagePath" name="currentImagePath" value="<%= questionToEdit.getImagePath() != null ? questionToEdit.getImagePath() : "" %>">
                    <input type="hidden" id="questionTypeHidden" name="questionType" value="<%= questionType %>">

                    <div class="form-grid">
                        <div class="form-group">
<label class="form-label"><i class="fas fa-book" style="color: var(--accent-blue);"></i>Select Course</label>
<select name="coursename" class="form-select" id="courseSelectEdit" required>
    <!-- Add current course as selected option first -->
    <option value="<%= currentCourseName %>" selected><%= currentCourseName %></option>
    
    <!-- Then list all other courses -->
    <%
        ArrayList<String> allCourseNames = pDAO.getAllCourseNames();
        for (String course : allCourseNames) { 
            // Skip current course because it's already added
            if (!course.equals(currentCourseName)) {
    %>
        <option value="<%= course %>"><%= course %></option>
    <%
            }
        }
    %>
</select>

<!-- Store original course -->
<input type="hidden" name="originalCourse" value="<%= currentCourseName %>">

                        </div>

                        <div class="form-group">
                            <label class="form-label"><i class="fas fa-question" style="color: var(--info);"></i>Question Type</label>
                            <select id="questionTypeSelect" class="form-select" onchange="toggleEditOptions()">
                                <option value="MCQ" <%= "MCQ".equals(questionType) ? "selected" : "" %>>Multiple Choice (Single Answer)</option>
                                <option value="MultipleSelect" <%= "MultipleSelect".equals(questionType) ? "selected" : "" %>>Multiple Select (Choose Two)</option>
                                <option value="TrueFalse" <%= "TrueFalse".equals(questionType) ? "selected" : "" %>>True / False</option>
                                <option value="Code" <%= "Code".equals(questionType) ? "selected" : "" %>>Code Snippet</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-pencil-alt" style="color: var(--success);"></i>Your Question</label>
                        <textarea name="question" id="editQuestionTextarea" class="question-input" rows="3" oninput="checkForCodeSnippetEdit()"><%= questionToEdit.getQuestion() %></textarea>
                        <small class="form-hint">Enter your question text (optional if uploading an image)</small>
                        <!-- Preview for Code Snippets -->
                        <div id="codePreview" style="display: none; margin-top: 10px;">
                            <div class="code-question-indicator"><i class="fas fa-code"></i><strong>Code Analysis Question Preview</strong></div>
                            <div class="code-snippet">
                                <div class="code-header"><i class="fas fa-code"></i><span>Code to Analyze</span></div>
                                <pre id="previewCode"></pre>
                            </div>
                        </div>
                    </div>

                    <div id="editMcqOptions">
                        <div class="form-group">
                            <label class="form-label"><i class="fas fa-list-ol"></i> Options</label>
                            <div class="options-grid">
                                <textarea name="opt1" id="editOpt1" class="option-input" required rows="2"><%= questionToEdit.getOpt1() %></textarea>
                                <textarea name="opt2" id="editOpt2" class="option-input" required rows="2"><%= questionToEdit.getOpt2() %></textarea>
                                <textarea name="opt3" id="editOpt3" class="option-input" rows="2"><%= questionToEdit.getOpt3() != null ? questionToEdit.getOpt3() : "" %></textarea>
                                <textarea name="opt4" id="editOpt4" class="option-input" rows="2"><%= questionToEdit.getOpt4() != null ? questionToEdit.getOpt4() : "" %></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-check-circle" style="color: var(--success);"></i>Correct Answer</label>
                        <div id="editCorrectAnswerContainer">
                            <textarea id="editCorrectAnswer" name="correct" class="form-control" required rows="2"><%= questionToEdit.getCorrect() %></textarea>
                            <small class="form-hint">Must match one of the options exactly</small>
                        </div>

                        <div id="editMultipleCorrectContainer" style="display:none;">
                            <div class="options-grid">
                                <div class="form-check">
                                    <input type="checkbox" id="editCorrectOpt1" class="form-check-input edit-correct-checkbox">
                                    <label for="editCorrectOpt1" class="form-check-label">Option 1</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="editCorrectOpt2" class="form-check-input edit-correct-checkbox">
                                    <label for="editCorrectOpt2" class="form-check-label">Option 2</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="editCorrectOpt3" class="form-check-input edit-correct-checkbox">
                                    <label for="editCorrectOpt3" class="form-check-label">Option 3</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="editCorrectOpt4" class="form-check-input edit-correct-checkbox">
                                    <label for="editCorrectOpt4" class="form-check-label">Option 4</label>
                                </div>
                            </div>
                            <small class="form-hint">Select exactly 2 correct answers</small>
                        </div>
                    </div>
                    
                    <!-- Image Upload Section -->
                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-image" style="color: var(--info);"></i> Upload Question Image (Optional)</label>
                        <div id="currentImageDisplay" style="margin-bottom: 15px;">
                            <% if (questionToEdit.getImagePath() != null && !questionToEdit.getImagePath().isEmpty()) { %>
                                <div class="file-name-display" style="display: flex; align-items: center; gap: 10px; padding: 10px; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: var(--radius-sm);">
                                    <i class="fas fa-image"></i>
                                    <span>Current Image: <%= new File(questionToEdit.getImagePath()).getName() %></span>
                                    <button type="button" class="remove-file-btn" onclick="removeCurrentImage()">×</button>
                                </div>
                                <div style="margin-top: 10px; text-align: center;">
                                    <img src="<%= questionToEdit.getImagePath() %>" alt="Current Question Image" style="max-width: 200px; max-height: 200px; border-radius: var(--radius-sm); border: 1px solid var(--medium-gray);">
                                </div>
                            <% } else { %>
                                <div class="form-hint">No image currently uploaded</div>
                            <% } %>
                        </div>
                        <div class="drop-zone" id="editImageDropZone">
                            <div class="drop-zone-content">
                                <i class="fas fa-cloud-upload-alt drop-icon"></i>
                                <p class="drop-text">Drag & drop a new image here or click to browse</p>
                                <p class="drop-hint">Supports JPG, PNG, GIF, WebP (Max 3MB)</p>
                                <input type="file" name="imageFile" class="form-control" id="editImageFile" accept=".jpg,.jpeg,.png,.gif,.webp" style="display: none;">
                            </div>
                        </div>
                        <div id="editImageFileNameDisplay" class="file-name-display" style="display: none; margin-top: 10px;">
                            <i class="fas fa-image"></i>
                            <span id="editImageFileName"></span>
                            <button type="button" class="remove-file-btn" onclick="removeEditImageFile()">×</button>
                        </div>
                        <small class="form-hint">Upload a new image to replace the current one (optional)</small>
                    </div>
                    
                    <!-- Image Preview Section -->
                    <div id="editImagePreviewSection" class="form-group" style="display: none;">
                        <label class="form-label"><i class="fas fa-eye" style="color: var(--success);"></i> Image Preview</label>
                        <div style="text-align: center; padding: 10px; border: 1px solid var(--medium-gray); border-radius: var(--radius-sm);">
                            <img id="editImagePreview" src="#" alt="Image Preview" style="max-width: 100%; max-height: 200px; display: none; border-radius: var(--radius-sm);">
                            <p id="editPreviewPlaceholder" style="color: var(--dark-gray); margin: 0;">New image will appear here</p>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="adm-page.jsp?coursename=<%= currentCourseName %>&pgprt=4" class="btn btn-outline"><i class="fas fa-times"></i> Cancel</a>
                        <button type="submit" class="btn btn-primary" id="editSubmitBtn" onclick="return validateAndSubmit(event)"><i class="fas fa-save"></i> Update Question</button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<script>
    function updateEditCorrectOptionLabels() {
        for (let i = 1; i <= 4; i++) {
            const optInput = document.getElementById(`editOpt${i}`);
            const label = document.querySelector(`label[for="editCorrectOpt${i}"]`);
            if (optInput && label) {
                const value = optInput.value.trim();
                label.textContent = value || `Option ${i}`;
            }
        }
    }
    
    function toggleEditOptions() {
        const qType = document.getElementById("questionTypeSelect").value;
        const mcq = document.getElementById("editMcqOptions");
        const single = document.getElementById("editCorrectAnswerContainer");
        const multiple = document.getElementById("editMultipleCorrectContainer");
        const correct = document.getElementById("editCorrectAnswer");
        
        document.getElementById("questionTypeHidden").value = qType;
    
        mcq.style.display = "none";
        single.style.display = "none";
        multiple.style.display = "none";
        correct.required = false;
    
        if (qType === "TrueFalse") {
            single.style.display = "block";
            correct.placeholder = "Enter 'True' or 'False";
            correct.required = true;
        } else {
            mcq.style.display = "block";
            if (qType === "MultipleSelect") {
                multiple.style.display = "block";
                updateEditCorrectOptionLabels();
                initializeMultipleSelectCheckboxes();
            } else {
                single.style.display = "block";
                correct.placeholder = qType === 'Code' ? "Expected output" : "Correct Answer";
                correct.required = true;
            }
        }
    }

// Function to check if question suggests code snippet type
function checkForCodeSnippetEdit() {
    const questionText = document.getElementById("editQuestionTextarea").value;
    const questionType = document.getElementById("questionTypeSelect").value;
    
    // Count lines and check for code indicators
    const lines = questionText.split('\n').filter(line => line.trim() !== '');
    const hasCodeIndicators = /(?:def |function |public |class |print\(|console\.\|<[^>]*>\|\{|\}|import |int |String |printf\(|cout )/.test(questionText);
    
    // If question is longer than 3 lines or contains code indicators and is not already Code type
    if ((lines.length > 3 || hasCodeIndicators) && questionType !== 'Code') {
        if (confirm("This question appears to contain code or multiple lines. Would you like to change the question type to 'Code Snippet'?")) {
            document.getElementById("questionTypeSelect").value = "Code";
            toggleEditOptions();
        }
    }
    
    // Update preview if it's a code question
    updateCodePreview(questionText, questionType);
}

// Function to update code snippet preview
function updateCodePreview(questionText, questionType) {
    const previewDiv = document.getElementById('codePreview');
    const previewCode = document.getElementById('previewCode');
    
    if (questionType === 'Code') {
        let questionPart = "";
        let codePart = "";
        
        if(questionText.includes('```')){
            const parts = questionText.split('```', 3);
            if(parts.length >= 2) {
                questionPart = parts[0].trim();
                codePart = parts[1].trim();
            } else {
                questionPart = questionText.replace(/```/g, "").trim();
            }
        } else {
            codePart = questionText;
            questionPart = "What is the output/result of this code?";
        }
        
        previewCode.textContent = codePart;
        previewDiv.style.display = 'block';
    } else {
        previewDiv.style.display = 'none';
    }
}

// Initialize preview on page load
window.addEventListener('DOMContentLoaded', function() {
    const initialQuestionText = document.getElementById("editQuestionTextarea").value;
    const initialQuestionType = document.getElementById("questionTypeSelect").value;
    updateCodePreview(initialQuestionText, initialQuestionType);
});

    function initializeMultipleSelectCheckboxes() {
        const correctAnswers = document.getElementById('editCorrectAnswer').value.split('|');
        document.querySelectorAll('.edit-correct-checkbox').forEach(cb => {
            const optionValue = cb.value.trim();
            if (optionValue && correctAnswers.includes(optionValue)) {
                cb.checked = true;
            } else {
                cb.checked = false;
            }
        });
    }

    function validateAndSubmit(event) {
        event.preventDefault();
        
        const qType = document.getElementById("questionTypeSelect").value;
        let msg = '';

        // Check if there's an image file uploaded
        const imageFileInput = document.getElementById('editImageFile');
        const hasImageFile = imageFileInput && imageFileInput.files.length > 0;
        
        // Check if there's a current image (already uploaded previously)
        const currentImagePathElement = document.getElementById('currentImagePath');
        const hasCurrentImage = currentImagePathElement && currentImagePathElement.value && currentImagePathElement.value.trim() !== '';
        
        // Check if image should be removed
        const removeImageElement = document.querySelector('input[name="removeImage"][value="true"]');
        const willRemoveImage = removeImageElement !== null;
        
        // Only validate question text if no image is present (either newly uploaded or previously uploaded and not being removed)
        const hasImage = (hasImageFile || (hasCurrentImage && !willRemoveImage));
        
        if (!hasImage) {
            // Only validate question text if no image is present
            const questionText = document.getElementById('editQuestionTextarea').value.trim();
            if (!questionText) {
                msg = "Question text is required when no image is uploaded.";
            }
        }

        if (qType === "TrueFalse") {
            const correctValue = document.getElementById('editCorrectAnswer').value.trim().toLowerCase();
            if (correctValue !== "true" && correctValue !== "false") {
                msg = "Answer must be 'True' or 'False'.";
            }
        } else {
            const opt1 = document.getElementById('editOpt1').value.trim();
            const opt2 = document.getElementById('editOpt2').value.trim();
            
            if (!opt1 || !opt2) {
                msg = "At least Option 1 and Option 2 are required.";
            }
            
            const opts = ['editOpt1', 'editOpt2', 'editOpt3', 'editOpt4']
                .map(id => document.getElementById(id).value.trim())
                .filter(Boolean);
                
            if (new Set(opts).size !== opts.length) {
                msg = "Options must be unique.";
            } else if (qType === "MultipleSelect") {
                const selectedCount = document.querySelectorAll('.edit-correct-checkbox:checked').length;
                if (selectedCount !== 2) {
                    msg = "Select exactly 2 correct answers.";
                } else {
                    const selectedAnswers = Array.from(document.querySelectorAll('.edit-correct-checkbox:checked'))
                        .map(cb => cb.value)
                        .join('|');
                    document.getElementById('editCorrectAnswer').value = selectedAnswers;
                }
            } else {
                const correctValue = document.getElementById('editCorrectAnswer').value.trim();
                if (correctValue && !opts.includes(correctValue)) {
                    msg = "Correct answer must match one of the options.";
                }
            }
        }

        if (msg) {
            alert(msg);
            return false;
        }
        
        // Show loading state
        const submitBtn = document.getElementById('editSubmitBtn');
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating...';
        submitBtn.disabled = true;
        
        // Submit the form
        document.getElementById('editQuestionForm').submit();
        
        return true;
    }

    // Image upload functions for edit
    function initEditImageUpload() {
        const editImageFileInput = document.getElementById('editImageFile');
        const editImageDropZone = document.getElementById('editImageDropZone');
        
        if (editImageFileInput && editImageDropZone) {
            // Click to browse
            editImageDropZone.addEventListener('click', () => {
                editImageFileInput.click();
            });
            
            // File input change
            editImageFileInput.addEventListener('change', function() {
                if (this.files && this.files[0]) {
                    displayEditImageFileName(this.files[0]);
                }
            });
            
            // Drag and drop events
            ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                editImageDropZone.addEventListener(eventName, preventEditImageDefaults, false);
            });
            
            function preventEditImageDefaults(e) {
                e.preventDefault();
                e.stopPropagation();
            }
            
            ['dragenter', 'dragover'].forEach(eventName => {
                editImageDropZone.addEventListener(eventName, highlightEditImage, false);
            });
            
            ['dragleave', 'drop'].forEach(eventName => {
                editImageDropZone.addEventListener(eventName, unhighlightEditImage, false);
            });
            
            function highlightEditImage() {
                editImageDropZone.classList.add('drag-over');
            }
            
            function unhighlightEditImage() {
                editImageDropZone.classList.remove('drag-over');
            }
            
            editImageDropZone.addEventListener('drop', handleEditImageDrop, false);
            
            function handleEditImageDrop(e) {
                const dt = e.dataTransfer;
                const files = dt.files;
                
                if (files.length > 0) {
                    const file = files[0];
                    // Check if it's an image file
                    if (file.type.match('image.*')) {
                        // Set the file to the hidden input
                        const dataTransfer = new DataTransfer();
                        dataTransfer.items.add(file);
                        editImageFileInput.files = dataTransfer.files;
                        displayEditImageFileName(file);
                    } else {
                        alert('Please select an image file (JPG, PNG, GIF).');
                    }
                }
            }
            
            function displayEditImageFileName(file) {
                const editImageFileNameDisplay = document.getElementById('editImageFileNameDisplay');
                const editImageFileNameSpan = document.getElementById('editImageFileName');
                const editImagePreview = document.getElementById('editImagePreview');
                const editPreviewPlaceholder = document.getElementById('editPreviewPlaceholder');
                const editImagePreviewSection = document.getElementById('editImagePreviewSection');
                
                editImageFileNameSpan.textContent = file.name;
                editImageFileNameDisplay.style.display = 'flex';
                editImageDropZone.style.display = 'none';
                
                // Show image preview if it's an image file
                if (file.type.match('image.*')) {
                    const reader = new FileReader();
                    
                    reader.onload = function(e) {
                        editImagePreview.src = e.target.result;
                        editImagePreview.style.display = 'block';
                        editPreviewPlaceholder.style.display = 'none';
                        editImagePreviewSection.style.display = 'block';
                    };
                    
                    reader.readAsDataURL(file);
                }
            }
        }
    }
    
    function removeEditImageFile() {
        const editImageFileInput = document.getElementById('editImageFile');
        const editImageFileNameDisplay = document.getElementById('editImageFileNameDisplay');
        const editImageDropZone = document.getElementById('editImageDropZone');
        const editImagePreviewSection = document.getElementById('editImagePreviewSection');
        
        // Reset file input
        editImageFileInput.value = '';
        
        // Hide file name display and show drop zone
        editImageFileNameDisplay.style.display = 'none';
        editImageDropZone.style.display = 'block';
        
        // Also hide the preview section
        editImagePreviewSection.style.display = 'none';
    }
    
    function removeCurrentImage() {
        // Show confirmation dialog
        if (confirm('Are you sure you want to remove the current image?')) {
            // Add a hidden input field to indicate the image should be removed
            const removeImageInput = document.createElement('input');
            removeImageInput.type = 'hidden';
            removeImageInput.name = 'removeImage';
            removeImageInput.value = 'true';
            document.getElementById('editQuestionForm').appendChild(removeImageInput);
            
            // Hide the current image display
            document.getElementById('currentImageDisplay').innerHTML = '<div class="form-hint">Image will be removed on update</div>';
            
            // Also hide the preview section if it exists
            const editImagePreviewSection = document.getElementById('editImagePreviewSection');
            if (editImagePreviewSection) {
                editImagePreviewSection.style.display = 'none';
            }
        }
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        toggleEditOptions();
        
        // Initialize option values for checkboxes
        for (let i = 1; i <= 4; i++) {
            const optInput = document.getElementById(`editOpt${i}`);
            const checkbox = document.getElementById(`editCorrectOpt${i}`);
            const label = document.querySelector(`label[for="editCorrectOpt${i}"]`);

            if (optInput && checkbox && label) {
                // Set initial values
                const value = optInput.value.trim();
                label.textContent = value || `Option ${i}`;
                checkbox.value = value;
                checkbox.disabled = !value;
                
                // Add change listener
                optInput.addEventListener('input', () => {
                    const newValue = optInput.value.trim();
                    label.textContent = newValue || `Option ${i}`;
                    checkbox.value = newValue;
                    checkbox.disabled = !newValue;
                    if (!newValue) {
                        checkbox.checked = false;
                    }
                });
            }
        }

        // Initialize multiple select checkboxes if needed
        if (document.getElementById('questionTypeSelect').value === "MultipleSelect") {
            initializeMultipleSelectCheckboxes();
        }

        document.querySelectorAll('.edit-correct-checkbox').forEach(cb => {
            cb.addEventListener('change', function() {
                if (document.querySelectorAll('.edit-correct-checkbox:checked').length > 2) {
                    this.checked = false;
                    alert("You can only select 2 correct answers.");
                }
            });
        });

        document.getElementById('questionTypeSelect').addEventListener('change', toggleEditOptions);
        document.getElementById('editQuestionForm').addEventListener('submit', validateAndSubmit);
        
        // Initialize image upload functionality
        initEditImageUpload();
    });
</script>