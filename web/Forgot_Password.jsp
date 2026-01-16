<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Online Assessment System</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>

<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
%>

<!-- Include Header -->
<jsp:include page="header.jsp" />

<style>
    /* Override body background for forgot password page */
    body {
        background-color: #f8fafc;
    }
    
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
    }
    
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        line-height: 1.5;
        background-color: var(--light-gray);
        min-height: 100vh;
    }
    
    /* Forgot Password Container */
    .forgot-password-container {
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
        box-shadow: var(--shadow-lg);
        border-right: 1px solid rgba(255, 255, 255, 0.1);
        overflow-y: auto;
        scrollbar-width: thin;
        scrollbar-color: rgba(255, 255, 255, 0.3) transparent;
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
    
    /* Main Content Area */
    .main-content {
        flex: 1;
        padding: var(--spacing-xl);
        overflow-y: auto;
        background: transparent;
        margin-left: 200px;
        min-height: 100vh;
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
    
    /* Forgot Password Card */
    .forgot-password-card {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-lg);
        border: 1px solid var(--border-color);
        max-width: 500px;
        margin: 0 auto;
        overflow: hidden;
        transition: transform var(--transition-normal), box-shadow var(--transition-normal);
    }
    
    .forgot-password-card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-xl);
    }
    
    .card-header {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: var(--spacing-lg);
        text-align: center;
        position: relative;
        overflow: hidden;
    }
    
    .card-header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%);
        animation: shimmer 3s infinite;
    }
    
    @keyframes shimmer {
        0% { transform: translateX(-100%); }
        100% { transform: translateX(100%); }
    }
    
    .card-header h2 {
        font-size: 20px;
        font-weight: 600;
        margin: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-md);
        position: relative;
        z-index: 1;
    }
    
    .card-header i {
        font-size: 24px;
        color: var(--accent-blue-light);
    }
    
    /* Card Content */
    .card-content {
        padding: var(--spacing-2xl);
    }
    
    /* Form Styles */
    .forgot-form {
        display: flex;
        flex-direction: column;
        gap: var(--spacing-lg);
    }
    
    .form-group {
        display: flex;
        flex-direction: column;
        gap: var(--spacing-sm);
    }
    
    .form-label {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .form-label i {
        color: var(--accent-blue);
        width: 20px;
    }
    
    .form-input {
        padding: 12px 16px;
        border: 2px solid var(--medium-gray);
        border-radius: var(--radius-md);
        font-size: 15px;
        transition: all var(--transition-normal);
        background: var(--light-gray);
    }
    
    .form-input:focus {
        outline: none;
        border-color: var(--accent-blue);
        background: var(--white);
        box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
    }
    
    .form-input.error {
        border-color: var(--error);
        background: var(--error-light);
    }
    
    .form-input.success {
        border-color: var(--success);
        background: var(--success-light);
    }
    
    /* Form Steps */
    .form-step {
        display: none;
        animation: fadeIn 0.3s ease;
    }
    
    .form-step.active {
        display: block;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* Step Indicators */
    .step-indicators {
        display: flex;
        justify-content: center;
        gap: var(--spacing-md);
        margin-bottom: var(--spacing-xl);
    }
    
    .step-indicator {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .step-circle {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: var(--medium-gray);
        color: var(--dark-gray);
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 16px;
        transition: all var(--transition-normal);
        border: 3px solid transparent;
    }
    
    .step-circle.active {
        background: var(--accent-blue);
        color: var(--white);
        border-color: var(--accent-blue-light);
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25);
    }
    
    .step-circle.completed {
        background: var(--success);
        color: var(--white);
    }
    
    .step-label {
        font-size: 12px;
        font-weight: 500;
        color: var(--dark-gray);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .step-label.active {
        color: var(--accent-blue);
        font-weight: 600;
    }
    
    .step-line {
        flex: 1;
        height: 3px;
        background: var(--medium-gray);
        margin-top: 20px;
        max-width: 60px;
    }
    
    /* Info Messages */
    .info-message {
        background: var(--info-light);
        border: 1px solid var(--info);
        color: var(--text-dark);
        padding: var(--spacing-md);
        border-radius: var(--radius-md);
        margin-bottom: var(--spacing-lg);
        display: flex;
        align-items: flex-start;
        gap: var(--spacing-md);
        animation: slideIn 0.3s ease;
    }
    
    .info-message i {
        color: var(--info);
        font-size: 18px;
        margin-top: 2px;
    }
    
    .success-message {
        background: var(--success-light);
        border-color: var(--success);
    }
    
    .success-message i {
        color: var(--success);
    }
    
    .error-message {
        background: var(--error-light);
        border-color: var(--error);
    }
    
    .error-message i {
        color: var(--error);
    }
    
    @keyframes slideIn {
        from { opacity: 0; transform: translateX(-20px); }
        to { opacity: 1; transform: translateX(0); }
    }
    
    /* Form Actions */
    .form-actions {
        display: flex;
        gap: var(--spacing-md);
        margin-top: var(--spacing-xl);
        padding-top: var(--spacing-lg);
        border-top: 1px solid var(--medium-gray);
    }
    
    .form-button {
        flex: 1;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
        padding: 16px 24px;
        border-radius: var(--radius-md);
        font-size: 16px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        border: none;
        transition: all var(--transition-normal);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        min-width: 220px;
        box-sizing: border-box;
    }
    
    .btn-primary {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
    }
    
    .btn-primary:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(9, 41, 77, 0.25);
    }
    
    .btn-secondary {
        background: var(--medium-gray);
        color: var(--text-dark);
    }
    
    .btn-secondary:hover:not(:disabled) {
        background: var(--dark-gray);
        color: var(--white);
    }
    
    .btn-success {
        background: linear-gradient(90deg, var(--success), #059669);
        color: var(--white);
    }
    
    .btn-success:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(16, 185, 129, 0.25);
    }
    
    .form-button:disabled {
        opacity: 0.6;
        cursor: not-allowed;
        transform: none !important;
        box-shadow: none !important;
    }
    
    /* Back to Login Link */
    .back-to-login {
        text-align: center;
        margin-top: var(--spacing-xl);
        padding-top: var(--spacing-lg);
        border-top: 1px solid var(--medium-gray);
    }
    
    .back-to-login a {
        color: var(--accent-blue);
        text-decoration: none;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: var(--spacing-sm);
        transition: all var(--transition-normal);
    }
    
    .back-to-login a:hover {
        color: var(--secondary-blue);
        gap: var(--spacing-md);
    }
    

    
    /* Responsive Design */
    @media (max-width: 992px) {
        .sidebar {
            width: 100%;
            height: auto;
            position: static;
            padding: var(--spacing-md);
            border-right: none;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .sidebar-header {
            padding-top: var(--spacing-lg);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--spacing-md);
        }
        
        .mut-logo {
            max-height: 60px;
        }
        
        .sidebar-nav {
            padding: var(--spacing-md) 0;
        }
        
        .nav-item {
            justify-content: center;
            margin: 0 var(--spacing-md);
        }
        
        .main-content {
            margin-left: 0;
            padding: var(--spacing-md);
        }
        
        .page-header {
            flex-direction: column;
            align-items: flex-start;
            gap: var(--spacing-md);
            text-align: left;
        }
        
        .stats-badge {
            width: 100%;
            text-align: center;
        }
    }
    
    @media (max-width: 768px) {
        .sidebar {
            width: 100%;
            height: auto;
            position: static;
            padding: var(--spacing-md);
            border-right: none;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .sidebar-header {
            padding-top: var(--spacing-lg);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--spacing-md);
        }
        
        .mut-logo {
            max-height: 60px;
        }
        
        .sidebar-nav {
            padding: var(--spacing-md) 0;
        }
        
        .nav-item {
            justify-content: center;
            margin: 0 var(--spacing-md);
        }
        
        .main-content {
            margin-left: 0;
            padding: var(--spacing-md);
        }
        
        .page-header {
            flex-direction: column;
            align-items: flex-start;
            gap: var(--spacing-md);
            text-align: left;
        }
        
        .stats-badge {
            width: 100%;
            text-align: center;
        }
        
        .forgot-password-card {
            max-width: 100%;
            margin: 0;
        }
        
        .card-content {
            padding: var(--spacing-lg);
        }
        
        .form-actions {
            flex-direction: column;
            gap: var(--spacing-sm);
        }
        
        .form-button {
            width: 100%;
            margin-bottom: var(--spacing-sm);
        }
        
        .btn-secondary:last-child {
            margin-bottom: 0;
        }
        
        .step-indicators {
            flex-direction: row;
            align-items: center;
            gap: var(--spacing-sm);
            overflow-x: auto;
            padding: var(--spacing-sm 0);
            margin-bottom: var(--spacing-lg);
        }
        
        .step-indicator {
            flex-shrink: 0;
        }
        
        .step-circle {
            width: 32px;
            height: 32px;
            font-size: 14px;
        }
        
        .step-label {
            font-size: 10px;
            white-space: nowrap;
        }
        
        .step-line {
            max-width: 30px;
        }
        
        .back-to-login {
            margin-top: var(--spacing-lg);
        }
    }
    
    @media (max-width: 576px) {
        .forgot-password-container {
            flex-direction: column;
        }
        
        .main-content {
            margin-left: 0;
            padding: var(--spacing-sm);
        }
        
        .page-header {
            padding: var(--spacing-md);
        }
        
        .forgot-password-card {
            margin: 0 var(--spacing-sm);
            border-radius: var(--radius-md);
        }
        
        .card-content {
            padding: var(--spacing-md);
        }
        
        .card-header h2 {
            font-size: 18px;
        }
        
        .form-group {
            gap: var(--spacing-xs);
        }
        
        .form-label {
            font-size: 13px;
        }
        
        .form-input {
            padding: 10px 12px;
            font-size: 14px;
        }
        
        .form-button {
            padding: 12px 16px;
            font-size: 14px;
        }
        
        .step-indicators {
            gap: var(--spacing-xs);
        }
        
        .step-circle {
            width: 28px;
            height: 28px;
            font-size: 12px;
        }
        
        .step-label {
            font-size: 8px;
            max-width: 60px;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .step-line {
            max-width: 20px;
        }
        
        .info-message {
            flex-direction: column;
            align-items: flex-start;
            gap: var(--spacing-sm);
            font-size: 13px;
        }
        
        .info-message i {
            font-size: 16px;
        }
    }
    
    @media (max-width: 480px) {
        .card-content {
            padding: var(--spacing-sm);
        }
        
        .page-header {
            padding: var(--spacing-sm);
            flex-direction: column;
            gap: var(--spacing-sm);
            text-align: center;
        }
        
        .page-title {
            flex-direction: column;
            gap: var(--spacing-xs);
        }
        
        .form-input {
            padding: 8px 10px;
        }
        
        .form-button {
            padding: 10px 12px;
            font-size: 13px;
        }
        
        .password-requirements {
            padding: var(--spacing-sm);
        }
        
        .password-requirements ul {
            padding-left: var(--spacing-xs);
        }
        
        .password-requirements li {
            font-size: 11px;
        }
    }
    
    /* Extra small devices (phones, 320px and up) */
    @media (max-width: 320px) {
        .main-content {
            padding: var(--spacing-xs);
        }
        
        .card-content {
            padding: var(--spacing-xs);
        }
        
        .page-header {
            padding: var(--spacing-xs);
        }
        
        .form-actions {
            gap: var(--spacing-xs);
        }
        
        .form-button {
            padding: 8px 10px;
            font-size: 12px;
        }
    }
    
    /* Mobile Touch Targets for Better UX */
    @media (hover: none) and (pointer: coarse) {
        .form-input {
            min-height: 44px; /* Minimum touch target size */
        }
        
        .form-button {
            min-height: 44px;
            min-width: 120px;
            padding: 12px 16px;
        }
        
        .nav-item {
            min-height: 44px;
            padding: var(--spacing-md) var(--spacing-lg);
        }
        
        .step-circle {
            min-width: 44px;
            min-height: 44px;
        }
    }
</style>

<!-- Main Container -->
<div class="forgot-password-container">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
        </div>
        <nav class="sidebar-nav">
            <div class="left-menu">
                <a class="nav-item" href="login.jsp">
                    <i class="fas fa-sign-in-alt"></i>
                    <span>Login</span>
                </a>
                <a class="nav-item active" href="Forgot_Password.jsp">
                    <i class="fas fa-key"></i>
                    <span>Forgot Password</span>
                </a>
                <a class="nav-item" href="index.jsp">
                    <i class="fas fa-home"></i>
                    <span>Home</span>
                </a>
            </div>
        </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <!-- Page Header -->
        <header class="page-header">
            <div class="page-title">
                <i class="fas fa-key"></i>
                Password Recovery
            </div>
            <div class="stats-badge" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                <i class="fas fa-user-lock"></i>
                Secure Reset
            </div>
        </header>

        <!-- Forgot Password Card -->
        <div class="forgot-password-card">
            <div class="card-header">
                <h2><i class="fas fa-lock"></i> Reset Your Password</h2>
            </div>
            
            <div class="card-content">
                <!-- Step Indicators -->
                <div class="step-indicators">
                    <div class="step-indicator">
                        <div class="step-circle active">1</div>
                        <span class="step-label active">Verify Email</span>
                    </div>
                    <div class="step-line"></div>
                    <div class="step-indicator">
                        <div class="step-circle">2</div>
                        <span class="step-label">Enter Code</span>
                    </div>
                    <div class="step-line"></div>
                    <div class="step-indicator">
                        <div class="step-circle">3</div>
                        <span class="step-label">New Password</span>
                    </div>
                </div>

                <!-- Step 1: Email Verification -->
                <div class="form-step active" id="step1">
                    <div class="info-message">
                        <i class="fas fa-info-circle"></i>
                        <div>
                            <strong>Forgot your password?</strong> Enter your email address below and we'll send you a verification code to reset your password.
                        </div>
                    </div>
                    
                    <form class="forgot-form" id="emailForm">
                        <div class="form-group">
                            <label class="form-label" for="email">
                                <i class="fas fa-envelope"></i>
                                Email Address
                            </label>
                            <input type="email" 
                                   id="email" 
                                   name="email" 
                                   class="form-input" 
                                   placeholder="Enter your registered email"
                                   required
                                   onkeyup="checkEmail()">
                            <div id="emailStatus" style="display: none; margin-top: var(--spacing-xs); font-size: 13px;"></div>
                        </div>
                        
                        <div class="form-actions">
                            <button type="button" class="form-button btn-secondary" onclick="window.location.href='login.jsp'">
                                <i class="fas fa-arrow-left"></i>
                                Back to Login
                            </button>
                            <button type="submit" 
                                    id="sendCodeBtn" 
                                    class="form-button btn-primary" 
                                    disabled>
                                <i class="fas fa-paper-plane"></i>
                                Send Verification Code
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Step 2: Verification Code -->
                <div class="form-step" id="step2">
                    <div class="info-message">
                        <i class="fas fa-shield-alt"></i>
                        <div>
                            <strong>Verification code sent!</strong> Please check your email and enter the 8-character code we sent to <span id="emailDisplay" style="font-weight: 600;"></span>
                        </div>
                    </div>
                    
                    <form class="forgot-form" id="codeForm">
                        <input type="hidden" id="hiddenEmail" name="email">
                        
                        <div class="form-group">
                            <label class="form-label" for="code">
                                <i class="fas fa-key"></i>
                                Verification Code
                            </label>
                            <input type="text" 
                                   id="code" 
                                   name="code" 
                                   class="form-input" 
                                   placeholder="Enter 8-character code"
                                   maxlength="8"
                                   pattern="[A-Z0-9]{8}"
                                   required>
                            <div class="code-hint" style="font-size: 12px; color: var(--dark-gray); margin-top: var(--spacing-xs);">
                                <i class="fas fa-clock"></i> Code expires in 1 hour
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button type="button" class="form-button btn-secondary" onclick="goToStep(1)">
                                <i class="fas fa-arrow-left"></i>
                                Back
                            </button>
                            <button type="submit" class="form-button btn-primary" id="verifyCodeBtn">
                                <i class="fas fa-check-circle"></i>
                                Verify Code
                            </button>
                        </div>
                        
                        <div class="resend-code" style="text-align: center; margin-top: var(--spacing-lg);">
                            <button type="button" class="btn-text" onclick="resendCode()" id="resendBtn" style="background: none; border: none; color: var(--accent-blue); cursor: pointer;">
                                <i class="fas fa-redo"></i>
                                Resend Code
                            </button>
                            <div id="resendTimer" style="font-size: 12px; color: var(--dark-gray); margin-top: var(--spacing-xs);">
                                Resend available in <span id="countdown">60</span> seconds
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Step 3: New Password -->
                <div class="form-step" id="step3">
                    <div class="info-message success-message">
                        <i class="fas fa-check-circle"></i>
                        <div>
                            <strong>Code verified successfully!</strong> Now create a new secure password for your account.
                        </div>
                    </div>
                    
                    <form class="forgot-form" id="passwordForm">
                        <input type="hidden" id="finalEmail" name="email">
                        <input type="hidden" id="finalCode" name="code">
                        
                        <div class="form-group">
                            <label class="form-label" for="newPassword">
                                <i class="fas fa-lock"></i>
                                New Password
                            </label>
                            <input type="password" 
                                   id="newPassword" 
                                   name="newPassword" 
                                   class="form-input" 
                                   placeholder="Enter new password"
                                   required
                                   onkeyup="validatePassword()">
                            <div id="passwordStrength" style="font-size: 12px; margin-top: var(--spacing-xs);"></div>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="confirmPassword">
                                <i class="fas fa-lock"></i>
                                Confirm Password
                            </label>
                            <input type="password" 
                                   id="confirmPassword" 
                                   name="confirmPassword" 
                                   class="form-input" 
                                   placeholder="Confirm new password"
                                   required
                                   onkeyup="checkPasswordMatch()">
                            <div id="passwordMatch" style="font-size: 12px; margin-top: var(--spacing-xs);"></div>
                        </div>
                        
                        <div class="password-requirements" style="background: var(--light-gray); padding: var(--spacing-md); border-radius: var(--radius-sm); margin-bottom: var(--spacing-lg);">
                            <h4 style="font-size: 14px; margin-bottom: var(--spacing-sm); color: var(--text-dark);">
                                <i class="fas fa-shield-alt"></i> Password Requirements:
                            </h4>
                            <ul style="font-size: 12px; color: var(--dark-gray); list-style: none; padding-left: var(--spacing-sm);">
                                <li id="reqLength" style="margin-bottom: var(--spacing-xs);"><i class="fas fa-circle" style="font-size: 6px;"></i> At least 8 characters</li>
                                <li id="reqUppercase" style="margin-bottom: var(--spacing-xs);"><i class="fas fa-circle" style="font-size: 6px;"></i> One uppercase letter</li>
                                <li id="reqLowercase" style="margin-bottom: var(--spacing-xs);"><i class="fas fa-circle" style="font-size: 6px;"></i> One lowercase letter</li>
                                <li id="reqNumber" style="margin-bottom: var(--spacing-xs);"><i class="fas fa-circle" style="font-size: 6px;"></i> One number</li>
                                <li id="reqSpecial"><i class="fas fa-circle" style="font-size: 6px;"></i> One special character</li>
                            </ul>
                        </div>
                        
                        <div class="form-actions">
                            <button type="button" class="form-button btn-secondary" onclick="goToStep(2)">
                                <i class="fas fa-arrow-left"></i>
                                Back
                            </button>
                            <button type="submit" class="form-button btn-success" id="resetPasswordBtn" disabled>
                                <i class="fas fa-save"></i>
                                Reset Password
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Success Message -->
                <div class="form-step" id="step4" style="text-align: center;">
                    <div class="info-message success-message" style="margin-bottom: var(--spacing-2xl);">
                        <i class="fas fa-check-circle"></i>
                        <div>
                            <strong>Password reset successful!</strong> Your password has been updated successfully.
                        </div>
                    </div>
                    
                    <div style="font-size: 16px; color: var(--text-dark); margin-bottom: var(--spacing-xl);">
                        <i class="fas fa-thumbs-up" style="font-size: 48px; color: var(--success); margin-bottom: var(--spacing-md);"></i>
                        <p>You can now log in with your new password.</p>
                    </div>
                    
                    <div class="form-actions" style="justify-content: center;">
                        <button type="button" class="form-button btn-primary" onclick="window.location.href='login.jsp'">
                            <i class="fas fa-sign-in-alt"></i>
                            Go to Login
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Back to Login -->
        <div class="back-to-login">
            <a href="login.jsp">
                <i class="fas fa-arrow-left"></i>
                Return to Login Page
            </a>
        </div>
    </main>
</div>

<!-- Include Footer -->
<jsp:include page="footer.jsp" />

<!-- JavaScript -->
<script>
    let currentStep = 1;
    let emailVerified = false;
    let resendTimer = 60;
    let countdownInterval;
    
    // Initialize
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('emailForm').addEventListener('submit', handleEmailSubmit);
        document.getElementById('codeForm').addEventListener('submit', handleCodeSubmit);
        document.getElementById('passwordForm').addEventListener('submit', handlePasswordSubmit);
    });
    
    // Check email existence
    function checkEmail() {
        const email = document.getElementById('email').value;
        const sendCodeBtn = document.getElementById('sendCodeBtn');
        const emailStatus = document.getElementById('emailStatus');
        const emailInput = document.getElementById('email');
        
        if (!isValidEmail(email)) {
            emailStatus.style.display = 'none';
            sendCodeBtn.disabled = true;
            emailInput.classList.remove('success', 'error');
            return;
        }
        
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (this.readyState === 4) {
                if (this.status === 200) {
                    const response = this.responseText.trim();
                    console.log('Email check response:', response); // Debug log
                    console.log('Response length:', response.length); // Debug log
                    
                    if (response === 'exists') {
                        emailStatus.innerHTML = '<i class="fas fa-check-circle" style="color: var(--success);"></i> Email verified';
                        emailStatus.style.color = 'var(--success)';
                        emailInput.classList.remove('error');
                        emailInput.classList.add('success');
                        sendCodeBtn.disabled = false;
                        emailVerified = true;
                    } else {
                        emailStatus.innerHTML = '<i class="fas fa-times-circle" style="color: var(--error);"></i> Email not found in our system';
                        emailStatus.style.color = 'var(--error)';
                        emailInput.classList.remove('success');
                        emailInput.classList.add('error');
                        sendCodeBtn.disabled = true;
                        emailVerified = false;
                    }
                    emailStatus.style.display = 'block';
                } else {
                    console.error('HTTP Error:', this.status); // Debug log
                }
            }
        };
        
        xhr.open('POST', 'controller.jsp', true);
        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        xhr.send('page=forgot_password&action=check_email&email=' + encodeURIComponent(email));
    }
    
    function isValidEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }
    
    // Handle email submission
    function handleEmailSubmit(e) {
        e.preventDefault();
        const email = document.getElementById('email').value;
        const sendCodeBtn = document.getElementById('sendCodeBtn');
        
        if (!emailVerified) return;
        
        // Disable button during request
        sendCodeBtn.disabled = true;
        
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                // Re-enable button
                sendCodeBtn.disabled = false;
                
                if (this.responseText.trim() === 'success') {
                    // Store email for next steps
                    document.getElementById('hiddenEmail').value = email;
                    document.getElementById('finalEmail').value = email;
                    document.getElementById('emailDisplay').textContent = email;
                    
                    // Update step indicators
                    updateStepIndicators(2);
                    
                    // Start resend timer
                    startResendTimer();
                    
                    // Move to step 2
                    goToStep(2);
                } else {
                    showError('Failed to send verification code. Please try again.');
                }
            }
        };
        
        xhr.open('POST', 'controller.jsp', true);
        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        xhr.send('page=forgot_password&action=send_code&email=' + encodeURIComponent(email));
    }
    
    // Handle code verification
    function handleCodeSubmit(e) {
        e.preventDefault();
        const code = document.getElementById('code').value.toUpperCase();
        const email = document.getElementById('hiddenEmail').value;
        const verifyCodeBtn = document.getElementById('verifyCodeBtn');
        
        if (!code || code.length !== 8) return;
        
        // Disable button during request
        verifyCodeBtn.disabled = true;
        
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                // Re-enable button
                verifyCodeBtn.disabled = false;
                
                if (this.responseText.trim() === 'valid') {
                    // Store code for next step
                    document.getElementById('finalCode').value = code;
                    
                    // Update step indicators
                    updateStepIndicators(3);
                    
                    // Move to step 3
                    goToStep(3);
                } else {
                    showError('Invalid verification code. Please try again.');
                }
            }
        };
        
        xhr.open('POST', 'controller.jsp', true);
        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        xhr.send('page=forgot_password&action=verify_code&email=' + encodeURIComponent(email) + '&code=' + code);
    }
    
    // Handle password reset
    function handlePasswordSubmit(e) {
        e.preventDefault();
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const email = document.getElementById('finalEmail').value;
        const code = document.getElementById('finalCode').value;
        const resetPasswordBtn = document.getElementById('resetPasswordBtn');
        
        if (newPassword !== confirmPassword) {
            showError('Passwords do not match');
            return;
        }
        
        if (!validatePasswordStrength(newPassword)) return;
        
        // Disable button during request
        resetPasswordBtn.disabled = true;
        
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                // Re-enable button
                resetPasswordBtn.disabled = false;
                
                if (this.responseText.trim() === 'success') {
                    // Update step indicators
                    updateStepIndicators(4);
                    
                    // Move to success step
                    goToStep(4);
                } else {
                    showError('Failed to reset password. Please try again.');
                }
            }
        };
        
        xhr.open('POST', 'controller.jsp', true);
        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        xhr.send('page=forgot_password&action=reset_password&email=' + encodeURIComponent(email) + 
                 '&code=' + code + 
                 '&password=' + encodeURIComponent(newPassword) + 
                 '&confirm_password=' + encodeURIComponent(confirmPassword));
    }
    
    // Navigation functions
    function goToStep(step) {
        document.querySelectorAll('.form-step').forEach(el => {
            el.classList.remove('active');
        });
        document.getElementById('step' + step).classList.add('active');
        currentStep = step;
    }
    
    function updateStepIndicators(step) {
        document.querySelectorAll('.step-circle').forEach((circle, index) => {
            circle.classList.remove('active', 'completed');
            if (index + 1 < step) {
                circle.classList.add('completed');
            } else if (index + 1 === step) {
                circle.classList.add('active');
            }
        });
        
        document.querySelectorAll('.step-label').forEach((label, index) => {
            label.classList.remove('active');
            if (index + 1 === step) {
                label.classList.add('active');
            }
        });
    }
    
    // Password validation
    function validatePassword() {
        const password = document.getElementById('newPassword').value;
        const strength = document.getElementById('passwordStrength');
        const resetPasswordBtn = document.getElementById('resetPasswordBtn');
        
        const hasLength = password.length >= 8;
        const hasUpper = /[A-Z]/.test(password);
        const hasLower = /[a-z]/.test(password);
        const hasNumber = /\d/.test(password);
        const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
        
        // Update requirement indicators
        updateRequirement('reqLength', hasLength);
        updateRequirement('reqUppercase', hasUpper);
        updateRequirement('reqLowercase', hasLower);
        updateRequirement('reqNumber', hasNumber);
        updateRequirement('reqSpecial', hasSpecial);
        
        // Calculate strength
        const requirementsMet = [hasLength, hasUpper, hasLower, hasNumber, hasSpecial].filter(Boolean).length;
        
        if (requirementsMet === 0) {
            strength.textContent = '';
            strength.style.color = '';
            resetPasswordBtn.disabled = true;
        } else if (requirementsMet <= 2) {
            strength.innerHTML = '<i class="fas fa-exclamation-circle"></i> Weak password';
            strength.style.color = 'var(--error)';
            resetPasswordBtn.disabled = true;
        } else if (requirementsMet <= 4) {
            strength.innerHTML = '<i class="fas fa-check-circle"></i> Good password';
            strength.style.color = 'var(--warning)';
            resetPasswordBtn.disabled = false;
        } else {
            strength.innerHTML = '<i class="fas fa-check-circle"></i> Strong password';
            strength.style.color = 'var(--success)';
            resetPasswordBtn.disabled = false;
        }
        
        checkPasswordMatch();
    }
    
    function updateRequirement(elementId, met) {
        const element = document.getElementById(elementId);
        if (met) {
            element.innerHTML = element.innerHTML.replace('fa-circle', 'fa-check-circle');
            element.style.color = 'var(--success)';
        } else {
            element.innerHTML = element.innerHTML.replace('fa-check-circle', 'fa-circle');
            element.style.color = 'var(--dark-gray)';
        }
    }
    
    function validatePasswordStrength(password) {
        const hasLength = password.length >= 8;
        const hasUpper = /[A-Z]/.test(password);
        const hasLower = /[a-z]/.test(password);
        const hasNumber = /\d/.test(password);
        const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
        
        return hasLength && hasUpper && hasLower && hasNumber && hasSpecial;
    }
    
    function checkPasswordMatch() {
        const password = document.getElementById('newPassword').value;
        const confirm = document.getElementById('confirmPassword').value;
        const match = document.getElementById('passwordMatch');
        const resetPasswordBtn = document.getElementById('resetPasswordBtn');
        
        if (!password || !confirm) {
            match.textContent = '';
            return;
        }
        
        if (password === confirm) {
            match.innerHTML = '<i class="fas fa-check-circle"></i> Passwords match';
            match.style.color = 'var(--success)';
            if (validatePasswordStrength(password)) {
                resetPasswordBtn.disabled = false;
            }
        } else {
            match.innerHTML = '<i class="fas fa-times-circle"></i> Passwords do not match';
            match.style.color = 'var(--error)';
            resetPasswordBtn.disabled = true;
        }
    }
    
    // Resend timer functions
    function startResendTimer() {
        resendTimer = 60;
        const resendBtn = document.getElementById('resendBtn');
        const countdownEl = document.getElementById('countdown');
        const resendTimerEl = document.getElementById('resendTimer');
        
        resendBtn.disabled = true;
        resendTimerEl.style.display = 'block';
        
        clearInterval(countdownInterval);
        countdownInterval = setInterval(() => {
            resendTimer--;
            countdownEl.textContent = resendTimer;
            
            if (resendTimer <= 0) {
                clearInterval(countdownInterval);
                resendBtn.disabled = false;
                resendTimerEl.style.display = 'none';
            }
        }, 1000);
    }
    
    function resendCode() {
        const email = document.getElementById('hiddenEmail').value;
        const xhr = new XMLHttpRequest();
        
        xhr.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                if (this.responseText.trim() === 'success') {
                    showSuccess('Verification code resent successfully!');
                    startResendTimer();
                }
            }
        };
        
        xhr.open('POST', 'controller.jsp', true);
        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        xhr.send('page=forgot_password&action=resend_code&email=' + encodeURIComponent(email));
    }
    
    // Helper functions
    function showError(message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'info-message error-message';
        errorDiv.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
        errorDiv.style.marginTop = 'var(--spacing-md)';
        
        // Remove any existing error messages
        document.querySelectorAll('.error-message').forEach(el => el.remove());
        
        // Insert error message
        const currentStep = document.querySelector('.form-step.active');
        currentStep.insertBefore(errorDiv, currentStep.firstChild);
        
        // Auto-remove after 5 seconds
        setTimeout(() => errorDiv.remove(), 5000);
    }
    
    function showSuccess(message) {
        const successDiv = document.createElement('div');
        successDiv.className = 'info-message success-message';
        successDiv.innerHTML = `<i class="fas fa-check-circle"></i> ${message}`;
        successDiv.style.marginTop = 'var(--spacing-md)';
        
        // Remove any existing success messages
        document.querySelectorAll('.success-message').forEach(el => {
            if (el.parentElement === successDiv.parentElement) el.remove();
        });
        
        // Insert success message
        const currentStep = document.querySelector('.form-step.active');
        currentStep.insertBefore(successDiv, currentStep.firstChild);
        
        // Auto-remove after 5 seconds
        setTimeout(() => successDiv.remove(), 5000);
    }
</script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>