<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page contentType="text/csv;charset=UTF-8" language="java" %>
<%
    // Set HTTP headers for CSV download
    response.setHeader("Content-Disposition", "attachment; filename=\"class_register.csv\"");

    // Get filter parameters from the request
    String studentNameFilter = request.getParameter("student_name");
    if (studentNameFilter == null) studentNameFilter = "";

    String dateFilter = request.getParameter("registration_date");
    if (dateFilter == null) dateFilter = "";

    // Fetch the filtered data from the database
    DatabaseClass pDAO = DatabaseClass.getInstance();
    ArrayList<Map<String, String>> registerList = pDAO.getFilteredDailyRegister(studentNameFilter, dateFilter);

    // Write CSV header
    out.print("Register ID,Student ID,Student Name,Registration Date,Registration Time\n");

    // Write CSV data rows
    for (Map<String, String> record : registerList) {
        String studentName = record.get("student_name");
        if (studentName != null) {
            studentName = studentName.replace("\"", "\"\"");
        } else {
            studentName = "";
        }
        out.print(record.get("register_id") + ",");
        out.print(record.get("student_id") + ",");
        out.print("\"" + studentName + "\",");
        out.print(record.get("registration_date") + ",");
        out.print(record.get("registration_time") + "\n");
    }
%>