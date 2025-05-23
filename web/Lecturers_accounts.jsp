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
        padding-left: 5%;
    }
    #lecturerSearch {
        margin-right: 10px;
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
            <a href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
            <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Student Accounts</h2></a>
            <a class="active" href="adm-page.jsp?pgprt=6"><h2 style="color:black">Lecture Accounts</h2></a>
        </div>
    </div>
</div>

<!-- CONTENT AREA -->
<div class="content-area">
    <div class="inner" style="margin-top: 50px">
        <!-- Lecturers Table -->
        <div class="title" style="margin-top: -30px; background-color: #D8A02E">List of All Registered Lecturers</div>

        <br><br/>
        <div class="search-container">
                        <a href="Lecture_signup.jsp" class="button">
                <span class="form-button" style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
                    Add New Lecture
                </span>
            </a>
            <input type="text" id="lecturerSearch" placeholder="Search by Staff No." style="margin-right: 10%;">

        </div>


        <table id="one-column-emphasis">
            <colgroup>
                <col class="oce-first" />
            </colgroup>
            <thead>
                <tr>
                    <th scope="col">Name</th>
                    <th scope="col">Staff Number</th>
                    <th scope="col">Email</th>
                    <th scope="col">Contact</th>
                    <th scope="col">City</th>
                    <th scope="col">Address</th>
                    <th scope="col">Action</th>
                </tr>
            </thead>
            <tbody id="lecturerTableBody">
                <%
                    ArrayList<User> lecturerList = pDAO.getAllLecturers(); // Assuming you have a method for this

                    // Iterate through the lecturer list
                    for (User lecturer : lecturerList) {
                %>
                <tr>
                    <td><%= lecturer.getFirstName() + " " + lecturer.getLastName() %></td>
                    <td><%= lecturer.getUserName() %></td>
                    <td><%= lecturer.getEmail() %></td>
                    <td><%= lecturer.getContact() %></td>
                    <td><%= lecturer.getCity() %></td>
                    <td><%= lecturer.getAddress() %></td>
                    <td>
                        <a href="controller.jsp?page=Lecturers_accounts&operation=del&uid=<%= lecturer.getUserId() %>" 
                           onclick="return confirm('Are you sure you want to delete this?');">
                            <div class="delete-btn" style="max-width: 40px;font-size: 17px; padding: 3px">X</div>
                        </a>
                    </td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
            
        <br>

    </div>
</div>

<script>
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