<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Authentication and authorization checks
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");
    if (!("admin".equals(userType) || "lecture".equals(userType))) {
        response.sendRedirect("std-page.jsp");
        return;
    }

    // Get filter parameters from request
    String studentNameFilter = request.getParameter("student_name");
    if (studentNameFilter == null) studentNameFilter = "";

    String dateFilter = request.getParameter("registration_date");
    if (dateFilter == null) dateFilter = "";

    // Instantiate DAO and fetch data using the new method
    DatabaseClass pDAO = DatabaseClass.getInstance();
    ArrayList<Map<String, String>> registerList = pDAO.getFilteredDailyRegister(studentNameFilter, dateFilter);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Register Log</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="style-backend.css">
</head>
<body>
<div class="dashboard-container">
    <!-- Sidebar -->
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
            <a href="adm-page.jsp?pgprt=3" class="nav-item">
                <i class="fas fa-question-circle"></i>
                <h2>Questions</h2>
            </a>
            <a href="adm-page.jsp?pgprt=5" class="nav-item">
                <i class="fas fa-chart-bar"></i>
                <h2>Results</h2>
            </a>
            <a href="adm-page.jsp?pgprt=1" class="nav-item">
                <i class="fas fa-user-graduate"></i>
                <h2>Student Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=6" class="nav-item">
                <i class="fas fa-chalkboard-teacher"></i>
                <h2>Lecture Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=7" class="nav-item">
               <i class="fas fa-users"></i>
               <h2>Exam Registers</h2>
           </a>
           <a href="adm-page.jsp?pgprt=8" class="nav-item active">
               <i class="fas fa-clipboard-list"></i>
               <h2>Class Registers</h2>
           </a>
        </nav>
    </aside>

    <div class="main-content">
        <!-- Header -->
        <div class="page-header">
            <div class="page-title">
                <i class="fas fa-clipboard-list"></i> Class Register Log
            </div>
        </div>

        <!-- Filter Container -->
        <div class="filter-container">
            <form method="get" action="adm-page.jsp">
                <input type="hidden" name="pgprt" value="8">
                <div class="filter-grid">
                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-user"></i> Student Name</label>
                        <input type="text" name="student_name" class="filter-control" value="<%= studentNameFilter %>" placeholder="Search by name...">
                    </div>
                    <div class="filter-group">
                        <label class="filter-label"><i class="fas fa-calendar-alt"></i> Registration Date</label>
                        <input type="date" name="registration_date" class="filter-control" value="<%= dateFilter %>">
                    </div>
                </div>
                <div class="quick-filter-row">
                    <button class="btn btn-primary" type="submit">
                        <i class="fas fa-search"></i> Apply Filters
                    </button>
                    <a href="adm-page.jsp?pgprt=8" class="btn btn-outline">
                        <i class="fas fa-times"></i> Clear Filters
                    </a>
                    <a href="export-class-register.jsp?student_name=<%= URLEncoder.encode(studentNameFilter, "UTF-8") %>&registration_date=<%= URLEncoder.encode(dateFilter, "UTF-8") %>" class="btn btn-success">
                        <i class="fas fa-file-csv"></i> Export to CSV
                    </a>
                </div>
            </form>
        </div>

        <!-- Results Table -->
        <div class="results-card">
            <div class="card-header">
                <span><i class="fas fa-table"></i> Attendance Records</span>
                <span class="stats-badge"><%= registerList.size() %> Records Found</span>
            </div>

            <% if (!registerList.isEmpty()) { %>
                <div class="results-table-container">
                    <table class="results-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Register ID</th>
                                <th>Student ID</th>
                                <th>Student Name</th>
                                <th>Date</th>
                                <th>Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int i = 0; for (Map<String, String> record : registerList) { i++; %>
                            <tr>
                                <td><%= i %></td>
                                <td><%= record.get("register_id") %></td>
                                <td><%= record.get("student_id") %></td>
                                <td><strong><%= record.get("student_name") %></strong></td>
                                <td><%= record.get("registration_date") %></td>
                                <td><%= record.get("registration_time") %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } else { %>
                <div class="no-results">
                    <i class="fas fa-box-open"></i>
                    <h2>No Records Found</h2>
                    <p>No attendance records match your filter criteria.</p>
                </div>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>