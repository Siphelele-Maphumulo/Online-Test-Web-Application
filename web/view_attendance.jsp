
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.User"%>
<%
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    User currentUser = (User) session.getAttribute("currentUser");
    ArrayList<Map<String, String>> attendanceList = pDAO.getAttendanceByStudentId(currentUser.getUserId());
%>
<div class="page-header">
    <div class="page-title"><i class="fas fa-eye"></i> View Attendance</div>
</div>
<div class="course-card">
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Time</th>
            </tr>
        </thead>
        <tbody>
            <% for (Map<String, String> attendance : attendanceList) { %>
                <tr>
                    <td><%= attendance.get("registration_date") %></td>
                    <td><%= attendance.get("registration_time") %></td>
                </tr>
            <% } %>
        </tbody>
    </table>
</div>
