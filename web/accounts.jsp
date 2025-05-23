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
    .search-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin: 10px 0;
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
            <a href="adm-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <a href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
<!--            <a href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>-->
            <a href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
            <a class="active" href="adm-page.jsp?pgprt=1"><h2 style="color:black">Student Accounts</h2></a>
            <a href="adm-page.jsp?pgprt=6"><h2 style="color:black">Lecture Accounts</h2></a>
        </div>
    </div>
</div>

<!-- CONTENT AREA -->
<div class="content-area">
    <div class="inner" style="margin-top: 50px">
        <!-- Students Table -->
        <div class="title" style="margin-top: -30px; background-color: #D8A02E">List of All Registered Students</div>
        
        <br><br/>
        <div class="search-container" style="padding-left: 5%">
                        <a href="signup.jsp?from=account" class="button">
                <span class="form-button" style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
                    Add New Student
                </span>
            </a>
            <input type="text" id="studentSearch" placeholder="Search by Student No." style="margin-right: 10%;">

        </div>
        
        <table id="one-column-emphasis">
            <colgroup>
                <col class="oce-first" />
            </colgroup>
            <thead>
                <tr>
                    <th scope="col">Name</th>
                    <th scope="col">Student Number</th>
                    <th scope="col">Email</th>
                    <th scope="col">Contact</th>
                    <th scope="col">City</th>
                    <th scope="col">Address</th>
                    <th scope="col">Action</th>
                </tr>
            </thead>
            <tbody id="studentTableBody">
                <%
                    User currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());
                    ArrayList<User> studentList = pDAO.getAllStudents();
                    
                    // Iterate through the student list
                    for (User user : studentList) {
                        if (user.getUserId() != Integer.parseInt(session.getAttribute("userId").toString())) {
                            // Show students based on the user type
                            if (currentUser.getType().equalsIgnoreCase("lecture") && user.getType().equalsIgnoreCase("student") ||
                                currentUser.getType().equalsIgnoreCase("admin")) {
                %>
                                <tr>
                                    <td><%= user.getFirstName() + " " + user.getLastName() %></td>
                                    <td><%= user.getUserName() %></td>
                                    <td><%= user.getEmail() %></td>
                                    <td><%= user.getContact() %></td>
                                    <td><%= user.getCity() %></td>
                                    <td><%= user.getAddress() %></td>
                                    <td>
                                    <!-- In the table body where you have the delete link for each student -->
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

        <br>

     
    
    </div>
</div>

<script>
    // Function to filter students
    document.getElementById('studentSearch').onkeyup = function() {
        var input = this.value.toLowerCase();
        var table = document.getElementById("studentTableBody");
        var rows = table.getElementsByTagName("tr");
        
        for (var i = 0; i < rows.length; i++) {
            var cells = rows[i].getElementsByTagName("td");
            var match = false;
            if (cells.length > 0) {
                for (var j = 0; j < cells.length; j++) {
                    if (cells[j].textContent.toLowerCase().includes(input)) {
                        match = true;
                        break;
                    }
                }
                rows[i].style.display = match ? "" : "none";
            }
        }
    };

    // Function to filter lecturers
    document.getElementById('lecturerSearch').onkeyup = function() {
        var input = this.value.toLowerCase();
        var table = document.getElementById("lecturerTableBody");
        var rows = table.getElementsByTagName("tr");
        
        for (var i = 0; i < rows.length; i++) {
            var cells = rows[i].getElementsByTagName("td");
            var match = false;
            if (cells.length > 0) {
                for (var j = 0; j < cells.length; j++) {
                    if (cells[j].textContent.toLowerCase().includes(input)) {
                        match = true;
                        break;
                    }
                }
                rows[i].style.display = match ? "" : "none";
            }
        }
    };
</script>