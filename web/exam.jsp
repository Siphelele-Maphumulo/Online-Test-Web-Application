
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/gh/Bernardo-Castilho/dragdroptouch@master/DragDropTouch.js"></script>
<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.Exams"%>
<%
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    
    // Generate CSRF token if not exists
    if (session.getAttribute("csrf_token") == null) {
        String csrfToken = java.util.UUID.randomUUID().toString();
        session.setAttribute("csrf_token", csrfToken);
    }
    
    // CHECK IF USER IS TRYING TO ACCESS EXAM WITHOUT ACTIVE SESSION
    String showExamForm = "true"; // Default to showing exam selection form
    
    // Only show active exam if BOTH conditions are met:
    // 1. session has examStarted = "1"
    // 2. URL has coursename parameter
    if ("1".equals(String.valueOf(session.getAttribute("examStarted"))) && 
        request.getParameter("coursename") != null && 
        !request.getParameter("coursename").isEmpty()) {
        showExamForm = "false"; // Show active exam
    } else {
        // Clear any stale exam session data
        session.removeAttribute("examStarted");
        session.removeAttribute("examId");
    }
%>

<%!
    // Function to escape HTML characters for safe display in attributes
    public String escapeHtmlAttr(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;");
    }

    // Helper method to format duration in minutes to readable format
    private String formatDuration(int minutes) {
        if (minutes < 60) {
            return minutes + " minute" + (minutes != 1 ? "s" : "");
        } else {
            int hours = minutes / 60;
            int remainingMinutes = minutes % 60;
            if (remainingMinutes == 0) {
                return hours + " hour" + (hours != 1 ? "s" : "");
            } else {
                return hours + " hour" + (hours != 1 ? "s" : "") + " " + 
                       remainingMinutes + " minute" + (remainingMinutes != 1 ? "s" : "");
            }
        }
    }
%>


