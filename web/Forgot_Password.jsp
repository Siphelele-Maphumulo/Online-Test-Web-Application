<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<%
    User user = pDAO.getUserDetails(session.getAttribute("userId").toString());

    // Check if the user is either an admin or a lecturer
    if (user.getType().equalsIgnoreCase("admin") || user.getType().equalsIgnoreCase("lecture")) {
%>
<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-background" style="background-color:#F3F3F3; color:black">
        <!-- Logo Section -->
        <div style="text-align: center; margin: 20px 0;">
            <img src="IMG/mut.png" alt="MUT Logo" style="max-height: 120px;">
        </div>
        <!-- Navigation Menu -->
        <div class="left-menu">
            <!-- Profile Section -->
            <a class="active"  href="adm-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <!-- Academic Management -->
            <a href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
            <a href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>
            <a href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
            <!-- Administrative Tasks -->
            <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
        </div>
    </div>
</div>

    <!-- CONTENT AREA -->
    <div class="content-area">
        <div class="panel" style="float: left;max-width: 600px">

<%
    } else {
%>
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="sidebar-background" style="background-color:#F3F3F3; color:black">
            <div style="flex: 1;">
                <img src="IMG/mut.png" alt="MUT Logo" style="max-height: 120px;">
            </div>
            <div class="left-menu">
                <a class="active" href="std-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
                <a href="std-page.jsp?pgprt=1"><h2 style="color:black">Exams</h2></a>
                <a href="std-page.jsp?pgprt=2"><h2 style="color:black">Results</h2></a>
            </div>
        </div>
    </div>
    <!-- CONTENT AREA -->
    <div class="content-area">
        <div class="panel" style="float: left;max-width: 600px">
<%
    }

    if (request.getParameter("pedt") == null) {
%>
    <div class="title" style="background-color: #D8A02E">Profile</div>
    <div class="profile">
        <h2>
            <span class="tag" style="background-color: rgba(74, 23, 30, 0.8);">Your Name</span><span class="val"><%= user.getFirstName() + " " %><%= user.getLastName() %></span><br/>
            <span class="tag" style="background-color: rgba(74, 23, 30, 0.8);">Email</span><span class="val"><%= user.getEmail() %></span><br/>
            <span class="tag" style="background-color: rgba(74, 23, 30, 0.8);">Contact No</span><span class="val"><%= user.getContact() %></span><br/>
            <span class="tag" style="background-color: rgba(74, 23, 30, 0.8);">City</span><span class="val"><%= user.getCity() %></span><br/>
            <span class="tag" style="background-color: rgba(74, 23, 30, 0.8);">Address</span><span class="val"><%= user.getAddress() %></span>
        </h2>
    </div>
    <br/>
    <a href="<%= user.getType().equals("admin") || user.getType().equals("lecture") ? "adm-page.jsp" : "std-page.jsp" %>?pgprt=0&pedt=1">
        <span class="form-button" style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
            Edit Profile
        </span>
    </a>
<%
    } else {
%>
<!-- Start of Edit Form -->
<div class="title">Edit Profile</div>
<div class="central-div form-style-6" style="position:inherit;margin-top: 70px;">
    <form action="controller.jsp">
        <input type="hidden" name="page" value="profile">
        <input type="hidden" name="utype" value="<%= user.getType() %>">
        <table>
            <tr>
                <td><label>First Name</label></td>
                <td><input type="text" name="fname" value="<%= user.getFirstName() %>" class="text" 
                         placeholder="First Name" readonly></td>
            </tr>
            <tr>
                <td><label>Last Name</label></td>
                <td><input type="text" name="lname" value="<%= user.getLastName() %>" class="text" 
                         placeholder="Last Name" readonly></td>
            </tr>
            <tr>
                <td><label>User Name</label></td>
                <td><input type="text" name="uname" value="<%= user.getUserName() %>" class="text" 
                         placeholder="User Name" readonly></td>
            </tr>
            <tr>
                <td><label>Email</label></td>
                <td><input type="email" name="email" value="<%= user.getEmail() %>" class="text" 
                         placeholder="Email" readonly></td>
            </tr>
            <tr>
                <td><label>Password</label></td>
                <td><input type="password" name="pass" class="text" 
                         placeholder="New Password (leave blank to keep current)"></td>
            </tr>
            <tr>
                <td><label>Contact No</label></td>
                <td><input type="text" name="contactno" value="<%= user.getContact() %>" class="text" 
                         placeholder="Contact No" readonly></td>
            </tr>
            <tr>
                <td><label>City</label></td>
                <td><input type="text" name="city" value="<%= user.getCity() %>" class="text" 
                         placeholder="City" readonly></td>
            </tr>
            <tr>
                <td><label>Address</label></td>
                <td><input type="text" name="address" value="<%= user.getAddress() %>" class="text" 
                         placeholder="Address" readonly></td>
            </tr>
            <tr>
                <td></td>
                <td>
                    <center>
                        <input type="submit" class="form-button" value="Done" 
                            style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
                    </center>
                </td>
            </tr>
        </table>
    </form>
</div>
<%
    }
%>