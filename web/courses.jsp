<%@ page import="java.util.ArrayList" %>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page" />

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
    
        table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
    }

    table th, table td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }

    table th {
        background-color: #3b5998;
        color: white;
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
            <a class="active" href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
            <a href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>
            <a href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
            <!-- Administrative Tasks -->
            <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
        </div>
    </div>
</div>




<!-- CONTENT AREA -->
<div class="content-area">
    <!-- All Courses Panel -->
    <div class="panel">
        <div class="title" style="background-color: #D8A02E">All Courses</div>
        <table>
            <thead >
                <tr >
                    <th scope="col" style="background-color: rgba(74, 23, 30, 0.8);">Courses</th>
                    <th scope="col" style="background-color: rgba(74, 23, 30, 0.8);">T. Marks</th>
                    <th scope="col" style="background-color: rgba(74, 23, 30, 0.8);">Exam Date</th>
                    <th scope="col" style="background-color: rgba(74, 23, 30, 0.8);">Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                ArrayList list = pDAO.getAllCourses();
                // Assuming the list contains course name, total marks, and exam date
                for (int i = 0; i < list.size(); i += 3) {
                    if (i + 2 < list.size()) {
                %>
                <tr>
                    <td><%= list.get(i) %></td> <!-- Course name -->
                    <td><%= list.get(i + 1) %></td> <!-- Total marks -->
                    <td><%= list.get(i + 2) %></td> <!-- Exam date -->
                    <td>
                        <a href="controller.jsp?page=courses&operation=del&cname=<%= list.get(i) %>"
                           onclick="return confirm('Are you sure you want to delete this?');" class="del">
                           <div class="delete-btn" style="background-color: red; color: white; padding: 5px; border-radius: 5px;">X</div>
                        </a>
                    </td>
                </tr>
                <%
                    }
                }
                %>
            </tbody>
        </table>
    </div>

    <!-- Add New Course Panel -->
    <div class="panel">
        <div class="title" style="background-color: #D8A02E">Add New Course</div>
        <form action="controller.jsp">
            <table>
                <tr>
                    <td><label>Course Name</label></td>
                    <td><input type="text" name="coursename" class="text" placeholder="Course Name" required></td>
                </tr>
                <tr>
                    <td><label>Total Marks</label></td>
                    <td><input type="text" name="totalmarks" class="text" placeholder="Total Marks" required></td>
                </tr>
                <tr>
                    <td><label>Exam Time</label></td>
                    <td><input type="text" name="time" class="text" placeholder="MM" required></td>
                </tr>
                <tr>
                    <td><label>Exam Date</label></td>
                    <td><input type="date" name="examdate" class="text" required></td> <!-- New date input -->
                </tr>
                <tr>
                    <td colspan="2">
                        <input type="hidden" name="page" value="courses">
                        <input type="hidden" name="operation" value="addnew">
                    <center>
                        <input type="submit" class="form-button" value="Add" 
                               style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
                    </center>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</div>
