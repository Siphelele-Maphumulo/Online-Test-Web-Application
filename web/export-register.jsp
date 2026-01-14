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
        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        
        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 20px;
            border-radius: 8px;
            width: 400px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            position: relative;
        }
        
        .modal-header {
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        
        .modal-title {
            font-size: 18px;
            color: #d32f2f;
            font-weight: bold;
        }
        
        .modal-body {
            padding: 10px 0;
            margin-bottom: 15px;
        }
        
        .modal-footer {
            border-top: 1px solid #ddd;
            padding-top: 15px;
            text-align: right;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
            margin-left: 8px;
        }
        
        .btn-danger {
            background-color: #d32f2f;
            color: white;
        }
        
        .btn-danger:hover {
            background-color: #b71c1c;
        }
        
        .btn-secondary {
            background-color: #757575;
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #616161;
        }
        
        .close-btn {
            position: absolute;
            right: 15px;
            top: 15px;
            font-size: 20px;
            cursor: pointer;
            color: #999;
        }
        
        .close-btn:hover {
            color: #333;
        }
        
        /* Delete Button Style */
        .delete-btn {
            background-color: #ff4444;
            color: white;
            border: none;
            padding: 4px 10px;
            border-radius: 3px;
            cursor: pointer;
            font-size: 12px;
            margin: 2px;
        }
        
        .delete-btn:hover {
            background-color: #cc0000;
        }
        
        /* Action Column Style */
        .action-cell {
            text-align: center;
            white-space: nowrap;
        }
        
        /* Status Badges */
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .status-completed {
            background-color: #4caf50;
            color: white;
        }
        
        .status-inprogress {
            background-color: #ff9800;
            color: white;
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
                    <div class="modal-title">Confirm Deletion</div>
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
                    <div class="metadata-value">User ID: <%= session.getAttribute("userId") %></div>
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
                        <th class="col-actions">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        ResultSet rs = pDAO.getFilteredExamRegister(examId, studentId, firstName, lastName, courseName, examDate);
                        
                        int count = 0;
                        int completedCount = 0;
                        int inProgressCount = 0;
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
                                
                                String status = "Incomplete";
                                String statusClass = "status-inprogress";
                                if (examEndTime != null) {
                                    status = "Completed";
                                    statusClass = "status-completed";
                                    completedCount++;
                                } else {
                                    inProgressCount++;
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
                    <td class="action-cell">
                        <button class="delete-btn" 
                                onclick="showDeleteModal('<%= currentExamId %>', '<%= rsStudentId %>', '<%= studentName %>', '<%= course %>', '<%= formattedDate %>')">
                            Delete
                        </button>
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
                        <div class="summary-value"><%= inProgressCount %></div>
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