<style>
    /* CSS Variables for Maintainability - PROFESSIONAL THEME */
    :root {
        /* Primary Colors - Professional Blue Theme */
        --primary-blue: #09294d;
        --secondary-blue: #1a3d6d;
        --accent-blue: #3b82f6;
        --accent-blue-light: #60a5fa;
        
        /* Neutral Colors - Modern Gray Scale */
        --white: #ffffff;
        --light-gray: #f8fafc;
        --medium-gray: #e2e8f0;
        --dark-gray: #64748b;
        --text-dark: #1e293b;
        --border-color: #e5e7eb;
        
        /* Semantic Colors */
        --success: #10b981;
        --success-light: #d1fae5;
        --warning: #f59e0b;
        --warning-light: #fef3c7;
        --error: #ef4444;
        --error-light: #fee2e2;
        --info: #0ea5e9;
        --info-light: #e0f2fe;
        
        /* Spacing - 8px grid */
        --spacing-xs: 4px;
        --spacing-sm: 8px;
        --spacing-md: 16px;
        --spacing-lg: 24px;
        --spacing-xl: 32px;
        --spacing-2xl: 48px;
        
        /* Border Radius - Modern */
        --radius-sm: 6px;
        --radius-md: 10px;
        --radius-lg: 16px;
        --radius-xl: 24px;
        --radius-full: 9999px;
        
        /* Shadows - Material Design inspired */
        --shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
        --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        
        /* Transitions */
        --transition-fast: 150ms cubic-bezier(0.4, 0, 0.2, 1);
        --transition-normal: 200ms cubic-bezier(0.4, 0, 0.2, 1);
        --transition-slow: 300ms cubic-bezier(0.4, 0, 0.2, 1);
        
        /* Z-index layers */
        --z-dropdown: 100;
        --z-sticky: 200;
        --z-modal: 300;
        --z-popover: 400;
        --z-tooltip: 500;
    }
    
    /* Reset and Base Styles */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        line-height: 1.5;
        color: var(--text-dark);
        background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        min-height: 100vh;
        font-weight: 400;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
    }
    
    /* Dashboard Container */
    .dashboard-container {
        display: flex;
        min-height: 100vh;
        background: transparent;
    }
    
    /* Sidebar - Modern Design */
    .sidebar {
        width: 200px;
        background: linear-gradient(180deg, var(--primary-blue) 0%, #0d3060 100%);
        color: var(--white);
        flex-shrink: 0;
        position: fixed;
        top: 0;
        left: 0;
        height: 100vh;
        z-index: var(--z-sticky);
        box-shadow: var(--shadow-lg);
        border-right: 1px solid rgba(255, 255, 255, 0.1);
        overflow-y: auto;
        scrollbar-width: thin;
        scrollbar-color: rgba(255, 255, 255, 0.3) transparent;
    }
    
    .sidebar::-webkit-scrollbar {
        width: 6px;
    }
    
    .sidebar::-webkit-scrollbar-track {
        background: transparent;
    }
    
    .sidebar::-webkit-scrollbar-thumb {
        background-color: rgba(255, 255, 255, 0.3);
        border-radius: var(--radius-full);
    }
    
    /* Main Content Area - Add margin to account for fixed sidebar */
    .content-area,
    .main-content {
        flex: 1;
        padding: var(--spacing-xl);
        overflow-y: auto;
        background: transparent;
        margin-left: 180px;
        min-height: 100vh;
    }
    
    /* Responsive Design - Adjust for mobile */
    @media (max-width: 768px) {
        .sidebar {
            width: 100%;
            height: auto;
            position: static;
        }
        
        .content-area,
        .main-content {
            margin-left: 0;
            padding: var(--spacing-lg);
        }
    }
    
    .sidebar-header {
        padding-top: 35%;
        text-align: center;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        background: rgba(255, 255, 255, 0.05);
        backdrop-filter: blur(10px);
    }
    
    .mut-logo {
        max-height: 150px;
        width: auto;
        filter: brightness(0) invert(1);
    }
    
    .mut-logo:hover {
        transform: scale(1.05);
    }
    
    .sidebar-nav {
        padding: var(--spacing-lg) 0;
    }
    
    .nav-item {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        padding: var(--spacing-md) var(--spacing-lg);
        color: rgba(255, 255, 255, 0.85);
        text-decoration: none;
        transition: all var(--transition-normal);
        border-radius: var(--radius-md);
        margin: 0 var(--spacing-sm) var(--spacing-sm);
        font-weight: 500;
        font-size: 14px;
        position: relative;
        overflow: hidden;
    }
    
    .nav-item::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        width: 4px;
        height: 100%;
        background: var(--accent-blue);
        transform: translateX(-100%);
        transition: transform var(--transition-normal);
    }
    
    .nav-item:hover {
        background: rgba(255, 255, 255, 0.1);
        color: var(--white);
        padding-left: var(--spacing-xl);
    }
    
    .nav-item:hover::before {
        transform: translateX(0);
    }
    
    .nav-item.active {
        background: linear-gradient(90deg, rgba(59, 130, 246, 0.2), rgba(59, 130, 246, 0.1));
        color: var(--white);
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
    }
    
    .nav-item.active::before {
        transform: translateX(0);
    }
    
    .nav-item i {
        width: 20px;
        text-align: center;
        font-size: 16px;
        opacity: 0.9;
    }
    
    /* Layout Structure */
    .exam-wrapper {
        display: flex;
        min-height: 100vh;
        background: var(--light-gray);
    }
    
    .left-menu a {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        padding: var(--spacing-md) var(--spacing-lg);
        color: rgba(255, 255, 255, 0.8);
        text-decoration: none;
        transition: all var(--transition-normal);
        border-left: 3px solid transparent;
        font-weight: 500;
        font-size: 14px;
    }
    
    .left-menu a:hover {
        background: rgba(255, 255, 255, 0.1);
        color: var(--white);
        border-left-color: var(--accent-blue);
    }
    
    .left-menu a.active {
        background: rgba(255, 255, 255, 0.15);
        color: var(--white);
        border-left-color: var(--white);
    }
    
    .left-menu a i {
        width: 20px;
        text-align: center;
    }
    
    /* Page Header */
    .page-header {
        background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
        border-radius: var(--radius-lg);
        padding: var(--spacing-xl);
        margin-bottom: var(--spacing-xl);
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
        position: relative;
        overflow: hidden;
    }
    
    .page-header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 4px;
        background: linear-gradient(90deg, var(--accent-blue), var(--success));
    }
    
    .page-title {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        font-size: 20px;
        font-weight: 600;
        color: var(--text-dark);
    }
    
    .page-title i {
        color: var(--accent-blue);
        background: var(--accent-blue-light);
        padding: var(--spacing-sm);
        border-radius: var(--radius-md);
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
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
    
    /* Fixed Bottom Timer & Progress Bar */
    .fixed-bottom-panel {
        position: fixed;
        bottom: 0;
        left: 20%;
        right: 0;
        background: var(--white);
        border-top: 1px solid var(--medium-gray);
        box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
        z-index: 100;
        padding: var(--spacing-md);
    }
    
    .timer-progress-wrapper {
        display: flex;
        justify-content: space-between;
        align-items: center;
        max-width: 1200px;
        margin: 0 auto;
        gap: var(--spacing-lg);
    }
    
    .timer-section {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
    }
    
    .progress-section {
        flex: 1;
        max-width: 400px;
    }
    
    /* Questions Container */
    .questions-container {
        display: flex;
        flex-direction: column;
        gap: var(--spacing-lg);
        margin-bottom: 140px;
    }
    
    /* Question Card */
    .question-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        padding: var(--spacing-lg);
        transition: transform var(--transition-normal), box-shadow var(--transition-normal);
        position: relative;
    }
    
    .question-card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-lg);
    }
    
    .question-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 4px;
        height: 100%;
        background: linear-gradient(180deg, var(--primary-blue), var(--secondary-blue));
    }
    
    .question-header {
        display: flex;
        align-items: flex-start;
        margin-bottom: var(--spacing-md);
        gap: var(--spacing-md);
    }
    
    .question-label {
        display: inline-flex;
        width: 36px;
        height: 36px;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        border-radius: var(--radius-sm);
        font-weight: 600;
        font-size: 14px;
        flex-shrink: 0;
    }
    
    .question-content {
        flex: 1;
        display: flex;
        flex-direction: column;
        min-width: 0;
    }
    
    /* Code Snippet Styling */
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
    
    /* Question Image Styles */
    .question-image-container {
        margin: var(--spacing-md) 0;
        text-align: center;
    }
    
    .question-image {
        max-width: 100%;
        max-height: 400px;
        height: auto;
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        background: var(--white);
        padding: var(--spacing-md);
        object-fit: contain;
    }
    
    /* Responsive adjustments for images */
    @media (max-width: 768px) {
        .question-image {
            max-height: 300px;
            padding: var(--spacing-sm);
        }
    }
    
    @media (max-width: 480px) {
        .question-image {
            max-height: 250px;
        }
    }
    
    /* Answers Section */
    .answers {
        margin-top: var(--spacing-md);
    }
    
    .multi-select-note {
        background: #eff6ff;
        padding: var(--spacing-sm) var(--spacing-md);
        border-radius: var(--radius-sm);
        margin-bottom: var(--spacing-md);
        border-left: 3px solid var(--accent-blue);
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        font-weight: 500;
        color: var(--text-dark);
        font-size: 13px;
    }
    
    .form-check {
        padding: var(--spacing-sm) var(--spacing-md);
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        margin-bottom: var(--spacing-sm);
        background: var(--white);
        transition: all var(--transition-fast);
        cursor: pointer;
        display: flex;
        align-items: flex-start;
    }
    
    .form-check:hover {
        background: var(--light-gray);
        border-color: var(--accent-blue);
    }
    
    .form-check.selected {
        background: #eff6ff;
        border-color: var(--accent-blue);
    }
    
    .form-check-input {
        width: 18px;
        height: 18px;
        margin-top: 3px;
        cursor: pointer;
        flex-shrink: 0;
    }
    
    .form-check-input:checked {
        background-color: var(--primary-blue);
        border-color: var(--primary-blue);
    }
    
    .form-check-label {
        font-weight: 500;
        color: var(--dark-gray);
        margin-left: var(--spacing-md);
        cursor: pointer;
        line-height: 1.5;
        font-size: 14px;
        word-wrap: break-word;
        flex: 1;
    }
    
    /* SUBMIT SECTION */
    .submit-section {
        margin-top: 60px;
        margin-bottom: 100px;
        display: flex;
        justify-content: center;
        align-items: center;
    }
    
    .submit-card {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-lg);
        border: 1px solid var(--medium-gray);
        max-width: 600px;
        width: 100%;
        overflow: hidden;
        transition: transform var(--transition-normal), box-shadow var(--transition-slow);
    }
    
    .submit-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
    }
    
    .submit-header {
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: var(--spacing-lg) var(--spacing-xl);
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        font-size: 18px;
        font-weight: 600;
    }
    
    .submit-header i {
        font-size: 24px;
        opacity: 0.9;
    }
    
    .submit-content {
        padding: var(--spacing-xl);
    }
    
    /* Warning Box */
    .warning-box {
        display: flex;
        align-items: flex-start;
        gap: var(--spacing-md);
        background: linear-gradient(135deg, #fffbeb, #fef3c7);
        border: 1px solid #f59e0b;
        border-radius: var(--radius-md);
        padding: var(--spacing-lg);
        margin-bottom: var(--spacing-xl);
    }
    
    .warning-icon {
        flex-shrink: 0;
        width: 48px;
        height: 48px;
        background: #f59e0b;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--white);
        font-size: 20px;
    }
    
    .warning-text strong {
        color: #92400e;
        font-size: 16px;
        font-weight: 600;
        display: block;
        margin-bottom: var(--spacing-xs);
    }
    
    .warning-text p {
        color: #78350f;
        font-size: 14px;
        line-height: 1.5;
        margin: 0;
    }
    
    /* Submit Stats */
    .submit-stats {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-lg);
        margin-bottom: var(--spacing-xl);
    }
    
    .stat-item {
        text-align: center;
        padding: var(--spacing-md);
        min-width: 80px;
    }
    
    .stat-number {
        display: block;
        font-size: 28px;
        font-weight: 700;
        color: var(--primary-blue);
        margin-bottom: var(--spacing-xs);
    }
    
    .stat-label {
        font-size: 13px;
        color: var(--dark-gray);
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .stat-divider {
        width: 1px;
        height: 40px;
        background: var(--medium-gray);
    }
    
    /* Submit Footer */
    .submit-footer {
        padding: 0 var(--spacing-xl) var(--spacing-xl);
        text-align: center;
    }
    
    .submit-btn {
        background: linear-gradient(135deg, var(--success), #10b981);
        border: none;
        border-radius: var(--radius-lg);
        padding: 16px 48px;
        font-size: 16px;
        font-weight: 600;
        color: var(--white);
        cursor: pointer;
        transition: all var(--transition-normal);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
        box-shadow: 0 4px 15px rgba(5, 150, 105, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .submit-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(5, 150, 105, 0.4);
    }
    
    .submit-btn:active {
        transform: translateY(0);
    }
    
    .submit-btn:disabled {
        background: var(--dark-gray);
        transform: none;
        cursor: not-allowed;
        box-shadow: none;
    }
    
    .btn-text {
        transition: opacity var(--transition-fast);
    }
    
    .btn-loading {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
    }
    
    .submit-btn.loading .btn-text {
        opacity: 0;
    }
    
    .submit-btn.loading .btn-loading {
        display: block !important;
    }
    
    .submit-guarantee {
        margin-top: var(--spacing-md);
        display: flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
        color: var(--dark-gray);
        font-size: 12px;
        font-weight: 500;
    }
    
    .submit-guarantee i {
        color: var(--success);
    }
    
    /* Action Button */
    .action-btn {
        background: linear-gradient(135deg, var(--accent-blue), var(--accent-blue-light));
        color: var(--white);
        border: none;
        border-radius: var(--radius-md);
        padding: 10px 20px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: all var(--transition-normal);
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        position: relative;
        overflow: hidden;
    }
    
    .action-btn::after {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transform: translateX(-100%);
        transition: transform 0.6s;
    }
    
    .action-btn:hover::after {
        transform: translateX(100%);
    }
    
    .action-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25);
    }
    
    /* Course Selection */
    .course-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        padding: var(--spacing-xl);
        margin-bottom: var(--spacing-lg);
        max-width: 500px;
        margin-left: auto;
        margin-right: auto;
    }
    
    .form-label {
        font-weight: 600;
        color: var(--text-dark);
        margin-bottom: var(--spacing-sm);
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .form-select {
        width: 100%;
        padding: var(--spacing-sm) var(--spacing-md);
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        font-size: 14px;
        transition: all var(--transition-fast);
        background: var(--white);
        color: var(--text-dark);
        margin-bottom: var(--spacing-md);
    }
    
    .form-select:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }
    
    .start-exam-btn {
        background: linear-gradient(90deg, var(--success), #10b981);
        border: none;
        border-radius: var(--radius-sm);
        padding: 12px var(--spacing-lg);
        font-size: 14px;
        font-weight: 500;
        color: var(--white);
        cursor: pointer;
        transition: all var(--transition-normal);
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
    }
    
    .start-exam-btn:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(5, 150, 105, 0.2);
    }
    
    /* Result Display */
    .result-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        padding: var(--spacing-xl);
        margin-bottom: var(--spacing-lg);
        max-width: 600px;
        margin-left: auto;
        margin-right: auto;
    }
    
    .result-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: var(--spacing-lg);
        margin-top: var(--spacing-lg);
    }
    
    .result-item {
        background: var(--light-gray);
        padding: var(--spacing-lg);
        border-radius: var(--radius-sm);
        border-left: 3px solid var(--primary-blue);
        transition: transform var(--transition-fast);
    }
    
    .result-item:hover {
        transform: translateY(-2px);
    }
    
    .result-item strong {
        color: var(--text-dark);
        display: block;
        margin-bottom: var(--spacing-sm);
        font-size: 14px;
        font-weight: 600;
    }
    
    .result-value {
        color: var(--dark-gray);
        font-size: 18px;
        font-weight: 600;
    }
    
    .status-pass {
        color: var(--success);
    }
    
    .status-fail {
        color: var(--error);
    }
    
    .percentage-badge {
        background: linear-gradient(90deg, var(--info), #0ea5e9);
        color: var(--white);
        padding: 6px 16px;
        border-radius: 16px;
        font-weight: 600;
        font-size: 13px;
        display: inline-block;
    }
    
    /* FLOATING PROGRESS BUTTON */
    .progress-float-btn {
        position: fixed;
        bottom: 100px;
        right: 30px;
        width: 60px;
        height: 60px;
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        border: none;
        border-radius: 50%;
        color: var(--white);
        font-size: 20px;
        cursor: pointer;
        box-shadow: 0 4px 20px rgba(9, 41, 77, 0.3);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 2px;
        transition: all var(--transition-normal);
        z-index: 200;
    }
    
    .progress-float-btn:hover {
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 8px 30px rgba(9, 41, 77, 0.4);
    }
    
    .progress-float-btn:active {
        transform: translateY(-1px) scale(0.98);
    }
    
    .float-counter {
        font-size: 10px;
        font-weight: 600;
        background: rgba(255, 255, 255, 0.2);
        padding: 2px 6px;
        border-radius: 10px;
        min-width: 20px;
        text-align: center;
    }
    
    /* PROGRESS MODAL */
    .progress-modal {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        z-index: 300;
        backdrop-filter: blur(4px);
    }
    
    .progress-modal.active {
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .modal-content {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        max-width: 500px;
        width: 90%;
        max-height: 80vh;
        overflow: hidden;
        animation: modalSlideIn 0.3s ease-out;
    }
    
    @keyframes modalSlideIn {
        from {
            opacity: 0;
            transform: translateY(-50px) scale(0.9);
        }
        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }
    
    .modal-header {
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: var(--spacing-lg) var(--spacing-xl);
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .close-modal {
        background: none;
        border: none;
        color: var(--white);
        font-size: 24px;
        cursor: pointer;
        padding: 0;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: background-color var(--transition-fast);
    }
    
    .close-modal:hover {
        background: rgba(255, 255, 255, 0.2);
    }
    
    .modal-body {
        padding: var(--spacing-xl);
    }
    
    .progress-summary {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: var(--spacing-lg);
        margin-bottom: var(--spacing-xs);
    }
    
    .progress-circle {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .progress-ring {
        transform: rotate(-90deg);
    }
    
    .progress-ring-circle {
        transition: stroke-dashoffset 0.35s;
        stroke-linecap: round;
    }
    
    .progress-ring-progress {
        transition: stroke-dashoffset 0.35s;
        stroke-linecap: round;
    }
    
    .progress-text {
        position: absolute;
        text-align: center;
    }
    
    .progress-text .progress-percent {
        display: block;
        font-size: 20px;
        font-weight: 700;
        color: var(--primary-blue);
    }
    
    .progress-text small {
        font-size: 8px;
        color: var(--dark-gray);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: var(--spacing-md);
        width: 100%;
    }
    
    .stat-box {
        text-align: center;
        padding: var(--spacing-md);
        border-radius: var(--radius-md);
        transition: transform var(--transition-fast);
    }
    
    .stat-box:hover {
        transform: translateY(-2px);
    }
    
    .stat-box.answered {
        background: linear-gradient(135deg, #ecfdf5, #d1fae5);
        border: 1px solid #a7f3d0;
    }
    
    .stat-box.unanswered {
        background: linear-gradient(135deg, #fffbeb, #fef3c7);
        border: 1px solid #fde68a;
    }
    
    .stat-box.total {
        background: linear-gradient(135deg, #eff6ff, #dbeafe);
        border: 1px solid #bfdbfe;
    }
    
    .stat-box i {
        font-size: 24px;
        margin-bottom: var(--spacing-xs);
    }
    
    .stat-box.answered i {
        color: var(--success);
    }
    
    .stat-box.unanswered i {
        color: var(--warning);
    }
    
    .stat-box.total i {
        color: var(--info);
    }
    
    .stat-count {
        display: block;
        font-size: 20px;
        font-weight: 700;
        margin-bottom: 2px;
    }
    
    .stat-label {
        font-size: 11px;
        color: var(--dark-gray);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .progress-bar-container {
        margin-top: var(--spacing-lg);
    }
    
    .progress-info {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: var(--spacing-sm);
        font-size: 8px;
        font-weight: 600;
        color: var(--text-dark);
    }
    
    .modal-footer {
        padding: var(--spacing-lg) var(--spacing-xl);
        background: var(--light-gray);
        display: flex;
        gap: var(--spacing-md);
        justify-content: flex-end;
    }
    
    .btn-secondary {
        background: var(--white);
        border: 1px solid var(--medium-gray);
        color: var(--dark-gray);
        padding: 10px 20px;
        border-radius: var(--radius-sm);
        font-size: 10px;
        font-weight: 500;
        cursor: pointer;
        transition: all var(--transition-fast);
    }
    
    .btn-secondary:hover {
        background: var(--light-gray);
        border-color: var(--dark-gray);
    }
    
    .btn-primary {
        background: linear-gradient(135deg, var(--success), #10b981);
        border: none;
        color: var(--white);
        padding: 10px 24px;
        border-radius: var(--radius-sm);
        font-size: 10px;
        font-weight: 600;
        cursor: pointer;
        transition: all var(--transition-fast);
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .btn-primary:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(5, 150, 105, 0.3);
    }
    
    /* Timer and Progress Styles */
    .timer-badge {
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: 8px 16px;
        border-radius: 20px;
        font-size: 14px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .timer-badge span.time {
        order: -1;
    }
    
    .timer-badge.warning {
        background: linear-gradient(135deg, #f59e0b, #d97706);
        animation: pulse 1s infinite;
    }
    
    .timer-badge.critical {
        background: linear-gradient(135deg, #dc2626, #b91c1c);
        animation: pulse 0.5s infinite;
    }
    
    .timer-badge.expired {
        background: linear-gradient(135deg, #6b7280, #4b5563);
    }
    
    .stats-badge.warning {
        background: linear-gradient(135deg, #f59e0b, #d97706);
        animation: pulse 1s infinite;
    }
    
    .stats-badge.critical {
        background: linear-gradient(135deg, #dc2626, #b91c1c);
        animation: pulse 0.5s infinite;
    }
    
    .stats-badge.expired {
        background: linear-gradient(135deg, #6b7280, #4b5563);
    }
    
    @keyframes pulse {
        0% { opacity: 1; }
        50% { opacity: 0.7; }
        100% { opacity: 1; }
    }
    
    /* Progress Bar Styles */
    .progress {
        height: 8px;
        background-color: var(--medium-gray);
        border-radius: var(--radius-sm);
        overflow: hidden;
        margin-top: var(--spacing-xs);
    }
    
    .progress-bar {
        height: 100%;
        background: var(--success);
        border-radius: var(--radius-sm);
        transition: width 0.3s ease;
    }
    
    .progress-label {
        display: flex;
        justify-content: space-between;
        font-size: 12px;
        color: var(--dark-gray);
        font-weight: 500;
        margin-bottom: 4px;
    }
    
    /* Modal Progress Bar */
    .modal .progress {
        height: 12px;
    }
    
    .modal .progress-bar {
        background: linear-gradient(90deg, var(--success), #10b981);
    }
    
    /* Form Check Input Styles */
    .form-check-input[type="radio"] {
        border-radius: 50%;
    }
    
    .form-check-input[type="checkbox"] {
        border-radius: var(--radius-sm);
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
    
    /* CONFIRMATION MODAL STYLES */
    .modal-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        z-index: 1000;
        backdrop-filter: blur(4px);
        align-items: center;
        justify-content: center;
    }
    
    .modal-container {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        max-width: 500px;
        width: 90%;
        overflow: hidden;
        animation: modalSlideIn 0.3s ease-out;
    }
    
    .modal-container .modal-header {
        background: linear-gradient(135deg, var(--warning), #f59e0b);
        color: var(--white);
        padding: var(--spacing-lg) var(--spacing-xl);
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .modal-title {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .modal-container .modal-body {
        padding: var(--spacing-xl);
    }
    
    .modal-container .modal-body p {
        margin-bottom: var(--spacing-lg);
        font-size: 16px;
        line-height: 1.5;
        color: var(--text-dark);
    }
    
    .modal-container .modal-body ul {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    
    .modal-container .modal-body li {
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        padding: var(--spacing-sm) 0;
        font-size: 14px;
        color: var(--dark-gray);
    }
    
    .modal-container .modal-body li i {
        color: var(--warning);
        width: 20px;
    }
    
    .modal-container .modal-body li strong {
        color: var(--text-dark);
        margin-right: var(--spacing-xs);
    }
    
    .modal-container .modal-footer {
        padding: var(--spacing-lg) var(--spacing-xl);
        background: var(--light-gray);
        display: flex;
        gap: var(--spacing-md);
        justify-content: flex-end;
        border-top: 1px solid var(--medium-gray);
    }
    
    /* DELETE MODAL STYLES */
    .delete-modal {
        display: none;
        position: fixed;
        z-index: 1100;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.5);
        align-items: center;
        justify-content: center;
    }
    
    .delete-modal .modal-content {
        background-color: #fff;
        margin: 10% auto;
        padding: 0;
        border-radius: 8px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        max-width: 500px;
        width: 90%;
        animation: modalSlideIn 0.3s ease-out;
    }
    
    .delete-modal .modal-header {
        padding: 16px 20px;
        background-color: #f8f9fa;
        border-bottom: 1px solid #dee2e6;
        border-radius: 8px 8px 0 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .delete-modal .modal-header h3 {
        margin: 0;
        color: #333;
        font-size: 18px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .delete-modal .close-modal {
        color: #aaa;
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
        line-height: 20px;
    }
    
    .delete-modal .close-modal:hover {
        color: #000;
    }
    
    .delete-modal .modal-body {
        padding: 20px;
        color: #333;
        font-size: 16px;
        line-height: 1.5;
    }
    
    .delete-modal .modal-footer {
        padding: 16px 20px;
        background-color: #f8f9fa;
        border-top: 1px solid #dee2e6;
        border-radius: 0 0 8px 8px;
        text-align: right;
        display: flex;
        gap: 10px;
        justify-content: flex-end;
    }
    
    /* Delete Modal Button Styles */
    .btn-outline {
        background: transparent;
        border: 1px solid var(--medium-gray);
        color: var(--dark-gray);
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.3s ease;
    }
    
    .btn-outline:hover {
        background: var(--light-gray);
        border-color: var(--dark-gray);
    }
    
    .btn-danger {
        background: linear-gradient(135deg, #dc2626, #b91c1c);
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .btn-danger:hover {
        background: linear-gradient(135deg, #b91c1c, #991b1b);
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.3);
    }
    
    .btn-danger:disabled {
        background: #9ca3af;
        cursor: not-allowed;
        transform: none;
        box-shadow: none;
    }
    
    /* Responsive Design */
    @media (max-width: 768px) {
        .exam-wrapper {
            flex-direction: column;
        }
        
        .fixed-bottom-panel {
            padding-right: 20%;
        }
        
        .timer-progress-wrapper {
            flex-direction: column;
            gap: var(--spacing-md);
        }
        
        .progress-section {
            max-width: 100%;
        }
        
        .page-header {
            flex-direction: column;
            gap: var(--spacing-md);
            text-align: center;
        }
        
        .result-grid {
            grid-template-columns: 1fr;
        }
        
        .question-header {
            flex-direction: column;
            text-align: center;
        }
        
        .submit-section {
            margin-top: 40px;
            margin-bottom: 80px;
            padding: 0 var(--spacing-md);
        }
        
        .submit-card {
            margin: 0;
        }
        
        .submit-header {
            padding: var(--spacing-md) var(--spacing-lg);
            font-size: 16px;
        }
        
        .submit-content {
            padding: var(--spacing-lg);
        }
        
        .warning-box {
            flex-direction: column;
            text-align: center;
        }
        
        .submit-stats {
            flex-direction: column;
            gap: var(--spacing-md);
        }
        
        .stat-divider {
            width: 60px;
            height: 1px;
        }
        
        .submit-footer {
            padding: 0 var(--spacing-lg) var(--spacing-lg);
        }
        
        .submit-btn {
            padding: 14px 36px;
            font-size: 15px;
        }
        
        .progress-float-btn {
            bottom: 80px;
            right: 20px;
            width: 50px;
            height: 50px;
            font-size: 18px;
        }
        
        .modal-content,
        .modal-container {
            margin: var(--spacing-md);
            width: auto;
        }
        
        .stats-grid {
            grid-template-columns: 1fr;
        }
        
        .modal-footer {
            flex-direction: column;
        }
        
        .modal-container .modal-footer {
            flex-direction: column;
        }
        
        .delete-modal .modal-footer {
            flex-direction: column;
        }
    }
    
    @media (max-width: 480px) {
        .content-area {
            padding: var(--spacing-sm);
            padding-bottom: 200px;
        }
        
        .question-card,
        .course-card,
        .result-card {
            padding: var(--spacing-md);
        }
        
        .form-check {
            padding: var(--spacing-sm);
        }
        
        .submit-section {
            margin-top: 30px;
            margin-bottom: 60px;
            padding: 0 var(--spacing-sm);
        }
        
        .submit-header {
            padding: var(--spacing-md);
            font-size: 15px;
        }
        
        .submit-content {
            padding: var(--spacing-md);
        }
        
        .warning-icon {
            width: 40px;
            height: 40px;
            font-size: 18px;
        }
        
        .stat-number {
            font-size: 24px;
        }
        
        .submit-btn {
            padding: 12px 28px;
            font-size: 14px;
        }
        
        .progress-float-btn {
            bottom: 70px;
            right: 15px;
            width: 45px;
            height: 45px;
            font-size: 16px;
        }
        
        .float-counter {
            font-size: 9px;
            min-width: 18px;
        }
        
        .modal-container .modal-body {
            padding: var(--spacing-lg);
        }
        
        .modal-container .modal-footer {
            padding: var(--spacing-md);
        }
    }
    
    /* Drag and Drop Question Styles - PHASE 3 Implementation */
    .drag-drop-question {
        background: white;
        border-radius: 12px;
        padding: 0;
        margin: var(--spacing-md) 0;
        box-shadow: var(--shadow-md);
        overflow: hidden;
    }
    
    .drag-drop-instructions {
        text-align: left;
        padding: var(--spacing-md) var(--spacing-lg);
        background: #f8fafc;
        border-bottom: 1px solid var(--medium-gray);
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
    }
    
    .drag-drop-instructions i {
        font-size: 20px;
        color: var(--accent-blue);
        background: white;
        padding: 10px;
        border-radius: 8px;
        box-shadow: var(--shadow-sm);
    }
    
    .drag-drop-instructions strong {
        display: block;
        font-size: 15px;
        color: var(--text-dark);
        margin-bottom: 2px;
    }
    
    .drag-drop-instructions p {
        margin: 0;
        color: var(--dark-gray);
        font-size: 13px;
    }
    
    .drag-drop-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 30px;
        padding: 20px;
        background: white;
    }
    
    .draggable-items-panel {
        background: #f5f7fa;
        border-radius: 10px;
        padding: 20px;
    }
    
    .drop-targets-panel {
        background: white;
        border-radius: 10px;
        padding: 20px;
        border: 2px dashed #ccc;
    }
    
    .panel-header {
        margin-bottom: 20px;
        color: var(--text-dark);
        font-size: 14px;
        font-weight: 600;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
    }
    
    .panel-header i {
        color: var(--accent-blue);
    }
    
    .shuffle-btn {
        background: transparent;
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        padding: 6px 10px;
        color: var(--dark-gray);
        cursor: pointer;
        transition: all var(--transition-fast);
        font-size: 12px;
    }
    
    .shuffle-btn:hover {
        background: var(--primary-blue);
        color: white;
        border-color: var(--primary-blue);
    }
    
    .drag-items-list, .drop-targets-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    
    .drag-item {
        background: #92AB2F;
        border: 2px solid #5D8E2;
        border-radius: 8px;
        padding: 15px 20px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        cursor: grab;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 10px;
        transition: all 0.2s;
        font-size: 14px;
        color: white;
        user-select: none;
    }
    
    .drag-item::before {
        content: '?';
        font-size: 18px;
        color: white;
        font-weight: bold;
    }
    
    .drag-item:hover {
        background: #7FB069;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        border-color: #5D8E2;
    }
    
    .drag-item.dragging {
        opacity: 0.7;
        box-shadow: 0 8px 15px rgba(0,0,0,0.2);
        cursor: grabbing;
        transform: scale(1.02);
    }
    
    .drop-target {
        background: #f8fafc;
        border: 2px dashed #94a3b8;
        border-radius: 8px;
        padding: 20px;
        min-height: 80px;
        position: relative;
        display: flex;
        flex-direction: column;
        gap: 10px;
        transition: all 0.2s;
    }
    
    .drop-target.waiting {
        border: 2px dashed #92AB2F;
        animation: blinkBorder 1.5s infinite;
    }
    
    @keyframes blinkBorder {
        0%, 50% { border-color: #92AB2F; border-style: dashed; }
        25%, 75% { border-color: #5D8E2; border-style: solid; }
        100% { border-color: #92AB2F; border-style: dashed; }
    }
    
    .drop-target-header {
        font-size: 13px;
        font-weight: 600;
        color: var(--dark-gray);
        margin-bottom: 5px;
    }
    
    .drop-target.drag-over {
        border-color: #3b82f6;
        background: #eff6ff;
        border-style: solid;
        transform: scale(1.02);
    }
    
    .drop-target .placeholder {
        font-style: italic;
        color: var(--dark-gray);
        font-size: 13px;
        text-align: center;
        margin: auto;
    }
    
    .dropped-item {
        background: white;
        border: 1px solid #3b82f6;
        border-left: 4px solid #3b82f6;
        border-radius: 6px;
        padding: 12px 15px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-size: 14px;
        font-weight: 500;
        box-shadow: var(--shadow-sm);
        animation: slideIn 0.3s ease-out;
    }
    
    @keyframes slideIn {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .remove-btn {
        background: #fee2e2;
        color: #ef4444;
        border: none;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        opacity: 0;
        transition: opacity 0.2s;
        font-size: 14px;
    }
    
    .dropped-item:hover .remove-btn {
        opacity: 1;
    }
    
    .remove-btn:hover {
        background: #fecaca;
        transform: scale(1.1);
    }
    
    @media (max-width: 768px) {
        .drag-drop-container {
            grid-template-columns: 1fr;
        }
        
        .drag-items-section, .drop-targets-section {
            margin-bottom: var(--spacing-md);
        }
    }
    
    @media (min-width: 1440px) {
        .content-area {
            max-width: calc(100% - 250px);
        }
    }
</style>

<div class="exam-wrapper">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
        </div>
        <nav class="sidebar-nav">
            <div class="left-menu">
                <a class="nav-item" href="std-page.jsp?pgprt=0"><i class="fas fa-user"></i><span>Profile</span></a>
                <a class="nav-item active" href="std-page.jsp?pgprt=1"><i class="fas fa-file-alt"></i><span>Exams</span></a>
                <a class="nav-item" href="std-page.jsp?pgprt=2"><i class="fas fa-chart-line"></i><span>Results</span></a>
                <a class="nav-item" href="std-page.jsp?pgprt=3"><i class="fas fa-chart-line"></i><span>Exam Results</span></a>
            </div>
        </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="content-area">
        <% if ("false".equals(showExamForm)) { 
            // SHOW ACTIVE EXAM
            String courseName = request.getParameter("coursename");
            ArrayList<Questions> questionsList = pDAO.getQuestions(courseName, 20);
            int totalQ = questionsList.size();
        %>
            <!-- EXAM ACTIVE -->
            <div class="page-header">
                <div class="page-title"><i class="fas fa-file-alt"></i> <%= courseName %> Exam</div>
            </div>

            <form id="myform" action="controller.jsp" method="post">
                <input type="hidden" name="page" value="exams">
                <input type="hidden" name="operation" value="submitted">
                <input type="hidden" name="size" value="<%= totalQ %>">
                <input type="hidden" name="totalmarks" value="<%= pDAO.getTotalMarksByName(courseName) %>">
                <input type="hidden" name="coursename" value="<%= courseName %>">

                <div class="questions-container">
                <% for (int i=0; i<totalQ; i++){
                    Questions q = questionsList.get(i);
                    boolean isMultiTwo = false;
                    boolean isDragDrop = false;
                    try{
                        String qt = q.getQuestion().toLowerCase();
                        String questionType = q.getQuestionType();
                        isMultiTwo = "MultipleSelect".equalsIgnoreCase(questionType) ||
                                    qt.contains("select two") || qt.contains("choose two") || 
                                    qt.contains("pick two") || qt.contains("multiple answers") || 
                                    qt.contains("two options") || qt.contains("multiple select") ||
                                    qt.contains("select multiple") || qt.contains("choose multiple");
                        isDragDrop = "DRAG_AND_DROP".equalsIgnoreCase(questionType);
                    } catch(Exception e) { 
                        isMultiTwo = false; 
                        isDragDrop = false;
                    }

                    String fullQuestion = q.getQuestion(), questionPart = "", codePart = "";
                    if(fullQuestion.contains("```")){
                        String[] parts = fullQuestion.split("```");
                        if(parts.length >= 2) {
                            questionPart = parts[0].trim();
                            codePart = parts[1].trim();
                        } else {
                            questionPart = fullQuestion.replace("```", "").trim();
                        }
                    } else {
                        boolean isCodeQuestion = fullQuestion.contains("def ") || fullQuestion.contains("function ") || 
                                                fullQuestion.contains("public ") || fullQuestion.contains("class ") ||
                                                fullQuestion.contains("print(") || fullQuestion.contains("console.") || 
                                                fullQuestion.contains("<?php") || fullQuestion.contains("import ") ||
                                                fullQuestion.contains("int ") || fullQuestion.contains("String ") || 
                                                fullQuestion.contains("printf(") || fullQuestion.contains("cout ");
                        if(isCodeQuestion) {
                            codePart = fullQuestion;
                            questionPart = "What is the output/result of this code?";
                        } else {
                            questionPart = fullQuestion;
                        }
                    }
                    
                    java.util.List<String> opts = new java.util.ArrayList<>();
                    if(q.getOpt1() != null && !q.getOpt1().trim().isEmpty()) opts.add(q.getOpt1());
                    if(q.getOpt2() != null && !q.getOpt2().trim().isEmpty()) opts.add(q.getOpt2());
                    if(q.getOpt3() != null && !q.getOpt3().trim().isEmpty()) opts.add(q.getOpt3());
                    if(q.getOpt4() != null && !q.getOpt4().trim().isEmpty()) opts.add(q.getOpt4());
                    
                    // Randomize the options for the question
                    java.util.Collections.shuffle(opts, new java.util.Random(new java.util.Date().getTime()));
                %>
                    <div class="question-card" data-qindex="<%= i %>">
                        <div class="question-header">
                            <div class="question-label"><%= i+1 %></div>
                            <div class="question-content">
                                <% if(!questionPart.isEmpty() && !questionPart.equals("What is the output/result of this code?")){ %>
                                    <p class="question-text"><%= questionPart %></p>
                                <% } %>
                                
                                <!-- Question Image -->
                                <% if(q.getImagePath() != null && !q.getImagePath().isEmpty()){ %>
                                    <div class="question-image-container">
                                        <img src="<%= q.getImagePath() %>" alt="Question Image" class="question-image" onerror="this.style.display='none';">
                                    </div>
                                <% } %>
                                
                                <% if(!codePart.isEmpty()){ %>
                                    <div class="code-question-indicator"><i class="fas fa-code"></i><strong>Code Analysis Question</strong></div>
                                    <div class="code-snippet">
                                        <div class="code-header"><i class="fas fa-code"></i><span>Code to Analyze</span></div>
                                        <pre><%= codePart %></pre>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        <div class="answers" data-max-select="<%= isMultiTwo?"2":"1" %>">
                            <% if(isDragDrop){ 
                                // Serialize relational data to JSON for JS
                                org.json.JSONArray itemsArray = new org.json.JSONArray();
                                if (q.getDragItems() != null && !q.getDragItems().isEmpty()) {
                                    for (myPackage.classes.DragItem di : q.getDragItems()) {
                                        org.json.JSONObject jo = new org.json.JSONObject();
                                        jo.put("id", di.getId());
                                        jo.put("text", di.getItemText());
                                        itemsArray.put(jo);
                                    }
                                } else if (q.getDragItemsJson() != null && !q.getDragItemsJson().isEmpty()) {
                                    // Fallback to JSON column if relational list is empty
                                    try {
                                        itemsArray = new org.json.JSONArray(q.getDragItemsJson());
                                    } catch (Exception e) {
                                        // Silently handle JSON parsing errors
                                    }
                                }
                                
                                org.json.JSONArray targetsArray = new org.json.JSONArray();
                                if (q.getDropTargets() != null && !q.getDropTargets().isEmpty()) {
                                    for (myPackage.classes.DropTarget dt : q.getDropTargets()) {
                                        org.json.JSONObject jo = new org.json.JSONObject();
                                        jo.put("id", dt.getId());
                                        jo.put("label", dt.getTargetLabel());
                                        targetsArray.put(jo);
                                    }
                                } else if (q.getDropTargetsJson() != null && !q.getDropTargetsJson().isEmpty()) {
                                    // Fallback to JSON column if relational list is empty
                                    try {
                                        targetsArray = new org.json.JSONArray(q.getDropTargetsJson());
                                    } catch (Exception e) {
                                        // Silently handle JSON parsing errors
                                    }
                                }
                            %>
                                <div class="drag-drop-question" 
                                     data-items-json="<%= escapeHtmlAttr(itemsArray.toString()) %>" 
                                     data-targets-json="<%= escapeHtmlAttr(targetsArray.toString()) %>">
                                    <div class="drag-drop-instructions">
                                        <i class="fas fa-hand-rock"></i>
                                        <div>
                                            <strong>Drag and Drop the Items</strong>
                                            <p>Match each item from the left panel to its corresponding target on the right.</p>
                                        </div>
                                    </div>
                                    
                                    <div class="drag-drop-container">
                                        <div class="draggable-items-panel">
                                            <div class="panel-header">
                                                <i class="fas fa-grip-vertical"></i> Draggable Items
                                                <button type="button" class="shuffle-btn" onclick="shuffleDraggableItems(<%= i %>)" title="Shuffle Items">
                                                    <i class="fas fa-random"></i>
                                                </button>
                                            </div>
                                            <div class="drag-items-list" id="dragItems_<%= i %>">
                                                <!-- Drag items will be loaded dynamically -->
                                            </div>
                                        </div>
                                        
                                        <div class="drop-targets-panel">
                                            <div class="panel-header">
                                                <i class="fas fa-bullseye"></i> Drop Targets
                                                <button type="button" class="shuffle-btn" onclick="shuffleDropTargets(<%= i %>)" title="Shuffle Targets">
                                                    <i class="fas fa-random"></i>
                                                </button>
                                            </div>
                                            <div class="drop-targets-list" id="dropTargets_<%= i %>">
                                                <!-- Drop targets will be loaded dynamically -->
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <input type="hidden" name="dragDropQuestion_<%= i %>" value="true">
                                    <input type="hidden" name="qid<%= i %>" value="<%= q.getQuestionId() %>">

                                    <!-- Step 12: Visible Debugging -->
                                    <div style="background: #fff3cd; border: 1px solid #ffeeba; padding: 10px; margin: 10px 0; font-size: 11px; display: none;" class="drag-debug">
                                        <strong>Debug Info (Question <%= i+1 %>):</strong>
                                        <div>Items: <code id="debug-items-<%= i %>"></code></div>
                                        <div>Targets: <code id="debug-targets-<%= i %>"></code></div>
                                    </div>
                                    <script>
                                        (function() {
                                            const itemsJson = '<%= escapeHtmlAttr(itemsArray.toString()) %>';
                                            const targetsJson = '<%= escapeHtmlAttr(targetsArray.toString()) %>';
                                            console.log('Question <%= i+1 %> Data:', { itemsJson, targetsJson });
                                            document.getElementById('debug-items-<%= i %>').textContent = itemsJson;
                                            document.getElementById('debug-targets-<%= i %>').textContent = targetsJson;
                                            // Uncomment to show debug info in UI
                                            // document.querySelector('.drag-debug').style.display = 'block';
                                        })();
                                    </script>
                                </div>
                            <% } else { %>
                                <% if(isMultiTwo){ %>
                                    <div class="multi-select-note"><i class="fas fa-check-double"></i><strong>Choose up to 2 answers</strong></div>
                                <% } %>
                                <% for(int oi=0; oi<opts.size(); oi++){
                                    String optVal = opts.get(oi);
                                    String inputId = "q"+i+"o"+(oi+1);
                                %>
                                    <div class="form-check">
                                        <input class="form-check-input answer-input <%= isMultiTwo?"multi":"single" %>" 
                                            type="<%= isMultiTwo?"checkbox":"radio" %>" 
                                            id="<%= inputId %>" 
                                            name="<%= isMultiTwo ? ("ans"+i+"_"+oi) : ("ans"+i) %>" 
                                            value="<%= optVal %>" 
                                            data-qindex="<%= i %>">
                                        <label class="form-check-label" for="<%= inputId %>"><%= optVal %></label>
                                    </div>
                                <% } %>
                                <% if(isMultiTwo){ %>
                                    <input type="hidden" id="ans<%= i %>-hidden" name="ans<%= i %>" value="">
                                <% } %>
                            <% } %>
                        </div>
                        <input type="hidden" name="question<%= i %>" value="<%= q.getQuestion() %>">
                        <input type="hidden" name="qid<%= i %>" value="<%= q.getQuestionId() %>">
                        <input type="hidden" name="qtype<%= i %>" value="<%= isDragDrop?"dragdrop":(isMultiTwo?"multi2":"single") %>">
                    </div>
                <% } %>
                </div>

                <!-- FLOATING PROGRESS BUTTON -->
                <button type="button" id="progressFloatBtn" class="progress-float-btn" title="Exam Progress">
                    <i class="fas fa-chart-pie"></i><span class="float-counter" id="floatCounter">0/<%= totalQ %></span>
                </button>

                <!-- PROGRESS / SUBMIT MODAL -->
                <div id="progressModal" class="progress-modal">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3><i class="fas fa-tachometer-alt"></i> Exam Progress</h3>
                            <button type="button" class="close-modal">&times;</button>
                        </div>
                        <div class="modal-body">
                            <div class="progress-summary">
                                <div class="progress-circle" data-progress="0">
                                    <svg class="progress-ring" width="80" height="80">
                                        <circle class="progress-ring-circle" stroke="#e2e8f0" stroke-width="6" fill="transparent" r="34" cx="40" cy="40"/>
                                        <circle class="progress-ring-progress" stroke="#059669" stroke-width="6" fill="transparent" r="34" cx="40" cy="40" stroke-dasharray="213.628" stroke-dashoffset="213.628"/>
                                    </svg>
                                    <div class="progress-text"><span class="progress-percent">0%</span><small>Complete</small></div>
                                </div>
                                <div class="stats-grid">
                                    <div class="stat-box answered"><i class="fas fa-check-circle"></i><span class="stat-count" id="modalAnswered">0</span><span class="stat-label">Answered</span></div>
                                    <div class="stat-box unanswered"><i class="fas fa-circle-notch"></i><span class="stat-count" id="modalUnanswered"><%= totalQ %></span><span class="stat-label">Unanswered</span></div>
                                    <div class="stat-box total"><i class="fas fa-clipboard-list"></i><span class="stat-count"><%= totalQ %></span><span class="stat-label">Total</span></div>
                                </div>
                            </div>
                            <div class="progress-bar-container">
                                <div class="progress-info"><span>Question Progress</span><span id="modalProgressText">0 / <%= totalQ %></span></div>
                                <div class="progress"><div class="progress-bar" id="modalProgressBar" style="width:0%"></div></div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn-secondary close-modal">Continue Exam</button>
                            <button type="button" id="modalSubmitBtn" class="btn-primary"><i class="fas fa-paper-plane"></i> Submit Exam</button>
                        </div>
                    </div>
                </div>

                <!-- SUBMIT SECTION -->
                <div class="submit-section">
                    <div class="submit-card">
                        <div class="submit-header"><i class="fas fa-flag-checkered"></i><span>Ready to Submit</span></div>
                        <div class="submit-content">
                            <div class="warning-box">
                                <div class="warning-icon"><i class="fas fa-exclamation-triangle"></i></div>
                                <div class="warning-text">
                                    <strong>Final Review Required</strong>
                                    <p>Unanswered questions will be marked as incorrect. Please review all answers before submission.</p>
                                </div>
                            </div>
                            <div class="submit-stats">
                                <div class="stat-item"><span class="stat-number" id="submitAnswered">0</span><span class="stat-label">Answered</span></div>
                                <div class="stat-divider"></div>
                                <div class="stat-item"><span class="stat-number" id="submitUnanswered"><%= totalQ %></span><span class="stat-label">Unanswered</span></div>
                                <div class="stat-divider"></div>
                                <div class="stat-item"><span class="stat-number"><%= totalQ %></span><span class="stat-label">Total</span></div>
                            </div>
                        </div>
                        <div class="submit-footer">
                            <button type="button" id="submitBtn" class="submit-btn">
                                <i class="fas fa-paper-plane"></i><span class="btn-text">Submit Exam</span>
                                <span class="btn-loading" style="display:none;"><i class="fas fa-spinner fa-spin"></i> Submitting...</span>
                            </button>
                            <div class="submit-guarantee"><i class="fas fa-shield-alt"></i><span>Your responses are securely recorded</span></div>
                        </div>
                    </div>
                </div>

                <!-- FIXED BOTTOM PANEL -->
                <div class="fixed-bottom-panel">
                    <div class="timer-progress-wrapper">
                        <div class="timer-section">
                            <div class="stats-badge timer-badge"><i class="fas fa-clock"></i><span id="remainingTime">--:--</span></div>
                            <span style="font-weight:600;color:var(--text-dark);">Time Remaining</span>
                        </div>
                        <div class="progress-section">
                            <div class="progress-label"><span>Progress</span><span id="progressLabel">0%</span></div>
                            <div class="progress"><div class="progress-bar" id="progressBar" style="width:0%"></div></div>
                        </div>
                    </div>
                </div>
            </form>

            <!-- SCRIPT BLOCK -->
            <script>
                /* --- GLOBAL VARIABLES --- */
                var examActive = true;
                var warningGiven = false;
                var dirty = false;
                var timerInterval = null;
                var examDuration = <%= pDAO.getExamDuration(courseName) %>;
                var totalQuestions = <%= totalQ %>;
                var currentCourseName = '<%= courseName %>';

                /* --- MULTI-SELECT HIDDEN FIELD --- */
                function updateHiddenForMulti(qindex){
                    var box = document.querySelector('.question-card[data-qindex="'+qindex+'"] .answers');
                    if(!box) return;
                    var selectedValues = [];
                    box.querySelectorAll('input.multi:checked').forEach(function(ch){
                        selectedValues.push(ch.value);
                    });
                    var hidden = document.getElementById('ans'+qindex+'-hidden');
                    if(hidden){
                        hidden.value = selectedValues.join('|');
                    }
                }

                /* --- ANSWER SELECTION & PROGRESS --- */
                document.addEventListener('change', function(e){
                    if(!e.target.classList || !e.target.classList.contains('answer-input')) return;
                    
                    var wrapper = e.target.closest('.answers');
                    if(!wrapper) return;
                    
                    var maxSel = parseInt(wrapper.getAttribute('data-max-select') || '1', 10);
                    
                    if(e.target.classList.contains('multi')){
                        var checkedBoxes = wrapper.querySelectorAll('input.multi:checked');
                        if(checkedBoxes.length > maxSel){
                            e.target.checked = false;
                            alert('You can only select up to ' + maxSel + ' options for this question.');
                            return;
                        }
                        var qindex = e.target.getAttribute('data-qindex');
                        updateHiddenForMulti(qindex);
                    }
                    
                    document.querySelectorAll('.form-check').forEach(function(c){
                        if (c && c.classList) {
                            c.classList.remove('selected');
                        }
                    });
                    document.querySelectorAll('.answer-input:checked').forEach(function(inp){
                        var fc = inp.closest('.form-check');
                        if(fc && fc.classList) fc.classList.add('selected');
                    });
                    
                    updateProgress();
                    dirty = true;
                });

                function updateProgress(){
                    var cards = document.querySelectorAll('.question-card');
                    var answered = 0;
                    
                    cards.forEach(function(card){
                        var box = card.querySelector('.answers');
                        if(!box) return;
                        
                        const qindex = card.getAttribute('data-qindex');
                        const isDragDrop = card.querySelector('.drag-drop-question') !== null;
                        
                        if (isDragDrop) {
                            // Question is answered if at least one target has an item
                            if (card.querySelectorAll('.dropped-item').length > 0) {
                                answered++;
                            }
                        } else {
                            var maxSel = parseInt(box.getAttribute('data-max-select') || '1', 10);
                            if(maxSel === 1){
                                if(box.querySelector('input.single:checked')) answered++;
                            } else {
                                if(box.querySelectorAll('input.multi:checked').length >= 1) answered++;
                            }
                        }
                    });
                    
                    var total = cards.length;
                    var pct = total ? Math.round((answered / total) * 100) : 0;
                    
                    // Update progress bars
                    var progressBar = document.getElementById('progressBar');
                    var modalProgressBar = document.getElementById('modalProgressBar');
                    if(progressBar) progressBar.style.width = pct + '%';
                    if(modalProgressBar) modalProgressBar.style.width = pct + '%';
                    
                    // Update labels
                    var progressLabel = document.getElementById('progressLabel');
                    var progressPercent = document.querySelector('.progress-percent');
                    if(progressLabel) progressLabel.textContent = pct + '%';
                    if(progressPercent) progressPercent.textContent = pct + '%';
                    
                    // Update counters
                    var submitAnswered = document.getElementById('submitAnswered');
                    var submitUnanswered = document.getElementById('submitUnanswered');
                    var floatCounter = document.getElementById('floatCounter');
                    var modalAnswered = document.getElementById('modalAnswered');
                    var modalUnanswered = document.getElementById('modalUnanswered');
                    var modalProgressText = document.getElementById('modalProgressText');
                    
                    if(submitAnswered) submitAnswered.textContent = answered;
                    if(submitUnanswered) submitUnanswered.textContent = total - answered;
                    if(floatCounter) floatCounter.textContent = answered + '/' + total;
                    if(modalAnswered) modalAnswered.textContent = answered;
                    if(modalUnanswered) modalUnanswered.textContent = total - answered;
                    if(modalProgressText) modalProgressText.textContent = answered + ' / ' + total;
                    
                    // Update circular progress
                    var circumference = 2 * Math.PI * 34;
                    var offset = circumference - (pct / 100) * circumference;
                    var progressRing = document.querySelector('.progress-ring-progress');
                    if(progressRing) progressRing.style.strokeDashoffset = offset;
                }

                /* --- ASYNC ANSWER SAVING --- */
                function saveAnswer(qindex, answer) {
                    const questionCard = document.querySelector(`.question-card[data-qindex="${qindex}"]`);
                    if (!questionCard) return;

                    const qid = questionCard.querySelector('input[name="qid' + qindex + '"]').value;
                    const question = questionCard.querySelector('input[name="question' + qindex + '"]').value;

                    const formData = new FormData();
                    formData.append('page', 'saveAnswer');
                    formData.append('qid', qid);
                    formData.append('question', question);
                    formData.append('ans', answer);

                    navigator.sendBeacon('controller.jsp', new URLSearchParams(formData));
                }

                document.addEventListener('change', function(e) {
                    if (e.target.classList && e.target.classList.contains('answer-input')) {
                        const qindex = e.target.getAttribute('data-qindex');
                        let answer = '';
                        if (e.target.classList.contains('multi')) {
                            const wrapper = e.target.closest('.answers');
                            const selectedValues = [];
                            wrapper.querySelectorAll('input.multi:checked').forEach(function(ch) {
                                selectedValues.push(ch.value);
                            });
                            answer = selectedValues.join('|');
                        } else {
                            answer = e.target.value;
                        }
                        saveAnswer(qindex, answer);
                    }
                });

                /* --- TIMER MANAGEMENT --- */
                function startTimer() {
                    var timerEl = document.getElementById('remainingTime');
                    if(!timerEl) {
                        console.warn('Timer element not found, timer disabled');
                        return;
                    }
                    
                    // Calculate initial time
                    var timeInSeconds = examDuration > 0 ? examDuration * 60 : 60 * 60;
                    
                    // Check if we have a saved start time
                    var storageKey = 'examStartTime_' + currentCourseName;
                    var startTime = sessionStorage.getItem(storageKey);
                    var elapsedSeconds = 0;
                    
                    if(startTime) {
                        // Resume from saved time
                        elapsedSeconds = Math.floor((Date.now() - parseInt(startTime)) / 1000);
                        timeInSeconds = Math.max(0, timeInSeconds - elapsedSeconds);
                    } else {
                        // Start new timer
                        sessionStorage.setItem(storageKey, Date.now().toString());
                    }
                    
                    var time = timeInSeconds;
                    
                    function fmt(n) {
                        return String(n).padStart(2, '0');
                    }
                    
                    function updateTimerDisplay() {
                        var minutes = Math.floor(time / 60);
                        var seconds = time % 60;
                        timerEl.textContent = fmt(minutes) + ':' + fmt(seconds);
                        
                        // Color coding
                        if (timerEl.classList) {
                            timerEl.classList.remove('warning', 'critical', 'expired');
                            if(time <= 300) timerEl.classList.add('warning');
                            if(time <= 60) timerEl.classList.add('critical');
                        }
                    }
                    
                    updateTimerDisplay();
                    
                    // Clear any existing interval
                    if(timerInterval) clearInterval(timerInterval);
                    
                    // Start new interval
                    timerInterval = setInterval(function() {
                        time--;
                        
                        if(time <= 0) {
                            clearInterval(timerInterval);
                            if (timerEl) {
                                timerEl.textContent = "00:00";
                                if (timerEl.classList) {
                                    timerEl.classList.add('expired');
                                }
                            }
                            autoSubmitExam();
                            return;
                        }
                        
                        updateTimerDisplay();
                    }, 1000);
                }

                function autoSubmitExam() {
                    // Save all answers before submitting
                    document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
                        var qindex = box.closest('.question-card').getAttribute('data-qindex');
                        if(qindex) updateHiddenForMulti(qindex);
                    });
                    
                    // Alert user
                    alert('Time is up! Your exam will be submitted automatically.');
                    
                    // Clean up and submit
                    cleanupExam();
                    setTimeout(function() {
                        document.getElementById('myform').submit();
                    }, 1000);
                }

                /* --- EXAM SUBMISSION --- */
                function submitExam() {
                    // Save all multi-select answers
                    document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
                        var card = box.closest('.question-card');
                        if (!card) return;
                        var qindex = card.getAttribute('data-qindex');
                        if (qindex) updateHiddenForMulti(qindex);
                    });
                    
                    // Handle Drag and Drop answers - PHASE 5 Integration
                    const dragDropAnswers = getDragDropAnswers();
                    Object.keys(dragDropAnswers).forEach(qindex => {
                        const mappings = dragDropAnswers[qindex];
                        const formattedMappings = {};
                        for (let tId in mappings) {
                            formattedMappings['target_' + tId] = 'item_' + mappings[tId];
                        }
                        const ansValue = JSON.stringify(formattedMappings);
                        
                        let hiddenAns = document.querySelector('input[name="ans' + qindex + '"]');
                        if (!hiddenAns) {
                            hiddenAns = document.createElement('input');
                            hiddenAns.type = 'hidden';
                            hiddenAns.name = 'ans' + qindex;
                            document.getElementById('myform').appendChild(hiddenAns);
                        }
                        hiddenAns.value = ansValue;
                    });
                    
                    var answeredQuestions = 0;
                    document.querySelectorAll('.question-card').forEach(function(card){
                        const isDragDrop = card.querySelector('.drag-drop-question') !== null;
                        if (isDragDrop) {
                            if (card.querySelectorAll('.dropped-item').length > 0) {
                                answeredQuestions++;
                            }
                        } else {
                            var box = card.querySelector('.answers');
                            if(!box) return;
                            var maxSel = parseInt(box.getAttribute('data-max-select') || '1', 10);
                            if(maxSel === 1) {
                                if(box.querySelector('input.single:checked')) answeredQuestions++;
                            } else {
                                if(box.querySelectorAll('input.multi:checked').length >= 1) answeredQuestions++;
                            }
                        }
                    });
                    
                    // Check for unanswered questions
                    if(answeredQuestions < totalQuestions) {
                        var unanswered = totalQuestions - answeredQuestions;
                        if(!confirm("You have " + unanswered + " unanswered question" + 
                                (unanswered > 1 ? "s" : "") + ". Submit anyway?")) {
                            return;
                        }
                    }
                    
                    // Final confirmation
                    if(confirm("Are you sure you want to submit your exam? This action cannot be undone.")) {
                        cleanupExam();
                        
                        // Show loading state
                        var btn = document.getElementById('submitBtn');
                        if(btn) {
                            btn.disabled = true;
                            if (btn.classList) {
                                btn.classList.add('loading');
                            }
                            var btnText = btn.querySelector('.btn-text');
                            var btnLoading = btn.querySelector('.btn-loading');
                            if(btnText) btnText.style.display = 'none';
                            if(btnLoading) btnLoading.style.display = 'inline';
                        }
                        
                        // Submit form
                        setTimeout(function() {
                            document.getElementById('myform').submit();
                        }, 500);
                    }
                }

                /* --- CLEANUP FUNCTION --- */
                function cleanupExam() {
                    examActive = false;
                    dirty = false;
                    
                    // Clear session storage
                    var storageKey = 'examStartTime_' + currentCourseName;
                    sessionStorage.removeItem(storageKey);
                    
                    // Clear all exam session storage
                    Object.keys(sessionStorage).forEach(function(key) {
                        if(key.startsWith('examStartTime_')) {
                            sessionStorage.removeItem(key);
                        }
                    });
                    
                    // Clear timer interval
                    if(timerInterval) {
                        clearInterval(timerInterval);
                        timerInterval = null;
                    }
                    
                    // Remove navigation protection
                    window.onbeforeunload = null;
                }

                /* --- NAVIGATION PROTECTION --- */
                function setupNavigationProtection() {
                    // Prevent leaving the page
                    window.onbeforeunload = function(e) {
                        if(examActive && dirty && !warningGiven) {
                            var message = 'You have an active exam in progress. If you leave, your answers may not be saved.';
                            e.returnValue = message;
                            return message;
                        }
                    };
                    
                    // Intercept navigation clicks
                    document.addEventListener('click', function(e) {
                        if(!examActive) return;
                        
                        var link = e.target.closest('a');
                        if(link && link.href) {
                            // Check if it's navigation away from exam page
                            var currentUrl = window.location.href;
                            var targetUrl = link.href;
                            
                            // Allow navigation within exam pages
                            if(!targetUrl.includes('std-page.jsp?pgprt=1') && 
                            !targetUrl.includes('controller.jsp?page=exams')) {
                                
                                e.preventDefault();
                                
                                // Show warning modal
                                showNavigationWarning(function(proceed) {
                                    if(proceed) {
                                        warningGiven = true;
                                        cleanupExam();
                                        window.location.href = link.href;
                                    }
                                });
                            }
                        }
                    });
                }

                /* --- FLOATING PROGRESS BUTTON & MODAL --- */
                function setupProgressModal() {
                    var floatBtn = document.getElementById('progressFloatBtn');
                    var modal = document.getElementById('progressModal');
                    var closeModal = document.querySelectorAll('.close-modal');
                    var modalSubmitBtn = document.getElementById('modalSubmitBtn');
                    
                    if(floatBtn && modal) {
                        floatBtn.addEventListener('click', function() {
                            if (modal && modal.classList) {
                                modal.classList.add('active');
                            }
                            updateProgress();
                        });
                        
                        closeModal.forEach(function(btn) {
                            btn.addEventListener('click', function() {
                                if (modal && modal.classList) {
                                    modal.classList.remove('active');
                                }
                            });
                        });
                        
                        modal.addEventListener('click', function(e) {
                            if(e.target === modal) {
                                modal.classList.remove('active');
                            }
                        });
                        
                        if(modalSubmitBtn) {
                            modalSubmitBtn.addEventListener('click', function() {
                                if (modal && modal.classList) {
                                    modal.classList.remove('active');
                                }
                                submitExam();
                            });
                        }
                    }
                }

                /* --- INITIALIZATION --- */
                document.addEventListener('DOMContentLoaded', function() {
                    // Initialize components
                    updateProgress();
                    startTimer();
                    setupNavigationProtection();
                    setupProgressModal();
                    
                    // Set up submit button handlers
                    var submitBtn = document.getElementById('submitBtn');
                    if(submitBtn) {
                        submitBtn.addEventListener('click', submitExam);
                    }
                    
                    // Clear session storage when page unloads (if exam is not active)
                    window.addEventListener('beforeunload', function() {
                        if(!examActive) {
                            var storageKey = 'examStartTime_' + currentCourseName;
                            sessionStorage.removeItem(storageKey);
                        }
                    });
                });
                
                /* --- SIMPLIFIED DRAG AND DROP FUNCTIONALITY - NO BACKTICKS --- */
let userMappings = {};

function initializeDragDropQuestions() {
    const dragDropQuestions = document.querySelectorAll('.drag-drop-question');
    
    dragDropQuestions.forEach(function(questionContainer, idx) {
        const card = questionContainer.closest('.question-card');
        if (!card) return;
        
        const questionIndex = card.getAttribute('data-qindex');
        userMappings[questionIndex] = {};
        
        const dragItemsContainer = document.getElementById('dragItems_' + questionIndex);
        const dropTargetsContainer = document.getElementById('dropTargets_' + questionIndex);
        
        // SIMPLE parsing with NO template literals
        let itemsData = [];
        let targetsData = [];
        
        try {
            var itemsJson = questionContainer.getAttribute('data-items-json');
            var targetsJson = questionContainer.getAttribute('data-targets-json');
            
            if (itemsJson && itemsJson != 'null' && itemsJson != 'undefined') {
                itemsData = JSON.parse(itemsJson);
            }
            if (targetsJson && targetsJson != 'null' && targetsJson != 'undefined') {
                targetsData = JSON.parse(targetsJson);
            }
        } catch (e) {
            console.log('Error parsing drag-drop JSON for question ' + (parseInt(questionIndex) + 1));
            itemsData = [];
            targetsData = [];
        }
        
        // Call render function
        renderDragDropInterface(questionIndex, dragItemsContainer, dropTargetsContainer, itemsData, targetsData);
    });
}

/* --- DRAG AND DROP RANDOMIZATION --- */
function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        const temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}

function renderDragDropInterface(qIdx, dragContainer, dropContainer, items, targets) {
    console.log('Rendering drag-drop for question ' + (parseInt(qIdx) + 1));
    
    // Handle simple string arrays
    var normalizedItems = [];
    for (var i = 0; i < items.length; i++) {
        if (typeof items[i] === 'string') {
            normalizedItems.push({ id: 'item_' + i, text: items[i] });
        } else {
            normalizedItems.push(items[i]);
        }
    }
    
    var normalizedTargets = [];
    for (var i = 0; i < targets.length; i++) {
        if (typeof targets[i] === 'string') {
            normalizedTargets.push({ id: 'target_' + i, label: targets[i] });
        } else {
            normalizedTargets.push(targets[i]);
        }
    }
    
    // RANDOMIZE: Shuffle both items and targets
    var shuffledItems = shuffleArray(normalizedItems.slice());
    var shuffledTargets = shuffleArray(normalizedTargets.slice());
    
    // Render Items (randomized order)
    dragContainer.innerHTML = '';
    for (var i = 0; i < shuffledItems.length; i++) {
        var item = shuffledItems[i];
        var el = document.createElement('div');
        el.className = 'drag-item';
        el.draggable = true;
        el.id = 'q' + qIdx + '_item_' + item.id;
        el.setAttribute('data-item-id', item.id);
        el.setAttribute('data-text', item.text);
        el.textContent = item.text;
        
        el.addEventListener('dragstart', handleDragStart);
        el.addEventListener('dragend', handleDragEnd);
        
        dragContainer.appendChild(el);
    }
    
    // Render Targets (randomized order)
    dropContainer.innerHTML = '';
    for (var i = 0; i < shuffledTargets.length; i++) {
        var target = shuffledTargets[i];
        var el = document.createElement('div');
        el.className = 'drop-target';
        el.id = 'q' + qIdx + '_target_' + target.id;
        el.setAttribute('data-target-id', target.id);
        el.innerHTML = '<div class="drop-target-header">' + target.label + '</div>' +
                       '<div class="placeholder">Drop here</div>';
        
        el.addEventListener('dragover', handleDragOver);
        el.addEventListener('dragenter', handleDragEnter);
        el.addEventListener('dragleave', handleDragLeave);
        el.addEventListener('drop', handleDrop);
        
        dropContainer.appendChild(el);
    }
    
    // Initialize waiting states for empty targets
    updateWaitingStates();
}

function shuffleDraggableItems(qIdx) {
    const dragContainer = document.getElementById('dragItems_' + qIdx);
    const dragItems = Array.from(dragContainer.children);
    
    // Shuffle items
    const shuffled = shuffleArray(dragItems);
    
    // Clear and re-append in shuffled order
    dragContainer.innerHTML = '';
    shuffled.forEach(item => dragContainer.appendChild(item));
}

function shuffleDropTargets(qIdx) {
    const dropContainer = document.getElementById('dropTargets_' + qIdx);
    const dropTargets = Array.from(dropContainer.children);
    
    // Shuffle targets
    const shuffled = shuffleArray(dropTargets);
    
    // Clear and re-append in shuffled order
    dropContainer.innerHTML = '';
    shuffled.forEach(target => dropContainer.appendChild(target));
}

/* --- IMAGE RANDOMIZATION --- */
function randomizeImages() {
    const questionCards = document.querySelectorAll('.question-card');
    
    questionCards.forEach(card => {
        const imageContainer = card.querySelector('.question-image-container');
        if (imageContainer) {
            // Random chance to show image above or below question text
            if (Math.random() > 0.5) {
                // Already in default position
            } else {
                // Move image after question text
                const questionContent = card.querySelector('.question-content');
                const questionText = card.querySelector('.question-text');
                if (questionText && imageContainer) {
                    questionContent.insertBefore(imageContainer, questionText.nextSibling);
                }
            }
        }
    });
}

// Call this after DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    randomizeImages();
});

// DRAG HANDLERS
function handleDragStart(e) {
    e.target.classList.add('dragging');
    e.dataTransfer.setData('text/plain', e.target.id);
    e.dataTransfer.effectAllowed = 'move';
}

function handleDragEnd(e) {
    e.target.classList.remove('dragging');
}

function handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
}

function handleDragEnter(e) {
    e.preventDefault();
    var target = e.target.closest('.drop-target');
    if (target) {
        target.classList.add('drag-over');
        target.classList.remove('waiting');
    }
}

function handleDragLeave(e) {
    var target = e.target.closest('.drop-target');
    if (target) {
        target.classList.remove('drag-over');
        // Add waiting state back if target doesn't have items
        if (!target.querySelector('.dropped-item')) {
            target.classList.add('waiting');
        }
    }
}

function handleDrop(e) {
    e.preventDefault();
    var target = e.target.closest('.drop-target');
    if (!target) return;
    
    target.classList.remove('drag-over');
    target.classList.remove('waiting');
    
    var itemId = e.dataTransfer.getData('text/plain');
    var draggedEl = document.getElementById(itemId);
    if (!draggedEl) return;
    
    var qIdx = target.id.split('_')[0].substring(1);
    var targetId = target.getAttribute('data-target-id');
    var itemDataId = draggedEl.getAttribute('data-item-id');
    var itemText = draggedEl.getAttribute('data-text');
    
    // Remove existing item if present
    if (target.querySelector('.dropped-item')) {
        var existingDropped = target.querySelector('.dropped-item');
        restoreItemToPool(qIdx, existingDropped.getAttribute('data-item-id'), existingDropped.getAttribute('data-text'));
        target.innerHTML = '<div class="drop-target-header">' + target.querySelector('.drop-target-header').textContent + '</div>';
    }
    
    // Add new item
    var droppedEl = document.createElement('div');
    droppedEl.className = 'dropped-item';
    droppedEl.setAttribute('data-item-id', itemDataId);
    droppedEl.setAttribute('data-text', itemText);
    droppedEl.innerHTML = '<span>' + itemText + '</span>' +
                          '<button type="button" class="remove-btn" title="Remove">&times;</button>';
    
    droppedEl.querySelector('.remove-btn').onclick = function() {
        removeItemFromTarget(qIdx, targetId, itemDataId, itemText);
    };
    
    target.appendChild(droppedEl);
    
    // Hide original item
    draggedEl.style.display = 'none';
    
    // Update mappings
    if (!userMappings[qIdx]) userMappings[qIdx] = {};
    userMappings[qIdx][targetId] = itemDataId;
    
    updateProgress();
    
    // Save answer
    saveDragDropAnswer(qIdx);
    
    // Add waiting state to all empty targets
    updateWaitingStates();
}

function updateWaitingStates() {
    var allTargets = document.querySelectorAll('.drop-target');
    allTargets.forEach(function(target) {
        if (!target.querySelector('.dropped-item')) {
            target.classList.add('waiting');
        } else {
            target.classList.remove('waiting');
        }
    });
}

function restoreItemToPool(qIdx, itemId, text) {
    var pool = document.getElementById('dragItems_' + qIdx);
    var originalItem = document.getElementById('q' + qIdx + '_item_' + itemId);
    if (originalItem) {
        originalItem.style.display = 'flex';
    }
}

function removeItemFromTarget(qIdx, targetId, itemId, text) {
    var target = document.getElementById('q' + qIdx + '_target_' + targetId);
    if (target) {
        var droppedItem = target.querySelector('.dropped-item');
        if (droppedItem) droppedItem.remove();
        if (!target.querySelector('.placeholder')) {
            var placeholder = document.createElement('div');
            placeholder.className = 'placeholder';
            placeholder.textContent = 'Drop here';
            target.appendChild(placeholder);
        }
    }
    
    restoreItemToPool(qIdx, itemId, text);
    if (userMappings[qIdx]) {
        delete userMappings[qIdx][targetId];
    }
    
    updateProgress();
    saveDragDropAnswer(qIdx);
}

function saveDragDropAnswer(qIdx) {
    if (!userMappings[qIdx]) return;
    
    var mappings = userMappings[qIdx];
    var formattedMappings = {};
    
    for (var tId in mappings) {
        formattedMappings['target_' + tId] = 'item_' + mappings[tId];
    }
    
    var answer = JSON.stringify(formattedMappings);
    
    // Save using existing saveAnswer function
    if (typeof saveAnswer === 'function') {
        saveAnswer(qIdx, answer);
    }
}

function getDragDropAnswers() {
    return userMappings;
}

// Initialize drag-drop questions when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeDragDropQuestions);
} else {
    initializeDragDropQuestions();
}
            </script>

            <% } else if ("1".equals(request.getParameter("showresult"))) {
                        // SHOW RESULTS PAGE
                        Exams result = pDAO.getResultByExamId(Integer.parseInt(request.getParameter("eid")));
                        
                        // IMPORTANT: Clear exam session when showing results
                        session.removeAttribute("examStarted");
                        session.removeAttribute("examId");
                        
                        // Clear any pending exam timer data
                        session.removeAttribute("remainingTime");
                        session.removeAttribute("courseName");
                        
                        // Get result details directly from Exams object - NO REFLECTION NEEDED
                        String studentFullName = "Student";
                        String courseName = "Unknown Course";
                        String examDate = "N/A";
                        String startTime = "N/A";
                        String endTime = "N/A";
                        int obtainedMarks = 0;
                        int totalMarks = 0;
                        String resultStatus = "Unknown";
                        
                        if (result != null) {
                            studentFullName = result.getFullName();
                            if (studentFullName == null || studentFullName.trim().isEmpty()) {
                                studentFullName = result.getUserName();
                            }
                            if (studentFullName == null || studentFullName.trim().isEmpty()) {
                                studentFullName = result.getEmail();
                            }

                            courseName = result.getcName();
                            examDate = result.getDate();
                            startTime = result.getStartTime();
                            endTime = result.getEndTime();
                            obtainedMarks = result.getObtMarks();
                            totalMarks = result.gettMarks();
                            resultStatus = result.getStatus();

                            // Fallback for status if it's missing or just "completed"
                            if (resultStatus == null || resultStatus.isEmpty() || resultStatus.equalsIgnoreCase("completed")) {
                                double percentage = (totalMarks > 0) ? (double) obtainedMarks / totalMarks * 100 : 0;
                                resultStatus = (percentage >= 45.0) ? "Pass" : "Fail";
                            }
                        }
                    %>
            <!-- RESULTS -->
            <div class="page-header">
                <div class="page-title"><i class="fas fa-chart-line"></i> Exam Result</div>
                <div class="stats-badge"><i class="fas fa-graduation-cap"></i> <%= resultStatus %></div>
            </div>
            <div class="result-card">
                <div class="result-grid">
                    <div class="result-item"><strong><i class="fas fa-calendar-alt"></i> Exam Date</strong><div class="result-value"><%= examDate %></div></div>
                    <div class="result-item"><strong><i class="fas fa-book"></i> Course Name</strong><div class="result-value"><%= courseName %></div></div>
                    <div class="result-item"><strong><i class="fas fa-clock"></i> Start Time</strong><div class="result-value"><%= startTime %></div></div>
                    <div class="result-item"><strong><i class="fas fa-clock"></i> End Time</strong><div class="result-value"><%= endTime %></div></div>
                    <div class="result-item"><strong><i class="fas fa-star"></i> Obtained Marks</strong><div class="result-value"><%= obtainedMarks %></div></div>
                    <div class="result-item"><strong><i class="fas fa-star-half-alt"></i> Total Marks</strong><div class="result-value"><%= totalMarks %></div></div>
                    <div class="result-item">
                        <strong><i class="fas fa-flag"></i> Result Status</strong>
                        <div class="result-value <%= resultStatus.equalsIgnoreCase("Pass")?"status-pass":"status-fail" %>">
                            <i class="fas <%= resultStatus.equalsIgnoreCase("Pass")?"fa-check-circle":"fa-times-circle" %>"></i> <%= resultStatus %>
                        </div>
                    </div>
                    <div class="result-item">
                        <strong><i class="fas fa-chart-pie"></i> Percentage</strong>
                        <div class="result-value">
                            <% 
                                double percentage = 0;
                                if(totalMarks > 0) {
                                    percentage = (double)obtainedMarks / totalMarks * 100;
                                }
                            %>
                            <span class="percentage-badge"><%= String.format("%.1f", percentage) %>%</span>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons
                <div style="text-align: center; margin-top: 20px;">
                    <a href="std-page.jsp?pgprt=2&eid=<%= request.getParameter("eid") %>" class="action-btn" style="background: linear-gradient(135deg, #4a90e2, #357abd); margin-right: 10px;">
                        <i class="fas fa-eye"></i>
                        View Details
                    </a> -->
                </div>
                </div>
                                <!-- Action Buttons -->
                <div style="text-align: center; margin-top: 20px;">
                    <a href="std-page.jsp?pgprt=2&eid=<%= result.getExamId() %>" class="action-btn" style="background: linear-gradient(135deg, #4a90e2, #357abd); margin-right: 10px;">
                        <i class="fas fa-eye"></i>
                        View Details
                    </a>
                </div>
                <!-- RELAUNCH SECTION -->
                <div style="margin-top: 30px; padding: 20px; background: #f8fafc; border-radius: 10px; text-align: center; border-top: 2px solid #e2e8f0;">
                    <p style="margin-bottom: 20px; color: #64748b;">Ready to take another exam? Select a course below.</p>
                    <a href="std-page.jsp?pgprt=1"
                       class="btn-primary"
                       style="padding: 12px 30px; font-size: 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none;">
                        <h3 style="margin-bottom: 0; color: #fffff;">
                            <i class="fas fa-redo"></i> Take Another Exam
                        </h3>
                    </a>
                </div>
            </div>
            
            <!-- CLEAR EXAM SESSION DATA -->
            <script>
                // Clear all exam session data when viewing results
                Object.keys(sessionStorage).forEach(function(key) {
                    if(key.startsWith('examStartTime_')) {
                        sessionStorage.removeItem(key);
                    }
                });
                
                // Also clear any other exam-related data
                sessionStorage.clear();
            </script>

        <% } else { 
            // SHOW COURSE SELECTION FORM (DEFAULT VIEW)
            // Clear any stale session data
            session.removeAttribute("examStarted");
            session.removeAttribute("examId");
            session.removeAttribute("remainingTime");
            session.removeAttribute("courseName");
        %>
        <!-- EXAM SELECTION -->
        <div class="page-header">
            <div class="page-title"><i class="fas fa-file-alt"></i> Take Exam</div>
            <div class="stats-badge"><i class="fas fa-clipboard-check"></i> Available Exams</div>
        </div>

        <div class="course-card">
            <form action="controller.jsp" method="post" id="examStartForm">
                <input type="hidden" name="page" value="exams">
                <input type="hidden" name="operation" value="startexam">
                <input type="hidden" name="csrf_token" value="<%= session.getAttribute("csrf_token") != null ? session.getAttribute("csrf_token") : "" %>">
<!--                <label class="form-label"><i class="fas fa-book"></i> Select Course</label>-->
                <select name="coursename" class="form-select" required id="courseSelect">
                    <option value="">Choose a course...</option>
        
            <% 
                // Get only ACTIVE courses - using the new method
                ArrayList<String> activeCourseNames = pDAO.getActiveCourseNames();
                if (activeCourseNames != null && !activeCourseNames.isEmpty()) {
                    for(String courseName : activeCourseNames){ 
                        if (courseName != null && !courseName.trim().isEmpty()) {
                            int duration = pDAO.getExamDuration(courseName);
            %>
            <option value="<%= courseName %>" data-duration="<%= duration %>">
                <%= courseName %> (<%= formatDuration(duration) %>)
            </option>
            <% 
                        }
                    }
                } else {
            %>
            <option value="" disabled>No exams available</option>
            <% } %>
                </select>

                <!-- Course Info Display -->
                <div id="courseInfo" style="margin-top: 10px; padding: 10px; background: #f0f9ff; border-radius: 6px; display: none;">
                    <i class="fas fa-info-circle" style="color: #3b82f6;"></i>
                    <span id="courseInfoText"></span>
                </div>

                <!-- No Exams Message -->
                <% if (activeCourseNames == null || activeCourseNames.isEmpty()) { %>
                <div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin-top: 15px; text-align: center; border: 1px solid #e2e8f0;">
                    <i class="fas fa-calendar-times" style="color: #64748b; font-size: 24px; margin-bottom: 10px;"></i>
                    <p style="color: #64748b; margin: 0;">No active exams are currently available. Please check back later.</p>
                </div>
                <% } %>

                <button type="submit" class="start-exam-btn" id="startExamBtn" 
                        <% if (activeCourseNames == null || activeCourseNames.isEmpty()) { %>disabled<% } %>>
                    <i class="fas fa-play"></i> Start Exam
                </button>
            </form>
        </div>
            
<!-- CLEAR EXAM SESSION DATA -->
<script>
    // Clear all exam session data when on course selection page
    Object.keys(sessionStorage).forEach(function(key) {
        if(key.startsWith('examStartTime_')) {
            sessionStorage.removeItem(key);
        }
    });
    
    // Clear all session storage to ensure clean state
    sessionStorage.clear();
    
    // Show course info when selected
    document.getElementById('courseSelect').addEventListener('change', function() {
        var selectedOption = this.options[this.selectedIndex];
        var courseInfo = document.getElementById('courseInfo');
        var courseInfoText = document.getElementById('courseInfoText');
        
        if(selectedOption.value) {
            var duration = selectedOption.getAttribute('data-duration') || '60';
            courseInfoText.textContent = 'This exam has a duration of ' + duration + ' minutes.';
            courseInfo.style.display = 'block';
        } else {
            courseInfo.style.display = 'none';
        }
    });
    
    // Check course status function
    function checkCourseStatus(courseName, callback) {
        console.log('Checking course status for:', courseName);

        // Get CSRF token
        const csrfTokenInput = document.querySelector('input[name="csrf_token"]');
        if (!csrfTokenInput || !csrfTokenInput.value) {
            console.error('CSRF token not found');
            callback(true); // Assume active on error
            return;
        }

        // Create form data
        const formData = new FormData();
        formData.append('page', 'exams');
        formData.append('operation', 'checkCourseStatus');
        formData.append('courseName', courseName);
        formData.append('csrf_token', csrfTokenInput.value);

        console.log('Sending AJAX request to check course status...');

        // Send AJAX request with timeout
        const timeout = 5000; // 5 second timeout

        // Create abort controller for timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => {
            controller.abort();
            console.log('Request timeout');
        }, timeout);

        fetch('controller.jsp', {
            method: 'POST',
            body: formData,
            signal: controller.signal
        })
        .then(response => {
            clearTimeout(timeoutId);
            console.log('Response status:', response.status);
            console.log('Response ok:', response.ok);

            if (!response.ok) {
                throw new Error(`Network response was not ok: ${response.status} ${response.statusText}`);
            }
            return response.text();
        })
        .then(data => {
            console.log('Raw response data:', data);
            console.log('Response length:', data.length);

            // Trim and parse response
            const trimmedData = data.trim();
            console.log('Trimmed data:', trimmedData);

            // Check if response is "true" or "false"
            if (trimmedData === 'true' || trimmedData === 'false') {
                const isActive = trimmedData === 'true';
                console.log('Course is active:', isActive);
                callback(isActive);
            } else {
                console.error('Unexpected response format:', trimmedData);
                // If we get an unexpected response, assume course is active
                // because getActiveCourseNames() already filtered inactive ones
                console.log('Assuming course is active due to unexpected response format');
                callback(true);
            }
        })
        .catch(error => {
            clearTimeout(timeoutId);
            console.error('Error checking course status:', error);
            console.error('Error name:', error.name);
            console.error('Error message:', error.message);

            // Show error message only if it's not an abort error
            if (error.name === 'AbortError') {
                console.log('Request aborted due to timeout');
            } else {
                console.log('Error:', error.message);
            }
            // Default to true on error (since getActiveCourseNames already filtered)
            callback(true);
        });
    }
    
    // Confirm before starting exam (using modal instead of alert)
    document.getElementById('examStartForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        var courseSelect = document.getElementById('courseSelect');
        if(!courseSelect || !courseSelect.value) {
            alert('Please select a course.');
            return;
        }
        
        var selectedOption = courseSelect.options[courseSelect.selectedIndex];
        var courseName = selectedOption.value;
        var duration = selectedOption.getAttribute('data-duration') || '60';
        
        // Get modal elements
        var confirmationModal = document.getElementById('confirmationModal');
        var inactiveModal = document.getElementById('inactiveModal');
        var modalCourseName = document.getElementById('modalCourseName');
        var modalDuration = document.getElementById('modalDuration');
        var inactiveCourseName = document.getElementById('inactiveCourseName');
        
        if (!confirmationModal || !inactiveModal || !modalCourseName || !modalDuration || !inactiveCourseName) {
            console.error('Modal elements not found');
            alert('System error: Modal elements not found. Please refresh the page.');
            return;
        }
        
        checkCourseStatus(courseName, function(isActive) {
            if (isActive) {
                modalCourseName.textContent = courseName;
                modalDuration.textContent = duration + ' minutes';
                confirmationModal.style.display = 'flex';
            } else {
                inactiveCourseName.textContent = courseName;
                inactiveModal.style.display = 'flex';
            }
        });
    });
</script>
        <% } %>
    </main>
</div>

<!-- Confirmation Modal (for course selection) -->
<div id="confirmationModal" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Confirm Exam Start</h3>
        </div>
        <div class="modal-body">
            <p>Are you ready to start the "<strong id="modalCourseName"></strong>" exam?</p>
            <ul>
                <li><i class="fas fa-clock"></i><strong>Exam Duration:</strong> <span id="modalDuration"></span> minutes</li>
                <li><i class="fas fa-hourglass-start"></i>The timer will start immediately.</li>
                <li><i class="fas fa-lock"></i>You cannot leave the page until you submit.</li>
            </ul>
        </div>
        <div class="modal-footer">
            <button id="cancelButton" class="btn-secondary">Cancel</button>
            <button id="beginButton" class="btn-primary">Begin Exam</button>
        </div>
    </div>
</div>

<!-- Inactive Course Modal -->
<div id="inactiveModal" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header" style="background-color: #dc3545;">
            <h3 class="modal-title"><i class="fas fa-exclamation-circle"></i> Course Not Available</h3>
        </div>
        <div class="modal-body">
            <div style="text-align: center; margin-bottom: 20px;">
                <i class="fas fa-lock fa-3x" style="color: #dc3545; margin-bottom: 15px;"></i>
                <h4 style="color: #dc3545; margin-bottom: 10px;">Exam Temporarily Unavailable</h4>
            </div>
            <p>The "<strong id="inactiveCourseName"></strong>" exam is currently <strong style="color: #dc3545;">NOT ACTIVE</strong>.</p>
            <ul style="color: #6c757d;">
                <li><i class="fas fa-calendar-times"></i> This exam has been deactivated by the administrator</li>
                <li><i class="fas fa-user-clock"></i> Please check back later or contact your instructor</li>
                <li><i class="fas fa-book"></i> You can select another available course</li>
            </ul>
            <div style="background-color: #f8f9fa; padding: 10px; border-radius: 5px; margin-top: 15px;">
                <i class="fas fa-info-circle" style="color: #17a2b8;"></i>
                <small>Only exams marked as "Active" can be taken by students.</small>
            </div>
        </div>
        <div class="modal-footer">
            <button id="closeInactiveModal" class="btn-secondary">Close</button>
            <button id="selectOtherCourse" class="btn-outline">Select Another Course</button>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="delete-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-exclamation-triangle" style="color: #dc3545;"></i> Delete Exam Result</h3>
            <span class="close-modal" onclick="closeDeleteModal()">&times;</span>
        </div>
        <div class="modal-body">
            <p id="deleteModalMessage">Are you sure you want to delete this exam result?</p>
        </div>
        <div class="modal-footer">
            <button onclick="closeDeleteModal()" class="btn-outline">Cancel</button>
            <button onclick="confirmDelete()" class="btn-danger">
                <i class="fas fa-trash"></i> Delete
            </button>
        </div>
    </div>
</div>

<script>
    // Confirmation Modal JavaScript
    document.addEventListener('DOMContentLoaded', function () {
        const form = document.getElementById('examStartForm');
        const courseSelect = document.getElementById('courseSelect');
        const confirmationModal = document.getElementById('confirmationModal');
        const modalCourseName = document.getElementById('modalCourseName');
        const modalDuration = document.getElementById('modalDuration');
        const beginButton = document.getElementById('beginButton');
        const cancelButton = document.getElementById('cancelButton');
        
        // Inactive Modal elements
        const inactiveModal = document.getElementById('inactiveModal');
        const closeInactiveModal = document.getElementById('closeInactiveModal');
        const selectOtherCourse = document.getElementById('selectOtherCourse');

        // Initialize modal display to none
        if (confirmationModal) confirmationModal.style.display = 'none';
        if (inactiveModal) inactiveModal.style.display = 'none';

        if (beginButton) {
            beginButton.addEventListener('click', function () {
                console.log('Begin button clicked, submitting form...');
                sessionStorage.clear(); // Clear storage and submit
                if (form) {
                    // Remove the event listener to prevent infinite loop
                    form.removeEventListener('submit', arguments.callee);
                    form.submit();
                }
            });
        }

        if (cancelButton) {
            cancelButton.addEventListener('click', function () {
                if (confirmationModal) confirmationModal.style.display = 'none';
            });
        }
        
        // Inactive Modal handlers
        if (closeInactiveModal) {
            closeInactiveModal.addEventListener('click', function () {
                if (inactiveModal) inactiveModal.style.display = 'none';
            });
        }
        
        if (selectOtherCourse) {
            selectOtherCourse.addEventListener('click', function () {
                if (inactiveModal) inactiveModal.style.display = 'none';
                // Clear the course selection
                if (courseSelect) {
                    courseSelect.value = '';
                    const courseInfo = document.getElementById('courseInfo');
                    if (courseInfo) courseInfo.style.display = 'none';
                }
            });
        }

        // Close modals when clicking outside
        if (confirmationModal) {
            confirmationModal.addEventListener('click', function (e) {
                if (e.target === confirmationModal) {
                    confirmationModal.style.display = 'none';
                }
            });
        }
        
        if (inactiveModal) {
            inactiveModal.addEventListener('click', function (e) {
                if (e.target === inactiveModal) {
                    inactiveModal.style.display = 'none';
                }
            });
        }
    });

    // Global variables for delete modal
    let deleteExamId = null;
    let deleteStudentName = null;
    let deleteCourseName = null;

    function showDeleteModal(examId, studentName, courseName) {
        deleteExamId = examId;
        deleteStudentName = studentName;
        deleteCourseName = courseName;
        
        console.log('Showing delete modal for:', {examId, studentName, courseName});
        
        const modal = document.getElementById('deleteModal');
        if (!modal) {
            console.error('Delete modal not found!');
            alert('Error: Delete modal not found.');
            return;
        }
        
        const modalMessage = document.getElementById('deleteModalMessage');
        if (!modalMessage) {
            console.error('Modal message element not found!');
            return;
        }
        
        // Clean up text
        const cleanStudentName = studentName ? studentName.replace(/'/g, "\\'") : 'Unknown Student';
        const cleanCourseName = courseName ? courseName.replace(/'/g, "\\'") : 'Unknown Course';
        
        modalMessage.innerHTML = `Are you sure you want to delete the exam result for:<br><br>
                                 <strong>Student:</strong> ${cleanStudentName}<br>
                                 <strong>Course:</strong> ${cleanCourseName}<br>
                                // <strong>Exam ID:</strong> ${examId}<br><br>
                                 <span style="color: #dc3545; font-weight: bold;">
                                 <i class="fas fa-exclamation-triangle"></i> This action cannot be undone!</span>`;
        
        modal.style.display = 'flex';
    }
    
    function closeDeleteModal() {
        const modal = document.getElementById('deleteModal');
        if (modal) {
            modal.style.display = 'none';
        }
        deleteExamId = null;
        deleteStudentName = null;
        deleteCourseName = null;
    }
    
    function confirmDelete() {
        if (!deleteExamId) {
            alert('No exam selected for deletion.');
            return;
        }
        
        console.log('Confirming delete for exam ID:', deleteExamId);
        
        // Show loading state
        const deleteBtn = document.querySelector('#deleteModal .modal-footer .btn-danger');
        if (deleteBtn) {
            const originalText = deleteBtn.innerHTML;
            deleteBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
            deleteBtn.disabled = true;
            
            // Revert button after 5 seconds if something goes wrong
            setTimeout(() => {
                deleteBtn.innerHTML = originalText;
                deleteBtn.disabled = false;
            }, 5000);
        }

        // Submit delete request
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'controller.jsp';

        // Add CSRF token
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'csrf_token';
        csrfInput.value = '<%= session.getAttribute("csrf_token") != null ? session.getAttribute("csrf_token") : "" %>';
        form.appendChild(csrfInput);

        const pageInput = document.createElement('input');
        pageInput.type = 'hidden';
        pageInput.name = 'page';
        pageInput.value = 'results';
        form.appendChild(pageInput);

        const operationInput = document.createElement('input');
        operationInput.type = 'hidden';
        operationInput.name = 'operation';
        operationInput.value = 'delete';
        form.appendChild(operationInput);

        const examIdInput = document.createElement('input');
        examIdInput.type = 'hidden';
        examIdInput.name = 'eid';
        examIdInput.value = deleteExamId;
        form.appendChild(examIdInput);

        console.log('Submitting delete form for exam ID:', deleteExamId);
        document.body.appendChild(form);
        form.submit();
    }

    // Close delete modal when clicking outside
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('deleteModal');
        if (event.target === modal) {
            closeDeleteModal();
        }
        
        const inactiveModal = document.getElementById('inactiveModal');
        if (event.target === inactiveModal) {
            inactiveModal.style.display = 'none';
        }
    });

    // Add keyboard support for modals
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeDeleteModal();
            const inactiveModal = document.getElementById('inactiveModal');
            if (inactiveModal && inactiveModal.style.display === 'flex') {
                inactiveModal.style.display = 'none';
            }
        }
    });
</script>
