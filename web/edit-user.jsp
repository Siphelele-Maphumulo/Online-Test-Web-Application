<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

// Get current user details FIRST
User currentUser = null;

// Check if user is logged in
if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Get current user details
currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());

if (currentUser == null) {
    // User not found in database
    session.invalidate();
    response.sendRedirect("login.jsp");
    return;
}

// Now get student list
ArrayList<User> studentList = pDAO.getAllStudents();
int totalCount = 0;
int displayCount = 0;

// Count total students (excluding current user)
for (User user : studentList) {
    if (user.getUserId() != Integer.parseInt(session.getAttribute("userId").toString())) {
        if (currentUser.getType().equalsIgnoreCase("lecture") && user.getType().equalsIgnoreCase("student") ||
            currentUser.getType().equalsIgnoreCase("admin")) {
            totalCount++;
        }
    }
}

String targetUserIdParam = request.getParameter("uid");
User targetUser = null;
if (targetUserIdParam != null && !targetUserIdParam.trim().isEmpty()) {
    targetUser = pDAO.getUserDetails(targetUserIdParam);
}

ArrayList<String> editPageCourses = pDAO.getAllCourseNames();
String flashMessage = (String) session.getAttribute("message");
String errorMessage = (String) session.getAttribute("error");
if (flashMessage != null) {
    session.removeAttribute("message");
}
if (errorMessage != null) {
    session.removeAttribute("error");
}

String targetInitials = "?";
String backLink = "adm-page.jsp?pgprt=1";
String currentCourseName = null;
if (targetUser != null) {
    String first = targetUser.getFirstName() != null ? targetUser.getFirstName().trim() : "";
    String last = targetUser.getLastName() != null ? targetUser.getLastName().trim() : "";
    if (!first.isEmpty()) {
        targetInitials = first.substring(0, 1).toUpperCase();
    }
    if (!last.isEmpty()) {
        targetInitials = targetInitials.equals("?") ? last.substring(0, 1).toUpperCase() : targetInitials + last.substring(0, 1).toUpperCase();
    }
    if ("?".equals(targetInitials) && targetUser.getUserName() != null && !targetUser.getUserName().trim().isEmpty()) {
        targetInitials = targetUser.getUserName().substring(0, 1).toUpperCase();
    }

    if ("lecture".equalsIgnoreCase(targetUser.getType())) {
        backLink = "adm-page.jsp?pgprt=6";
    }

    currentCourseName = targetUser.getCourseName();
}
%>


