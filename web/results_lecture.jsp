<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-background" style="background-color:#F3F3F3; color:black">
        <!-- Logo on the left -->
        <div style="flex: 1;">
            <img src="IMG/mut.png" alt="MUT Logo" style="max-height: 120px;">
        </div>

        <div class="left-menu">
            <a href="adm-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <a href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
            <a href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>
            <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
            <a class="active" href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
        </div>
    </div>
</div>

<!-- CONTENT AREA -->
<div class="content-area">
    <div class="panel" style="float: left; max-width: 900px">

        <% if (request.getParameter("eid") == null) { %>
            <div class="title" style="background-color: #D8A02E">All Results</div>
            <table id="rounded-corner">
                <thead>
                    <tr>
                        <th scope="col" class="rounded-company">Date</th>
                        <th scope="col" class="rounded-q1">Course</th>
                        <th scope="col" class="rounded-q2">Time</th>
                        <th scope="col" class="rounded-q2">Marks</th> <!-- New column for Marks -->
                        <th scope="col" class="rounded-q3">Status</th>
                        <th scope="col" class="rounded-q4">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        // Now calling without student ID to get results for all students
                        ArrayList<Exams> list = pDAO.getResultsFromExams();
                        for (int i = 0; i < list.size(); i++) {
                            Exams e = list.get(i);
                    %>
                    <tr>
                        <td><%= e.getFullName() %></td>
                        <td><%= e.getDate() %></td> <!-- Displaying the exam date -->
                        <td><%= e.getcName() %></td> <!-- Displaying the course name -->
                        <td><%= e.getStartTime() + " - " + e.getEndTime() %></td> <!-- Displaying the time -->
                        <td><%= e.getObtMarks() %> / <%= e.gettMarks() %></td> <!-- Displaying marks obtained and total marks -->
                        <% if (e.getStatus() != null) {
                            if (e.getStatus().equals("Pass")) { %>
                                <td style="background: #00cc33; color:white"><%= e.getStatus() %></td>
                            <% } else { %>
                                <td style="background: #ff3333; color:white"><%= e.getStatus() %></td>
                            <% } 
                        } else { %>
                            <td style="background: bisque;">Terminated</td>
                        <% } %>
                        <td><a href="std-page.jsp?pgprt=2&eid=<%= e.getExamId() %>">Details</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="title">Result Details</div>
            <table id="gradient-style">
                <%
                    ArrayList<Answers> list = pDAO.getAllAnswersByExamId(
                        Integer.parseInt(request.getParameter("eid"))
                    );
                    for (int i = 0; i < list.size(); i++) {
                        Answers a = list.get(i);
                %>
                <tr>
                    <td rowspan="2"><%= i + 1 %>)</td>
                    <td colspan="2"><%= a.getQuestion() %></td>
                    <td rowspan="2">
                        <% if (a.getStatus().equals("correct")) { %>
                            <span style="color: green;"><%= a.getStatus() %></span>
                        <% } else { %>
                            <span style="color: red;"><%= a.getStatus() %></span>
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <td><%="Your Ans: " + a.getAnswer() %></td>
                    <td><%="Correct Ans: " + a.getCorrectAns() %></td>
                </tr>
                <tr>
                    <td colspan="3" style="background: white"></td>
                <% } %>
            </table>
        <% } %>
    </div>
</div>
