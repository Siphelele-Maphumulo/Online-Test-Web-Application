<%@ page import="java.sql.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="myPackage.classes.User" %>
<%
    // Check if user is admin/lecturer
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check user type
    String userType = (String) session.getAttribute("userType");
    if (userType == null) {
        int userId = Integer.parseInt(session.getAttribute("userId").toString());
        User user = DatabaseClass.getInstance().getUserDetails(String.valueOf(userId));
        if (user != null) {
            userType = user.getType();
            session.setAttribute("userType", userType);
        }
    }

    if (!("admin".equals(userType) || "lecture".equals(userType))) {
        response.sendRedirect("std-page.jsp");
        return;
    }
    
    DatabaseClass pDAO = DatabaseClass.getInstance();
    
    // Get current user details for display
    User currentUser = null;
    String currentUserFullName = "Unknown User";
    try {
        int userId = Integer.parseInt(session.getAttribute("userId").toString());
        currentUser = pDAO.getUserDetails(String.valueOf(userId));
        if (currentUser != null) {
            String firstName = currentUser.getFirstName();
            String lastName = currentUser.getLastName();
            currentUserFullName = (firstName != null ? firstName.trim() : "") + " " + 
                               (lastName != null ? lastName.trim() : "");
            if (currentUserFullName.trim().isEmpty()) {
                currentUserFullName = "User ID: " + userId + " (Debug: firstName=" + firstName + ", lastName=" + lastName + ")";
            }
        } else {
            currentUserFullName = "User ID: " + userId + " (Debug: currentUser is null)";
        }
    } catch (Exception e) {
        currentUserFullName = "User ID: " + session.getAttribute("userId") + " (Debug: Exception=" + e.getMessage() + ")";
    }
    
    // Handle delete operation if requested
    String deleteAction = request.getParameter("delete_action");
    String deleteExamId = request.getParameter("delete_exam_id");
    String deleteStudentId = request.getParameter("delete_student_id");
    
    if ("confirm_delete".equals(deleteAction) && deleteExamId != null && deleteStudentId != null) {
        try {
            // Perform the delete operation
            boolean deleted = pDAO.deleteExamRecord(Integer.parseInt(deleteExamId), 
                                                     Integer.parseInt(deleteStudentId));
            if (deleted) {
                // Refresh the page with success message
                response.sendRedirect("exam-register-report.jsp?success=Record+deleted+successfully");
                return;
            }
        } catch (NumberFormatException e) {
            // Handle invalid ID format
            response.sendRedirect("exam-register-report.jsp?error=Invalid+record+ID");
            return;
        } catch (SQLException e) {
            // Handle database error
            response.sendRedirect("exam-register-report.jsp?error=Database+error:+" + e.getMessage());
            return;
        }
    }
    
    // Get all filter parameters
    int examId = 0;
    String examIdParam = request.getParameter("exam_id");
    if (examIdParam != null && !examIdParam.isEmpty()) {
        try {
            examId = Integer.parseInt(examIdParam);
        } catch (NumberFormatException e) {
            examId = 0;
        }
    }
    
    int studentId = 0;
    String studentIdParam = request.getParameter("student_id");
    if (studentIdParam != null && !studentIdParam.isEmpty()) {
        try {
            studentId = Integer.parseInt(studentIdParam);
        } catch (NumberFormatException e) {
            studentId = 0;
        }
    }
    
    String firstName = request.getParameter("first_name");
    if (firstName == null) firstName = "";
    
    String lastName = request.getParameter("last_name");
    if (lastName == null) lastName = "";
    
    String courseName = request.getParameter("course_name");
    if (courseName == null) courseName = "";
    
    String examDate = request.getParameter("exam_date");
    if (examDate == null) examDate = "";
    
    // Generate filename
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
    Date now = new Date();
    String timestamp = sdf.format(now);
    String filename = "Exam_Register_" + timestamp;
    
    if (examId > 0) {
        filename += "_Exam" + examId;
    }
    if (studentId > 0) {
        filename += "_Student" + studentId;
    }
    if (!courseName.isEmpty()) {
        String safeCourseName = courseName.replaceAll("[^a-zA-Z0-9]", "_");
        filename += "_" + safeCourseName;
    }
    if (!examDate.isEmpty()) {
        filename += "_" + examDate.replace("-", "");
    }
    filename += ".html";
    
    // Set headers for HTML download
    response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-Disposition", "attachment;filename=\"" + filename + "\"");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Register Report</title>
    <style>
        /* Professional Exam Register Report Styling */
        :root {
            --primary-blue: #09294d;
            --secondary-blue: #1a3d6d;
            --accent-blue: #4a90e2;
            --text-white: #ffffff;
            --text-light: #e0e9ff;
            --shadow-light: rgba(255, 255, 255, 0.1);
            --shadow-dark: rgba(0, 0, 0, 0.1);
            --transition-speed: 0.2s;
            --medium-gray: #6b7280;
            --light-gray: #f3f4f6;
            --dark-gray: #374151;
            --success: #10b981;
            --warning: #f59e0b;
            --error: #ef4444;
        }

        /* Reset and Base Styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
            background-color: #f8fafc;
            color: #334155;
            line-height: 1.5;
            font-size: 14px;
            overflow-x: hidden;
        }

        /* Report Container */
        .report-container {
            max-width: 1200px;
            margin: 0 auto;
            border: 1px solid var(--medium-gray);
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            background: white;
            overflow: hidden;
        }

        /* Report Header */
        .report-header {
            background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
            color: var(--text-white);
            padding: 30px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .report-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grid" width="10" height="10" patternUnits="userSpaceOnUse"><path d="M 10 0 L 0 0 0 10" fill="none" stroke="rgba(255,255,255,0.03)" stroke-width="0.5"/></pattern></defs><rect width="100" height="100" fill="url(%23grid)"/></svg>');
            pointer-events: none;
        }

        .institution-logo {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 20px;
            margin-bottom: 20px;
            position: relative;
            z-index: 1;
        }

        .logo-col {
            display: flex;
            align-items: center;
        }

        .logo-link {
            display: flex;
            align-items: center;
            text-decoration: none;
            color: var(--text-white);
            font-weight: 600;
            font-size: 18px;
            transition: var(--transition-speed);
        }

        .logo-link:hover {
            transform: translateY(-2px);
        }

        .logo-symbol {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            margin-right: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        }

        .institution-name {
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            position: relative;
            z-index: 1;
        }

        .report-title {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 2px;
            position: relative;
            z-index: 1;
        }

        .report-subtitle {
            font-size: 14px;
            opacity: 0.9;
            font-weight: 400;
            position: relative;
            z-index: 1;
        }

        /* Metadata Section */
        .metadata-section {
            background: var(--light-gray);
            padding: 25px;
            border-bottom: 1px solid var(--medium-gray);
        }

        .metadata-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }

        .metadata-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--medium-gray);
            transition: var(--transition-speed);
        }

        .metadata-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .metadata-label {
            font-size: 12px;
            color: var(--medium-gray);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
            font-weight: 600;
        }

        .metadata-value {
            font-size: 16px;
            font-weight: 600;
            color: var(--primary-blue);
        }

        /* Filters Section */
        .filters-section {
            background: white;
            padding: 25px;
            border-bottom: 1px solid var(--medium-gray);
        }

        .filters-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
        }

        .filter-item {
            background: linear-gradient(135deg, var(--accent-blue), var(--secondary-blue));
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 2px 8px rgba(74, 144, 226, 0.3);
        }

        .filter-label::before {
            content: '🔍';
            font-size: 14px;
        }

        /* Data Section */
        .data-section {
            padding: 25px;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }

        .data-table thead {
            background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
            color: white;
        }

        .data-table th {
            padding: 16px 12px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid var(--accent-blue);
            background: linear-gradient(135deg, #0F3058, #1a3d6d);
            color: white;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .data-table tbody tr {
            transition: var(--transition-speed);
            border-bottom: 1px solid #f0f0f0;
        }

        .data-table tbody tr:nth-child(even) {
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
        }

        .data-table tbody tr:nth-child(odd) {
            background: linear-gradient(135deg, #ffffff, #f8fafc);
        }

        .data-table tbody tr:hover {
            background: linear-gradient(135deg, #e8f4fd, #dbeafe);
            transform: scale(1.005);
            box-shadow: 0 2px 8px rgba(15, 48, 88, 0.1);
        }

        .data-table td {
            padding: 14px 12px;
            font-size: 14px;
            vertical-align: middle;
            border-right: 1px solid #f0f0f0;
            background: transparent;
        }

        .data-table td:last-child {
            border-right: none;
        }

        /* Column-specific professional styling */
        .data-table td.col-serial {
            background: linear-gradient(135deg, #0F3058, #1a3d6d);
            color: white;
            font-weight: 700;
            text-align: center;
            border-right: 1px solid #f0f0f0;
        }

        .data-table td.col-name {
            background: linear-gradient(135deg, #f8fafc, #e2e8f0);
            font-weight: 600;
            color: #0F3058;
        }

        .data-table td.col-id {
            background: linear-gradient(135deg, #ffffff, #f1f5f9);
            font-family: 'Courier New', monospace;
            font-weight: 600;
            color: #0F3058;
            text-align: center;
        }

        .data-table td.col-course {
            background: linear-gradient(135deg, #e8f4fd, #dbeafe);
            color: #0F3058;
            font-weight: 500;
        }

        .data-table td.col-exam-id {
            background: linear-gradient(135deg, #f8fafc, #e2e8f0);
            font-family: 'Courier New', monospace;
            font-weight: 600;
            color: #0F3058;
            text-align: center;
        }

        .data-table td.col-date {
            background: linear-gradient(135deg, #ffffff, #f1f5f9);
            font-weight: 500;
            color: #0F3058;
        }

        .data-table td.col-time {
            background: linear-gradient(135deg, #e8f4fd, #dbeafe);
            font-family: 'Courier New', monospace;
            font-weight: 600;
            color: #0F3058;
            text-align: center;
        }

        .data-table td.col-duration {
            background: linear-gradient(135deg, #f8fafc, #e2e8f0);
            font-family: 'Courier New', monospace;
            font-weight: 600;
            color: #0F3058;
            text-align: center;
        }

        .data-table td.col-email {
            background: linear-gradient(135deg, #ffffff, #f1f5f9);
            color: #64748b;
            font-size: 13px;
        }

        .data-table td.col-status {
            background: linear-gradient(135deg, #e8f4fd, #dbeafe);
            text-align: center;
        }

        .text-center {
            text-align: center;
        }

        .col-serial {
            width: 60px;
        }

        .col-name {
            min-width: 200px;
        }

        .col-id {
            width: 100px;
        }

        .col-course {
            min-width: 150px;
        }

        .col-exam-id {
            width: 100px;
        }

        .col-date {
            width: 120px;
        }

        .col-time {
            width: 80px;
        }

        .col-duration {
            width: 100px;
        }

        .col-email {
            min-width: 180px;
        }

        .col-status {
            width: 120px;
        }

        /* Status Badges */
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-block;
        }

        .status-completed {
            background: linear-gradient(135deg, var(--success), #059669);
            color: white;
            box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
        }

        .status-inprogress {
            background: linear-gradient(135deg, var(--warning), #d97706);
            color: white;
            box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
        }

        .status-incomplete {
            background: linear-gradient(135deg, var(--medium-gray), #4b5563);
            color: white;
            box-shadow: 0 2px 8px rgba(107, 114, 128, 0.3);
        }

        /* Action Button */
        .delete-btn {
            background: linear-gradient(135deg, var(--error), #dc2626);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: var(--transition-speed);
            box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .delete-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
            background: linear-gradient(135deg, #dc2626, #b91c1c);
        }

        .delete-btn:active {
            transform: translateY(0);
        }

        /* Summary Section */
        .summary-section {
            background: linear-gradient(135deg, var(--light-gray), #e5e7eb);
            padding: 30px;
            border-top: 1px solid var(--medium-gray);
        }

        .summary-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--primary-blue);
            margin-bottom: 20px;
            text-align: center;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }

        .summary-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            border: 1px solid var(--medium-gray);
            transition: var(--transition-speed);
        }

        .summary-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
        }

        .summary-card.highlight-stat {
            background: linear-gradient(135deg, var(--accent-blue), var(--primary-blue));
            color: white;
            border: none;
        }

        .summary-value {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 8px;
            line-height: 1;
        }

        .summary-label {
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            opacity: 0.8;
        }

        /* Report Footer */
        .report-footer {
            background: var(--dark-gray);
            color: var(--text-light);
            padding: 25px;
            text-align: center;
            font-size: 12px;
        }

        .footer-text {
            margin-bottom: 8px;
            opacity: 0.9;
        }

        .report-id {
            font-family: 'Courier New', monospace;
            background: var(--primary-blue);
            color: white;
            padding: 2px 8px;
            border-radius: 4px;
            font-weight: 600;
        }

        /* Modal Styles - Professional Version */
        .modal {
            display: none;
            position: fixed;
            z-index: 10000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
            animation: fadeIn 0.3s ease-out;
        }

        .modal-content {
            background: white;
            margin: 5% auto;
            padding: 0;
            border-radius: 16px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
            position: relative;
            animation: slideIn 0.3s ease-out;
            border: 1px solid var(--medium-gray);
        }

        .modal-header {
            background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
            color: white;
            padding: 20px;
            border-radius: 16px 16px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 18px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .close-btn {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            font-size: 24px;
            cursor: pointer;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition-speed);
        }

        .close-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
        }

        .modal-body {
            padding: 25px;
        }

        .modal-footer {
            padding: 20px 25px;
            background: var(--light-gray);
            border-radius: 0 0 16px 16px;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: var(--transition-speed);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .btn-danger {
            background: linear-gradient(135deg, var(--error), #dc2626);
            color: white;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(239, 68, 68, 0.4);
        }

        .btn-secondary {
            background: var(--medium-gray);
            color: white;
            box-shadow: 0 4px 12px rgba(107, 114, 128, 0.3);
        }

        .btn-secondary:hover {
            background: var(--dark-gray);
            transform: translateY(-2px);
        }

        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideIn {
            from { 
                opacity: 0;
                transform: translateY(-30px) scale(0.9);
            }
            to { 
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        /* Print Styles */
        @media print {
            body { 
                background: white; 
                color: black; 
            }
            
            .report-container {
                box-shadow: none;
                border: 1px solid #000;
            }
            
            .modal {
                display: none !important;
            }
            
            .delete-btn {
                display: none !important;
            }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .report-container {
                margin: 10px;
                border-radius: 8px;
            }
            
            .metadata-grid {
                grid-template-columns: 1fr;
            }
            
            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .data-table {
                font-size: 12px;
            }
            
            .data-table th, .data-table td {
                padding: 8px 6px;
            }
            
            .modal-content {
                margin: 10% auto;
                width: 95%;
            }
        }

        @media (max-width: 480px) {
            .report-header {
                padding: 20px;
            }
            
            .institution-name {
                font-size: 18px;
            }
            
            .report-title {
                font-size: 24px;
            }
            
            .summary-grid {
                grid-template-columns: 1fr;
            }
            
            .data-table {
                font-size: 11px;
            }
            
            .col-name, .col-email {
                min-width: 120px;
            }
        }
    </style>
</head>
<body>
    <div class="report-container">
        <!-- Delete Confirmation Modal -->
        <div id="deleteModal" class="modal">
            <div class="modal-content">
                <span class="close-btn" onclick="closeModal()">&times;</span>
                <div class="modal-header">
                    <div class="modal-title">
                        <i class="fas fa-exclamation-triangle" style="color: var(--warning);"></i>
                        Confirm Deletion
                    </div>
                    <span class="close-btn" onclick="closeModal()">&times;</span>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this exam record?</p>
                    <p><strong>This action cannot be undone.</strong></p>
                    <div id="recordDetails" style="background-color: #f5f5f5; padding: 10px; border-radius: 4px; margin-top: 10px;"></div>
                </div>
                <div class="modal-footer">
                    <form id="deleteForm" method="post" style="display: inline;">
                        <input type="hidden" name="delete_action" value="confirm_delete">
                        <input type="hidden" id="deleteExamIdInput" name="delete_exam_id">
                        <input type="hidden" id="deleteStudentIdInput" name="delete_student_id">
                        <!-- Keep filter parameters for redirect -->
                        <% if (examId > 0) { %>
                        <input type="hidden" name="exam_id" value="<%= examId %>">
                        <% } %>
                        <% if (studentId > 0) { %>
                        <input type="hidden" name="student_id" value="<%= studentId %>">
                        <% } %>
                        <% if (!firstName.isEmpty()) { %>
                        <input type="hidden" name="first_name" value="<%= firstName %>">
                        <% } %>
                        <% if (!lastName.isEmpty()) { %>
                        <input type="hidden" name="last_name" value="<%= lastName %>">
                        <% } %>
                        <% if (!courseName.isEmpty()) { %>
                        <input type="hidden" name="course_name" value="<%= courseName %>">
                        <% } %>
                        <% if (!examDate.isEmpty()) { %>
                        <input type="hidden" name="exam_date" value="<%= examDate %>">
                        <% } %>
                        <button type="button" class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                        <button type="submit" class="btn btn-danger">Delete Record</button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Report Header -->
        <div class="report-header">
            <div class="institution-logo">
                <div class="logo-col">
                    <a href="index.jsp" class="logo-link logo-symbol">
                        <img src="https://raw.githubusercontent.com/Siphelele-Maphumulo/Online-Test-Web-Application/refs/heads/main/images/Design.png" 
                             alt="MUT Logo" 
                             class="header-logo logo-symbol">
                    </a>
                </div>
                <div class="institution-name">CODE SA TESTINGS</div>
            </div>
            <h1 class="report-title">ATTENDANCE REGISTER</h1>
            <div class="report-subtitle">CodeSA Institute Pty Ltd | Official Examination Records</div>
        </div>
        
        <!-- Metadata Section -->
        <div class="metadata-section">
            <div class="metadata-grid">
                <div class="metadata-card">
                    <div class="metadata-label">Report Generated</div>
                    <div class="metadata-value"><%= new SimpleDateFormat("dd MMMM yyyy 'at' HH:mm:ss").format(now) %></div>
                </div>
                <div class="metadata-card">
                    <div class="metadata-label">Generated By</div>
                    <div class="metadata-value"><%= currentUserFullName %></div>
                </div>
                <div class="metadata-card">
                    <div class="metadata-label">Report ID</div>
                    <div class="metadata-value">EXR-<%= timestamp %></div>
                </div>
            </div>
        </div>
        
        <!-- Filters Section -->
        <div class="filters-section">
            <div class="filters-grid">
                <% 
                    boolean hasFilters = false;
                    String[] filters = new String[6];
                    
                    if (examId > 0) { 
                        filters[0] = "Exam ID: " + examId;
                        hasFilters = true;
                    }
                    if (studentId > 0) { 
                        filters[1] = "Student ID: " + studentId;
                        hasFilters = true;
                    }
                    if (!firstName.isEmpty()) { 
                        filters[2] = "First Name: " + firstName;
                        hasFilters = true;
                    }
                    if (!lastName.isEmpty()) { 
                        filters[3] = "Last Name: " + lastName;
                        hasFilters = true;
                    }
                    if (!courseName.isEmpty()) { 
                        filters[4] = "Course: " + courseName;
                        hasFilters = true;
                    }
                    if (!examDate.isEmpty()) { 
                        filters[5] = "Date: " + examDate;
                        hasFilters = true;
                    }
                    
                    if (hasFilters) {
                        for (String filter : filters) {
                            if (filter != null) {
                %>
                <div class="filter-item">
                    <span class="filter-label">?</span> <%= filter %>
                </div>
                <%
                            }
                        }
                    } else {
                %>
                <div class="filter-item">
                    <span class="filter-label">?</span> All Records (No Filters Applied)
                </div>
                <%
                    }
                %>
            </div>
        </div>
        
        <!-- Data Section -->
        <div class="data-section">
            <table class="data-table">
                <thead>
                    <tr>
                        <th class="col-serial">#</th>
                        <th class="col-name">Student Name</th>
                        <th class="col-id">Student ID</th>
                        <th class="col-course">Course</th>
                        <th class="col-exam-id">Exam ID</th>
                        <th class="col-date">Exam Date</th>
                        <th class="col-time">Start Time</th>
                        <th class="col-time">End Time</th>
                        <th class="col-duration">Duration</th>
                        <th class="col-email">Email</th>
                        <th class="col-status">Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        ResultSet rs = pDAO.getFilteredExamRegister(examId, studentId, firstName, lastName, courseName, examDate);
                        
                        int count = 0;
                        int completedCount = 0;
                        int inCompleteCount = 0;
                        long totalDuration = 0;
                        
                        if (rs != null) {
                            while (rs.next()) {
                                count++;
                                String rsFirstName = rs.getString("first_name");
                                String rsLastName = rs.getString("last_name");
                                int rsStudentId = rs.getInt("student_id");
                                String course = rs.getString("course_name");
                                int currentExamId = rs.getInt("exam_id");
                                Date examDateObj = rs.getDate("exam_date");
                                Time examStartTime = rs.getTime("start_time");
                                Time examEndTime = rs.getTime("end_time");
                                String email = rs.getString("email");
                                
                                String studentName = (rsFirstName != null ? rsFirstName.trim() : "") + " " + 
                                                   (rsLastName != null ? rsLastName.trim() : "");
                                
                                // Calculate duration
                                String duration = "N/A";
                                long durationMillis = 0;
                                if (examEndTime != null && examStartTime != null) {
                                    long startMillis = examStartTime.getTime();
                                    long endMillis = examEndTime.getTime();
                                    durationMillis = endMillis - startMillis;
                                    totalDuration += durationMillis;
                                    
                                    long seconds = durationMillis / 1000;
                                    long hours = seconds / 3600;
                                    long minutes = (seconds % 3600) / 60;
                                    long secs = seconds % 60;
                                    duration = String.format("%02d:%02d:%02d", hours, minutes, secs);
                                }
                                
                                String status = "incomplete";
                                String statusClass = "status-incomplete";
                                if (examEndTime != null) {
                                    status = "Completed";
                                    statusClass = "status-completed";
                                    completedCount++;
                                } else {
                                    inCompleteCount++;
                                }
                                
                                // Format date
                                String formattedDate = "N/A";
                                if (examDateObj != null) {
                                    formattedDate = new SimpleDateFormat("dd-MMM-yyyy").format(examDateObj);
                                }
                                
                                // Format times
                                String formattedStartTime = "N/A";
                                if (examStartTime != null) {
                                    formattedStartTime = examStartTime.toString().substring(0, 5);
                                }
                                
                                String formattedEndTime = "N/A";
                                if (examEndTime != null) {
                                    formattedEndTime = examEndTime.toString().substring(0, 5);
                                }
                %>
                <tr>
                    <td class="text-center"><%= count %></td>
                    <td><strong><%= studentName %></strong></td>
                    <td class="text-center"><code><%= rsStudentId %></code></td>
                    <td><%= course %></td>
                    <td class="text-center"><%= currentExamId %></td>
                    <td class="text-center"><%= formattedDate %></td>
                    <td class="text-center"><%= formattedStartTime %></td>
                    <td class="text-center"><%= formattedEndTime %></td>
                    <td class="text-center"><%= duration %></td>
                    <td><small><%= email != null ? email : "N/A" %></small></td>
                    <td class="text-center">
                        <span class="status-badge <%= statusClass %>"><%= status %></span>
                    </td>
                </tr>
                <%
                            }
                        }
                        
                        // Calculate statistics
                        double completionRate = count > 0 ? (completedCount * 100.0) / count : 0;
                        long avgDuration = count > 0 ? totalDuration / count : 0;
                        long avgSeconds = avgDuration / 1000;
                        long avgHours = avgSeconds / 3600;
                        long avgMinutes = (avgSeconds % 3600) / 60;
                        long avgSecs = avgSeconds % 60;
                        String avgDurationStr = avgDuration > 0 ? String.format("%02d:%02d:%02d", avgHours, avgMinutes, avgSecs) : "N/A";
                        
                %>
                </tbody>
            </table>
            
            <!-- Summary Section -->
            <% if (count > 0) { %>
            <div class="summary-section">
                <div class="summary-title">PERFORMANCE SUMMARY</div>
                <div class="summary-grid">
                    <div class="summary-card">
                        <div class="summary-value"><%= count %></div>
                        <div class="summary-label">Total Records</div>
                    </div>
                    <div class="summary-card highlight-stat">
                        <div class="summary-value"><%= completedCount %></div>
                        <div class="summary-label">Exams Completed</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-value"><%= inCompleteCount %></div>
                        <div class="summary-label">In Progress</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-value"><%= avgDurationStr %></div>
                        <div class="summary-label">Avg Duration</div>
                    </div>
                    <div class="summary-card highlight-stat">
                        <div class="summary-value"><%= String.format("%.1f%%", completionRate) %></div>
                        <div class="summary-label">Completion Rate</div>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div style="text-align: center; padding: 40px; color: var(--dark-gray);">
                <div style="font-size: 24px; margin-bottom: 10px;">?</div>
                <h3 style="color: var(--primary-blue); margin-bottom: 10px;">No Records Found</h3>
                <p>No exam register records match the specified criteria.</p>
            </div>
            <% } %>
            
        </div>
        
        <!-- Report Footer -->
        <div class="report-footer">
            <div class="footer-text">This is an official document generated by the Professional Testing System</div>
            <div class="footer-text">Report ID: <span class="report-id">EXR-<%= timestamp %></span> | System Version: 2.1</div>
            <div class="footer-text">� <%= new SimpleDateFormat("yyyy").format(now) %> CodeSA Institute Pty Ltd. All rights reserved.</div>
            <div class="footer-text" style="margin-top: 10px; font-size: 11px; color: var(--dark-gray);">
                Document Classification: INTERNAL USE | Valid until: <%= new SimpleDateFormat("dd MMM yyyy").format(new Date(now.getTime() + 3L * 30 * 24 * 60 * 60 * 1000)) %>
            </div>
        </div>
    </div>
    
    <script>
        // Modal functions
        function showDeleteModal(examId, studentId, studentName, course, examDate) {
            document.getElementById('deleteExamIdInput').value = examId;
            document.getElementById('deleteStudentIdInput').value = studentId;
            
            // Display record details in modal
            document.getElementById('recordDetails').innerHTML = 
                '<strong>Exam ID:</strong> ' + examId + '<br>' +
                '<strong>Student ID:</strong> ' + studentId + '<br>' +
                '<strong>Name:</strong> ' + studentName + '<br>' +
                '<strong>Course:</strong> ' + course + '<br>' +
                '<strong>Exam Date:</strong> ' + examDate;
            
            document.getElementById('deleteModal').style.display = 'block';
        }
        
        function closeModal() {
            document.getElementById('deleteModal').style.display = 'none';
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            var modal = document.getElementById('deleteModal');
            if (event.target == modal) {
                closeModal();
            }
        }
        
        // Add confirmation before form submission
        document.getElementById('deleteForm').addEventListener('submit', function(e) {
            if (!confirm('Are you absolutely sure? This record will be permanently deleted.')) {
                e.preventDefault();
                closeModal();
            }
        });
    </script>
</body>
</html>
<%
    } catch (SQLException e) {
        // Error handling
        out.println("<div style='padding: 40px; text-align: center; color: #dc2626;'>");
        out.println("<h3>ERROR GENERATING REPORT</h3>");
        out.println("<p>" + e.getMessage() + "</p>");
        out.println("</div>");
    }
%>