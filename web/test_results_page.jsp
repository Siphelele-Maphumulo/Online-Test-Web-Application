<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.User"%>
<%
    // Create a test session for debugging
    session.setAttribute("userId", "1");
    session.setAttribute("userStatus", "1");
    
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    User testUser = new User();
    testUser.setFirstName("Test");
    testUser.setLastName("User");
    testUser.setType("student");
    
    // Store user object in request scope for testing
    request.setAttribute("currentUser", testUser);
%>
<jsp:include page="std-page.jsp">
    <jsp:param name="pgprt" value="2"/>
</jsp:include>