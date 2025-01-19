<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<style>
    .sidebar {
        width: 250px;
        height: 100vh;
        background-color: black;
        position: fixed;
        top: 0;
        left: 0;
        color: white;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }    
</style>

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
            <a href="adm-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <!-- Academic Management -->
            <a href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
            <a href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>
            <a href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
            <!-- Administrative Tasks -->
            <a class="active" href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
        </div>
    </div>
</div>


<!-- CONTENT AREA -->
<div class="content-area">
    <div class="inner" style="margin-top: 50px">
        <div class="title" style="margin-top: -30px" style="background-color: #D8A02E">List of All Registered Students</div>
        
        <br><br><br/>
        <div style="padding-left: 5%">
            <!-- Passing the "from=account" parameter in the link to indicate the user is coming from the Accounts page -->
            <a href="signup.jsp?from=account" class="button">
                <span class="form-button" style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
                    Add New Student
                </span>
            </a>
        </div>
        
        <br>

        <table id="one-column-emphasis">
            <colgroup>
                <col class="oce-first" />
            </colgroup>
            <thead>
                <tr>
                    <th scope="col">Name</th>
                    <th scope="col">Email</th>
                    <th scope="col">City</th>
                    <th scope="col">Address</th>
                    <th scope="col">Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    User currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());
                    ArrayList<User> list = pDAO.getAllUsers();
                    User user;
                    
                    // Iterate through the user list
                    for (int i = 0; i < list.size(); i++) {
                        user = list.get(i);

                        // Only show users that are not the current user and apply filters based on role
                        if (user.getUserId() != Integer.parseInt(session.getAttribute("userId").toString())) {

                            // If the logged-in user is a lecturer, show only student accounts
                            if (currentUser.getType().equalsIgnoreCase("lecture") && user.getType().equalsIgnoreCase("student")) {
                %>
                                <tr>
                                    <td><%= user.getFirstName() + " " + user.getLastName() %></td>
                                    <td><%= user.getEmail() %></td>
                                    <td><%= user.getCity() %></td>
                                    <td><%= user.getAddress() %></td>
                                    <td>
                                        <a href="controller.jsp?page=accounts&operation=del&uid=<%= user.getUserId() %>" 
                                           onclick="return confirm('Are you sure you want to delete this?');">
                                            <div class="delete-btn" style="max-width: 40px;font-size: 17px; padding: 3px">X</div>
                                        </a>
                                    </td>
                                </tr>
                <%
                            // If the logged-in user is an admin, show all accounts
                            } else if (currentUser.getType().equalsIgnoreCase("admin")) {
                %>
                                <tr>
                                    <td><%= user.getFirstName() + " " + user.getLastName() %></td>
                                    <td><%= user.getEmail() %></td>
                                    <td><%= user.getCity() %></td>
                                    <td><%= user.getAddress() %></td>
                                    <td>
                                        <a href="controller.jsp?page=accounts&operation=del&uid=<%= user.getUserId() %>" 
                                           onclick="return confirm('Are you sure you want to delete this?');">
                                            <div class="delete-btn" style="max-width: 40px;font-size: 17px; padding: 3px">X</div>
                                        </a>
                                    </td>
                                </tr>
                <%
                            }
                        }
                    }
                %>
            </tbody>
        </table>
    </div>
</div>
