<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.RearrangeItem"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>

<!-- Font Awesome Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<%!
    private String[] parseSimpleJsonArray(String json) {
        if (json == null) return new String[0];
        json = json.trim();
        if (json.length() < 2) return new String[0];
        if ("[]".equals(json)) return new String[0];
        if (json.startsWith("[") && json.endsWith("]")) {
            json = json.substring(1, json.length() - 1).trim();
        }
        if (json.isEmpty()) return new String[0];

        // Expecting a simple JSON array of strings produced by DatabaseClass.toJsonArray
        // Example: ["A","B"]
        String[] parts = json.split("(?<=\"),(?=\")");
        for (int i = 0; i < parts.length; i++) {
            String s = parts[i].trim();
            if (s.startsWith("\"") && s.endsWith("\"")) {
                s = s.substring(1, s.length() - 1);
            }
            s = s.replace("\\\\\"", "\"");
            s = s.replace("\\\\n", "\n");
            s = s.replace("\\\\r", "\r");
            s = s.replace("\\\\t", "\t");
            s = s.replace("\\\\\\\\", "\\");
            parts[i] = s;
        }
        return parts;
    }

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

<%
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

// Generate new CSRF token for each page load
String csrfToken = java.util.UUID.randomUUID().toString();
session.setAttribute("csrf_token", csrfToken);

String courseName = request.getParameter("coursename");
String searchTerm = request.getParameter("search");
String questionTypeFilter = request.getParameter("type");
String sortBy = request.getParameter("sort");

// Use enhanced getAllQuestions method with search, filters, and descending order
ArrayList list = (courseName != null) ? pDAO.getAllQuestions(courseName, searchTerm, questionTypeFilter, sortBy) : new ArrayList();
%>

