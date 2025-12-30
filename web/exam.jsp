<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.Exams"%>
<%
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
%>
<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

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
            position: fixed; /* Changed from sticky to fixed */
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
            padding: var(--spacing-xl);
            overflow-y: auto;
            background: transparent;
            margin-left: 180px; /* Add this to push content right */
            min-height: 100vh;
        }

        /* Responsive Design - Adjust for mobile */
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: static; /* Back to static on mobile */
            }

            .content-area,
            .main-content {
                margin-left: 0; /* Remove margin on mobile */
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
        
        /* Main Content Area */
        .content-area {
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
        
        /* Fixed Bottom Timer & Progress Bar */
        .fixed-bottom-panel {
            position: fixed;
            bottom: 0;
            left: 0;
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
            margin-bottom: 140px; /* Space for fixed bottom panel */
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
        
        /* Syntax Highlighting */
        .code-keyword { color: #f472b6; }
        .code-function { color: #34d399; }
        .code-string { color: #fbbf24; }
        .code-number { color: #a78bfa; }
        .code-comment { color: var(--dark-gray); font-style: italic; }
        .code-operator { color: #f472b6; }
        
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
 /* SUBMIT SECTION - Professional Design */
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

/* Responsive Design */
@media (max-width: 768px) {
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
}

@media (max-width: 480px) {
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
}
        .note {
            color: var(--dark-gray);
            font-size: 13px;
            max-width: 500px;
            font-weight: 500;
            text-align: center;
            margin-bottom: var(--spacing-md);
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

        .action-btn {
            background: var(--primary-blue);
            color: var(--white);
            padding: 10px 15px;
            border-radius: var(--radius-sm);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: var(--spacing-sm);
            transition: background-color var(--transition-fast);
        }

        .action-btn:hover {
            background: var(--secondary-blue);
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .exam-wrapper {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                height: auto;
                position: static;
            }
            
            .sidebar-background {
                padding: var(--spacing-md);
            }
            
            .sidebar-header {
                padding: var(--spacing-lg) var(--spacing-md);
            }
            
            .left-menu {
                display: flex;
                overflow-x: auto;
                padding: var(--spacing-sm) 0;
                gap: var(--spacing-sm);
            }
            
            .left-menu a {
                flex-direction: column;
                padding: var(--spacing-sm);
                min-width: 80px;
                text-align: center;
                border-left: none;
                border-bottom: 3px solid transparent;
                font-size: 12px;
            }
            
            .left-menu a.active {
                border-left: none;
                border-bottom-color: var(--white);
            }
            
            .left-menu a:hover {
                border-left: none;
                border-bottom-color: var(--accent-blue);
            }
            
            .content-area {
                margin-left: 0;
                padding: var(--spacing-md);
                padding-bottom: 180px;
            }
            
            .fixed-bottom-panel {
                left: 0;
            }
            
            .timer-progress-wrapper {
                flex-direction: column;
                gap: var(--spacing-md);
            }
            
            .progress-section {
                max-width: 100%;
            }
            
            .page-header,
            .exam-header {
                flex-direction: column;
                gap: var(--spacing-md);
                text-align: center;
            }
            
            .timer-container {
                align-items: center;
                width: 100%;
            }
            
            .timer-progress-group {
                flex-direction: column;
                width: 100%;
                gap: var(--spacing-md);
            }
            
            .progress-container {
                min-width: 100%;
            }
            
            .submit-inner {
                flex-direction: column;
                gap: var(--spacing-md);
                text-align: center;
            }
            
            .submit-btn {
                width: 100%;
            }
            
            .result-grid {
                grid-template-columns: 1fr;
            }
            
            .question-header {
                flex-direction: column;
                text-align: center;
            }
            
            .info-item {
                flex-direction: column;
                align-items: flex-start;
                gap: var(--spacing-sm);
            }
            
            .info-tag {
                width: 100%;
                margin-right: 0;
                min-width: auto;
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
            
            .submit-inner {
                padding: var(--spacing-md) var(--spacing-lg);
            }
            
            .badge-time {
                min-width: 70px;
                font-size: 12px;
            }
        }
        
        @media (min-width: 1440px) {
            .content-area {
                max-width: calc(100% - 250px);
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
        
        /* Utility Classes */
        .text-center { text-align: center; }
        .mt-1 { margin-top: var(--spacing-sm); }
        .mt-2 { margin-top: var(--spacing-md); }
        .mt-3 { margin-top: var(--spacing-lg); }
        .mb-1 { margin-bottom: var(--spacing-sm); }
        .mb-2 { margin-bottom: var(--spacing-md); }
        .mb-3 { margin-bottom: var(--spacing-lg); }
        
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
  margin-bottom: var(--spacing-xl);
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
  font-size: 11px;
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
  font-size: 13px;
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
  font-size: 14px;
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
  font-size: 14px;
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

/* Responsive Design */
@media (max-width: 768px) {
  .progress-float-btn {
    bottom: 80px;
    right: 20px;
    width: 50px;
    height: 50px;
    font-size: 18px;
  }
  
  .modal-content {
    margin: var(--spacing-md);
    width: auto;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .modal-footer {
    flex-direction: column;
  }
}

@media (max-width: 480px) {
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

/* Responsive Design */
@media (max-width: 768px) {
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
}

@media (max-width: 480px) {
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
}

/* Timer warning states */
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

/* Add these styles to your CSS section */

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
    background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
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

/* Badge styles for timer */
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

.timer-badge.warning {
    background: linear-gradient(135deg, #f59e0b, #d97706);
}

.timer-badge.critical {
    background: linear-gradient(135deg, #dc2626, #b91c1c);
}

.timer-badge.expired {
    background: linear-gradient(135deg, #6b7280, #4b5563);
}
</style>

<div class="exam-wrapper">
  <!--  SIDEBAR  -->
  <aside class="sidebar">
    <div class="sidebar-header">
        <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
    </div>
    <nav class="sidebar-nav">
      <div class="left-menu">
        <a class="nav-item" href="std-page.jsp?pgprt=0"><i class="fas fa-user"></i><span>Profile</span></a>
        <a class="nav-item active" href="std-page.jsp?pgprt=1"><i class="fas fa-file-alt"></i><span>Exams</span></a>
        <a class="nav-item" href="std-page.jsp?pgprt=2"><i class="fas fa-chart-line"></i><span>Results</span></a>
      </div>
    </nav>
  </aside>

  <!--  MAIN CONTENT  -->
  <main class="content-area">
  <% if ("1".equals(String.valueOf(session.getAttribute("examStarted")))) { %>
    <!--  EXAM ACTIVE  -->
    <div class="page-header">
      <div class="page-title"><i class="fas fa-file-alt"></i> <%= request.getParameter("coursename")!=null?request.getParameter("coursename"):"Selected Course" %> Exam</div>
    </div>

    <%
      ArrayList<Questions> questionsList = pDAO.getQuestions(request.getParameter("coursename"),20);
      int totalQ = questionsList.size();
    %>
    <form id="myform" action="controller.jsp" method="post">
      <input type="hidden" name="page" value="exams">
      <input type="hidden" name="operation" value="submitted">
      <input type="hidden" name="size" value="<%= totalQ %>">
      <input type="hidden" name="totalmarks" value="<%= pDAO.getTotalMarksByName(request.getParameter("coursename")) %>">

      <div class="questions-container">
      <% for (int i=0;i<totalQ;i++){
           Questions q = questionsList.get(i);
           boolean isMultiTwo=false;
           try{
             String qt=q.getQuestion().toLowerCase();
             isMultiTwo=qt.contains("select two")||qt.contains("choose two")||qt.contains("pick two")||qt.contains("multiple answers")||qt.contains("two options");
           }catch(Exception e){isMultiTwo=false;}

           String fullQuestion=q.getQuestion(),questionPart="",codePart="";
           if(fullQuestion.contains("```")){
               String[] parts=fullQuestion.split("```");
               if(parts.length>=2){questionPart=parts[0].trim();codePart=parts[1].trim();}
               else{questionPart=fullQuestion.replace("```","").trim();}
           }else{
               boolean isCodeQuestion=fullQuestion.contains("def ")||fullQuestion.contains("function ")||fullQuestion.contains("public ")||fullQuestion.contains("class ")||
                                      fullQuestion.contains("print(")||fullQuestion.contains("console.")||fullQuestion.contains("<?php")||fullQuestion.contains("import ")||
                                      fullQuestion.contains("int ")||fullQuestion.contains("String ")||fullQuestion.contains("printf(")||fullQuestion.contains("cout ");
               if(isCodeQuestion){codePart=fullQuestion;questionPart="What is the output/result of this code?";}
               else{questionPart=fullQuestion;}
           }
           java.util.List<String> opts=new java.util.ArrayList<>();
           if(q.getOpt1()!=null&&!q.getOpt1().trim().isEmpty()) opts.add(q.getOpt1());
           if(q.getOpt2()!=null&&!q.getOpt2().trim().isEmpty()) opts.add(q.getOpt2());
           if(q.getOpt3()!=null&&!q.getOpt3().trim().isEmpty()) opts.add(q.getOpt3());
           if(q.getOpt4()!=null&&!q.getOpt4().trim().isEmpty()) opts.add(q.getOpt4());
      %>
        <div class="question-card" data-qindex="<%= i %>">
          <div class="question-header">
            <div class="question-label"><%= i+1 %></div>
            <div class="question-content">
              <% if(!questionPart.isEmpty()&&!questionPart.equals("What is the output/result of this code?")){ %><p class="question-text"><%= questionPart %></p><% } %>
              <% if(!codePart.isEmpty()){ %>
                <div class="code-question-indicator"><i class="fas fa-code"></i><strong>Code Analysis Question</strong></div>
                <div class="code-snippet"><div class="code-header"><i class="fas fa-code"></i><span>Code to Analyze</span></div><pre><%= codePart %></pre></div>
              <% } %>
            </div>
          </div>
          <div class="answers" data-max-select="<%= isMultiTwo?"2":"1" %>">
            <% if(isMultiTwo){ %><div class="multi-select-note"><i class="fas fa-check-double"></i><strong>Choose up to 2 answers</strong></div><% } %>
            <% for(int oi=0;oi<opts.size();oi++){
                 String optVal=opts.get(oi),inputId="q"+i+"o"+(oi+1);
            %>
              <div class="form-check">
                <input class="form-check-input answer-input <%= isMultiTwo?"multi":"single" %>" type="<%= isMultiTwo?"checkbox":"radio" %>" id="<%= inputId %>" name="<%= isMultiTwo?("ans"+i+"_"+oi):("ans"+i) %>" value="<%= optVal %>" data-qindex="<%= i %>">
                <label class="form-check-label" for="<%= inputId %>"><%= optVal %></label>
              </div>
            <% } %>
            <% if(isMultiTwo){ %><input type="hidden" id="ans<%= i %>-hidden" name="ans<%= i %>" value=""><% } %>
          </div>
          <input type="hidden" name="question<%= i %>" value="<%= q.getQuestion() %>">
          <input type="hidden" name="qid<%= i %>" value="<%= q.getQuestionId() %>">
          <input type="hidden" name="qtype<%= i %>" value="<%= isMultiTwo?"multi2":"single" %>">
        </div>
      <% } %>
      </div>

      <!--  FLOATING PROGRESS BUTTON  -->
      <button type="button" id="progressFloatBtn" class="progress-float-btn" title="Exam Progress">
        <i class="fas fa-chart-pie"></i><span class="float-counter" id="floatCounter">0/<%= totalQ %></span>
      </button>

      <!--  PROGRESS / SUBMIT MODAL  -->
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

      <!--  SUBMIT SECTION  -->
      <div class="submit-section">
        <div class="submit-card">
          <div class="submit-header"><i class="fas fa-flag-checkered"></i><span>Ready to Submit</span></div>
          <div class="submit-content">
            <div class="warning-box">
              <div class="warning-icon"><i class="fas fa-exclamation-triangle"></i></div>
              <div class="warning-text"><strong>Final Review Required</strong><p>Unanswered questions will be marked as incorrect. Please review all answers before submission.</p></div>
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

      <!--  FIXED BOTTOM PANEL  -->
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

    <!--  SCRIPT BLOCK  -->
    <script>
    /* --- TIMER --- */
    (function(){
      document.addEventListener('DOMContentLoaded',function(){
        var timerEl=document.getElementById('remainingTime');
        if(!timerEl){console.warn('Timer element not found, timer disabled');return;}
        var examDuration=<%= pDAO.getExamDuration(request.getParameter("coursename")) %>; // minutes
        var timeInSeconds=examDuration>0?examDuration*60:120*60; // fallback 120 min
        var time=timeInSeconds;
        var formEl=document.getElementById('myform');
        function fmt(n){return String(n).padStart(2,'0');}
        timerEl.textContent=fmt(Math.floor(time/60))+':'+fmt(time%60);
        var tick=setInterval(function(){
          time--;
          if(time<=0){clearInterval(tick);timerEl.textContent="00:00";timerEl.classList.add('expired');
            document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
              var qindex=box.closest('.question-card').getAttribute('data-qindex');
              if(qindex)updateHiddenForMulti(qindex);
            });
            window.onbeforeunload=null;if(formEl)formEl.submit();return;
          }
          timerEl.textContent=fmt(Math.floor(time/60))+':'+fmt(time%60);
          timerEl.classList.remove('warning','critical');
          if(time<300)timerEl.classList.add('warning');
          if(time<60)timerEl.classList.add('critical');
        },1000);
      });
    })();

    /* --- MULTI-SELECT HIDDEN FIELD --- */
    function updateHiddenForMulti(qindex){
      var box=document.querySelector('.question-card[data-qindex="'+qindex+'"] .answers');
      if(!box)return;
      var selectedValues=[];
      box.querySelectorAll('input.multi:checked').forEach(function(ch){selectedValues.push(ch.value);});
      var hidden=document.getElementById('ans'+qindex+'-hidden');
      if(hidden){hidden.value=selectedValues.join('|');}
    }

    /* --- ANSWER SELECTION & PROGRESS --- */
    var dirty=false;
    document.addEventListener('change',function(e){
      if(!e.target.classList||!e.target.classList.contains('answer-input'))return;
      var wrapper=e.target.closest('.answers');
      if(!wrapper)return;
      var maxSel=parseInt(wrapper.getAttribute('data-max-select')||'1',10);
      if(e.target.classList.contains('multi')){
        var checkedBoxes=wrapper.querySelectorAll('input.multi:checked');
        if(checkedBoxes.length>maxSel){e.target.checked=false;alert('You can only select up to '+maxSel+' options for this question.');return;}
        var qindex=e.target.getAttribute('data-qindex');
        updateHiddenForMulti(qindex);
      }
      document.querySelectorAll('.form-check').forEach(function(c){c.classList.remove('selected');});
      document.querySelectorAll('.answer-input:checked').forEach(function(inp){var fc=inp.closest('.form-check');if(fc)fc.classList.add('selected');});
      updateProgress();dirty=true;
    });

    function updateProgress(){
      var cards=document.querySelectorAll('.question-card');
      var answered=0;
      cards.forEach(function(card){
        var box=card.querySelector('.answers');
        if(!box)return;
        var maxSel=parseInt(box.getAttribute('data-max-select')||'1',10);
        if(maxSel===1){if(box.querySelector('input.single:checked'))answered++;}
        else{if(box.querySelectorAll('input.multi:checked').length>=1)answered++;}
      });
      var total=cards.length;
      var pct=total?Math.round((answered/total)*100):0;
      document.getElementById('progressBar').style.width=pct+'%';
      document.getElementById('progressLabel').textContent=pct+'%';
      document.getElementById('submitAnswered').textContent=answered;
      document.getElementById('submitUnanswered').textContent=total-answered;
    }
    updateProgress();

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

    /* --- SUBMIT BUTTON --- */
    document.getElementById('submitBtn').addEventListener('click',function(){
      document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
        var qindex=box.closest('.question-card').getAttribute('data-qindex');
        updateHiddenForMulti(qindex);
      });
      var totalQuestions=<%= totalQ %>;
      var answeredQuestions=0;
      document.querySelectorAll('.question-card').forEach(function(card){
        var box=card.querySelector('.answers');
        if(!box)return;
        var maxSel=parseInt(box.getAttribute('data-max-select')||'1',10);
        if(maxSel===1){if(box.querySelector('input.single:checked'))answeredQuestions++;}
        else{if(box.querySelectorAll('input.multi:checked').length>=1)answeredQuestions++;}
      });
      if(answeredQuestions<totalQuestions){
        var unanswered=totalQuestions-answeredQuestions;
        if(!confirm("You have "+unanswered+" unanswered question"+(unanswered>1?"s":"")+". Submit anyway?"))return;
      }
      if(confirm("Are you sure you want to submit your exam? This action cannot be undone.")){
        window.onbeforeunload=null;
        var btn=this;
        btn.disabled=true;btn.classList.add('loading');
        setTimeout(function(){document.getElementById('myform').submit();},500);
      }
    });

    /* --- FLOATING PROGRESS BUTTON & MODAL --- */
    document.addEventListener('DOMContentLoaded',function(){
      var floatBtn=document.getElementById('progressFloatBtn');
      var modal=document.getElementById('progressModal');
      var closeModal=document.querySelectorAll('.close-modal');
      var modalSubmitBtn=document.getElementById('modalSubmitBtn');
      var mainSubmitBtn=document.getElementById('submitBtn');
      function updateFloatingCounter(){
        var total=<%= totalQ %>;
        var answered=document.querySelectorAll('.answer-input:checked').length;
        document.getElementById('floatCounter').textContent=answered+'/'+total;
        document.getElementById('modalAnswered').textContent=answered;
        document.getElementById('modalUnanswered').textContent=total-answered;
        document.getElementById('modalProgressText').textContent=answered+' / '+total;
        var percentage=total>0?Math.round((answered/total)*100):0;
        document.getElementById('modalProgressBar').style.width=percentage+'%';
        document.querySelector('.progress-percent').textContent=percentage+'%';
        var circumference=2*Math.PI*34;
        var offset=circumference-(percentage/100)*circumference;
        document.querySelector('.progress-ring-progress').style.strokeDashoffset=offset;
      }
      floatBtn.addEventListener('click',function(){modal.classList.add('active');updateFloatingCounter();});
      closeModal.forEach(function(btn){btn.addEventListener('click',function(){modal.classList.remove('active');});});
      modal.addEventListener('click',function(e){if(e.target===modal)modal.classList.remove('active');});
      modalSubmitBtn.addEventListener('click',function(){modal.classList.remove('active');mainSubmitBtn.click();});
      document.addEventListener('change',updateFloatingCounter);
      updateFloatingCounter();
    });
    </script>

  <% } else if ("1".equals(request.getParameter("showresult"))) {
       Exams result = pDAO.getResultByExamId(Integer.parseInt(request.getParameter("eid")));
  %>
    <!--  RESULTS  -->
    <div class="page-header">
      <div class="page-title"><i class="fas fa-chart-line"></i> Exam Result</div>
      <div class="stats-badge"><i class="fas fa-graduation-cap"></i> <%= result.getStatus() %></div>
    </div>
    <div class="result-card">
      <div class="result-grid">
        <div class="result-item"><strong><i class="fas fa-calendar-alt"></i> Exam Date</strong><div class="result-value"><%= result.getDate() %></div></div>
        <div class="result-item"><strong><i class="fas fa-book"></i> Course Name</strong><div class="result-value"><%= result.getcName() %></div></div>
        <div class="result-item"><strong><i class="fas fa-clock"></i> Start Time</strong><div class="result-value"><%= result.getStartTime() %></div></div>
        <div class="result-item"><strong><i class="fas fa-clock"></i> End Time</strong><div class="result-value"><%= result.getEndTime() %></div></div>
        <div class="result-item"><strong><i class="fas fa-star"></i> Obtained Marks</strong><div class="result-value"><%= result.getObtMarks() %></div></div>
        <div class="result-item"><strong><i class="fas fa-star-half-alt"></i> Total Marks</strong><div class="result-value"><%= result.gettMarks() %></div></div>
        <div class="result-item">
          <strong><i class="fas fa-flag"></i> Result Status</strong>
          <div class="result-value <%= result.getStatus().equalsIgnoreCase("Pass")?"status-pass":"status-fail" %>">
            <i class="fas <%= result.getStatus().equalsIgnoreCase("Pass")?"fa-check-circle":"fa-times-circle" %>"></i> <%= result.getStatus() %>
          </div>
        </div>
        <div class="result-item">
          <strong><i class="fas fa-chart-pie"></i> Percentage</strong>
          <div class="result-value">
            <% double percentage=0;if(result.gettMarks()>0)percentage=(double)result.getObtMarks()/result.gettMarks()*100; %>
            <span class="percentage-badge"><%= String.format("%.1f",percentage) %>%</span>
          </div>
        </div>
      </div>
      <div style="text-align: center; margin-top: 20px;">
        <a href="std-page.jsp?pgprt=2&eid=<%= result.getExamId() %>" class="action-btn">
          <i class="fas fa-eye"></i>
          View
        </a>
      </div>
    </div>

  <% } else { %>
    <!--  COURSE PICKER  -->
    <div class="page-header">
      <div class="page-title"><i class="fas fa-pencil-alt"></i> Start New Exam</div>
      <div class="stats-badge"><i class="fas fa-play-circle"></i> Ready to Start</div>
    </div>
    <div class="course-card">
      <form action="controller.jsp" method="post">
        <input type="hidden" name="page" value="exams">
        <input type="hidden" name="operation" value="startexam">
        <label class="form-label"><i class="fas fa-book"></i> Select Course</label>
        <select name="coursename" class="form-select" required>
          <option value="">Choose a course...</option>
          <% ArrayList<String> courseList=pDAO.getAllCourseNames();
             for(String course:courseList){ %>
            <option value="<%= course %>"><%= course %></option>
          <% } %>
        </select>
        <button type="submit" class="start-exam-btn"><i class="fas fa-play"></i> Start Exam</button>
      </form>
    </div>
  <% } %>
  </main>
</div>