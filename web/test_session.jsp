<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Object userIdObj = session.getAttribute("userId");
    Object userStatusObj = session.getAttribute("userStatus");
    
    out.println("<h2>Session Debug Information</h2>");
    out.println("<p><strong>userId:</strong> " + (userIdObj != null ? userIdObj.toString() : "NULL") + "</p>");
    out.println("<p><strong>userStatus:</strong> " + (userStatusObj != null ? userStatusObj.toString() : "NULL") + "</p>");
    out.println("<p><strong>Session ID:</strong> " + session.getId() + "</p>");
    
    if (userIdObj != null && userStatusObj != null && "1".equals(userStatusObj.toString())) {
        out.println("<p style='color: green;'><strong>Session is valid!</strong></p>");
        out.println("<p><a href='std-page.jsp?pgprt=1'>Go to Exams Page</a></p>");
        out.println("<p><a href='std-page.jsp?pgprt=2'>Go to Results Page</a></p>");
    } else {
        out.println("<p style='color: red;'><strong>Session is invalid or expired!</strong></p>");
        out.println("<p><a href='login.jsp'>Go to Login Page</a></p>");
    }
%>