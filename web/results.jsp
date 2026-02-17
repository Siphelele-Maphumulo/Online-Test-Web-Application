<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<%@ page isELIgnored="true" %>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>
 
<%! 
// Function to escape HTML characters for safe display
public String escapeHtml(String input) {
    if (input == null) return "";
    return input.replace("&", "&amp;")
               .replace("<", "&lt;")
               .replace(">", "&gt;")
               .replace("\"", "&quot;")
               .replace("'", "&#x27;");
}
%>

<%
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

myPackage.classes.User currentUser = null;
if (session.getAttribute("userId") != null) {
    currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());
}

if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Get user ID from session
Integer userId = null;
if (session.getAttribute("userId") != null) {
    userId = Integer.parseInt(session.getAttribute("userId").toString());
}

// Get student's exam results
ArrayList<Exams> examList = new ArrayList<>();
int totalResults = 0;
int passedExams = 0;
double avgPercentage = 0.0;

// Variable to store latest exam ID
int latestExamId = 0;

if (userId != null) {
    examList = pDAO.getResultsFromExams(userId);
    totalResults = examList.size();
    
    // Find the latest exam ID
    if (!examList.isEmpty()) {
        // Sort by exam ID to find the latest
        Exams latestExam = examList.get(0);
        for (Exams exam : examList) {
            if (exam.getExamId() > latestExam.getExamId()) {
                latestExam = exam;
            }
        }
        latestExamId = latestExam.getExamId();
    }
    
    // Calculate passed exams and average percentage
    double totalPercentage = 0;
    for (Exams exam : examList) {
        if (exam.gettMarks() > 0) {
            double percentage = (double) exam.getObtMarks() / exam.gettMarks() * 100;
            if (percentage >= 45.0) {
                passedExams++;
            }
            totalPercentage += percentage;
        }
    }
    
    if (totalResults > 0) {
        avgPercentage = totalPercentage / totalResults;
    }
}

