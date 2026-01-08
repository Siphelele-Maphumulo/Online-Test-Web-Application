<%@page import="myPackage.DatabaseClass"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%
    String examIdParam = request.getParameter("examId");
    
    try {
        DatabaseClass pDAO = DatabaseClass.getInstance();
        int examId = Integer.parseInt(examIdParam);
        boolean success = pDAO.deleteExamResult(examId);
        
        if (success) {
            out.print("{\"success\": true, \"message\": \"Result deleted successfully\"}");
        } else {
            out.print("{\"success\": false, \"message\": \"Failed to delete result\"}");
        }
    } catch (Exception e) {
        out.print("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
    }
%>