<!--style-->
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
            width: 280px;
            background: linear-gradient(180deg, var(--primary-blue) 0%, #0d3060 100%);
            color: var(--white);
            flex-shrink: 0;
            position: sticky;
            top: 0;
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
        
        .sidebar-header {
            padding: var(--spacing-2xl) var(--spacing-lg) var(--spacing-xl);
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
        }
        
        .mut-logo {
            max-height: 120px;
            width: auto;
            filter: brightness(0) invert(1);
            transition: transform var(--transition-normal);
        }
        
        .mut-logo:hover {
            transform: scale(1.05);
        }
        
        .sidebar-nav {
            padding: var(--spacing-xl) var(--spacing-sm);
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
        
        /* Main Content Area */
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
            gap: var(--spacing-md);
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
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: var(--spacing-2xl) var(--spacing-xl);
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border-color);
        }
        
        .empty-state i {
            font-size: 64px;
            color: var(--dark-gray);
            margin-bottom: var(--spacing-lg);
            opacity: 0.5;
        }
        
        .empty-state h2 {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: var(--spacing-md);
            color: var(--text-dark);
        }
        
        .empty-state p {
            color: var(--dark-gray);
            margin-bottom: var(--spacing-xl);
            max-width: 400px;
            margin-left: auto;
            margin-right: auto;
        }
        
        /* User Edit Grid */
        .user-edit-grid {
            display: grid;
            grid-template-columns: 350px 1fr;
            gap: var(--spacing-xl);
            margin-bottom: var(--spacing-xl);
        }
        
        @media (max-width: 1024px) {
            .user-edit-grid {
                grid-template-columns: 1fr;
            }
        }
        
        /* User Summary Card */
        .user-summary-card {
            background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border-color);
            padding: var(--spacing-xl);
            height: fit-content;
            position: sticky;
            top: var(--spacing-xl);
        }
        
        .summary-header {
            display: flex;
            align-items: center;
            gap: var(--spacing-lg);
            padding-bottom: var(--spacing-lg);
            margin-bottom: var(--spacing-lg);
            border-bottom: 2px solid var(--light-gray);
        }
        
        .summary-avatar {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--accent-blue), var(--accent-blue-light));
            border-radius: var(--radius-xl);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 28px;
            font-weight: 700;
            flex-shrink: 0;
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
            border: 4px solid var(--white);
            position: relative;
            overflow: hidden;
        }
        
        .summary-avatar::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            animation: shimmer 2s infinite;
        }
        
        .summary-header h2 {
            margin: 0 0 var(--spacing-xs) 0;
            font-size: 22px;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1.3;
        }
        
        .summary-header p {
            color: var(--dark-gray);
            font-size: 14px;
            margin-bottom: var(--spacing-md);
            display: flex;
            align-items: center;
            gap: var(--spacing-xs);
        }
        
        .summary-header p i {
            color: var(--accent-blue);
        }
        
        /* Role Badges */
        .role-badge {
            display: inline-flex;
            align-items: center;
            gap: var(--spacing-xs);
            padding: 6px 16px;
            border-radius: var(--radius-full);
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--white);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        
        .role-student {
            background: linear-gradient(135deg, #475569, #64748b);
        }
        
        .role-lecture {
            background: linear-gradient(135deg, #0891b2, #0ea5e9);
        }
        
        .role-admin {
            background: linear-gradient(135deg, #059669, #10b981);
        }
        
        /* Summary Details */
        .summary-details {
            list-style: none;
        }
        
        .summary-details li {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: var(--spacing-md) 0;
            border-bottom: 1px solid var(--light-gray);
            transition: background-color var(--transition-fast);
            border-radius: var(--radius-sm);
            padding-left: var(--spacing-sm);
            padding-right: var(--spacing-sm);
        }
        
        .summary-details li:hover {
            background-color: var(--light-gray);
        }
        
        .summary-details li:last-child {
            border-bottom: none;
        }
        
        .summary-details .label {
            font-weight: 600;
            color: var(--dark-gray);
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        
        .summary-details .label i {
            width: 16px;
            color: var(--accent-blue);
        }
        
        .summary-details span:last-child {
            font-weight: 500;
            color: var(--text-dark);
            font-size: 14px;
            text-align: right;
            max-width: 150px;
            word-break: break-word;
        }
        
        /* User Form Card */
        .user-form-card {
            background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border-color);
            padding: var(--spacing-xl);
        }
        
        .user-form-card h3 {
            font-size: 18px;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: var(--spacing-lg);
            padding-bottom: var(--spacing-md);
            border-bottom: 2px solid var(--light-gray);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        
        .user-form-card h3::before {
            content: '';
            width: 8px;
            height: 8px;
            background: var(--accent-blue);
            border-radius: 50%;
            display: block;
        }
        
        /* Form Grid */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: var(--spacing-lg);
            margin-bottom: var(--spacing-xl);
        }
        
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-label {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 14px;
            margin-bottom: var(--spacing-sm);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        
        .form-label i {
            color: var(--accent-blue);
            width: 16px;
            text-align: center;
        }
        
        .form-input {
            padding: 12px 16px;
            border: 2px solid var(--border-color);
            border-radius: var(--radius-md);
            font-size: 14px;
            transition: all var(--transition-fast);
            width: 100%;
            background: var(--white);
            font-family: inherit;
        }
        
        .form-input:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
            transform: translateY(-1px);
        }
        
        .form-input:disabled {
            background: var(--light-gray);
            cursor: not-allowed;
            opacity: 0.7;
        }
        
        /* Password Field */
        .password-field {
            position: relative;
        }
        
        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--dark-gray);
            cursor: pointer;
            padding: var(--spacing-xs);
            transition: color var(--transition-fast);
        }
        
        .password-toggle:hover {
            color: var(--accent-blue);
        }
        
        /* Input Hints */
        .input-hint {
            display: block;
            margin-top: var(--spacing-xs);
            font-size: 12px;
            color: var(--dark-gray);
            display: flex;
            align-items: center;
            gap: var(--spacing-xs);
        }
        
        .input-hint i {
            color: var(--accent-blue);
        }
        
        /* Form Actions */
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: var(--spacing-md);
            padding-top: var(--spacing-lg);
            border-top: 2px solid var(--light-gray);
            margin-top: var(--spacing-lg);
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
        
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        
        /* Responsive Design */
        @media (max-width: 992px) {
            .sidebar {
                display: none;
            }
            
            .main-content {
                margin-left: 0;
                padding: 15px;
                width: 100%;
                box-sizing: border-box;
            }
        }

        @media (max-width: 768px) {
            .dashboard-container {
                flex-direction: column;
            }
            
            .sidebar-nav {
                display: flex;
                overflow-x: auto;
                padding: var(--spacing-md);
                gap: var(--spacing-sm);
            }
            
            .nav-item {
                flex-direction: column;
                padding: var(--spacing-sm) var(--spacing-md);
                min-width: 80px;
                text-align: center;
                margin: 0;
                border-radius: var(--radius-md);
            }
            
            .nav-item::before {
                width: 100%;
                height: 3px;
                top: auto;
                bottom: 0;
                transform: translateY(100%);
            }
            
            .nav-item:hover::before,
            .nav-item.active::before {
                transform: translateY(0);
            }
            
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
            
            .user-summary-card,
            .user-form-card {
                padding: var(--spacing-lg);
            }
            
            .summary-header {
                flex-direction: column;
                text-align: center;
                gap: var(--spacing-md);
            }
            
            .form-actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
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
        
        /* Focus Styles for Accessibility */
        *:focus {
            outline: 2px solid var(--accent-blue);
            outline-offset: 2px;
        }
        
        *:focus:not(.focus-visible) {
            outline: none;
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
            <a href="adm-page.jsp?pgprt=3" class="nav-item">
                <i class="fas fa-question-circle"></i>
                <h2>Questions</h2>
            </a>
            <a href="adm-page.jsp?pgprt=5" class="nav-item">
                <i class="fas fa-chart-bar"></i>
                <h2>Results</h2>
            </a>
            <a href="adm-page.jsp?pgprt=1" class="nav-item active">
                <i class="fas fa-user-graduate"></i>
                <h2>Student Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=6" class="nav-item">
                <i class="fas fa-chalkboard-teacher"></i>
                <h2>Lecture Accounts</h2>
            </a>
        </nav>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <header class="page-header edit-header">
            <div class="page-title">
                <i class="fas fa-user-edit"></i>
                Edit Account
            </div>
            <div class="header-actions">
                <a href="<%= backLink %>" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i>
                    Back to Accounts
                </a>
            </div>
        </header>

        <% if (flashMessage != null && !flashMessage.isEmpty()) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <%= flashMessage %>
        </div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-circle"></i>
            <%= errorMessage %>
        </div>
        <% } %>

        <% if (targetUser == null) { %>
        <div class="empty-state">
            <i class="fas fa-user-slash"></i>
            <h2>User not found</h2>
            <p>The requested account could not be located. Please return to the accounts list.</p>
            <a href="adm-page.jsp?pgprt=1" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i>
                Back to Student Accounts
            </a>
        </div>
        <% } else { %>
        <section class="user-edit-grid">
            <div class="user-summary-card">
                <div class="summary-header">
                    <div class="summary-avatar" id="summaryAvatar"><%= targetInitials %></div>
                    <div>
                        <h2 id="summaryName"><%= (targetUser.getFirstName() != null ? targetUser.getFirstName() : "") %> <%= (targetUser.getLastName() != null ? targetUser.getLastName() : "") %></h2>
                        <p id="summaryEmail"><i class="fas fa-envelope"></i> <%= (targetUser.getEmail() != null ? targetUser.getEmail() : "Not provided") %></p>
                        <span id="summaryType" class="role-badge role-<%= (targetUser.getType() != null ? targetUser.getType().toLowerCase() : "student") %>">
                            <%= (targetUser.getType() != null ? targetUser.getType().substring(0, 1).toUpperCase() + targetUser.getType().substring(1) : "Student") %>
                        </span>
                    </div>
                </div>

            <ul class="summary-details">
                <li>
                    <span class="label"><i class="fas fa-id-card"></i> Username</span>
                    <span id="summaryUsername"><%= (targetUser.getUserName() != null ? targetUser.getUserName() : "") %></span>
                </li>
                <li>
                    <span class="label"><i class="fas fa-phone"></i> Contact</span>
                    <span id="summaryContact"><%= (targetUser.getContact() != null && !targetUser.getContact().isEmpty() ? targetUser.getContact() : "Not provided") %></span>
                </li>
                <li>
                    <span class="label"><i class="fas fa-city"></i> City</span>
                    <span id="summaryCity"><%= (targetUser.getCity() != null && !targetUser.getCity().isEmpty() ? targetUser.getCity() : "Not provided") %></span>
                </li>
                <li>
                    <span class="label"><i class="fas fa-map-marker-alt"></i> Address</span>
                    <span id="summaryAddress"><%= (targetUser.getAddress() != null && !targetUser.getAddress().isEmpty() ? targetUser.getAddress() : "Not provided") %></span>
                </li>
                <li id="summaryCourseRow" style="<%= ("lecture".equalsIgnoreCase(targetUser.getType()) ? "" : "display: none;") %>">
                    <span class="label"><i class="fas fa-book"></i> Course</span>
                    <span id="summaryCourse"><%= (currentCourseName != null && !currentCourseName.isEmpty() ? currentCourseName : "No course assigned") %></span>
                </li>
                <li>
                    <span class="label"><i class="fas fa-clock"></i> Last Updated</span>
                    <span><%= targetUser.getUserId() > 0 ? "Updates take effect immediately" : "" %></span>
                </li>
            </ul>

            </div>

            <div class="user-form-card">
                <h3>Update Account Details</h3>
                <form id="editUserForm" action="controller.jsp" method="post" onsubmit="return validateForm()">
                    <input type="hidden" name="page" value="accounts">
                    <input type="hidden" name="operation" value="edit">
                    <input type="hidden" name="uid" value="<%= targetUser.getUserId() %>">
                    <input type="hidden" name="original_type" value="<%= (targetUser.getType() != null ? targetUser.getType() : "") %>">

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label" for="editFname"><i class="fas fa-user"></i> First Name</label>
                            <input type="text" id="editFname" name="fname" class="form-input" 
                                   value="<%= (targetUser.getFirstName() != null ? targetUser.getFirstName() : "") %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editLname"><i class="fas fa-user"></i> Last Name</label>
                            <input type="text" id="editLname" name="lname" class="form-input" 
                                   value="<%= (targetUser.getLastName() != null ? targetUser.getLastName() : "") %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editUname"><i class="fas fa-at"></i> Username</label>
                            <input type="text" id="editUname" name="uname" class="form-input" 
                                   value="<%= (targetUser.getUserName() != null ? targetUser.getUserName() : "") %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editEmail"><i class="fas fa-envelope"></i> Email</label>
                            <input type="email" id="editEmail" name="email" class="form-input" 
                                   value="<%= (targetUser.getEmail() != null ? targetUser.getEmail() : "") %>" required>
                        </div>

                        <div class="form-group" style="grid-column: span 2;">
                            <label class="form-label" for="editPassword"><i class="fas fa-lock"></i> Password</label>
                            <div class="password-field">
                                <input type="password" id="editPassword" name="pass" class="form-input" 
                                       placeholder="Leave blank to keep current password">
                                <button type="button" class="password-toggle" id="passwordToggle">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                            <small class="input-hint"><i class="fas fa-info-circle"></i> Leave blank if you do not want to change the password.</small>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editType"><i class="fas fa-user-tag"></i> User Type</label>
                            <select id="editType" name="type" class="form-input" required>
                                <option value="student" <%= ("student".equalsIgnoreCase(targetUser.getType()) ? "selected" : "") %>>Student</option>
                                <option value="lecture" <%= ("lecture".equalsIgnoreCase(targetUser.getType()) ? "selected" : "") %>>Lecturer</option>
                                <option value="admin" <%= ("admin".equalsIgnoreCase(targetUser.getType()) ? "selected" : "") %>>Administrator</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editContact"><i class="fas fa-phone"></i> Contact Number</label>
                            <input type="tel" id="editContact" name="contactno" class="form-input" 
                                   value="<%= (targetUser.getContact() != null ? targetUser.getContact() : "") %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editCity"><i class="fas fa-city"></i> City</label>
                            <input type="text" id="editCity" name="city" class="form-input" 
                                   value="<%= (targetUser.getCity() != null ? targetUser.getCity() : "") %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="editAddress"><i class="fas fa-map-marker-alt"></i> Address</label>
                            <input type="text" id="editAddress" name="address" class="form-input" 
                                   value="<%= (targetUser.getAddress() != null ? targetUser.getAddress() : "") %>">
                        </div>

                        <div class="form-group" id="courseField" style="grid-column: span 2; <%= ("lecture".equalsIgnoreCase(targetUser.getType()) ? "" : "display: none;") %>">
                            <label class="form-label" for="editCourseName"><i class="fas fa-book"></i> Course Assignment</label>
                            <select id="editCourseName" name="course_name" class="form-input">
                                <option value="">-- No Course Assignment --</option>
                                <% if (editPageCourses != null) {
                                       for (String course : editPageCourses) {
                                           if (course != null && !course.trim().isEmpty()) {
                                %>
                                <option value="<%= course %>" <%= (currentCourseName != null && currentCourseName.equalsIgnoreCase(course)) ? "selected" : "" %>><%= course %></option>
                                <%         }
                                       }
                                   }
                                %>
                            </select>
                            <small class="input-hint"><i class="fas fa-info-circle"></i> Only applicable for lecturers.</small>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="btn btn-outline" id="cancelEditBtn">
                            <i class="fas fa-times"></i>
                            Cancel
                        </button>
                        <button type="button" class="btn btn-secondary" id="resetBtn">
                            <i class="fas fa-redo"></i>
                            Reset
                        </button>
                        <button type="submit" class="btn btn-primary" id="saveBtn">
                            <i class="fas fa-save"></i>
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </section>
        <% } %>
    </main>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<!-- JavaScript for enhanced functionality -->
<script>
    // Store original form values
    let originalFormValues = {};
    
    // Initialize when page loads
    document.addEventListener('DOMContentLoaded', function() {
        setupFormFunctionality();
        setupUserTypeChangeListener();
        setupPasswordToggle();
        storeOriginalValues();
    });
    
    // Store original form values
    function storeOriginalValues() {
        const form = document.getElementById('editUserForm');
        if (form) {
            const inputs = form.querySelectorAll('input, select');
            inputs.forEach(input => {
                if (input.type !== 'submit' && input.type !== 'button') {
                    originalFormValues[input.name || input.id] = input.value;
                }
            });
        }
    }
    
    // Setup form functionality
    function setupFormFunctionality() {
        // Cancel button
        const cancelBtn = document.getElementById('cancelEditBtn');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', function(e) {
                e.preventDefault();
                if (confirm('Are you sure you want to cancel? Any unsaved changes will be lost.')) {
                    window.location.href = '<%= backLink %>';
                }
            });
        }
        
        // Reset button
        const resetBtn = document.getElementById('resetBtn');
        if (resetBtn) {
            resetBtn.addEventListener('click', function(e) {
                e.preventDefault();
                resetForm();
            });
        }
        
        // Save button - form validation before submission
        const saveBtn = document.getElementById('saveBtn');
        if (saveBtn) {
            saveBtn.addEventListener('click', function(e) {
                if (!validateForm()) {
                    e.preventDefault();
                    alert('Please fill in all required fields correctly.');
                    return false;
                }
                return true;
            });
        }
    }
    
    // Setup user type change listener to show/hide course field
    function setupUserTypeChangeListener() {
        const userTypeSelect = document.getElementById('editType');
        const courseField = document.getElementById('courseField');
        
        if (userTypeSelect && courseField) {
            userTypeSelect.addEventListener('change', function() {
                if (this.value === 'lecture') {
                    courseField.style.display = 'block';
                } else {
                    courseField.style.display = 'none';
                    // Clear course selection when not a lecturer
                    const courseSelect = document.getElementById('editCourseName');
                    if (courseSelect) {
                        courseSelect.value = '';
                    }
                }
            });
        }
    }
    
    // Setup password toggle visibility
    function setupPasswordToggle() {
        const passwordToggle = document.getElementById('passwordToggle');
        const passwordField = document.getElementById('editPassword');
        
        if (passwordToggle && passwordField) {
            passwordToggle.addEventListener('click', function() {
                if (passwordField.type === 'password') {
                    passwordField.type = 'text';
                    this.innerHTML = '<i class="fas fa-eye-slash"></i>';
                } else {
                    passwordField.type = 'password';
                    this.innerHTML = '<i class="fas fa-eye"></i>';
                }
            });
        }
    }
    
    // Reset form to original values
    function resetForm() {
        if (confirm('Are you sure you want to reset the form? All changes will be lost.')) {
            const form = document.getElementById('editUserForm');
            if (form) {
                // Restore original values
                for (const [name, value] of Object.entries(originalFormValues)) {
                    const input = form.querySelector(`[name="${name}"]`) || document.getElementById(name);
                    if (input) {
                        input.value = value;
                        
                        // Trigger change event for select elements
                        if (input.tagName === 'SELECT') {
                            input.dispatchEvent(new Event('change'));
                        }
                    }
                }
                
                // Clear password field
                const passwordField = document.getElementById('editPassword');
                if (passwordField) {
                    passwordField.value = '';
                }
                
                alert('Form has been reset to original values.');
            }
        }
    }
    
    // Validate entire form
        function validateForm() {
            const form = document.getElementById('editUserForm');
            const requiredFields = form.querySelectorAll('[required]');
            let isValid = true;

            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    field.classList.add('error');
                    isValid = false;
                } else {
                    field.classList.remove('error');
                }
            });

            // Email regex
            const emailField = form.querySelector('[name="email"]');
            if (emailField && emailField.value) {
                const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!re.test(emailField.value)) isValid = false;
            }

            // Password length check if provided
            const passField = form.querySelector('[name="pass"]');
            if (passField && passField.value && passField.value.length < 6) isValid = false;

            return isValid;
        }