// Check if we should show latest results (from button click)
boolean showLatestResults = "true".equals(request.getParameter("showLatest"));
%>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!--Style-->
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
    
    /* Results Wrapper */
    .results-wrapper {
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

    /* Main Content Area - Add margin to account for fixed sidebar */
    .content-area,
    .main-content {
        flex: 1;
        padding: var(--spacing-md);
        padding-top: 20px;
        overflow-y: auto;
        background: transparent;
        margin-left: 0px;
        min-height: 100vh;
        min-width: 0;
    }
    .results-panel {
        margin-left: 0;
        width: 100%;
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
    
    .nav-item h2 {
        margin: 0;
        font-size: 14px;
        font-weight: 500;
        letter-spacing: 0.3px;
    }
    
    /* Left Menu (Legacy Support) */
    .left-menu a {
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
    
    .left-menu a::before {
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
    
    .left-menu a:hover {
        background: rgba(255, 255, 255, 0.1);
        color: var(--white);
        padding-left: var(--spacing-xl);
    }
    
    .left-menu a:hover::before {
        transform: translateX(0);
    }
    
    .left-menu a.active {
        background: linear-gradient(90deg, rgba(59, 130, 246, 0.2), rgba(59, 130, 246, 0.1));
        color: var(--white);
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
    }
    
    .left-menu a.active::before {
        transform: translateX(0);
    }
    
    .left-menu a i {
        width: 20px;
        text-align: center;
        font-size: 16px;
        opacity: 0.9;
    }
    
    /* Main Content Area */
    .content-area,
    .main-content {
        flex: 1;
        padding: var(--spacing-xl);
        overflow-y: auto;
        background: transparent;
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
    
    .header-actions {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
    }
    
    /* Stats Badge */
    .stats-badge {
        background: linear-gradient(135deg, var(--accent-blue), var(--accent-blue-light));
        color: var(--white);
        padding: 8px 20px;
        border-radius: var(--radius-full);
        font-size: 14px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.2);
        letter-spacing: 0.3px;
    }
    
    /* Latest Badge */
    .latest-badge {
        background: linear-gradient(135deg, #FFD700, #FFA500);
        color: #333;
        padding: 8px 16px;
        border-radius: var(--radius-full);
        font-size: 13px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        box-shadow: 0 4px 12px rgba(255, 215, 0, 0.2);
    }
    
    /* Exam ID Badge */
    .exam-id-badge {
        background: linear-gradient(135deg, var(--dark-gray), #94a3b8);
        color: var(--white);
        padding: 8px 16px;
        border-radius: var(--radius-full);
        font-size: 13px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        box-shadow: 0 4px 12px rgba(100, 116, 139, 0.15);
    }
    
    /* Alert Messages */
    .alert {
        background: linear-gradient(90deg, var(--success-light), #ecfdf5);
        border-left: 4px solid var(--success);
        color: var(--text-dark);
        padding: var(--spacing-lg);
        border-radius: var(--radius-md);
        margin-bottom: var(--spacing-xl);
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        font-size: 14px;
        box-shadow: var(--shadow-sm);
        animation: slideIn 0.3s ease-out;
    }
    
    .alert-success {
        background: linear-gradient(90deg, var(--success-light), #ecfdf5);
        border-left-color: var(--success);
    }
    
    .alert-success i {
        color: var(--success);
    }
    
    .alert-error {
        background: linear-gradient(90deg, var(--error-light), #fef2f2);
        border-left-color: var(--error);
    }
    
    .alert-error i {
        color: var(--error);
    }
    
    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    /* Results Card */
    .results-card {
        background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
        margin-bottom: 0;
        overflow: hidden;
        transition: transform var(--transition-normal), box-shadow var(--transition-normal);
    }
    
    .results-card:hover {
        transform: translateY(-4px);
        box-shadow: var(--shadow-xl);
    }
    
    .card-header {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: var(--spacing-lg) var(--spacing-xl);
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 16px;
        font-weight: 600;
        position: relative;
        overflow: hidden;
    }
    
    .card-header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 4px;
        background: linear-gradient(90deg, var(--accent-blue), var(--success));
    }
    
    .card-header i {
        opacity: 0.9;
        font-size: 18px;
    }
    
    /* Search Container */
    .search-container {
        position: relative;
        margin-bottom: 5px;
        max-width: 400px;
    }
    
    .search-input {
        width: 100%;
        padding: 14px 40px 14px 16px;
        border: 2px solid var(--border-color);
        border-radius: var(--radius-md);
        font-size: 15px;
        transition: all var(--transition-fast);
        background: var(--white);
        color: var(--text-dark);
        font-family: inherit;
    }
    
    .search-input:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        transform: translateY(-1px);
    }
    
    .search-icon {
        position: absolute;
        right: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--dark-gray);
        font-size: 16px;
        transition: color var(--transition-fast);
    }
    
    .search-input:focus + .search-icon {
        color: var(--accent-blue);
    }
    
    /* Results Summary */
    .results-summary {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 5px;
        margin-bottom: 0;
    }
    
    .summary-item {
        background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
        border: 2px solid var(--border-color);
        border-radius: var(--radius-lg);
        padding: var(--spacing-lg);
        text-align: center;
        box-shadow: var(--shadow-md);
        transition: all var(--transition-normal);
        position: relative;
        overflow: hidden;
    }
    
    .summary-item::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 4px;
        background: linear-gradient(90deg, var(--accent-blue), var(--success));
    }
    
    .summary-item:hover {
        transform: translateY(-4px);
        box-shadow: var(--shadow-xl);
        border-color: var(--accent-blue);
    }
    
    .summary-value {
        font-size: 24px;
        font-weight: 700;
        color: var(--text-dark);
        margin-bottom: var(--spacing-sm);
        line-height: 1.2;
    }
    
    .summary-label {
        color: var(--dark-gray);
        font-weight: 600;
        font-size: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-xs);
    }
    
    .summary-label i {
        color: var(--accent-blue);
        font-size: 14px;
    }
    
    /* Results Table Container */
    .results-table-container {
        overflow-x: auto;
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
        background: var(--white);
        margin-top: 5px;
    }
    
    .results-table {
        width: 100%;
        border-collapse: collapse;
        background: var(--white);
    }
    
    .results-table thead th {
        background: linear-gradient(180deg, var(--light-gray) 0%, #f1f5f9 100%);
        color: var(--text-dark);
        padding: var(--spacing-lg);
        font-weight: 600;
        text-align: left;
        border-bottom: 2px solid var(--border-color);
        font-size: 14px;
        cursor: pointer;
        transition: all var(--transition-fast);
        position: relative;
        white-space: nowrap;
    }
    
    .results-table thead th:hover {
        background: #f1f5f9;
        color: var(--accent-blue);
    }
    
    .results-table tbody td {
        padding: var(--spacing-lg);
        border-bottom: 1px solid var(--light-gray);
        vertical-align: middle;
        color: var(--text-dark);
        font-size: 14px;
        text-align: left;
        transition: background-color var(--transition-fast);
    }
    
    .results-table tbody tr {
        transition: all var(--transition-fast);
    }
    
    .results-table tbody tr:hover {
        background: var(--light-gray);
    }
    
    .results-table tbody tr:hover td {
        color: var(--text-dark);
    }
    
    /* Latest Exam Row */
    .result-row.latest-exam {
        background: linear-gradient(90deg, rgba(255, 215, 0, 0.05) 0%, rgba(255, 215, 0, 0.02) 100%);
        border-left: 4px solid #FFD700;
    }
    
    .result-row.latest-exam:hover {
        background: linear-gradient(90deg, rgba(255, 215, 0, 0.1) 0%, rgba(255, 215, 0, 0.05) 100%);
    }
    
    .latest-indicator {
        color: #FFA500;
        margin-left: var(--spacing-xs);
        font-size: 12px;
        font-weight: 600;
    }
    
    /* Status Badges */
    .status-badge,
    .exam-status-badge {
        padding: 8px 16px;
        border-radius: var(--radius-full);
        font-weight: 600;
        font-size: 13px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    
    .status-pass,
    .exam-status-badge.status-pass {
        background: linear-gradient(135deg, var(--success), #34d399);
        color: var(--white);
    }
    
    .status-fail,
    .exam-status-badge.status-fail {
        background: linear-gradient(135deg, var(--error), #f87171);
        color: var(--white);
    }
    
    .status-terminated {
        background: linear-gradient(135deg, var(--warning), #fbbf24);
        color: var(--white);
    }
    
    /* Percentage Badge */
    .percentage-badge {
        background: linear-gradient(135deg, var(--info), #0ea5e9);
        color: var(--white);
        padding: 8px 16px;
        border-radius: var(--radius-full);
        font-weight: 700;
        font-size: 13px;
        display: inline-block;
        min-width: 60px;
        text-align: center;
        box-shadow: 0 2px 8px rgba(14, 165, 233, 0.2);
    }
    
    /* Button Styles */
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
        padding: 12px 24px;
        border-radius: var(--radius-md);
        font-size: 14px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        border: none;
        transition: all var(--transition-normal);
        font-family: inherit;
        position: relative;
        overflow: hidden;
    }
    
    .btn::after {
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
    
    .btn:hover::after {
        transform: translateX(100%);
    }
    
    .btn-primary {
        background: linear-gradient(135deg, var(--accent-blue), var(--accent-blue-light));
        color: var(--white);
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25);
    }
    
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(59, 130, 246, 0.35);
    }
    
    .btn-secondary {
        background: linear-gradient(135deg, var(--dark-gray), #94a3b8);
        color: var(--white);
        box-shadow: 0 4px 12px rgba(100, 116, 139, 0.15);
    }
    
    .btn-secondary:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(100, 116, 139, 0.25);
    }
    
    .btn-success {
        background: linear-gradient(135deg, var(--success), #34d399);
        color: var(--white);
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
    }
    
    .btn-error {
        background: linear-gradient(135deg, var(--error), #f87171);
        color: var(--white);
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.25);
    }
    
    .btn-outline {
        background: transparent;
        color: var(--text-dark);
        border: 2px solid var(--border-color);
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
    }
    
    .btn-outline:hover {
        background: var(--light-gray);
        border-color: var(--dark-gray);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
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
    
    /* No Results Message */
    .no-results,
    .error-message {
        text-align: center;
        padding: var(--spacing-2xl) var(--spacing-xl);
        color: var(--dark-gray);
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
    }
    
    .no-results i,
    .error-message i {
        font-size: 64px;
        color: var(--dark-gray);
        margin-bottom: var(--spacing-lg);
        opacity: 0.5;
    }
    
    .no-results h2,
    .error-message h2 {
        font-size: 24px;
        font-weight: 600;
        margin-bottom: var(--spacing-md);
        color: var(--text-dark);
    }
    
    .no-results p,
    .error-message p {
        color: var(--dark-gray);
        margin-bottom: var(--spacing-xl);
        max-width: 400px;
        margin-left: auto;
        margin-right: auto;
    }
    
    .error-message {
        color: var(--error);
    }
    
    .error-message i {
        color: var(--error);
        opacity: 0.8;
    }
    
    /* Sort Indicator */
    .sort-indicator {
        margin-left: var(--spacing-xs);
        font-size: 10px;
        color: var(--dark-gray);
        transition: transform var(--transition-fast);
    }
    
    .sort-indicator.rotate {
        transform: rotate(180deg);
        color: var(--accent-blue);
    }
    
    /* Details Header */
    .details-header {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        margin-bottom: var(--spacing-xl);
        padding: var(--spacing-lg);
        background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
    }
    
    /* Loading State */
    .loading {
        opacity: 0.7;
        pointer-events: none;
    }
    
    .loading::after {
        content: '';
        display: inline-block;
        width: 16px;
        height: 16px;
        border: 2px solid rgba(255, 255, 255, 0.3);
        border-top: 2px solid var(--white);
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-left: var(--spacing-sm);
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    /* Code Snippet Styling for Results */
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
        white-space: pre-wrap;
        word-wrap: break-word;
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

    /* Question Analysis Styling */
    .question-analysis {
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-md);
        margin-bottom: var(--spacing-md);
        overflow: hidden;
    }

    .question-text {
        margin-bottom: var(--spacing-md);
        color: var(--text-dark);
        font-weight: 500;
        line-height: 1.5;
    }

    .answer-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: var(--spacing-md);
        padding: var(--spacing-md);
    }

    @media (max-width: 768px) {
        .answer-grid {
            grid-template-columns: 1fr;
        }
    }

    /* Question Analysis Header */
    .question-analysis-header {
        background: linear-gradient(135deg, var(--success-light), var(--error-light));
        padding: var(--spacing-md);
        display: flex;
        align-items: flex-start;
        gap: var(--spacing-md);
    }

    .question-number {
        width: 32px;
        height: 32px;
        background: linear-gradient(135deg, var(--success), var(--error));
        color: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        flex-shrink: 0;
        margin-top: 2px;
    }

    .question-content {
        flex: 1;
        min-width: 0;
    }
    
    /* Question Image Styles */
    .question-image-container {
        margin: var(--spacing-md) 0;
        text-align: center;
        width: 100%;
        clear: both;
    }
    
    .question-image {
        max-width: 100%;
        max-height: 500px;
        height: auto;
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        background: var(--white);
        padding: var(--spacing-sm);
        object-fit: contain;
        display: inline-block;
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

    .question-status {
        display: flex;
        align-items: center;
        gap: 4px;
        font-weight: 600;
        flex-shrink: 0;
    }

    /* Ensure question text displays properly */
    .question-text {
        margin-bottom: var(--spacing-sm);
        padding-right: var(--spacing-md);
    }

    .question-analysis .code-snippet {
        margin: var(--spacing-sm) 0;
    }
    
    /* Responsive Design */
    @media (max-width: 768px) {
        .results-wrapper {
            flex-direction: column;
        }
        
        .sidebar {
            width: 100%;
            height: auto;
            position: static;
            box-shadow: none;
            border-right: none;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .sidebar-header {
            padding: var(--spacing-xl) var(--spacing-md);
        }
        
        .sidebar-nav {
            display: flex;
            overflow-x: auto;
            padding: var(--spacing-md);
            gap: var(--spacing-sm);
        }
        
        .nav-item,
        .left-menu a {
            flex-direction: column;
            padding: var(--spacing-sm) var(--spacing-md);
            min-width: 80px;
            text-align: center;
            margin: 0;
            border-radius: var(--radius-md);
        }
        
        .nav-item::before,
        .left-menu a::before {
            width: 100%;
            height: 3px;
            top: auto;
            bottom: 0;
            transform: translateY(100%);
        }
        
        .nav-item:hover::before,
        .nav-item.active::before,
        .left-menu a:hover::before,
        .left-menu a.active::before {
            transform: translateY(0);
        }
        
        .nav-item:hover,
        .left-menu a:hover {
            padding-left: var(--spacing-md);
        }
        
        .content-area,
        .main-content {
            padding: var(--spacing-lg);
        }
        
        .page-header {
            flex-direction: column;
            gap: var(--spacing-lg);
            text-align: center;
            padding: var(--spacing-lg);
        }
        
        .header-actions {
            width: 100%;
            justify-content: center;
        }
        
        .results-summary {
            grid-template-columns: 1fr;
        }
        
        .summary-item {
            padding: var(--spacing-lg);
        }
        
        .summary-value {
            font-size: 20px;
        }
        
        .results-table-container {
            overflow-x: auto;
        }
        
        .results-table thead th,
        .results-table tbody td {
            padding: var(--spacing-md);
            font-size: 13px;
        }
        
        .status-badge,
        .exam-status-badge,
        .percentage-badge {
            font-size: 12px;
            padding: 6px 12px;
        }
        
        .action-btn,
        .btn {
            padding: 10px 16px;
            font-size: 13px;
        }

        .question-analysis-header {
            flex-direction: column;
            align-items: flex-start;
        }

        .question-status {
            align-self: flex-end;
        }
    }
    
    @media (max-width: 480px) {
        .content-area,
        .main-content {
            padding: var(--spacing-md);
        }
        
        .page-header {
            padding: var(--spacing-md);
        }
        
        .card-header {
            padding: var(--spacing-md);
            flex-direction: column;
            gap: var(--spacing-sm);
            text-align: center;
        }
        
        .search-container {
            max-width: 100%;
        }
        
        .details-header {
            flex-direction: column;
            text-align: center;
            gap: var(--spacing-md);
        }

        .answer-grid {
            padding: var(--spacing-sm);
            gap: var(--spacing-sm);
        }
    }
    
    @media (min-width: 1440px) {
        .content-area,
        .main-content {
            max-width: calc(100% - 280px);
        }
    }
    
    /* Utility Classes */
    .text-center { text-align: center; }
    .mt-1 { margin-top: var(--spacing-sm); }
    .mt-2 { margin-top: var(--spacing-md); }
    .mt-3 { margin-top: var(--spacing-lg); }
    .mb-1 { margin-bottom: var(--spacing-sm); }
    .mb-2 { margin-bottom: var(--spacing-md); }
    .mb-3 { margin-bottom: var(--spacing-lg); }
    .w-full { width: 100%; }
    .grid-col-span-2 { grid-column: span 2; }
    
    /* Color Utility Classes */
    .success-light {
        color: var(--success-light);
    }
    
    .error-light {
        color: var(--error-light);
    }
    
    /* Focus Styles for Accessibility */
    *:focus {
        outline: 2px solid var(--accent-blue);
        outline-offset: 2px;
    }
    
    *:focus:not(.focus-visible) {
        outline: none;
    }
    
    /* Floating Delete Button Styles */
    .floating-delete-selected {
        position: fixed;
        bottom: 30px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 1000;
        background: linear-gradient(135deg, var(--error) 0%, #b91c1c 100%);
        color: white;
        border: none;
        border-radius: 50px;
        padding: 15px 30px;
        font-size: 16px;
        font-weight: 600;
        box-shadow: 0 10px 25px rgba(220, 38, 38, 0.4);
        cursor: pointer;
        display: none;
        transition: all 0.3s ease;
        text-decoration: none;
    }
    
    .floating-delete-selected:hover {
        transform: translateX(-50%) scale(1.05);
        box-shadow: 0 12px 30px rgba(220, 38, 38, 0.5);
    }
    
    .floating-delete-selected.show {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .floating-delete-selected i {
        font-size: 18px;
    }
    
    /* Modal Styles */
    .modal-backdrop {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 2000;
    }
    
    .modal-box {
        background: white;
        border-radius: 12px;
        padding: 0;
        max-width: 400px;
        width: 90%;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    }
    
    .modal-header {
        padding: 20px 24px 16px;
        border-bottom: 1px solid #e5e7eb;
        font-size: 18px;
        font-weight: 600;
        color: var(--primary-blue);
    }
    
    .modal-body {
        padding: 20px 24px;
        color: var(--dark-gray);
        line-height: 1.5;
    }
    
    .modal-footer {
        padding: 16px 24px 20px;
        border-top: 1px solid #e5e7eb;
        display: flex;
        gap: 12px;
        justify-content: flex-end;
    }
    
    .btn-cancel {
        padding: 8px 16px;
        border: 1px solid #d1d5db;
        background: white;
        color: var(--dark-gray);
        border-radius: 6px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s ease;
    }
    
    .btn-cancel:hover {
        background: #f9fafb;
        border-color: #9ca3af;
    }
    
    .btn-confirm-del {
        padding: 8px 16px;
        border: none;
        background: var(--error);
        color: white;
        border-radius: 6px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s ease;
    }
    
    .btn-confirm-del:hover {
        background: #b91c1c;
    }
    
    /* Multi-select functionality */
    .multi-select-checkbox {
        position: absolute;
        top: 10px;
        left: 10px;
        z-index: 10;
        opacity: 0;
        pointer-events: none;
    }
    
    .question-card.multi-selected {
        background-color: rgba(250, 150, 150, 0.479);
        outline-offset: -3px;
        position: relative;
    }
    
    .question-card.multi-selected::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(226, 79, 74, 0.1);
        z-index: 1;
        pointer-events: none;
    }
    
    .multi-select-toggle {
        position: absolute;
        top: 10px;
        left: 10px;
        z-index: 20;
        width: 20px;
        height: 20px;
        border: 2px solid var(--dark-gray);
        border-radius: 4px;
        background: var(--white);
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
    }
    
    .multi-select-toggle.checked {
        background: var(--white);
        border-color: red;
    }
    
    .multi-select-toggle.checked::after {
        content: '✓';
        border-color: red;
        font-size: 12px;
        font-weight: bold;
    }
    
    /* Floating delete button */
    .floating-delete-selected {
        position: fixed;
        bottom: 30px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 1000;
        background: linear-gradient(135deg, var(--error) 0%, #b91c1c 100%);
        color: white;
        border: none;
        border-radius: 50px;
        padding: 15px 30px;
        font-size: 16px;
        font-weight: 600;
        box-shadow: 0 10px 25px rgba(220, 38, 38, 0.4);
        cursor: pointer;
        display: none;
        transition: all 0.3s ease;
        text-decoration: none;
    }
    
    .floating-delete-selected:hover {
        transform: translateX(-50%) scale(1.05);
        box-shadow: 0 12px 30px rgba(220, 38, 38, 0.5);
    }
    
    .floating-delete-selected.show {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .floating-delete-selected i {
        font-size: 18px;
    }
    
    /* Checkbox container to avoid interfering with card clicks */
    .checkbox-container {
        position: relative;
        display: inline-block;
    }
    
    /* Responsive adjustments */
    @media (max-width: 768px) {
        .floating-scroll {
            bottom: 80px;
            right: 15px;
        }
        
        .scroll-btn {
            width: 35px;
            height: 35px;
            font-size: 14px;
        }
        
        .floating-delete-selected {
            bottom: 20px;
            padding: 12px 24px;
            font-size: 14px;
        }
    }
</style>

<div class="results-wrapper">
  <!-- SIDEBAR -->
  <aside class="sidebar">
    <div class="sidebar-header">
        <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
    </div>
    <nav class="sidebar-nav">
      <div class="left-menu">
        <a class="nav-item" href="std-page.jsp?pgprt=0">
          <i class="fas fa-user"></i>
          <span>Profile</span>
        </a>
        <a class="nav-item" href="std-page.jsp?pgprt=1">
          <i class="fas fa-file-alt"></i>
          <span>Lunch Exam</span>
        </a>
        <a class="nav-item active" href="std-page.jsp?pgprt=2">
          <i class="fas fa-chart-line"></i>
          <span>Results</span>
        </a>
        <a class="nav-item" href="std-page.jsp?pgprt=3">
          <i class="fas fa-chart-line"></i>
          <span>Daily Register</span>
        </a>
      </div>
    </nav>
  </aside>

  <!-- CONTENT AREA -->
  <main class="content-area">
    <div class="results-panel">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title">
          <i class="fas fa-chart-line"></i>
          My Exam Results
        </div>
        <div class="header-actions">
          <% if (latestExamId > 0) { %>
          <a href="std-page.jsp?pgprt=2&showLatest=true" class="action-btn" style="background: linear-gradient(135deg, #4a90e2, #357abd); margin-right: 10px;">
            <i class="fas fa-clock"></i>
            View Latest Results
          </a>
          <% } %>
          <div class="stats-badge">
            <i class="fas fa-graduation-cap"></i>
            <%= totalResults %> Results
          </div>
        </div>
      </div>

      <%
        // Check if we should show details view (either specific eid or latest results)
        boolean showDetails = false;
        int displayExamId = 0;
        
        if (request.getParameter("eid") != null) {
            showDetails = true;
            displayExamId = Integer.parseInt(request.getParameter("eid"));
        } else if (showLatestResults && latestExamId > 0) {
            showDetails = true;
            displayExamId = latestExamId;
        }
        
        if (showDetails) {
      %>
        <!-- Details View Header -->
        <div class="details-header">
          <a href="std-page.jsp?pgprt=2" class="action-btn" style="background: var(--dark-gray); margin-bottom: var(--spacing-md);">
            <i class="fas fa-arrow-left"></i>
            Back to All Results
          </a>
          
          <% if (displayExamId == latestExamId) { %>
          <div class="latest-badge">
            <i class="fas fa-star"></i>
            Latest Exam Results
          </div>
          <% } %>
        </div>
        
        <div class="results-card">
          <div class="card-header">
            <span><i class="fas fa-file-alt"></i> Exam Result Details</span>
            <div class="exam-id-badge">
              <i class="fas fa-hashtag"></i>
              Exam ID: <%= displayExamId %>
            </div>
          </div>
          
          <div style="padding: var(--spacing-xl);">
            <%
              // Get exam details
              Exams examDetails = pDAO.getResultByExamId(displayExamId);
              ArrayList<Answers> answersList = pDAO.getAllAnswersByExamId(displayExamId);
              
              if (examDetails == null || answersList == null) {
            %>
              <div class="error-message">
                <i class="fas fa-exclamation-triangle"></i>
                <h3>Results Not Found</h3>
                <p>The requested exam results could not be found.</p>
                <a href="std-page.jsp?pgprt=2" class="action-btn">
                  <i class="fas fa-arrow-left"></i>
                  Return to Results
                </a>
              </div>
            <%
              } else {
                int correctAnswers = 0;
                for (Answers a : answersList) {
                  if (a.getStatus().equals("correct") || a.getStatus().startsWith("partial:")) {
                    correctAnswers++;
                  }
                }
                
                // Get actual values from database
                int obtainedMarks = examDetails.getObtMarks();
                int totalMarks = examDetails.gettMarks();
                
                // Calculate percentage (Weighted Marks Percentage)
                double percentage = 0;
                if (totalMarks > 0) {
                    percentage = (double) obtainedMarks / totalMarks * 100;
                }

                // Calculate accuracy (Correct Questions / Total Questions)
                double accuracyRate = 0;
                if (!answersList.isEmpty()) {
                    accuracyRate = (double) correctAnswers / answersList.size() * 100;
                }
                
                // Get result status from database (populated in getResultByExamId)
                String statusText = examDetails.getStatus();
                if (statusText == null || statusText.isEmpty() || statusText.equalsIgnoreCase("completed")) {
                    // Fallback to calculation if status is missing or just "completed"
                    statusText = (percentage >= 45.0) ? "Pass" : "Fail";
                }
                
                String statusClass = statusText.equalsIgnoreCase("Pass") ? "status-pass" : "status-fail";
                String percentageColor = statusText.equalsIgnoreCase("Pass") ? "var(--success)" : "var(--error)";
                
                // Debug logging
                // === RESULTS DEBUG ===
                // Exam ID: " + displayExamId
                // Obtained Marks: " + obtainedMarks
                // Total Marks: " + totalMarks
                // Percentage: " + percentage
                // Status: " + statusText
                // ===================
            %>
            
            <!-- Exam Summary -->
            <div class="exam-summary" style="background: var(--light-gray); padding: var(--spacing-lg); border-radius: var(--radius-md); margin-bottom: var(--spacing-xl);">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--spacing-md);">
                <div>
                  <h3 style="color: var(--text-dark); margin-bottom: var(--spacing-xs);">
                    <i class="fas fa-book"></i>
                    <%= examDetails.getcName() %>
                  </h3>
                  <div style="color: var(--dark-gray); font-size: 14px;">
                    <i class="fas fa-calendar"></i> <%= examDetails.getDate() %> 
                    | <i class="fas fa-clock"></i> <%= examDetails.getStartTime() %> - <%= examDetails.getEndTime() %>
                  </div>
                </div>
                <div class="exam-status-badge <%= statusClass %>">
                  <i class="fas fa-check-circle"></i>
                  <%= statusText %>
                </div>
              </div>
              
              <!-- Quick Stats -->
              <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: var(--spacing-md); text-align: center;">
                <div>
                  <div style="font-size: 1.5rem; font-weight: 700; color: var(--primary-blue);"><%= answersList.size() %></div>
                  <div style="color: var(--dark-gray); font-weight: 600;">Total Questions</div>
                </div>
                <div>
                  <div style="font-size: 1.5rem; font-weight: 700; color: var(--success);"><%= correctAnswers %></div>
                  <div style="color: var(--dark-gray); font-weight: 600;">Correct Answers</div>
                </div>
                <div>
                  <div style="font-size: 1.5rem; font-weight: 700; color: var(--error);"><%= answersList.size() - correctAnswers %></div>
                  <div style="color: var(--dark-gray); font-weight: 600;">Incorrect Answers</div>
                </div>
                <div>
                  <div style="font-size: 1.5rem; font-weight: 700; color: var(--info);"><%= String.format("%.1f", accuracyRate) %>%</div>
                  <div style="color: var(--dark-gray); font-weight: 600;">Accuracy Rate</div>
                </div>
              </div>
              
              <!-- Marks Summary -->
              <div style="margin-top: var(--spacing-lg); padding-top: var(--spacing-md); border-top: 1px solid var(--medium-gray);">
                <div style="display: flex; justify-content: center; gap: var(--spacing-xl); align-items: center;">
                  <div style="text-align: center;">
                    <div style="font-size: 2rem; font-weight: 800; color: var(--primary-blue);">
                      <%= examDetails.getObtMarks() %>/<%= examDetails.gettMarks() %>
                    </div>
                    <div style="color: var(--dark-gray); font-weight: 600;">Marks Obtained</div>
                  </div>
                  <div style="width: 1px; height: 40px; background: var(--medium-gray);"></div>
                  <div style="text-align: center;">
                    <div style="font-size: 2rem; font-weight: 800; color: <%= percentageColor %>;">
                      <%= String.format("%.1f", percentage) %>%
                    </div>
                    <div style="color: var(--dark-gray); font-weight: 600;">Percentage</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Question Details -->
            <h3 style="color: var(--text-dark); margin-bottom: var(--spacing-md);">
              <i class="fas fa-list-check"></i>
              Question-wise Analysis
            </h3>
            
           <%
              for (int i = 0; i < answersList.size(); i++) {
                Answers a = answersList.get(i);
                boolean isCorrect = a.getStatus().equals("correct");
                
                // Get question details to check question type
                Questions questionObj = null;
                String questionType = "MCQ";
                if (a.getQuestionId() > 0) {
                    questionObj = pDAO.getQuestionById(a.getQuestionId());
                    if (questionObj != null && questionObj.getQuestionType() != null) {
                        questionType = questionObj.getQuestionType();
                    }
                }
                
                // Check if this is a drag-drop or rearrange question
                boolean isDragDrop = "DRAG_AND_DROP".equalsIgnoreCase(questionType) || 
                                    (a.getAnswer() != null && a.getAnswer().startsWith("{"));
                boolean isRearrange = "REARRANGE".equalsIgnoreCase(questionType) ||
                                     (a.getAnswer() != null && a.getAnswer().startsWith("["));
                
                // Calculate question score and max marks
                float qScore = 0;
                float qMaxMarks = (questionObj != null) ? questionObj.getTotalMarks() : 1.0f;
                if (qMaxMarks <= 0) qMaxMarks = 1.0f;

                if (a.getStatus().equals("correct")) {
                    qScore = qMaxMarks;
                } else if (a.getStatus().startsWith("partial:")) {
                    try {
                        qScore = Float.parseFloat(a.getStatus().substring(8));
                    } catch (Exception e) { qScore = 0; }
                }

                // Extract and format question text with code snippets
                String fullQuestion = a.getQuestion();
                String questionPart = "";
                String codePart = "";
                boolean hasCode = false;

                if(fullQuestion.contains("```")){
                    String[] parts = fullQuestion.split("```");
                    if(parts.length >= 2) {
                        questionPart = parts[0].trim();
                        codePart = parts[1].trim();
                        hasCode = true;
                    } else {
                        questionPart = fullQuestion.replace("```", "").trim();
                    }
                } else {
                    // Check if it's a code question by looking for code indicators
                    boolean isCodeQuestion = fullQuestion.contains("def ") || fullQuestion.contains("function ") || 
                                            fullQuestion.contains("public ") || fullQuestion.contains("class ") ||
                                            fullQuestion.contains("print(") || fullQuestion.contains("console.") || 
                                            fullQuestion.contains("<?php") || fullQuestion.contains("import ") ||
                                            fullQuestion.contains("int ") || fullQuestion.contains("String ") || 
                                            fullQuestion.contains("printf(") || fullQuestion.contains("cout ");
                    if(isCodeQuestion) {
                        codePart = fullQuestion;
                        questionPart = "What is the output/result of this code?";
                        hasCode = true;
                    } else {
                        questionPart = fullQuestion;
                    }
                }
            %>
            <div class="question-analysis">
              <div class="question-analysis-header" style="background: <%= isCorrect ? "var(--success-light)" : "var(--error-light)" %>;">
                <div class="question-number" style="background: <%= isCorrect ? "var(--success)" : "var(--error)" %>;">
                  <%= i + 1 %>
                </div>
                <div class="question-content">
                  <% if(!questionPart.isEmpty() && !questionPart.equals("What is the output/result of this code?")){ %>
                    <p class="question-text"><%= questionPart %></p>
                  <% } %>
                  
                  <!-- Question Image -->
                  <% 
                    String imagePath = "";
                    int questionId = a.getQuestionId();
                    if (questionId > 0) {
                        Questions questionDetailsObj = pDAO.getQuestionById(questionId);
                        if (questionDetailsObj != null && questionDetailsObj.getImagePath() != null && !questionDetailsObj.getImagePath().isEmpty()) {
                            imagePath = questionDetailsObj.getImagePath();
                        }
                    }
                    if (!imagePath.isEmpty()) { 
                  %>
                    <div class="question-image-container">
                        <img src="<%= imagePath %>" alt="Question Image" class="question-image" onerror="this.style.display='none';">
                    </div>
                  <% } %>
                  
                  <% if(hasCode){ %>
                    <div class="code-question-indicator"><i class="fas fa-code"></i><strong>Code Analysis Question</strong></div>
                    <div class="code-snippet">
                      <div class="code-header"><i class="fas fa-code"></i><span>Code to Analyze</span></div>
                      <pre><%= codePart %></pre>
                    </div>
                  <% } %>
                </div>
                <div class="question-status" style="color: <%= isCorrect ? "var(--success)" : "var(--error)" %>;">
                  <i class="fas <%= isCorrect ? "fa-check" : "fa-times" %>"></i>
                  <%= isCorrect ? "Correct" : "Incorrect" %>
                </div>
              </div>
              
              <div class="answer-grid">
                <% if (isDragDrop) { %>
                  <!-- Drag-Drop Question Answer Display -->
                  <div style="grid-column: 1 / -1;">
                    <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 12px; font-size: 13px;">
                      <i class="fas fa-hand-rock"></i> Drag and Drop Question
                    </div>
                    
                    <div style="background: var(--light-gray); padding: 16px; border-radius: var(--radius-md); border: 1px solid var(--medium-gray);">
                      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <!-- Student's Answers -->
                        <div>
                          <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 8px; font-size: 12px;">
                            <i class="fas fa-user-edit"></i> Your Matches
                          </div>
                          <div style="background: var(--white); padding: 12px; border-radius: var(--radius-sm); border: 1px solid <%= isCorrect ? "var(--success)" : "var(--error)" %>;">
                            <%
                              // Get student's drag-drop answers
                              ArrayList<myPackage.classes.DragDropAnswer> studentAnswers = new ArrayList<>();
                              try {
                                  studentAnswers = pDAO.getStudentDragDropAnswers(examDetails.getExamId(), a.getQuestionId(), String.valueOf(userId));
                              } catch (Exception e) {
                                  // Handle error gracefully
                              }
                              
                              if (studentAnswers.isEmpty()) {
                            %>
                                <div style="color: var(--dark-gray); font-style: italic;">No matches made</div>
                            <%
                              } else {
                                for (myPackage.classes.DragDropAnswer answer : studentAnswers) {
                                  // Find item and target text
                                  String itemTxt = "Item " + answer.getDragItemId();
                                  String targetTxt = "Target " + answer.getDropTargetId();
                                  
                                  if (questionObj != null) {
                                      if (questionObj.getDragItems() != null) {
                                          for (myPackage.classes.DragItem di : questionObj.getDragItems()) {
                                              if (di.getId() == answer.getDragItemId()) {
                                                  itemTxt = di.getItemText();
                                                  break;
                                              }
                                          }
                                      }
                                      if (questionObj.getDropTargets() != null) {
                                          for (myPackage.classes.DropTarget dt : questionObj.getDropTargets()) {
                                              if (dt.getId() == answer.getDropTargetId()) {
                                                  targetTxt = dt.getTargetLabel();
                                                  break;
                                              }
                                          }
                                      }
                                  }
                            %>
                                <div style="margin-bottom: 8px; padding: 6px; background: <%= answer.isCorrect() ? "rgba(5, 150, 105, 0.1)" : "rgba(220, 38, 38, 0.1)" %>; border-radius: 4px; font-size: 12px; white-space: pre-wrap;">
                                  <i class="fas <%= answer.isCorrect() ? "fa-check" : "fa-times" %>" style="color: <%= answer.isCorrect() ? "var(--success)" : "var(--error)" %>;"></i>
                                  <strong><%= itemTxt %></strong> ? <%= targetTxt %> <%= answer.isCorrect() ? "(Correct)" : "(Incorrect)" %>
                                </div>
                            <%
                                }
                              }
                            %>
                          </div>
                        </div>
                        
                        <!-- Correct Answers -->
                        <div>
                          <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 8px; font-size: 12px;">
                            <i class="fas fa-check-circle"></i> Correct Matches
                          </div>
                          <div style="background: var(--white); padding: 12px; border-radius: var(--radius-sm); border: 1px solid var(--success);">
                            <%
                              // Get correct drag-drop answers from question object
                              if (questionObj != null && questionObj.getDragItems() != null) {
                                  for (myPackage.classes.DragItem di : questionObj.getDragItems()) {
                                      if (di.getCorrectTargetId() != null && di.getCorrectTargetId() > 0) {
                                          String correctTargetLabel = "Target " + di.getCorrectTargetId();
                                          if (questionObj.getDropTargets() != null) {
                                              for (myPackage.classes.DropTarget dt : questionObj.getDropTargets()) {
                                                  if (dt.getId() == di.getCorrectTargetId().intValue()) {
                                                      correctTargetLabel = dt.getTargetLabel();
                                                      break;
                                                  }
                                              }
                                          }
                            %>
                                <div style="margin-bottom: 8px; padding: 6px; background: rgba(5, 150, 105, 0.1); border-radius: 4px; font-size: 12px; white-space: pre-wrap;">
                                  <i class="fas fa-check" style="color: var(--success);"></i>
                                  <strong><%= di.getItemText() %></strong> ? <%= correctTargetLabel %>
                                </div>
                            <%
                                      }
                                  }
                              } else {
                            %>
                                <div style="color: var(--dark-gray); font-style: italic;">No correct matches available</div>
                            <%
                              }
                            %>
                          </div>
                        </div>
                      </div>
                      
                      <!-- Score Display -->
                      <div style="margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--medium-gray);">
                        <div style="text-align: center;">
                          <div style="font-size: 14px; font-weight: 600; color: <%= isCorrect ? "var(--success)" : (qScore > 0 ? "var(--warning)" : "var(--error)") %>;">
                            <%= isCorrect ? "Full Score" : (qScore > 0 ? "Partial Score" : "Incorrect") %>: <%= qScore %> / <%= qMaxMarks %>
                          </div>
                          <!-- <div style="font-size: 12px; color: var(--dark-gray); margin-top: 4px;">
                            <%= a.getAnswer() %>
                          </div> -->
                        </div>
                      </div>
                    </div>
                  </div>
                <% } else if (isRearrange) { %>
                  <!-- Rearrange Question Answer Display -->
                  <div style="grid-column: 1 / -1;">
                    <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 12px; font-size: 13px;">
                      <i class="fas fa-sort-amount-down"></i> Rearrange Question
                    </div>
                    
                    <div style="background: var(--light-gray); padding: 16px; border-radius: var(--radius-md); border: 1px solid var(--medium-gray);">
                      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <!-- Student's Answer -->
                        <div>
                          <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 8px; font-size: 12px;">
                            <i class="fas fa-user-edit"></i> Your Order
                          </div>
                          <div style="background: var(--white); padding: 12px; border-radius: var(--radius-sm); border: 1px solid <%= isCorrect ? "var(--success)" : "var(--error)" %>;">
                            <%
                              try {
                                  org.json.JSONArray userArr = new org.json.JSONArray(a.getAnswer());
                                  for (int j = 0; j < userArr.length(); j++) {
                                      int itemId = userArr.getInt(j);
                                      String itemText = "Item " + itemId;
                                      if (questionObj != null && questionObj.getRearrangeItems() != null && !questionObj.getRearrangeItems().isEmpty()) {
                                          for (myPackage.classes.RearrangeItem ri : questionObj.getRearrangeItems()) {
                                              if (ri.getId() == itemId) {
                                                  itemText = ri.getItemText();
                                                  break;
                                              }
                                          }
                                      } else if (questionObj != null && questionObj.getDragItemsJson() != null) {
                                          // Fallback to JSON indices if relational items are missing
                                          try {
                                              org.json.JSONArray fallbackArr = new org.json.JSONArray(questionObj.getDragItemsJson());
                                              if (itemId >= 0 && itemId < fallbackArr.length()) {
                                                  itemText = fallbackArr.getString(itemId);
                                              }
                                          } catch (Exception e) {}
                                      }
                                      
                                      // Check if this item is in the correct position
                                      boolean itemInCorrectPos = false;
                                      try {
                                          org.json.JSONArray correctArr = new org.json.JSONArray(a.getCorrectAnswer());
                                          if (j < correctArr.length() && correctArr.getInt(j) == itemId) {
                                              itemInCorrectPos = true;
                                          }
                                      } catch (Exception e) {}
                            %>
                                <div style="margin-bottom: 8px; padding: 6px; background: <%= itemInCorrectPos ? "rgba(5, 150, 105, 0.1)" : "rgba(220, 38, 38, 0.1)" %>; border-radius: 4px; font-size: 12px; display: flex; align-items: center; gap: 8px;">
                                  <span style="background: <%= itemInCorrectPos ? "var(--success)" : "var(--error)" %>; color: white; width: 20px; height: 20px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; flex-shrink: 0;">
                                    <%= j + 1 %>
                                  </span>
                                  <span style="flex: 1; white-space: pre-wrap;"><%= itemText %></span>
                                  <i class="fas <%= itemInCorrectPos ? "fa-check" : "fa-times" %>" style="color: <%= itemInCorrectPos ? "var(--success)" : "var(--error)" %>;"></i>
                                </div>
                            <%
                                  }
                              } catch (Exception e) {
                            %>
                                <div style="color: var(--dark-gray); font-style: italic;">Invalid answer format</div>
                            <%
                              }
                            %>
                          </div>
                        </div>
                        
                        <!-- Correct Answer -->
                        <div>
                          <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 8px; font-size: 12px;">
                            <i class="fas fa-check-circle"></i> Correct Order
                          </div>
                          <div style="background: var(--white); padding: 12px; border-radius: var(--radius-sm); border: 1px solid var(--success);">
                            <%
                              try {
                                  org.json.JSONArray correctArr = new org.json.JSONArray(a.getCorrectAnswer());
                                  for (int j = 0; j < correctArr.length(); j++) {
                                      int itemId = correctArr.getInt(j);
                                      String itemText = "Item " + itemId;
                                      if (questionObj != null && questionObj.getRearrangeItems() != null && !questionObj.getRearrangeItems().isEmpty()) {
                                          for (myPackage.classes.RearrangeItem ri : questionObj.getRearrangeItems()) {
                                              if (ri.getId() == itemId) {
                                                  itemText = ri.getItemText();
                                                  break;
                                              }
                                          }
                                      } else if (questionObj != null && questionObj.getDragItemsJson() != null) {
                                          // Fallback to JSON indices
                                          try {
                                              org.json.JSONArray fallbackArr = new org.json.JSONArray(questionObj.getDragItemsJson());
                                              if (itemId >= 0 && itemId < fallbackArr.length()) {
                                                  itemText = fallbackArr.getString(itemId);
                                              }
                                          } catch (Exception e) {}
                                      }
                            %>
                                <div style="margin-bottom: 8px; padding: 6px; background: rgba(5, 150, 105, 0.1); border-radius: 4px; font-size: 12px; display: flex; align-items: center; gap: 8px;">
                                  <span style="background: var(--success); color: white; width: 20px; height: 20px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; flex-shrink: 0;">
                                    <%= j + 1 %>
                                  </span>
                                  <span style="flex: 1; white-space: pre-wrap;"><%= itemText %></span>
                                </div>
                            <%
                                  }
                              } catch (Exception e) {
                            %>
                                <div style="color: var(--dark-gray); font-style: italic;">No correct order available</div>
                            <%
                              }
                            %>
                          </div>
                        </div>
                      </div>
                      
                      <!-- Score Display -->
                      <div style="margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--medium-gray);">
                        <div style="text-align: center;">
                          <div style="font-size: 14px; font-weight: 600; color: <%= isCorrect ? "var(--success)" : (qScore > 0 ? "var(--warning)" : "var(--error)") %>;">
                            <%= isCorrect ? "Full Score" : (qScore > 0 ? "Partial Score" : "Incorrect") %>: <%= qScore %> / <%= qMaxMarks %>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                <% } else { %>
                  <!-- Regular Question Answer Display -->
                  <div>
                    <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 4px; font-size: 13px;">
                      <i class="fas fa-user-edit"></i> Your Answer
                    </div>
                    <div style="color: <%= isCorrect ? "var(--success)" : "var(--error)" %>; font-weight: 600; background: var(--white); padding: 8px 12px; border-radius: var(--radius-sm); border: 1px solid <%= isCorrect ? "var(--success)" : "var(--error)" %>;">
                      <% 
                        // Hide raw JSON display for drag-drop questions
                        String answerDisplay = a.getAnswer();
                        if (answerDisplay != null && answerDisplay.startsWith("{")) {
                            answerDisplay = "[Drag and Drop Answer]";
                        }
                      %>
                      <%= escapeHtml(answerDisplay != null ? answerDisplay : "No Answer") %>
                    </div>
                  </div>
                  
                  <div>
                    <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 4px; font-size: 13px;">
                      <i class="fas fa-check-circle"></i> Correct Answer
                    </div>
                    <div style="color: var(--success); font-weight: 600; background: var(--white); padding: 8px 12px; border-radius: var(--radius-sm); border: 1px solid var(--success);">
                      <% 
                        // Hide raw JSON display for drag-drop questions
                        String correctAnswerDisplay = a.getCorrectAnswer();
                        if (correctAnswerDisplay != null && correctAnswerDisplay.startsWith("{")) {
                            correctAnswerDisplay = "[Drag and Drop Answer]";
                        }
                      %>
                      <%= escapeHtml(correctAnswerDisplay != null ? correctAnswerDisplay : "N/A") %>
                    </div>
                  </div>
                  <!-- Score for regular question -->
                  <div style="grid-column: 1 / -1; margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--medium-gray); text-align: center;">
                    <div style="font-size: 14px; font-weight: 600; color: <%= isCorrect ? "var(--success)" : (qScore > 0 ? "var(--warning)" : "var(--error)") %>;">
                      <%= isCorrect ? "Correct" : (qScore > 0 ? "Partial Score" : "Incorrect") %>: <%= qScore %> / <%= qMaxMarks %>
                    </div>
                  </div>
                <% } %>
              </div>
            </div>
            <% 
              } // End for loop
            %>
            
            <!-- View All Results Link -->
            <div style="text-align: center; margin-top: var(--spacing-xl);">
              <a href="std-page.jsp?pgprt=2" class="action-btn" style="background: var(--primary-blue);">
                <i class="fas fa-list"></i>
                View All Exam Results
              </a>
            </div>
            
            <%
              } // End else (exam found)
            %>
          </div>
        </div>
      <%
        } else {
          // Show the list view (all results)
      %>
        <!-- Search Section -->
        <div class="search-container">
          <input type="text" id="courseSearch" class="search-input" placeholder="Search by course name..." onkeyup="filterAndSortTable()">
          <i class="fas fa-search search-icon"></i>
        </div>

        <!-- Results Summary -->
        <div class="results-summary">
          <div class="summary-item">
            <div class="summary-value"><%= totalResults %></div>
            <div class="summary-label">Total Exams</div>
          </div>
          <div class="summary-item">
            <div class="summary-value"><%= passedExams %></div>
            <div class="summary-label">Exams Passed</div>
          </div>
          <div class="summary-item">
            <div class="summary-value"><%= totalResults - passedExams %></div>
            <div class="summary-label">Exams Failed</div>
          </div>
          <div class="summary-item">
            <div class="summary-value"><%= String.format("%.1f", avgPercentage) %>%</div>
            <div class="summary-label">Average Score</div>
          </div>
        </div>

        <!-- Results Card -->
        <div class="results-card">
          <div class="card-header">
            <span><i class="fas fa-list"></i> All Exam Results</span>
            <div class="header-actions">
              <% if (latestExamId > 0) { %>
              <a href="std-page.jsp?pgprt=2&showLatest=true" class="action-btn" style="background: linear-gradient(135deg, #4a90e2, #357abd);">
                <i class="fas fa-clock"></i>
                View Latest Results
              </a>
              <% } %>
              <div class="stats-badge" style="background: linear-gradient(135deg, var(--success), #10b981);">
                <i class="fas fa-database"></i>
                <%= totalResults %> Records
              </div>
            </div>
          </div>
          
          <div class="results-table-container">
            <table class="results-table">
              <thead>
                <tr>
                  <th onclick="toggleSort(this, 'course')">
                    Course
                    <i class="fas fa-sort sort-indicator"></i>
                  </th>
                  <th onclick="toggleSort(this, 'date')">
                    Date
                    <i class="fas fa-sort sort-indicator"></i>
                  </th>
                  <th onclick="toggleSort(this, 'time')">
                    Time
                    <i class="fas fa-sort sort-indicator"></i>
                  </th>
                  <th onclick="toggleSort(this, 'marks')">
                    Marks
                    <i class="fas fa-sort sort-indicator"></i>
                  </th>
                  <th onclick="toggleSort(this, 'status')">
                    Status
                    <i class="fas fa-sort sort-indicator"></i>
                  </th>
                  <th onclick="toggleSort(this, 'percentage')">
                    %
                    <i class="fas fa-sort sort-indicator"></i>
                  </th>
                  <th>Details</th>
                </tr>
              </thead>
              <tbody id="courseTable">
                <% 
                  if (examList.isEmpty()) {
                %>
                  <tr>
                    <td colspan="7" class="no-results">
                      <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                      No exam results found. Complete some exams to see your results here.
                    </td>
                  </tr>
                <%
                  } else {
                    for (int i = 0; i < examList.size(); i++) {
                      Exams e = examList.get(i);
                      
                      // Calculate percentage
                      double percentage = 0;
                      if (e.gettMarks() > 0) {
                          percentage = (double) e.getObtMarks() / e.gettMarks() * 100;
                      }
                      
                      // Get result status from object (already has fallback logic in DatabaseClass)
                      String statusText = e.getStatus();
                      String statusClass = "status-fail";
                      
                      if (statusText != null) {
                          if (statusText.equalsIgnoreCase("Pass")) {
                              statusClass = "status-pass";
                          } else if (statusText.equalsIgnoreCase("Fail")) {
                              statusClass = "status-fail";
                          } else if (statusText.equalsIgnoreCase("completed") || statusText.equalsIgnoreCase("terminated")) {
                              statusText = "Terminated";
                              statusClass = "status-terminated";
                          } else {
                              statusClass = "status-terminated";
                          }
                      } else {
                          statusText = "InComplete";
                          statusClass = "status-terminated";
                      }
                      
                      // Check if this is the latest exam
                      boolean isLatest = e.getExamId() == latestExamId;
                %>
                <tr class="result-row <%= isLatest ? "latest-exam" : "" %>" 
                    data-course="<%= e.getcName().toLowerCase() %>"
                    data-date="<%= e.getDate() %>"
                    data-time="<%= e.getStartTime() + " - " + e.getEndTime() %>"
                    data-marks="<%= e.getObtMarks() %>/<%= e.gettMarks() %>"
                    data-percentage="<%= percentage %>"
                    data-status="<%= statusText.toLowerCase() %>">
                  <td class="course-name">
                    <%= e.getcName() %>
                    <% if (isLatest) { %>
                    <span class="latest-indicator" title="Latest Exam">
                      <i class="fas fa-star"></i>
                    </span>
                    <% } %>
                  </td>
                  <td class="exam-date"><%= e.getDate() %></td>
                  <td class="exam-time"><%= e.getStartTime() + " - " + e.getEndTime() %></td>
                  <td class="exam-marks"><%= e.getObtMarks() %> / <%= e.gettMarks() %></td>
                  <td>
                    <span class="status-badge <%= statusClass %>">
                      <i class="fas <%= statusClass.equals("status-pass") ? "fa-check-circle" : 
                                       statusClass.equals("status-fail") ? "fa-times-circle" : "fa-exclamation-triangle" %>"></i>
                      <%= statusText %>
                    </span>
                  </td>
                  <td>
                    <span class="percentage-badge">
                      <%= String.format("%.0f", percentage) %>%
                    </span>
                  </td>
                  <td>
                    <a href="std-page.jsp?pgprt=2&eid=<%= e.getExamId() %>" class="action-btn">
                      <i class="fas fa-eye"></i>
                      View
                    </a>
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
      <%
        }
      %>
    </div>
  </main>
</div>

<script>
  // Global variables for sorting and filtering
  let currentSort = {
    column: null,
    direction: 'asc'
  };
  
  let currentFilters = {
    search: '',
    status: 'all',
    minPercentage: 0,
    maxPercentage: 100
  };
  
  // Initialize the page
  document.addEventListener('DOMContentLoaded', function() {
    initializeFilters();
    updateResultsCount();
    addFilterControls();
  });
  
  function initializeFilters() {
    // Add event listeners for search
    const searchInput = document.getElementById('courseSearch');
    if (searchInput) {
      searchInput.addEventListener('input', function() {
        currentFilters.search = this.value.toLowerCase();
        applyAllFilters();
      });
    }
  }
  
  function addFilterControls() {
    // Create filter controls container
    const filterControls = document.createElement('div');
    filterControls.className = 'filter-controls';
    filterControls.style.cssText = `
      background: var(--white);
      border-radius: var(--radius-md);
      padding: var(--spacing-md);
      margin-bottom: var(--spacing-md);
      border: 1px solid var(--medium-gray);
      box-shadow: var(--shadow-sm);
    `;
    
    // Add filter header
    filterControls.innerHTML = `
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--spacing-sm);">
        <h4 style="font-size: 14px; font-weight: 600; color: var(--text-dark);">
          <i class="fas fa-filter"></i> Filter Results
        </h4>
        <button id="resetFilters" class="action-btn" style="background: var(--dark-gray);">
          <i class="fas fa-redo"></i> Reset
        </button>
      </div>
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--spacing-md);">
        <div>
          <label style="display: block; font-size: 12px; font-weight: 600; color: var(--text-dark); margin-bottom: 4px;">
            Status Filter
          </label>
          <select id="statusFilter" class="search-input" style="width: 100%;">
            <option value="all">All Status</option>
            <option value="pass">Pass Only</option>
            <option value="fail">Fail Only</option>
            <option value="terminated">Terminated Only</option>
          </select>
        </div>
        <div>
          <label style="display: block; font-size: 12px; font-weight: 600; color: var(--text-dark); margin-bottom: 4px;">
            Score Range
          </label>
          <div style="display: flex; gap: var(--spacing-sm);">
            <input type="number" id="minScore" class="search-input" placeholder="Min %" min="0" max="100" style="flex: 1;">
            <span style="color: var(--dark-gray); align-self: center;">to</span>
            <input type="number" id="maxScore" class="search-input" placeholder="Max %" min="0" max="100" style="flex: 1;">
          </div>
        </div>
      </div>
    `;
    
    // Insert filter controls after search container
    const searchContainer = document.querySelector('.search-container');
    if (searchContainer) {
      searchContainer.parentNode.insertBefore(filterControls, searchContainer.nextSibling);
    } else {
      const resultsPanel = document.querySelector('.results-panel');
      if (resultsPanel) {
        resultsPanel.insertBefore(filterControls, resultsPanel.children[1]);
      }
    }
    
    // Add event listeners to filter controls
    const statusFilter = document.getElementById('statusFilter');
    const minScore = document.getElementById('minScore');
    const maxScore = document.getElementById('maxScore');
    const resetBtn = document.getElementById('resetFilters');
    
    if (statusFilter) {
      statusFilter.addEventListener('change', function() {
        currentFilters.status = this.value;
        applyAllFilters();
      });
    }
    
    if (minScore) {
      minScore.addEventListener('input', debounce(function() {
        currentFilters.minPercentage = parseInt(this.value) || 0;
        applyAllFilters();
      }, 300));
    }
    
    if (maxScore) {
      maxScore.addEventListener('input', debounce(function() {
        currentFilters.maxPercentage = parseInt(this.value) || 100;
        applyAllFilters();
      }, 300));
    }
    
    if (resetBtn) {
      resetBtn.addEventListener('click', resetAllFilters);
    }
  }
  
  function applyAllFilters() {
    const tableBody = document.getElementById('courseTable');
    if (!tableBody) return;
    
    const rows = tableBody.querySelectorAll('tr.result-row');
    let visibleCount = 0;
    
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      const courseName = row.getAttribute('data-course');
      const status = row.getAttribute('data-status');
      const percentage = parseFloat(row.getAttribute('data-percentage'));
      
      let showRow = true;
      
      // Apply search filter
      if (currentFilters.search && !courseName.includes(currentFilters.search)) {
        showRow = false;
      }
      
      // Apply status filter
      if (currentFilters.status !== 'all' && status !== currentFilters.status) {
        showRow = false;
      }
      
      // Apply percentage filter
      if (percentage < currentFilters.minPercentage || percentage > currentFilters.maxPercentage) {
        showRow = false;
      }
      
      // Show/hide row
      row.style.display = showRow ? "" : "none";
      if (showRow) visibleCount++;
    }
    
    // Update visible count
    updateVisibleCount(visibleCount);
  }
  
  function updateVisibleCount(count) {
    const totalCount = document.querySelectorAll('tr.result-row').length;
    const countElement = document.getElementById('visibleCount');
    
    if (!countElement) {
      // Create visible count element if it doesn't exist
      const statsBadge = document.querySelector('.card-header .stats-badge');
      if (statsBadge) {
        const visibleCountElement = document.createElement('span');
        visibleCountElement.id = 'visibleCount';
        visibleCountElement.style.cssText = `
          background: var(--info);
          color: var(--white);
          padding: 4px 8px;
          border-radius: 10px;
          font-size: 12px;
          font-weight: 500;
          margin-left: 8px;
        `;
        visibleCountElement.textContent = `${count} shown`;
        statsBadge.appendChild(visibleCountElement);
      }
    } else {
      countElement.textContent = `${count} shown`;
    }
  }
  
  function updateResultsCount() {
    const rows = document.querySelectorAll('tr.result-row');
    const visibleRows = document.querySelectorAll('tr.result-row:not([style*="display: none"])');
    updateVisibleCount(visibleRows.length);
  }
  
  function resetAllFilters() {
    // Reset search input
    const searchInput = document.getElementById('courseSearch');
    if (searchInput) {
      searchInput.value = '';
      currentFilters.search = '';
    }
    
    // Reset status filter
    const statusFilter = document.getElementById('statusFilter');
    if (statusFilter) {
      statusFilter.value = 'all';
      currentFilters.status = 'all';
    }
    
    // Reset score filters
    const minScore = document.getElementById('minScore');
    const maxScore = document.getElementById('maxScore');
    if (minScore) {
      minScore.value = '';
      currentFilters.minPercentage = 0;
    }
    if (maxScore) {
      maxScore.value = '';
      currentFilters.maxPercentage = 100;
    }
    
    // Show all rows
    const rows = document.querySelectorAll('tr.result-row');
    for (let i = 0; i < rows.length; i++) {
      rows[i].style.display = "";
    }
    
    // Update counts
    updateVisibleCount(rows.length);
  }
  
  function toggleSort(header, column) {
    const tableBody = document.getElementById('courseTable');
    if (!tableBody) return;
    
    // Get visible rows only
    const rows = Array.from(tableBody.querySelectorAll('tr.result-row:not([style*="display: none"])'));
    const indicator = header.querySelector('.sort-indicator');
    
    // Reset all sort indicators
    document.querySelectorAll('.sort-indicator').forEach(ind => {
      ind.classList.remove('rotate', 'fa-sort-up', 'fa-sort-down');
      ind.className = 'fas fa-sort sort-indicator';
    });
    
    // Toggle direction if clicking the same column
    if (currentSort.column === column) {
      currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
      currentSort.column = column;
      currentSort.direction = 'asc';
    }
    
    // Update sort indicator
    if (currentSort.direction === 'asc') {
      indicator.classList.remove('fa-sort');
      indicator.classList.add('fa-sort-up');
    } else {
      indicator.classList.remove('fa-sort');
      indicator.classList.add('fa-sort-down');
    }
    
    // Sort rows
    rows.sort((a, b) => {
      let aValue, bValue;
      
      switch(column) {
        case 'course':
          aValue = a.getAttribute('data-course');
          bValue = b.getAttribute('data-course');
          break;
        case 'date':
          aValue = new Date(a.getAttribute('data-date'));
          bValue = new Date(b.getAttribute('data-date'));
          break;
        case 'time':
          aValue = a.getAttribute('data-time');
          bValue = b.getAttribute('data-time');
          break;
        case 'marks':
          const aMarks = a.getAttribute('data-marks').split('/').map(Number);
          const bMarks = b.getAttribute('data-marks').split('/').map(Number);
          aValue = aMarks[0] / aMarks[1];
          bValue = bMarks[0] / bMarks[1];
          break;
        case 'status':
          const statusOrder = { 'pass': 1, 'fail': 2, 'terminated': 3 };
          aValue = statusOrder[a.getAttribute('data-status')] || 4;
          bValue = statusOrder[b.getAttribute('data-status')] || 4;
          break;
        case 'percentage':
          aValue = parseFloat(a.getAttribute('data-percentage'));
          bValue = parseFloat(b.getAttribute('data-percentage'));
          break;
        default:
          const cell = column === 'details' ? 6 : 0;
          aValue = a.cells[cell]?.textContent.trim() || '';
          bValue = b.cells[cell]?.textContent.trim() || '';
      }
      
      // Handle null/undefined values
      aValue = aValue || '';
      bValue = bValue || '';
      
      // Compare values
      if (aValue < bValue) return currentSort.direction === 'asc' ? -1 : 1;
      if (aValue > bValue) return currentSort.direction === 'asc' ? 1 : -1;
      return 0;
    });
    
    // Reappend sorted rows
    rows.forEach(row => tableBody.appendChild(row));
  }
  
  function filterAndSortTable() {
    const input = document.getElementById('courseSearch');
    if (!input) return;
    
    currentFilters.search = input.value.toLowerCase();
    applyAllFilters();
  }
  
  // Utility function for debouncing
  function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
  
  // Add CSS for filter controls
  const style = document.createElement('style');
  style.textContent = `
    .filter-controls select.search-input {
      background: var(--white);
      border: 1px solid var(--medium-gray);
      border-radius: var(--radius-sm);
      padding: 8px 12px;
      font-size: 13px;
      transition: all var(--transition-fast);
      appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364748b' d='M2 4l4 4 4-4z'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 12px center;
      background-size: 12px;
    }
    
    .filter-controls select.search-input:focus {
      outline: none;
      border-color: var(--accent-blue);
      box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }
    
    .filter-controls input[type="number"].search-input {
      background: var(--white);
      border: 1px solid var(--medium-gray);
      border-radius: var(--radius-sm);
      padding: 8px 12px;
      font-size: 13px;
      transition: all var(--transition-fast);
    }
    
    .filter-controls input[type="number"].search-input:focus {
      outline: none;
      border-color: var(--accent-blue);
      box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }
    
    .filter-controls .action-btn {
      padding: 6px 12px;
      font-size: 12px;
    }
    
    /* Quick filter buttons */
    .quick-filters {
      display: flex;
      gap: var(--spacing-sm);
      margin-top: var(--spacing-sm);
      flex-wrap: wrap;
    }
    
    .quick-filter-btn {
      background: var(--light-gray);
      border: 1px solid var(--medium-gray);
      border-radius: 16px;
      padding: 6px 12px;
      font-size: 12px;
      font-weight: 500;
      cursor: pointer;
      transition: all var(--transition-fast);
      color: var(--text-dark);
      display: inline-flex;
      align-items: center;
      gap: 4px;
    }
    
    .quick-filter-btn:hover,
    .quick-filter-btn.active {
      background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
      color: var(--white);
      border-color: transparent;
    }
  `;
  document.head.appendChild(style);
  
  // Add quick filters function
  function addQuickFilters() {
    const filterControls = document.querySelector('.filter-controls');
    if (!filterControls) return;
    
    const quickFilters = document.createElement('div');
    quickFilters.className = 'quick-filters';
    quickFilters.innerHTML = `
      <div style="font-size: 12px; font-weight: 600; color: var(--text-dark); margin-right: var(--spacing-sm);">Quick Filters:</div>
      <button class="quick-filter-btn" onclick="setQuickFilter('high_scores')">
        <i class="fas fa-star"></i> High Scores (?80%)
      </button>
      <button class="quick-filter-btn" onclick="setQuickFilter('low_scores')">
        <i class="fas fa-exclamation-triangle"></i> Low Scores (&lt;50%)
      </button>
      <button class="quick-filter-btn" onclick="setQuickFilter('recent')">
        <i class="fas fa-clock"></i> Recent Exams
      </button>
      <button class="quick-filter-btn" onclick="setQuickFilter('failed')">
        <i class="fas fa-times-circle"></i> Failed Exams
      </button>
    `;
    
    filterControls.appendChild(quickFilters);
  }
  
  function setQuickFilter(filterType) {
    resetAllFilters();
    
    const minScore = document.getElementById('minScore');
    const maxScore = document.getElementById('maxScore');
    const statusFilter = document.getElementById('statusFilter');
    
    switch(filterType) {
      case 'high_scores':
        if (minScore) minScore.value = '80';
        if (maxScore) maxScore.value = '100';
        currentFilters.minPercentage = 80;
        currentFilters.maxPercentage = 100;
        break;
      case 'low_scores':
        if (minScore) minScore.value = '0';
        if (maxScore) maxScore.value = '50';
        currentFilters.minPercentage = 0;
        currentFilters.maxPercentage = 50;
        break;
      case 'recent':
        // Sort by date descending
        const dateHeader = document.querySelector('th[onclick*="date"]');
        if (dateHeader) toggleSort(dateHeader, 'date');
        break;
      case 'failed':
        if (statusFilter) statusFilter.value = 'fail';
        currentFilters.status = 'fail';
        break;
    }
    
    applyAllFilters();
  }
  
  // Initialize quick filters after page loads
  setTimeout(addQuickFilters, 100);
  
  // Delete Modal Functions
  function showDeleteModal() {
    document.getElementById('deleteModal').style.display = 'flex';
  }
  
  function hideDeleteModal() {
    document.getElementById('deleteModal').style.display = 'none';
  }
  
  function showDeleteSelectedModal(count) {
    document.getElementById('deleteCount').textContent = count;
    document.getElementById('deleteSelectedModal').style.display = 'flex';
  }
  
  function hideDeleteSelectedModal() {
    document.getElementById('deleteSelectedModal').style.display = 'none';
  }
  
  function deleteSelectedQuestions() {
    const selectedCount = document.getElementById('selectedCount').textContent;
    if (selectedCount > 0) {
      showDeleteSelectedModal(selectedCount);
    }
  }
  
  function confirmDeleteSelected() {
    // Add your deletion logic here
    console.log('Deleting selected questions...');
    hideDeleteSelectedModal();
    // Reset selection
    document.getElementById('selectedCount').textContent = '0';
    document.getElementById('floatingDeleteBtn').classList.remove('show');
  }
  
  // Scroll Button Functions
  function initScrollButtons() {
    const scrollUpBtn = document.getElementById('scrollUpBtn');
    const scrollDownBtn = document.getElementById('scrollDownBtn');
    const floatingScroll = document.getElementById('floatingScroll');
    
    if (!scrollUpBtn || !scrollDownBtn || !floatingScroll) return;
    
    function scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }
    
    function scrollToBottom() {
        window.scrollTo({
            top: document.documentElement.scrollHeight - window.innerHeight,
            behavior: 'smooth'
        });
    }
    
    function toggleScrollButtons() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const scrollHeight = document.documentElement.scrollHeight;
        const clientHeight = window.innerHeight;
        
        // Show buttons if page is scrollable
        if (scrollHeight > clientHeight) {
            floatingScroll.classList.add('visible');
        } else {
            floatingScroll.classList.remove('visible');
        }
    }
    
    // Event listeners
    scrollUpBtn.addEventListener('click', scrollToTop);
    scrollDownBtn.addEventListener('click', scrollToBottom);
    window.addEventListener('scroll', toggleScrollButtons);
    window.addEventListener('resize', toggleScrollButtons);
    
    // Initial check
    toggleScrollButtons();
  }
  
  // Initialize scroll buttons when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initScrollButtons);
  } else {
    initScrollButtons();
  }
</script>

<!-- Floating Delete Selected Button -->
<% if (currentUser.getType().equalsIgnoreCase("admin")) { %>
<button id="floatingDeleteBtn" class="floating-delete-selected" onclick="deleteSelectedQuestions()">
    <i class="fas fa-trash"></i> Delete Selected (<span id="selectedCount">0</span>)
</button>
<% } %>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="modal-backdrop" style="display: none;">
    <div class="modal-box">
        <div class="modal-header">Confirm Deletion</div>
        <div class="modal-body">
            Are you sure you want to delete this question? This action cannot be undone.
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" onclick="hideDeleteModal()">Cancel</button>
            <button class="btn-confirm-del" id="confirmDelBtn">Delete Question</button>
        </div>
    </div>
</div>

<!-- Delete Selected Confirmation Modal -->
<div id="deleteSelectedModal" class="modal-backdrop" style="display: none;">
    <div class="modal-box">
        <div class="modal-header">Confirm Bulk Deletion</div>
        <div class="modal-body">
            Are you sure you want to delete <span id="deleteCount" style="font-weight: bold;">0</span> selected question(s)?
            <div style="color: #dc3545; font-weight: 500; margin-top: 10px;">This action cannot be undone.</div>
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" onclick="hideDeleteSelectedModal()">Cancel</button>
            <button class="btn-confirm-del" onclick="confirmDeleteSelected()">Delete Selected</button>
        </div>
    </div>
</div>

<!-- Floating Scroll Buttons -->
<div class="floating-scroll" id="floatingScroll">
    <button class="scroll-btn" id="scrollUpBtn" title="Scroll to Top">
        <i class="fas fa-chevron-up"></i>
    </button>
    <button class="scroll-btn" id="scrollDownBtn" title="Scroll to Bottom">
        <i class="fas fa-chevron-down"></i>
    </button>
</div>