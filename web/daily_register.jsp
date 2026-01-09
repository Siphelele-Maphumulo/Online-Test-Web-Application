<%-- 
    Document   : daily_register.jsp
    Created on : Jan 4, 2026, 12:48:41 PM
    Author     : CodeSA Siphelele
--%>

<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="myPackage.DatabaseClass" %>
<%@page import="myPackage.classes.User" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Daily Attendance Register</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/vanilla-js-calendar@1.6.5/build/vanilla-js-calendar.min.css">
    </head>
    <body>
        <%
            // Authentication check
            if (session.getAttribute("userId") == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            int userId = Integer.parseInt(session.getAttribute("userId").toString());
            DatabaseClass pDAO = DatabaseClass.getInstance();
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            // Determine user type
            String userType = (String) session.getAttribute("userType");
            if (userType == null) {
                User user = pDAO.getUserDetails(String.valueOf(userId));
                if (user != null) {
                    userType = user.getType();
                    session.setAttribute("userType", userType);
                }
            }

            // Redirect non-students to appropriate pages
            if ("admin".equals(userType)) {
                response.sendRedirect("adm-page.jsp?pgprt=7");
                return;
            } else if ("lecture".equals(userType)) {
                response.sendRedirect("lec-page.jsp");
                return;
            }

            // Get student details
            User student = pDAO.getUserDetails(String.valueOf(userId));
            String studentName = "Student";
            String studentEmail = "";
            
            if (student != null) {
                studentName = student.getFirstName() + " " + student.getLastName();
                studentEmail = student.getEmail();
            }
            
            // Get today's date
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
            String todayDate = sdf.format(new java.util.Date());
            
            // Check if attendance already marked today
            boolean attendanceMarkedToday = false;
            try {
                conn = pDAO.getConnection();
                String checkQuery = "SELECT COUNT(*) as count FROM daily_register WHERE student_id = ? AND DATE(registration_date) = ?";
                pstmt = conn.prepareStatement(checkQuery);
                pstmt.setInt(1, userId);
                pstmt.setString(2, todayDate);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    attendanceMarkedToday = rs.getInt("count") > 0;
                }
            } catch (Exception e) {
                attendanceMarkedToday = false;
            } finally {
                // Close resources
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            }
            
            // Handle attendance marking if form was submitted
            String operation = request.getParameter("operation");
            if ("mark_attendance".equals(operation) && !attendanceMarkedToday) {
                boolean marked = pDAO.markAttendance(userId, studentName);
                if (marked) {
                    session.setAttribute("message", "Attendance marked successfully!");
                    attendanceMarkedToday = true;
                } else {
                    session.setAttribute("error", "Failed to mark attendance. Please try again.");
                }
            }
            
            // Get attendance history
            ArrayList<Map<String, String>> attendanceHistory = null;
            try {
                attendanceHistory = pDAO.getAttendanceByStudentId(userId);
            } catch (Exception e) {
                // Handle error - table might not exist yet
            }
            
            // Get filter parameters
            String filterDate = request.getParameter("filter_date");
            if (filterDate == null || filterDate.isEmpty()) {
                filterDate = todayDate;
            }
            
            String filterCourse = request.getParameter("filter_course");
            if (filterCourse == null) filterCourse = "";
            
            // Get student courses for dropdown
            List<String> studentCourses = new ArrayList<>();
            try {
                conn = pDAO.getConnection();
                String coursesQuery = "SELECT DISTINCT course_name FROM exam_register WHERE student_id = ?";
                pstmt = conn.prepareStatement(coursesQuery);
                pstmt.setInt(1, userId);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String course = rs.getString("course_name");
                    if (course != null && !course.trim().isEmpty()) {
                        studentCourses.add(course.trim());
                    }
                }
            } catch (Exception e) {
                // Add default courses if query fails
                studentCourses.add("Computer Science");
                studentCourses.add("Mathematics");
                studentCourses.add("Physics");
            } finally {
                // Close resources
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
            
            // Calculate attendance statistics
            int totalDays = 0;
            int presentDays = 0;
            
            if (attendanceHistory != null) {
                totalDays = attendanceHistory.size();
                presentDays = totalDays; // In this simple system, all recorded days are present days
            }
            
            int attendanceRate = totalDays > 0 ? (presentDays * 100 / totalDays) : 0;
            int absentDays = pDAO.getDaysAbsentCount(userId);
            int lateDays = pDAO.getDaysLateCount(userId);
        %>

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
            
            /* Sidebar Styles - Enhanced */
            .sidebar {
                width: 220px;
                background: linear-gradient(180deg, var(--primary-blue), #0f3c7a);
                color: var(--white);
                flex-shrink: 0;
                position: sticky;
                top: 0;
                height: 100vh;
                overflow-y: auto;
                overflow-x: hidden;
                z-index: var(--z-sidebar);
                box-shadow: var(--shadow-md);
                border-right: 1px solid rgba(255, 255, 255, 0.1);
            }

            .sidebar::-webkit-scrollbar {
                width: 8px;
            }

            .sidebar::-webkit-scrollbar-thumb {
                background: rgba(255, 255, 255, 0.25);
                border-radius: var(--radius-full);
                transition: background var(--transition-fast);
            }

            .sidebar::-webkit-scrollbar-thumb:hover {
                background: rgba(255, 255, 255, 0.4);
            }

            .sidebar::-webkit-scrollbar-track {
                background: transparent;
            }

            .sidebar-header {
                padding: var(--spacing-xl) var(--spacing-lg);
                text-align: center;
                border-bottom: 1px solid rgba(255, 255, 255, 0.15);
                position: relative;
                overflow: hidden;
            }

            .sidebar-header::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, var(--accent-blue), #3b82f6);
            }

            .mut-logo {
                max-height: 140px;
                width: auto;
                filter: brightness(0) invert(1);
                transition: transform var(--transition-normal);
            }

            .mut-logo:hover {
                transform: scale(1.05);
            }

            .sidebar-nav {
                padding: var(--spacing-md) 0;
            }
    
            
            /* Main Content Area */
            .content-area,
            .main-content {
                flex: 1;
                padding: var(--spacing-xl);
                overflow-y: auto;
                background: transparent;
                margin-left: 180px;
                min-height: 100vh;
            }

            /* Navigation Items */
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
            
            .nav-item span {
                margin: 0;
                font-size: 14px;
                font-weight: 500;
                letter-spacing: 0.3px;
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
            
            /* Cards */
            .course-card {
                background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
                border-radius: var(--radius-lg);
                box-shadow: var(--shadow-md);
                border: 1px solid var(--border-color);
                padding: var(--spacing-xl);
                margin-bottom: var(--spacing-xl);
                transition: transform var(--transition-normal), box-shadow var(--transition-normal);
                position: relative;
                overflow: hidden;
            }
            
            .course-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 4px;
                background: linear-gradient(90deg, var(--accent-blue), var(--success));
            }
            
            .course-card:hover {
                transform: translateY(-4px);
                box-shadow: var(--shadow-xl);
            }
            
            .results-card {
                background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
                border-radius: var(--radius-lg);
                box-shadow: var(--shadow-md);
                border: 1px solid var(--border-color);
                margin-bottom: var(--spacing-xl);
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
            
            /* Student Info Card */
            .student-info-card {
                background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
                color: var(--white);
                border-radius: var(--radius-lg);
                padding: var(--spacing-xl);
                margin-bottom: var(--spacing-xl);
                box-shadow: var(--shadow-lg);
                position: relative;
                overflow: hidden;
            }
            
            .student-info-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 4px;
                background: linear-gradient(90deg, var(--accent-blue), var(--success));
            }
            
            .student-info-card h3 {
                font-size: 18px;
                font-weight: 600;
                margin-bottom: var(--spacing-lg);
                display: flex;
                align-items: center;
                gap: var(--spacing-md);
            }
            
            .student-info-card p {
                font-size: 15px;
                opacity: 0.95;
                margin-bottom: var(--spacing-md);
                display: flex;
                align-items: center;
                gap: var(--spacing-sm);
            }
            
            .student-info-card p i {
                width: 20px;
                opacity: 0.8;
            }
            
            /* Filter Container */
            .filter-container {
                background: linear-gradient(135deg, var(--white) 0%, #fafcff 100%);
                border-radius: var(--radius-lg);
                border: 1px solid var(--border-color);
                padding: var(--spacing-xl);
                margin-bottom: var(--spacing-xl);
                box-shadow: var(--shadow-md);
                position: relative;
                overflow: hidden;
            }
            
            .filter-container::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 4px;
                background: linear-gradient(90deg, var(--accent-blue), var(--success));
            }
            
            .filter-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: var(--spacing-lg);
                margin-bottom: var(--spacing-md);
            }
            
            .filter-group {
                display: flex;
                flex-direction: column;
            }
            
            .filter-label {
                font-weight: 600;
                color: var(--text-dark);
                font-size: 14px;
                margin-bottom: var(--spacing-sm);
                display: flex;
                align-items: center;
                gap: var(--spacing-sm);
            }
            
            .filter-control,
            .filter-select {
                padding: 12px 16px;
                border: 2px solid var(--border-color);
                border-radius: var(--radius-md);
                font-size: 15px;
                transition: all var(--transition-fast);
                background: var(--white);
                color: var(--text-dark);
                font-family: inherit;
            }
            
            .filter-control:focus,
            .filter-select:focus {
                outline: none;
                border-color: var(--accent-blue);
                box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
                transform: translateY(-1px);
            }
            
            .filter-select {
                appearance: none;
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3E%3Cpath fill='%2364748b' d='M8 11L3 6h10l-5 5z'/%3E%3C/svg%3E");
                background-repeat: no-repeat;
                background-position: right 16px center;
                background-size: 16px;
                padding-right: 48px;
            }
            
            /* Quick Filters */
            .quick-filter-row {
                display: flex;
                flex-wrap: wrap;
                gap: var(--spacing-sm);
                margin-top: var(--spacing-lg);
                padding-top: var(--spacing-lg);
                border-top: 1px solid var(--border-color);
            }
            
            /* Buttons */
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
            
            .btn-success {
                background: linear-gradient(135deg, var(--success), #34d399);
                color: var(--white);
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
            }
            
            .btn-success:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(16, 185, 129, 0.35);
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
            
            /* Attendance Status */
            .attendance-status {
                display: flex;
                align-items: center;
                gap: var(--spacing-sm);
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
            
            .status-present {
                background: linear-gradient(135deg, var(--success), #34d399);
                color: var(--white);
            }
            
            .status-absent {
                background: linear-gradient(135deg, var(--error), #f87171);
                color: var(--white);
            }
            
            .status-late {
                background: linear-gradient(135deg, var(--warning), #fbbf24);
                color: var(--white);
            }
            
            /* Results Table */
            .results-table-container {
                overflow-x: auto;
                border-radius: var(--radius-lg);
                box-shadow: var(--shadow-md);
                border: 1px solid var(--border-color);
                background: var(--white);
                margin-top: var(--spacing-lg);
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
            
            /* No Results Message */
            .no-results {
                text-align: center;
                padding: var(--spacing-2xl) var(--spacing-xl);
                color: var(--dark-gray);
                background: var(--white);
                border-radius: var(--radius-lg);
                box-shadow: var(--shadow-md);
                border: 1px solid var(--border-color);
            }
            
            .no-results i {
                font-size: 64px;
                color: var(--dark-gray);
                margin-bottom: var(--spacing-lg);
                opacity: 0.5;
            }
            
            .no-results h2 {
                font-size: 24px;
                font-weight: 600;
                margin-bottom: var(--spacing-md);
                color: var(--text-dark);
            }
            
            .no-results p {
                color: var(--dark-gray);
                margin-bottom: var(--spacing-xl);
                max-width: 400px;
                margin-left: auto;
                margin-right: auto;
            }
            
            .results-count {
                text-align: center;
                padding: var(--spacing-lg);
                color: var(--dark-gray);
                font-size: 14px;
                border-top: 2px solid var(--border-color);
                background: linear-gradient(180deg, var(--light-gray) 0%, #f1f5f9 100%);
                font-weight: 500;
            }
            
            /* Attendance Statistics Grid */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: var(--spacing-lg);
                margin-top: var(--spacing-lg);
            }
            
            .stat-card {
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
            
            .stat-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 4px;
                background: linear-gradient(90deg, var(--accent-blue), var(--success));
            }
            
            .stat-card:hover {
                transform: translateY(-4px);
                box-shadow: var(--shadow-xl);
                border-color: var(--accent-blue);
            }
            
            .stat-value {
                font-size: 28px;
                font-weight: 700;
                color: var(--text-dark);
                margin-bottom: var(--spacing-sm);
                line-height: 1.2;
            }
            
            .stat-label {
                color: var(--dark-gray);
                font-weight: 600;
                font-size: 14px;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: var(--spacing-xs);
            }
            
            .stat-label i {
                color: var(--accent-blue);
                font-size: 14px;
            }
            
            /* Start Exam Button */
            .start-exam-btn {
                background: linear-gradient(135deg, var(--success), #34d399);
                color: var(--white);
                padding: 14px 28px;
                border-radius: var(--radius-md);
                border: none;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all var(--transition-normal);
                display: inline-flex;
                align-items: center;
                gap: var(--spacing-sm);
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
                font-family: inherit;
                position: relative;
                overflow: hidden;
            }
            
            .start-exam-btn::after {
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
            
            .start-exam-btn:hover::after {
                transform: translateX(100%);
            }
            
            .start-exam-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(16, 185, 129, 0.35);
            }
            
            .start-exam-btn:disabled {
                background: var(--medium-gray);
                cursor: not-allowed;
                transform: none;
                box-shadow: none;
            }
            
            /* Responsive Design */
            @media (max-width: 768px) {
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
                
                .nav-item:hover {
                    padding-left: var(--spacing-md);
                }
                
                .content-area,
                .main-content {
                    padding: var(--spacing-lg);
                    margin-left: 0;
                }
                
                .page-header {
                    flex-direction: column;
                    gap: var(--spacing-lg);
                    text-align: center;
                    padding: var(--spacing-lg);
                }
                
                .filter-grid {
                    grid-template-columns: 1fr;
                }
                
                .stats-grid {
                    grid-template-columns: 1fr;
                }
                
                .results-table-container {
                    overflow-x: auto;
                }
                
                .results-table thead th,
                .results-table tbody td {
                    padding: var(--spacing-md);
                    font-size: 13px;
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
                
                .filter-container {
                    padding: var(--spacing-md);
                }
                
                .start-exam-btn {
                    padding: 12px 20px;
                    font-size: 15px;
                }
            }
        </style>

        <%@ include file="header-messages.jsp" %>
        <%@ include file="modal_assets.jspf" %>

        <div class="results-wrapper">
            <!-- Sidebar Navigation -->
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
                            <span>Exams</span>
                        </a>
                        <a class="nav-item" href="std-page.jsp?pgprt=2">
                            <i class="fas fa-chart-line"></i>
                            <span>Results</span>
                        </a>
                        <a class="nav-item active" href="std-page.jsp?pgprt=3">
                            <i class="fas fa-calendar-check"></i>
                            <span>Register</span>
                        </a>
                        <a class="nav-item" href="std-page.jsp?pgprt=4">
                            <i class="fas fa-eye"></i>
                            <span>Attendance</span>
                        </a>
                    </div>
                </nav>
            </aside>

            <div class="main-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div class="page-title">
                        <i class="fas fa-calendar-check"></i> Daily Attendance Register
                    </div>
                    <div class="stats-badge">
                        <i class="fas fa-user-graduate"></i> Student Portal
                    </div>
                </div>

                <!-- Alert Messages -->
                <% if (session.getAttribute("message") != null) { %>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i>
                        <%= session.getAttribute("message") %>
                    </div>
                    <% session.removeAttribute("message"); %>
                <% } %>
                
                <% if (session.getAttribute("error") != null) { %>
                    <div class="alert alert-error">
                        <i class="fas fa-exclamation-circle"></i>
                        <%= session.getAttribute("error") %>
                    </div>
                    <% session.removeAttribute("error"); %>
                <% } %>

                <!-- Student Information -->
                <div class="student-info-card">
                    <h3><i class="fas fa-user-circle"></i> Student Information</h3>
                    <p><i class="fas fa-user"></i> <strong>Name:</strong> <%= studentName %></p>
                    <p><i class="fas fa-id-card"></i> <strong>Student ID:</strong> <%= userId %></p>
                    <% if (!studentEmail.isEmpty()) { %>
                        <p><i class="fas fa-envelope"></i> <strong>Email:</strong> <%= studentEmail %></p>
                    <% } %>
                    <p><i class="fas fa-calendar-day"></i> <strong>Today's Date:</strong> <%= todayDate %></p>
                </div>

                <!-- Today's Attendance Card -->
                <div class="course-card">
                    <h3 style="margin-bottom: var(--spacing-md); color: var(--text-dark); font-size: 18px;">
                        <i class="fas fa-calendar-day"></i> Today's Attendance
                    </h3>
                    
                    <% if (attendanceMarkedToday) { %>
                        <div class="attendance-status status-present" style="margin-bottom: var(--spacing-lg);">
                            <i class="fas fa-check-circle"></i> Attendance already marked for today
                        </div>
                        <p style="color: var(--dark-gray); margin-bottom: var(--spacing-lg); font-size: 15px;">
                            You have successfully marked your attendance for <strong><%= todayDate %></strong>.
                        </p>
                        <button class="start-exam-btn" disabled>
                            <i class="fas fa-check"></i> Attendance Marked
                        </button>
                    <% } else { %>
                        <div class="attendance-status status-absent" style="margin-bottom: var(--spacing-lg);">
                            <i class="fas fa-exclamation-circle"></i> Attendance not marked for today
                        </div>
                        <p style="color: var(--dark-gray); margin-bottom: var(--spacing-lg); font-size: 15px;">
                            Please mark your attendance for <strong><%= todayDate %></strong> by clicking the button below.
                        </p>
                        <form method="post" onsubmit="return confirm('Are you sure you want to mark attendance for today?');">
                            <input type="hidden" name="operation" value="mark_attendance">
                            <button type="submit" class="start-exam-btn">
                                <i class="fas fa-check"></i> Mark Today's Attendance
                            </button>
                        </form>
                    <% } %>
                </div>

                <!-- Attendance History -->
                <div class="course-card">
                    <h3 style="margin-bottom: var(--spacing-md); color: var(--text-dark); font-size: 18px;">
                        <i class="fas fa-history"></i> Attendance History
                    </h3>
                    <% if (attendanceHistory != null && !attendanceHistory.isEmpty()) { %>
                        <form id="bulkDeleteForm" action="controller.jsp" method="post">
                            <input type="hidden" name="page" value="daily-register">
                            <input type="hidden" name="operation" value="bulk_delete">
                            <input type="hidden" name="csrf_token" value="<%= session.getAttribute("csrf_token") %>">
                            <button type="submit" class="btn btn-error" style="margin-bottom: 20px;">
                                <i class="fas fa-trash"></i> Delete Selected
                            </button>
                            <div class="results-table-container">
                                <table class="results-table">
                                    <thead>
                                        <tr>
                                            <th><input type="checkbox" id="selectAll"></th>
                                            <th>#</th>
                                            <th>Date</th>
                                            <th>Time</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            int i = 0;
                                            for (Map<String, String> record : attendanceHistory) {
                                                i++;
                                        %>
                                        <tr>
                                            <td><input type="checkbox" name="registerIds" value="<%= record.get("register_id") %>"></td>
                                            <td><%= i %></td>
                                            <td><%= record.get("registration_date") %></td>
                                            <td><%= record.get("registration_time") %></td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </form>
                    <% } else { %>
                        <div class="no-results">
                            No attendance history found.
                        </div>
                    <% } %>
                </div>

                <!-- Attendance Statistics -->
                <div class="course-card">
                    <h3 style="margin-bottom: var(--spacing-md); color: var(--text-dark); font-size: 18px;">
                        <i class="fas fa-chart-pie"></i> Attendance Statistics
                    </h3>
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value" style="color: var(--success);"><%= attendanceRate %>%</div>
                            <div class="stat-label">
                                <i class="fas fa-chart-line"></i> Attendance Rate
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" style="color: var(--accent-blue);"><%= presentDays %></div>
                            <div class="stat-label">
                                <i class="fas fa-check-circle"></i> Days Present
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" style="color: var(--error);"><%= absentDays %></div>
                            <div class="stat-label">
                                <i class="fas fa-times-circle"></i> Days Absent
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" style="color: var(--warning);"><%= lateDays %></div>
                            <div class="stat-label">
                                <i class="fas fa-clock"></i> Days Late
                            </div>
                        </div>
                    </div>
                    <p style="margin-top: var(--spacing-lg); font-size: 14px; color: var(--dark-gray); text-align: center;">
                        Based on <%= totalDays %> recorded attendance days.
                    </p>
                    <div id="calendar-container" style="margin-top: 20px;"></div>
                </div>
            </div>
        </div>

<style>
    .event-present { background-color: #28a745 !important; color: white !important; }
    .event-late { background-color: #ffc107 !important; color: white !important; }
    .event-absent { background-color: #dc3545 !important; color: white !important; }
</style>

<div id="deleteConfirmationModal" class="modal-overlay" style="display: none;">
  <div class="modal-content">
    <div class="modal-header">
      <h2 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Confirm Deletion</h2>
      <button class="close-button" onclick="closeModal()">&times;</button>
    </div>
    <div class="modal-body">
      <p id="deleteModalMessage">Are you sure you want to delete the selected records?</p>
    </div>
    <div class="modal-footer">
      <button onclick="closeModal()" class="btn btn-secondary">Cancel</button>
      <button id="confirmDeleteBtn" class="btn btn-danger">Delete</button>
    </div>
  </div>
</div>

        <script src="https://cdn.jsdelivr.net/npm/vanilla-js-calendar@1.6.5/build/vanilla-js-calendar.min.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const calendar = new VanillaJsCalendar('#calendar-container', {
                    events: JSON.parse('<%= pDAO.getAttendanceCalendarData(userId) %>'),
                });
            });

            // Add confirmation for marking attendance
            document.addEventListener('DOMContentLoaded', function() {
                const markBtn = document.querySelector('.start-exam-btn');
                if (markBtn && !markBtn.disabled) {
                    markBtn.addEventListener('click', function(e) {
                        if (!confirm('Are you sure you want to mark your attendance for today?')) {
                            e.preventDefault();
                        }
                    });
                }

                const selectAllCheckbox = document.getElementById('selectAll');
                if (selectAllCheckbox) {
                    selectAllCheckbox.addEventListener('change', function(e) {
                        const checkboxes = document.querySelectorAll('input[name="registerIds"]');
                        checkboxes.forEach(checkbox => {
                            checkbox.checked = e.target.checked;
                        });
                    });
                }

                const bulkDeleteForm = document.getElementById('bulkDeleteForm');
                if (bulkDeleteForm) {
                    bulkDeleteForm.addEventListener('submit', function(e) {
                        e.preventDefault();
                        const selected = document.querySelectorAll('input[name="registerIds"]:checked').length;
                        if (selected === 0) {
                            showAlert('Please select at least one record to delete.');
                            return;
                        }
                        
                        document.getElementById('deleteModalMessage').innerText = 'Are you sure you want to delete ' + selected + ' record(s)?';
                        showModal();

                        document.getElementById('confirmDeleteBtn').onclick = function() {
                            e.target.submit();
                        };
                    });
                }
                
                // Set today's date as default in date filter
                const dateFilter = document.querySelector('input[name="filter_date"]');
                if (dateFilter && !dateFilter.value) {
                    const today = new Date().toISOString().split('T')[0];
                    dateFilter.value = today;
                }
                
                // Add loading state to buttons
                const forms = document.querySelectorAll('form');
                forms.forEach(form => {
                    form.addEventListener('submit', function() {
                        const submitBtn = this.querySelector('button[type="submit"]');
                        if (submitBtn) {
                            submitBtn.classList.add('loading');
                            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
                        }
                    });
                });
            });
        </script>
    </body>
</html>