</script>

<style>
    .form-input.error {
        border-color: #dc3545 !important;
        box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25) !important;
    }
</style>

<%-- Add auto-close functionality for alert messages --%>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Auto-close alert messages after 5 seconds
    const alerts = document.querySelectorAll('.alert');
    
    alerts.forEach(alert => {
        // Add close button to alerts
        const closeButton = document.createElement('button');
        closeButton.innerHTML = '&times;';
        closeButton.className = 'alert-close-btn';
        closeButton.style.cssText = `
            background: none;
            border: none;
            font-size: 20px;
            font-weight: bold;
            cursor: pointer;
            color: inherit;
            opacity: 0.7;
            margin-left: auto;
            padding: 0 5px;
        `;
        closeButton.addEventListener('click', function() {
            closeAlert(alert);
        });
        alert.appendChild(closeButton);
        
        // Auto-close after 5 seconds
        setTimeout(() => {
            closeAlert(alert);
        }, 5000);
    });
    
    // Function to close alert with fade-out animation
    function closeAlert(alertElement) {
        if (alertElement && alertElement.parentElement) {
            alertElement.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
            alertElement.style.opacity = '0';
            alertElement.style.transform = 'translateY(-10px)';
            setTimeout(() => {
                if (alertElement.parentElement) {
                    alertElement.remove();
                }
            }, 300);
        }
    }
});

// Also close alerts when clicking anywhere outside
document.addEventListener('click', function(event) {
    if (!event.target.closest('.alert') && !event.target.closest('.alert-close-btn')) {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            closeAlert(alert);
        });
    }
});
</script>

<%-- Add CSS for close button hover effect --%>
<style>
.alert-close-btn:hover {
    opacity: 1 !important;
    color: #dc2626 !important;
}
</style>