<!-- Your existing CSS -->
<style>
    :root {
        --primary-blue: #09294d;
        --secondary-blue: #1a3d6d;
        --accent-blue: #4a90e2;
        --white: #ffffff;
        --light-gray: #f8fafc;
        --medium-gray: #e2e8f0;
        --dark-gray: #64748b;
        --text-dark: #1e293b;
        --success: #059669;
        --warning: #d97706;
        --error: #dc2626;
        --info: #0891b2;
        --radius-md: 8px;
        --radius-sm: 4px;
        --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
        --spacing-md: 16px;
        --spacing-lg: 24px;
    }

    body {
        font-family: 'Inter', -apple-system, sans-serif;
        background-color: var(--light-gray);
        color: var(--text-dark);
        margin: 0;
    }

    .dashboard-container { display: flex; min-height: 100vh; }
    
    .sidebar {
        width: 200px;
        background: linear-gradient(180deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        position: sticky;
        top: 0;
        height: 100vh;
    }

    .sidebar-header { padding: 32px 24px; text-align: center; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
    .mut-logo { max-height: 120px; width: auto; filter: brightness(0) invert(1); }
    .sidebar-nav { padding: 24px 0; }
    .nav-item {
        display: flex; align-items: center; gap: 16px; padding: 16px 24px;
        color: rgba(255, 255, 255, 0.8); text-decoration: none; transition: 0.2s;
    }
    .nav-item:hover, .nav-item.active { background: rgba(255, 255, 255, 0.1); color: var(--white); }
    .nav-item.active { border-left: 4px solid var(--white); }
    .nav-item h2 { font-size: 14px; font-weight: 500; margin: 0; }

    .main-content { flex: 1; padding: var(--spacing-lg); overflow-y: auto; }

    .page-header {
        background: var(--white); border-radius: var(--radius-md); padding: var(--spacing-lg);
        margin-bottom: var(--spacing-lg); display: flex; justify-content: space-between;
        align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    .page-title { display: flex; align-items: center; gap: 8px; font-size: 20px; font-weight: 600; }
    .stats-badge {
        background: var(--primary-blue); color: var(--white); padding: 6px 16px;
        border-radius: 20px; font-size: 13px; display: flex; align-items: center; gap: 6px;
    }

    .questions-container { max-width: 1000px; margin: 0 auto; }

    .course-banner {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white); padding: 20px 24px; border-radius: var(--radius-md);
        margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;
    }
    .course-info h2 { margin: 0; font-size: 18px; }
    .course-stats { font-size: 12px; opacity: 0.9; margin-top: 4px; }

    .question-card {
        background: var(--white); border-radius: var(--radius-md); box-shadow: var(--shadow-md);
        margin-bottom: 24px; border: 1px solid var(--medium-gray); overflow: hidden;
    }
    .question-header {
        padding: 16px 24px; background: #fcfcfc; border-bottom: 1px solid #eee;
        display: flex; justify-content: space-between; align-items: center;
    }
    .q-number-box {
        display: flex; align-items: center; gap: 12px;
    }
    .q-badge {
        width: 32px; height: 32px; background: var(--primary-blue); color: white;
        border-radius: 50%; display: flex; align-items: center; justify-content: center;
        font-weight: bold; font-size: 14px;
    }
    .q-type-label {
        font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;
        background: #eee; padding: 2px 8px; border-radius: 4px; color: #666;
    }

    .question-body { padding: 24px; }
    .question-text { font-size: 16px; font-weight: 500; margin-bottom: 20px; color: #334155; }
    
    .options-grid {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px;
    }
    .option-card {
        padding: 16px; border: 1px solid #e2e8f0; border-radius: 6px; background: #f8fafc;
        position: relative; transition: 0.2s;
    }
    .option-card.correct { border-color: var(--success); background-color: #ecfdf5; }
    .option-card.correct-multi { border-color: var(--info); background-color: #f0f9ff; }
    .option-marker { font-size: 11px; font-weight: 700; color: #94a3b8; margin-bottom: 4px; display: block; }
    .option-content { font-size: 14px; color: #1e293b; }
    .correct-tag {
        position: absolute; top: 8px; right: 8px; font-size: 10px;
        background: var(--success); color: white; padding: 2px 6px; border-radius: 4px;
    }

    /* Drag and Drop Preview Styles */
    .dd-preview {
        background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;
    }
    .dd-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; align-items: center; }
    .dd-column h4 { font-size: 13px; color: #64748b; margin-top: 0; margin-bottom: 12px; text-align: center; }
    .dd-item-list { display: flex; flex-direction: column; gap: 8px; }
    .dd-pair {
        display: flex; align-items: center; justify-content: space-between;
        background: white; padding: 10px 16px; border-radius: 6px; border: 1px solid #e2e8f0;
        font-size: 14px;
    }
    .dd-drag-text { color: var(--primary-blue); font-weight: 600; }
    .dd-arrow { color: #cbd5e1; }
    .dd-target-text { color: var(--success); font-weight: 600; }
    
    .dd-targets-pool {
        margin-top: 20px; padding-top: 15px; border-top: 1px dashed #cbd5e1;
    }
    .target-badge {
        display: inline-block; background: #f1f5f9; border: 1px solid #e2e8f0;
        padding: 4px 12px; border-radius: 16px; font-size: 12px; margin-right: 8px;
        color: #475569;
    }
    
    /* Rearrange Question Preview Styles */
    .rearrange-preview {
        background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;
    }
    .rearrange-items-container {
        display: flex; flex-direction: column; gap: 10px; margin-bottom: 15px;
    }
    .rearrange-item {
        display: flex; align-items: center; justify-content: space-between;
        background: white; padding: 10px 16px; border-radius: 6px; border: 1px solid #e2e8f0;
        font-size: 14px;
    }
    .rearrange-item-number {
        display: inline-block; background: #e0f2fe; color: #0369a1; padding: 2px 8px;
        border-radius: 12px; font-size: 11px; font-weight: 600; margin-right: 10px;
    }
    .rearrange-item-text { color: var(--primary-blue); font-weight: 600; }

    .question-footer {
        padding: 12px 24px; background: #f8fafc; border-top: 1px solid #eee;
        display: flex; justify-content: space-between; align-items: center;
    }
    .qid-info { font-size: 12px; color: #94a3b8; }
    .actions { display: flex; gap: 8px; }
    
    .btn-icon {
        width: 36px; height: 36px; display: flex; align-items: center; justify-content: center;
        border-radius: 6px; text-decoration: none; transition: 0.2s; border: none; cursor: pointer;
    }
    .btn-edit { background: #e0f2fe; color: #0369a1; }
    .btn-edit:hover { background: #bae6fd; }
    .btn-delete { background: #fee2e2; color: #b91c1c; }
    .btn-delete:hover { background: #fecaca; }

    .floating-back {
        position: fixed; bottom: 30px; right: 0px;
        background: var(--white); border: 1px solid var(--medium-gray);
        padding: 10px 20px; border-radius: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        text-decoration: none; color: var(--text-dark); font-weight: 500;
        display: flex; align-items: center; gap: 8px; z-index: 100;
    }
    .floating-back:hover { background: #476287; color: #e0f2fe;}

    .no-data {
        text-align: center; padding: 60px; background: white; border-radius: var(--radius-md);
        box-shadow: var(--shadow-md); color: var(--dark-gray);
    }
    .no-data i { font-size: 48px; margin-bottom: 16px; opacity: 0.3; }

    /* Modal */
    .modal-backdrop {
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center;
    }
    .modal-box {
        background: white; border-radius: 12px; width: 90%; max-width: 450px;
        overflow: hidden; animation: slideIn 0.3s ease;
    }
    @keyframes slideIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    .modal-header { padding: 20px; background: #f8fafc; border-bottom: 1px solid #eee; font-weight: 600; text-align: center; }
    .modal-body { padding: 24px; font-size: 15px; line-height: 1.5; color: #475569; text-align: center; }
    .modal-footer { padding: 16px 24px; background: #f8fafc; display: flex; justify-content: flex-end; gap: 12px; }
    .btn-cancel { background: #eee; color: #666; padding: 8px 16px; border-radius: 6px; cursor: pointer; border: none; }
    .btn-confirm-del { background: var(--error); color: white; padding: 8px 16px; border-radius: 6px; cursor: pointer; border: none; }

    /* Search and Filter Styles */
    .search-filter-section {
        background: var(--white);
        border-radius: var(--radius-md);
        padding: var(--spacing-lg);
        margin-bottom: var(--spacing-lg);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
    }

    .search-filter-form {
        display: flex;
        flex-direction: column;
        gap: var(--spacing-md);
    }

    .search-row {
        display: flex;
        gap: var(--spacing-md);
        align-items: center;
        flex-wrap: wrap;
    }

    .search-box {
        position: relative;
        flex: 1;
        min-width: 300px;
        max-width: 500px;
    }

    .search-box i {
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--dark-gray);
        z-index: 2;
    }

    .search-input {
        width: 100%;
        padding: 12px 16px 12px 45px;
        border: 2px solid var(--medium-gray);
        border-radius: var(--radius-md);
        font-size: 14px;
        transition: all var(--transition-fast);
        background: var(--white);
        color: var(--text-dark);
    }

    .search-input:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }

    .clear-search {
        position: absolute;
        right: 8px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: var(--dark-gray);
        cursor: pointer;
        padding: 4px;
        border-radius: 50%;
        transition: all var(--transition-fast);
        opacity: 0.6;
    }

    .clear-search:hover {
        opacity: 1;
        background: var(--light-gray);
    }

    .filter-controls {
        display: flex;
        gap: var(--spacing-sm);
        align-items: center;
        flex-wrap: wrap;
    }

    .filter-select {
        padding: 12px 16px;
        border: 2px solid var(--medium-gray);
        border-radius: var(--radius-md);
        font-size: 14px;
        background: var(--white);
        color: var(--text-dark);
        cursor: pointer;
        transition: all var(--transition-fast);
        min-width: 150px;
    }

    .filter-select:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }

    .btn-search {
        padding: 12px 20px;
        background: var(--accent-blue);
        color: var(--white);
        border: none;
        border-radius: var(--radius-md);
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all var(--transition-fast);
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }

    .btn-search:hover {
        background: #3b82f6;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(74, 144, 226, 0.2);
    }

    .active-filters {
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        flex-wrap: wrap;
        padding: var(--spacing-sm);
        background: var(--light-gray);
        border-radius: var(--radius-sm);
        border-left: 3px solid var(--accent-blue);
    }

    .filter-label {
        font-size: 13px;
        color: var(--dark-gray);
        font-weight: 600;
    }

    .filter-tag {
        display: inline-flex;
        align-items: center;
        gap: var(--spacing-xs);
        padding: 4px 8px;
        background: var(--accent-blue);
        color: var(--white);
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
    }

    .remove-filter {
        color: var(--white);
        text-decoration: none;
        opacity: 0.8;
        transition: opacity var(--transition-fast);
        display: flex;
        align-items: center;
    }

    .remove-filter:hover {
        opacity: 1;
    }

    .clear-all-filters {
        color: var(--error);
        text-decoration: none;
        font-size: 12px;
        font-weight: 600;
        transition: color var(--transition-fast);
    }

    .clear-all-filters:hover {
        color: #b91c1c;
        text-decoration: underline;
    }

    /* Floating Scroll Button */
    .floating-scroll {
        position: fixed;
        bottom: 300px;
        right: 5px;
        z-index: 1000;
        display: flex;
        flex-direction: column;
        gap: 8px;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
    }

    .floating-scroll.visible {
        opacity: 1;
        visibility: visible;
    }

    .scroll-btn {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        background-color: #476287;
        color: var(--white);
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 8px;
        box-shadow: var(--shadow-lg);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }

    .scroll-btn:hover {
        transform: scale(1.1);
        box-shadow: 0 8px 25px rgba(9, 41, 77, 0.3);
    }

    .scroll-btn:active {
        transform: scale(0.95);
    }

    .scroll-btn::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0;
        height: 0;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: translate(-50%, -50%);
        transition: width 0.4s ease, height 0.4s ease;
    }

    .scroll-btn:active::before {
        width: 100%;
        height: 100%;
    }

    /* Responsive adjustments */
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
        .dashboard-container { flex-direction: column; }
        .sidebar { width: 100%; height: auto; position: static; }
        .sidebar-nav { display: flex; overflow-x: auto; padding: 10px; }
        .nav-item { padding: 10px; min-width: 80px; text-align: center; }
        .main-content { padding: 15px; }
        .page-header { flex-direction: column; gap: 10px; text-align: center; }

        .floating-scroll {
            bottom: 20px;
            right: 20px;
        }

        .scroll-btn {
            width: 45px;
            height: 45px;
            font-size: 16px;
        }
        
        .search-row {
            flex-direction: column;
            align-items: stretch;
        }

        .search-box {
            min-width: auto;
            max-width: none;
        }

        .filter-controls {
            flex-direction: column;
            align-items: stretch;
        }

        .filter-select,
        .btn-search {
            width: 100%;
        }

        .active-filters {
            flex-direction: column;
            align-items: flex-start;
        }
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
</style>

<div class="dashboard-container">
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="Logo" class="mut-logo">
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
        <!-- Display session messages -->
        <div class="messages-container">
            <% 
                String successMsg = (String) session.getAttribute("message");
                String errorMsg = (String) session.getAttribute("error");
                if (successMsg != null && !successMsg.trim().isEmpty()) {
            %>
                <div class="alert alert-success" style="padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between; background: #ecfdf5; color: #059669; border: 1px solid #10b981;">
                    <span><i class="fas fa-check-circle"></i> <%= successMsg %></span>
                    <i class="fas fa-times" style="cursor:pointer" onclick="this.parentElement.style.display='none'"></i>
                </div>
            <% session.removeAttribute("message"); } 
                if (errorMsg != null && !errorMsg.trim().isEmpty()) {
            %>
                <div class="alert alert-error" style="padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between; background: #fef2f2; color: #dc2626; border: 1px solid #ef4444;">
                    <span><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></span>
                    <i class="fas fa-times" style="cursor:pointer" onclick="this.parentElement.style.display='none'"></i>
                </div>
            <% session.removeAttribute("error"); } %>
        </div>

        <div class="questions-container">
            <header class="page-header">
                <div class="page-title">
                    <i class="fas fa-list"></i> Question Bank
                </div>
                <div class="stats-badge">
                    <i class="fas fa-database"></i> Total: <%= list.size() %>
                </div>
            </header>

            <% if (courseName != null && !courseName.isEmpty()) { %>
                <!-- Search and Filter Section -->
                <div class="search-filter-section">
                    <form method="GET" action="showall.jsp" class="search-filter-form">
                        <input type="hidden" name="coursename" value="<%= courseName %>">
                        
                        <div class="search-row">
                            <div class="search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" 
                                       name="search" 
                                       placeholder="Search questions, options..." 
                                       value="<%= searchTerm != null ? searchTerm : "" %>"
                                       class="search-input">
                                <button type="button" class="clear-search" onclick="clearSearch()">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                            
                            <div class="filter-controls">
                                <select name="type" class="filter-select" onchange="this.form.submit()">
                                    <option value="all" <%= "all".equalsIgnoreCase(questionTypeFilter) ? "selected" : "" %>>All Types</option>
                                    <option value="MCQ" <%= "MCQ".equalsIgnoreCase(questionTypeFilter) ? "selected" : "" %>>Multiple Choice</option>
                                    <option value="MultipleSelect" <%= "MultipleSelect".equalsIgnoreCase(questionTypeFilter) ? "selected" : "" %>>Multiple Select</option>
                                    <option value="TrueFalse" <%= "TrueFalse".equalsIgnoreCase(questionTypeFilter) ? "selected" : "" %>>True/False</option>
                                    <option value="Code" <%= "Code".equalsIgnoreCase(questionTypeFilter) ? "selected" : "" %>>Code Snippet</option>
                                    <option value="DRAG_AND_DROP" <%= "DRAG_AND_DROP".equalsIgnoreCase(questionTypeFilter) ? "selected" : "" %>>Drag & Drop</option>
                                    <option value="REARRANGE" <%= "REARRANGE".equalsIgnoreCase(questionTypeFilter) ? "selected" : "" %>>Rearrange</option>
                                </select>
                                
                                <select name="sort" class="filter-select" onchange="this.form.submit()">
                                    <option value="desc" <%= "desc".equalsIgnoreCase(sortBy) || sortBy == null ? "selected" : "" %>>Newest First</option>
                                    <option value="asc" <%= "asc".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Oldest First</option>
                                </select>
                                
                                <button type="submit" class="btn-search">
                                    <i class="fas fa-filter"></i> Apply
                                </button>
                            </div>
                        </div>
                        
                        <% if (searchTerm != null && !searchTerm.trim().isEmpty() || 
                             (questionTypeFilter != null && !questionTypeFilter.trim().isEmpty() && !"all".equalsIgnoreCase(questionTypeFilter)) ) { %>
                            <div class="active-filters">
                                <span class="filter-label">Active filters:</span>
                                <% if (searchTerm != null && !searchTerm.trim().isEmpty()) { %>
                                    <span class="filter-tag">
                                        Search: "<%= searchTerm %>"
                                        <a href="showall.jsp?coursename=<%= courseName %>&type=<%= questionTypeFilter != null ? questionTypeFilter : "all" %>&sort=<%= sortBy != null ? sortBy : "desc" %>" class="remove-filter">
                                            <i class="fas fa-times"></i>
                                        </a>
                                    </span>
                                <% } %>
                                <% if (questionTypeFilter != null && !questionTypeFilter.trim().isEmpty() && !"all".equalsIgnoreCase(questionTypeFilter)) { %>
                                    <span class="filter-tag">
                                        Type: <%= questionTypeFilter %>
                                        <a href="showall.jsp?coursename=<%= courseName %>&search=<%= searchTerm != null ? searchTerm : "" %>&sort=<%= sortBy != null ? sortBy : "desc" %>" class="remove-filter">
                                            <i class="fas fa-times"></i>
                                        </a>
                                    </span>
                                <% } %>
                                <a href="showall.jsp?coursename=<%= courseName %>" class="clear-all-filters">Clear all</a>
                            </div>
                        <% } %>
                    </form>
                </div>

                <div class="course-banner">
                    <div class="course-info">
                        <h2><%= courseName %></h2>
                        <div class="course-stats">Management portal for exam questions</div>
                    </div>
                    <div class="stats-badge" style="background: rgba(255,255,255,0.2);">
                        <i class="fas fa-check-circle"></i> Active
                    </div>
                </div>

                <% if (list.isEmpty()) { %>
                    <div class="no-data">
                        <i class="fas fa-folder-open"></i>
                        <p>No questions have been added to this course yet.</p>
                        <a href="adm-page.jsp?pgprt=3" class="btn btn-primary">Add First Question</a>
                    </div>
                <% } else { %>
                    <% for (int i = 0; i < list.size(); i++) { 
                        Questions q = (Questions) list.get(i);
                        String qType = q.getQuestionType() != null ? q.getQuestionType() : "MCQ";
                        boolean isDD = "DRAG_AND_DROP".equals(qType);
                        boolean isRearrange = "REARRANGE".equals(qType);
                        boolean isFIB = "FillInTheBlank".equalsIgnoreCase(qType);
                        boolean isMS = "MultipleSelect".equals(qType);
                        String[] correctAns = isMS ? q.getCorrect().split("\\|") : new String[]{q.getCorrect()};
                    %>
                        <div class="question-card">
                            <div class="checkbox-container">
                                <input type="checkbox" class="multi-select-checkbox" id="checkbox-<%= q.getQuestionId() %>" data-qid="<%= q.getQuestionId() %>" />
                                <label for="checkbox-<%= q.getQuestionId() %>" class="multi-select-toggle" onclick="toggleQuestionSelection(this)"></label>
                            </div>
                            <div class="question-header">
                                <div class="q-number-box">
                                    <div class="q-badge"><%= i + 1 %></div>
                                    <span class="q-type-label"><%= qType %></span>
                                </div>
                                <div class="actions">
                                    <a href="edit_question.jsp?qid=<%= q.getQuestionId() %>&coursename=<%= courseName %>" class="btn-icon btn-edit" title="Edit Question">
                                        <i class="fas fa-pen"></i>
                                    </a>
                                    <button class="btn-icon btn-delete" data-qid="<%= q.getQuestionId() %>" data-course="<%= courseName %>" onclick="showDeleteModalFromData(this)" title="Delete Question">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                            
                            <div class="question-body">
                                <div class="question-text"><%= q.getQuestion() %></div>

                                <% if (q.getImagePath() != null && !q.getImagePath().isEmpty()) { %>
                                    <div style="margin-bottom: 20px; border: 1px solid #eee; padding: 10px; border-radius: 8px; display: inline-block;">
                                        <img src="<%= q.getImagePath() %>" style="max-width: 100%; max-height: 250px; border-radius: 4px;">
                                    </div>
                                <% } %>

                                <% if (isDD) { 
                                    Map<String, String> dd = pDAO.getDragDropData(q.getQuestionId());
                                    String[] items = parseSimpleJsonArray(dd.get("drag_items"));
                                    String[] targets = parseSimpleJsonArray(dd.get("drop_targets"));
                                    String[] correctMap = parseSimpleJsonArray(dd.get("drag_correct_targets"));
                                %>
                                    <div class="dd-preview">
                                        <div class="dd-column">
                                            <h4><i class="fas fa-link"></i> Correct Pairings Preview</h4>
                                            <div class="dd-item-list">
                                                <% for (int j = 0; j < items.length; j++) { 
                                                    String target = (j < correctMap.length) ? correctMap[j] : "Not Assigned";
                                                %>
                                                    <div class="dd-pair">
                                                        <span class="dd-drag-text"><%= items[j] %></span>
                                                        <span class="dd-arrow"><i class="fas fa-arrow-right"></i></span>
                                                        <span class="dd-target-text"><%= target %></span>
                                                    </div>
                                                <% } %>
                                            </div>
                                        </div>
                                        <div class="dd-targets-pool">
                                            <span style="font-size: 12px; color: #94a3b8; display: block; margin-bottom: 8px;">Available Drop Targets:</span>
                                            <% for (String t : targets) { %>
                                                <span class="target-badge"><%= t %></span>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } else if (isFIB) { %>
                                    <div class="option-card correct" style="max-width: 400px;">
                                        <span class="option-marker">ACCEPTED ANSWER</span>
                                        <div class="option-content"><%= q.getCorrect() %></div>
                                        <span class="correct-tag"><i class="fas fa-check"></i></span>
                                    </div>
                                <% } else if (isRearrange) { 
                                    // Handle rearrange questions
                                    java.util.List<String> displayItems = new java.util.ArrayList<>();
                                    if (q.getRearrangeItems() != null && !q.getRearrangeItems().isEmpty()) {
                                        for (myPackage.classes.RearrangeItem ri : q.getRearrangeItems()) {
                                            displayItems.add(ri.getItemText());
                                        }
                                    } else if (q.getRearrangeItemsJson() != null && !q.getRearrangeItemsJson().isEmpty()) {
                                        // Fallback to JSON column if relational list is empty
                                        try {
                                            org.json.JSONArray itemsArray = new org.json.JSONArray(q.getRearrangeItemsJson());
                                            for (int j = 0; j < itemsArray.length(); j++) {
                                                Object obj = itemsArray.get(j);
                                                if (obj instanceof org.json.JSONObject) {
                                                    displayItems.add(((org.json.JSONObject)obj).optString("text", ""));
                                                } else {
                                                    displayItems.add(obj.toString());
                                                }
                                            }
                                        } catch (Exception e) {
                                            // Silently handle JSON parsing errors
                                        }
                                    }
                                %>
                                    <div class="rearrange-preview">
                                        <h4><i class="fas fa-sort-amount-down"></i> Correct Sequence Order</h4>
                                        <div class="rearrange-items-container">
                                            <% for (int j = 0; j < displayItems.size(); j++) { 
                                                int position = j + 1; // Positions start from 1
                                            %>
                                                <div class="rearrange-item">
                                                    <span class="rearrange-item-number">#<%= position %></span>
                                                    <span class="rearrange-item-text"><%= displayItems.get(j) %></span>
                                                </div>
                                            <% } %>
                                        </div>
                                        <div class="dd-targets-pool">
                                            <span style="font-size: 12px; color: #94a3b8; display: block; margin-bottom: 8px;">Students must arrange these items in the correct order:</span>
                                            <% for (int j = 0; j < displayItems.size(); j++) { %>
                                                <span class="target-badge">#<%= j + 1 %> <%= displayItems.get(j) %></span>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } else { %>

                                    <div class="options-grid">
                                        <% 
                                        String[] opts = {q.getOpt1(), q.getOpt2(), q.getOpt3(), q.getOpt4()};
                                        char[] labels = {'A', 'B', 'C', 'D'};
                                        for (int j = 0; j < 4; j++) {
                                            if (opts[j] == null || opts[j].isEmpty()) continue;
                                            boolean isCorrect = containsAnswer(correctAns, opts[j]);
                                        %>
                                            <div class="option-card <%= isCorrect ? (isMS ? "correct-multi" : "correct") : "" %>">
                                                <span class="option-marker">OPTION <%= labels[j] %></span>
                                                <div class="option-content"><%= opts[j] %></div>
                                                <% if (isCorrect) { %>
                                                    <span class="correct-tag" style="<%= isMS ? "background: var(--info);" : "" %>">
                                                        <i class="fas fa-check"></i>
                                                    </span>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="question-footer">
                                <div class="qid-info">ID: #<%= q.getQuestionId() %> | Course: <%= courseName %></div>
                                <% if (isMS) { %>
                                    <span class="q-type-label" style="background: #e0f2fe; color: #0369a1;">Multiple Select</span>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            <% } else { %>
                <div class="no-data">
                    <i class="fas fa-search"></i>
                    <p>No course selected. Please return to the course list.</p>
                    <a href="adm-page.jsp?pgprt=3" class="btn btn-primary">Go to Courses</a>
                </div>
            <% } %>
        </div>
    </main>
</div>

<a href="adm-page.jsp?pgprt=3" class="floating-back">
    <i class="fas fa-chevron-left" ></i> Back to Courses
</a>

<!-- Floating Delete Selected Button -->
<button id="floatingDeleteBtn" class="floating-delete-selected" onclick="deleteSelectedQuestions()">
    <i class="fas fa-trash"></i> Delete Selected (<span id="selectedCount">0</span>)
</button>

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

<script>
    let questionToDelete = null;
    let courseToDeleteFrom = null;
    let csrfToken = '<%= csrfToken %>';

    function showDeleteModal(qid, cname) {
        questionToDelete = qid;
        courseToDeleteFrom = cname;
        document.getElementById('deleteModal').style.display = 'flex';
    }
    
    function showDeleteModalFromData(button) {
        const qid = button.getAttribute('data-qid');
        const cname = button.getAttribute('data-course');
        showDeleteModal(qid, cname);
    }

    function hideDeleteModal() {
        document.getElementById('deleteModal').style.display = 'none';
        questionToDelete = null;
        courseToDeleteFrom = null;
    }

    function clearSearch() {
        const searchInput = document.querySelector('.search-input');
        if (searchInput) {
            searchInput.value = '';
            // Submit form to clear search results
            searchInput.form.submit();
        }
    }

    // Floating scroll buttons functionality
    function initScrollButtons() {
        const floatingScroll = document.getElementById('floatingScroll');
        const scrollUpBtn = document.getElementById('scrollUpBtn');
        const scrollDownBtn = document.getElementById('scrollDownBtn');
        
        if (!floatingScroll || !scrollUpBtn || !scrollDownBtn) return;
        
        // Show/hide floating buttons based on scroll position
        function toggleScrollButtons() {
            const scrollPosition = window.pageYOffset || document.documentElement.scrollTop;
            const documentHeight = document.documentElement.scrollHeight;
            const windowHeight = window.innerHeight;
            
            // Show buttons when user scrolls down at least 200px
            if (scrollPosition > 200) {
                floatingScroll.classList.add('visible');
            } else {
                floatingScroll.classList.remove('visible');
            }
            
            // Hide scroll down button when at bottom
            if (scrollPosition + windowHeight >= documentHeight - 100) {
                scrollDownBtn.style.display = 'none';
            } else {
                scrollDownBtn.style.display = 'flex';
            }
            
            // Hide scroll up button when at top
            if (scrollPosition < 100) {
                scrollUpBtn.style.display = 'none';
            } else {
                scrollUpBtn.style.display = 'flex';
            }
        }
        
        // Scroll to top function
        function scrollToTop() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        }
        
        // Scroll to bottom function
        function scrollToBottom() {
            window.scrollTo({
                top: document.documentElement.scrollHeight,
                behavior: 'smooth'
            });
        }
        
        // Event listeners
        scrollUpBtn.addEventListener('click', scrollToTop);
        scrollDownBtn.addEventListener('click', scrollToBottom);
        window.addEventListener('scroll', toggleScrollButtons);
        
        // Initial check
        toggleScrollButtons();
    }

    document.getElementById('confirmDelBtn').onclick = function() {
        if (questionToDelete && courseToDeleteFrom) {
            // METHOD 1: Redirect with URL parameters (simplest)
            const url = 'controller.jsp?page=questions&operation=del&qid=' + 
                        encodeURIComponent(questionToDelete) + 
                        '&coursename=' + encodeURIComponent(courseToDeleteFrom) + 
                        '&csrf_token=' + encodeURIComponent(csrfToken);
            
            window.location.href = url;
            
            // Hide modal after click
            hideDeleteModal();
        } else {
            alert('Missing question information');
        }
    };

    // Close modal on outside click
    window.onclick = function(event) {
        const modal = document.getElementById('deleteModal');
        if (event.target == modal) {
            hideDeleteModal();
        }
        
        // Also close delete selected modal if clicked outside
        const deleteSelectedModal = document.getElementById('deleteSelectedModal');
        if (event.target == deleteSelectedModal) {
            hideDeleteSelectedModal();
        }
    }
    
    // Close modal on Escape key
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            hideDeleteModal();
            hideDeleteSelectedModal();
        }
    });

    // Add search on Enter key functionality
    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.querySelector('.search-input');
        if (searchInput) {
            searchInput.addEventListener('keypress', function(event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    this.form.submit();
                }
            });
        }
        
        // Initialize scroll buttons
        initScrollButtons();
    });
    
    // Multi-select functionality
    function toggleQuestionSelection(element) {
        const checkbox = element.previousElementSibling;
        const questionCard = checkbox.closest('.question-card');
        
        checkbox.checked = !checkbox.checked;
        
        if (checkbox.checked) {
            questionCard.classList.add('multi-selected');
            element.classList.add('checked');
        } else {
            questionCard.classList.remove('multi-selected');
            element.classList.remove('checked');
        }
        
        updateFloatingDeleteButton();
    }
    
    function updateFloatingDeleteButton() {
        const selectedCheckboxes = document.querySelectorAll('.multi-select-checkbox:checked');
        const floatingBtn = document.getElementById('floatingDeleteBtn');
        const countSpan = document.getElementById('selectedCount');
        
        countSpan.textContent = selectedCheckboxes.length;
        
        if (selectedCheckboxes.length > 0) {
            floatingBtn.classList.add('show');
        } else {
            floatingBtn.classList.remove('show');
        }
    }
    
    function deleteSelectedQuestions() {
        const selectedCheckboxes = document.querySelectorAll('.multi-select-checkbox:checked');
        
        if (selectedCheckboxes.length === 0) {
            alert('Please select at least one question to delete.');
            return;
        }
        
        // Show confirmation modal instead of confirm dialog
        document.getElementById('deleteCount').textContent = selectedCheckboxes.length;
        document.getElementById('deleteSelectedModal').style.display = 'flex';
    }
    
    function hideDeleteSelectedModal() {
        document.getElementById('deleteSelectedModal').style.display = 'none';
    }
    
    function confirmDeleteSelected() {
        hideDeleteSelectedModal();
        
        const selectedCheckboxes = document.querySelectorAll('.multi-select-checkbox:checked');
        
        // Collect all selected question IDs
        const questionIds = [];
        selectedCheckboxes.forEach(checkbox => {
            questionIds.push(checkbox.dataset.qid);
        });
        
        // Perform the deletion
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'controller.jsp';
        
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
        
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'csrf_token';
        csrfInput.value = '<%= csrfToken %>';
        form.appendChild(csrfInput);
        
        const courseInput = document.createElement('input');
        courseInput.type = 'hidden';
        courseInput.name = 'coursename';
        courseInput.value = '<%= courseName %>';
        form.appendChild(courseInput);
        
        // Add each question ID as a separate input
        questionIds.forEach(id => {
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'questionIds';
            idInput.value = id;
            form.appendChild(idInput);
        });
        
        document.body.appendChild(form);
        form.submit();
    }
    
    // Add event listener to handle clicks on question cards to prevent interference with checkboxes
    document.addEventListener('click', function(e) {
        // If clicked on a question card but not on an action button or checkbox, toggle selection
        if (e.target.closest('.question-card') && 
            !e.target.closest('.actions') && 
            !e.target.closest('.multi-select-toggle') &&
            !e.target.closest('.btn-edit') &&
            !e.target.closest('.btn-delete')) {
            
            const card = e.target.closest('.question-card');
            const checkbox = card.querySelector('.multi-select-checkbox');
            const toggle = card.querySelector('.multi-select-toggle');
            
            if (checkbox && toggle) {
                checkbox.checked = !checkbox.checked;
                
                if (checkbox.checked) {
                    card.classList.add('multi-selected');
                    toggle.classList.add('checked');
                } else {
                    card.classList.remove('multi-selected');
                    toggle.classList.remove('checked');
                }
                
                updateFloatingDeleteButton();
            }
        }
    });
</script>
