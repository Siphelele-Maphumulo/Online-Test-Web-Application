
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/gh/Bernardo-Castilho/dragdroptouch@master/DragDropTouch.js"></script>
<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.Exams"%>
<%@ page isELIgnored="true" %>
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
    
    // Null-coalescing function: returns value if non-null/non-empty, otherwise fallback
    public String nz(String v, String fallback) {
        return (v != null && !v.trim().isEmpty()) ? v.trim() : fallback;
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
        padding-top: 100px;
        overflow-y: auto;
        background: transparent;
        margin-left: 0px;
        min-height: 100vh;
        min-width: 100vh;
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
        padding: 15px 20px;
        margin-bottom: 10px;
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
    
    /* Exam Header Styles - TOP BAR */
    .exam-header-container {
        position: fixed;
        top: 0;
        left: 15%;
        right: 0;
        width: 85%;
        z-index: 1000;
        background: var(--white);
        box-shadow: 0 2px 10px rgba(0,0,0,0.15);
    }

    .top-progress-bar-row {
        background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
        color: white;
        padding: 10px 20px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
    }

    .progress-info-left {
        font-weight: 600;
        font-size: 14px;
        white-space: nowrap;
    }

    .progress-container-center {
        flex: 1;
        height: 12px;
        background: rgba(255,255,255,0.2);
        border-radius: 6px;
        overflow: hidden;
    }

    .progress-fill {
        height: 100%;
        background: #7fb069;
        width: 0%;
        transition: width 0.3s ease;
    }

    .time-left-right {
        font-weight: 600;
        font-size: 14px;
        white-space: nowrap;
    }

    /* Sub-header Navigation Row */
    .nav-header-row {
        background: white;
        border-bottom: 2px solid var(--primary-blue);
        padding: 10px 20px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }

    .utility-icons {
        display: flex;
        gap: 15px;
    }

    .util-btn {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 20px;
        color: var(--text-dark);
        transition: color 0.2s;
    }

    .util-btn:hover {
        color: var(--accent-blue);
    }

    .question-counter {
        font-size: 24px;
        font-weight: 500;
        color: var(--text-dark);
    }

    .nav-buttons {
        display: flex;
        gap: 10px;
    }

    .exam-nav-btn {
        background: #92AB2F;
        color: white;
        border: none;
        padding: 8px 20px;
        border-radius: 4px;
        font-weight: 600;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: background 0.2s;
    }

    .exam-nav-btn:hover {
        background: #7FB069;
    }

    .exam-nav-btn:disabled {
        background: #ccc;
        cursor: not-allowed;
    }

    .exam-nav-btn.btn-prev i {
        margin-right: 5px;
    }

    .exam-nav-btn.btn-next i {
        margin-left: 5px;
    }
    
    /* Questions Container */
    .questions-container {
        display: flex;
        flex-direction: column;
        gap: 15px;
        margin-bottom: 20px;
        margin-top: -90px;
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
    
    /* ALERT MODALS */
    .alert-modal {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.6);
        z-index: 400;
        backdrop-filter: blur(4px);
        align-items: center;
        justify-content: center;
    }
    
    .alert-modal.active {
        display: flex;
    }
    
    .alert-modal-content {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
        max-width: 420px;
        width: 90%;
        text-align: center;
        animation: modalSlideIn 0.3s ease-out;
        overflow: hidden;
    }
    
    .alert-modal-warning {
        border-top: 5px solid #f59e0b;
    }
    
    .alert-modal-danger {
        border-top: 5px solid #ef4444;
    }
    
    .alert-modal-icon {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 30px auto 20px;
        animation: pulse 2s infinite;
    }
    
    .alert-modal-warning .alert-modal-icon {
        background: linear-gradient(135deg, #fef3c7, #fde68a);
        color: #f59e0b;
        font-size: 32px;
    }
    
    .alert-modal-danger .alert-modal-icon {
        background: linear-gradient(135deg, #fee2e2, #fecaca);
        color: #ef4444;
        font-size: 32px;
    }
    
    @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
    }
    
    .alert-modal-body {
        padding: 0 30px 25px;
    }
    
    .alert-modal-body h3 {
        margin: 0 0 10px;
        font-size: 22px;
        font-weight: 700;
        color: #1f2937;
    }
    
    .alert-modal-body p {
        margin: 0 0 10px;
        font-size: 15px;
        color: #6b7280;
        line-height: 1.5;
    }
    
    .alert-modal-timer {
        font-size: 13px !important;
        color: #9ca3af !important;
        margin-top: 15px !important;
    }
    
    .alert-modal-timer span {
        font-weight: 700;
        color: #f59e0b !important;
    }
    
    .alert-modal-warning-text {
        font-size: 13px !important;
        color: #ef4444 !important;
    }
    
    .alert-modal-footer {
        padding: 20px 30px 30px;
        display: flex;
        gap: 12px;
        justify-content: center;
    }
    
    .btn-alert-secondary,
    .btn-alert-danger {
        padding: 12px 28px;
        border-radius: var(--radius-md);
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all var(--transition-fast);
        border: none;
    }
    
    .btn-alert-secondary {
        background: #f3f4f6;
        color: #4b5563;
    }
    
    .btn-alert-secondary:hover {
        background: #e5e7eb;
    }
    
    .btn-alert-danger {
        background: linear-gradient(135deg, #ef4444, #dc2626);
        color: white;
    }
    
    .btn-alert-danger:hover {
        background: linear-gradient(135deg, #dc2626, #b91c1c);
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
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
        
    .exam-header-container {
        position: static;
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
    }
    
    /* Rearrange Question Styles */
    .rearrange-question {
        background: white;
        border-radius: 12px;
        padding: 0;
        margin: var(--spacing-md) 0;
        box-shadow: var(--shadow-md);
        overflow: hidden;
    }
    
    .rearrange-instructions {
        text-align: left;
        padding: var(--spacing-md) var(--spacing-lg);
        background: #f8fafc;
        border-bottom: 1px solid var(--medium-gray);
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
    }
    
    .rearrange-instructions i {
        font-size: 20px;
        color: var(--success);
    }
    
    .rearrange-instructions strong {
        display: block;
        font-size: 15px;
        color: var(--text-dark);
        margin-bottom: 2px;
    }
    
    .rearrange-instructions p {
        margin: 0;
        color: var(--dark-gray);
        font-size: 13px;
    }
    
    .rearrange-interface {
        display: flex;
        flex-direction: column;
        gap: 10px;
        padding: 20px;
        background: white;
    }
    
    .rearrange-items-list {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }
    
    .rearrange-items-list.horizontal {
        flex-direction: row;
        flex-wrap: wrap;
        justify-content: center;
    }
    
    .rearrange-items-list.grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 15px;
    }
    
    .rearrange-item {
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: white;
        padding: 15px 20px;
        border-radius: var(--radius-md);
        font-size: 15px;
        font-weight: 500;
        box-shadow: var(--shadow-md);
        border: 2px solid transparent;
        transition: all 0.2s ease;
        cursor: grab;
        user-select: none;
        display: flex;
        align-items: center;
        gap: 15px;
    }
    
    .rearrange-item:hover {
        transform: translateY(-2px) scale(1.02);
        box-shadow: var(--shadow-lg);
        border-color: var(--accent-blue-light);
    }
    
    .rearrange-item.dragging {
        opacity: 0.5;
        cursor: grabbing;
        transform: scale(1.05);
    }
    
    .rearrange-item.drag-over {
        border-color: var(--success);
        transform: scale(1.02);
    }
    
    .rearrange-item .item-position {
        background: rgba(255, 255, 255, 0.2);
        border-radius: 50%;
        width: 28px;
        height: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        font-weight: 600;
    }
    
    .rearrange-item .drag-handle {
        color: rgba(255, 255, 255, 0.7);
        font-size: 18px;
        margin-right: 5px;
        cursor: grab;
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
    
    /* Horizontal orientation - drop targets side by side */
    .drag-drop-container.horizontal-layout {
        grid-template-columns: 1fr 1fr;
    }
    
    .horizontal-layout .drop-targets-list {
        display: flex;
        flex-direction: row;
        flex-wrap: nowrap;
        gap: 15px;
        align-items: center;
        justify-content: flex-end;
    }
    
    .horizontal-layout .drop-target {
        width: 120px;
        height: 80px;
        flex: 0 0 auto;
        margin: 0;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .horizontal-layout .drop-target.inline-target {
        width: auto;
        height: auto;
        display: inline-block;
    }
    
    .horizontal-layout .drop-target.inline-target .drop-zone-inline {
        width: 120px;
        height: 80px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }
    
    .drag-drop-container.vertical-layout {
        grid-template-columns: 1fr;
    }

    /* Landscape / Code Box Layout */
    .drag-drop-container.landscape-layout {
        grid-template-columns: 200px 1fr;
        gap: 20px;
        align-items: start;
    }

    .landscape-layout .draggable-items-panel {
        padding: 15px;
        background: #f1f5f9;
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-md);
    }
    
    /* Keep drag items vertical in landscape mode */
    .landscape-layout .drag-items-list {
        display: flex;
        flex-direction: column;
        gap: 10px;
        align-items: stretch;
        padding: 10px;
    }

    .landscape-layout .drop-targets-panel {
        padding: 15px;
        background: #ffffff;
        border: 2px solid #e2e8f0;
        border-style: solid; /* Override dashed */
        display: flex;
        flex-direction: column;
    }

    .landscape-layout .drop-targets-list {
        display: flex;
        flex-direction: column;
        gap: 8px;
        align-items: stretch;
        padding: 10px;
        justify-content: flex-start;
    }

    .landscape-layout .drop-target {
        min-height: 60px;
        min-width: 80px;
        padding: 8px;
        border: 2px dashed #cbd5e1;
        background: #f8fafc;
        display: flex;
        flex-direction: column;
        justify-content: center;
        flex: 0 0 auto;
    }
    
    .landscape-layout .drop-target-header {
        font-size: 11px;
        margin-bottom: 4px;
        text-align: center;
        white-space: nowrap;
    }

    .landscape-layout .drag-item {
        padding: 10px 15px;
        font-size: 13px;
        margin-bottom: 8px;
        display: block;
        width: 100%;
        box-sizing: border-box;
    }

    .landscape-layout .dropped-item {
        padding: 6px 10px;
        font-size: 12px;
        min-width: 60px;
        display: block;
        margin: 4px 0;
    }

    .landscape-layout .placeholder {
        font-size: 11px;
        padding: 4px;
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
        border: 2px solid #5D8E2F;
        border-radius: 8px;
        padding: 15px 14px; /* Reduced horizontal padding by 30% */
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
        border-color: #5D8E2F;
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

    .drop-target.target-reordering {
        opacity: 0.5;
        border: 2px solid var(--accent-blue);
    }

    /* Inline style for code blocks with targets */
    .drop-target.inline-target {
        display: block;
        border: 1px solid #e2e8f0;
        background: #ffffff;
        padding: 10px 15px;
        min-height: auto;
        margin-bottom: 5px;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        line-height: 1.6;
        white-space: pre-wrap;
    }

    .drop-target.inline-target .drop-zone-inline {
        display: inline-flex;
        min-width: 120px;
        min-height: 34px;
        border: 2px dashed #94a3b8;
        border-radius: 4px;
        background: #f1f5f9;
        vertical-align: middle;
        margin: 0 5px;
        padding: 2px;
        transition: all 0.2s;
        align-items: center;
        justify-content: center;
    }

    .drop-target.inline-target .drop-zone-inline.drag-over {
        border-color: var(--accent-blue);
        background: #eff6ff;
    }

    .drop-target.inline-target .dropped-item {
        margin: 0;
        padding: 4px 10px;
        font-size: 13px;
        border-radius: 4px;
    }
    
    .drop-target.waiting {
        border: 2px dashed #92AB2F;
    }

    .drop-target.inline-target.waiting .drop-zone-inline {
        border-color: #92AB2F;
    }
    
    @keyframes blinkBorder {
        0%, 50% { border-color: #92AB2F; border-style: dashed; }
        25%, 75% { border-color: #5D8E2F; border-style: solid; }
        100% { border-color: #92AB2F; border-style: dashed; }
    }
    
    .drop-target-header {
        font-size: 13px;
        font-weight: 600;
        color: var(--dark-gray);
        margin-bottom: 5px;
        white-space: pre-wrap;
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
            max-width: calc(100% - 200px);
        }
    }

    /* Scientific Calculator Styles */
    .calculator-modal {
        display: none;
        position: fixed;
        top: 150px;
        left: 250px;
        z-index: 1000;
        background: #f1f3f4;
        border-radius: 8px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.3);
        width: 320px;
        height: 220px;
        padding: 15px;
        border: 1px solid #ccc;
    }

    .calc-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;
        padding-bottom: 5px;
        border-bottom: 1px solid #ddd;
        cursor: move;
    }

    .calc-title {
        font-size: 14px;
        font-weight: 600;
        color: #555;
    }

    .calc-display {
        background: white;
        border: 1px solid #ccc;
        border-radius: 4px;
        padding: 10px;
        text-align: right;
        font-family: 'Consolas', monospace;
        margin-bottom: 15px;
    }

    .calc-history {
        font-size: 12px;
        color: #888;
        min-height: 1.2em;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .calc-main-val {
        font-size: 24px;
        font-weight: 500;
        word-wrap: break-word;
        min-height: 1.2em;
    }

    .calc-buttons {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 8px;
    }

    .calc-btn {
        padding: 10px;
        border: 1px solid #dcdcdc;
        border-radius: 4px;
        background: #fff;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
        transition: background 0.1s;
    }

    .calc-btn:hover {
        background: #f8f8f8;
    }

    .calc-btn.op {
        background: #f1f3f4;
        color: #1a73e8;
    }

    .calc-btn.eq {
        background: #1a73e8;
        color: white;
        grid-column: span 2;
    }

    .calc-btn.sci {
        font-size: 12px;
        color: #555;
    }

    /* Rough Paper Styles */
    .rough-paper-modal {
        display: none;
        position: fixed;
        top: 150px;
        right: 50px;
        z-index: 1000;
        background: #fff9c4;
        border-radius: 4px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        width: 400px;
        padding: 0;
        border: 1px solid #fbc02d;
    }

    .rough-header {
        background: #fbc02d;
        color: #333;
        padding: 8px 12px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: move;
        font-weight: 600;
        font-size: 14px;
    }

    .rough-content {
        padding: 10px;
    }

    .rough-textarea {
        width: 100%;
        height: 300px;
        border: none;
        background: transparent;
        resize: both;
        font-family: 'Courier New', monospace;
        font-size: 16px;
        line-height: 1.5;
        outline: none;
    }
.question-counter:hover {
    background-color: rgba(146, 171, 47, 0.1);
    border-radius: 4px;
    padding: 2px 4px;
}

</style>

<style>
/* Question Navigation Modal Styles */
.question-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(60px, 1fr));
    gap: 12px;
    max-height: 400px;
    overflow-y: auto;
    padding: 10px;
}

.question-icon {
    width: 60px;
    height: 60px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 18px;
    color: white;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    border: 2px solid transparent;
}

.question-icon:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    border-color: #3b82f6;
}

.question-icon.answered {
    background: #10b981;
}

.question-icon.unanswered {
    background: #ef4444;
}

.question-icon.current {
    border: 2px solid #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
}

.alert-modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.close-modal-btn {
    background: none;
    border: none;
    color: white;
    font-size: 24px;
    cursor: pointer;
    padding: 0;
    width: 30px;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    transition: background-color 0.2s;
}

.close-modal-btn:hover {
    background: rgba(255, 255, 255, 0.1);
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
                <a class="nav-item active" href="std-page.jsp?pgprt=1"><i class="fas fa-file-alt"></i><span>Lunch Exam</span></a>
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
            <!-- EXAM ACTIVE HEADER -->
            <div class="exam-header-container">
                <div class="top-progress-bar-row">
                    <div class="progress-info-left">Exam Progress (<span id="examProgressPctHeader">0%</span>)</div>
                    <div class="progress-container-center">
                        <div class="progress-fill" id="progressBarHeader"></div>
                    </div>
                    <div class="time-left-right">Time Left: <span id="remainingTimeHeader">--:--</span></div>
                </div>
                <div class="nav-header-row">
                    <div class="utility-icons">
                        <button type="button" class="util-btn" onclick="toggleCalculator()" title="Scientific Calculator">
                            <i class="fas fa-calculator"></i>
                        </button>
                        <button type="button" class="util-btn" onclick="toggleRoughPaper()" title="Rough Paper">
                            <i class="fas fa-sticky-note"></i>
                        </button>
                    </div>
                    <div class="question-counter" style="cursor: pointer;" onclick="showQuestionNavigationModal()" title="Click to navigate to any question">Question <span id="currentQNum">1</span>/<%= totalQ %></div>
                    <div class="nav-buttons">
                        <button type="button" class="exam-nav-btn btn-first" onclick="goToFirstQuestion()" title="Go to first question">
                            <i class="fas fa-step-backward"></i>
                        </button>
                        <button type="button" class="exam-nav-btn btn-prev" id="prevBtn" onclick="prevQuestion()" disabled>
                            <i class="fas fa-arrow-left"></i> Prev
                        </button>
                        <button type="button" class="exam-nav-btn btn-next" id="nextBtn" onclick="nextQuestion()">
                            Next <i class="fas fa-arrow-right"></i>
                        </button>
                        <button type="button" class="exam-nav-btn btn-last" onclick="goToLastQuestion()" title="Go to last question">
                            <i class="fas fa-step-forward"></i>
                        </button>
                    </div>
                </div>
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
                    boolean isRearrange = false;
                    try{
                        String qt = q.getQuestion().toLowerCase();
                        String questionType = q.getQuestionType();
                        isMultiTwo = "MultipleSelect".equalsIgnoreCase(questionType) ||
                                    qt.contains("select two") || qt.contains("choose two") || 
                                    qt.contains("pick two") || qt.contains("multiple answers") || 
                                    qt.contains("two options") || qt.contains("multiple select") ||
                                    qt.contains("select multiple") || qt.contains("choose multiple");
                        isDragDrop = "DRAG_AND_DROP".equalsIgnoreCase(questionType);
                        isRearrange = "REARRANGE".equalsIgnoreCase(questionType);
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
                                     data-targets-json="<%= escapeHtmlAttr(targetsArray.toString()) %>"
                                     data-extra-data="<%= escapeHtmlAttr(nz(q.getExtraData(), "{}")) %>">
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
                            <% } else if(isRearrange) {
                                org.json.JSONArray itemsArray = new org.json.JSONArray();
                                if (q.getRearrangeItems() != null && !q.getRearrangeItems().isEmpty()) {
                                    for (myPackage.classes.RearrangeItem ri : q.getRearrangeItems()) {
                                        org.json.JSONObject jo = new org.json.JSONObject();
                                        jo.put("id", ri.getId());
                                        jo.put("text", ri.getItemText());
                                        itemsArray.put(jo);
                                    }
                                } else if (q.getRearrangeItemsJson() != null && !q.getRearrangeItemsJson().isEmpty()) {
                                    try {
                                        itemsArray = new org.json.JSONArray(q.getRearrangeItemsJson());
                                    } catch (Exception e) {}
                                }
                            %>
                                <div class="rearrange-question"
                                     data-items-json="<%= escapeHtmlAttr(itemsArray.toString()) %>"
                                     data-extra-data="<%= escapeHtmlAttr(nz(q.getExtraData(), "{}")) %>">
                                    <div class="rearrange-instructions">
                                        <i class="fas fa-sort-amount-down"></i>
                                        <div>
                                            <strong>Rearrange the Items</strong>
                                            <p>Drag and drop the items below into the correct sequence order.</p>
                                        </div>
                                    </div>
                                    <div class="rearrange-interface" id="rearrange_<%= i %>">
                                        <!-- Rearrange items will be loaded dynamically -->
                                    </div>
                                    <input type="hidden" name="rearrangeQuestion_<%= i %>" value="true">
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
                        <input type="hidden" name="qtype<%= i %>" value="<%= isDragDrop?"dragdrop":(isRearrange?"rearrange":(isMultiTwo?"multi2":"single")) %>">
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

                <!-- TIME UP MODAL -->
                <div id="timeUpModal" class="alert-modal">
                    <div class="alert-modal-content alert-modal-warning">
                        <div class="alert-modal-icon">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="alert-modal-body">
                            <h3>Time is Up!</h3>
                            <p>Your exam will be submitted automatically.</p>
                            <p class="alert-modal-timer">Submitting in <span id="timeUpCountdown">3</span> seconds...</p>
                        </div>
                    </div>
                </div>

                <!-- CONFIRM SUBMIT MODAL -->
                <div id="confirmSubmitModal" class="alert-modal">
                    <div class="alert-modal-content alert-modal-danger">
                        <div class="alert-modal-icon">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div class="alert-modal-body">
                            <h3>Confirm Submission</h3>
                            <p>Are you sure you want to submit your exam?</p>
                            <p class="alert-modal-warning-text">This action cannot be undone.</p>
                        </div>
                        <div class="alert-modal-footer">
                            <button type="button" class="btn-alert-secondary" onclick="closeConfirmSubmitModal()">Cancel</button>
                            <button type="button" class="btn-alert-danger" id="confirmSubmitBtn">Submit Exam</button>
                        </div>
                    </div>
                </div>

                <!-- QUESTION NAVIGATION MODAL -->
                <div id="questionNavModal" class="alert-modal" style="display: none;">
                    <div class="alert-modal-content" style="max-width: 800px; width: 90%;">
                        <div class="alert-modal-header" style="background: #09294d; color: white; padding: 20px; border-radius: 12px 12px 0 0;">
                            <h3 style="margin: 0; display: flex; align-items: center; gap: 10px;">
                                <i class="fas fa-list-ol"></i>
                                Question Navigation
                            </h3>
                            <button type="button" class="close-modal-btn" onclick="closeQuestionNavModal()" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer;">&times;</button>
                        </div>
                        <div class="alert-modal-body" style="padding: 20px;">
                            <p style="margin-bottom: 20px; color: #64748b;">Click on any question number to navigate directly to that question.</p>
                            <div id="questionGrid" class="question-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(60px, 1fr)); gap: 12px; max-height: 400px; overflow-y: auto; padding: 10px;">
                                <!-- Question icons will be populated by JavaScript -->
                            </div>
                        </div>
                        <div class="alert-modal-footer" style="padding: 15px 20px; border-top: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                            <div style="display: flex; gap: 15px; align-items: center;">
                                <div style="display: flex; align-items: center; gap: 5px;">
                                    <div style="width: 20px; height: 20px; background: #10b981; border-radius: 4px;"></div>
                                    <span style="font-size: 14px; color: #64748b;">Answered</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 5px;">
                                    <div style="width: 20px; height: 20px; background: #ef4444; border-radius: 4px;"></div>
                                    <span style="font-size: 14px; color: #64748b;">Unanswered</span>
                                </div>
                            </div>
                            <button type="button" class="btn-secondary" onclick="closeQuestionNavModal()">Close</button>
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
                                <div class="stat-item"><span class="stat-number" id="submitUnanswered" style="cursor: pointer; text-decoration: underline;" onclick="handleUnansweredClick()"><%= totalQ %></span><span class="stat-label">Unanswered</span></div>
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

                <!-- FIXED BOTTOM PANEL REMOVED -->
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
                var currentQuestionIndex = 0;

                /* --- CALCULATOR LOGIC --- */
                var calcInputStr = "";
                
                function toggleCalculator() {
                    var modal = document.getElementById('calculatorModal');
                    if (modal.style.display === 'block') {
                        modal.style.display = 'none';
                    } else {
                        modal.style.display = 'block';
                    }
                }

                function calcInput(val) {
                    calcInputStr += val;
                    document.getElementById('calcDisplay').textContent = calcInputStr.replace(/Math\.PI/g, '?').replace(/Math\.E/g, 'e');
                }

                function calcAction(action) {
                    var display = document.getElementById('calcDisplay');
                    var history = document.getElementById('calcHistory');

                    if (action === 'clear') {
                        calcInputStr = "";
                        display.textContent = "0";
                        history.textContent = "";
                    } else if (action === 'backspace') {
                        calcInputStr = calcInputStr.slice(0, -1);
                        display.textContent = calcInputStr || "0";
                    } else if (action === 'equal') {
                        try {
                            var result = eval(calcInputStr);
                            history.textContent = calcInputStr.replace(/Math\.PI/g, '?').replace(/Math\.E/g, 'e') + " =";
                            calcInputStr = result.toString();
                            display.textContent = calcInputStr;
                        } catch (e) {
                            display.textContent = "Error";
                            calcInputStr = "";
                        }
                    } else if (['sin', 'cos', 'tan', 'log', 'ln', 'sqrt'].includes(action)) {
                        try {
                            var val = eval(calcInputStr || "0");
                            var res = 0;
                            // Convert degrees to radians for trigonometric functions
                            var rad = val * (Math.PI / 180);
                            switch(action) {
                                case 'sin': res = Math.sin(rad); break;
                                case 'cos': res = Math.cos(rad); break;
                                case 'tan': res = Math.tan(rad); break;
                                case 'log': res = Math.log10(val); break;
                                case 'ln': res = Math.log(val); break;
                                case 'sqrt': res = Math.sqrt(val); break;
                            }
                            history.textContent = action + "(" + val + (['sin','cos','tan'].includes(action) ? "?" : "") + ") =";
                            // Round to 8 decimal places to avoid floating point issues
                            res = Math.round(res * 100000000) / 100000000;
                            calcInputStr = res.toString();
                            display.textContent = calcInputStr;
                        } catch (e) {
                            display.textContent = "Error";
                        }
                    } else if (action === 'pow') {
                        calcInputStr += "**";
                        display.textContent = calcInputStr;
                    }
                }

                // Drag functionality for calculator
                function initCalcDraggable() {
                    dragElement(document.getElementById("calculatorModal"));
                }

                function dragElement(elmnt) {
                    var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
                    var header = document.getElementById("calcHeader");
                    if (header) {
                        header.onmousedown = dragMouseDown;
                    } else {
                        elmnt.onmousedown = dragMouseDown;
                    }

                    function dragMouseDown(e) {
                        e = e || window.event;
                        e.preventDefault();
                        pos3 = e.clientX;
                        pos4 = e.clientY;
                        document.onmouseup = closeDragElement;
                        document.onmousemove = elementDrag;
                    }

                    function elementDrag(e) {
                        e = e || window.event;
                        e.preventDefault();
                        pos1 = pos3 - e.clientX;
                        pos2 = pos4 - e.clientY;
                        pos3 = e.clientX;
                        pos4 = e.clientY;
                        elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
                        elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
                    }

                    function closeDragElement() {
                        document.onmouseup = null;
                        document.onmousemove = null;
                    }
                }

                /* --- ROUGH PAPER LOGIC --- */
                function toggleRoughPaper() {
                    var modal = document.getElementById('roughPaperModal');
                    if (modal.style.display === 'block') {
                        modal.style.display = 'none';
                    } else {
                        modal.style.display = 'block';
                    }
                }

                function initRoughPaper() {
                    var textarea = document.getElementById('roughTextarea');
                    if (!textarea) return;
                    
                    var saved = sessionStorage.getItem('exam_rough_notes');
                    if (saved) textarea.value = saved;

                    textarea.addEventListener('input', function() {
                        sessionStorage.setItem('exam_rough_notes', this.value);
                    });
                    
                    var roughModal = document.getElementById("roughPaperModal");
                    var roughHeader = document.getElementById("roughHeader");
                    
                    // Simple drag implementation for rough paper
                    if (roughHeader) {
                        roughHeader.onmousedown = function(e) {
                            var pos1 = 0, pos2 = 0, pos3 = e.clientX, pos4 = e.clientY;
                            document.onmouseup = function() {
                                document.onmouseup = null;
                                document.onmousemove = null;
                            };
                            document.onmousemove = function(e) {
                                pos1 = pos3 - e.clientX;
                                pos2 = pos4 - e.clientY;
                                pos3 = e.clientX;
                                pos4 = e.clientY;
                                roughModal.style.top = (roughModal.offsetTop - pos2) + "px";
                                roughModal.style.left = (roughModal.offsetLeft - pos1) + "px";
                            };
                        };
                    }
                }

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

                function showQuestion(index) {
                    var cards = document.querySelectorAll('.question-card');
                    cards.forEach(function(card, idx) {
                        if (idx === index) {
                            card.style.display = 'block';
                        } else {
                            card.style.display = 'none';
                        }
                    });

                    // Update counter
                    var currentQNumEl = document.getElementById('currentQNum');
                    if (currentQNumEl) currentQNumEl.textContent = index + 1;

                    // Update buttons
                    var prevBtn = document.getElementById('prevBtn');
                    var nextBtn = document.getElementById('nextBtn');
                    var submitSection = document.querySelector('.submit-section');

                    if (prevBtn) prevBtn.disabled = (index === 0);
                    
                    if (index === totalQuestions - 1) {
                        if (nextBtn) {
                            nextBtn.innerHTML = 'Finish <i class="fas fa-flag-checkered"></i>';
                            nextBtn.style.background = '#059669';
                        }
                        if (submitSection) submitSection.style.display = 'flex';
                    } else {
                        if (nextBtn) {
                            nextBtn.innerHTML = 'Next <i class="fas fa-arrow-right"></i>';
                            nextBtn.style.background = '#92AB2F';
                        }
                        if (submitSection) submitSection.style.display = 'none';
                    }
                    
                    currentQuestionIndex = index;
                    updateProgress();
                    
                    // Update current question highlight in navigation modal if it's open
                    const modalIcons = document.querySelectorAll('#questionGrid .question-icon');
                    modalIcons.forEach(icon => {
                        icon.classList.remove('current');
                        if (parseInt(icon.getAttribute('data-qindex')) === index) {
                            icon.classList.add('current');
                        }
                    });
                }

                function nextQuestion() {
                    if (currentQuestionIndex < totalQuestions - 1) {
                        showQuestion(currentQuestionIndex + 1);
                        window.scrollTo(0, 0);
                    } else {
                        // On last question, show submit section if not already visible
                        document.querySelector('.submit-section').scrollIntoView({ behavior: 'smooth' });
                    }
                }

                function prevQuestion() {
                    if (currentQuestionIndex > 0) {
                        showQuestion(currentQuestionIndex - 1);
                        window.scrollTo(0, 0);
                    }
                }

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
                    var progressBarHeader = document.getElementById('progressBarHeader');
                    var modalProgressBar = document.getElementById('modalProgressBar');
                    if(progressBar) progressBar.style.width = pct + '%';
                    if(progressBarHeader) progressBarHeader.style.width = pct + '%';
                    if(modalProgressBar) modalProgressBar.style.width = pct + '%';
                    
                    // Update labels
                    var progressLabel = document.getElementById('progressLabel');
                    var examProgressPctHeader = document.getElementById('examProgressPctHeader');
                    var progressPercent = document.querySelector('.progress-percent');
                    if(progressLabel) progressLabel.textContent = pct + '%';
                    if(examProgressPctHeader) examProgressPctHeader.textContent = pct + '%';
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
                    var timerEl = document.getElementById('remainingTimeHeader');
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
                        var formattedTime = fmt(minutes) + ':' + fmt(seconds);
                        timerEl.textContent = formattedTime;
                        
                        var headerTimer = document.getElementById('remainingTimeHeader');
                        if (headerTimer) headerTimer.textContent = formattedTime;
                        
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
                    
                    // Handle Drag and Drop answers - save before auto-submit
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
                    
                    // Show time up modal
                    showTimeUpModal();
                    
                    // Clean up and submit
                    cleanupExam();
                    setTimeout(function() {
                        document.getElementById('myform').submit();
                    }, 3000);
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
                    
                    // Final confirmation - show modal
                    showConfirmSubmitModal();
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
                
                /* --- TIME UP MODAL FUNCTIONS --- */
                function showTimeUpModal() {
                    var modal = document.getElementById('timeUpModal');
                    if (modal) {
                        modal.classList.add('active');
                        
                        // Countdown
                        var countdown = 3;
                        var countdownEl = document.getElementById('timeUpCountdown');
                        var interval = setInterval(function() {
                            countdown--;
                            if (countdownEl) countdownEl.textContent = countdown;
                            if (countdown <= 0) {
                                clearInterval(interval);
                            }
                        }, 1000);
                    }
                }
                
                /* --- CONFIRM SUBMIT MODAL FUNCTIONS --- */
                function showConfirmSubmitModal() {
                    var modal = document.getElementById('confirmSubmitModal');
                    var confirmBtn = document.getElementById('confirmSubmitBtn');
                    
                    if (modal) {
                        modal.classList.add('active');
                        
                        // Set up confirm button handler
                        if (confirmBtn) {
                            confirmBtn.onclick = function() {
                                closeConfirmSubmitModal();
                                
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
                            };
                        }
                    }
                }
                
                function closeConfirmSubmitModal() {
                    var modal = document.getElementById('confirmSubmitModal');
                    if (modal) {
                        modal.classList.remove('active');
                    }
                }

                /* --- INITIALIZATION --- */
                document.addEventListener('DOMContentLoaded', function() {
                    // Initialize components
                    showQuestion(0);
                    startTimer();
                    initCalcDraggable();
                    initRoughPaper();
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
        
        // Check for orientation in extra_data
        try {
            var extraDataStr = questionContainer.getAttribute('data-extra-data');
            var isLandscape = false;
            
            if (extraDataStr) {
                var extraData = JSON.parse(extraDataStr);
                if (extraData.orientation === 'vertical') {
                    var container = questionContainer.querySelector('.drag-drop-container');
                    if (container) container.classList.add('vertical-layout');
                } else if (extraData.orientation === 'landscape') {
                    isLandscape = true;
                } else if (extraData.orientation === 'horizontal') {
                    // Apply horizontal layout class
                    var container = questionContainer.querySelector('.drag-drop-container');
                    if (container) container.classList.add('horizontal-layout');
                }
            }
            
            // Auto-detect landscape based on keywords or structure if not explicitly set
            var questionText = card.querySelector('.question-text') ? card.querySelector('.question-text').textContent.toLowerCase() : '';
            if (questionText.includes('code') || questionText.includes('line') || questionText.includes('order')) {
                isLandscape = true;
            }
            
            if (isLandscape) {
                var container = questionContainer.querySelector('.drag-drop-container');
                if (container) container.classList.add('landscape-layout');
            }
        } catch (e) {
            console.log('Error parsing extra data for orientation');
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
    
    // RANDOMIZE: Shuffle only items (targets stay in original order)
    var shuffledItems = shuffleArray(normalizedItems.slice());
    // Keep targets in original order - but we allow manual reordering now
    var orderedTargets = normalizedTargets.slice();
    
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
    
    // Render Targets
    dropContainer.innerHTML = '';
    for (var i = 0; i < orderedTargets.length; i++) {
        var target = orderedTargets[i];
        var el = document.createElement('div');
        el.id = 'q' + qIdx + '_target_' + target.id;
        el.setAttribute('data-target-id', target.id);
        el.draggable = true; // Targets are now draggable for reordering
        
        // Handle [[target]] placeholder
        var label = target.label || "";
        var parts = label.split('[[target]]');
        
        if (parts.length > 1) {
            el.className = 'drop-target inline-target';
            el.innerHTML = '<span>' + parts[0] + '</span>' + 
                           '<div class="drop-zone-inline"><div class="placeholder">Drop</div></div>' +
                           '<span>' + (parts[1] || "") + '</span>';
        } else {
            el.className = 'drop-target';
            el.innerHTML = '<div class="drop-target-header">' + label + '</div>' +
                           '<div class="placeholder">Drop here</div>';
        }
        
        // Listeners for item drops
        el.addEventListener('dragover', handleDragOver);
        el.addEventListener('dragenter', handleDragEnter);
        el.addEventListener('dragleave', handleDragLeave);
        el.addEventListener('drop', handleDrop);
        
        // Listeners for target reordering
        el.addEventListener('dragstart', handleTargetDragStart);
        el.addEventListener('dragend', handleTargetDragEnd);
        
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
let draggedTargetRow = null;

function handleTargetDragStart(e) {
    if (e.target.classList.contains('dropped-item') || e.target.closest('.dropped-item')) return;
    draggedTargetRow = this;
    this.classList.add('target-reordering');
    e.dataTransfer.setData('text/target-id', this.id);
    e.dataTransfer.effectAllowed = 'move';
    
    // Create a ghost image or just let it be
}

function handleTargetDragEnd(e) {
    this.classList.remove('target-reordering');
    draggedTargetRow = null;
}

function handleDragStart(e) {
    e.target.classList.add('dragging');
    e.dataTransfer.setData('text/plain', e.target.id);
    e.dataTransfer.setData('text/type', 'item');
    e.dataTransfer.effectAllowed = 'move';
}

function handleDragEnd(e) {
    e.target.classList.remove('dragging');
}

function handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    
    // Handle target reordering shifting
    if (draggedTargetRow && this !== draggedTargetRow && this.classList.contains('drop-target')) {
        if (this.parentNode === draggedTargetRow.parentNode) {
            const container = this.parentNode;
            const children = Array.from(container.children);
            const draggedIndex = children.indexOf(draggedTargetRow);
            const targetIndex = children.indexOf(this);
            
            if (draggedIndex < targetIndex) {
                container.insertBefore(draggedTargetRow, this.nextSibling);
            } else {
                container.insertBefore(draggedTargetRow, this);
            }
        }
    }
}

function handleDragEnter(e) {
    e.preventDefault();
    if (draggedTargetRow) return; // Don't highlight for target reordering
    
    var target = e.target.closest('.drop-target');
    if (target) {
        var zone = target.querySelector('.drop-zone-inline') || target;
        zone.classList.add('drag-over');
        target.classList.remove('waiting');
    }
}

function handleDragLeave(e) {
    if (draggedTargetRow) return;
    
    var target = e.target.closest('.drop-target');
    if (target) {
        var zone = target.querySelector('.drop-zone-inline') || target;
        zone.classList.remove('drag-over');
        // Add waiting state back if target doesn't have items
        if (!target.querySelector('.dropped-item')) {
            target.classList.add('waiting');
        }
    }
}

function createDroppedItem(qIdx, targetId, itemId, text) {
    var el = document.createElement('div');
    el.className = 'dropped-item';
    el.draggable = true;
    el.id = 'q' + qIdx + '_dropped_' + itemId;
    el.setAttribute('data-item-id', itemId);
    el.setAttribute('data-text', text);
    el.innerHTML = '<span>' + text + '</span>' +
                  '<button type="button" class="remove-btn" title="Remove">&times;</button>';
    
    el.addEventListener('dragstart', handleDragStart);
    el.addEventListener('dragend', handleDragEnd);
    
    el.querySelector('.remove-btn').onclick = function() {
        removeItemFromTarget(qIdx, targetId, itemId, text);
    };
    return el;
}

function handleDrop(e) {
    e.preventDefault();
    
    if (draggedTargetRow) {
        // Target reordering drop - handled in dragover for shifting
        return;
    }
    
    var target = e.target.closest('.drop-target');
    if (!target) return;
    
    var zone = target.querySelector('.drop-zone-inline') || target;
    zone.classList.remove('drag-over');
    target.classList.remove('waiting');
    
    var itemId = e.dataTransfer.getData('text/plain');
    var draggedEl = document.getElementById(itemId);
    if (!draggedEl || !draggedEl.classList.contains('drag-item') && !draggedEl.classList.contains('dropped-item')) return;
    
    var qIdx = target.id.split('_')[0].substring(1);
    var targetId = target.getAttribute('data-target-id');
    var itemDataId = draggedEl.getAttribute('data-item-id');
    var itemText = draggedEl.getAttribute('data-text');
    
    // Handle item moving from another target
    var sourceTargetId = null;
    if (draggedEl.classList.contains('dropped-item')) {
        var sourceTarget = draggedEl.closest('.drop-target');
        if (sourceTarget) {
            sourceTargetId = sourceTarget.getAttribute('data-target-id');
            // Remove from source target mapping
            if (userMappings[qIdx]) delete userMappings[qIdx][sourceTargetId];
            draggedEl.remove();
            // Show placeholder in source target if empty
            if (!sourceTarget.querySelector('.dropped-item') && !sourceTarget.querySelector('.placeholder')) {
                var ph = document.createElement('div');
                ph.className = 'placeholder';
                ph.textContent = 'Drop here';
                sourceTarget.appendChild(ph);
            }
        }
    } else {
        // From pool - hide original
        draggedEl.style.display = 'none';
    }

    // Swapping logic: if target already has an item
    if (target.querySelector('.dropped-item')) {
        var existingDropped = target.querySelector('.dropped-item');
        var existingId = existingDropped.getAttribute('data-item-id');
        var existingText = existingDropped.getAttribute('data-text');
        
        if (sourceTargetId) {
            // Swap: move existing item to source target
            var sourceTarget = document.getElementById('q' + qIdx + '_target_' + sourceTargetId);
            if (sourceTarget) {
                var sZone = sourceTarget.querySelector('.drop-zone-inline') || sourceTarget;
                // Remove placeholder from source target if it was just added
                var ph = sZone.querySelector('.placeholder');
                if (ph) ph.remove();
                
                var swappedEl = createDroppedItem(qIdx, sourceTargetId, existingId, existingText);
                sZone.appendChild(swappedEl);
                userMappings[qIdx][sourceTargetId] = existingId;
            }
        } else {
            // Move existing back to pool if new item came from pool
            restoreItemToPool(qIdx, existingId, existingText);
        }
        existingDropped.remove();
    }
    
    // Add new item to target
    var droppedEl = createDroppedItem(qIdx, targetId, itemDataId, itemText);
    zone.appendChild(droppedEl);
    
    // Remove placeholder
    var placeholder = zone.querySelector('.placeholder');
    if (placeholder) placeholder.remove();
    
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
        var zone = target.querySelector('.drop-zone-inline') || target;
        if (!zone.querySelector('.dropped-item')) {
            target.classList.add('waiting');
            if (!zone.querySelector('.placeholder')) {
                 var ph = document.createElement('div');
                 ph.className = 'placeholder';
                 ph.textContent = target.classList.contains('inline-target') ? 'Drop' : 'Drop here';
                 zone.appendChild(ph);
            }
        } else {
            target.classList.remove('waiting');
            var ph = zone.querySelector('.placeholder');
            if (ph) ph.remove();
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
        var zone = target.querySelector('.drop-zone-inline') || target;
        var droppedItem = zone.querySelector('.dropped-item');
        if (droppedItem) droppedItem.remove();
        if (!zone.querySelector('.placeholder')) {
            var placeholder = document.createElement('div');
            placeholder.className = 'placeholder';
            placeholder.textContent = target.classList.contains('inline-target') ? 'Drop' : 'Drop here';
            zone.appendChild(placeholder);
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

/* --- REARRANGE QUESTION FUNCTIONALITY --- */
function initializeRearrangeQuestions() {
    const rearrangeQuestions = document.querySelectorAll('.rearrange-question');
    
    rearrangeQuestions.forEach(function(questionContainer, idx) {
        const card = questionContainer.closest('.question-card');
        if (!card) return;
        
        const questionIndex = card.getAttribute('data-qindex');
        
        const itemsJson = questionContainer.getAttribute('data-items-json');
        let itemsData = [];
        
        try {
            if (itemsJson && itemsJson !== 'null' && itemsJson !== 'undefined') {
                itemsData = JSON.parse(itemsJson);
            }
        } catch (e) {
            console.log('Error parsing rearrange JSON for question ' + (parseInt(questionIndex) + 1));
            itemsData = [];
        }
        
        // Render the rearrange interface
        renderRearrangeInterface(questionIndex, questionContainer, itemsData);
    });
}

function renderRearrangeInterface(qIdx, container, items) {
    // Normalize items
    const normalizedItems = [];
    for (let i = 0; i < items.length; i++) {
        if (typeof items[i] === 'string') {
            normalizedItems.push({ id: 'item_' + i, text: items[i], correctPosition: i + 1 });
        } else {
            normalizedItems.push(items[i]);
        }
    }
    
    // Create the rearrange container
    const rearrangeContainer = document.createElement('div');
    rearrangeContainer.className = 'rearrange-container';
    
    // Create the items list that can be reordered
    const itemsList = document.createElement('div');
    itemsList.className = 'rearrange-items-list';
    itemsList.id = 'rearrangeItemsList_' + qIdx;
    
    // Shuffle items for student to rearrange
    const shuffledItems = [...normalizedItems];
    
    // Fisher-Yates shuffle algorithm
    for (let i = shuffledItems.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffledItems[i], shuffledItems[j]] = [shuffledItems[j], shuffledItems[i]];
    }
    
    // Add shuffled items to the list
    shuffledItems.forEach((item, index) => {
        const itemElement = createRearrangeItemElement(qIdx, item.id, item.text, index);
        itemsList.appendChild(itemElement);
    });
    
    rearrangeContainer.appendChild(itemsList);
    container.appendChild(rearrangeContainer);
    
    // Make the list sortable
    makeSortable(itemsList, qIdx);
}

function createRearrangeItemElement(qIdx, itemId, text, position) {
    const element = document.createElement('div');
    element.className = 'rearrange-item';
    element.draggable = true;
    element.id = 'q' + qIdx + '_rearrange_' + itemId;
    element.setAttribute('data-item-id', itemId);
    element.setAttribute('data-text', text);
    
    element.innerHTML = `
        <i class="fas fa-grip-vertical drag-handle"></i>
        <span class="item-position">${position + 1}</span>
        <span class="item-text">${text}</span>
    `;
    
    // Add drag events
    element.addEventListener('dragstart', handleRearrangeDragStart);
    element.addEventListener('dragend', handleRearrangeDragEnd);
    element.addEventListener('dragover', handleRearrangeDragOver);
    element.addEventListener('dragenter', handleRearrangeDragEnter);
    element.addEventListener('dragleave', handleRearrangeDragLeave);
    element.addEventListener('drop', handleRearrangeDrop);
    
    return element;
}

// Rearrange drag handlers
function handleRearrangeDragStart(e) {
    e.target.classList.add('dragging');
    e.dataTransfer.setData('text/plain', e.target.id);
    e.dataTransfer.effectAllowed = 'move';
}

function handleRearrangeDragEnd(e) {
    e.target.classList.remove('dragging');
    
    // Update positions after drag ends
    const list = e.target.parentElement;
    const qIdx = list.id.replace('rearrangeItemsList_', '');
    updateRearrangePositions(list, qIdx);
    saveRearrangeAnswer(qIdx);
}

function handleRearrangeDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
}

function handleRearrangeDragEnter(e) {
    e.preventDefault();
    e.target.classList.add('drag-over');
}

function handleRearrangeDragLeave(e) {
    e.target.classList.remove('drag-over');
}

function handleRearrangeDrop(e) {
    e.preventDefault();
    e.target.classList.remove('drag-over');
    
    const draggedId = e.dataTransfer.getData('text/plain');
    const draggedElement = document.getElementById(draggedId);
    const targetElement = e.target.closest('.rearrange-item');
    
    if (draggedElement && targetElement && draggedElement !== targetElement) {
        // Determine drop position
        const rect = targetElement.getBoundingClientRect();
        const next = (e.clientY - rect.top) / (rect.bottom - rect.top) > 0.5 ? targetElement.nextSibling : targetElement;
        
        const list = targetElement.parentElement;
        list.insertBefore(draggedElement, next);
        
        // Update positions
        updateRearrangePositions(list, list.id.replace('rearrangeItemsList_', ''));
        
        // Save answer
        saveRearrangeAnswer(list.id.replace('rearrangeItemsList_', ''));
    }
}

function makeSortable(list, qIdx) {
    let draggedItem = null;
    
    list.addEventListener('dragstart', function(e) {
        draggedItem = e.target;
        if (draggedItem.classList.contains('rearrange-item')) {
            draggedItem.classList.add('dragging');
            e.dataTransfer.setData('text/plain', draggedItem.id);
            e.dataTransfer.effectAllowed = 'move';
        }
    });
    
    list.addEventListener('dragend', function() {
        if (draggedItem) {
            draggedItem.classList.remove('dragging');
            draggedItem = null;
            
            // Update positions after drag completes
            updateRearrangePositions(list, qIdx);
            saveRearrangeAnswer(qIdx);
        }
    });
    
    list.addEventListener('dragover', function(e) {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        
        if (draggedItem && draggedItem.classList.contains('rearrange-item')) {
            const afterElement = getDragAfterElement(list, e.clientY);
            const currentSibling = draggedItem.nextSibling;
            
            if (currentSibling !== afterElement) {
                list.insertBefore(draggedItem, afterElement);
            }
        }
    });
}

function getDragAfterElement(container, y) {
    const draggableElements = [...container.querySelectorAll('.rearrange-item:not(.dragging)')];
    
    return draggableElements.reduce((closest, child) => {
        const box = child.getBoundingClientRect();
        const offset = y - box.top - box.height / 2;
        
        if (offset < 0 && offset > closest.offset) {
            return { offset: offset, element: child };
        } else {
            return closest;
        }
    }, { offset: Number.NEGATIVE_INFINITY }).element;
}

function updateRearrangePositions(list, qIdx) {
    const items = list.querySelectorAll('.rearrange-item');
    items.forEach((item, index) => {
        const positionSpan = item.querySelector('.item-position');
        if (positionSpan) {
            positionSpan.textContent = index + 1;
        }
    });
}

function saveRearrangeAnswer(qIdx) {
    const list = document.getElementById('rearrangeItemsList_' + qIdx);
    if (!list) return;
    
    const items = list.querySelectorAll('.rearrange-item');
    const orderedItemIds = [];
    
    items.forEach(item => {
        const itemId = item.getAttribute('data-item-id');
        if (itemId) {
            orderedItemIds.push(itemId.replace('item_', '')); // Extract numeric ID
        }
    });
    
    // Convert to integer IDs
    const orderedIds = orderedItemIds.map(id => parseInt(id));
    
    const answer = JSON.stringify(orderedIds);
    
    // Save using existing saveAnswer function
    if (typeof saveAnswer === 'function') {
        saveAnswer(qIdx, answer);
    }
}

function getRearrangeAnswers() {
    const rearrangeQuestions = document.querySelectorAll('.rearrange-question');
    const answers = {};
    
    rearrangeQuestions.forEach(function(questionContainer) {
        const card = questionContainer.closest('.question-card');
        if (!card) return;
        
        const qIdx = card.getAttribute('data-qindex');
        const list = document.getElementById('rearrangeItemsList_' + qIdx);
        
        if (list) {
            const items = list.querySelectorAll('.rearrange-item');
            const orderedItemIds = [];
            
            items.forEach(item => {
                const itemId = item.getAttribute('data-item-id');
                if (itemId) {
                    orderedItemIds.push(parseInt(itemId.replace('item_', '')));
                }
            });
            
            answers[qIdx] = orderedItemIds;
        }
    });
    
    return answers;
}

// Modify the submitExam function to handle rearrange answers
const originalSubmitExam = typeof submitExam === 'function' ? submitExam : function() {};
function submitExam() {
    // Handle original functionality
    if (typeof originalSubmitExam === 'function') {
        originalSubmitExam();
        return;
    }
    
    // Save all multi-select answers
    document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
        var card = box.closest('.question-card');
        if (!card) return;
        var qindex = card.getAttribute('data-qindex');
        if (qindex) updateHiddenForMulti(qindex);
    });
    
    // Handle Drag and Drop answers
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
    
    // Handle Rearrange answers
    const rearrangeAnswers = getRearrangeAnswers();
    Object.keys(rearrangeAnswers).forEach(qindex => {
        const orderedIds = rearrangeAnswers[qindex];
        const ansValue = JSON.stringify(orderedIds);
        
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
        const isRearrange = card.querySelector('.rearrange-question') !== null;
        
        if (isDragDrop) {
            if (card.querySelectorAll('.dropped-item').length > 0) {
                answeredQuestions++;
            }
        } else if (isRearrange) {
            // For rearrange, consider answered if there are items in the list
            const list = card.querySelector('.rearrange-items-list');
            if (list && list.querySelectorAll('.rearrange-item').length > 0) {
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
    
    // Final confirmation - show modal
    showConfirmSubmitModal();
}

// Modify the updateProgress function to handle rearrange questions
const originalUpdateProgress = typeof updateProgress === 'function' ? updateProgress : function() {};
function updateProgress() {
    originalUpdateProgress();
    
    var cards = document.querySelectorAll('.question-card');
    var answered = 0;
    
    cards.forEach(function(card){
        var box = card.querySelector('.answers');
        if(!box) return;
        
        const qindex = card.getAttribute('data-qindex');
        const isDragDrop = card.querySelector('.drag-drop-question') !== null;
        const isRearrange = card.querySelector('.rearrange-question') !== null;
        
        if (isDragDrop) {
            // Question is answered if at least one target has an item
            if (card.querySelectorAll('.dropped-item').length > 0) {
                answered++;
            }
        } else if (isRearrange) {
            // For rearrange questions, check if items exist in the list
            const list = card.querySelector('.rearrange-items-list');
            if (list && list.querySelectorAll('.rearrange-item').length > 0) {
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
    
    // Update progress bars and labels with the correct count
    var total = cards.length;
    var pct = total ? Math.round((answered / total) * 100) : 0;
    
    // Update progress bars
    var progressBar = document.getElementById('progressBar');
    var progressBarHeader = document.getElementById('progressBarHeader');
    var modalProgressBar = document.getElementById('modalProgressBar');
    if(progressBar) progressBar.style.width = pct + '%';
    if(progressBarHeader) progressBarHeader.style.width = pct + '%';
    if(modalProgressBar) modalProgressBar.style.width = pct + '%';
    
    // Update labels
    var progressLabel = document.getElementById('progressLabel');
    var examProgressPctHeader = document.getElementById('examProgressPctHeader');
    var progressPercent = document.querySelector('.progress-percent');
    if(progressLabel) progressLabel.textContent = pct + '%';
    if(examProgressPctHeader) examProgressPctHeader.textContent = pct + '%';
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

// Initialize rearrange questions when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeRearrangeQuestions);
} else {
    initializeRearrangeQuestions();
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
                    <% String viewEid = (result != null) ? String.valueOf(result.getExamId()) : request.getParameter("eid"); %>
                    <a href="std-page.jsp?pgprt=2&eid=<%= viewEid %>" class="action-btn" style="background: linear-gradient(135deg, #4a90e2, #357abd); margin-right: 10px;">
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
                        <h3 style="margin-bottom: 0; color: #ffffff;">
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
                    <i class="fas fa-play"></i> Take Exam
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

        <!-- Scientific Calculator -->
        <div id="calculatorModal" class="calculator-modal">
            <div class="calc-header" id="calcHeader">
                <div class="calc-title"><i class="fas fa-calculator"></i> Scientific Calculator</div>
                <button type="button" class="close-modal" onclick="toggleCalculator()" style="color: #666; font-size: 20px; border:none; background:none; cursor:pointer;">&times;</button>
            </div>
            <div class="calc-display">
                <div id="calcHistory" class="calc-history"></div>
                <div id="calcDisplay" class="calc-main-val">0</div>
            </div>
            <div class="calc-buttons">
                <button type="button" class="calc-btn sci" onclick="calcAction('sin')">sin</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('cos')">cos</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('tan')">tan</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('sqrt')">?</button>
                
                <button type="button" class="calc-btn sci" onclick="calcAction('log')">log</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('ln')">ln</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('pow')">x^y</button>
                <button type="button" class="calc-btn op" onclick="calcAction('clear')">AC</button>

                <button type="button" class="calc-btn" onclick="calcInput('7')">7</button>
                <button type="button" class="calc-btn" onclick="calcInput('8')">8</button>
                <button type="button" class="calc-btn" onclick="calcInput('9')">9</button>
                <button type="button" class="calc-btn op" onclick="calcInput('/')">/</button>

                <button type="button" class="calc-btn" onclick="calcInput('4')">4</button>
                <button type="button" class="calc-btn" onclick="calcInput('5')">5</button>
                <button type="button" class="calc-btn" onclick="calcInput('6')">6</button>
                <button type="button" class="calc-btn op" onclick="calcInput('*')">&times;</button>

                <button type="button" class="calc-btn" onclick="calcInput('1')">1</button>
                <button type="button" class="calc-btn" onclick="calcInput('2')">2</button>
                <button type="button" class="calc-btn" onclick="calcInput('3')">3</button>
                <button type="button" class="calc-btn op" onclick="calcInput('-')">-</button>

                <button type="button" class="calc-btn" onclick="calcInput('0')">0</button>
                <button type="button" class="calc-btn" onclick="calcInput('.')">.</button>
                <button type="button" class="calc-btn op" onclick="calcInput('+')">+</button>
                <button type="button" class="calc-btn op" onclick="calcAction('backspace')"><i class="fas fa-backspace"></i></button>
                
                <button type="button" class="calc-btn sci" onclick="calcInput('Math.PI')">?</button>
                <button type="button" class="calc-btn sci" onclick="calcInput('Math.E')">e</button>
                <button type="button" class="calc-btn eq" onclick="calcAction('equal')">=</button>
            </div>
        </div>

        <!-- Rough Paper -->
        <div id="roughPaperModal" class="rough-paper-modal">
            <div class="rough-header" id="roughHeader">
                <div><i class="fas fa-sticky-note"></i> Rough Paper</div>
                <button type="button" onclick="toggleRoughPaper()" style="border:none; background:none; cursor:pointer; font-size: 18px;">&times;</button>
            </div>
            <div class="rough-content">
                <textarea id="roughTextarea" class="rough-textarea" placeholder="Use this space for your rough work... (auto-saves)"></textarea>
            </div>
        </div>
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
        
        // Initialize question navigation
        const questionNavModal = document.getElementById('questionNavModal');
        if (questionNavModal) {
            // Close modal when clicking the close button
            const closeBtn = questionNavModal.querySelector('.close-modal-btn');
            if (closeBtn) {
                closeBtn.addEventListener('click', closeQuestionNavModal);
            }
        }

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
    
    // Question Navigation Functions
    function handleUnansweredClick() {
        const unansweredCount = parseInt(document.getElementById('submitUnanswered').textContent);
        
        if (unansweredCount === 1) {
            // If only one unanswered question, go directly to it
            goToFirstUnansweredQuestion();
        } else if (unansweredCount > 1) {
            // If multiple unanswered questions, show navigation modal
            showQuestionNavigationModal();
        }
    }
    
    function goToFirstUnansweredQuestion() {
        const questionCards = document.querySelectorAll('.question-card');
        
        for (let i = 0; i < questionCards.length; i++) {
            const card = questionCards[i];
            const answersContainer = card.querySelector('.answers');
            const qindex = card.getAttribute('data-qindex');
            
            if (answersContainer && !isQuestionAnswered(answersContainer)) {
                scrollToQuestion(qindex);
                return;
            }
        }
    }
    
    function showQuestionNavigationModal() {
        const modal = document.getElementById('questionNavModal');
        const grid = document.getElementById('questionGrid');
        
        if (!modal || !grid) {
            console.error('Question navigation modal or grid not found');
            return;
        }
        
        // Clear existing content
        grid.innerHTML = '';
        
        // Get all question cards
        const questionCards = document.querySelectorAll('.question-card');
        
        // Get current question index
        const currentQNum = parseInt(document.getElementById('currentQNum')?.textContent || '1') - 1;
        
        // Create question icons
        questionCards.forEach((card, index) => {
            const qindex = card.getAttribute('data-qindex');
            const answersContainer = card.querySelector('.answers');
            const isAnswered = answersContainer && isQuestionAnswered(answersContainer);
            
            const icon = document.createElement('div');
            icon.className = `question-icon ${isAnswered ? 'answered' : 'unanswered'}`;
            if (parseInt(qindex) === currentQNum) {
                icon.classList.add('current');
            }
            icon.textContent = parseInt(qindex) + 1;
            icon.setAttribute('data-qindex', qindex);
            icon.title = `Question ${parseInt(qindex) + 1} (${isAnswered ? 'Answered' : 'Unanswered'})`;
            
            // Use IIFE to capture the qindex value properly
            icon.addEventListener('click', (function(questionIndex) {
                return function() {
                    closeQuestionNavModal();
                    scrollToQuestion(questionIndex);
                };
            })(qindex));
            
            grid.appendChild(icon);
        });
        
        // Show modal
        modal.style.display = 'flex';
    }
    
    function closeQuestionNavModal() {
        const modal = document.getElementById('questionNavModal');
        if (modal) {
            modal.style.display = 'none';
        }
    }
    
    function goToFirstQuestion() {
        const firstQuestionIndex = 0;
        scrollToQuestion(firstQuestionIndex.toString());
    }
    
    function goToLastQuestion() {
        const questionCards = document.querySelectorAll('.question-card');
        const lastQuestionIndex = questionCards.length - 1;
        scrollToQuestion(lastQuestionIndex.toString());
    }
    
    function scrollToQuestion(qindex) {
        // First, make sure the question is visible
        if (typeof showQuestion === 'function') {
            // Use the existing showQuestion function to display the selected question
            showQuestion(parseInt(qindex));
        } else {
            // Fallback: manually show the question
            const questionCards = document.querySelectorAll('.question-card');
            questionCards.forEach((card, idx) => {
                if (idx == qindex) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
            
            // Update the question counter
            const currentQNumEl = document.getElementById('currentQNum');
            if (currentQNumEl) currentQNumEl.textContent = parseInt(qindex) + 1;
            
            // Update navigation buttons
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');
            
            if (prevBtn) prevBtn.disabled = (qindex === 0);
            
            const totalQuestions = document.querySelectorAll('.question-card').length;
            if (qindex === totalQuestions - 1) {
                if (nextBtn) {
                    nextBtn.innerHTML = 'Finish <i class="fas fa-flag-checkered"></i>';
                    nextBtn.style.background = '#059669';
                }
            } else {
                if (nextBtn) {
                    nextBtn.innerHTML = 'Next <i class="fas fa-arrow-right"></i>';
                    nextBtn.style.background = '#92AB2F';
                }
            }
        }
        
        // Small delay to ensure the question is visible before scrolling
        setTimeout(() => {
            const questionCard = document.querySelector(`.question-card[data-qindex="${qindex}"]`);
            if (questionCard) {
                questionCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
                
                // Add temporary highlight effect
                questionCard.style.boxShadow = '0 0 0 3px #3b82f6';
                questionCard.style.transition = 'box-shadow 0.3s';
                
                setTimeout(() => {
                    questionCard.style.boxShadow = '';
                }, 2000);
            }
        }, 100);
    }
    
    function isQuestionAnswered(answersContainer) {
        // Check for different question types
        const singleSelect = answersContainer.querySelector('input.single:checked');
        const multiSelect = answersContainer.querySelectorAll('input.multi:checked').length > 0;
        const textAnswer = answersContainer.querySelector('textarea');
        const hasText = textAnswer && textAnswer.value.trim() !== '';
        
        // For drag and drop questions
        const droppedItems = answersContainer.querySelectorAll('.dropped-item').length > 0;
        
        return singleSelect || multiSelect || hasText || droppedItems;
    }
    
    // Test function to verify horizontal orientation layout
    function testHorizontalOrientation() {
        console.log('Testing horizontal orientation layout:');
        
        // Find all drag-drop questions
        const dragDropContainers = document.querySelectorAll('.drag-drop-container');
        
        dragDropContainers.forEach((container, index) => {
            if (container.classList.contains('horizontal-layout')) {
                console.log(`Question ${index + 1} has horizontal layout`);
                
                const dropTargetsList = container.querySelector('.drop-targets-list');
                if (dropTargetsList) {
                    const style = getComputedStyle(dropTargetsList);
                    console.log(`  justify-content: ${style.justifyContent}`);
                    console.log(`  flex-direction: ${style.flexDirection}`);
                    
                    // Check if drop targets are aligned to the right
                    const isRightAligned = style.justifyContent === 'flex-end';
                    console.log(`  Right aligned: ${isRightAligned}`);
                    
                    // Check drop target sizes
                    const dropTargets = dropTargetsList.querySelectorAll('.drop-target');
                    dropTargets.forEach((target, targetIndex) => {
                        const targetStyle = getComputedStyle(target);
                        console.log(`  Target ${targetIndex + 1}: width=${targetStyle.width}, height=${targetStyle.height}`);
                    });
                }
            }
        });
    }
    
    // Close question navigation modal when clicking outside
    window.addEventListener('click', function(event) {
        const questionNavModal = document.getElementById('questionNavModal');
        if (event.target === questionNavModal) {
            closeQuestionNavModal();
        }
    });
</script>
