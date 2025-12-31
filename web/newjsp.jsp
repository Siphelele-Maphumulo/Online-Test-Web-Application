<%-- layout.jsp --%>
<%@ page import="myPackage.classes.User" %>
<%@ page import="myPackage.DatabaseClass" %>

<%
    DatabaseClass pDAO = DatabaseClass.getInstance();
    User currentUser = null;
    
    if (session.getAttribute("userId") != null) {
        currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());
    }
    
    String pageTitle = (String) request.getAttribute("pageTitle");
    String contentPage = (String) request.getAttribute("contentPage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle != null ? pageTitle : "Exam System" %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <%@ include file="header-messages.jsp" %>
    
    <div class="dashboard-container">
        <!-- Your layout structure -->
        <jsp:include page="<%= contentPage %>" />
    </div>
</body>
</html>