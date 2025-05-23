<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.classes.User"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.Result"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <link rel="stylesheet" type="text/css" href="style-backend.css">
</head>
<body>

<%
    // Get userId from session
    Object userIdObj = session.getAttribute("userId");

    if (userIdObj == null) {
        // Redirect if no session or invalid login
        response.sendRedirect("login.jsp");
        return;
    }

    String userIdStr = userIdObj.toString();
    User currentUser = pDAO.getUserDetails(userIdStr);

    if (currentUser == null) {
        // If user details not found, redirect to login
        response.sendRedirect("login.jsp");
        return;
    }

    String panelTitle;

    if (currentUser.getType().equalsIgnoreCase("admin")) {
        panelTitle = "Admin Panel";
    } else if (currentUser.getType().equalsIgnoreCase("lecture")) {
        panelTitle = "Lecture Panel";
    } else {
        // For students or unhandled types
        panelTitle = "Student Panel";
    }
%>

<!-- Top Area -->
<div class="top-area">
    <jsp:include page="header.jsp" />
    <center><h2><%= panelTitle %></h2></center>
</div>

<%
    // Check if user is logged in
    if (session.getAttribute("userStatus") != null && session.getAttribute("userStatus").equals("1")) {
        String pgprt = request.getParameter("pgprt");
%>

        <%
            if ("1".equals(pgprt)) {
        %>
                <jsp:include page="accounts.jsp" />
        <%
            } else if ("2".equals(pgprt)) {
        %>
                <jsp:include page="courses.jsp" />
        <%
            } else if ("3".equals(pgprt)) {
        %>
                <jsp:include page="questions.jsp" />
        <%
            } else if ("4".equals(pgprt)) {
        %>
                <jsp:include page="showall.jsp" />
        <%
            } else if ("5".equals(pgprt)) {
        %>
                <jsp:include page="admin-results.jsp" />
        <%
            } else if ("6".equals(pgprt)) {
        %>
                <jsp:include page="Lecturers_accounts.jsp" />
        <%
            } else {
                // Default page: Profile
                if (currentUser.getType().equalsIgnoreCase("admin")
                    || currentUser.getType().equalsIgnoreCase("lecture")) {
        %>
                    <jsp:include page="profile_staff.jsp" />
        <%
                } else {
        %>
                    <jsp:include page="profile.jsp" />
        <%
                }
            }
        %>

<%
    } else {
        // Redirect if session is invalid
        response.sendRedirect("login.jsp");
    }
%>

</body>
</html>