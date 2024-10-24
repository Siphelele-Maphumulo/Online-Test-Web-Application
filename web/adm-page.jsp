<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.classes.User"%>
<%@page import="myPackage.DatabaseClass"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <link rel="stylesheet" type="text/css" href="style-backend.css">
</head>
<body>

    <%
        // Retrieve the logged-in user details using the session attribute for userId
        User currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());

        // Check the type of user and display the corresponding panel
        if (currentUser.getType().equalsIgnoreCase("admin")) {
    %>
        <!-- Top Area for Admin Panel -->
        <div class="top-area">
            <!-- Include the header -->
            <jsp:include page="header.jsp" />
            <center><h2>Admin Panel</h2></center> 
            <!--<a href="controller.jsp?page=logout" style="float: right;background:#3b5998; color:white">Logout</a>-->
        </div>
    <%
        } else if (currentUser.getType().equalsIgnoreCase("lecture")) {
    %>
        <!-- Top Area for Lecture Panel -->
        <div class="top-area">
            <!-- Include the header -->
            <jsp:include page="header.jsp" />
            <center><h2>Lecture Panel</h2></center> 
            <!--<a href="controller.jsp?page=logout" style="float: right;background:#3b5998; color:white">Logout</a>-->
        </div>
    <%
        } else {
            // Optional: Handle other user types or unknown types (e.g., student)
    %>
        <!-- Top Area for Default Panel (for other user types, such as students) -->
        <div class="top-area">
            <!-- Include the header -->
            <jsp:include page="header.jsp" />
            <center><h2>Student Panel</h2></center> 
            <!--<a href="controller.jsp?page=logout" style="float: right;background:#3b5998; color:white">Logout</a>-->
        </div>
    <%
        }
    %>

    <%
        if (session.getAttribute("userStatus") != null && session.getAttribute("userStatus").equals("1")) {
    %>

        <%
            // Handle different parts of the dashboard (accounts, courses, questions, profile)
            if (request.getParameter("pgprt").equals("1")) {
        %>
                <!-- Include the Accounts page -->
                <jsp:include page="accounts.jsp" />
        <%
            } else if (request.getParameter("pgprt").equals("2")) {
        %>
                <!-- Include the Courses page -->
                <jsp:include page="courses.jsp" />
        <%
            } else if (request.getParameter("pgprt").equals("3")) {
        %>
                <!-- Include the Questions page -->
                <jsp:include page="questions.jsp" />
        <%
            } else if (request.getParameter("pgprt").equals("4")) {
        %>
                <!-- Include the Show All page -->
                <jsp:include page="showall.jsp" />
        <%
            } else if (request.getParameter("pgprt").equals("5")) {
        %>
                <!-- Include the Show All page -->
                <jsp:include page="result_lecture.jsp" />
        <%
            } else {
        %>
                <!-- Default is the Profile page -->
                <jsp:include page="profile.jsp" />
        <%
            }
        %>

    <%
        } else {
            // Redirect to login page if userStatus is not set or not "1"
            response.sendRedirect("login.jsp");
        }
    %>

</body>
</html>
